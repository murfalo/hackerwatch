namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;224;320;32;32"]
	class ActorHealthTrigger
	{
		bool Enabled;

		[Editable validation=IsValid changed=OnChanged]
		UnitFeed Units;

		[Editable type=enum default=2]
		FloatCompareFunc Function;

		[Editable]
		float Value;

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
					m_callbacks.RegisterEventCallback(added[i], UnitEventType::Damaged, this, "UnitDamaged");
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

		void UnitDamaged(UnitPtr unit, SValue@ arg)
		{
			if (!Enabled)
				return;

			auto actor = cast<Actor>(unit.GetScriptBehavior());
			if (actor is null)
				return;

			float hp = actor.GetHealth();
			bool result = false;
			switch (Function)
			{
				case FloatCompareFunc::Greater: result = hp > Value; break;
				case FloatCompareFunc::Less: result = hp < Value; break;
				case FloatCompareFunc::GreaterOrEqual: result = hp >= Value; break;
				case FloatCompareFunc::LessOrEqual: result = hp <= Value; break;
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
