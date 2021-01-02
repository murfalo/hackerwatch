class GiveLives : IEffect
{
	int m_lives;

	GiveLives(UnitPtr unit, SValue& params)
	{
		m_lives = GetParamInt(unit, params, "lives", false, 1);
	}

	void SetWeaponInformation(uint weapon) {}
	
	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto gm = cast<BaseGameMode>(g_gameMode);
		gm.m_extraLives += m_lives;
		(Network::Message("ExtraLives") << gm.m_extraLives).SendToAll();

		GetHUD().SetExtraLife();

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		if (cast<BaseGameMode>(g_gameMode) is null)
			return false;

		if (cast<Player>(target.GetScriptBehavior()) is null)
			return false;

		return true;
	}
}