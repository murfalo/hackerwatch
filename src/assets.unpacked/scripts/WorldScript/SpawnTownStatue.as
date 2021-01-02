namespace WorldScript
{
	[WorldScript color="#DBB1DE" icon="system/icons.png;288;192;32;32"]
	class SpawnTownStatue
	{
		[Editable default="doodads/generic/desert_statues.unit"]
		UnitProducer@ DefaultUnit;

		[Editable default="default"]
		string DefaultScene;

		UnitScene@ GetDefaultScene()
		{
			if (DefaultUnit is null)
				return null;

			return DefaultUnit.GetUnitScene(DefaultScene);
		}
	}
}
