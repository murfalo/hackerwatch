namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;224;320;32;32"]
	class ActorBuffTrigger
	{
		bool Enabled;

		[Editable type=enum]
		BuffCheckMode Mode;

		[Editable]
		string Buff;

		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;
		

		UnitSource Instigator;

		UnitCallbackList m_callbacks;


		bool IsValid(UnitPtr unit)
		{
			return WorldScript::GetWorldScript(unit) is null && cast<Actor>(unit.GetScriptBehavior()) !is null;
		}

		void OnChanged(array<UnitPtr>@ added, array<UnitPtr>@ removed)
		{
			if (!Network::IsServer())
				return;

			if (added !is null)
			{
				for (uint i = 0; i < added.length(); i++)
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Custom, uint(CustomUnitEventType::ApplyBuff), this, "UnitApplyBuff");
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

		void UnitApplyBuff(UnitPtr unit, SValue@ arg)
		{
			if (!Enabled)
				return;

			auto actor = cast<CompositeActorBehavior>(unit.GetScriptBehavior());
			if (actor is null)
				return;

			bool result = false;
			switch (Mode)
			{
				case BuffCheckMode::BuffName: result = actor.m_buffs.HasBuff(HashString(Buff)); break;
				case BuffCheckMode::BuffTag: result = actor.m_buffs.HasTags(ApplyActorBuffTag(0, Buff)); break;
			}

			if (!result)
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
