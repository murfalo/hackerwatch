namespace Modifiers
{
	class FlameShield : Modifier, IBuffWidgetInfo
	{
		float m_dmgTakenMul;

		int m_cooldown;
		int m_cooldownC;

		uint m_fxHash;
		uint m_fxChargeHash;

		UnitScene@ m_fx;
		UnitScene@ m_fxCharge;

		ScriptSprite@ m_cooldownIcon;

		array<IEffect@>@ m_effects;

		FlameShield() { }
		FlameShield(UnitPtr unit, SValue& params)
		{
			m_dmgTakenMul = GetParamFloat(unit, params, "dmg-taken-mul", false, 1);

			m_cooldown = GetParamInt(unit, params, "cooldown");

			m_fxHash = HashString(GetParamString(unit, params, "fx", false));
			@m_fx = Resources::GetEffect(m_fxHash);

			m_fxChargeHash = HashString(GetParamString(unit, params, "fx-charge", false));
			@m_fxCharge = Resources::GetEffect(m_fxChargeHash);

			@m_cooldownIcon = ScriptSprite(GetParamArray(unit, params, "hud-cooldown"));

			@m_effects = LoadEffects(unit, params);
		}

		Modifier@ Instance() override
		{
			auto ret = FlameShield();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasDamageTakenMul() override { return true; }
		float DamageTakenMul(PlayerBase@ player, DamageInfo &di) override
		{
			if (m_cooldownC > 0)
				return 1;

			if (di.Attacker !is player)
			{
				vec2 dir;
				if (di.Attacker !is null)
					dir = normalize(xy(player.m_unit.GetPosition()) - xy(di.Attacker.m_unit.GetPosition()));

%if !HARDCORE
				auto skill = cast<Skills::Explode>(player.m_skills[2]);
				if (skill !is null)
				{
					skill.DoTrigger(dir);
					(Network::Message("PlayerActiveSkillActivate") << int(skill.m_skillId) << dir).SendToAll();
				}
%endif

				if (m_effects !is null && m_effects.length() > 0)
				{
					vec2 pos = xy(player.m_unit.GetPosition());
					bool isHusk = (cast<PlayerHusk>(player) !is null);
					ApplyEffects(m_effects, player, player.m_unit, pos, dir, 1.0f, isHusk);
				}
			}

			m_cooldownC = m_cooldown;

			auto hud = GetHUD();
			if (hud !is null)
				hud.ShowBuffIcon(player, this);

			PlayEffect(m_fx, player.m_unit);
			(Network::Message("AttachEffect") << m_fxHash << player.m_unit).SendToAll();

			return m_dmgTakenMul;
		}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt) override
		{
			if (m_cooldownC <= 0)
				return;

			m_cooldownC -= dt;
			if (m_cooldownC < 0)
			{
				PlayEffect(m_fxCharge, player.m_unit);
				(Network::Message("AttachEffect") << m_fxHash << player.m_unit).SendToAll();
			}
		}

		ScriptSprite@ GetBuffIcon() { return m_cooldownIcon; }
		int GetBuffIconDuration() { return m_cooldownC; }
		int GetBuffIconMaxDuration() { return m_cooldown; }
		int GetBuffIconCount() { return -1; }
	}
}
