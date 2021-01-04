namespace WorldScript
{
	[WorldScript color="0 255 0" icon="system/icons.png;0;96;32;32"]
	class HealUnits
	{
		[Editable validation=IsValid]
		UnitFeed Units;

		[Editable default=10 min=0 max=1000000]
		int Amount;

		[Editable default=0]
		float AmountFactor;

		bool IsValid(UnitPtr unit)
		{
			return cast<Actor>(unit.GetScriptBehavior()) !is null;
		}

		SValue@ ServerExecute()
		{
			array<UnitPtr>@ units = Units.FetchAll();
			for (uint i = 0; i < units.length(); i++)
			{
				auto a = cast<Actor>(units[i].GetScriptBehavior());

				if (Amount > 0)
					a.Heal(Amount);

				if (AmountFactor > 0.0f)
				{
					auto enemy = cast<CompositeActorBehavior>(a);
					if (enemy !is null)
						enemy.Heal(roll_round(AmountFactor * enemy.GetMaxHp()));
				}
			}

			return null;
		}
	}
}
