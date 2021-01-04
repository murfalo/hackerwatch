namespace Menu
{
	class CharacterSelectionMenu : HwrMenu
	{
		CheckBoxGroupWidget@ m_wList;
		Widget@ m_wTemplate;

		ScalableSpriteButtonWidget@ m_wPlayButton;

		string m_context;

		CharacterSelectionMenu(MenuProvider@ provider, string context)
		{
			super(provider);

			m_context = context;
		}

		void Initialize(GUIDef@ def) override
		{
			@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
			@m_wTemplate = m_widget.GetWidgetById("template");

			@m_wPlayButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("playbutton"));
			if (m_context != "")
				m_wPlayButton.SetText(Resources::GetString(".mainmenu.character.select.select"));

			ReloadList();
		}

		void Show() override
		{
			HwrMenu::Show();

			ReloadList();
		}

		string GetModClassName(string id)
		{
			auto enabledMods = HwrSaves::GetEnabledMods();
			for (uint i = 0; i < enabledMods.length(); i++)
			{
				auto mod = enabledMods[i];
				auto sval = mod.Data;

				auto arrCustomClasses = GetParamArray(UnitPtr(), sval, "custom-character-classes", false);
				if (arrCustomClasses !is null)
				{
					for (uint j = 0; j < arrCustomClasses.length(); j++)
					{
						auto charClass = arrCustomClasses[j];
						if (charClass.GetType() == SValueType::Dictionary)
						{
							string classId = GetParamString(UnitPtr(), charClass, "id");
							if (classId == id)
								return GetParamString(UnitPtr(), charClass, "name");
						}
						else if (charClass.GetType() == SValueType::String && charClass.GetString() == id)
							return id;
					}
				}
			}
			return id;
		}

		void ReloadList()
		{
			m_wList.ClearChildren();

			auto arrCharacters = HwrSaves::GetCharacters();
			auto arrLevelSaves = HwrSaves::GetLevelSaves();

			for (uint i = 0; i < arrCharacters.length(); i++)
			{
				auto svChar = arrCharacters[i];
				auto gss = arrLevelSaves[i];

				bool mercenary = GetParamBool(UnitPtr(), svChar, "mercenary", false);
				bool mercenaryLocked = GetParamBool(UnitPtr(), svChar, "mercenary-locked", false);
				int mercenaryPrestige = GetParamInt(UnitPtr(), svChar, "mercenary-prestige", false);

				if (mercenary && mercenaryLocked)
					continue;

				string name = GetParamString(UnitPtr(), svChar, "name");
				int level = GetParamInt(UnitPtr(), svChar, "level");
				string charClass = GetParamString(UnitPtr(), svChar, "class");
				int face = GetParamInt(UnitPtr(), svChar, "face", false);
				uint frame = uint(GetParamInt(UnitPtr(), svChar, "current-frame", false, HashString("default")));

				DungeonNgpList ngps;
				ngps.Load(svChar, "ngps");

				int ngp = ngps["base"];
				int desertNgp = ngps["pop"];

				int gladiatorPoints = GetParamInt(UnitPtr(), svChar, "gladiator-points", false);
				int gladiatorRank = gladiatorPoints / Tweak::PointsPerGladiatorRank;

				string charClassUnitPath = "players/" + charClass + ".unit";
				bool charClassExists = (Resources::GetUnitProducer(charClassUnitPath) !is null);

				auto wNewItem = cast<CheckBoxWidget>(m_wTemplate.Clone());
				wNewItem.SetID("");
				wNewItem.m_visible = true;
				wNewItem.m_value = "" + i;

				if (charClass == "gladiator" && !Platform::HasDLC("pop"))
					wNewItem.m_enabled = false;

				if (charClass == "witch_hunter" && !Platform::HasDLC("wh"))
					wNewItem.m_enabled = false;

				if (mercenary && !Platform::HasDLC("mt"))
					wNewItem.m_enabled = false;

				string tooltipText = ngps.BuildCharacterInfoTooltip();
				if (gladiatorRank > 0)
					tooltipText += Resources::GetString(".charinfo.arena.rank", { { "rank", gladiatorRank } }) + "\n";

				if (gss !is null)
				{
					if (m_context.findFirst("multi-") == 0)
					{
						if (mercenary)
						{
							wNewItem.m_enabled = false;
							tooltipText += "\\cff0000" + Resources::GetString(".mainmenu.character.select.restrict.insession") + "\\d\n";
						}
						else
						{
							// Make it yellow as a warning
							tooltipText += "\\cffff00";
						}
					}

					auto svGm = gss.GetGamemode();
					if (svGm !is null)
					{
						string dungeonId = GetParamString(UnitPtr(), svGm, "dungeon-id", false);
						int levelCount = GetParamInt(UnitPtr(), svGm, "level-count", false);

						string dungeonName = "??";
						string floorName = "??";
						string actName = "??";

						auto dungeon = DungeonProperties::Get(dungeonId);
						if (dungeon !is null)
						{
							if (dungeon.m_name != "")
								dungeonName = Resources::GetString(dungeon.m_name);

							auto dungeonLevel = dungeon.GetLevel(levelCount);
							if (dungeonLevel !is null)
							{
								floorName = dungeon.GetFloorName(dungeonLevel);
								actName = dungeon.GetActName(dungeonLevel);
							}
						}
						else
							floorName = Resources::GetString(".world.floor", { { "num", levelCount + 1 } });

						tooltipText += Resources::GetString(".mainmenu.character.select.currently", {
							{ "dungeon", dungeonName },
							{ "act", UcFirst(utf8string(actName), true).plain() },
							{ "floor", UcFirst(utf8string(floorName), true).plain() }
						}) + "\n";
					}
				}

				wNewItem.m_tooltipText = strTrim(tooltipText);

				array<Materials::Dye@> dyes = Materials::DyesFromSval(svChar);

				auto wUnit = cast<UnitWidget>(wNewItem.GetWidgetById("unit"));
				if (wUnit !is null)
				{
					wUnit.m_visible = charClassExists;
					if (charClassExists)
					{
						wUnit.AddUnit(charClassUnitPath, "idle-3");
						wUnit.m_dyeStates = Materials::MakeDyeStates(dyes);
					}
				}

				if (!charClassExists)
				{
					auto wUnknownClass = wNewItem.GetWidgetById("unknown-class");
					if (wUnknownClass !is null)
						wUnknownClass.m_visible = true;
				}

				auto wPortrait = cast<PortraitWidget>(wNewItem.GetWidgetById("portrait"));
				if (wPortrait !is null)
				{
					wPortrait.m_visible = charClassExists;
					if (charClassExists)
					{
						wPortrait.SetClass(charClass);
						wPortrait.SetFace(face);
						wPortrait.SetDyes(dyes);
						wPortrait.SetFrame(frame);
						wPortrait.UpdatePortrait();
					}
				}

				auto wLevel = cast<TextWidget>(wNewItem.GetWidgetById("level"));
				if (wLevel !is null)
				{
					wLevel.SetText("" + level);
					if (ngp == 0 && desertNgp == 0)
						wLevel.m_anchor.y = 0.5;

					if (mercenary)
						wLevel.SetColor(ParseColorRGBA("#CC7D4FFF"));
				}

				auto wName = cast<TextWidget>(wNewItem.GetWidgetById("name"));
				if (wName !is null)
				{
					if (mercenary)
					{
						auto title = g_classTitles.m_titlesMercenary.GetTitleFromPoints(mercenaryPrestige);
						wName.SetText(Resources::GetString(title.m_name) + " " + name);
					}
					else
					{
						string charClassName;
						if (charClassExists)
							charClassName = Resources::GetString(".class." + charClass);
						else
							charClassName = GetModClassName(charClass);
						dictionary params = { { "name", name }, { "class", charClassName } };
						wName.SetText(Resources::GetString(".mainmenu.character.select.name", params));
					}

					if (mercenary)
						wName.SetColor(ParseColorRGBA("#CC7D4FFF"));
				}

				if (mercenary)
				{
					array<Widget@> arrMercFrames = {
						wNewItem.GetWidgetById("merc-frame-unit"),
						wNewItem.GetWidgetById("merc-frame-level"),
						wNewItem.GetWidgetById("merc-frame-name")
					};

					for (uint j = 0; j < arrMercFrames.length(); j++)
						arrMercFrames[j].m_visible = true;
				}

				m_wList.AddChild(wNewItem);

				if (i == 0 && wNewItem.m_enabled)
					wNewItem.SetChecked(true);
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "new")
				OpenMenu(CharacterCreationMenu(m_provider, m_context), "gui/main_menu/character_creation.gui");
			else if (name == "play")
			{
				auto wChecked = m_wList.GetChecked();
				if (wChecked is null)
					return;
				HwrSaves::PickCharacter(parseInt(wChecked.GetValue()));

				FinishContext(m_context);
			}
			else if (name == "delete")
			{
				auto wChecked = cast<Widget>(m_wList.GetChecked());
				if (wChecked is null)
					return;
				auto wName = cast<TextWidget>(wChecked.GetWidgetById("name"));
				g_gameMode.ShowDialog(
					"delete",
					Resources::GetString(".mainmenu.character.delete.text", { { "name", wName.m_str } }),
					Resources::GetString(".misc.yes"),
					Resources::GetString(".misc.no"),
					this
				);
			}
			else if (name == "delete yes")
			{
				auto wChecked = m_wList.GetChecked();
				if (wChecked is null)
					return;
				HwrSaves::DeleteCharacter(parseInt(wChecked.GetValue()));
				ReloadList();
			}
			else
				HwrMenu::OnFunc(sender, name);
		}
	}
}
