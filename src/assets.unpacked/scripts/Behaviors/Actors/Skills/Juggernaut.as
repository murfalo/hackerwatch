namespace Skills
{
	class Juggernaut : Skill
	{
		array<IEffect@>@ m_effects;
		Modifiers::TriggerEffect@ m_bash;
		
		uint m_cooldown;
		uint m_lastHitTime;
		UnitPtr m_lastUnit;
	
		Juggernaut(UnitPtr unit, SValue& params)
		{
			super(unit);
			
			@m_effects = LoadEffects(unit, params);
			
			m_cooldown = GetParamInt(unit, params, "cooldown", false, 1);
			
			auto stunningBlows = cast<Skills::PassiveSkill>(cast<PlayerBase>(m_owner).m_skills[5]);
			if (stunningBlows !is null)
				@m_bash = cast<Modifiers::TriggerEffect>(stunningBlows.m_modifiers[0]);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			Skill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
		}
		
		void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxOther) override
		{
			if (fxOther.IsSensor())
				return;
				
			auto nowT = g_scene.GetTime();
			if (m_lastUnit == unit)
			{
				if ((m_lastHitTime + m_cooldown) > nowT)
					return;
			}
				
			m_lastUnit = unit;

			auto player = cast<PlayerHusk>(unit.GetScriptBehavior());
			if (player !is null)
				return;

			ApplyEffects(m_effects, m_owner, unit, pos, vec2(-normal.x, -normal.y), 1.0f, false, 0.0f, 0.0f, 1.0);
			m_lastHitTime = nowT;
			
			auto a = cast<Actor>(unit.GetScriptBehavior());
			if (m_bash !is null && a !is null && a.Team != m_owner.Team)
				m_bash.TriggerEffects(cast<Player>(m_owner), a, Modifiers::EffectTrigger::Hit);
		}
	}
}
