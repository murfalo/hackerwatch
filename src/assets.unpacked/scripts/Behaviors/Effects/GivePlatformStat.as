class GivePlatformStat : IEffect
{
	StatActionType m_type;
	string m_name;

	int m_valueInt;
	float m_valueFloat;

	GivePlatformStat(UnitPtr unit, SValue& params)
	{
		string type = GetParamString(unit, params, "type");
		     if (type == "UnlockAchievement") m_type = StatActionType::UnlockAchievement;
		else if (type == "SetStatInt") m_type = StatActionType::SetStatInt;
		else if (type == "SetStatFloat") m_type = StatActionType::SetStatFloat;
		else if (type == "IncreaseStatInt") m_type = StatActionType::IncreaseStatInt;
		else if (type == "IncreaseStatFloat") m_type = StatActionType::IncreaseStatFloat;
		else if (type == "DecreaseStatInt") m_type = StatActionType::DecreaseStatInt;
		else if (type == "DecreaseStatFloat") m_type = StatActionType::DecreaseStatFloat;

		m_name = GetParamString(unit, params, "name");

		m_valueInt = GetParamInt(unit, params, "value-int", false, 0);
		m_valueFloat = GetParamInt(unit, params, "value-float", false, 0.0f);
	}
	
	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

%if MOD_ACHIEVEMENT_CHECKS
		switch (m_type)
		{
			case StatActionType::UnlockAchievement: Platform::Service.UnlockAchievement(m_name); break;

			case StatActionType::SetStatInt: Platform::Service.SetStatInt(m_name, m_valueInt); break;
			case StatActionType::SetStatFloat: Platform::Service.SetStatFloat(m_name, m_valueFloat); break;

			case StatActionType::IncreaseStatInt: Platform::Service.IncreaseStatInt(m_name, m_valueInt); break;
			case StatActionType::IncreaseStatFloat: Platform::Service.IncreaseStatFloat(m_name, m_valueFloat); break;

			case StatActionType::DecreaseStatInt: Platform::Service.IncreaseStatInt(m_name, -m_valueInt); break;
			case StatActionType::DecreaseStatFloat: Platform::Service.IncreaseStatFloat(m_name, -m_valueFloat); break;
		}
%endif

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		return (cast<Player>(target.GetScriptBehavior()) !is null);
	}
}
