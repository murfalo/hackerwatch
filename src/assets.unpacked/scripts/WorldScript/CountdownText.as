namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;96;0;32;32"]
	class CountdownText
	{
		[Editable default=3]
		int BeginCount;
		[Editable default=0]
		int EndCount;

		[Editable default=false]
		bool ShowLastNumber;

		[Editable default=-1]
		int StepCount;
		[Editable default=1000]
		int StepInterval;

		[Editable default="gui/fonts/code2003_20_bold.fnt"]
		string Font;

		[Editable default=0.5]
		float AnchorX;
		[Editable default=0.7]
		float AnchorY;

		[Editable default="#FFFFFFFF"]
		vec4 Color;

		[Editable]
		SoundEvent@ SoundTick;
		[Editable]
		SoundEvent@ SoundFinish;

		[Editable validation=IsExecutable]
		UnitFeed FinishTrigger;

		bool m_counting;
		int m_count;
		int m_intervalC;

		TextWidget@ m_widget;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		void Update(int dt)
		{
			if ((ShowLastNumber && m_intervalC < 0) || (!ShowLastNumber && !m_counting) || m_widget is null)
				return;

			m_intervalC -= dt;
			if (m_intervalC <= 0)
			{
				m_count += StepCount;
				if (m_counting)
					m_intervalC += StepInterval;
				else if (ShowLastNumber)
				{
					m_widget.m_visible = false;
					return;
				}

				m_widget.SetText("" + m_count);
				m_widget.m_host.DoLayout();

				if (StepCount < 0 && m_count <= EndCount)
					Done();
				else if (StepCount > 0 && m_count >= EndCount)
					Done();
				else
					PlaySound2D(SoundTick);
			}
		}

		void Done()
		{
			PlaySound2D(SoundFinish);

			m_counting = false;
			if (!ShowLastNumber)
				m_widget.m_visible = false;

			auto scripts = FinishTrigger.FetchAll();
			for (uint i = 0; i < scripts.length(); i++)
			{
				auto script = WorldScript::GetWorldScript(scripts[i]);
				if (script !is null)
					script.Execute();
			}
		}

		SValue@ ServerExecute()
		{
			HUD@ hud = GetHUD();
			@m_widget = hud.GetCountDown();
			if (m_widget is null)
				return null;

			m_counting = true;
			m_count = BeginCount;
			m_intervalC = StepInterval;

			PlaySound2D(SoundTick);

			m_widget.m_visible = true;
			m_widget.m_anchor = vec2(AnchorX, AnchorY);
			m_widget.SetColor(Color);
			m_widget.SetFont(Font);
			m_widget.SetText("" + m_count);

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
