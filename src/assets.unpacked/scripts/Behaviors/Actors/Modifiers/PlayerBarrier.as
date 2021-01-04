namespace Modifiers
{
	class PlayerBarrier : Modifier
	{
		float m_chance;
		float m_dmgTakenMul;
	
		PlayerBarrier(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", false, 10);
			m_dmgTakenMul = GetParamFloat(unit, params, "dmg-taken-mul", false, 1);
		}

		bool HasDamageTakenMul() override { return true; }
		float DamageTakenMul(PlayerBase@ player, DamageInfo &di) override 
		{
			if (di.DamageType == 0)
				return 1;
		
			if (randf() > m_chance) 
				return 1;
			
			if (di.Attacker !is null && di.Attacker !is player)
			{
				auto skill = cast<Skills::PassiveSkill>(player.m_skills[4]);
				if (skill !is null)
				{
					auto mod = cast<Modifiers::TriggerEffect>(skill.m_modifiers[0]);
					if (mod !is null)
						mod.Trigger(player, di.Attacker.m_unit);
				}
			}
			
			return m_dmgTakenMul; 
		}
	}
}