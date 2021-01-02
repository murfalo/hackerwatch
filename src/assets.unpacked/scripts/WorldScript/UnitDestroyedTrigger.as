namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;64;192;32;32"]
	class UnitDestroyedTrigger
	{
		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;
		
		UnitSource Instigator;

		UnitCallbackList m_callbacks;
		
		
		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null;
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}
			
		void OnChanged(array<UnitPtr>@ added, array<UnitPtr>@ removed)
		{
			if (!Network::IsServer())
				return;
		
			if (added !is null)
				for (uint i = 0; i < added.length(); i++)
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Destroyed, this, "UnitDestroyed");
			
			if (removed !is null)
				for (uint i = 0; i < removed.length(); i++)
					m_callbacks.UnregisterEventCallback(removed[i]);
		}
		
		void UnitDestroyed(UnitPtr unit, SValue& arg)
		{
			Instigator.Replace(unit);
			WorldScript::GetWorldScript(g_scene, this).Execute();
			Instigator.Clear();
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
