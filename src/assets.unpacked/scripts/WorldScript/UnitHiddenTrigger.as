enum HiddenState
{
	Either		= 0,
	Hidden		= 1,
	Shown		= 2,
}

namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;416;256;32;32"]
	class UnitHiddenTrigger
	{
		bool Enabled;
	
		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		[Editable type=enum default=0]
		HiddenState HiddenState;
		
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
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Hidden, this, "UnitHidden");
				
			if (removed !is null)
				for (uint i = 0; i < removed.length(); i++)
					m_callbacks.UnregisterEventCallback(removed[i]);
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}
		
		void UnitHidden(UnitPtr unit, SValue& arg)
		{
			if (!Enabled)
				return;
		
			switch (HiddenState)
			{
			case HiddenState::Hidden:
				if (!unit.IsHidden())
					return;
				break;
				
			case HiddenState::Shown:
				if (unit.IsHidden())
					return;
				break;
			}
		
			Instigator.Replace(unit);
			WorldScript::GetWorldScript(g_scene, this).Execute();
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}