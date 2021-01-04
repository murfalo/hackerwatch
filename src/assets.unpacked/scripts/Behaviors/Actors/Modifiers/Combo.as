namespace Modifiers
{
	class Combo : FilterModifier
	{
		array<IEffect@>@ m_effects;
		ivec3 m_props;
		bool m_invert;
		bool m_disabled;
		
		Combo(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			
			@m_effects = LoadEffects(unit, params);
			m_invert = GetParamBool(unit, params, "invert", false, false);
			
			m_props.x = GetParamInt(unit, params, "trigger-count", false, 0);
			m_props.y = GetParamInt(unit, params, "unlock-time", false, 0);
			m_props.z = GetParamInt(unit, params, "maintain-time", false, 0);

			m_disabled = GetParamBool(unit, params, "disabled", false, false);
		}
		
		bool Filter(PlayerBase@ player, Actor@ enemy) override 
		{
			if (player is null)
				return false;
			return m_invert ? !player.m_comboActive : player.m_comboActive; 
		}
		
		bool HasComboEffects() override { return m_effects !is null; }
		array<IEffect@>@ ComboEffects(PlayerBase@ player) override { return m_effects; }
		
		bool HasComboProps() override { return m_props.x != 0 || m_props.y != 0 || m_props.z != 0; }
		ivec3 ComboProps(PlayerBase@ player) override { return m_props; }

		bool ComboDisabled(PlayerBase@ player) override { return m_disabled; }
	}
}