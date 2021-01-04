class LifestealDamage : Damage
{
	float m_lifesteal;
	float m_manasteal;

	uint m_fxAttackerHash;
	UnitScene@ m_fxAttacker;

	LifestealDamage(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_lifesteal = GetParamFloat(unit, params, "lifesteal");
		m_manasteal = GetParamFloat(unit, params, "manasteal");

		m_fxAttackerHash = HashString(GetParamString(unit, params, "lifesteal-attacker-effect", false));
		@m_fxAttacker = Resources::GetEffect(m_fxAttackerHash);
	}

	int DoDamage(IDamageTaker@ target, DamageInfo di, vec2 pos, vec2 dir) override
	{
		int dmg = Damage::DoDamage(target, di, pos, dir);

		if (di.Attacker !is null)
		{
			di.Attacker.Heal(roll_round(dmg * m_lifesteal));

			auto player = cast<Player>(di.Attacker);
			if (player !is null)
				player.GiveMana(roll_round(dmg * m_manasteal));

			PlayEffect(m_fxAttacker, di.Attacker.m_unit);
			(Network::Message("AttachEffect") << m_fxAttackerHash << di.Attacker.m_unit).SendToAll();
		}

		return dmg;
	}
}
