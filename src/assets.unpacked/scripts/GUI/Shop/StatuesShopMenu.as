class StatuesShopMenuContent : ShopMenuContent
{
	Widget@ m_wList;
	Widget@ m_wTemplate;

	StatueSelectMenu@ m_selectMenu;

	Sprite@ m_spriteOre;

	StatuesShopMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.statues");
	}

	void OnShow() override
	{
		@m_wList = m_widget.GetWidgetById("list");
		@m_wTemplate = m_widget.GetWidgetById("template");

		@m_spriteOre = m_def.GetSprite("ore");

		RefreshList();
	}

	string GetGuiFilename() override
	{
		return "gui/shop/statues.gui";
	}

	bool ShouldShowStars() override
	{
		return false;
	}

	int NumSlotsForLevel()
	{
		return 3;
	}

	void RefreshList()
	{
		m_wList.ClearChildren();

		auto gm = cast<Campaign>(g_gameMode);

		int numSlots = NumSlotsForLevel();

		auto town = gm.m_town;
		if (Network::IsServer())
			@town = gm.m_townLocal;

		if (Network::IsServer())
		{
			for (uint i = town.m_statuePlacements.length(); i < uint(numSlots); i++)
			{
				print("new slot: " + i);
				town.m_statuePlacements.insertLast("");
			}
		}

		for (int i = 0; i < numSlots; i++)
		{
			string statueID = "";
			TownStatue@ statue = null;
			Statues::StatueDef@ statueDef = null;

			if (uint(i) < town.m_statuePlacements.length())
				statueID = town.m_statuePlacements[i];

			if (statueID != "")
				@statue = town.GetStatue(statueID);

			if (statue !is null)
				@statueDef = statue.GetDef();

			auto wNewItem = m_wTemplate.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wSwitchButton = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("switch-button"));
			if (wSwitchButton !is null)
			{
				wSwitchButton.m_func = "set-statue " + i;
				wSwitchButton.m_enabled = Network::IsServer();
				if (statue !is null)
				{
					wSwitchButton.m_tooltipText = Resources::GetString(".shop.statues.switch");

					auto wIcon = cast<SpriteWidget>(wSwitchButton.GetWidgetById("icon"));
					if (wIcon !is null)
						wIcon.SetSprite("icon-switch");
				}
				else
					wSwitchButton.m_tooltipText = Resources::GetString(".shop.statues.build");
			}

			auto wUpgradeButton = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("upgrade-button"));
			if (wUpgradeButton !is null)
			{
				if (statue !is null)
				{
					int cost = statueDef.GetUpgradeCost(statue.m_level + 1);

					bool enoughBlueprints = (statue.m_level < statue.m_blueprint);

					wUpgradeButton.m_func = "upgrade " + statueID;
					wUpgradeButton.m_enabled = (Network::IsServer() && Currency::CanAfford(0, cost) && enoughBlueprints);

					wUpgradeButton.m_tooltipTitle = Resources::GetString(".shop.statues.upgrade");
					wUpgradeButton.m_tooltipText = Resources::GetString(statueDef.m_descUpgrade);

					if (!enoughBlueprints)
						wUpgradeButton.m_tooltipText = "\\cff0000" + Resources::GetString(".shop.statues.upgrade.blueprint") + "\\d\n\n" + wUpgradeButton.m_tooltipText;

					if (!Currency::CanAfford(0, cost))
						wUpgradeButton.AddTooltipSub(m_spriteOre, "\\cff0000" + formatThousands(cost));
					else
						wUpgradeButton.AddTooltipSub(m_spriteOre, formatThousands(cost));
				}
				else
					wUpgradeButton.m_enabled = false;
			}

			auto wClearButton = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("clear-button"));
			if (wClearButton !is null)
			{
				wClearButton.m_func = "clear " + i;
				wClearButton.m_enabled = (Network::IsServer() && statue !is null);
			}

			auto wPreview = cast<UnitWidget>(wNewItem.GetWidgetById("preview"));
			if (wPreview !is null)
			{
				wPreview.ClearUnits();
				if (statue !is null)
				{
					wPreview.AddUnit(statueDef.m_scene);

					wPreview.ClearTooltipSubs();
					wPreview.AddTooltipSub(null, Resources::GetString(".shop.statues.level", {
						{ "level", statue.m_level }
					}));

					wPreview.m_tooltipTitle = Resources::GetString(statueDef.m_name);
					wPreview.m_tooltipText = Resources::GetString(statueDef.m_desc);
				}
				else
				{
					wPreview.AddUnit("doodads/generic/desert_statues.unit", "default");
					wPreview.m_tooltipTitle = "";
					wPreview.m_tooltipText = "";
				}
			}

			m_wList.AddChild(wNewItem);
		}

		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "set-statue")
		{
			if (!Network::IsServer())
				return;

			StatueSelectMenu(g_gameMode.m_guiBuilder, this, parseInt(parse[1])).Show();
		}
		else if (parse[0] == "upgrade")
		{
			if (!Network::IsServer())
				return;

			auto gm = cast<Town>(g_gameMode);
			auto statue = gm.m_townLocal.GetStatue(parse[1]);

			if (statue is null)
			{
				PrintError("Couldn't find town statue \"" + parse[1] + "\"");
				return;
			}

			auto def = statue.GetDef();
			int cost = def.GetUpgradeCost(statue.m_level + 1);

			if (!Currency::CanAfford(0, cost))
			{
				PrintError("Not enough ore to upgrade statue \"" + parse[1] + "\"");
				return;
			}

			if (parse.length() == 2)
			{
				g_gameMode.ShowDialog(
					"upgrade " + parse[1],
					Resources::GetString(".shop.statues.upgrade.prompt", {
						{ "cost", formatThousands(cost) }
					}),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					m_shopMenu
				);
			}
			else if (parse[2] == "yes")
			{
				Currency::Spend(0, cost);

				statue.m_level++;

				PlaySound2D(Resources::GetSoundEvent("event:/ui/statue_upgrade"));

				print("Upgraded \"" + parse[1] + "\" for " + cost + " ore");
				Stats::Add("statue-upgrades-bought", 1, GetLocalPlayerRecord());

				RefreshList();

				gm.SetStatues();
				gm.RefreshTownModifiers();
			}
		}
		else if (parse[0] == "clear")
		{
			if (!Network::IsServer())
				return;

			int slot = parseInt(parse[1]);

			auto gm = cast<Town>(g_gameMode);
			gm.m_townLocal.m_statuePlacements[slot] = "";

			(Network::Message("TownStatueSet") << slot << "").SendToAll();

			RefreshList();

			gm.SetStatues();
			gm.RefreshTownModifiers();
		}
	}
}
