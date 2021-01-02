namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;128;352;32;32"]
	class UnitDamagedTrigger
	{
		bool Enabled;
	
		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;
		
		UnitSource Instigator;
		
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
				for (uint i = 0; i < added.length(); i++)
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Damaged, this, "UnitDamaged");
				
			if (removed !is null)
				for (uint i = 0; i < removed.length(); i++)
					m_callbacks.UnregisterEventCallback(removed[i]);
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}
		
		void UnitDamaged(UnitPtr unit, SValue& arg)
		{
			if (!Enabled)
				return;
		
			Instigator.Replace(unit);
			WorldScript::GetWorldScript(g_scene, this).Execute();
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}