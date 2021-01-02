enum CompareMode
{
	All = 1,
	Any
}

namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;64;384;32;32"]
	class CompareMultiVariables
	{
		[Editable type=enum default=1]
		CompareMode Mode;

		[Editable type=enum default=1]
		CompareFunc Function;

		[Editable max=1 validation=IsVariable]
		UnitFeed Variable;

		[Editable validation=IsVariable]
		UnitFeed Variables;

		[Editable validation=IsExecutable]
		UnitFeed OnTrue;

		[Editable validation=IsExecutable]
		UnitFeed OnFalse;

		bool IsVariable(UnitPtr unit)
		{
			return cast<Variable>(unit.GetScriptBehavior()) !is null;
		}

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			auto variable = Variable.FetchFirst();
			auto vars = Variables.FetchAll();
		
			if (!variable.IsValid() || vars.length() == 0)
				return null;

			Variable@ var = cast<Variable>(variable.GetScriptBehavior());
			bool result = false;

			for (uint i = 0; i < vars.length(); i++)
			{
				Variable@ compare = cast<Variable>(vars[i].GetScriptBehavior());

				switch(Function)
				{
					case CompareFunc::Equal:
						result = var.GetValue() == compare.GetValue();
						break;
					case CompareFunc::Greater:
						result = var.GetValue() > compare.GetValue();
						break;
					case CompareFunc::Less:
						result = var.GetValue() < compare.GetValue();
						break;
					case CompareFunc::GreaterOrEqual:
						result = var.GetValue() >= compare.GetValue();
						break;
					case CompareFunc::LessOrEqual:
						result = var.GetValue() <= compare.GetValue();
						break;
					case CompareFunc::NotEqual:
						result = var.GetValue() != compare.GetValue();
						break;
				}

				if (Mode == CompareMode::Any && result)
					break;
				else if (Mode == CompareMode::All && !result)
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