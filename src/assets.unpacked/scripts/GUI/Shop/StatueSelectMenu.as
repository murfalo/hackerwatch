class StatueSelectMenu : UserWindow
{
	StatuesShopMenuContent@ m_owner;

	CheckBoxGroupWidget@ m_wList;

	int m_slot;

	Sprite@ m_spriteOre;

	StatueSelectMenu(GUIBuilder@ b, StatuesShopMenuContent@ owner, int slot)
	{
		super(b, "gui/shop/statues_select.gui");

		@m_owner = owner;

		m_slot = slot;
	}

	GUIDef@ LoadWidget(GUIBuilder@ b, string filename) override
	{
		auto def = UserWindow::LoadWidget(b, filename);

		@m_spriteOre = def.GetSprite("icon-ore");

		return def;
	}

	bool BlocksLower() override
	{
		return true;
	}

	void Show() override
	{
		if (m_visible)
			return;

		auto gm = cast<Town>(g_gameMode);

		gm.m_userWindows.insertLast(this);

		@m_wList = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("list"));
		auto wTemplate = m_widget.GetWidgetById("template");

		for (uint i = 0; i < gm.m_townLocal.m_statues.length(); i++)
		{
			auto statue = gm.m_townLocal.m_statues[i];
			auto statueDef = statue.GetDef();
			int placement = gm.m_townLocal.GetStatuePlacement(statue.m_id);

			string name = Resources::GetString(statueDef.m_name);

			auto wNewStatue = wTemplate.Clone();
			wNewStatue.SetID("");
			wNewStatue.m_visible = true;

			auto wCheck = cast<CheckBoxWidget>(wNewStatue.GetWidgetById("check"));
			if (wCheck !is null)
			{
				wCheck.m_enabled = (placement == -1);
				wCheck.m_tooltipTitle = name;
				wCheck.m_tooltipText = Resources::GetString(statueDef.m_desc);
				wCheck.m_value = statue.m_id;

				if (statue.m_level == 0)
				{
					int cost = statueDef.GetUpgradeCost(statue.m_level + 1);
					if (!Currency::CanAfford(0, cost))
					{
						wCheck.AddTooltipSub(m_spriteOre, "\\cff0000" + formatThousands(cost));
						wCheck.m_enabled = false;
					}
					else
						wCheck.AddTooltipSub(m_spriteOre, formatThousands(cost));
				}
			}

			auto wPreview = cast<UnitWidget>(wNewStatue.GetWidgetById("preview"));
			if (wPreview !is null)
				wPreview.AddUnit(statueDef.m_sceneSmall);

			auto wLevel = cast<TextWidget>(wNewStatue.GetWidgetById("level"));
			if (wLevel !is null)
			{
				if (statue.m_level == 0)
					wLevel.m_visible = false;
				else
				{
					wLevel.SetText("" + statue.m_level);
					if (placement != -1)
						wLevel.SetColor(vec4(0.5, 0.5, 0.5, 1));
				}
			}

			auto wBlueprints = cast<TextWidget>(wNewStatue.GetWidgetById("blueprints"));
			if (wBlueprints !is null)
				wBlueprints.SetText("" + statue.m_blueprint);

			auto wName = cast<TextWidget>(wNewStatue.GetWidgetById("name"));
			if (wName !is null)
			{
				wName.SetText(name);
				if (placement != -1)
					wName.SetColor(vec4(0.5, 0.5, 0.5, 1));
			}

			m_wList.AddChild(wNewStatue);
		}

		UserWindow::Show();
	}

	void Close() override
	{
		if (!m_visible)
			return;

		auto gm = cast<Town>(g_gameMode);

		int index = gm.m_userWindows.findByRef(this);
		if (index != -1)
			gm.m_userWindows.removeAt(index);

		UserWindow::Close();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "set-statue")
		{
			auto checked = m_wList.GetChecked();
			if (checked is null)
			{
				Close();
				return;
			}

			string statueID = checked.GetValue();

			auto gm = cast<Town>(g_gameMode);
			auto townStatue = gm.m_townLocal.GetStatue(statueID);

			if (townStatue.m_level == 0)
			{
				auto statueDef = Statues::GetStatue(statueID);
				int cost = statueDef.GetUpgradeCost(1);

				g_gameMode.ShowDialog(
					"set-statue-confirm " + statueID,
					Resources::GetString(".shop.statues.firststatue", {
						{ "cost", formatThousands(cost) }
					}),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					this
				);
				return;
			}

			gm.m_townLocal.m_statuePlacements[m_slot] = statueID;

			PlaySound2D(Resources::GetSoundEvent("event:/ui/statue_build"));

			(Network::Message("TownStatueSet") << m_slot << statueID).SendToAll();

			gm.SetStatues();
			gm.RefreshTownModifiers();

			m_owner.RefreshList();

			Close();
		}
		else if (parse[0] == "set-statue-confirm" && parse.length() == 3 && parse[2] == "yes")
		{
			auto gm = cast<Town>(g_gameMode);

			auto townStatue = gm.m_townLocal.GetStatue(parse[1]);
			auto def = Statues::GetStatue(parse[1]);
			int cost = def.GetUpgradeCost(1);

			if (!Currency::CanAfford(0, cost))
			{
				PrintError("Not enough ore to buy first level statue of type \"" + def.m_id + "\"");
				return;
			}

			townStatue.m_level = 1;
			Currency::Spend(0, cost);

			gm.m_townLocal.m_statuePlacements[m_slot] = parse[1];

			Stats::Add("statue-upgrades-bought", 1, GetLocalPlayerRecord());

			if (def.m_achievement != "")
				Platform::Service.UnlockAchievement(def.m_achievement);

			PlaySound2D(Resources::GetSoundEvent("event:/ui/statue_build"));

			(Network::Message("TownStatueSet") << m_slot << parse[1]).SendToAll();

			gm.SetStatues();
			gm.RefreshTownModifiers();

			m_owner.RefreshList();

			Close();
		}
		else
			UserWindow::OnFunc(sender, name);
	}
}
