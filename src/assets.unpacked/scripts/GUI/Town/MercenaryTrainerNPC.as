// The mercenary trainer, aka "Men at arms" or "Master at arms"
class MercenaryTrainerNPC : ScriptWidgetHost
{
	Widget@ m_wList;
	Widget@ m_wTemplate;

	SoundEvent@ m_sndBuyGold;

	MercenaryTrainerNPC(SValue& params)
	{
		super();

		@m_sndBuyGold = Resources::GetSoundEvent("event:/ui/buy_gold");
	}

	void Initialize(bool loaded) override
	{
		@m_wList = m_widget.GetWidgetById("list");
		@m_wTemplate = m_widget.GetWidgetById("template");

		ReloadList();
	}

	int GetLevelCap(PlayerRecord@ record)
	{
		return 3 + (3 * record.GetTitleIndex());
	}

	int GetTitleIndex(int forLevel)
	{
		return clamp((forLevel - 1) / 3, 0, 7);
	}

	bool AtUpgradeLimit(int forLevel)
	{
		return ((forLevel - 1) / 3) > 7;
	}

	// int GetCost(int forLevel)
	// {
		// return 500 + (forLevel * 500);
		// return forLevel * (1000 + ((forLevel / 3) * 500));
		// return forLevel * 1000;
	// }
	
	int GetCost(int forLevel)
	{
		int ret = 0;
		for (int i = 0; i < forLevel; i++) {
			int rank = i / 3;
			ret += 1000 + rank * 500;
		}
		return ret;
	}

	void ReloadList()
	{
		auto record = GetLocalPlayerRecord();
		int levelCap = GetLevelCap(record);

		m_wList.ClearChildren();
		for (uint i = 0; i < MercenaryUpgradeDef::Instances.length(); i++)
		{
			auto upgrade = MercenaryUpgradeDef::Instances[i];

			int ownedLevel = record.GetMercenaryUpgradeLevel(upgrade.m_idHash);
			int purchaseLevel = ownedLevel + 1;

			auto wNewItem = m_wTemplate.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(upgrade.m_sprite);

			auto wLevel = cast<TextWidget>(wNewItem.GetWidgetById("level"));
			if (wLevel !is null && ownedLevel > 0)
				wLevel.SetText("" + ownedLevel);

			auto wButton = cast<ShopButtonWidget>(wNewItem.GetWidgetById("button"));
			if (wButton !is null)
			{
				wButton.m_func = "upgrade " + upgrade.m_id;

				wButton.SetText(Resources::GetString(upgrade.m_name));

				wButton.m_tooltipTitle = Resources::GetString(upgrade.m_name);
				wButton.m_tooltipText = Resources::GetString(upgrade.m_description);

				if (AtUpgradeLimit(purchaseLevel))
				{
					wButton.m_shopRestricted = true;
					wButton.m_tooltipText += "\n" + Resources::GetString(".shop.menu.restriction.limit");
				}
				else if (purchaseLevel > levelCap)
				{
					wButton.m_shopRestricted = true;

					auto titleList = record.GetTitleList();
					auto titleRequired = titleList.GetTitle(GetTitleIndex(purchaseLevel));
					wButton.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.menu.restriction.player-title", {
						{ "title", Resources::GetString(titleRequired.m_name) }
					});
				}

				wButton.SetPriceGold(GetCost(purchaseLevel));
				wButton.UpdateEnabled();
			}

			m_wList.AddChild(wNewItem);
		}

		m_forceFocus = true;
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "upgrade")
		{
			auto record = GetLocalPlayerRecord();
			auto upgrade = MercenaryUpgradeDef::Get(parse[1]);

			int ownedLevel = record.GetMercenaryUpgradeLevel(upgrade.m_idHash);

			int cost = GetCost(ownedLevel + 1);
			if (!Currency::CanAfford(record, cost))
			{
				PrintError("Not enough gold to get the \"" + upgrade.m_id + "\" upgrade!");
				return;
			}

			Currency::Spend(record, cost);

			PlaySound2D(m_sndBuyGold);

			record.IncrementMercenaryUpgrade(upgrade.m_idHash);

			ReloadList();

			GetLocalPlayer().RefreshModifiers();
		}
		if (name == "stop")
			Stop();
	}
}
