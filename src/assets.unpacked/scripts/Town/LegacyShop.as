class LegacyShop : ScriptWidgetHost
{
	MenuTabSystem@ m_tabSystem;

	TextWidget@ m_wLegacyPoints;
	ScalableSpriteIconButtonWidget@ m_wButtonBuy;

	array<Materials::Dye@> m_selectedDyes;
	array<PlayerTrails::TrailDef@> m_selectedTrails;
	array<PlayerFrame@> m_selectedFrames;
	array<Pets::PetSkin@> m_selectedPetSkins;
	array<PlayerComboStyle@> m_selectedComboStyles;
	array<PlayerCorpseGravestone@> m_selectedGravestones;

	LegacyShop(SValue& params)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wLegacyPoints = cast<TextWidget>(m_widget.GetWidgetById("points"));
		@m_wButtonBuy = cast<ScalableSpriteIconButtonWidget>(m_widget.GetWidgetById("buy"));

		@m_tabSystem = MenuTabSystem(this);
		m_tabSystem.AddTab(LegacyShopDyesTab(this));
		m_tabSystem.AddTab(LegacyShopTrailsTab(this));
		m_tabSystem.AddTab(LegacyShopFramesTab(this));
		m_tabSystem.AddTab(LegacyShopPetSkinsTab(this));
		m_tabSystem.AddTab(LegacyShopCombosTab(this));
		m_tabSystem.AddTab(LegacyShopGravestonesTab(this));
		m_tabSystem.SetTab("dyes");

		UpdateInfo();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	int GetSelectedItemCount()
	{
		int ret = 0;
		ret += m_selectedDyes.length();
		ret += m_selectedTrails.length();
		ret += m_selectedFrames.length();
		ret += m_selectedPetSkins.length();
		ret += m_selectedComboStyles.length();
		ret += m_selectedGravestones.length();
		return ret;
	}

	int GetSelectedCost()
	{
		int ret = 0;

		for (uint i = 0; i < m_selectedDyes.length(); i++)
			ret += m_selectedDyes[i].m_legacyPoints;

		for (uint i = 0; i < m_selectedTrails.length(); i++)
			ret += m_selectedTrails[i].m_legacyPoints;

		for (uint i = 0; i < m_selectedFrames.length(); i++)
			ret += m_selectedFrames[i].m_legacyPoints;

		for (uint i = 0; i < m_selectedPetSkins.length(); i++)
			ret += m_selectedPetSkins[i].m_legacyPoints;

		for (uint i = 0; i < m_selectedComboStyles.length(); i++)
			ret += m_selectedComboStyles[i].m_legacyPoints;

		for (uint i = 0; i < m_selectedGravestones.length(); i++)
			ret += m_selectedGravestones[i].m_legacyPoints;

		return ret;
	}

	void UpdateInfo()
	{
		auto gm = cast<Campaign>(g_gameMode);

		m_wLegacyPoints.SetText(formatThousands(gm.m_townLocal.m_legacyPoints));

		int numItems = GetSelectedItemCount();
		int cost = GetSelectedCost();
		bool canAfford = (cost <= gm.m_townLocal.m_legacyPoints);

		m_wButtonBuy.SetText(formatThousands(cost));
		m_wButtonBuy.m_enabled = (numItems > 0 && canAfford);
	}

	void ReloadLists()
	{
		m_tabSystem.m_currentTab.OnShow();
		UpdateInfo();
	}

	void Update(int dt) override
	{
		m_tabSystem.Update(dt);

		ScriptWidgetHost::Update(dt);
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		ScriptWidgetHost::Draw(sb, idt);

		m_tabSystem.Draw(sb, idt);
	}

	void DoLayout() override
	{
		bool invalidated = m_invalidated;

		ScriptWidgetHost::DoLayout();

		if (invalidated)
			m_tabSystem.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Stop();
		else if (name == "buy")
		{
			int numItems = GetSelectedItemCount();
			if (numItems == 0)
			{
				PrintError("No items selected!");
				return;
			}

			auto gm = cast<Campaign>(g_gameMode);

			int cost = GetSelectedCost();
			if (cost > gm.m_townLocal.m_legacyPoints)
			{
				PrintError("Not enough legacy points!");
				return;
			}

			g_gameMode.ShowDialog(
				"buy",
				Resources::GetString(".town.legacyshop.buy.prompt", {
					{ "points", formatThousands(cost) }
				}),
				Resources::GetString(".menu.yes"),
				Resources::GetString(".menu.no"),
				this
			);
		}
		else if (name == "buy yes")
		{
			auto gm = cast<Campaign>(g_gameMode);

			int cost = GetSelectedCost();
			if (cost > gm.m_townLocal.m_legacyPoints)
			{
				PrintError("Not enough legacy points!");
				return;
			}

			gm.m_townLocal.m_legacyPoints -= cost;

			for (uint i = 0; i < m_selectedDyes.length(); i++)
				gm.m_townLocal.m_dyes.insertLast(m_selectedDyes[i]);
			m_selectedDyes.removeRange(0, m_selectedDyes.length());

			for (uint i = 0; i < m_selectedTrails.length(); i++)
				gm.m_townLocal.m_trails.insertLast(m_selectedTrails[i]);
			m_selectedTrails.removeRange(0, m_selectedTrails.length());

			for (uint i = 0; i < m_selectedFrames.length(); i++)
				gm.m_townLocal.m_frames.insertLast(m_selectedFrames[i]);
			m_selectedFrames.removeRange(0, m_selectedFrames.length());

			for (uint i = 0; i < m_selectedPetSkins.length(); i++)
				gm.m_townLocal.m_petSkins.insertLast(m_selectedPetSkins[i].m_idHash);
			m_selectedPetSkins.removeRange(0, m_selectedPetSkins.length());

			for (uint i = 0; i < m_selectedComboStyles.length(); i++)
				gm.m_townLocal.m_comboStyles.insertLast(m_selectedComboStyles[i].m_idHash);
			m_selectedComboStyles.removeRange(0, m_selectedComboStyles.length());

			for (uint i = 0; i < m_selectedGravestones.length(); i++)
				gm.m_townLocal.m_gravestones.insertLast(m_selectedGravestones[i].m_idHash);
			m_selectedGravestones.removeRange(0, m_selectedGravestones.length());

			PlaySound2D(Resources::GetSoundEvent("event:/ui/buy_gold"));
			Platform::Service.UnlockAchievement("legacy_shop");

			ReloadLists();
		}
		else if (!m_tabSystem.OnFunc(sender, name))
			ScriptWidgetHost::OnFunc(sender, name);
	}

	void Stop() override
	{
		m_tabSystem.Close();

		ScriptWidgetHost::Stop();
	}
}
