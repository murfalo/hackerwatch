class RetiredGladiatorNPC : ScriptWidgetHost
{
	Sprite@ m_spriteGold;
	Sprite@ m_spriteSwordToken;

	TextWidget@ m_wTokens;
	TextWidget@ m_wTokensSpent;
	ScalableSpriteButtonWidget@ m_wRespec;

	Widget@ m_wList;
	Widget@ m_wTemplate;

	SoundEvent@ m_sndBuyGold;

	RetiredGladiatorNPC(SValue& params)
	{
		super();
	}

	int GetUpgradeCost(RetiredGladiatorValue& currentLevel)
	{
		if (currentLevel.m_value < currentLevel.m_max)
			return 0;
		return 500 + (500 * currentLevel.m_value);
	}

	void Initialize(bool loaded) override
	{
		@m_sndBuyGold = Resources::GetSoundEvent("event:/ui/buy_gold");

		@m_spriteGold = m_def.GetSprite("gold");
		@m_spriteSwordToken = m_def.GetSprite("sword-token");

		@m_wTokens = cast<TextWidget>(m_widget.GetWidgetById("tokens"));
		@m_wTokensSpent = cast<TextWidget>(m_widget.GetWidgetById("tokens-spent"));
		@m_wRespec = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("respec"));

		@m_wList = m_widget.GetWidgetById("list");
		@m_wTemplate = m_widget.GetWidgetById("template");

		UpdateInterface();
	}

	void AddButton(string upgradeType, RetiredGladiatorValue& currentLevel)
	{
		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		auto wNewContainer = m_wTemplate.Clone();
		wNewContainer.SetID("");
		wNewContainer.m_visible = true;

		auto wLevel = cast<TextWidget>(wNewContainer.GetWidgetById("level"));
		auto wButton = cast<ShopButtonWidget>(wNewContainer.GetWidgetById("button"));

		if (wLevel !is null)
			wLevel.SetText("" + currentLevel.m_value);

		if (wButton !is null)
		{
			int costGold = GetUpgradeCost(currentLevel);

			string upgradeName = Resources::GetString(".retiredgladiator.upgrade." + upgradeType);

			wButton.SetIcon("icon-" + upgradeType);
			wButton.SetText(upgradeName);
			wButton.m_func = "buy " + upgradeType;

			wButton.SetPriceGold(costGold);
			wButton.m_shopRestricted = (record.GetAvailableSwordTokens() <= 0 || !Platform::HasDLC("pop"));
			wButton.UpdateEnabled();

			wButton.ClearTooltipSubs();
			wButton.AddTooltipSub(m_spriteGold, formatInt(costGold));
			wButton.AddTooltipSub(m_spriteSwordToken, "1");

			wButton.m_tooltipTitle = upgradeName;
			wButton.m_tooltipText = Resources::GetString(".retiredgladiator.upgrade", {
				{ "level", currentLevel + 1 }
			});
		}

		m_wList.AddChild(wNewContainer);
	}

	void UpdateInterface()
	{
		auto record = GetLocalPlayerRecord();

		m_wList.ClearChildren();

		AddButton("attack-power", record.retiredAttackPower);
		AddButton("skill-power", record.retiredSkillPower);
		AddButton("armor", record.retiredArmor);
		AddButton("resistance", record.retiredResistance);

		m_wTokens.SetText("" + record.GetAvailableSwordTokens());
		m_wTokensSpent.SetText("" + record.GetSpentSwordTokens());
		m_wRespec.m_enabled = (record.GetSpentSwordTokens() > 0);

		m_forceFocus = true;
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "buy")
		{
			auto record = GetLocalPlayerRecord();

			if (record.GetAvailableSwordTokens() <= 0)
			{
				PrintError("Not enough sword tokens!");
				return;
			}

			int costGold = 0;
			if (parse[1] == "attack-power") costGold = GetUpgradeCost(record.retiredAttackPower);
			else if (parse[1] == "skill-power") costGold = GetUpgradeCost(record.retiredSkillPower);
			else if (parse[1] == "armor") costGold = GetUpgradeCost(record.retiredArmor);
			else if (parse[1] == "resistance") costGold = GetUpgradeCost(record.retiredResistance);

			if (!Currency::CanAfford(record, costGold))
			{
				PrintError("Not enough gold!");
				return;
			}

			if (parse[1] == "attack-power") record.retiredAttackPower++;
			else if (parse[1] == "skill-power") record.retiredSkillPower++;
			else if (parse[1] == "armor") record.retiredArmor++;
			else if (parse[1] == "resistance") record.retiredResistance++;

			Currency::Spend(record, costGold);

			record.RefreshModifiers();

			PlaySound2D(m_sndBuyGold);

			UpdateInterface();
		}
		else if (name == "respec")
		{
			g_gameMode.ShowDialog(
				"respec",
				Resources::GetString(".retiredgladiator.respec.prompt"),
				Resources::GetString(".menu.yes"),
				Resources::GetString(".menu.no"),
				this
			);
		}
		else if (name == "respec yes")
		{
			auto record = GetLocalPlayerRecord();

			record.retiredAttackPower = 0;
			record.retiredSkillPower = 0;
			record.retiredArmor = 0;
			record.retiredResistance = 0;

			record.RefreshModifiers();

			UpdateInterface();
		}
		else if (name == "stop")
			Stop();
	}
}
