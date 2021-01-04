namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;320;288;32;32"]
	class UnitPickedUpTrigger
	{
		bool Enabled;
	
		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		UnitSource Instigator;
		UnitSource Picker;
		
		UnitCallbackList m_callbacks;
		
		
		bool IsValid(UnitPtr unit)
		{
			return cast<Pickup>(unit.GetScriptBehavior()) !is null;
		}
		
		void OnChanged(array<UnitPtr>@ added, array<UnitPtr>@ removed)
		{
			if (added !is null)
			{
				for (uint i = 0; i < added.length(); i++)
				{
					auto pickup = cast<Pickup>(added[i].GetScriptBehavior());
					if (pickup is null)
						continue;
						
					pickup.m_callbacks.insertLast(this);
				}
			}
				
			if (removed !is null)
			{
				for (uint i = 0; i < removed.length(); i++)
				{
					auto pickup = cast<Pickup>(removed[i].GetScriptBehavior());
					if (pickup is null)
						continue;
				
					for (uint j = 0; j < pickup.m_callbacks.length(); j++)
					{
						if(pickup.m_callbacks[j] is this)
						{
							pickup.m_callbacks.removeAt(j);
							break;
						}
					}
				}
			}
		}
		
		void Cleanup()
		{
			m_callbacks.Cleanup();
		}
		
		void UnitPicked(UnitPtr picked, UnitPtr picker)
		{
			if (!Enabled)
				return;
				
			Instigator.Replace(picked);
			Picker.Replace(picker);

			WorldScript::GetWorldScript(g_scene, this).Execute();
		}
		
		SValue@ ServerExecute()
		{
			return null;
		}
	}
}