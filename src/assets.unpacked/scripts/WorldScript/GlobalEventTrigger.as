namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;192;352;32;32"]
	class GlobalEventTrigger
	{
		[Editable]
		string EventName;

		[Editable default=1 min=0 max=1]
		float ChanceToExecute;

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
