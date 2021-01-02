namespace WorldScript
{
	[WorldScript color="50 50 255" icon="system/icons.png;256;0;32;32"]
	class RandomPicker
	{
		vec3 Position;

		[Editable validation=IsPickedRandom]
		UnitFeed PickedRandoms;

		[Editable default=1 min=1 max=100000]
		uint NumToExecute;

		bool IsPickedRandom(UnitPtr unit)
		{
			return cast<PickedRandom>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			array<PickedRandom@> scripts;

			int totChance = 0;
			auto rnds = PickedRandoms.FetchAll();
			for (uint i = 0; i < rnds.length(); i++)
			{
				auto ws = WorldScript::GetWorldScript(rnds[i]);

				if (!ws.CanExecuteNow())
					continue;

				auto random = cast<PickedRandom>(rnds[i].GetScriptBehavior());
				if (random is null)
				{
					PrintError("Unit " + rnds[i].GetId() + " is not a PickedRandom! (" + rnds[i].GetDebugName() + ")");
					continue;
				}

				scripts.insertLast(random);
				totChance += random.Chance;
			}

			uint num = NumToExecute;
			while (scripts.length() > 0 && num > 0)
			{
				int n = randi(totChance);
				for (uint i = 0; i < scripts.length(); i++)
				{
					n -= scripts[i].Chance;
					if (n < 0)
					{
						WorldScript::GetWorldScript(g_scene, scripts[i]).Execute();
						totChance -= scripts[i].Chance;
						scripts.removeAt(i);

						break;
					}
				}

				num--;
			}

			return null;
		}
	}
}
