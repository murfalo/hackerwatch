namespace WorldScript
{
	[WorldScript color="238 80 80" icon="system/icons.png;192;320;32;32"]
	class StopAnnounceText
	{
		[Editable max=1 validation=IsValid]
		UnitFeed AnnounceScript;

		[Editable default=250]
		int FadeTime;

		bool IsValid(UnitPtr unit)
		{
			return cast<AnnounceText>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			auto unit = AnnounceScript.FetchFirst();

			if (!unit.IsValid())
				return;

			auto script = cast<AnnounceText>(unit.GetScriptBehavior());
			if (script is null)
				return;

			auto hud = GetHUD();
			if (hud is null) {
				return;
			}
			auto w = cast<TextWidget>(hud.m_widget.GetWidgetById("announce"));

			if (!w.m_visible || hud.m_currAnnounce !is script)
				return;

			auto col = script.Color;
			auto colTransparent = vec4(col.x, col.y, col.x, 0);

			w.CancelAnimations();
			w.Animate(WidgetVec4Animation("color", col, colTransparent, FadeTime));
			w.Animate(WidgetBoolAnimation("visible", false, FadeTime));
		}
	}
}
