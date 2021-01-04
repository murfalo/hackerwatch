namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;288;352;32;32"]
	class SetUnitLayer
	{
		[Editable]
		UnitFeed Units;

		[Editable]
		int Layer;

		SValue@ ServerExecute()
		{
			auto units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
				units[i].SetLayer(Layer);

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
