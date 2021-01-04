enum ChangeFunc
{
	Set = 1,
	Add,
	Subtract
}

namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;32;384;32;32"]
	class ChangeVariables
	{
		[Editable type=enum default=1]
		ChangeFunc Function;
	
		[Editable]
		int Value;
	
		[Editable validation=IsVariable]
		UnitFeed Variables;

		bool IsVariable(UnitPtr unit)
		{
			return cast<Variable>(unit.GetScriptBehavior()) !is null;
		}
		
		SValue@ ServerExecute()
		{
			SValueBuilder sval;
			sval.PushArray();
		
			auto vars = Variables.FetchAll();
			for (uint i = 0; i < vars.length(); i++)
			{
				Variable@ var = cast<Variable>(vars[i].GetScriptBehavior());
				switch(Function)
				{
					case ChangeFunc::Set:
						var.SetValue(Value);
						break;
					case ChangeFunc::Add:
						var.SetValue(var.GetValue() + Value);
						break;
					case ChangeFunc::Subtract:
						var.SetValue(var.GetValue() - Value);
						break;
				}
				
				sval.PushInteger(var.GetValue());
			}
			
			sval.PopArray();
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			array<SValue@>@ data = val.GetArray();
		
			auto vars = Variables.FetchAll();
			for (uint i = 0; i < vars.length(); i++)
			{
				Variable@ var = cast<Variable>(vars[i].GetScriptBehavior());
				var.SetValue(data[i].GetInteger());
			}
		}
	}
}