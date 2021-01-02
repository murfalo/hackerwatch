namespace WorldScript
{
	[WorldScript color="#A9A9A9" icon="system/icons.png;256;352;32;32"]
	class ShowSpeechBubble
	{
		SpeechBubble@ m_current;
		int m_timeC;

		[Editable default="gui/speechbubbles/white.sval"]
		string Style;

		[Editable]
		string Title;

		[Editable]
		string Text;

		[Editable default=-2]
		int Time;

		[Editable]
		UnitFeed Objects;

		[Editable]
		UnitFeed ForPlayer;

		[Editable default=true]
		bool HideOthers;

		[Editable]
		int HeightOffset;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			UnitPtr unit = ForPlayer.FetchFirst();
			if (unit.IsValid() && cast<Player>(unit.GetScriptBehavior()) is null)
				return;

			ShowBubble(sval);
		}

		void HideAll()
		{
			auto gm = cast<Campaign>(g_gameMode);
			if (gm !is null)
				gm.m_hud.m_speechBubbles.HideAll();
		}

		void HideBubble()
		{
			if (m_current is null)
				return;

			auto gm = cast<Campaign>(g_gameMode);
			if (gm is null)
				return;

			gm.m_hud.m_speechBubbles.Hide(m_current);
			@m_current = null;
		}

		void ShowBubble(SValue@ sval)
		{
			if (HideOthers)
				HideAll();
			else if (m_current !is null)
				HideBubble();

			auto gm = cast<Campaign>(g_gameMode);
			if (gm is null)
				return;

			string title = Resources::GetString(Title);
			string text = Resources::GetString(Text);

			@m_current = gm.m_hud.m_speechBubbles.Show();
			@m_current.m_shower = this;
			m_current.SetStyle(Style);
			m_current.SetText(title, text);
			m_current.m_unit = Objects.FetchFirst();
			m_current.m_offset.y = -HeightOffset;
			m_current.OnShown();

			m_timeC = Time;
			if (m_timeC == -2)
				m_timeC = Tweak::TextTimeCalc_Start + text.length() * Tweak::TextTimeCalc_PerCharacter;
		}

		void Update(int dt)
		{
			if (m_timeC > 0)
			{
				m_timeC -= dt;
				if (m_timeC <= 0)
					HideBubble();
			}
		}
	}
}
