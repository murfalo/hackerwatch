namespace WorldScript
{
	dictionary g_variables;

	[WorldScript color="#8fff8f" icon="system/icons.png;0;384;32;32"]
	class GlobalVariable : Variable
	{
		[Editable]
		string Name;
		
		void SetValue(int v) override { g_variables.set(Name, v); }
		int GetValue() override 
		{ 
			int value = 0;
			if (!g_variables.get(Name, value))
				return Value;
			return value; 
		}
	}
}