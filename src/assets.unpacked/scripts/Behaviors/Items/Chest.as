class Chest : IUsable
{
	UnitPtr m_unit;
	int m_lock;
	LootDef@ m_lootDef;
	SoundEvent@ m_openSnd;

	Chest(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		m_lock = GetParamInt(unit, params, "lock");
		@m_lootDef = LoadLootDef(GetParamString(unit, params, "loot", false));
		@m_openSnd = Resources::GetSoundEvent(GetParamString(unit, params, "open-snd", false));
	}
	
	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		if (fxSelf.IsSensor())
			player.AddUsable(this);
	}

	void EndCollision(UnitPtr unit, Fixture@ fxSelf, Fixture@ fxOther)
	{
		Player@ player = cast<Player>(unit.GetScriptBehavior());
		if (player is null)
			return;

		if (fxSelf.IsSensor())
			player.RemoveUsable(this);
	}

	UnitPtr GetUseUnit()
	{
		return m_unit;
	}

	bool CanUse(PlayerBase@ player)
	{
		if (!m_unit.IsValid() || m_unit.IsDestroyed())
			return false;
	
		if (m_lock < 0)
			return true;

		if (cast<PlayerHusk>(player) !is null)
			return true;
			
		return player.m_record.keys[m_lock] > 0;
	}

	void Use(PlayerBase@ player)
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
			Stats::Add("chest-used-" + m_lock, 1, player.m_record);
		}
		else
			Stats::Add("chest-used-wood", 1, player.m_record);

		if (Network::IsServer())
		{
			m_unit.Destroy();

			if (m_lootDef !is null)
				m_lootDef.Spawn(xy(m_unit.GetPosition()));
		}

		Stats::Add("chests-opened", 1, player.m_record);
		PlaySound3D(m_openSnd, m_unit.GetPosition());
	}

	void NetUse(PlayerHusk@ player)
	{
		Use(player);
	}

	UsableIcon GetIcon(Player@ player)
	{
		if (!CanUse(player))
			return UsableIcon::Cross;

		if (m_lock < 0)
			return UsableIcon::Generic;
		else
			return UsableIcon::Key;
	}

	int UsePriority(IUsable@ other) { return 0; }
}
