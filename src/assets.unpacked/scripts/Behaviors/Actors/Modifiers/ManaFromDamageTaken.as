namespace Modifiers
{
	class ManaFromDamageTaken : Modifier
	{
		float m_scale;
		float m_chance;

		ManaFromDamageTaken(UnitPtr unit, SValue& params)
		{
			m_scale = GetParamFloat(unit, params, "scale");
			m_chance = GetParamFloat(unit, params, "chance", false, 1.0);
		}

		bool HasManaFromDamage() override { return true; }
		int ManaFromDamage(PlayerBase@ player, int dmgAmnt) override
		{
			if (dmgAmnt > 0 && roll_chance(player, m_chance))
				return int(dmgAmnt * m_scale);
			return 0;
		}
	}
}
