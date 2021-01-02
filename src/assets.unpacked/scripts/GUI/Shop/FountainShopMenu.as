class FountainShopMenuContent : ShopMenuContent
{
	ScalableSpriteIconButtonWidget@ m_wButton;

	Widget@ m_wTemplateWish;
	Widget@ m_wListGood;
	Widget@ m_wListBad;

	SpriteWidget@ m_wScale;

	TextWidget@ m_wPoints;
	TextWidget@ m_wGoldGain;
	TextWidget@ m_wExpMul;

	TextWidget@ m_wDepositGold;
	Widget@ m_wDepositButtons;

	Widget@ m_wListPresets;
	Widget@ m_wTemplatePreset;

	SoundEvent@ m_sndLockIn;

	array<FavorButtonWidget@> m_arrButtons;

	FountainShopMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.fountain");
	}

	void OnShow() override
	{
		@m_wButton = cast<ScalableSpriteIconButtonWidget>(m_widget.GetWidgetById("button"));

		@m_wTemplateWish = m_widget.GetWidgetById("wish-template");
		@m_wListGood = m_widget.GetWidgetById("wishes-good");
		@m_wListBad = m_widget.GetWidgetById("wishes-bad");

		@m_wScale = cast<SpriteWidget>(m_widget.GetWidgetById("scale"));

		@m_wPoints = cast<TextWidget>(m_widget.GetWidgetById("favor-points"));
		@m_wGoldGain = cast<TextWidget>(m_widget.GetWidgetById("gold-gain"));
		@m_wExpMul = cast<TextWidget>(m_widget.GetWidgetById("exp-mul"));

		@m_wDepositGold = cast<TextWidget>(m_widget.GetWidgetById("deposited-gold"));
		@m_wDepositButtons = m_widget.GetWidgetById("deposit-buttons");

		@m_wListPresets = m_widget.GetWidgetById("preset-list");
		@m_wTemplatePreset = m_widget.GetWidgetById("preset-template");

		@m_sndLockIn = Resources::GetSoundEvent("event:/ui/lockin");

		ReloadList();
		ReloadPresets();

		UpdateInterface();
	}

	void ReloadList() override
	{
		m_wListBad.ClearChildren();
		m_wListGood.ClearChildren();

		for (uint i = 0; i < Fountain::AvailableEffects.length(); i++)
		{
			auto effect = Fountain::AvailableEffects[i];

			if (Fountain::CurrentEffects.length() > 0 && !Fountain::HasEffect(effect.m_idHash))
				continue;

			Widget@ wList;
			if (effect.m_favor < 0)
				@wList = m_wListBad;
			else if (effect.m_favor > 0)
				@wList = m_wListGood;

			auto wNewButton = cast<FavorButtonWidget>(m_wTemplateWish.Clone());
			wNewButton.SetID("");
			wNewButton.m_visible = true;
			wNewButton.Set(effect, m_shopMenu.m_currentShopLevel);
			wList.AddChild(wNewButton);

			m_arrButtons.insertLast(wNewButton);
		}

		m_wListGood.m_children.sortAsc();
		m_wListBad.m_children.sortDesc();
	}

	void ReloadPresets()
	{
		if (!Network::IsServer())
		{
			auto wPresets = m_widget.GetWidgetById("presets");
			if (wPresets !is null)
				wPresets.m_visible = false;
			return;
		}

		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		bool isLockedIn = (Fountain::CurrentEffects.length() > 0);

		m_wListPresets.ClearChildren();

		for (uint i = 0; i < town.m_fountainPresets.length(); i++)
		{
			auto preset = town.m_fountainPresets[i];

			auto wNewItem = m_wTemplatePreset.Clone();
			wNewItem.SetID("");
			wNewItem.m_visible = true;

			auto wButtonLoad = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-load"));
			if (wButtonLoad !is null)
			{
				wButtonLoad.m_enabled = (!isLockedIn && Network::IsServer() && preset.effects.length() > 0);
				wButtonLoad.m_func = "load-preset " + i;

				string strName = Resources::GetString(".fountain.presets.name", { { "num", i + 1 } });
				wButtonLoad.SetText(strName);
				wButtonLoad.m_tooltipTitle = strName;

				string strTooltip;
				bool secondEffect = false;
				for (uint j = 0; j < preset.effects.length(); j++)
				{
					auto effect = Fountain::GetEffect(preset.effects[j]);
					if (effect is null)
						continue;

					if (secondEffect)
						strTooltip += "\\d, ";
					secondEffect = true;

					if (effect.m_favor > 0)
						strTooltip += "\\c00ff00";
					else if (effect.m_favor < 0)
						strTooltip += "\\cff0000";
					strTooltip += Resources::GetString(".fountain.effect." + effect.m_id + ".name");
				}
				wButtonLoad.m_tooltipText = strTooltip;
			}

			auto wButtonSave = cast<ScalableSpriteButtonWidget>(wNewItem.GetWidgetById("button-save"));
			if (wButtonSave !is null)
				wButtonSave.m_func = "save-preset " + i;

			auto wSeparator = wNewItem.GetWidgetById("separator");
			if (wSeparator !is null)
				wSeparator.m_visible = (i > 0);

			m_wListPresets.AddChild(wNewItem);
		}
	}

	string GetGuiFilename() override
	{
		return "gui/shop/fountain.gui";
	}

	int GetFavor()
	{
		auto effects = GetSelectedEffects();

		int favor = 0;
		for (uint i = 0; i < effects.length(); i++)
			favor += effects[i].m_favor;

		return favor;
	}

	int GetCost()
	{
		int favor = GetFavor();

		if (favor <= 0)
			return 0;
		else if (favor > 20)
			return 200000000; // 200m

		return int(150 * (pow(2, favor) - 1));
	}

	void Deposit(int amount)
	{
		auto gm = cast<Town>(g_gameMode);
		if (gm is null)
			return;

		if (!Currency::CanAfford(amount))
		{
			PrintError("Can't afford to deposit " + amount + " gold into fountain!");
			return;
		}

		Stats::Add("fountain-deposited", amount, GetLocalPlayerRecord());

		Currency::Spend(amount);
		gm.m_town.m_fountainGold += amount;

		if (Network::IsServer())
			gm.m_townLocal.m_fountainGold += amount;

		(Network::Message("DepositFountain") << amount).SendToAll();

		UpdateInterface();
	}

	void NetDeposit(int amount)
	{
		auto gm = cast<Town>(g_gameMode);
		if (gm is null)
			return;

		m_wDepositGold.SetText(formatThousands(gm.m_town.m_fountainGold));
	}

	bool CanAfford()
	{
%if HARDCORE
		return GetCost() == 0;
%else
		auto gm = cast<Town>(g_gameMode);
		if (gm is null)
			return false;

		return gm.m_town.m_fountainGold >= GetCost();
%endif
	}

	void Buy()
	{
		if (!Network::IsServer())
		{
			PrintError("Not server, can't buy effects");
			return;
		}

		if (!CanAfford())
		{
			PrintError("Can't afford effects");
			return;
		}

		if (Fountain::CurrentEffects.length() > 0)
		{
			PrintError("There already are affects active");
			return;
		}

		auto gm = cast<Town>(g_gameMode);
		if (gm is null)
			return;

		auto player = GetLocalPlayer();

		int favor = GetFavor();
		int cost = GetCost();

		PlaySound2D(m_sndLockIn);

		Stats::Add("fountain-used", 1, player.m_record);
		Stats::Add("fountain-paid", cost, player.m_record);

		if (favor > 0)
			Stats::Add("fountain-favor-good", favor, player.m_record);
		else if (favor < 0)
			Stats::Add("fountain-favor-bad", -favor, player.m_record);

%if HARDCORE
		if (favor > 0)
		{
			PrintError("Shouldn't be able to pay for positive favor!");
			return;
		}
%else
		gm.m_town.m_fountainGold -= cost;
		gm.m_townLocal.m_fountainGold -= cost;
%endif

		gm.m_town.m_savedFountainEffects.removeRange(0, gm.m_town.m_savedFountainEffects.length());
		gm.m_townLocal.m_savedFountainEffects.removeRange(0, gm.m_townLocal.m_savedFountainEffects.length());

		SValueBuilder builder;
		builder.PushArray();

		auto arrSelected = GetSelectedEffects();
		for (uint i = 0; i < arrSelected.length(); i++)
		{
			auto effect = arrSelected[i];

			Fountain::ApplyEffect(effect.m_idHash);
			gm.m_town.m_savedFountainEffects.insertLast(effect.m_idHash);
			gm.m_townLocal.m_savedFountainEffects.insertLast(effect.m_idHash);

			builder.PushInteger(effect.m_idHash);
		}

		builder.PopArray();
		(Network::Message("SetFountain") << builder.Build()).SendToAll();

		Fountain::RefreshModifiers(g_allModifiers);

		player.RefreshModifiers();

		ReloadList();
		ReloadPresets();

		UpdateInterface();
	}

	void NetBuy()
	{
		ReloadList();
		ReloadPresets();

		UpdateInterface();
	}

	array<Fountain::Effect@> GetSelectedEffects()
	{
		array<Fountain::Effect@> ret;

		if (Fountain::CurrentEffects.length() > 0)
		{
			for (uint i = 0; i < Fountain::CurrentEffects.length(); i++)
			{
				uint id = Fountain::CurrentEffects[i];
				auto effect = Fountain::GetEffect(id);
				if (effect is null)
				{
					PrintError("Couldn't find current effect with ID " + id);
					continue;
				}
				ret.insertLast(effect);
			}
			return ret;
		}

		for (uint i = 0; i < m_arrButtons.length(); i++)
		{
			auto button = m_arrButtons[i];
			if (button.IsChecked())
			{
				auto effect = Fountain::GetEffect(button.m_value);
				if (effect is null)
				{
					PrintError("Couldn't find selected effect with ID \"" + button.m_value + "\"");
					continue;
				}
				ret.insertLast(effect);
			}
		}

		return ret;
	}

	bool AnyEffectSelected()
	{
		for (uint i = 0; i < m_arrButtons.length(); i++)
		{
			if (m_arrButtons[i].IsChecked())
				return true;
		}
		return false;
	}

	void UpdateInterface()
	{
		auto gm = cast<Campaign>(g_gameMode);

		auto arrSelected = GetSelectedEffects();

		int favor = 0;
		for (uint i = 0; i < arrSelected.length(); i++)
			favor += arrSelected[i].m_favor;

		if (favor > 0)
		{
			m_wPoints.SetText(Resources::GetString(".fountain.favorcount", { { "favor", "+" + favor } }));
			m_wPoints.SetColor(vec4(0, 1, 0, 1));
			m_wScale.SetSprite("scale-left");
		}
		else if (favor < 0)
		{
			m_wPoints.SetText(Resources::GetString(".fountain.favorcount", { { "favor", "" + favor } }));
			m_wPoints.SetColor(vec4(1, 0, 0, 1));
			m_wScale.SetSprite("scale-right");
		}
		else if (favor == 0)
		{
			m_wPoints.SetText(Resources::GetString(".fountain.favorcount", { { "favor", "0" } }));
			m_wPoints.SetColor(vec4(1, 1, 1, 1));
			m_wScale.SetSprite("scale-balanced");
		}

		float goldGain = 0.0f;
		float expMul = 0.0f;

		if (favor < 0)
		{
			goldGain = 0.05f * -favor;
			expMul = 0.05f * -favor;
		}

		m_wGoldGain.SetText(round(goldGain * 100.0f) + "%");
		m_wExpMul.SetText(round(expMul * 100.0f) + "%");

%if HARDCORE
		m_wDepositGold.SetText("-");
%else
		m_wDepositGold.SetText(formatThousands(gm.m_town.m_fountainGold));
%endif

		for (uint i = 0; i < m_wDepositButtons.m_children.length(); i++)
		{
			auto wButton = cast<ScalableSpriteButtonWidget>(m_wDepositButtons.m_children[i]);
			if (wButton is null)
				continue;

			int buttonValue = parseInt(wButton.m_value);
%if HARDCORE
			wButton.m_enabled = false;
			wButton.m_tooltipText = Resources::GetString(".fountain.deposit.hardcore");
%else
			wButton.m_enabled = Currency::CanAfford(buttonValue);
%endif
		}

		if (Fountain::CurrentEffects.length() > 0)
		{
			m_wButton.SetText(Resources::GetString(".fountain.lockedin"));
			m_wButton.m_enabled = false;
			m_wButton.m_iconVisible = false;
		}
		else
		{
			m_wButton.SetText(formatThousands(GetCost()));
			m_wButton.m_enabled = (Network::IsServer() && CanAfford() && AnyEffectSelected());
			m_wButton.m_iconVisible = true;
		}

		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "close")
			m_shopMenu.Close();
		else if (parse[0] == "wishes-changed")
			UpdateInterface();
		else if (parse[0] == "buy")
			Buy();
