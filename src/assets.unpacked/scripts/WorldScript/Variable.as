namespace WorldScript
{
	[WorldScript color="#8fbc8f" icon="system/icons.png;0;384;32;32"]
	class Variable
	{
		[Editable]
		int Value;
		
		int GetValue() { return Value; }
		void SetValue(int v) { Value = v; }
		
		SValue@ Save()
		{
			SValueBuilder sval;
			sval.PushInteger(GetValue());
			return sval.Build();
		}
		
		void Load(SValue@ data)
		{
			SetValue(data.GetInteger());
		}
		
		void DebugDraw(vec2 pos, SpriteBatch& sb)
		{
			auto sysFont = Resources::GetBitmapFont("system/system.fnt");
			auto text = sysFont.BuildText("" + GetValue());
			
			sb.DrawString(pos - vec2(text.GetWidth(), text.GetHeight() - 1) / 2, text);
		}
	}
}