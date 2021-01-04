class HUD : IWidgetHoster
{
	GUIDef@ m_guiDef;

	WorldScript::AnnounceText@ m_currAnnounce;

	WaypointMarkersWidget@ m_waypoints;

	SpeechBubbleManager@ m_speechBubbles;

	UsableIcon m_currentUseIcon;
	Sprite@ m_useIcon;
	Sprite@ m_useIconCross;
	Sprite@ m_useIconKey;
	Sprite@ m_useIconShop;
	Sprite@ m_useIconSpeech;
	Sprite@ m_useIconExit;
	Sprite@ m_useIconQuestion;
	Sprite@ m_useIconRevive;

	Widget@ m_wTopbar;
	Widget@ m_wHealthGui;
	Widget@ m_wSkillGui;
	Widget@ m_wBossBars;

	uint m_tutorialData;
	TextWidget@ m_wTutorial;
	TextWidget@ m_wDeadMessage;
	TextWidget@ m_wDeadMessage2;

	int m_barStatsTimeC;

	SpriteBarWidget@ m_wBarHealth;
	TextWidget@ m_wHealth; //TODO: Move this into SpriteBarWidget

	SpriteBarWidget@ m_wBarMana;
	TextWidget@ m_wMana; //TODO: Move this into SpriteBarWidget

	TextWidget@ m_wCombo;
	SpriteBarWidget@ m_wBarCombo;
	SpriteBarWidget@ m_wBarComboTimer;
	SpriteBarWidget@ m_wBarExperience;

	TextWidget@ m_wCurrencyGold;
	SpriteWidget@ m_wCurrencyGoldIcon;

	TextWidget@ m_wCurrencyOre;
	SpriteWidget@ m_wCurrencyOreIcon;

	Widget@ m_wTownValuesContainer;
	TextWidget@ m_wCurrencySkillPoints;

	SpriteWidget@ m_wCurrencyLegacyPointsIcon;
	TextWidget@ m_wCurrencyLegacyPoints;
	TextWidget@ m_wCurrencyPrestige;

	RectWidget@ m_wKeyTemplate;
	Widget@ m_wKeyList;

	SpriteWidget@ m_wPotion;
	DotbarWidget@ m_wPotionBar;

	array<SkillWidget@> m_arrSkillWidgets;

	PlayerRecord@ m_lastRecord;

	Tooltip@ m_tooltipItems;

	TextWidget@ m_wDebugHandicap;

	Widget@ m_wBuffList;
	Widget@ m_wBuffTemplate;

	array<TopNumberIconWidget@> m_topNumberIcons;
	Widget@ m_wTopNumberTemplate;
	Widget@ m_wTopNumberList;

%if HARDCORE
	TextWidget@ m_wMercenary;
%endif

	HUD(GUIBuilder@ b)
	{
		@m_speechBubbles = SpeechBubbleManager();

		GUIDef@ def = LoadWidget(b, "gui/hud.gui");
		@m_guiDef = def;

		@m_useIcon = def.GetSprite("use-icon");
		@m_useIconCross = def.GetSprite("use-icon-cross");
		@m_useIconKey = def.GetSprite("use-icon-key");
		@m_useIconShop = def.GetSprite("use-icon-shop");
		@m_useIconSpeech = def.GetSprite("use-icon-speech");
		@m_useIconExit = def.GetSprite("use-icon-exit");
		@m_useIconQuestion = def.GetSprite("use-icon-question");
		@m_useIconRevive = def.GetSprite("use-icon-revive");

		@m_wTopbar = m_widget.GetWidgetById("topbar");
		@m_wHealthGui = m_widget.GetWidgetById("health-gui");
		@m_wSkillGui = m_widget.GetWidgetById("skill-gui");
		@m_wBossBars = m_widget.GetWidgetById("boss-bars");

		@m_waypoints = cast<WaypointMarkersWidget>(m_widget.GetWidgetById("waypoints"));

		Tutorial::AssignHUD(cast<TextWidget>(m_widget.GetWidgetById("tutorial")));
		
		@m_wDeadMessage = cast<TextWidget>(m_widget.GetWidgetById("deadmessage"));
		@m_wDeadMessage2 = cast<TextWidget>(m_widget.GetWidgetById("deadmessage2"));

		@m_wBarHealth = cast<SpriteBarWidget>(m_widget.GetWidgetById("health-bar"));
		@m_wHealth = cast<TextWidget>(m_widget.GetWidgetById("health"));

		@m_wBarMana = cast<SpriteBarWidget>(m_widget.GetWidgetById("mana-bar"));
		@m_wMana = cast<TextWidget>(m_widget.GetWidgetById("mana"));

		@m_wCombo = cast<TextWidget>(m_widget.GetWidgetById("combo"));
		@m_wBarCombo = cast<SpriteBarWidget>(m_widget.GetWidgetById("combo-bar"));
		@m_wBarComboTimer = cast<SpriteBarWidget>(m_widget.GetWidgetById("combo-bar-timer"));
		@m_wBarExperience = cast<SpriteBarWidget>(m_widget.GetWidgetById("exp-bar"));

		@m_wCurrencyGold = cast<TextWidget>(m_widget.GetWidgetById("gold"));
		@m_wCurrencyGoldIcon = cast<SpriteWidget>(m_widget.GetWidgetById("gold-icon"));

		@m_wCurrencyOre = cast<TextWidget>(m_widget.GetWidgetById("ore"));
		@m_wCurrencyOreIcon = cast<SpriteWidget>(m_widget.GetWidgetById("ore-icon"));

		@m_wTownValuesContainer = m_widget.GetWidgetById("town-values-container");
		@m_wCurrencySkillPoints = cast<TextWidget>(m_widget.GetWidgetById("skill-points"));

		@m_wCurrencyLegacyPointsIcon = cast<SpriteWidget>(m_widget.GetWidgetById("legacy-points-icon"));
		@m_wCurrencyLegacyPoints = cast<TextWidget>(m_widget.GetWidgetById("legacy-points"));
		@m_wCurrencyPrestige = cast<TextWidget>(m_widget.GetWidgetById("prestige"));

		@m_wKeyTemplate = cast<RectWidget>(m_widget.GetWidgetById("topbar-key-template"));
		@m_wKeyList = m_widget.GetWidgetById("topbar-key-list");

		@m_wPotion = cast<SpriteWidget>(m_widget.GetWidgetById("potion"));
		@m_wPotionBar = cast<DotbarWidget>(m_widget.GetWidgetById("potion-bar"));

		for (uint i = 0; ; i++)
		{
			auto wSkill = cast<SkillWidget>(m_widget.GetWidgetById("skill-" + (i + 1)));
			if (wSkill is null)
				break;
			m_arrSkillWidgets.insertLast(wSkill);
		}

		@m_tooltipItems = Tooltip(Resources::GetSValue("gui/tooltip.sval"));

		@m_wDebugHandicap = cast<TextWidget>(m_widget.GetWidgetById("debug-handicap"));

		@m_wBuffList = m_widget.GetWidgetById("buff-list");
		@m_wBuffTemplate = m_widget.GetWidgetById("buff-template");

		@m_wTopNumberTemplate = m_widget.GetWidgetById("topnumber-template");
		@m_wTopNumberList = m_widget.GetWidgetById("topnumber-list");

%if HARDCORE
		@m_wMercenary = cast<TextWidget>(m_widget.GetWidgetById("mercenary"));
%endif
	}

	void Start()
	{
		if (g_isTown)
		{
%if HARDCORE
			//TODO: Different icons
			m_wCurrencyGoldIcon.SetSprite("topbar-icon-gold-town");
			m_wCurrencyOreIcon.SetSprite("topbar-icon-ore-town");
%else
			m_wCurrencyGoldIcon.SetSprite("topbar-icon-gold-town");
			m_wCurrencyOreIcon.SetSprite("topbar-icon-ore-town");
%endif
		}

		m_wDebugHandicap.m_visible = GetVarBool("ui_debug_handicap");
	}

	void OnDeath()
	{
		// ?
	}

	void InitializeKeys(PlayerRecord@ record)
	{
		m_wKeyList.ClearChildren();

		for (uint i = 0; i < record.keys.length(); i++)
		{
			int num = record.keys[i];

			auto wNewKey = cast<RectWidget>(m_wKeyTemplate.Clone());
			wNewKey.m_visible = true;
			wNewKey.SetID("");
			wNewKey.m_visible = (num > 0);

			auto wSprite = cast<SpriteWidget>(wNewKey.GetWidgetById("icon"));
			wSprite.SetSprite("topbar-icon-key-" + i);

			auto wText = cast<TextWidget>(wNewKey.GetWidgetById("value"));
			wText.m_visible = GetVarBool("ui_key_count");
			wText.SetText("" + num);

			m_wKeyList.AddChild(wNewKey);
		}
	}

	void Update(int dt) override
	{
		BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
		if (gm is null)
			return;

		PlayerRecord@ record = null;
		if (gm.m_spectating)
			@record = g_players[gm.m_spectatingPlayer];
		else
			@record = GetLocalPlayerRecord();

		Update(dt, record);
	}

	void Update(int dt, PlayerRecord@ record)
	{
		if (record is null)
			return;

		auto gm = cast<Campaign>(g_gameMode);

%if HARDCORE
		m_wMercenary.m_visible = GetVarBool("ui_hud_mercenary");
%endif

		m_speechBubbles.Update(dt);

		m_wHealthGui.m_visible = GetVarBool("ui_hud_stats");
		m_wSkillGui.m_visible = GetVarBool("ui_hud_skills");
		m_wBuffList.m_visible = m_wSkillGui.m_visible;
		m_wBossBars.m_visible = (m_wBossBars.m_children.length() > 2 && GetVarBool("ui_hud_bossbar"));
		if (cast<Survival>(g_gameMode) !is null)
			m_wTopbar.m_visible = false;
		else
			m_wTopbar.m_visible = GetVarBool("ui_hud_topbar");
		m_wTopNumberList.m_visible = m_wTopbar.m_visible;

		int newBossbarWidth = g_gameMode.m_wndWidth;
		m_wBossBars.m_offset.x = 15;
		if (m_wHealthGui.m_visible)
		{
			int statsWidth = m_wHealthGui.m_width - 7;
			m_wBossBars.m_offset.x = statsWidth;
			newBossbarWidth -= statsWidth;
		}
		else
			newBossbarWidth -= 15;
		if (m_wSkillGui.m_visible)
			newBossbarWidth -= m_wSkillGui.m_width - 7;
		else
			newBossbarWidth -= 15;

		m_wBossBars.m_width = newBossbarWidth;
		
		Tutorial::Update(dt);
		
		if (m_lastRecord !is record)
		{
			if (m_lastRecord is null)
				InitializeKeys(record);

			@m_lastRecord = record;
		}

		if (record.hp < 1.0f || record.mana < 1.0f)
			m_barStatsTimeC = 1500;
		else if (m_barStatsTimeC > 0)
			m_barStatsTimeC -= dt;

		auto player = cast<PlayerBase>(record.actor);
		if (player !is null)
		{
			for (int i = 0; i < min(m_arrSkillWidgets.length(), player.m_skills.length()); i++)
				m_arrSkillWidgets[i].SetSkill(player.m_skills[i]);

			auto localPlayer = cast<Player>(player);
			if (localPlayer !is null)
			{
				vec2 comboBars = localPlayer.GetComboBars();
				comboBars.x = clamp(comboBars.x, 0.0f, 1.0f);
				m_wBarCombo.SetValue(comboBars.x);
				m_wBarComboTimer.SetValue(comboBars.x * comboBars.y);
				m_wCombo.m_visible = comboBars.x >= 1.0f;
				m_wCombo.SetText("" + localPlayer.m_comboCount);
			}
			else
			{
				m_wBarCombo.SetValue(0);
				m_wBarComboTimer.SetValue(0);
				m_wCombo.m_visible = false;
			}

			int charges = 1 + g_allModifiers.PotionCharges();

			float potionSpriteStep = (4.0f / float(charges));
			int potionSprite = (4 - int(round(potionSpriteStep * record.potionChargesUsed)));

			if (potionSprite < 0 || record.potionChargesUsed == charges) potionSprite = 0;
			else if (potionSprite > 4) potionSprite = 4;

			//NOTE: This has to be in Update() since this unlocks when you find a well in dungeon
			m_wPotion.m_visible = g_flags.IsSet("unlock_apothecary");
			if (m_wPotion.m_visible)
			{
				//NOTE: This also has to be in Update() due to spectating other players
				if (record.ngps["pop"] > 0)
					m_wPotion.SetSprite("djinn-potion-" + potionSprite);
				else
					m_wPotion.SetSprite("potion-" + potionSprite);

				m_wPotionBar.m_value = (charges - record.potionChargesUsed);
				m_wPotionBar.m_max = charges;
			}

			//TODO: use Player instead of localPlayer so we can spectate player's proper stats
			ivec2 extraStats;
			ivec2 extraStatsFromItems;
			float healthMul = 1.0f;
			if (localPlayer !is null)
			{
				extraStats = g_allModifiers.StatsAdd(localPlayer);
				healthMul = g_allModifiers.MaxHealthMul(localPlayer);
				extraStatsFromItems = localPlayer.m_record.modifiersItems.StatsAdd(localPlayer);
			}

			float maxHealth = (record.MaxHealth() + extraStats.x) * healthMul;
			float maxMana = record.MaxMana() + extraStats.y;

			m_wBarHealth.SetValue(record.hp);
			m_wBarHealth.m_valueExtra = 1.0f - (extraStatsFromItems.x / maxHealth);
			m_wHealth.SetText("" + int(ceil(record.hp * maxHealth)));

			m_wBarMana.SetValue(record.mana);
			m_wBarMana.m_valueExtra = 1.0f - (extraStatsFromItems.y / maxMana);
			m_wMana.SetText("" + int(floor(record.mana * maxMana)));
		}
		else
		{
			for (uint i = 0; i < m_arrSkillWidgets.length(); i++)
				m_arrSkillWidgets[i].SetSkill(null);

			m_wBarHealth.SetValue(0);
			m_wHealth.SetText("0");

			m_wBarMana.SetValue(0);
			m_wMana.SetText("0");

			m_wBarCombo.SetValue(0);
			m_wBarComboTimer.SetValue(0);

			if (record.ngps["pop"] > 0)
				m_wPotion.SetSprite("djinn-potion-0");
			else
				m_wPotion.SetSprite("potion-0");
		}

		int64 xpStart = record.LevelExperience(record.level - 1);
		int64 xpEnd = record.LevelExperience(record.level) - xpStart;
		int64 xpNow = record.experience - xpStart;

		m_wBarExperience.SetValue(float(xpNow / double(xpEnd)));

		if (gm !is null && gm.m_townLocal !is null)
		{
			int currGold = Currency::GetGold(record);
			int currOre = Currency::GetOre(record);

			int currLegacy = gm.m_townLocal.m_legacyPoints;
			int currPrestige = record.GetPrestige();

			if (g_isTown)
			{
				m_wTownValuesContainer.m_visible = GetVarBool("ui_hud_topbar");

				m_wCurrencySkillPoints.SetText(formatThousands(record.GetAvailableSkillpoints()));

				m_wCurrencyLegacyPoints.m_parent.m_visible = (Platform::HasDLC("mt") && currLegacy > 0);
				m_wCurrencyLegacyPoints.SetText(formatThousands(currLegacy));
			}
			else if (record.mercenary)
			{
				// Hack: Legacy points now becomes prestige!
				m_wCurrencyLegacyPointsIcon.SetSprite("topbar-icon-prestige");
				m_wCurrencyLegacyPoints.m_parent.m_visible = (Platform::HasDLC("mt") && currPrestige > 0);
				m_wCurrencyLegacyPoints.SetText(formatThousands(currPrestige));
			}

			m_wCurrencyGold.SetText(formatThousands(currGold));
			m_wCurrencyOre.SetText(formatThousands(currOre));

			if (record.mercenary)
			{
				m_wCurrencyPrestige.m_parent.m_visible = (Platform::HasDLC("mt") && currPrestige > 0);
				m_wCurrencyPrestige.SetText(formatThousands(currPrestige));
			}
		}

		bool showKeyCount = GetVarBool("ui_key_count");
		for (uint i = 0; i < record.keys.length(); i++)
		{
			int num = record.keys[i];
			m_wKeyList.m_children[i].m_visible = (num > 0);

			auto wTextValue = cast<TextWidget>(m_wKeyList.m_children[i].GetWidgetById("value"));
			wTextValue.m_visible = showKeyCount;
			if (wTextValue.m_visible)
				wTextValue.SetText("" + num);
		}

		if (m_wDebugHandicap.m_visible)
			m_wDebugHandicap.SetText("Handicap: " + record.handicap);

%PROFILE_START HUD UpdateWidgets
		IWidgetHoster::Update(dt);
%PROFILE_STOP
	}

	void Draw(SpriteBatch& sb, int idt) override
	{
		bool drawnPlayerBars = DrawPlayerBars(sb);
		DrawUseIcon(sb, drawnPlayerBars ? 22 : 14);

		m_speechBubbles.Draw(sb, idt);

		IWidgetHoster::Draw(sb, idt);

		DrawHoverItem(sb);
	}

	bool DrawPlayerBars(SpriteBatch& sb)
	{
		if (cast<Town>(g_gameMode) !is null)
			return false;

		auto plr = GetLocalPlayerRecord();

		auto localPlayer = cast<Player>(plr.actor);
		if (localPlayer is null)
			return false;
		
		int yPos = g_gameMode.m_wndHeight / 2 - 10 - 10 - 1;
		int width = 16;

		vec2 comboBars = localPlayer.GetComboBars();
		comboBars.x = clamp(comboBars.x, 0.0f, 1.0f);

		int barsVisibility = GetVarInt("ui_bars_visibility");
		if (barsVisibility == -1)
			return false;

		bool alwaysShowBars = (barsVisibility == 1);
		bool showBarStats = (alwaysShowBars || m_barStatsTimeC > 0);
		bool showBarCombo = (alwaysShowBars || comboBars.x > 0.0f);

		int height = 1;
		if (showBarStats) height += 4;
		if (showBarCombo) height += 2;

		if (height == 1)
			return false;

		vec4 p = vec4((g_gameMode.m_wndWidth - width) / 2, yPos, width, height);
		sb.DrawSprite(null, p, p, vec4(0, 0, 0, 1));

		yPos--;

		if (showBarStats)
		{
			DrawPlayerBar(sb, width -2, yPos += 2, plr.hp, vec4(1,0,0,1), vec4(0.16,0.06,0.06,1));
			DrawPlayerBar(sb, width -2, yPos += 2, plr.mana, vec4(0,0.71,1,1), vec4(0.06,0.08,0.12,1));
		}

		if (showBarCombo)
		{
			yPos += 2;
		
			DrawPlayerBar(sb, width -2, yPos, comboBars.x, vec4(.3,0,.3,1), vec4(0.03,0,0.03,1));
			DrawPlayerBar(sb, width -2, yPos, comboBars.x * comboBars.y, vec4(1,0,1,1), vec4(0,0,0,0));
		}

		return true;
	}

	void DrawPlayerBar(SpriteBatch& sb, int width, int ypos, float fill, vec4 colorFilled, vec4 colorEmpty)
	{
		int w = int(width * clamp(fill, 0.0, 1.0));

		vec4 p = vec4((g_gameMode.m_wndWidth - width) / 2, ypos, w, 1);
		sb.DrawSprite(null, p, p, colorFilled);

		p.x += w;
		p.z = width - w;
		sb.DrawSprite(null, p, p, colorEmpty);
	}

	void DrawHoverItem(SpriteBatch& sb)
	{
		auto localPlayer = GetLocalPlayer();
		if (localPlayer is null)
			return;

		auto usable = localPlayer.GetTopUsable();
		if (usable is null || !usable.CanUse(localPlayer))
			return;

		auto gm = cast<BaseGameMode>(g_gameMode);
		if (gm is null)
			return;

		bool hasTooltip = false;

		auto hoverItem = cast<Item>(usable);
		if (hoverItem !is null && hoverItem.m_initialized)
		{
			m_tooltipItems.SetTitle("\\c" + GetItemQualityColorString(hoverItem.m_item.quality) + utf8string(Resources::GetString(hoverItem.m_item.name)).toUpper().plain());
			m_tooltipItems.SetText(Resources::GetString(hoverItem.m_item.desc) + (hoverItem.m_item.set !is null ? ("\n\\c" + SetItemColorString + Resources::GetString(hoverItem.m_item.set.name) + "\\d") : ""));
			hasTooltip = true;
		}

		auto hoverDrink = cast<ConsumableDrink>(usable);
		if (hoverDrink !is null)
		{
			m_tooltipItems.SetTitle("\\c" + GetItemQualityColorString(hoverDrink.m_drink.quality) + utf8string(Resources::GetString(hoverDrink.m_drink.name)).toUpper().plain());
			m_tooltipItems.SetText(Resources::GetString(hoverDrink.m_drink.desc));
			hasTooltip = true;
		}

		auto hoverBarrel = cast<TavernBarrel>(usable);
		if (hoverBarrel !is null)
		{
			m_tooltipItems.SetTitle("\\c" + GetItemQualityColorString(hoverBarrel.m_drink.quality) + utf8string(Resources::GetString(hoverBarrel.m_drink.name)).toUpper().plain());
			m_tooltipItems.SetText(Resources::GetString(hoverBarrel.m_drink.desc));
			hasTooltip = true;
		}

		auto hoverBlueprint = cast<ForgeBlueprint>(usable);
		if (hoverBlueprint !is null)
		{
			m_tooltipItems.SetTitle("\\c" + GetItemQualityColorString(hoverBlueprint.m_item.quality) + utf8string(Resources::GetString(hoverBlueprint.m_item.name)).toUpper().plain());
			m_tooltipItems.SetText(Resources::GetString(hoverBlueprint.m_item.desc) + (hoverBlueprint.m_item.set !is null ? ("\n\\c" + SetItemColorString + Resources::GetString(hoverBlueprint.m_item.set.name) + "\\d") : ""));
			hasTooltip = true;
		}

		auto hoverDyeBucket = cast<DyeBucket>(usable);
		if (hoverDyeBucket !is null)
		{
			m_tooltipItems.SetTitle(Materials::GetCategoryName(hoverDyeBucket.m_dye.m_category) + ": " + Resources::GetString(hoverDyeBucket.m_dye.m_name));
			m_tooltipItems.SetText("\\c" + GetItemQualityColorString(hoverDyeBucket.m_dye.m_quality) + GetItemQualityNameFull(hoverDyeBucket.m_dye.m_quality));
			hasTooltip = true;
		}

		auto hoverStatueBlueprint = cast<StatueBlueprint>(usable);
		if (hoverStatueBlueprint !is null)
		{
			auto statue = cast<Campaign>(g_gameMode).m_townLocal.GetStatue(hoverStatueBlueprint.m_statueDef.m_id);
			
			int bp = 0;
			if (statue !is null)
				bp = statue.m_blueprint;

			m_tooltipItems.SetTitle(Resources::GetString(".statues.blueprint.title"));
			m_tooltipItems.SetText(Resources::GetString(".statues.blueprint.level", 
				{ { "statue", Resources::GetString(hoverStatueBlueprint.m_statueDef.m_name) }, { "level", (bp + 1) } }
			));
			hasTooltip = true;
		}

		if (hasTooltip)
		{
			vec2 tooltipSize = m_tooltipItems.GetSize();
			m_tooltipItems.Draw(sb, vec2(
				gm.m_wndWidth / 2 - tooltipSize.x / 2,
				gm.m_wndHeight / 2 - tooltipSize.y - 30
			));
		}
	}

	void DrawUseIcon(SpriteBatch& sb, int y)
	{
		auto localPlayer = GetLocalPlayer();
		if (localPlayer is null)
			return;

		IUsable@ usable = localPlayer.GetTopUsable();
		if (usable is null)
			return;

		vec2 pos = vec2(g_gameMode.m_wndWidth / 2, g_gameMode.m_wndHeight / 2);

		auto icon = usable.GetIcon(localPlayer);
		if (icon == UsableIcon::None)
			return;

		if (icon == UsableIcon::Cross)
			sb.DrawSprite(pos - vec2(m_useIconCross.GetWidth() / 2, y + m_useIconCross.GetHeight()), m_useIconCross, g_menuTime);
		else if (icon == UsableIcon::Shop)
			sb.DrawSprite(pos - vec2(m_useIconShop.GetWidth() / 2, y + m_useIconShop.GetHeight()), m_useIconShop, g_menuTime);
		else if (icon == UsableIcon::Speech)
			sb.DrawSprite(pos - vec2(m_useIconSpeech.GetWidth() / 2, y + m_useIconSpeech.GetHeight()), m_useIconSpeech, g_menuTime);
		else if (icon == UsableIcon::Exit)
			sb.DrawSprite(pos - vec2(m_useIconExit.GetWidth() / 2, y + m_useIconExit.GetHeight()), m_useIconExit, g_menuTime);
		else if (icon == UsableIcon::Question)
			sb.DrawSprite(pos - vec2(m_useIconQuestion.GetWidth() / 2, y + m_useIconQuestion.GetHeight()), m_useIconQuestion, g_menuTime);
		else if (icon == UsableIcon::Revive)
			sb.DrawSprite(pos - vec2(m_useIconRevive.GetWidth() / 2, y + m_useIconRevive.GetHeight()), m_useIconRevive, g_menuTime);
		else
		{
			sb.DrawSprite(pos - vec2(m_useIcon.GetWidth() / 2, y + m_useIcon.GetHeight()), m_useIcon, g_menuTime);

			if (icon == UsableIcon::Key)
				sb.DrawSprite(pos - vec2(m_useIconKey.GetWidth() / 2, y + m_useIcon.GetHeight() + 2 + m_useIconKey.GetHeight()), m_useIconKey, g_menuTime);
		}
	}

	bool Announce(const AnnounceParams &in params)
	{
		auto w = cast<TextWidget>(m_widget.GetWidgetById("announce"));
		if (w is null)
		{
			PrintError("TextWidget \"announce\" not found!");
			return false;
		}

		if (w.m_visible && !params.m_override)
			return false;

		if (params.m_align == -1) w.m_alignment = TextAlignment::Left;
		else if (params.m_align == 0) w.m_alignment = TextAlignment::Center;
		else if (params.m_align == 1) w.m_alignment = TextAlignment::Right;

		w.SetFont(params.m_font);
		w.SetText(params.m_text);
		w.m_anchor = params.m_anchor;
		w.m_visible = true;

		auto col = tocolor(params.m_color);
		auto colTransparent = vec4(col.r, col.g, col.b, 0);

		w.CancelAnimations();
		w.Animate(WidgetVec4Animation("color", colTransparent, col, params.m_fadeTime));
		if (params.m_time != -1)
		{
			w.Animate(WidgetVec4Animation("color", col, colTransparent, params.m_fadeTime, params.m_fadeTime + params.m_time));
			w.Animate(WidgetBoolAnimation("visible", false, params.m_fadeTime + params.m_time + params.m_fadeTime));
		}

		return true;
	}

	TextWidget@ GetCountDown()
	{
		return cast<TextWidget>(m_widget.GetWidgetById("countdown"));
	}

	void SetExtraLife()
	{
		// ?
	}

	TopNumberIconWidget@ GetTopNumberIcon(string id)
	{
		for (uint i = 0; i < m_topNumberIcons.length(); i++)
		{
			auto wIcon = m_topNumberIcons[i];
			if (wIcon.m_topID == id)
				return wIcon;
		}
		return null;
	}

	TopNumberIconWidget@ SetTopNumberIcon(string id, int number = -1)
	{
		auto wIcon = GetTopNumberIcon(id);
		if (wIcon is null)
		{
			@wIcon = cast<TopNumberIconWidget>(m_wTopNumberTemplate.Clone());
			wIcon.m_visible = true;
			wIcon.SetID("");
			wIcon.m_topID = id;
			wIcon.SetSprite("topnumber-" + id);
			m_wTopNumberList.AddChild(wIcon);
			m_topNumberIcons.insertLast(wIcon);
		}
		wIcon.SetNumber(number);
		return wIcon;
	}

	void HideTopNumberIcon(string id)
	{
		for (uint i = 0; i < m_topNumberIcons.length(); i++)
		{
			auto wIcon = m_topNumberIcons[i];
			if (wIcon.m_topID != id)
				continue;

			wIcon.RemoveFromParent();
			m_topNumberIcons.removeAt(i);
		}
	}

	void ClearTopNumberIcons()
	{
		m_wTopNumberList.ClearChildren();
		m_topNumberIcons.removeRange(0, m_topNumberIcons.length());
	}

	BossBarWidget@ AddBossBar(Actor@ actor)
	{
		auto wTemplate = m_widget.GetWidgetById("boss-template");
		if (wTemplate is null)
			return null;

		if (m_wBossBars is null)
			return null;

		auto wBossBar = cast<BossBarWidget>(wTemplate.Clone());
		wBossBar.m_visible = true;
		wBossBar.SetID("");
		@wBossBar.m_actor = actor;
		m_wBossBars.AddChild(wBossBar);

		for (uint i = 0; i < m_wBossBars.m_children.length(); i++)
		{
			auto wBar = cast<BossBarWidget>(m_wBossBars.m_children[i]);
			if (wBar is null)
				continue;
			wBar.UpdateAppearance();
		}

		return wBossBar;
	}

	BossBarWidget@ GetBossBar(Actor@ actor)
	{
		if (m_wBossBars is null)
			return null;

		for (uint i = 0; i < m_wBossBars.m_children.length(); i++)
		{
			BossBarWidget@ bar = cast<BossBarWidget>(m_wBossBars.m_children[i]);
			if (bar is null)
				continue;

			if (bar.m_actor is actor)
				return bar;
		}

		return null;
	}

	void PlayPickup()
	{
		// ?
	}

	Widget@ ShowBuffIcon(PlayerBase@ player, IBuffWidgetInfo@ buff)
	{
		if (player is null)
			return null;

		auto gm = cast<Campaign>(g_gameMode);
		if (gm is null)
			return null;

		if (gm.m_spectating)
		{
			if (player.m_record !is g_players[gm.m_spectatingPlayer])
				return null;
		}
		else if (!player.m_record.local)
			return null;

		if (buff.GetBuffIcon() is null)
			return null;

		BuffWidget@ wExisting = null;
		for (uint i = 0; i < m_wBuffList.m_children.length(); i++)
		{
			auto wBuff = cast<BuffWidget>(m_wBuffList.m_children[i]);
			if (wBuff.m_buff is buff)
			{
				@wExisting = wBuff;
				break;
			}
		}

		if (wExisting !is null)
			return wExisting;

		auto wNewBuff = cast<BuffWidget>(m_wBuffTemplate.Clone());
		wNewBuff.SetID("");
		wNewBuff.m_visible = true;
		@wNewBuff.m_buff = buff;
		m_wBuffList.AddChild(wNewBuff);

		return wNewBuff;
	}
}
