class ShopMenuContent
{
	ShopMenu@ m_shopMenu;

	GUIDef@ m_def;
	Widget@ m_widget;

	ShopMenuContent()
	{
		auto gm = cast<Campaign>(g_gameMode);
		@m_shopMenu = gm.m_shopMenu;
	}

	ShopMenuContent(ShopMenu@ shopMenu)
	{
		@m_shopMenu = shopMenu;
	}

	string GetTitle()
	{
		return "none";
	}

	void OnShow()
	{
	}

	void OnClose()
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null)
			gm.SaveLocalTown();
	}

	string GetGuiFilename()
	{
		return "gui/shop/none.gui";
	}

	bool ShouldShowStars()
	{
		return true;
	}

	void Update(int dt)
	{
	}

	void ReloadList()
	{
	}

	bool BuyItem(Upgrades::Upgrade@ upgrade, Upgrades::UpgradeStep@ step)
	{
		auto record = GetLocalPlayerRecord();
		auto player = GetLocalPlayer();

		if (player is null)
		{
			PrintError("Player is dead");
			PlaySound2D(m_shopMenu.m_sndCantBuy);
			return false;
		}

		if (!step.CanAfford(record))
		{
			PrintError("Too expensive");
			PlaySound2D(m_shopMenu.m_sndCantBuy);
			return false;
		}

		if (!step.BuyNow(record))
		{
			PlaySound2D(m_shopMenu.m_sndCantBuy);
			return false;
		}

		if (upgrade.ShouldRemember())
		{
			OwnedUpgrade@ ownedUpgrade = record.GetOwnedUpgrade(upgrade.m_id);
			if (ownedUpgrade !is null)
			{
				ownedUpgrade.m_level = step.m_level;
				@ownedUpgrade.m_step = step;
			}
			else
			{
				@ownedUpgrade = OwnedUpgrade();
				ownedUpgrade.m_id = upgrade.m_id;
				ownedUpgrade.m_idHash = upgrade.m_idHash;
				ownedUpgrade.m_level = step.m_level;
				@ownedUpgrade.m_step = step;
				record.upgrades.insertLast(ownedUpgrade);
			}
		}

		step.PayForUpgrade(record);

		(Network::Message("PlayerGiveUpgrade") << upgrade.m_id << step.m_level).SendToAll();
		
		float payScale = step.PayScale(record);

		if ((int(step.m_costSkillPoints) * payScale) > 0)
			PlaySound2D(m_shopMenu.m_sndBuySkill);
		else if ((int(step.m_costOre) * payScale) > 0)
			PlaySound2D(m_shopMenu.m_sndBuyOre);
		else if ((int(step.m_costGold) * payScale) > 0)
			PlaySound2D(m_shopMenu.m_sndBuyGold);
		else
			PlaySound2D(m_shopMenu.m_sndBuyFree);

		return true;
	}

	void OnFunc(Widget@ sender, string name)
	{
		auto parse = name.split(" ");
		if (parse[0] == "buy-item")
		{
			auto btn = cast<UpgradeShopButtonWidget>(sender);
			if (btn !is null)
			{
				if (BuyItem(btn.m_upgrade, btn.m_upgradeStep))
					ReloadList();
			}
		}
	}
}
