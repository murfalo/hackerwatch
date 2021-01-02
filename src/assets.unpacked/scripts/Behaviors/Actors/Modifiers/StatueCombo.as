namespace Modifiers
{
	class StatueCombo : StackedModifier
	{
		int m_maintainTime;

		StatueCombo() {}
		StatueCombo(UnitPtr unit, SValue& params)
		{
			m_maintainTime = GetParamInt(unit, params, "maintain-time", false, 0);
		}

		Modifier@ Instance() override
		{
			auto ret = StatueCombo();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		bool HasComboProps() override { return true; }
		ivec3 ComboProps(PlayerBase@ player) override
		{
			ivec3 ret(0, 0, 0);

			if (player.m_comboActive)
				ret.z = m_maintainTime * m_stackCount;

			return ret;
		}
	}
}
