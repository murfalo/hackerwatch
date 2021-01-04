namespace Skills
{
	class Whirlwind : ActiveSkill
	{
		array<IEffect@>@ m_effects;

		int m_duration;
		int m_freq;
		int m_durationC;
		int m_freqC;

		Whirlwind(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			@m_effects = LoadEffects(unit, params);
			
			m_duration = GetParamInt(unit, params, "duration");
			m_freq = GetParamInt(unit, params, "freq");
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
		}
		
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
			m_freqC = m_freq;
			m_animCountdown = m_duration - m_castpoint;
			
			PlaySkillEffect(vec2(1,0));
		}
		
		float GetMoveSpeedMul() override { return m_durationC <= 0 ? 1.0 : m_speedMul; }

		void DoUpdate(int dt) override
		{
			if (m_durationC <= 0)
				return;
			
			m_durationC -= g_wallDelta;
			m_freqC -= dt;
			
			if (m_freqC <= 0)
			{
				m_freqC += m_freq;
			
				vec2 pos = xy(m_owner.m_unit.GetPosition());
				ApplyEffects(m_effects, m_owner, UnitPtr(), pos, vec2(1,0), 1.0, m_owner.IsHusk(), 1, 1);
			}
		}
	}
}