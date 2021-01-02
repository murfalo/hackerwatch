class GameOver : UserWindow
{
	Widget@ m_wSentences;
	Widget@ m_wSentenceTemplate;

	Actor@ m_killingActor;


	GameOver(GUIBuilder@ b)
	{
		super(b, "gui/gameover.gui");
	}

	void DoShow()
	{
		if (m_visible)
			return;

		/*
		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
		{
			gm.SaveLocalTown();
		}
		*/

		auto gm = cast<Campaign>(g_gameMode);
		gm.ShowUserWindow(this);

		// Fade in animations (gotta fix this)
		int fadeTime = 1000;

		auto wKiller = m_widget.GetWidgetById("killer");
		if (wKiller !is null)
		{
			if (m_killingActor is null)
				wKiller.m_visible = false;
			else
			{
				wKiller.m_visible = true;

				auto wKillerUnit = cast<UnitWidget>(wKiller.GetWidgetById("killer-unit"));
				auto wKillerText = cast<TextWidget>(wKiller.GetWidgetById("killer-text"));

				auto plrKiller = cast<PlayerBase>(m_killingActor);
				if (plrKiller is null)
				{
					auto unit = m_killingActor.m_unit;
					auto@ unitProd = unit.GetUnitProducer();
					if (unitProd is null)
					{
						PrintError("Unit producer is null for killer unit!");

						if (wKillerText !is null)
							wKillerText.m_visible = false;

						if (wKillerUnit !is null)
							wKillerUnit.m_visible = false;
					}
					else
					{
						auto params = unitProd.GetBehaviorParams();

						if (wKillerText !is null)
						{
							string unitName = GetParamString(unit, params, "beastiary-name", false);
							if (unitName != "")
								wKillerText.SetText(Resources::GetString(unitName));
						}

						if (wKillerUnit !is null)
						{
							string scene = GetParamString(unit, params, "beastiary-scene", false, "idle-3");
							vec2 sceneOffset = GetParamVec2(UnitPtr(), params, "beastiary-offset", false);

							auto uws = wKillerUnit.AddUnit(unit.GetUnitScene(scene));
							uws.m_offset = sceneOffset + vec2(1, 2);
							wKillerUnit.Invalidate();
						}
					}
				}
				else
				{
					auto killerRecord = plrKiller.m_record;

					if (wKillerText !is null)
						wKillerText.SetText(killerRecord.GetName());

					if (wKillerUnit !is null)
					{
						wKillerUnit.AddUnit("players/" + killerRecord.charClass + ".unit", "idle-3");
						wKillerUnit.m_dyeStates = Materials::MakeDyeStates(killerRecord);
						wKillerUnit.m_offset = vec2(1, 4);
						wKillerUnit.Invalidate();
					}
				}

				Invalidate();
			}
		}


		auto wBackground = m_widget.GetWidgetById("background");
		if (wBackground !is null)
			wBackground.Animate(WidgetVec4Animation("color", vec4(0, 0, 0, 0), vec4(0, 0, 0, 1), fadeTime));

		auto wImage = m_widget.GetWidgetById("image");
		if (wImage !is null)
			wImage.Animate(WidgetVec4Animation("color", vec4(1, 1, 1, 0), vec4(1, 1, 1, 1), fadeTime));

		auto wContent = m_widget.GetWidgetById("content");
		if (wContent !is null)
			wContent.Animate(WidgetBoolAnimation("visible", true, fadeTime));

		auto wMock = cast<TextWidget>(m_widget.GetWidgetById("mock"));
		if (wMock !is null)
			wMock.SetText(Resources::GetString(".gameover.mock." + randi(5)));

		auto record = GetLocalPlayerRecord();
		auto stats = record.statisticsSession;

		// Restart button
		auto wRestart = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button_restart"));
		if (wRestart !is null)
			wRestart.m_enabled = Network::IsServer();

%if !HARDCORE
		// Gold
		auto wGold = cast<TextWidget>(m_widget.GetWidgetById("gold"));
		if (wGold !is null)
			wGold.SetText(stats.GetStatString("gold-found"));

		// Ore
		auto wOre = cast<TextWidget>(m_widget.GetWidgetById("ore"));
		if (wOre !is null)
			wOre.SetText(stats.GetStatString("ore-found"));
%else
		// Legacy points
		auto wLegacyPoints = cast<TextWidget>(m_widget.GetWidgetById("legacy-points"));
		if (wLegacyPoints !is null)
		{
			int prestige = record.GetPrestige();
			wLegacyPoints.SetText(formatThousands(prestige));
		}
%endif

		auto wContainerResourcesStored = m_widget.GetWidgetById("container-resources-stored");

		auto wGoldStored = cast<TextWidget>(m_widget.GetWidgetById("gold-stored"));
		auto wOreStored = cast<TextWidget>(m_widget.GetWidgetById("ore-stored"));

%if HARDCORE
		// Show gold & ore stored containers if we have life insurance
		if (record.HasInsurance(gm.m_dungeon.m_id))
		{
			if (wContainerResourcesStored !is null)
				wContainerResourcesStored.m_visible = true;

			// Gold stored
			if (wGoldStored !is null)
			{
				int takeGold = ApplyTaxRate(gm.m_townLocal.m_gold, record.runGold);
				wGoldStored.SetText(takeGold);
			}

			// Ore stored
			if (wOreStored !is null)
				wOreStored.SetText(record.runOre);
		}
%else
		// Always show gold & ore stored containers
		if (wContainerResourcesStored !is null)
			wContainerResourcesStored.m_visible = true;

		// Gold stored
		if (wGoldStored !is null)
			wGoldStored.SetText(stats.GetStatString("gold-stored"));

		// Ore stored
		if (wOreStored !is null)
			wOreStored.SetText(stats.GetStatString("ores-stored"));
%endif

		// Sentences
		@m_wSentences = m_widget.GetWidgetById("sentences");
		@m_wSentenceTemplate = m_widget.GetWidgetById("sentence-template");

		array<string> possibleSentences = FindPossibleSentences(record);

		for (uint i = 0; i < possibleSentences.length(); i++)
		{
			int index = randi(possibleSentences.length());
			AddSentence(possibleSentences[index]);
			possibleSentences.removeAt(index);
		}

		g_gameMode.ReplaceTopWidgetRoot(this);
	}

	void Close() override
	{
		// Do nothing
	}

	void AddSentence(string text)
	{
		auto wNewText = cast<TextWidget>(m_wSentenceTemplate.Clone());
		wNewText.SetID("");
		wNewText.m_visible = true;
		wNewText.SetText(text);
		m_wSentences.AddChild(wNewText);
	}

	array<string> FindPossibleSentences(PlayerRecord@ record)
	{
		array<string> ret;

		auto stats = record.statisticsSession;

		if (g_flags.IsSet("unlock_apothecary"))
		{
			// "You never used your potion!"
			int potionCharges = 1 + g_allModifiers.PotionCharges();
			int unusedPotions = potionCharges - record.potionChargesUsed;
			if (unusedPotions == 0)
				ret.insertLast(Resources::GetString(".gameover.sentence.unused-potion.none"));
			else if (unusedPotions == 1)
				ret.insertLast(Resources::GetString(".gameover.sentence.unused-potion.one"));
			else if (unusedPotions == potionCharges)
				ret.insertLast(Resources::GetString(".gameover.sentence.unused-potion.never"));
			else if (unusedPotions > 0)
				ret.insertLast(Resources::GetString(".gameover.sentence.unused-potion.plural", { { "num", unusedPotions } }));
		}

		// "X keys remain unused."
		int unusedKeys = 0;
		for (uint i = 0; i < record.keys.length(); i++)
			unusedKeys += record.keys[i];
		if (unusedKeys == 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.unused-keys.one"));
		else if (unusedKeys > 0)
			ret.insertLast(Resources::GetString(".gameover.sentence.unused-keys.plural", { { "num", unusedKeys } }));

		// "You died with a lot of unused mana!"
		if (record.mana > 0.9f)
			ret.insertLast(Resources::GetString(".gameover.sentence.unused-mana"));

		// "You're rich!"
		int goldStored = stats.GetStatInt("gold-stored");
		if (goldStored == 0)
			ret.insertLast(Resources::GetString(".gameover.sentence.gold.none"));
		else if (goldStored > 5000)
			ret.insertLast(Resources::GetString(".gameover.sentence.gold.rich"));

		// "You died the first minute."
		if (stats.GetStatInt("time-played") < 60)
			ret.insertLast(Resources::GetString(".gameover.sentence.first-minute"));
		else
			ret.insertLast(Resources::GetString(".gameover.sentence.time", { { "time", stats.GetStatString("time-played") } }));

		// "You wasted X ore."
		int oreFound = stats.GetStatInt("ore-found");
		int oreStored = stats.GetStatInt("ores-stored");
		int oreWasted = oreFound - oreStored;
		if (oreWasted == 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.ore.one"));
		else if (oreWasted > 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.ore.plural", { { "num", oreWasted } }));

		// "You didn't kill any enemies!"
		if (stats.GetStatInt("enemies-killed") == 0)
			ret.insertLast(Resources::GetString(".gameover.sentence.no-enemies"));

		// "You opened X chests."
		int numChests = stats.GetStatInt("chests-opened");
		if (numChests == 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.chests.one"));
		else
			ret.insertLast(Resources::GetString(".gameover.sentence.chests.plural", { { "num", numChests } }));

		// "You took X damage."
		int numDamageTaken = stats.GetStatInt("damage-taken");
		ret.insertLast(Resources::GetString(".gameover.sentence.damage-taken", { { "num", numDamageTaken } }));

		// "You picked up X items."
		int numPickedItems = stats.GetStatInt("items-picked");
		if (numPickedItems == 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.items-picked.one"));
		else
			ret.insertLast(Resources::GetString(".gameover.sentence.items-picked.plural", { { "num", numPickedItems } }));

		// "You visited X floors."
		int numVisitedFloors = stats.GetStatInt("floors-visited");
		if (numVisitedFloors == 1)
			ret.insertLast(Resources::GetString(".gameover.sentence.floors.one"));
		else
			ret.insertLast(Resources::GetString(".gameover.sentence.floors.plural", { { "num", numVisitedFloors } }));

		// "You traveled X km."
		int numTraveledUnits = stats.GetStatInt("units-traveled");
		ret.insertLast(Resources::GetString(".gameover.sentence.units", { { "meters", formatMeters(numTraveledUnits) } }));

		// "You lost X experience."
		int xpLoss = int((record.experience - record.LevelExperience(record.level - 1)) * Tweak::DeathExperienceLoss);
		if (xpLoss > 0)
			ret.insertLast(Resources::GetString(".gameover.sentence.experience", { { "num", xpLoss } }));

		return ret;
	}

	void Update(int dt) override
	{
		if (!m_visible)
			return;

		IWidgetHoster::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		if (!m_visible)
			return;

		UserWindow::Draw(sb, idt);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "restart" && Network::IsServer())
		{
			auto gm = cast<BaseGameMode>(g_gameMode);
			if (gm !is null)
				gm.RestartGame();
		}
		else if (name == "exit")
		{
			PauseGame(false, false);
			StopScenario();
			return;
		}
		else if (name == "stats")
		{
			auto gm = cast<Campaign>(g_gameMode);
			gm.ShowUserWindow(gm.m_playerMenu);
		}
		else if (name == "scoreclose")
			g_gameMode.ReplaceTopWidgetRoot(this);
		else
			UserWindow::OnFunc(sender, name);
	}
}
