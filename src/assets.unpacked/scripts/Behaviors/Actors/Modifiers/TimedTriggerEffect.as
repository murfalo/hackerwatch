namespace Modifiers
{
	class TimedTriggerEffect : TriggerEffect
	{
		int m_freq;
		int m_timer;
	
		TimedTriggerEffect() { super(); }
		TimedTriggerEffect(UnitPtr unit, SValue& params)
		{
			m_chance = GetParamFloat(unit, params, "chance", false, 10);
			@m_effects = LoadEffects(unit, params);
			m_weaponInfo = GetParamInt(unit, params, "weapon-info", false, 0);
			m_fx = GetParamString(unit, params, "fx", false);
			m_selfFx = GetParamString(unit, params, "self-fx", false);
			m_timeout = GetParamInt(unit, params, "timeout", false);
			m_intensity = GetParamFloat(unit, params, "intensity", false, 1.0f);
			m_enabled = true;
			
			m_freq = GetParamInt(unit, params, "freq", true, 1000);
			m_timer = randi(m_freq);
		}

		Modifier@ Instance() override
		{
			auto ret = TimedTriggerEffect();
			ret = this;
			ret.m_cloned++;
			return ret;
		}
		
		// NOTE: HasTriggerEffects returns true so that PlayerHandler::GetTriggerEffectFromID can properly find this modifier and netsync it
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, EffectTrigger trigger) override {}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt)  override
		{
			if (player.IsHusk())
				return;
		
			m_timer -= dt;
			if (m_timer <= 0)
			{
				m_timer += m_freq;

				if (!roll_chance(player, m_chance))
					return;

				Trigger(player, player.m_unit);
			}
		}
	}
}