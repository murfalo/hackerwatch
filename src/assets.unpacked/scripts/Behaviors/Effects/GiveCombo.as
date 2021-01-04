class GiveCombo : IEffect
{
	int m_time;

	GiveCombo(UnitPtr unit, SValue& params)
	{
		m_time = GetParamInt(UnitPtr(), params, "time", false, 2000);
	}

	void SetWeaponInformation(uint weapon) { }

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto player = cast<Player>(target.GetScriptBehavior());
		if (player !is null && !g_allModifiers.ComboDisabled(player))
		{
			if (player.m_comboCount < 10)
				player.m_comboCount = 10;
			player.m_comboTime = m_time + player.m_record.GetModifiers().ComboProps(player).z;

			(Network::Message("PlayerCombo") << true << player.m_comboTime << player.m_comboCount).SendToAll();
		}

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}
