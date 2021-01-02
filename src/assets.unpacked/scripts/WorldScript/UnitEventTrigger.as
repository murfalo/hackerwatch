namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;160;64;32;32"]
	class UnitEventTrigger
	{
		[Editable]
		string EventName;

		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		UnitCallbackList m_callbacks;

		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}

		void OnChanged(array<UnitPtr>@ added, array<UnitPtr>@ removed)
		{
			if (!Network::IsServer())
				return;

			if (added !is null)
			{
				for (uint i = 0; i < added.length(); i++)
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Custom, this, "UnitCustomEvent");
			}

			if (removed !is null)
			{
				for (uint i = 0; i < removed.length(); i++)
					m_callbacks.UnregisterEventCallback(removed[i]);
			}
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}

		void UnitCustomEvent(UnitPtr unit, SValue@ sv)
		{
			string receivedEventName = "";

			if (sv.GetType() == SValueType::Array)
			{
				array<SValue@>@ arr = sv.GetArray();
				if (arr.length() > 0 && arr[0].GetType() == SValueType::String)
					receivedEventName = arr[0].GetString();
			}
			else if (sv.GetType() == SValueType::String)
				receivedEventName = sv.GetString();
			else
				return;

			if (receivedEventName == EventName)
				WorldScript::GetWorldScript(g_scene, this).Execute();
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
