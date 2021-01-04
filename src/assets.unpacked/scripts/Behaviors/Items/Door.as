class Door : Chest
{
	Door(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}

	void Use(PlayerBase@ player) override
	{
		if (m_unit.IsDestroyed() || !m_unit.IsValid())
			return;

		if (m_lock >= 0)
		{
			if (player.m_record.keys[m_lock] <= 0 && cast<PlayerHusk>(player) is null)
			{
				AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".hud.nokey"), player.m_unit.GetPosition());
				print("No key!");
				return;
			}

			player.m_record.keys[m_lock]--;
		}

		auto plr = cast<Player>(player);
		if (plr !is null)
			plr.RemoveUsable(this);

		m_unit.SetUnitScene("open", true);
		PlaySound3D(m_openSnd, m_unit.GetPosition());
	}

	void NetUse(PlayerHusk@ player) override
	{
		Chest::NetUse(player);

		auto localPlayer = GetLocalPlayer();
		if (localPlayer !is null && localPlayer.FindUsable(this) != -1)
			localPlayer.RemoveUsable(this);
	}
}
