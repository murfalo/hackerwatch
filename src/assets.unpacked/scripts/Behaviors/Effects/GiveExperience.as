class GiveExperience : IEffect
{
	int m_exp;
	float m_expScalar;

	GiveExperience(UnitPtr unit, SValue& params)
	{
		m_exp = GetParamInt(unit, params, "exp", false);
		m_expScalar = GetParamFloat(unit, params, "exp-scalar", false);
	}

	void SetWeaponInformation(uint weapon) {}
	
	int GetExp(PlayerRecord@ record)
	{
		if (m_exp > 0)
			return m_exp;
		int xpStart = record.LevelExperience(record.level - 1);
		int xpEnd = record.LevelExperience(record.level) - xpStart;
		return int(m_expScalar * xpEnd);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		Player@ plr = cast<Player>(target.GetScriptBehavior());
		int amount = int(GetExp(plr.m_record) * intensity);
		plr.m_record.GiveExperience(amount);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		Player@ plr = cast<Player>(target.GetScriptBehavior());
		if (plr is null)
			return false;

		int amount = int(GetExp(plr.m_record) * intensity);
		if (amount <= 0)
			return false;

		return true;
	}
}