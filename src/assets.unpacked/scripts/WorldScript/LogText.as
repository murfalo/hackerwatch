namespace WorldScript
{
	[WorldScript color="238 50 238" icon="system/icons.png;192;320;32;32"]
	class LogText
	{
		[Editable]
		string Text;

		[Editable validation=IsVariable]
		UnitFeed Variables;

		[Editable]
		bool AsDialog;

		bool IsVariable(UnitPtr unit)
		{
			return cast<Variable>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			string varDump = "";
			auto vars = Variables.FetchAll();
			for (uint i = 0; i < vars.length(); i++)
			{
				Variable@ var = cast<Variable>(vars[i].GetScriptBehavior());
				if (varDump != "")
					varDump += " ";
				varDump += vars[i].GetId() + ":" + var.GetValue();
			}
			string finalText = Text + " " + varDump;
			print("[LogText] " + finalText);
			if (AsDialog)
				g_gameMode.ShowDialog("", finalText, Resources::GetString(".menu.ok"), null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
