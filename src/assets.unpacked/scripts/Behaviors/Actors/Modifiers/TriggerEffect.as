namespace Modifiers
{
	class TriggerEffect : Modifier, IBuffWidgetInfo
	{
		bool m_enabled;
		float m_chance;
		array<IEffect@>@ m_effects;
		uint m_weaponInfo;
		bool m_targetSelf;
		string m_fx;
		string m_selfFx;
		EffectTrigger m_trigger;
		uint m_timeout;
		int m_timeoutC;
		int m_counter;
		int m_counterC;

		bool m_useAttackSpeed;
		bool m_ignoreNoLootUnits;
		
		SyncVerb m_verb;
		uint m_verbId;
		uint m_modId;

		float m_intensity;

		ScriptSprite@ m_cooldownIcon;

		float m_requiredHp;

		TriggerEffect() {}
		TriggerEffect(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", false, 10);
			m_counterC = m_counter = GetParamInt(unit, params, "counter", false, 0);
			@m_effects = LoadEffects(unit, params);
			m_weaponInfo = GetParamInt(unit, params, "weapon-info", false, 0);
			m_targetSelf = GetParamBool(unit, params, "target-self", false, false);
			m_trigger = ParseEffectTrigger(GetParamString(unit, params, "trigger", false));
			m_fx = GetParamString(unit, params, "fx", false);
			m_selfFx = GetParamString(unit, params, "self-fx", false);
			m_timeout = GetParamInt(unit, params, "timeout", false);
			m_intensity = GetParamFloat(unit, params, "intensity", false, 1.0f);
			m_useAttackSpeed = GetParamBool(unit, params, "use-attack-speed", false, false);
			m_ignoreNoLootUnits = GetParamBool(unit, params, "ignore-no-loot-units", false, false);
			m_requiredHp = GetParamFloat(unit, params, "required-hp", false, 1.0f);
			m_enabled = true;

			auto arrIcon = GetParamArray(unit, params, "hud-cooldown", false);
			if (arrIcon !is null)
				@m_cooldownIcon = ScriptSprite(arrIcon);
		}

		Modifier@ Instance() override
		{
			auto ret = TriggerEffect();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt) override
		{
			if (m_timeoutC > 0)
			{
				if (m_useAttackSpeed)
				{
					if (m_weaponInfo == 1)
						dt = int(dt * player.m_currentAttackSpeed.x);
					else
						dt = int(dt * player.m_currentAttackSpeed.y);
				}

				m_timeoutC -= dt;
			}
		}
		
		void Initialize(SyncVerb verb, uint id, uint modId) override
		{
			m_verb = verb;
			m_verbId = id;
			m_modId = modId;

			if (m_verb == SyncVerb::None)
			{
				PrintError("Trigger effect modifier unsyncable: No netsync verb set!");
				DumpStack();
			}

			PropagateWeaponInformation(m_effects, m_weaponInfo);
		}
		
		void NetTrigger(PlayerBase@ player, UnitPtr target)
		{	
			if (!target.IsValid())
				return;
				
			if (player is null)
				return;

			vec2 targetPos = xy(target.GetPosition());
			vec2 dir = (target != player.m_unit) ? normalize(xy(target.GetPosition() - player.m_unit.GetPosition())) : vec2(cos(player.m_dirAngle), sin(player.m_dirAngle));
			
			ApplyEffects(m_effects, player, target, targetPos, dir, m_intensity, true);
			
			if (m_selfFx != "")
			{
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_selfFx, xy(player.m_unit.GetPosition()), ePs);
			}
			if (m_fx != "")
			{		
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_fx, targetPos, ePs);
			}
		}
		
		void Trigger(PlayerBase@ player, UnitPtr target)
		{
			if (!m_enabled)
				return;
			
			if (!target.IsValid())
				return;

			vec2 targetPos = xy(target.GetPosition());
			vec2 dir = (target != player.m_unit) ? normalize(xy(target.GetPosition() - player.m_unit.GetPosition())) : vec2(cos(player.m_dirAngle), sin(player.m_dirAngle));
			
			if (m_verb != Modifiers::SyncVerb::None && !target.IsDestroyed())
				(Network::Message("ModifierTriggerEffect") << int(m_verb) << m_verbId << m_modId << target).SendToAll();
			
			ApplyEffects(m_effects, player, target, targetPos, dir, m_intensity, false);
			
			if (m_selfFx != "")
			{
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_selfFx, xy(player.m_unit.GetPosition()), ePs);
			}
			if (m_fx != "")
			{		
				dictionary ePs = { { 'angle', atan(dir.y, dir.x) } };
				PlayEffect(m_fx, targetPos, ePs);
			}
		}
		
		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, EffectTrigger trigger) override
		{ 
			if (m_trigger != trigger)
				return;
		
			if (!roll_chance(player, m_chance))
				return;

			if (m_timeoutC > 0)
				return;
			
			m_timeoutC = m_timeout;

			if (m_timeoutC > 0 && m_cooldownIcon !is null)
			{
				auto hud = GetHUD();
				if (hud !is null)
					hud.ShowBuffIcon(player, this);
			}

			if (m_counter > 0)
			{
				if (--m_counterC > 0)
					return;

				m_counterC = m_counter;
			}
			
			if (m_ignoreNoLootUnits && enemy !is null)
			{
				auto behavior = cast<CompositeActorBehavior>(enemy);
				if (behavior !is null && behavior.m_noLoot)
					return;
			}

			UnitPtr target;
			if (m_targetSelf)
			{
				target = player.m_unit;

				if (player.GetHealth() > m_requiredHp)
					return;
			}
			else if (enemy !is null)
			{
			
				target = enemy.m_unit;
				if (!enemy.IsTargetable())
					return;

				if (enemy.GetHealth() > m_requiredHp)
					return;
			}
			
			Trigger(player, target);
		}

		ScriptSprite@ GetBuffIcon() { return m_cooldownIcon; }
		int GetBuffIconDuration() { return m_timeoutC; }
		int GetBuffIconMaxDuration() { return m_timeout; }
		int GetBuffIconCount() { return -1; }
	}
}

bool roll_chance(PlayerBase@ player, float chance, bool flipLuck = false)
{
	if (player !is null && player.m_record !is null && player.m_record.IsLocalPlayer()) {
		chance *= GetVarFloat("hx_roll_chance");
	}

	float c = clamp(chance, 0.0f, 1.0f);
	if (player !is null && player.m_currLuck != 0)
	{
		float l = player.m_currLuck * (flipLuck ? -1 : 1);
		c = 1 - pow(1 - c, pow(2, l / 10.0f));
	}
	
	return randf() <= c;
}