class DecimateGold : IEffect
{
	float m_amount;

	DecimateGold(UnitPtr unit, SValue& params)
	{
		m_amount = GetParamFloat(unit, params, "amount", false, 0.0f);
	}

	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		auto player = cast<PlayerBase>(target.GetScriptBehavior());
		if (player is null)
			return false;

		int takeGold = int(int(player.m_record.runGold) * m_amount);
		player.m_record.runGold -= takeGold;
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		return (cast<PlayerBase>(target.GetScriptBehavior()) !is null);
	}
}
