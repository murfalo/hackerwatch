class SpawnDjinn : IEffect
{
	SpawnDjinn(UnitPtr unit, SValue& params)
	{
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		auto player = cast<Player>(owner);
		if (player is null)
			return false;

		player.SpawnDjinn();
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		auto player = cast<PlayerBase>(owner);
		if (player is null)
			return false;

		return (player.m_record.ngps["pop"] > 0);
	}

	void SetWeaponInformation(uint weapon) { }
}
