class BestiaryNPC : ScriptWidgetHost
{
	Sprite@ m_spriteGold;

	Sprite@ m_spriteHealth;
	Sprite@ m_spriteArmor;
	Sprite@ m_spriteResistance;

	Sprite@ m_spriteSkillPoints;

	SoundEvent@ m_sndAttune;

	array<BestiaryEntry@> m_currentUnits;

	BestiaryNPC(SValue& params)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_spriteGold = m_def.GetSprite("icon-gold");

		@m_spriteHealth = m_def.GetSprite("icon-health");
		@m_spriteArmor = m_def.GetSprite("icon-armor");
		@m_spriteResistance = m_def.GetSprite("icon-resistance");

		@m_spriteSkillPoints = m_def.GetSprite("skill-points");

		@m_sndAttune = Resources::GetSoundEvent("event:/ui/attune");

		ReloadList();
		ReloadPointsWorth();
	}

	BestiaryEntry@ GetCurrentEntry(uint idHash)
	{
		for (uint i = 0; i < m_currentUnits.length(); i++)
		{
			if (m_currentUnits[i].m_idHash == idHash)
				return m_currentUnits[i];
		}
		return null;
	}

	void ReloadList()
	{
		auto wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		if (wList is null)
			return;

		wList.PauseScrolling();
		wList.ClearChildren();
		m_currentUnits.removeRange(0, m_currentUnits.length());

		auto town = cast<Campaign>(g_gameMode).m_townLocal;

		AddCategory(wList, "beast", town.GetBestiary("beast"));
		AddCategory(wList, "undead", town.GetBestiary("undead"));
		AddCategory(wList, "aberration", town.GetBestiary("aberration"));
		AddCategory(wList, "construct", town.GetBestiary("construct"));

		wList.ResumeScrolling();

		Invalidate();
	}

	void AddCategory(Widget@ wList, string name, array<BestiaryEntry@>@ units)
	{
		units.sortDesc();

		auto wTemplateHeader = m_widget.GetWidgetById("template-header");
		auto wTemplateSeparator = m_widget.GetWidgetById("template-separator");
		auto wTemplate = m_widget.GetWidgetById("template");

		auto wNewSeparator = wTemplateSeparator.Clone();
		wNewSeparator.m_visible = true;
		wNewSeparator.SetID("");
		wList.AddChild(wNewSeparator);

		auto wNewHeader = wTemplateHeader.Clone();
		wNewHeader.m_visible = true;
		wNewHeader.SetID("");

		auto wHeaderType = cast<TextWidget>(wNewHeader.GetWidgetById("type"));
		if (wHeaderType !is null)
			wHeaderType.SetText(Resources::GetString(".bestiary.type." + name));

		wList.AddChild(wNewHeader);

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < units.length(); i++)
		{
			auto unit = units[i];
			auto entry = record.GetBestiaryAttunement(unit.m_idHash);

			if (unit.m_kills == 0 && unit.m_killer == 0 && entry.m_attuned == 0)
				continue;

			auto wNewItem = wTemplate.Clone();
			wNewItem.m_visible = true;
			wNewItem.SetID("");

			if (!UpdateEntry(unit, wNewItem))
				continue;

			wNewItem.SetID("unit-" + unit.m_idHash);

			m_currentUnits.insertLast(unit);
			wList.AddChild(wNewItem);
		}
	}

	bool UpdateEntry(BestiaryEntry@ unit, Widget@ wItem)
	{
		auto record = GetLocalPlayerRecord();
		auto params = unit.m_producer.GetBehaviorParams();

		string unitName = GetParamString(UnitPtr(), params, "beastiary-name", false);
		if (unitName == "")
			return false;

		string unitDescription = GetParamString(UnitPtr(), params, "beastiary-description", false);

		string displayScene = GetParamString(UnitPtr(), params, "beastiary-scene", false, "idle-3");
		UnitScene@ scene = unit.m_producer.GetUnitScene(displayScene);
		vec2 sceneOffset = GetParamVec2(UnitPtr(), params, "beastiary-offset", false);

		// TODO: Add to tooltip..   show hp after X kills, show armor after Y kills, etc (?)
		int hp = GetParamInt(UnitPtr(), params, "hp");
		int armor = GetParamInt(UnitPtr(), params, "armor", false, 0);
		int resistance = GetParamInt(UnitPtr(), params, "resistance", false, 0);
		int expReward = GetParamInt(UnitPtr(), params, "experience-reward", false, 0);

		auto wUnit = cast<UnitWidget>(wItem.GetWidgetById("unit"));
		if (wUnit !is null)
		{
			auto uws = wUnit.AddUnit(scene);
			uws.m_offset = sceneOffset + vec2(1, 2);
		}

		vec4 qualityColor = GetItemQualityColor(unit.m_quality);

		auto wNameContainer = cast<RectWidget>(wItem.GetWidgetById("name-container"));
		if (wNameContainer !is null)
		{
			if (unit.m_quality != ActorItemQuality::Common)
				wNameContainer.m_color = desaturate(qualityColor);
		}

		auto wName = cast<TextWidget>(wItem.GetWidgetById("name"));
		if (wName !is null)
		{
			wName.SetText(Resources::GetString(unitName));
			wName.SetColor(qualityColor);

			wName.m_tooltipTitle = Resources::GetString(unitName);

			wName.m_tooltipText = "";
			if (unitDescription != "")
				wName.m_tooltipText = Resources::GetString(unitDescription) + "\n\n";
			wName.m_tooltipText += Resources::GetString(".bestiary.expreward") + ": " + formatThousands(expReward);

			wName.ClearTooltipSubs();
			wName.AddTooltipSub(m_spriteHealth, formatThousands(hp));

			if (armor > 0)
				wName.AddTooltipSub(m_spriteArmor, formatThousands(armor));

			if (resistance > 0)
				wName.AddTooltipSub(m_spriteResistance, formatThousands(resistance));
		}

		auto wDlc = cast<SpriteWidget>(wItem.GetWidgetById("dlc"));
		if (wDlc !is null)
		{
			wDlc.m_visible = (unit.m_dlc != "");
			wDlc.SetSprite("icon-dlc-" + unit.m_dlc);
		}

		auto wKills = cast<TextWidget>(wItem.GetWidgetById("kills"));
		if (wKills !is null)
			wKills.SetText(formatThousands(unit.m_kills));

		auto entry = record.GetBestiaryAttunement(unit.m_idHash);

		auto wAttune = cast<ScalableSpriteButtonWidget>(wItem.GetWidgetById("button-attune"));
		if (wAttune !is null)
		{
			int attuneCost = entry.GetAttuneCost(entry.m_attuned + 1);
			wAttune.m_enabled = attuneCost <= record.GetAvailableSkillpoints();

			wAttune.m_tooltipTitle = Resources::GetString(".town.bestiary.attune");

			float dmgMul = 0.2f * (entry.m_attuned + 1);
			float dmgReduction = pow(0.95f, entry.m_attuned + 1);

			wAttune.m_tooltipText =
				Resources::GetString(".town.bestiary.damage", {
					{ "damage", formatFloat(dmgMul * 100.0f, "", 0, 0) }
				}) + "\n" +
				Resources::GetString(".town.bestiary.damagereduction", {
					{ "reduction", formatFloat((1.0f - dmgReduction) * 100.0f, "", 0, 0) }
				});

			wAttune.ClearTooltipSubs();
			wAttune.AddTooltipSub(m_spriteSkillPoints, formatThousands(attuneCost));

			wAttune.m_func = "attune " + unit.m_idHash;

			if (wAttune.m_hovering)
				wAttune.ShowTooltip();
		}

		auto wAttuneLevel = cast<TextWidget>(wItem.GetWidgetById("attune-level"));
		if (wAttuneLevel !is null)
		{
			if (entry.m_attuned > 0)
			{
				wAttuneLevel.m_visible = true;
				wAttuneLevel.SetText("" + entry.m_attuned);

				float dmgMul = 0.2f * entry.m_attuned;
				float dmgReduction = pow(0.95f, entry.m_attuned);

				wAttuneLevel.m_parent.m_tooltipText =
					Resources::GetString(".town.bestiary.damage", {
						{ "damage", formatFloat(dmgMul * 100.0f, "", 0, 0) }
					}) + "\n" +
					Resources::GetString(".town.bestiary.damagereduction", {
						{ "reduction", formatFloat((1.0f - dmgReduction) * 100.0f, "", 0, 0) }
					});
			}
			else
			{
				wAttuneLevel.m_parent.m_tooltipText = "";
				wAttuneLevel.m_visible = false;
			}
		}

		return true;
	}

	void ReloadButtonCosts()
	{
		auto wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));
		if (wList is null)
			return;

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < wList.m_children.length(); i++)
		{
			auto wItem = wList.m_children[i];
			auto idParse = wItem.m_id.split("-");
			if (idParse.length() != 2 || idParse[0] != "unit")
				continue;

			auto unit = GetCurrentEntry(parseInt(idParse[1]));
			auto entry = record.GetBestiaryAttunement(unit.m_idHash);

			auto wAttune = cast<ScalableSpriteButtonWidget>(wItem.GetWidgetById("button-attune"));
			if (wAttune !is null)
			{
				int attuneCost = entry.GetAttuneCost(entry.m_attuned + 1);
				wAttune.m_enabled = attuneCost <= record.GetAvailableSkillpoints();
			}
		}
	}

	int GetPointsWorth()
	{
		int ret = 0;

		auto record = GetLocalPlayerRecord();
		for (uint i = 0; i < record.bestiaryAttunements.length(); i++)
		{
			auto entry = record.bestiaryAttunements[i];
			for (int j = 1; j <= entry.m_attuned; j++)
				ret += entry.GetAttuneCost(j);
		}

		return ret;
	}

	int GetRespecCost()
	{
		return GetRespecCost(GetPointsWorth());
	}

	int GetRespecCost(int points)
	{
		return 250 * points;
	}

	void ReloadPointsWorth()
	{
		auto wPointsWorth = cast<TextWidget>(m_widget.GetWidgetById("skillpoints-worth"));
		if (wPointsWorth is null)
			return;

		int worth = GetPointsWorth();

		wPointsWorth.SetText(formatThousands(worth));

		auto wRespec = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("respec"));
		if (wRespec !is null)
		{
			int respecCost = GetRespecCost(worth);

			wRespec.m_enabled = (worth > 0 && Currency::CanAfford(respecCost));

			wRespec.ClearTooltipSubs();
			wRespec.AddTooltipSub(m_spriteGold, formatThousands(respecCost));
			wRespec.m_tooltipTitle = Resources::GetString(".town.bestiary.respec.tooltip.title");
			wRespec.m_tooltipText = Resources::GetString(".town.bestiary.respec.tooltip", {
				{ "skillpoints", formatThousands(worth) }
			});
		}
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "close")
			Stop();
		else if (parse[0] == "attune")
		{
			auto record = GetLocalPlayerRecord();

			auto unit = GetCurrentEntry(parseUInt(parse[1]));
			auto entry = record.GetBestiaryAttunement(unit.m_idHash);

			int attuneCost = entry.GetAttuneCost(entry.m_attuned + 1);

			auto wItem = m_widget.GetWidgetById("unit-" + parse[1]);

			if (attuneCost > record.GetAvailableSkillpoints())
			{
				PrintError("Not enough skillpoints to attune!");
				return;
			}

			Stats::Add("spent-skillpoints", attuneCost, record);

			entry.m_attuned++;
			PlaySound2D(m_sndAttune);

			UpdateEntry(unit, wItem);
			ReloadButtonCosts();
			ReloadPointsWorth();
		}
		else if (parse[0] == "retrain")
		{
			int pointsWorth = GetPointsWorth();
			int respecCost = GetRespecCost(pointsWorth);

			auto record = GetLocalPlayerRecord();

			if (parse.length() == 2)
			{
				if (parse[1] == "yes")
				{
					auto gm = cast<Campaign>(g_gameMode);

					if (!Currency::CanAfford(respecCost))
					{
						PrintError("Not enough money to retrain bestiary!");
						return;
					}

					Currency::Spend(respecCost);

					for (uint i = 0; i < m_currentUnits.length(); i++)
					{
						auto unit = m_currentUnits[i];
						auto entry = record.GetBestiaryAttunement(unit.m_idHash);

						if (entry.m_attuned > 0)
						{
							entry.m_attuned = 0;

							auto wItem = m_widget.GetWidgetById("unit-" + entry.m_idHash);
							if (wItem !is null)
								UpdateEntry(unit, wItem);
						}
					}

					ReloadButtonCosts();
					ReloadPointsWorth();
				}
			}
			else
			{
				g_gameMode.ShowDialog(
					"retrain",
					Resources::GetString(".town.bestiary.respec.prompt", {
						{ "gold", formatThousands(respecCost) },
						{ "points", formatThousands(pointsWorth) }
					}),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					this
				);
			}
		}
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }
}
