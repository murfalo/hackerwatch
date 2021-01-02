class EffectSpawner
{
	UnitPtr m_unit;

	array<UnitScene@> m_effects;

	int m_intervalC;
	int m_interval;
	int m_intervalRandom;

	vec2 m_posRandom;

	EffectSpawner(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		array<SValue@>@ arr = GetParamArray(unit, params, "effects");
		for (uint i = 0; i < arr.length(); i++)
		{
			string fxName = arr[i].GetString();
			UnitScene@ fx = Resources::GetEffect(fxName);
			m_effects.insertLast(fx);
		}

		m_interval = GetParamInt(unit, params, "interval");
		m_intervalRandom = GetParamInt(unit, params, "interval-random", false);
		m_intervalC = m_interval + randi(m_intervalRandom);

		m_posRandom = GetParamVec2(unit, params, "pos-random", false);
		
		m_unit.SetUpdateDistanceLimit(300);
	}

	void Update(int dt)
	{
		if (m_intervalC > 0)
		{
			m_intervalC -= dt;
			if (m_intervalC <= 0)
			{
				m_intervalC = m_interval + randi(m_intervalRandom);

				int index = randi(m_effects.length());
				vec2 pos = xy(m_unit.GetPosition());
				pos.x += (randf() - 0.5f) * m_posRandom.x;
				pos.y += (randf() - 0.5f) * m_posRandom.y;
				PlayEffect(m_effects[index], pos);
			}
		}
	}
}
