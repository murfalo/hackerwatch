namespace Modifiers
{
	class Buff : Modifier
	{
		ActorBuffDef@ m_buff;
		int m_freq;
		
		int m_timer;
	
		Buff() { }
		Buff(UnitPtr unit, SValue& params)
		{
			@m_buff = LoadActorBuff(GetParamString(unit, params, "buff", true));
			m_freq = GetParamInt(unit, params, "freq", false, 1000);
		}

		Modifier@ Instance() override
		{
			auto ret = Buff();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt)  override
		{
			if (player.IsHusk())
				return;
		
			m_timer -= dt;
			if (m_timer <= 0)
			{
				m_timer += m_freq;
				player.ApplyBuff(ActorBuff(player, m_buff, 1.0f, false));
			}
		}
	}
}