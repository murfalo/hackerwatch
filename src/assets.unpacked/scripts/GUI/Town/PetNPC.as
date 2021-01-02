class PetNPC : ScriptWidgetHost
{
	Sprite@ m_iconGold;

	CheckBoxGroupWidget@ m_wListPets;

	CheckBoxGroupWidget@ m_wListSkins;
	Widget@ m_wTemplateSkin;

	Widget@ m_wListFlags;
	Widget@ m_wTemplateFlag;

	Pets::PetDef@ m_currentPetDef;
	int m_currentPetSkin;
	array<uint> m_currentPetFlags;

	PetNPC(SValue& params)
	{
		super();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Initialize(bool loaded) override
	{
		@m_iconGold = m_def.GetSprite("icon-gold");

		@m_wListPets = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list-pets"));

		@m_wListSkins = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list-skins"));
		@m_wTemplateSkin = m_widget.GetWidgetById("template-skin");

		@m_wListFlags = m_widget.GetWidgetById("list-flags");
		@m_wTemplateFlag = m_widget.GetWidgetById("template-flag");

		auto wTemplatePet = m_widget.GetWidgetById("template-pet");

		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < Pets::g_defs.length(); i++)
		{
			auto petDef = Pets::g_defs[i];
			bool petUnlocked = record.IsPetUnlocked(petDef);

			auto wNewPet = cast<CheckBoxWidget>(wTemplatePet.Clone());
			wNewPet.m_visible = true;
			wNewPet.SetID("");

			auto wUnlocked = wNewPet.GetWidgetById("unlocked");
			if (wUnlocked !is null)
				wUnlocked.m_visible = petUnlocked;

			string restrictionText = "";

			if (petDef.m_requiredClass != "")
			{
				wNewPet.m_enabled = wNewPet.m_enabled && (record.charClass == petDef.m_requiredClass);
				restrictionText += "\n" + Resources::GetString(".town.pets.restriction.class", {
					{ "class", Resources::GetString(".class." + petDef.m_requiredClass) }
				});
			}

			for (uint j = 0; j < petDef.m_requiredDlcs.length(); j++)
			{
				auto dlc = petDef.m_requiredDlcs[j];
				wNewPet.m_enabled = wNewPet.m_enabled && HasDLC(dlc);
				restrictionText += "\n" + Resources::GetString(".town.pets.restriction.dlc", {
					{ "dlc", Resources::GetString(".dlc." + dlc) }
				});
			}

			for (uint j = 0; j < petDef.m_requiredFlags.length(); j++)
			{
				auto flagRequirement = petDef.m_requiredFlags[j];
				wNewPet.m_enabled = wNewPet.m_enabled && g_flags.IsSet(flagRequirement.m_flag);
				restrictionText += "\n" + Resources::GetString(flagRequirement.m_text);
			}

			wNewPet.m_tooltipTitle = Resources::GetString(petDef.m_name);
			wNewPet.m_tooltipText = Resources::GetString(petDef.m_description);
			wNewPet.m_tooltipText	+= restrictionText;

			if (!petUnlocked)
				wNewPet.AddTooltipSub(m_iconGold, formatThousands(petDef.m_cost));

			wNewPet.m_value = petDef.m_id;

			auto wIcon = cast<SpriteWidget>(wNewPet.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(petDef.GetIcon());

			m_wListPets.AddChild(wNewPet);
		}

		if (record.currentPet == 0)
		{
			m_wListPets.SetChecked("");
			m_currentPetSkin = 0;
			m_currentPetFlags.removeRange(0, m_currentPetFlags.length());
		}
		else
		{
			@m_currentPetDef = Pets::GetDef(record.currentPet);
			if (m_currentPetDef !is null)
				m_wListPets.SetChecked(m_currentPetDef.m_id);
			else
				m_wListPets.SetChecked("");
			m_currentPetSkin = record.currentPetSkin;
			m_currentPetFlags = record.currentPetFlags;
		}

		ReloadPetOptions();
	}

	void ReloadPetOptions()
	{
		UpdateButton();

		m_wListSkins.ClearChildren();
		m_wListFlags.ClearChildren();

		if (m_currentPetDef is null)
			return;

		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		for (uint i = 0; i < m_currentPetDef.m_skins.length(); i++)
		{
			auto petSkin = m_currentPetDef.m_skins[i];

			if (petSkin.m_legacyPoints > 0 && gm.m_townLocal.m_petSkins.find(petSkin.m_idHash) == -1)
				continue;

			auto wNewSkin = cast<CheckBoxWidget>(m_wTemplateSkin.Clone());
			wNewSkin.m_visible = true;
			wNewSkin.SetID("");

			wNewSkin.m_tooltipTitle = Resources::GetString(petSkin.m_name);

			if (petSkin.m_cost > 0)
				wNewSkin.AddTooltipSub(m_iconGold, formatThousands(petSkin.m_cost));

			wNewSkin.m_value = "" + i;

			auto wIcon = cast<SpriteWidget>(wNewSkin.GetWidgetById("icon"));
			if (wIcon !is null)
				wIcon.SetSprite(petSkin.m_icon);

			m_wListSkins.AddChild(wNewSkin);
		}
		m_wListSkins.SetChecked(m_currentPetSkin);

		for (uint i = 0; i < Pets::g_flags.length(); i++)
			AddNewFlag(Pets::g_flags[i]);

		for (uint i = 0; i < m_currentPetDef.m_flags.length(); i++)
			AddNewFlag(m_currentPetDef.m_flags[i]);
	}

	void AddNewFlag(Pets::PetFlag@ petFlag)
	{
		auto wNewFlag = cast<CheckBoxWidget>(m_wTemplateFlag.Clone());
		wNewFlag.m_visible = true;
		wNewFlag.SetID("");

		wNewFlag.m_tooltipText = Resources::GetString(petFlag.m_description);

		wNewFlag.m_value = petFlag.m_id;
		wNewFlag.m_checked = (m_currentPetFlags.find(petFlag.m_idHash) != -1);

		wNewFlag.SetText(Resources::GetString(petFlag.m_name));

		m_wListFlags.AddChild(wNewFlag);
	}

	void UpdateButton()
	{
		auto wButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button"));
		if (wButton is null)
			return;

		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return;

		int cost = GetCost();

		wButton.SetText(formatThousands(cost));
		wButton.m_enabled = Currency::CanAfford(cost);
	}

	int GetCost()
	{
		int ret = 0;

		auto record = GetLocalPlayerRecord();
		if (m_currentPetDef !is null)
		{
			if (!record.IsPetUnlocked(m_currentPetDef))
				ret += m_currentPetDef.m_cost;

			auto skin = m_currentPetDef.m_skins[m_currentPetSkin];
			if (m_currentPetSkin != record.currentPetSkin)
				ret += skin.m_cost;
		}

		return ret;
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "pet-changed")
		{
			auto record = GetLocalPlayerRecord();

			auto wChecked = cast<CheckBoxWidget>(m_wListPets.GetChecked());
			if (wChecked.m_value == "")
				@m_currentPetDef = null;
			else
				@m_currentPetDef = Pets::GetDef(wChecked.m_value);

			if (m_currentPetDef is null || record.currentPet != m_currentPetDef.m_idHash)
				m_currentPetSkin = 0;
			else
				m_currentPetSkin = record.currentPetSkin;

			m_currentPetFlags.removeRange(0, m_currentPetFlags.length());
			if (m_currentPetDef !is null)
			{
				for (uint i = 0; i < Pets::g_flags.length(); i++)
				{
					auto petFlag = Pets::g_flags[i];
					if (petFlag.m_default)
						m_currentPetFlags.insertLast(petFlag.m_idHash);
				}

				for (uint i = 0; i < m_currentPetDef.m_flags.length(); i++)
				{
					auto petFlag = m_currentPetDef.m_flags[i];
					if (petFlag.m_default)
						m_currentPetFlags.insertLast(petFlag.m_idHash);
				}
			}

			ReloadPetOptions();
			UpdateButton();
		}
		else if (name == "skin-changed")
		{
			auto wChecked = cast<CheckBoxWidget>(m_wListSkins.GetChecked());
			m_currentPetSkin = parseInt(wChecked.m_value);
		}
		else if (name == "flag-changed")
		{
			auto wChecked = cast<CheckBoxWidget>(sender);
			if (wChecked is null)
			{
				PrintError("Flag changed func, but it's not a checkbox?");
				return;
			}

			string id = wChecked.m_value;
			uint idHash = HashString(id);

			if (wChecked.m_checked)
			{
				if (m_currentPetFlags.find(idHash) != -1)
				{
					PrintError("Flag is already set!");
					return;
				}
				m_currentPetFlags.insertLast(idHash);
			}
			else
			{
				int index = m_currentPetFlags.find(idHash);
				if (index == -1)
				{
					PrintError("Flag is not set!");
					return;
				}
				m_currentPetFlags.removeAt(index);
			}
		}
		else if (name == "finish")
		{
			int cost = GetCost();
			if (!Currency::CanAfford(cost))
			{
				PrintError("Not enough gold!");
				Stop();
				return;
			}

			Currency::Spend(cost);

			auto record = GetLocalPlayerRecord();
			if (m_currentPetDef is null)
				record.currentPet = 0;
			else
			{
				record.currentPet = m_currentPetDef.m_idHash;
				Platform::Service.UnlockAchievement("pet_bought");
			}
			record.currentPetSkin = m_currentPetSkin;
			record.currentPetFlags = m_currentPetFlags;
			record.UnlockPet(m_currentPetDef);

			auto player = GetLocalPlayer();
			if (player !is null)
				player.LoadPet();

			Stop();
		}
		else if (name == "back")
			Stop();
	}
}
