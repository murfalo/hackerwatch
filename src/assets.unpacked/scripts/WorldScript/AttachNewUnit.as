namespace WorldScript
{
	[WorldScript color="186 85 211" icon="system/icons.png;416;0;32;32"]
	class AttachNewUnit
	{
		[Editable]
		UnitProducer@ UnitType;

		[Editable]
		string SceneName;

		[Editable max=1]
		UnitFeed AttachTo;

		[Editable]
		int OffsetX;
		[Editable]
		int OffsetY;

		[Editable default=true]
		bool DestroyOnDestroy;

		[Editable default=-1]
		int Layer;
		
		[Editable default=-1]
		int Duration;
		
		

		UnitPtr ProduceUnit(int id)
		{
			auto attachTo = AttachTo.FetchFirst();
		
			if (!attachTo.IsValid())
				return UnitPtr();

			if (UnitType is null)
				return UnitPtr();

			auto sceneName = SceneName;
			if (sceneName == "")
			{
				auto sceneSet = UnitType.GetSceneSet("start");
				if (sceneSet.length() > 0)
					sceneName = sceneSet[0];
			}

			auto offset = vec2(OffsetX, OffsetY);
			UnitProducer@ attProd = Resources::GetUnitProducer("system/attached.unit");
			UnitPtr attUnit = attProd.Produce(g_scene, attachTo.GetPosition() + xyz(offset), id);
			auto att = cast<AttachedUnit>(attUnit.GetScriptBehavior());
			att.Initialize(UnitType, sceneName, Layer, attachTo, offset, DestroyOnDestroy, Duration);
			
			return attUnit;
		}

		SValue@ ServerExecute()
		{
			auto u = ProduceUnit(0);
			if (!u.IsValid())
				return null;

			SValueBuilder sval;
			sval.PushInteger(u.GetId());
			return sval.Build();
		}

		void ClientExecute(SValue@ val)
		{
			if (val is null)
				return;
			ProduceUnit(val.GetInteger());
		}
	}
}
