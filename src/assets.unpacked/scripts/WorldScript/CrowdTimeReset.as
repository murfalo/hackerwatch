namespace WorldScript
{
	[WorldScript color="186 85 164" icon="system/icons.png;352;96;32;32"]
	class CrowdTimeReset
	{
		SValue@ ServerExecute()
		{
			Crowd::TimeReset();
			return null;
		}
	}
}
