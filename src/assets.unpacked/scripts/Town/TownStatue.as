class TownStatue
{
	string m_id;
	int m_level;
	int m_blueprint;

	Statues::StatueDef@ GetDef()
	{
		return Statues::GetStatue(m_id);
	}

	void Save(SValueBuilder& builder)
	{
		builder.PushDictionary(m_id);
		builder.PushInteger("level", m_level);
		builder.PushInteger("blueprint", m_blueprint);
		builder.PopDictionary();
	}

	void Load(SValue@ sv)
	{
		if (sv.GetType() == SValueType::Integer)
			m_blueprint = m_level = sv.GetInteger();
		else
		{
			m_level = GetParamInt(UnitPtr(), sv, "level");
			m_blueprint = GetParamInt(UnitPtr(), sv, "blueprint", false, m_level);
		}
	}
}
