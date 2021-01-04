namespace WorldScript
{
	[WorldScript color="238 232 170" icon="system/icons.png;192;320;32;32"]
	class AnnounceText
	{
		vec3 Position;

		[Editable]
		string Text;

		[Editable default="gui/fonts/arial11.fnt"]
		string Font;

		[Editable default=-1]
		int Align;

		[Editable default=0.5]
		float AnchorX;
		[Editable default=0.7]
		float AnchorY;

		[Editable default=-2]
		int Time;

		[Editable default=100]
		int FadeTime;

		[Editable default="#FFFFFFFF"]
		vec4 Color;

		[Editable default=false]
		bool Override;

		[Editable]
		SoundEvent@ Sound;

		[Editable validation=IsExecutable]
		UnitFeed FinishTrigger;

		[Editable]
		UnitFeed PlayerTarget;

		int m_finishC;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		void Update(int dt)
		{
			if (m_finishC > 0)
			{
				m_finishC -= dt;
				if (m_finishC <= 0)
				{
					auto scripts = FinishTrigger.FetchAll();
					for (uint i = 0; i < scripts.length(); i++)
					{
						auto script = WorldScript::GetWorldScript(scripts[i]);
						if (script !is null)
							script.Execute();
					}
				}
			}
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto hud = GetHUD();
			if (hud is null) {
				return;
			}

			UnitPtr unitPlayerTarget = PlayerTarget.FetchFirst();
			if (unitPlayerTarget.IsValid())
			{
				if (cast<Player>(unitPlayerTarget.GetScriptBehavior()) is null)
					return;
			}

			AnnounceParams params;
			params.m_text = Resources::GetString(Text);
			params.m_font = Font;
			params.m_anchor = vec2(AnchorX, AnchorY);
			params.m_time = Time;
			if (params.m_time == -2)
				params.m_time = Tweak::TextTimeCalc_Start + params.m_text.length() * Tweak::TextTimeCalc_PerCharacter;
			params.m_fadeTime = FadeTime;
			params.m_color = Color;
			params.m_override = Override;
			params.m_align = Align;

			if (!hud.Announce(params)) {
				return;
			}

			@hud.m_currAnnounce = this;

			m_finishC = FadeTime + params.m_time + FadeTime;

			if (Sound !is null)
				PlaySound2D(Sound);
		}
	}
}
