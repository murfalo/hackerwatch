namespace WorldScript
{
	[WorldScript color="186 85 164" icon="system/icons.png;352;96;32;32"]
	class CrowdTriggerAction
	{
		[Editable]
		string Id;

		[Editable default=1]
		int Amount;

		SValue@ ServerExecute()
		{
			Crowd::Trigger(Id, Amount);
			return null;
		}
	}
}
