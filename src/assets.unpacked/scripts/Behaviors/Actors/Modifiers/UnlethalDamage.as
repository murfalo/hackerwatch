namespace Modifiers
{
	class UnlethalDamage : Modifier
	{
		UnlethalDamage(UnitPtr unit, SValue& params)
		{
		}

		bool HasNonLethalDamage() override { return true; }
		bool NonLethalDamage(PlayerBase@ player, DamageInfo& dmg) override
		{
			return true;
		}
	}
}
