namespace Modifiers
{
	class Aura : Modifier
	{
		ActorBuffDef@ m_buff;
		int m_freq;
		int m_range;
		bool m_friendly;
		
		int m_timer;
	
		Aura() { }
		Aura(UnitPtr unit, SValue& params)
		{
			@m_buff = LoadActorBuff(GetParamString(unit, params, "buff", true));
			m_freq = GetParamInt(unit, params, "freq", true, 1000);
			m_range = GetParamInt(unit, params, "range", true, 150);
			m_friendly = GetParamBool(unit, params, "friendly", false, false);
			m_timer = randi(m_freq);
		}

		Modifier@ Instance() override
		{
			auto ret = Aura();
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
				
				array<UnitPtr>@ targets;
				UnitPtr unit = player.m_unit;
				
				if (m_friendly)
					@targets = g_scene.FetchActorsWithTeam(player.Team, xy(unit.GetPosition()), m_range);
				else
					@targets = g_scene.FetchActorsWithOtherTeam(player.Team, xy(unit.GetPosition()), m_range);
				
				for (uint i = 0; i < targets.length(); i++)
				{
					if (targets[i] == unit)
						continue;

					auto actor = cast<Actor>(targets[i].GetScriptBehavior());
					if (actor.IsTargetable())
						actor.ApplyBuff(ActorBuff(player, m_buff, 1.0f, false));
				}
			}
		}
	}
}