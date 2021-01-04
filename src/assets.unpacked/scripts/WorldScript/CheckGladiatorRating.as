namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;64;384;32;32"]
	class CheckGladiatorRating
	{
		[Editable type=enum default=1]
		CompareFunc Function;

		[Editable]
		int Value;

		[Editable validation=IsExecutable]
		UnitFeed OnTrue;

		[Editable validation=IsExecutable]
		UnitFeed OnFalse;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			bool result = false;

			int checkValue = g_gladiatorRating;

			switch(Function)
			{
				case CompareFunc::Equal:
					result = checkValue == Value;
					break;
				case CompareFunc::Greater:
					result = checkValue > Value;
					break;
				case CompareFunc::Less:
					result = checkValue < Value;
					break;
				case CompareFunc::GreaterOrEqual:
					result = checkValue >= Value;
					break;
				case CompareFunc::LessOrEqual:
					result = checkValue <= Value;
					break;
				case CompareFunc::NotEqual:
					result = checkValue != Value;
					break;
			}

			array<UnitPtr>@ toExec;
			if (result)
				@toExec = OnTrue.FetchAll();
			else
				@toExec = OnFalse.FetchAll();

			for (uint i = 0; i < toExec.length(); i++)
				WorldScript::GetWorldScript(g_scene, toExec[i].GetScriptBehavior()).Execute();

			return null;
		}
	}
}