%if !HARDCORE
		else if (parse[0] == "deposit")
		{
			auto wButton = cast<ScalableSpriteButtonWidget>(sender);
			int buttonValue = parseInt(wButton.m_value);
			Deposit(buttonValue);
		}
%endif
		else if (parse[0] == "save-preset")
		{
			uint index = parseUInt(parse[1]);

			auto newPreset = FountainPreset();

			for (uint i = 0; i < m_arrButtons.length(); i++)
			{
				auto button = m_arrButtons[i];
				if (button.IsChecked() || button.m_lockedIn)
				{
					uint idHash = button.m_effect.m_idHash;
					if (newPreset.effects.find(idHash) == -1)
						newPreset.effects.insertLast(idHash);
				}
			}

			auto gm = cast<Campaign>(g_gameMode);
			@gm.m_townLocal.m_fountainPresets[index] = newPreset;

			ReloadPresets();
		}
		else if (parse[0] == "load-preset")
		{
			uint index = parseUInt(parse[1]);

			auto gm = cast<Campaign>(g_gameMode);
			auto preset = gm.m_townLocal.m_fountainPresets[index];

			for (uint i = 0; i < m_arrButtons.length(); i++)
			{
				auto button = m_arrButtons[i];
				button.SetChecked(preset.effects.find(button.m_effect.m_idHash) != -1);
			}

			UpdateInterface();
		}
	}
}
