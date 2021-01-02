enum JamTriggerType
{
	OnJam = 1,
	OnUnjam,
	OnAnyJam
}

namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;32;32;32;32"]
	class JamTrigger
	{
		[Editable type=enum default=1]
		JamTriggerType TriggerType;

		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		UnitCallbackList m_callbacks;

		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null && cast<IJammable>(unit.GetScriptBehavior()) !is null;
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
			string type = sv.GetString();
			if (TriggerType == JamTriggerType::OnAnyJam ||
			   (TriggerType == JamTriggerType::OnJam && type == "Jam") ||
			   (TriggerType == JamTriggerType::OnUnjam && type == "Unjam"))
			{
				WorldScript::GetWorldScript(g_scene, this).Execute();
			}
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
