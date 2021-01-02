namespace Modifiers
{
	class Thorns : Modifier
	{
		float m_physical;
		float m_magical;
		
		Thorns(UnitPtr unit, SValue& params)
		{
			m_physical = GetParamFloat(unit, params, "physical", false, 0);
			m_magical = GetParamFloat(unit, params, "magical", false, 0);
		}

		bool HasDamageTaken() override { return true; }
		void DamageTaken(PlayerBase@ player, Actor@ enemy, int dmgAmnt) override 
		{
			if (enemy is null || enemy.IsDead())
				return;
				
			vec2 pos = xy(enemy.m_unit.GetPosition());
			vec2 dir = normalize(xy(enemy.m_unit.GetPosition() - player.m_unit.GetPosition()));
			
			uint weaponInfo = 0;
		
			auto dmg = DamageInfo(player, damage_round(dmgAmnt * m_physical), damage_round(dmgAmnt * m_magical), false, true, weaponInfo);
			dmg.LifestealMul = 0;

			enemy.Damage(dmg, pos, dir);
		}
	}
}
