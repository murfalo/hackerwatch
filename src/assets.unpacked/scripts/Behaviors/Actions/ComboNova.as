class ComboNova : Nova
{
	int m_level = 0;

	ComboNova(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_level = GetParamInt(unit, params, "level");
	}

	UnitProducer@ GetProducer(Actor@ owner) override
	{
		auto player = cast<PlayerBase>(owner);
		if (player is null)
			return null;

		auto style = player.m_comboStyle;
		if (style is null)
			return null;

		if (m_level == 0 || m_level > int(style.m_projectiles.length()))
		{
			PrintError("Unable to find level " + m_level + " for combo nova projectiles in style \"" + style.m_id + "\"!");
			return null;
		}

		return style.m_projectiles[m_level - 1];
	}
}
