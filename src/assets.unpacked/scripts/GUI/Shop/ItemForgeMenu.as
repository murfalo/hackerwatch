class SortableItem
{
	ActorItem@ m_item;

	SortableItem(ActorItem@ item)
	{
		@m_item = item;
	}

	int opCmp(const SortableItem &in other) const
	{
		if (m_item.quality > other.m_item.quality)
			return 1;
		else if (m_item.quality < other.m_item.quality)
			return -1;

		string nameSelf = Resources::GetString(m_item.name);
		string nameOther = Resources::GetString(other.m_item.name);
		return -nameSelf.opCmp(nameOther);
	}
}

class ItemForgeMenuContent : ShopMenuContent
{
	ScrollableWidget@ m_wList;
	Widget@ m_wTemplate;
	TextWidget@ m_wSkillpointsWorth;
	ScalableSpriteButtonWidget@ m_wRespecButton;
	TextWidget@ m_wFound;

	Sprite@ m_spriteSkillPoints;
	Sprite@ m_spriteOre;
	Sprite@ m_spriteGold;

	SoundEvent@ m_sndAttune;
	SoundEvent@ m_sndCraft;

	ItemForgeMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);

		@m_sndAttune = Resources::GetSoundEvent("event:/ui/attune");
		@m_sndCraft = Resources::GetSoundEvent("event:/ui/craft");
	}

	int GetItemCategory()
	{
		auto gmTown = cast<Town>(g_gameMode);
		if (gmTown !is null)
			return 0;

		auto gm = cast<Campaign>(g_gameMode);
		return gm.m_levelCount + 1;
	}

	bool HasOre(int amount)
	{
		return Currency::CanAfford(0, amount);
	}

	bool SpendOre(int amount)
	{
		if (Currency::CanAfford(0, amount))
		{
			Currency::Spend(0, amount);
			return true;
		}
		return false;
	}

	void Attune(ActorItem@ item)
	{
		auto player = GetLocalPlayer();
		if (player is null)
			return;

		player.AttuneItem(item);
	}

	void Craft(ActorItem@ item)
	{
		auto player = GetLocalPlayer();
		if (player is null)
			return;

		player.AddItem(item);
		player.m_record.itemForgeCrafted = GetItemCategory();

		if (cast<Town>(g_gameMode) !is null)
			Stats::Add("items-crafted", 1, player.m_record);
		else
		{
			Platform::Service.UnlockAchievement("dungeon_forge_used");
			Stats::Add("items-crafted-dungeon", 1, player.m_record);

			auto shopArea = m_shopMenu.m_shopArea;
			if (shopArea !is null)
			{
				shopArea.m_used = true;

				auto arrUsedUnits = shopArea.UsedUnits.FetchAll();
				for (uint i = 0; i < arrUsedUnits.length(); i++)
					arrUsedUnits[i].SetUnitScene(shopArea.UsedUnitScene, true);
			}
		}

		player.m_record.itemsBought.insertLast(item.id);
	}

	void OnShow() override
	{
		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		@m_wTemplate = m_widget.GetWidgetById("template");
		@m_wSkillpointsWorth = cast<TextWidget>(m_widget.GetWidgetById("attunements-worth"));
		@m_wRespecButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("respec"));
		@m_wFound = cast<TextWidget>(m_widget.GetWidgetById("found"));

		@m_spriteSkillPoints = m_def.GetSprite("skill-points");
		@m_spriteOre = m_def.GetSprite("ore");
		@m_spriteGold = m_def.GetSprite("gold");

		ReloadList();
	}

	int GetRespecSkillPoints()
	{
		auto record = GetLocalPlayerRecord();
		int ret = 0;
		for (uint i = 0; i < record.itemForgeAttuned.length(); i++)
		{
			auto item = g_items.GetItem(record.itemForgeAttuned[i]);
			if (item is null)
			{
				PrintError("Couldn't find attuned item with ID " + record.itemForgeAttuned[i]);
				continue;
			}

			ret += GetItemAttuneCost(item);
		}
		return ret;
	}

	int GetRespecCost()
	{
		return 250 * GetRespecSkillPoints();
	}

	void ReloadList() override
	{
		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		auto record = GetLocalPlayerRecord();

		int itemCategory = GetItemCategory();
		int skillPointsWorth = GetRespecSkillPoints();

		array<SortableItem@> items;
		for (uint i = 0; i < town.m_forgeBlueprints.length(); i++)
			items.insertLast(SortableItem(g_items.GetItem(town.m_forgeBlueprints[i])));
		items.sortDesc();

		if (m_wFound !is null)
		{
			int numTotalBlueprints = 0;
			for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
			{
				auto item = g_items.m_allItemsList[i];
				if (item.hasBlueprints)
					numTotalBlueprints++;
			}
			m_wFound.SetText(Resources::GetString(".shop.forge.found", { { "num", items.length() }, { "total", numTotalBlueprints } }));
		}

		if (m_wSkillpointsWorth !is null)
			m_wSkillpointsWorth.SetText(formatThousands(skillPointsWorth));

		bool inTown = (cast<Town>(g_gameMode) !is null);

%if HARDCORE
		int titleIndex = record.GetTitleIndex();
		auto titleList = record.GetTitleList();
%endif

		for (uint i = 0; i < items.length(); i++)
		{
			auto item = items[i].m_item;

			if (!inTown && m_shopMenu.m_currentShopLevel < int(item.quality))
				continue;

			vec4 qualityColor = GetItemQualityColor(item.quality);

			auto wNewItem = m_wTemplate.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wPlus = wNewItem.GetWidgetById("plus");
			if (wPlus !is null)
				wPlus.m_visible = (record.itemForgeAttuned.find(item.idHash) != -1);

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(item.icon);

			auto wNameContainer = cast<RectWidget>(wNewItem.GetWidgetById("name-container"));
			if (wNameContainer !is null)
			{
				if (item.quality != ActorItemQuality::Common)
					wNameContainer.m_color = desaturate(qualityColor);

				auto wName = cast<TextWidget>(wNameContainer.GetWidgetById("name"));
				if (wName !is null)
				{
					wName.SetText(Resources::GetString(item.name));
					wName.SetColor(qualityColor);

					wName.m_tooltipTitle = "\\c" + GetItemQualityColorString(item.quality) + utf8string(Resources::GetString(item.name)).toUpper().plain();
					wName.m_tooltipText = Resources::GetString(item.desc);

					if (item.set !is null)
					{
						wName.m_tooltipText += "\n\n";
						wName.m_tooltipText += GetItemSetColorString(record, item);
					}
				}
			}

			auto wButtonAttune = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-attune"));
			if (wButtonAttune !is null)
			{
				int attuneCost = GetItemAttuneCost(item);

				if (!item.canAttune || itemCategory > 0)
					wButtonAttune.m_visible = false;
				else
				{
					wButtonAttune.m_tooltipTitle = Resources::GetString(".shop.forge.attune");
					wButtonAttune.m_tooltipText = Resources::GetString(".shop.forge.attune.description");
					wButtonAttune.AddTooltipSub(m_spriteSkillPoints, formatThousands(attuneCost));

					if (record.itemForgeAttuned.find(item.idHash) != -1)
					{
						wButtonAttune.m_enabled = false;
						auto wButtonAttuneIcon = cast<SpriteWidget>(wButtonAttune.m_children[0]);
						if (wButtonAttuneIcon !is null)
							wButtonAttuneIcon.SetSprite("icon-attune-disabled");
					}
					else if (attuneCost > record.GetAvailableSkillpoints())
						wButtonAttune.m_enabled = false;
					else
						wButtonAttune.m_func = "attune " + item.id;
				}
			}

			auto wButtonCraft = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-craft"));
			if (wButtonCraft !is null)
			{
				int craftCost = GetItemCraftCost(item);

				wButtonCraft.m_tooltipTitle = Resources::GetString(".shop.forge.craft");
				wButtonCraft.m_tooltipText = Resources::GetString(".shop.forge.craft.description");
				wButtonCraft.AddTooltipSub(m_spriteOre, formatThousands(craftCost));

				bool isCrafted = (record.itemForgeCrafted == itemCategory);

				if (!HasOre(craftCost) || isCrafted || record.items.find(item.id) != -1)
					wButtonCraft.m_enabled = false;
				else
					wButtonCraft.m_func = "craft " + item.id;

%if HARDCORE
				if (inTown && titleIndex < int(item.quality))
				{
					wButtonCraft.m_enabled = false;

					auto titleRequired = titleList.GetTitle(int(item.quality));
					wButtonCraft.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.menu.restriction.player-title", {
						{ "title", Resources::GetString(titleRequired.m_name) }
					});
				}
%endif
			}

			m_wList.AddChild(wNewItem);
		}

		m_wList.ResumeScrolling();

		if (m_wRespecButton !is null)
		{
			if (skillPointsWorth > 0 && itemCategory == 0)
			{
				int respecCost = GetRespecCost();

				m_wRespecButton.m_enabled = Currency::CanAfford(respecCost);
				m_wRespecButton.ClearTooltipSubs();
				m_wRespecButton.AddTooltipSub(m_spriteGold, formatThousands(respecCost));
				m_wRespecButton.m_tooltipTitle = Resources::GetString(".shop.forge.respec.tooltip.title");
				m_wRespecButton.m_tooltipText = Resources::GetString(".shop.forge.respec.tooltip", {
					{ "skillpoints", formatThousands(skillPointsWorth) }
				});
			}
			else
			{
				m_wRespecButton.m_enabled = false;
				m_wRespecButton.m_tooltipTitle = "";
				m_wRespecButton.m_tooltipText = "";
			}
		}

		m_shopMenu.DoLayout();
	}

	string GetTitle() override
	{
		if (cast<Town>(g_gameMode) is null)
			return Resources::GetString(".shop.dungeonforge.title");
		else
			return Resources::GetString(".shop.forge.title");
	}

	string GetGuiFilename() override
	{
		if (cast<Town>(g_gameMode) is null)
			return "gui/shop/dungeonforge.gui";
		else
			return "gui/shop/itemforge.gui";
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "craft")
		{
			auto item = g_items.GetItem(parse[1]);
			if (item is null)
			{
				PrintError("Couldn't find item with ID " + parse[1]);
				return;
			}

			auto gm = cast<Campaign>(g_gameMode);
			auto town = gm.m_townLocal;

			int cost = GetItemCraftCost(item);
			if (!HasOre(cost))
			{
				PrintError("Can't afford crafting item with ID " + item.id);
				return;
			}

			SpendOre(cost);
			Craft(item);

			PlaySound2D(m_sndCraft);

			ReloadList();
			m_shopMenu.DoLayout();
		}
		else if (parse[0] == "attune")
		{
			auto item = g_items.GetItem(parse[1]);
			if (item is null)
			{
				PrintError("Couldn't find item with ID " + parse[1]);
				return;
			}

			auto record = GetLocalPlayerRecord();

			int cost = GetItemAttuneCost(item);
			if (cost > record.GetAvailableSkillpoints())
			{
				PrintError("Can't afford crafting item with ID " + item.id);
				return;
			}

			Attune(item);

			PlaySound2D(m_sndAttune);

			ReloadList();
			m_shopMenu.DoLayout();
		}
		else if (parse[0] == "respec")
		{
			if (parse.length() == 2 && parse[1] == "yes")
			{
				auto player = GetLocalPlayer();

				int cost = GetRespecCost();
				if (cost > 0)
				{
					if (!Currency::CanAfford(cost))
					{
						PrintError("Can't afford to respec!");
						return;
					}
					Currency::Spend(cost);
				}

				player.m_record.itemForgeAttuned.removeRange(0, player.m_record.itemForgeAttuned.length());
				player.RefreshModifiers();

				ReloadList();

				(Network::Message("PlayerRespecAttunements")).SendToAll();
			}
			else if (parse.length() == 1)
			{
				g_gameMode.ShowDialog(
					"respec",
					Resources::GetString(".shop.forge.respec.prompt", {
						{ "gold", formatThousands(GetRespecCost()) },
						{ "skillpoints", formatThousands(GetRespecSkillPoints()) }
					}),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					m_shopMenu
				);
			}
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}
}
