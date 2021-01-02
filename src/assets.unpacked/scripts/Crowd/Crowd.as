namespace Crowd
{
	class BufferedNetworkMessage
	{
		int m_timeC;

		uint m_idHash;
		int m_delta;

		bool m_stat;
	}

	array<BufferedNetworkMessage@> g_bufferedMessages;

	array<CrowdAction@> g_actions;

	void LoadActions(string filename)
	{
		auto sval = Resources::GetSValue(filename);
		auto arr = sval.GetArray();
		for (uint i = 0; i < arr.length(); i++)
		{
			auto svAction = arr[i];
			string className = GetParamString(UnitPtr(), svAction, "class");
			auto newAction = cast<CrowdAction>(InstantiateClass(className, svAction));
			if (newAction !is null)
				g_actions.insertLast(newAction);
		}
	}

	CrowdAction@ GetAction(const string &in id, bool stat = false)
	{
		return GetAction(HashString(id), stat);
	}

	CrowdAction@ GetAction(uint id, bool stat = false)
	{
		for (uint i = 0; i < g_actions.length(); i++)
		{
			auto action = g_actions[i];
			if (action.m_stat == stat && action.m_idHash == id)
				return action;
		}
		return null;
	}

	void Trigger(const string &in id, int delta = 1, bool stat = false)
	{
		auto gm = cast<Survival>(g_gameMode);
		if (gm is null)
			return;

		uint idHash = HashString(id);

		auto action = cast<TriggerAction>(GetAction(idHash, stat));
		if (action is null)
		{
			if (!stat)
				PrintError("Couldn't find Crowd TriggerAction '" + id + "'!");
			return;
		}

		if (!Network::IsServer())
		{
			AddNetworkMessage(idHash, delta, stat);
			return;
		}

		action.Trigger(delta);
	}

	void AddNetworkMessage(uint idHash, int delta, bool stat)
	{
		BufferedNetworkMessage@ msg = null;
		for (uint i = 0; i < g_bufferedMessages.length(); i++)
		{
			if (g_bufferedMessages[i].m_idHash == idHash)
			{
				@msg = g_bufferedMessages[i];
				break;
			}
		}

		if (msg is null)
		{
			@msg = BufferedNetworkMessage();
			msg.m_timeC = 1000 + randi(500);
			msg.m_idHash = idHash;
			msg.m_stat = stat;
			g_bufferedMessages.insertLast(msg);
		}

		msg.m_delta += delta;
	}

	void Update(int dt)
	{
		for (int i = int(g_bufferedMessages.length() - 1); i >= 0; i--)
		{
			auto msg = g_bufferedMessages[i];
			msg.m_timeC -= dt;

			if (msg.m_timeC > 0)
				continue;

			string msgName = "SurvivalCrowdTrigger";
			if (msg.m_stat)
				msgName += "Stat";

			//print("Sending " + msgName + " for " + msg.m_idHash + " with delta " + msg.m_delta);
			(Network::Message(msgName) << int(msg.m_idHash) << msg.m_delta).SendToAll();

			g_bufferedMessages.removeAt(i);
		}
	}

	void Pause(bool paused)
	{
		auto gm = cast<Survival>(g_gameMode);
		if (gm is null)
			return;

		if (gm.m_crowdPaused == paused)
			return;

		gm.m_crowdPaused = paused;
		gm.m_crowdTimeC = gm.m_crowdTime;
	}

	void TimeReset()
	{
		auto gm = cast<Survival>(g_gameMode);
		if (gm is null)
			return;

		gm.m_crowdTimeElapsed = 0;

		for (uint i = 0; i < g_actions.length(); i++)
			g_actions[i].TimeReset();
	}

	float ClearDelta()
	{
		bool debugCrowd = GetVarBool("g_debug_crowd");

		if (debugCrowd)
			print("Calculating crowd delta:");

		float ret = 0.0f;
		for (uint i = 0; i < g_actions.length(); i++)
		{
			auto action = g_actions[i];
			float delta = action.GetDelta();
			ret += delta;

			if (debugCrowd)
			{
				float debug = action.GetDebugValue();
				print("  " + delta + "   " + action.m_id + " (" + debug + ")");
			}

			action.Clear();
		}

		return ret;
	}
}
