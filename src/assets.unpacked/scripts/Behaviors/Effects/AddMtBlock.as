class AddMtBlock : IEffect
{
	int m_amount;

	UnitScene@ m_fxChargeLunarShield;

	AddMtBlock(UnitPtr unit, SValue& params)
	{
		m_amount = GetParamInt(unit, params, "amount");

		@m_fxChargeLunarShield = Resources::GetEffect("effects/players/lunar_shield_charge.effect");
	}

	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto plr = cast<PlayerBase>(target.GetScriptBehavior());
		if (plr is null)
			return false;

		plr.m_record.mtBlocks += m_amount;

		PlayEffect(m_fxChargeLunarShield, plr.m_unit);

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		auto plr = cast<PlayerBase>(target.GetScriptBehavior());
		if (plr is null)
			return false;

		if (plr.m_record.ngps["mt"] == 0)
			return false;

		return true;
	}
}
