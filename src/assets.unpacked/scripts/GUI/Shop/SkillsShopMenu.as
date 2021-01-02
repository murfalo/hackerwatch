class SkillsShopMenuContent : ShopMenuContent
{
	Widget@ m_wRowList;
	Widget@ m_wTemplateRow;

	ScalableSpriteButtonWidget@ m_wRespecButton;

	TextWidget@ m_wSkillpointsWorth;

	Widget@ m_wTemplateSkill;
	Widget@ m_wTemplateSkillOwned;
	Widget@ m_wTemplateSkillUnavailable;
	Widget@ m_wTemplateSkillEmpty;

	Sprite@ m_spriteMana;
	Sprite@ m_spriteSkillPoints;

	Sprite@ m_spriteGold;

	Upgrades::UpgradeShop@ m_shop;
	array<array<Upgrades::RecordUpgradeStep@>> m_tiers;

	int m_numTiers = 5;

	SkillsShopMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);

		@m_shop = cast<Upgrades::UpgradeShop>(Upgrades::GetShop("trainer"));

		for (int i = 0; i < m_numTiers; i++)
			m_tiers.insertLast(array<Upgrades::RecordUpgradeStep@>());

		for (uint i = 0; i < m_shop.m_upgrades.length(); i++)
		{
			auto upgrade = m_shop.m_upgrades[i];

			int stepLevel = 1;
			for (int j = 0; j < m_numTiers; j++)
			{
				auto step = cast<Upgrades::RecordUpgradeStep>(upgrade.GetStep(stepLevel));

				if (step !is null && j + 1 >= step.m_restrictShopLevelMin)
				{
					m_tiers[j].insertLast(step);
					stepLevel++;
				}
				else
					m_tiers[j].insertLast(null);
			}
		}

		/*
		print("Skill upgrades: " + m_tiers.length());
		for (uint i = 0; i < m_tiers.length(); i++)
		{
			print("  " + m_tiers[i].length() + " steps");
			for (uint j = 0; j < m_tiers[i].length(); j++)
				print("    " + j + ": " + (m_tiers[i][j] is null ? "null" : "OK"));
		}
		*/
	}

	void OnShow() override
	{
		@m_wRowList = m_widget.GetWidgetById("row-list");
		@m_wTemplateRow = m_widget.GetWidgetById("row-template");

		@m_wRespecButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("respec"));

		@m_wSkillpointsWorth = cast<TextWidget>(m_widget.GetWidgetById("skillpoints-worth"));

		@m_wTemplateSkill = m_widget.GetWidgetById("skill-template");
		@m_wTemplateSkillOwned = m_widget.GetWidgetById("skill-owned-template");
		@m_wTemplateSkillUnavailable = m_widget.GetWidgetById("skill-unavailable-template");
		@m_wTemplateSkillEmpty = m_widget.GetWidgetById("skill-empty-template");

		@m_spriteMana = m_def.GetSprite("icon-mana");
		@m_spriteSkillPoints = m_def.GetSprite("skill-points");

		@m_spriteGold = m_def.GetSprite("icon-gold");

		ReloadList();
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.skills");
	}

	int GetManaCost(int skillIndex, int level)
	{
		//TODO: Do we really need this function!?
		auto record = GetLocalPlayerRecord();

		SValue@ svalClass = Resources::GetSValue("players/" + record.charClass + "/char.sval");
		if (svalClass is null)
		{
			PrintError("Couldn't get SValue file for class \"" + record.charClass + "\"");
			return 0;
		}

		auto arrSkills = GetParamArray(UnitPtr(), svalClass, "skills");

		auto svalSkill = Resources::GetSValue(arrSkills[skillIndex].GetString());
		auto arrLevels = GetParamArray(UnitPtr(), svalSkill, "skills");

		if (level >= int(arrLevels.length()))
		{
			PrintError("Level " + level + " does not exist for skill index " + skillIndex + " in class \"" + record.charClass + "\"!");
			return 0;
		}

		return GetParamInt(UnitPtr(), arrLevels[level], "mana-cost", false, 0);
	}

	int GetRespecSkillPoints()
	{
		auto record = GetLocalPlayerRecord();

		int attunePointsWorth = 0;

		// Attuned items
		for (uint i = 0; i < record.itemForgeAttuned.length(); i++)
		{
			auto item = g_items.GetItem(record.itemForgeAttuned[i]);
			if (item is null)
			{
				PrintError("Couldn't find attuned item with ID " + record.itemForgeAttuned[i]);
				continue;
			}

			attunePointsWorth += GetItemAttuneCost(item);
		}

		// Attuned enemies
		for (uint i = 0; i < record.bestiaryAttunements.length(); i++)
		{
			auto entry = record.bestiaryAttunements[i];
			for (int j = 1; j <= entry.m_attuned; j++)
				attunePointsWorth += entry.GetAttuneCost(j);
		}

		return record.GetSpentSkillpoints() - attunePointsWorth;
	}

	int GetRespecCost()
	{
		auto record = GetLocalPlayerRecord();
		if (!record.freeRespecUsed)
			return 0;
		return 250 * GetRespecSkillPoints();
	}

	void ReloadList() override
	{
		m_wRowList.ClearChildren();

		auto player = GetLocalPlayer();
		if (player is null)
			return;

		auto record = player.m_record;

		int skillPointsWorth = GetRespecSkillPoints();
		m_wSkillpointsWorth.SetText(formatThousands(skillPointsWorth));

		for (int i = 0; i < m_numTiers; i++)
		{
			Widget@ wNewRow = m_wTemplateRow.Clone();
			wNewRow.SetID("");
			wNewRow.m_visible = true;

			auto wRowName = cast<TextWidget>(wNewRow.GetWidgetById("rowname"));
			if (wRowName !is null)
			{
				dictionary params = { { "num", i + 1 } };
				wRowName.SetText(Resources::GetString(".shop.tier.num", params));

				if (i >= m_shopMenu.m_currentShopLevel)
					wRowName.SetColor(vec4(0.2, 0.2, 0.2, 1));
			}

			auto wSkillList = wNewRow.GetWidgetById("skill-list");

			for (uint j = 0; j < 7; j++)
			{
				Upgrades::RecordUpgrade@ upgrade;
				Upgrades::RecordUpgradeStep@ step;
				Upgrades::RecordUpgradeStep@ stepAbove;
				Skills::Skill@ skill;

				if (j < m_shop.m_upgrades.length())
					@upgrade = cast<Upgrades::RecordUpgrade>(m_shop.m_upgrades[j]);
				if (j < m_tiers[i].length())
				{
					@step = m_tiers[i][j];
					if (i > 0)
						@stepAbove = m_tiers[i - 1][j];
				}

				string tooltipTitle;
				string tooltipSubCost;
				string tooltipText;
				int manaCost = 0;

				if (step !is null)
				{
					@skill = player.m_skills[step.m_skillIndex];

					tooltipTitle = skill.GetFullName(step.m_skillLevel);
					tooltipSubCost = ("" + step.m_costSkillPoints);
					tooltipText = skill.GetFullDescription(step.m_skillLevel);

					manaCost = GetManaCost(step.m_skillIndex, step.m_skillLevel);
				}

				if (step is null || upgrade is null)
				{
					// There's no step
					auto wNewSkill = m_wTemplateSkillEmpty.Clone();
					wNewSkill.SetID("");
					wNewSkill.m_visible = true;
					wSkillList.AddChild(wNewSkill);
				}
				else if (step.IsOwned(record))
				{
					// Step is owned
					auto wNewSkill = m_wTemplateSkillOwned.Clone();
					wNewSkill.SetID("");
					wNewSkill.m_visible = true;
					wNewSkill.m_tooltipTitle = tooltipTitle;

					if (j == 0) wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.primaryskill"));
					else if (j <= 3) wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.activeskill"));
					else wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.passiveskill"));

					wNewSkill.AddTooltipSub(m_spriteSkillPoints, tooltipSubCost);

					if (manaCost > 0)
						wNewSkill.AddTooltipSub(m_spriteMana, formatThousands(manaCost));

					wNewSkill.m_tooltipText = tooltipText;

					auto wIcon = cast<SpriteWidget>(wNewSkill.GetWidgetById("icon"));
					if (wIcon !is null)
						wIcon.SetSprite(skill.m_icon);

					wSkillList.AddChild(wNewSkill);
				}
				else if (m_shopMenu.m_currentShopLevel < step.m_restrictShopLevelMin)
				{
					// Shop level is not high enough for this step
					auto wNewSkill = m_wTemplateSkillUnavailable.Clone();
					wNewSkill.SetID("");
					wNewSkill.m_visible = true;
					wNewSkill.m_tooltipTitle = tooltipTitle;

					if (j == 0) wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.primaryskill"));
					else if (j <= 3) wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.activeskill"));
					else wNewSkill.AddTooltipSub(null, Resources::GetString(".misc.passiveskill"));

					wNewSkill.AddTooltipSub(m_spriteSkillPoints, tooltipSubCost);

					if (manaCost > 0)
						wNewSkill.AddTooltipSub(m_spriteMana, "" + manaCost);

					wNewSkill.m_tooltipText = tooltipText;

					auto wIcon = cast<SpriteWidget>(wNewSkill.GetWidgetById("icon"));
					if (wIcon !is null)
					{
						wIcon.m_colorize = true;
						wIcon.SetSprite(skill.m_icon);
					}

					wSkillList.AddChild(wNewSkill);
				}
				else if (m_shopMenu.m_currentShopLevel >= step.m_restrictShopLevelMin)
				{
					// Shop level is high enough to buy it
					auto wNewSkill = m_wTemplateSkill.Clone();
					wNewSkill.SetID("");
					wNewSkill.m_visible = true;

					auto wButton = cast<UpgradeShopButtonWidget>(wNewSkill.GetWidgetById("button"));
					wButton.Set(this, upgrade, step);
					wButton.m_tooltipTitle = tooltipTitle;

					if (j == 0) wButton.AddTooltipSub(null, Resources::GetString(".misc.primaryskill"));
					else if (j <= 3) wButton.AddTooltipSub(null, Resources::GetString(".misc.activeskill"));
					else wButton.AddTooltipSub(null, Resources::GetString(".misc.passiveskill"));

					wButton.AddTooltipSub(m_spriteSkillPoints, tooltipSubCost);

					if (manaCost > 0)
						wButton.AddTooltipSub(m_spriteMana, "" + manaCost);

					wButton.m_tooltipText = tooltipText;
					wButton.m_enabled = (wButton.m_enabled && (stepAbove is null || stepAbove.IsOwned(record)));

					wSkillList.AddChild(wNewSkill);
				}
			}

			m_wRowList.AddChild(wNewRow);
		}

		if (skillPointsWorth > 0)
		{
			int respecCost = GetRespecCost();

			m_wRespecButton.m_enabled = Currency::CanAfford(respecCost);
			m_wRespecButton.ClearTooltipSubs();
			m_wRespecButton.AddTooltipSub(m_spriteGold, formatThousands(respecCost));
			m_wRespecButton.m_tooltipTitle = Resources::GetString(".shop.skills.respec.tooltip.title");
			m_wRespecButton.m_tooltipText = Resources::GetString(".shop.skills.respec.tooltip", {
				{ "skillpoints", formatThousands(skillPointsWorth) }
			});
		}
		else
		{
			m_wRespecButton.m_enabled = false;
			m_wRespecButton.m_tooltipTitle = "";
			m_wRespecButton.m_tooltipText = "";
		}

		m_shopMenu.DoLayout();
	}

	string GetGuiFilename() override
	{
		return "gui/shop/skills.gui";
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "respec")
		{
			g_gameMode.ShowDialog(
				"respec",
				Resources::GetString(".shop.skills.respec.prompt", {
					{ "gold", formatThousands(GetRespecCost()) },
					{ "skillpoints", formatThousands(GetRespecSkillPoints()) }
				}),
				Resources::GetString(".menu.yes"),
				Resources::GetString(".menu.no"),
				m_shopMenu
			);
		}
		else if (name == "respec yes")
		{
			auto player = GetLocalPlayer();

			int cost = GetRespecCost();
			if (cost > 0)
			{
				if (!Currency::CanAfford(cost))
				{
					PrintError("Can't afford respec!");
					return;
				}
				Currency::Spend(cost);
			}
			else
				player.m_record.freeRespecUsed = true;

			player.m_record.ClearSkillUpgrades();

			player.RefreshSkills();
			player.RefreshModifiers();

			ReloadList();

			(Network::Message("PlayerRespecSkills")).SendToAll();
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}
}
