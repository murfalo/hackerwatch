namespace Menu
{
	class SlotsMenu : HwrMenu
	{
		ScrollableWidget@ m_wSlots;
		Widget@ m_wTemplate;

		int m_firstEmptySlot;

		array<SaveSlot@> m_saveSlots;
		int m_selectedSlot;

		int m_startSlot;
		array<uint> m_startMods;

		SlotsMenu(MenuProvider@ provider)
		{
			super(provider);
		}

		void Initialize(GUIDef@ def) override
		{
			HwrMenu::Initialize(def);

			@m_wSlots = cast<ScrollableWidget>(m_widget.GetWidgetById("slots"));
			@m_wTemplate = m_widget.GetWidgetById("template");

			m_saveSlots = HwrSaves::GetSaveSlots();
			if (m_saveSlots.length() == 0)
				m_saveSlots.insertLast(HwrSaves::CreateSlot(0));

			m_startSlot = m_selectedSlot = GetVarInt("g_save_slot");

			auto startSlot = GetSlotInfo(m_startSlot);
			if (startSlot !is null)
				m_startMods = startSlot.EnabledMods;

			RefreshSlots();
		}

		void Show() override
		{
			RefreshSlots();
			HwrMenu::Show();
		}

		void RefreshSlots()
		{
			m_wSlots.PauseScrolling();
			m_wSlots.ClearChildren();

			m_firstEmptySlot = -1;

			auto guildTitles = Titles::TitleList("tweak/titles/guild.sval");

			int maxIndex = 0;

			for (uint i = 0; i < m_saveSlots.length(); i++)
			{
				if (m_saveSlots[i].Slot > maxIndex)
					maxIndex = m_saveSlots[i].Slot;
			}

			if (maxIndex > 100)
				maxIndex = 100;

			int index = 0;
			for (int i = 0; i < maxIndex + 2; i++)
			{
				SaveSlot@ slot = GetSlotInfo(i);
				//bool slotHasTown = (index < int(m_saveSlots.length()) && m_saveSlots[index].Slot == i);

				if (slot is null && m_firstEmptySlot == -1)
					m_firstEmptySlot = i;

				auto wNewSlot = cast<RectWidget>(m_wTemplate.Clone());
				wNewSlot.SetID("");
				wNewSlot.m_visible = true;

				Widget@ wState = null;

				auto wName = cast<TextWidget>(wNewSlot.GetWidgetById("name"));

				if (slot !is null)
				{
					int rep = 0;
					if (slot.Town !is null)
					{
						TownRecord town;
						town.Load(slot.Town);
						rep = town.GetReputation();
					}

					auto title = guildTitles.GetTitleFromPoints(rep);

					string slotName = Resources::GetString(".mainmenu.slots.name", { { "num", slot.Slot + 1 } });

					if (title !is null)
						slotName += ": " + Resources::GetString(title.m_name);

					wName.SetText(slotName);
					wNewSlot.m_color = tocolor(vec4(0, 0.33f, 0, 1));
					index++;

					@wState = wNewSlot.GetWidgetById("state-slot");
				}
				else
				{
					wName.SetText(Resources::GetString(".mainmenu.slots.name", { { "num", i + 1 } }));
					@wState = wNewSlot.GetWidgetById("state-empty");
				}

				if (slot !is null && slot.Modded)
				{
					auto wModded = wNewSlot.GetWidgetById("modded");
					if (wModded !is null)
					{
						auto enabledMods = slot.EnabledMods;

						wModded.m_visible = true;

						if (enabledMods.length() == 1)
							wModded.m_tooltipTitle = Resources::GetString(".mods.count.1");
						else
							wModded.m_tooltipTitle = Resources::GetString(".mods.count", { { "num", enabledMods.length() } });

						if (enabledMods.length() == 0)
							wModded.m_tooltipText = Resources::GetString(".mods.help.modded");
						else
						{
							for (uint j = 0; j < enabledMods.length(); j++)
							{
								if (j > 0)
									wModded.m_tooltipText += "\n";

								auto mod = Platform::GetResourceMod(enabledMods[j]);
								if (mod is null)
									continue;

								wModded.m_tooltipText += mod.Name;
								/*
								wModded.m_tooltipText += Resources::GetString(".mods.listitem", {
									{ "name", mod.Name },
									{ "author", mod.Author }
								});
								*/
							}
						}
					}
				}

				auto wButtons = wNewSlot.GetWidgetById("buttons");

				for (uint j = 0; j < wButtons.m_children.length(); j++)
				{
					auto wButton = cast<ScalableSpriteButtonWidget>(wButtons.m_children[j]);
					if (wButton !is null)
						wButton.m_func += " " + i;
				}

				if (i == m_selectedSlot)
					@wState = wNewSlot.GetWidgetById("state-current");
				else
				{
					auto wButtonSwitch = cast<ScalableSpriteButtonWidget>(wButtons.GetWidgetById("switch"));
					wButtonSwitch.m_enabled = true;

					if (slot is null)
					{
						wButtonSwitch.m_tooltipText = Resources::GetString(".mainmenu.slots.create");

						auto wSwitchIcon = cast<SpriteWidget>(wButtonSwitch.m_children[0]);
						if (wSwitchIcon !is null)
							wSwitchIcon.SetSprite("icon-house-create");
					}
				}

				auto wButtonDelete = cast<ScalableSpriteButtonWidget>(wButtons.GetWidgetById("delete"));
				wButtonDelete.m_enabled = (i != m_selectedSlot && slot !is null);
				wButtonDelete.m_visible = (slot !is null);

				auto wButtonEdit = wButtons.GetWidgetById("edit");
				wButtonEdit.m_visible = (slot !is null);

				auto wButtonClone = wButtons.GetWidgetById("clone");
				wButtonClone.m_visible = (slot !is null);

				if (wState !is null)
					wState.m_visible = true;

				m_wSlots.AddChild(wNewSlot);
			}

			m_wSlots.ResumeScrolling();
		}

		SaveSlot@ GetSlotInfo(int slot)
		{
			for (uint i = 0; i < m_saveSlots.length(); i++)
			{
				if (m_saveSlots[i].Slot == slot)
					return m_saveSlots[i];
			}
			return null;
		}

		bool Close() override
		{
			HwrSaves::SwitchSlot(m_selectedSlot);
			SetVar("g_save_slot", m_selectedSlot);
			Config::SaveVar("g_save_slot", "" + m_selectedSlot);

			auto slot = GetSlotInfo(m_selectedSlot);

			bool reloadRequired = false;
			if (slot !is null)
			{
				auto newMods = slot.EnabledMods;
				if (m_startMods.length() != newMods.length())
					reloadRequired = true;
				else
				{
					for (uint i = 0; i < m_startMods.length(); i++)
					{
						if (newMods.find(m_startMods[i]) == -1)
						{
							reloadRequired = true;
							break;
						}
					}
				}
			}

			if (reloadRequired)
			{
				RestartMenu();
				return false;
			}

			if (!HwrMenu::Close())
				return false;
			
			g_flags.m_flags.deleteAll();
			
			SValue@ svTown = null;
			if (slot !is null)
				@svTown = slot.Town;
			
			auto gm = cast<MainMenu>(g_gameMode);
			@gm.m_town = TownRecord();
			gm.m_town.Load(svTown);
			return true;
		}

		void OnFunc(Widget@ sender, string name) override
		{
			auto parse = name.split(" ");
			if (parse[0] == "switch")
			{
				int newSlot = parseInt(parse[1]);

				auto slot = GetSlotInfo(newSlot);
				if (slot is null)
					m_saveSlots.insertLast(HwrSaves::CreateSlot(newSlot));

				m_selectedSlot = newSlot;

				RefreshSlots();
			}
			else if (parse[0] == "clone")
			{
				int slot = parseInt(parse[1]);

				if (parse.length() == 3)
				{
					if (parse[2] == "yes")
					{
						HwrSaves::CopyTown(slot, m_firstEmptySlot);
						m_selectedSlot = m_firstEmptySlot;

						auto arr = HwrSaves::GetSaveSlots();
						for (uint i = 0; i < arr.length(); i++)
						{
							if (arr[i].Slot == m_selectedSlot)
							{
								m_saveSlots.insertLast(arr[i]);
								break;
							}
						}

						RefreshSlots();
					}
				}
				else
				{
					g_gameMode.ShowDialog(
						"clone " + slot,
						Resources::GetString(".mainmenu.slots.clone.prompt", {
							{ "num", slot + 1 },
							{ "newnum", m_firstEmptySlot + 1 }
						}),
						Resources::GetString(".misc.yes"),
						Resources::GetString(".misc.no"),
						this
					);
				}
			}
			else if (parse[0] == "edit")
			{
				int slot = parseInt(parse[1]);
				auto slotInfo = GetSlotInfo(slot);

				if (parse.length() == 3)
				{
					if (parse[2] == "yes")
						OpenMenu(EditSlotMenu(m_provider, slotInfo), "gui/main_menu/editslot.gui");
				}
				else
				{
					if (slotInfo.Modded)
						OpenMenu(EditSlotMenu(m_provider, slotInfo), "gui/main_menu/editslot.gui");
					else
					{
						g_gameMode.ShowDialog(
							"edit " + slot,
							Resources::GetString(".mainmenu.slots.edit.prompt", { { "num", slot + 1 } }),
							Resources::GetString(".misc.yes"),
							Resources::GetString(".misc.no"),
							this
						);
					}
				}
			}
			else if (parse[0] == "delete")
			{
				int slot = parseInt(parse[1]);

				if (parse.length() == 3)
				{
					if (parse[2] == "yes")
					{
						HwrSaves::DeleteTown(slot);
						int index = -1;
						for (uint i = 0; i < m_saveSlots.length(); i++)
						{
							if (m_saveSlots[i].Slot == slot)
							{
								index = i;
								break;
							}
						}
						if (index != -1)
							m_saveSlots.removeAt(index);
						RefreshSlots();
					}
				}
				else
				{
					g_gameMode.ShowDialog(
						"delete " + slot,
						Resources::GetString(".mainmenu.slots.delete.prompt", { { "num", slot + 1 } }),
						Resources::GetString(".misc.yes"),
						Resources::GetString(".misc.no"),
						this
					);
				}
			}
			else
				HwrMenu::OnFunc(sender, name);
		}
	}
}
