namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;192;320;32;32"]
	class ShowFloatingText
	{
		vec3 Position;

		[Editable]
		string Text;

		[Editable type=enum default=7]
		FloatingTextType FloatingType;

		SValue@ ServerExecute()
		{
			ClientExecute(null);
			return null;
		}

		void ClientExecute(SValue@ val)
		{
			string str = Resources::GetString(Text);
			AddFloatingText(FloatingType, str, Position);
		}
	}
}
