namespace Menu
{
	class CharacterCreationMenu : HwrMenu
	{
		string m_context;

		CheckBoxGroupWidget@ m_wGroupClass;

		CheckBoxWidget@ m_wMercenary;

		array<UnitWidget@> m_wPreviews;

		string m_charClass;
		bool m_charMercenary;

		CharacterCreationMenu(MenuProvider@ provider, string context)
		{
			super(provider);

			m_context = context;
		}

		void Initialize(GUIDef@ def) override
		{
			auto wOptions = m_widget.GetWidgetById("options");
			if (wOptions !is null)
				wOptions.m_visible = Platform::HasDLC("mt");

			@m_wGroupClass = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("group-class"));

			for (uint i = 0; i < m_wGroupClass.m_children.length(); i++)
			{
				auto wCheckbox = cast<CheckBoxWidget>(m_wGroupClass.m_children[i]);

				string className = wCheckbox.GetValue();
				wCheckbox.m_enabled = IsClassUnlocked(className);

				wCheckbox.m_tooltipTitle = Resources::GetString(".class." + className);
				if (wCheckbox.m_enabled)
					wCheckbox.m_tooltipText = Resources::GetString(".class." + className + ".desc");
				else
					wCheckbox.m_tooltipText = Resources::GetString(".class." + className + ".disabled.desc");

				auto wPreview = cast<UnitWidget>(wCheckbox.GetWidgetById("preview"));
				wPreview.ClearUnits();

				auto uws = wPreview.AddUnit("players/" + className + ".unit", "idle-3");
				if (uws !is null)
					uws.m_offset = vec2(3, 3);

				auto dyeMap = Materials::GetDyeMapping(className);
				for (uint j = 0; j < dyeMap.m_categories.length(); j++)
				{
					auto category = dyeMap.m_categories[j];
					auto dye = Materials::GetRandomDye(category);
					wPreview.m_dyeStates.insertLast(dye.MakeDyeState());
				}

				m_wPreviews.insertLast(wPreview);
			}

			@m_wMercenary = cast<CheckBoxWidget>(m_widget.GetWidgetById("mercenary"));
			if (m_wMercenary !is null)
			{
				if (Platform::HasDLC("mt"))
				{
					m_wMercenary.m_enabled = true;
					m_wMercenary.m_tooltipText = Resources::GetString(".mainmenu.character.create.mercenary.tooltip");
				}
				else
					m_wMercenary.m_tooltipText = Resources::GetString(".mainmenu.character.create.mercenary.tooltip.blocked");
			}

			m_wGroupClass.SetCheckedRandom();
			ClassChanged();
		}

		bool IsBuildingLevel(string id, int level)
		{
			auto gm = cast<MainMenu>(g_gameMode);

			auto building = gm.m_town.GetBuilding(id);
			if (building is null)
				return false;

			return (building.m_level >= level);
		}

		bool IsTownFlagSet(string id)
		{
			return g_flags.Get(id) != FlagState::Off;
		}

		bool IsClassUnlocked(string className)
		{
			if (className == "thief")
				return IsBuildingLevel("tavern", 1);

			if (className == "priest")
				return IsBuildingLevel("chapel", 1);

			if (className == "wizard")
			 	return IsBuildingLevel("magicshop", 1);

			if (className == "paladin" || className == "ranger" || className == "sorcerer" || className == "warlock")
				return true;

			if (className == "gladiator")
				return IsTownFlagSet("unlock_gladiator") && Platform::HasDLC("pop");

			if (className == "witch_hunter")
				return Platform::HasDLC("wh");

			return false;
		}

		bool IsMercenaryAvailable()
		{
			auto arrCharacters = HwrSaves::GetCharacters();
			for (uint i = 0; i < arrCharacters.length(); i++)
			{
				auto svChar = arrCharacters[i];
				string charClass = GetParamString(UnitPtr(), svChar, "class");
				if (charClass == m_charClass)
				{
					int level = GetParamInt(UnitPtr(), svChar, "level");
					if (level >= 20)
						return true;
				}
			}
			return false;
		}

		void ClassChanged()
		{
			auto wSkillsRegular = m_widget.GetWidgetById("skills-regular");
			auto wSkillsMercenary = m_widget.GetWidgetById("skills-mercenary");

			m_charClass = m_wGroupClass.GetChecked().GetValue();

			SValue@ svalClass = Resources::GetSValue("players/" + m_charClass + "/char.sval");
			if (svalClass is null)
			{
				PrintError("Couldn't get SValue file for class \"" + m_charClass + "\"");
				return;
			}

			auto arrClassSkills = GetParamArray(UnitPtr(), svalClass, "skills");

			for (uint i = 0; i < uint(min(arrClassSkills.length(), 7)); i++)
			{
				string skillFnm = arrClassSkills[i].GetString();
				auto skill = Resources::GetSValue(skillFnm);

				string skillName = GetParamString(UnitPtr(), skill, "name");
				string skillDesc = skillName + ".create";

				auto arrIcon = GetParamArray(UnitPtr(), skill, "icon");
				auto spriteIcon = ScriptSprite(arrIcon);

				array<SpriteWidget@> arrSkillIcons = {
					cast<SpriteWidget>(wSkillsRegular.GetWidgetById("skill-" + i)),
					cast<SpriteWidget>(wSkillsMercenary.GetWidgetById("skill-" + i))
				};

				for (uint j = 0; j < arrSkillIcons.length(); j++)
				{
					auto wSkillIcon = arrSkillIcons[j];
					if (wSkillIcon is null)
						continue;

					wSkillIcon.SetSprite(spriteIcon);
					wSkillIcon.m_tooltipTitle = Resources::GetString(skillName);
					wSkillIcon.m_tooltipText = Resources::GetString(skillDesc);
				}
			}

			if (Platform::HasDLC("mt"))
			{
				m_wMercenary.m_enabled = IsMercenaryAvailable();
				if (!m_wMercenary.m_enabled)
				{
					m_wMercenary.SetChecked(false);
					m_wMercenary.m_tooltipText = Resources::GetString(".mainmenu.character.create.mercenary.tooltip.level20");
					m_charMercenary = false;
				}
				else
					m_wMercenary.m_tooltipText = Resources::GetString(".mainmenu.character.create.mercenary.tooltip");
			}

			if (wSkillsRegular !is null)
				wSkillsRegular.m_visible = !m_charMercenary;
			if (wSkillsMercenary !is null)
				wSkillsMercenary.m_visible = m_charMercenary;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");
			if (name == "class-changed")
				ClassChanged();
			else if (name == "mercenary-changed")
			{
				auto checkMercenary = cast<CheckBoxWidget>(sender);
				m_charMercenary = checkMercenary.IsChecked();
				ClassChanged();
			}
			else if (name == "mercenary-help")
				OpenMenu(Menu::Menu(m_provider), "gui/main_menu/mercenary_info.gui");
			else if (name == "next")
				OpenMenu(CharacterCustomizationMenu(m_provider, this, m_context), "gui/main_menu/character_customization.gui");
			else
				HwrMenu::OnFunc(sender, name);
		}
	}
}
