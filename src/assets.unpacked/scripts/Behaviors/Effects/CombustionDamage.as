class CombustionDamage : Damage
{
	CombustionDamage(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}

	void ToggleCombustion(PlayerBase@ player, bool enabled)
	{
		if (player is null)
			return;

		Skills::CombustionSkill@ combust = null;
		for (uint i = 4; i < player.m_skills.length(); i++)
		{
			@combust = cast<Skills::CombustionSkill>(player.m_skills[i]);
			if (combust !is null)
				break;
		}

		if (combust is null)
			return;

		for (uint i = 0; i < combust.m_modifiers.length(); i++)
		{
			auto trigEffect = cast<Modifiers::CombustionTriggerEffect>(combust.m_modifiers[i]);
			if (trigEffect !is null)
				trigEffect.m_enabled = enabled;
		}
	}

	int DoDamage(IDamageTaker@ target, DamageInfo di, vec2 pos, vec2 dir) override
	{
		auto player = cast<PlayerBase>(di.Attacker);

		ToggleCombustion(player, false);
		int ret = Damage::DoDamage(target, di, pos, dir);
		ToggleCombustion(player, true);

		return ret;
	}
}
