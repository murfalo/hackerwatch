namespace WorldScript
{
	[WorldScript color="238 50 238" icon="system/icons.png;192;320;32;32"]
	class ShowDialog : IWidgetHoster
	{
		[Editable]
		string Text;

		[Editable]
		bool AsQuestion;

		[Editable]
		bool ShouldPauseGame;

		[Editable]
		UnitFeed ForPlayer;

		[Editable validation=IsExecutable]
		UnitFeed OnYes;

		[Editable validation=IsExecutable]
		UnitFeed OnNo;

		[Editable validation=IsExecutable]
		UnitFeed OnOK;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			UnitPtr unit = ForPlayer.FetchFirst();
			if (unit.IsValid() && cast<Player>(unit.GetScriptBehavior()) is null)
				return null;

			if (AsQuestion)
			{
				g_gameMode.ShowDialog(
					"dialog",
					Resources::GetString(Text),
					Resources::GetString(".menu.yes"),
					Resources::GetString(".menu.no"),
					this
				);
			}
			else
			{
				g_gameMode.ShowDialog(
					"dialog",
					Resources::GetString(Text),
					Resources::GetString(".menu.ok"),
					this
				);
			}

			if (ShouldPauseGame)
				PauseGame(true, true);

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}

		void OnResult(string result)
		{
			if (!Network::IsServer())
			{
				auto ws = WorldScript::GetWorldScript(g_scene, this);
				(Network::Message("ShowDialogResult") << ws.GetUnit() << result).SendToHost();
				return;
			}

			array<UnitPtr>@ toExec;
			if (result == "ok")
				@toExec = OnOK.FetchAll();
			else if (result == "yes")
				@toExec = OnYes.FetchAll();
			else
				@toExec = OnNo.FetchAll();

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (ShouldPauseGame)
				PauseGame(false, true);

			auto parse = name.split(" ");
			if (parse[0] == "dialog")
			{
				if (AsQuestion && parse.length() == 2)
					OnResult(parse[1]);
				else if (!AsQuestion && parse.length() == 1)
					OnResult("ok");
			}
		}

		void DoLayout() override { }
		void Update(int dt) override { }
		void Draw(SpriteBatch& sb, int idt) override { }
		void UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override { }
	}
}
