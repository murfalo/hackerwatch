class GravestoneInterface : UserWindow
{
	PlayerGravestoneBehavior@ m_gravestone;

	GravestoneInterface(GUIBuilder@ b)
	{
		super(b, "gui/town/gravestone.gui");
	}

	void Set(PlayerGravestoneBehavior@ gravestone)
	{
		@m_gravestone = gravestone;

		auto title = g_classTitles.m_titlesMercenary.GetTitle(m_gravestone.m_titleIndex);

		auto wName = cast<TextWidget>(m_widget.GetWidgetById("name"));
		if (wName !is null)
			wName.SetText(Resources::GetString(title.m_name) + " " + m_gravestone.m_charName);

		auto wPortrait = cast<PortraitWidget>(m_widget.GetWidgetById("portrait"));
		if (wPortrait !is null)
		{
			wPortrait.SetFrame(m_gravestone.m_charFrame);
			wPortrait.SetClass(m_gravestone.m_charClass);
			wPortrait.SetFace(m_gravestone.m_charFace);
			wPortrait.SetDyes(m_gravestone.m_charDyes);
			wPortrait.UpdatePortrait();
		}

		auto wReached = cast<TextWidget>(m_widget.GetWidgetById("reached"));
		if (wReached !is null && m_gravestone.m_diedDungeon !is null)
		{
			auto level = m_gravestone.m_diedDungeon.GetLevel(m_gravestone.m_diedLevel);
			if (level is null)
			{
				PrintError("Level with index " + m_gravestone.m_diedLevel + " doesn't exist in dungeon " + m_gravestone.m_diedDungeon.m_id + " - falling back to highest level");
				@level = m_gravestone.m_diedDungeon.GetLevel(m_gravestone.m_diedDungeon.m_levels.length() - 1);
			}

			string str = Resources::GetString(".town.mercenarygravestone.reached", {
				{ "area", UcFirst(utf8string(m_gravestone.m_diedDungeon.GetAreaName(level)), true).plain() },
				{ "act", UcFirst(utf8string(m_gravestone.m_diedDungeon.GetActName(level)), true).plain() },
				{ "floor", UcFirst(utf8string(m_gravestone.m_diedDungeon.GetFloorName(level)), true).plain() }
			});

			wReached.SetText(str);
		}

		auto wEarned = cast<TextWidget>(m_widget.GetWidgetById("earned"));
		if (wEarned !is null)
		{
			wEarned.SetText(Resources::GetString(".town.mercenarygravestone.earned", {
				{ "points", formatThousands(m_gravestone.m_charLegacyPoints) }
			}));
		}

		auto wStats = cast<TextWidget>(m_widget.GetWidgetById("stats"));
		if (wStats !is null)
		{
			string str = Resources::GetString(".town.mercenarygravestone.stats", {
				{ "time", m_gravestone.m_charLifetimeStats.GetStatString("time-played") },
				{ "level", m_gravestone.m_charLevel }
			});

			int numBossesKilled = 0;
			for (int i = 1; ; i++)
			{
				auto stat = m_gravestone.m_charLifetimeStats.GetStat("boss-" + i + "-killed");
				if (stat is null)
					break;

				numBossesKilled += stat.m_valueInt;
			}

			if (numBossesKilled == 0)
				str += " " + Resources::GetString(".town.mercenarygravestone.bosses.none");
			else if (numBossesKilled == 1)
				str += " " + Resources::GetString(".town.mercenarygravestone.bosses.singular");
			else
			{
				str += " " + Resources::GetString(".town.mercenarygravestone.bosses.plural", {
					{ "num", formatThousands(numBossesKilled) }
				});
			}

			wStats.SetText(str);
		}
	}
}
