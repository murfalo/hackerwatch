// These messages are for debugging, not used in production
namespace DebugHandler
{
	void DebugCompareKills(uint8 peer, int kills)
	{
		PlayerRecord@ player = GetLocalPlayerRecord();
		int localKills = player.kills;
		if (localKills != kills)
			print("!!!!!!! Difference in kill count: " + localKills + " (local), " + kills + " (remote)");
		else
			print("kill diff OK");
	}
}
