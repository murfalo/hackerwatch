namespace Modifiers
{
	class AuraCone : Aura
	{
		float m_arc;
	
		AuraCone() { }
		AuraCone(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			m_arc = GetParamInt(unit, params, "arc", false, 90) * PI / 180.0f / 2;
			m_arc = dot(vec2(cos(0), sin(0)), vec2(cos(m_arc), sin(m_arc)));
		}

		Modifier@ Instance() override
		{
			auto ret = AuraCone();
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
					
				vec2 aimDir(cos(player.m_dirAngle), sin(player.m_dirAngle));
				
				for (uint i = 0; i < targets.length(); i++)
				{
					if (targets[i] == unit)
						continue;
					
					vec2 dir = normalize(xy(targets[i].GetPosition() - player.m_unit.GetPosition()));
					auto d = dot(aimDir, dir);
					//print("dot: " + d);
					
					if (d < m_arc)
						continue;
					
					cast<Actor>(targets[i].GetScriptBehavior()).ApplyBuff(ActorBuff(player, m_buff, 1.0f, false));
				}
			}
		}
	}
}