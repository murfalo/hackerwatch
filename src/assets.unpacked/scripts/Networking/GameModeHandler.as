namespace GameModeHandler
{
	FountainShopMenuContent@ GetFountainMenu()
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		for (uint i = 0; i < gm.m_userWindows.length(); i++)
		{
			auto shopMenu = cast<ShopMenu>(gm.m_userWindows[i]);
			if (shopMenu is null)
				continue;

			auto ret = cast<FountainShopMenuContent>(shopMenu.m_menuContent);
			if (ret !is null)
				return ret;
		}
		return null;
	}

	void SetFountain(SValue@ data)
	{
		Fountain::ClearEffects();

		auto arr = data.GetArray();
		for (uint i = 0; i < arr.length(); i++)
			Fountain::ApplyEffect(uint(arr[i].GetInteger()));

		auto fountainMenu = GetFountainMenu();
		if (fountainMenu !is null)
			fountainMenu.NetBuy();
	}

	void DepositFountain(uint8 peer, int amount)
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		gm.m_town.m_fountainGold += amount;

		if (Network::IsServer())
			gm.m_townLocal.m_fountainGold += amount;

		auto fountainMenu = GetFountainMenu();
		if (fountainMenu !is null)
			fountainMenu.NetDeposit(amount);
	}

	void SetNgp(int ngp)
	{
		if (Network::IsServer())
			return;

		g_ngp = float(ngp);
	}

	void SetDownscaling(bool downscaling)
	{
		if (Network::IsServer())
			return;

		g_downscaling = downscaling;
	}

	void GameOver()
	{
		BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
		if (gm is null)
			return;

		Campaign@ campaign = cast<Campaign>(g_gameMode);
		if (campaign !is null)
			campaign.OnRunEnd(true);

		if (gm.m_gameOver !is null)
			gm.m_gameOver.DoShow();
	}

	void ExtraLives(int lives)
	{
		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm is null)
			return;

		if (lives > gm.m_extraLives)
			GetHUD().SetExtraLife();
		gm.m_extraLives = lives;
	}

	void SyncFlag(string flag, bool value, bool persistent)
	{
		if (!value)
			g_flags.Delete(flag);
		else
			g_flags.Set(flag, persistent ? FlagState::Run : FlagState::Level);
	}

	void SpawnDrinkBarrel(vec2 pos, int quality)
	{
		RandomLootManager::NetSpawnDrinkBarrel(pos, ActorItemQuality(quality));
	}

	void SpawnItemBlueprint(vec2 pos, int quality)
	{
		RandomLootManager::NetSpawnItemBlueprint(pos, ActorItemQuality(quality));
	}

	void SpawnDyeBucket(vec2 pos, int quality)
	{
		RandomLootManager::NetSpawnDyeBucket(pos, ActorItemQuality(quality));
	}

	void SurvivalCrowdValue(float newValue, float delta)
	{
		auto gm = cast<Survival>(g_gameMode);
		if (gm is null)
		{
			PrintError("Gamemode is not of type Survival!");
			return;
		}

		gm.m_crowdValue = newValue;
		gm.m_hudSurvival.OnValueChange(delta);
		gm.UpdateCrowdSounds();
	}

	void PlaySurvivalIntroEffect(UnitPtr unitSpawnPoint)
	{
		auto spawnPoint = cast<WorldScript::SurvivalEnemySpawnPoint>(unitSpawnPoint.GetScriptBehavior());
		if (spawnPoint is null)
		{
			PrintError("Unit is not of type SurvivalEnemySpawnPoint!");
			return;
		}

		if (spawnPoint.IntroEffect is null)
		{
			PrintError("SurvivalEnemySpawnPoint with ID " + unitSpawnPoint.GetId() + " does not have an IntroEffect!");
			return;
		}

		vec2 pos = xy(spawnPoint.Position);
		PlayEffect(spawnPoint.IntroEffect, pos);
	}

	void SurvivalCrowdTrigger(int idHash, int delta)
	{
		if (!Network::IsServer())
			return;

		auto action = cast<Crowd::TriggerAction>(Crowd::GetAction(uint(idHash)));
		if (action is null)
		{
			PrintError("Couldn't find TriggerAction for hash " + uint(idHash) + "!");
			return;
		}

		action.Trigger(delta);
	}

	void SurvivalCrowdTriggerStat(int idHash, int delta)
	{
		if (!Network::IsServer())
			return;

		auto action = cast<Crowd::TriggerAction>(Crowd::GetAction(uint(idHash), true));
		if (action is null)
		{
			PrintError("Couldn't find TriggerAction for hash " + uint(idHash) + "!");
			return;
		}

		action.Trigger(delta);
	}

	void TownStatueSet(int slot, string statueID)
	{
		auto gm = cast<Town>(g_gameMode);
		if (gm is null)
		{
			PrintError("Gamemode is not Town!");
			return;
		}

		gm.m_town.m_statuePlacements[slot] = statueID;

		gm.SetStatues();
		gm.RefreshTownModifiers();

		//TODO: If statue shop menu is open, call RefreshList() on it
	}

	void SpawnTownGravestone(UnitPtr unit, SValue@ charData)
	{
		auto b = cast<PlayerGravestoneBehavior>(unit.GetScriptBehavior());
		if (b is null)
		{
			PrintError("Unit is not a player gravestone behavior!");
			return;
		}

		b.Initialize(charData);
	}
}
