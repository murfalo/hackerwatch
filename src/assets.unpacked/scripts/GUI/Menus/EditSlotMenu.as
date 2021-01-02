namespace Menu
{
	class SortableMod
	{
		ResourceMod@ m_mod;

		SortableMod(ResourceMod@ mod)
		{
			@m_mod = mod;
		}

		int opCmp(const SortableMod &in mod) const
		{
			int author = m_mod.Author.opCmp(mod.m_mod.Author);
			if (author != 0)
				return author;

			int name = m_mod.Name.opCmp(mod.m_mod.Name);
			if (name != 0)
				return name;

			int id = m_mod.ID.opCmp(mod.m_mod.ID);
			if (id != 0)
				return id;

			if (m_mod.Packaged && !mod.m_mod.Packaged)
				return -1;
			else if (!m_mod.Packaged && mod.m_mod.Packaged)
				return 1;

			return 0;
		}
	}

	class EditSlotMenu : HwrMenu
	{
		Widget@ m_wSaving;
		Widget@ m_wWindow;

		TextInputWidget@ m_wFilter;
		FilteredListWidget@ m_wModList;
		Widget@ m_wModTemplate;

		SaveSlot@ m_slot;

		bool m_saving;

		EditSlotMenu(MenuProvider@ provider, SaveSlot@ originSlot = null)
		{
			super(provider);

			@m_slot = originSlot;
		}

		void Initialize(GUIDef@ def) override
		{
			@m_wSaving = m_widget.GetWidgetById("saving");
			@m_wWindow = m_widget.GetWidgetById("window");

			@m_wFilter = cast<TextInputWidget>(m_widget.GetWidgetById("filter"));
			@m_wModList = cast<FilteredListWidget>(m_widget.GetWidgetById("mod-list"));
			@m_wModTemplate = m_widget.GetWidgetById("mod-template");

			array<uint32> enabledMods;
			if (m_slot !is null)
				enabledMods = m_slot.EnabledMods;

			auto actualMods = Platform::GetAllResourceMods();

			array<SortableMod@> mods;
			for (uint i = 0; i < actualMods.length(); i++)
				mods.insertLast(SortableMod(actualMods[i]));
			mods.sortAsc();

			for (uint i = 0; i < mods.length(); i++)
			{
				auto mod = mods[i].m_mod;

				auto wNewMod = cast<ScalableSpriteButtonWidget>(m_wModTemplate.Clone());
				wNewMod.SetID("");
				wNewMod.m_visible = true;

				wNewMod.SetText(mod.Name);
				wNewMod.m_value = mod.ID;
				wNewMod.m_filter = (mod.Name + " " + mod.Author + " " + mod.ID).toLower();

				if (m_slot !is null)
					wNewMod.SetChecked(enabledMods.find(HashString(mod.ID)) != -1);

				wNewMod.m_tooltipTitle = Resources::GetString(".mods.by", { { "author", mod.Author } });
				wNewMod.m_tooltipText = mod.Description;

				if (!mod.Packaged)
				{
					wNewMod.m_tooltipText += "\n\n" + Resources::GetString(".mods.unpacked");

					auto wUnpacked = wNewMod.GetWidgetById("unpacked");
					wUnpacked.m_visible = true;
					wNewMod.m_textOffset.x += wUnpacked.m_width + 2;
				}

				auto wAuthor = cast<TextWidget>(wNewMod.GetWidgetById("author"));
				if (wAuthor !is null)
					wAuthor.SetText(mod.Author);

				m_wModList.AddChild(wNewMod);
			}
		}

		bool GoBack() override
		{
			if (m_saving)
				return true;
			return HwrMenu::GoBack();
		}

		void Update(int dt) override
		{
			HwrMenu::Update(dt);

			if (m_saving && !HwrSaves::IsSaving())
			{
				m_saving = false;
				Close();
			}
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "ok")
			{
				print("ok, setting mods in " + m_slot.Slot);

				for (uint i = 0; i < m_wModList.m_children.length(); i++)
				{
					auto wCheck = cast<ICheckableWidget>(m_wModList.m_children[i]);
					if (wCheck is null)
						continue;

					string modIdString = wCheck.GetValue();
					uint modId = HashString(modIdString);
					if (wCheck.IsChecked())
						m_slot.EnableMod(modId);
					else
						m_slot.DisableMod(modId);
				}

				m_slot.Write();
				m_saving = true;

				m_wSaving.m_visible = true;
				m_wWindow.m_visible = false;
			}
			else if (name == "filterlist")
				m_wModList.SetFilter(m_wFilter.m_text.plain());
			else if (name == "filterlist-clear")
			{
				m_wFilter.ClearText();
				m_wModList.ShowAll();
			}
			else
				HwrMenu::OnFunc(sender, name);
		}
	}
}
