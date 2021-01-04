namespace WorldScript
{
	[WorldScript color="210 30 30" icon="system/icons.png;0;96;32;32"]
	class SetDamageTransfer
	{
		[Editable validation=IsValidSource]
		UnitFeed SourceUnits;

		[Editable validation=IsValidTarget]
		UnitFeed TargetUnits;

		bool IsValidSource(UnitPtr unit)
		{
			return cast<CompositeActorBehavior>(unit.GetScriptBehavior()) !is null;
		}

		bool IsValidTarget(UnitPtr unit)
		{
			return cast<IDamageTaker>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			array<UnitPtr>@ sources = SourceUnits.FetchAll();
			array<UnitPtr>@ targets = TargetUnits.FetchAll();

			if (sources.length() != targets.length())
			{
				PrintError("Can't set transfer targets because sources and targets don't have the same amount of units! (" + sources.length() + " sources and " + targets.length() + " targets) " +
					"Are you sure the source is a CompositeActorBehavior?");
				return null;
			}

			for (uint i = 0; i < sources.length(); i++)
			{
				auto source = cast<CompositeActorBehavior>(sources[i].GetScriptBehavior());
				if (source !is null && targets[i].IsValid())
					source.m_transferTarget = targets[i];
			}

			return null;
		}

		void ClientExecute(SValue@ val)
		{
			ServerExecute();
		}
	}
}
