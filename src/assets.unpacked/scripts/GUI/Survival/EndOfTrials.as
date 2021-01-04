class EndOfTrials : ScriptWidgetHost
{
	EndOfTrials(SValue& sval)
	{
		super();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }

	void Initialize(bool loaded) override
	{
		auto gm = cast<Survival>(g_gameMode);
		if (gm is null)
			return;

		gm.m_expLocked = false;

		int crowdValue = int(gm.m_crowdValue);
		int rewardGold, rewardOre, rewardExp, rewardPoints;
		string crowdMessage;

		auto arrRewards = Resources::GetSValue("tweak/crowdrewards.sval").GetArray();
		for (uint i = 0; i < arrRewards.length(); i++)
		{
			auto svReward = arrRewards[i];

			int rewardMin = GetParamInt(UnitPtr(), svReward, "min");
			int rewardMax = GetParamInt(UnitPtr(), svReward, "max");

			if (crowdValue >= rewardMin && crowdValue <= rewardMax)
			{
				rewardGold = GetParamInt(UnitPtr(), svReward, "gold");
				rewardOre = GetParamInt(UnitPtr(), svReward, "ore");
				rewardExp = GetParamInt(UnitPtr(), svReward, "exp");
				rewardPoints = GetParamInt(UnitPtr(), svReward, "points");
				crowdMessage = Resources::GetString(GetParamString(UnitPtr(), svReward, "crowd-message"));
				break;
			}
		}
		
%if HARDCORE
		rewardPoints = 5;
%endif

		auto record = GetLocalPlayerRecord();
		auto player = GetLocalPlayer();

		if (g_gladiatorRating < record.GladiatorRank())
			rewardPoints = 0;

		auto mods = record.GetModifiers();
		rewardGold = max(0, int(rewardGold * (mods.GoldGainScale(player) + mods.GoldGainScaleAdd(player) + 0.5f * g_ngp)));
		rewardOre = max(0, int(rewardOre * (mods.OreGainScale(player) + 0.5f * g_ngp)));
		rewardExp = max(0, int(rewardExp * ((mods.ExpMul(player, null) + mods.ExpMulAdd(player, null)) + 0.5f * g_ngp)));

		if (!loaded)
		{
			record.runGold += rewardGold;
			record.runOre += rewardOre;
			record.GiveExperience(rewardExp);

			print("Old points: " + record.gladiatorPoints);

			if (rewardPoints > 0)
			{
				print("Receiving " + rewardPoints + " gladiator points.");
				record.GiveGladiatorPoints(rewardPoints);
			}
			else
				print("Not high enough gladiator rating to receive points!");

			gm.OnRunEnd(false);

			print("New points: " + record.gladiatorPoints);
			print("New rank: " + record.GladiatorRank());

			gm.m_townLocal.m_lastGladiatorRank = -1;
		}

		auto wStatus = cast<TextWidget>(m_widget.GetWidgetById("status"));
		if (wStatus !is null)
			wStatus.SetText(Resources::GetString(".endoftrials.completed") + "\n" + crowdMessage);

		auto wGold = cast<TextWidget>(m_widget.GetWidgetById("gold"));
		if (wGold !is null)
			wGold.SetText(formatThousands(rewardGold));

		auto wOre = cast<TextWidget>(m_widget.GetWidgetById("ore"));
		if (wOre !is null)
			wOre.SetText(formatThousands(rewardOre));

		auto wExp = cast<TextWidget>(m_widget.GetWidgetById("exp"));
		if (wExp !is null)
			wExp.SetText(formatThousands(rewardExp));

		auto wPoints = cast<TextWidget>(m_widget.GetWidgetById("points"));
		if (wPoints !is null)
			wPoints.SetText(formatThousands(rewardPoints));

		int oldRank = record.GladiatorRank(-rewardPoints);

		int pointsRequired = oldRank * Tweak::PointsPerGladiatorRank;
		int progressNumber = 1;
		while (true)
		{
			auto sprite = cast<SpriteWidget>(m_widget.GetWidgetById("progress-" + progressNumber));
			if (sprite is null)
				break;

			if (record.gladiatorPoints >= pointsRequired + progressNumber)
			{
				if (pointsRequired + progressNumber > record.gladiatorPoints - rewardPoints)
					sprite.SetSprite("icon-progress-new");
				else
					sprite.SetSprite("icon-progress-on");
			}
			else
				sprite.SetSprite("icon-progress-off");

			progressNumber++;
		}

		auto wCount = cast<TextWidget>(m_widget.GetWidgetById("count"));
		if (wCount !is null)
			wCount.SetText("(" + (record.gladiatorPoints - pointsRequired) + "/5)");

		int pointsLeft = (oldRank + 1) * Tweak::PointsPerGladiatorRank - record.gladiatorPoints;

		if (rewardPoints > 0 && pointsLeft == 0 && Platform::HasDLC("pop"))
		{
%if !HARDCORE
			int extraNgPoints = int((Tweak::PointsPerGladiatorRank * 5) * (g_ngp - oldRank / 5.0f));
			if (extraNgPoints > 0)
			{
				record.gladiatorPoints += extraNgPoints;
				print("Bonus points: " + extraNgPoints);

				if (wPoints !is null)
					wPoints.SetText(formatThousands(rewardPoints + extraNgPoints));
			}
%endif
			g_flags.Set("unlock_gladiator", FlagState::Town);
		}

		int newRank = record.GladiatorRank();
		print("Final new rank: " + newRank);

		if (!loaded)
		{
			Stats::Max("arena-highest-rank", newRank, record);
			Stats::Add("arena-fights", 1, record);
		}

		auto wHelp = cast<TextWidget>(m_widget.GetWidgetById("help"));
		if (wHelp !is null)
		{
			if (rewardPoints == 0)
				wHelp.SetText(Resources::GetString(".endoftrials.nopoints"));
			else if (pointsLeft == 0)
			{
				wHelp.SetText(Resources::GetString(".endoftrials.levelup", {
					{ "level", newRank }
				}));
			}
			else
			{
				wHelp.SetText(Resources::GetString(".endoftrials.pointsleft." + (pointsLeft == 1 ? "singular" : "plural"), {
					{ "points", pointsLeft },
					{ "rank", oldRank + 1 }
				}));
			}
		}

		auto wButtonContinue = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button-continue"));
		if (wButtonContinue !is null)
		{
			if (pointsLeft == 0 && Network::IsServer())
			{
				wButtonContinue.SetText(Resources::GetString(".endoftrials.beginrank", {
					{ "rank", newRank }
				}));
			}
			wButtonContinue.m_enabled = Network::IsServer();
		}

		auto wButtonTown = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button-town"));
		if (wButtonTown !is null)
			wButtonTown.m_enabled = Network::IsServer();
	}

	int GetMaxRating()
	{
		auto record = GetLocalPlayerRecord();
		auto gm = cast<Campaign>(g_gameMode);

		int highestNgp = gm.m_townLocal.m_highestNgps.GetHighest();
		int gladiatorRank = record.GladiatorRank();

		return max(highestNgp * 5, gladiatorRank);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "continue" && Network::IsServer())
		{
			auto record = GetLocalPlayerRecord();
			g_gladiatorRating = min(g_gladiatorRating + 1, GetMaxRating());

			ChangeLevel(GetCurrentLevelFilename());
		}
		else if (name == "town" && Network::IsServer())
		{
			auto record = GetLocalPlayerRecord();
			record.items.removeRange(0, record.items.length());
			record.itemsBought.removeRange(0, record.itemsBought.length());
			record.itemsRecycled.removeRange(0, record.itemsRecycled.length());
			record.tavernDrinks.removeRange(0, record.tavernDrinks.length());
			record.tavernDrinksBought.removeRange(0, record.tavernDrinksBought.length());

			(Network::Message("PlayerArenaClear")).SendToAll();

			if (g_flags.IsSet("dlc_pop"))
				g_startId = "city_of_stone";
			ChangeLevel(GetTownLevelFilename());
		}
	}

	void Stop() override
	{
	}
}
