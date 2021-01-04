enum CompareFunc
{
	Equal = 1,
	Greater, 
	Less, 
	GreaterOrEqual, 
	LessOrEqual, 
	NotEqual
}

namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;64;384;32;32"]
	class CheckVariables
	{
		[Editable type=enum default=1]
		CompareFunc Function;
	
		[Editable]
		int Value;
	
		[Editable max=1 validation=IsVariable]
		UnitFeed Variable;
		
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
		
			if (!variable.IsValid())
				return null;
			
			Variable@ var = cast<Variable>(variable.GetScriptBehavior());
			
			bool result = false;
			
			switch(Function)
			{
				case CompareFunc::Equal:
					result = var.GetValue() == Value;
					break;
				case CompareFunc::Greater:
					result = var.GetValue() > Value;
					break;
				case CompareFunc::Less:
					result = var.GetValue() < Value;
					break;
				case CompareFunc::GreaterOrEqual:
					result = var.GetValue() >= Value;
					break;
				case CompareFunc::LessOrEqual:
					result = var.GetValue() <= Value;
					break;
				case CompareFunc::NotEqual:
					result = var.GetValue() != Value;
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