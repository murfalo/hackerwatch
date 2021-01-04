namespace Skills
{
	class Whirlnova : ActiveSkill
	{
		int m_duration;
		int m_durationC;
				
		int m_projDist;
		int m_projDelay;
		int m_projDelayC;
		int m_perRev;
		int m_projsShot;
		
		UnitProducer@ m_projProd;
		

		Whirlnova(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			m_duration = GetParamInt(unit, params, "duration");
			m_projDist = GetParamInt(unit, params, "proj-dist", false);
			m_projDelay = GetParamInt(unit, params, "proj-delay", false, 33);
			m_perRev = GetParamInt(unit, params, "per-revolution", false, 16);
			
			@m_projProd = Resources::GetUnitProducer(GetParamString(unit, params, "projectile", false));
		}
		/*
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
		}
		*/
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			StartWhirl(false);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			StartWhirl(true);
		}

		void StartWhirl(bool husk)
		{
			if (m_durationC > 0)
				return;

			m_durationC = m_duration;
			m_projDelayC = m_projDelay;
			m_projsShot = 0;
			m_animCountdown = m_duration - m_castpoint;
			
			PlaySkillEffect(vec2(1,0));
		}
		
		float GetMoveSpeedMul() override { return m_durationC <= 0 ? 1.0 : m_speedMul; }

		void DoUpdate(int dt) override
		{
			if (m_durationC <= 0)
				return;
			
			m_durationC -= dt;
			m_projDelayC -= dt;
			
			while (m_projDelayC <= 0)
			{
				m_projDelayC += m_projDelay;
			
				vec2 pos = xy(m_owner.m_unit.GetPosition());
				float angle = ((2 * PI / m_perRev) * m_projsShot++);
				vec2 shootDir = vec2(cos(angle), sin(angle));
				vec3 projPos = xyz(pos + shootDir * m_projDist);
				UnitPtr proj = m_projProd.Produce(g_scene, projPos);
				if (proj.IsValid())
				{
					IProjectile@ p = cast<IProjectile>(proj.GetScriptBehavior());
					if (p !is null)
						p.Initialize(m_owner, shootDir, 1.0, false, null, m_skillId + 1);
				}
			}
		}
	}
}