namespace WorldScript
{
	[WorldScript color="255 0 0" icon="system/icons.png;256;96;32;32"]
	class DestroyScripts
	{
		[Editable]
		bool DeleteSelf;
	
		[Editable validation=IsValid]
		UnitFeed Units;

		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) !is null;
		}
		
		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
				units[i].Destroy();

			if (DeleteSelf)
			{
				auto script = WorldScript::GetWorldScript(g_scene, this);
				script.GetUnit().Destroy();
			}

			return null;
		}
	}
}