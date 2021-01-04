namespace Modifiers
{
	class StatueTriggerEffect : TriggerEffect, IStatueModifier
	{
		int m_levelOffset = -1;

		float m_addPerLevel;
		float m_mulPerLevel = 1.0f;

		StatueTriggerEffect() { super(); }
		StatueTriggerEffect(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_levelOffset = GetParamInt(unit, params, "level-offset", false, -1);

			m_addPerLevel = GetParamFloat(unit, params, "add-per-level", false, 0.0f);
			m_mulPerLevel = GetParamFloat(unit, params, "mul-per-level", false, 1.0f);
		}

		Modifier@ Instance() override
		{
			auto ret = StatueTriggerEffect();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		void SetStatue(Statues::StatueDef@ def, int level)
		{
			level += m_levelOffset;
			m_intensity = (1.0f + (level * m_addPerLevel)) * pow(m_mulPerLevel, level);
		}
	}
}
