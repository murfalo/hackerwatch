namespace Modifiers
{
	class CriticalHitTrigger : TriggerEffect
	{
		float m_critChance;
		float m_spellChance;
	
		CriticalHitTrigger() {}
		CriticalHitTrigger(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			m_critChance = GetParamFloat(unit, params, "chance", false, 0);
			m_spellChance = GetParamFloat(unit, params, "spell-chance", false, 0);
			m_trigger = EffectTrigger::None;
			
			m_chance = GetParamFloat(unit, params, "trigger-chance", false, 10);
		}

		Modifier@ Instance() override
		{
			auto ret = CriticalHitTrigger();
			ret = this;
			ret.m_cloned++;
			return ret;
		}
		
		bool HasTriggerEffects() override { return false; }
		bool HasCrit() override { return true; }
		float CritChance(bool spell) override { return spell ? m_spellChance : m_critChance; }
		
		int Crit(PlayerBase@ player, Actor@ enemy, bool spell) override 
		{
			if (!RollCrit(player, spell))
				return 0;

			TriggerEffects(player, enemy, EffectTrigger::None);
			return 1;
		}
		
		bool RollCrit(PlayerBase@ player, bool spell)
		{
			if (spell)
				return roll_chance(player, m_spellChance);
				
			return roll_chance(player, m_critChance);
		}
	}
}