class EffectBehavior
{
	UnitPtr m_unit;
	int m_ttl;
	bool m_looping;
	EffectParams@ m_params;
	array<WorldScript@> m_finishTriggers;

	EffectBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		m_ttl = unit.GetCurrentUnitScene().Length();
	}
	
	void Initialize(UnitScene@ scene, bool attachToUnit = false)
	{
		m_unit.SetUnitScene(scene, true);
		m_ttl = scene.Length();
		@m_params = null;
		
		if (scene !is null)
		{
			auto d = scene.FetchData("data");
			if (d !is null)
			{
				if (attachToUnit)
				{
					PlaySound3D(Resources::GetSoundEvent(GetParamString(m_unit, d, "sound", false)), m_unit);
					PlayEffect(GetParamString(m_unit, d, "fx", false), m_unit);
				}
				else
				{
					PlaySound3D(Resources::GetSoundEvent(GetParamString(m_unit, d, "sound", false)), m_unit.GetPosition());
					PlayEffect(GetParamString(m_unit, d, "fx", false), m_unit.GetPosition());
				}
				
				auto gore = LoadGore(GetParamString(m_unit, d, "gore", false));
				if (gore !is null)
					gore.OnDeath(1.0, xy(m_unit.GetPosition()));
			}
		}
	}

	void Initialize(UnitScene@ scene, dictionary params, bool attachToUnit = false)
	{
		Initialize(scene, attachToUnit);
		
		@m_params = m_unit.CreateEffectParams();

		auto keys = params.getKeys();
		for (uint i = 0; i < keys.length(); i++)
		{
			float val;
			params.get(keys[i], val);
			m_params.Set(keys[i], val);
		}
	}

	void Initialize(UnitScene@ scene, EffectParams@ params)
	{
		Initialize(scene);
		
		@m_params = m_unit.CreateEffectParams(params);
	}
	

	void SetParam(string param, float value)
	{
		if (m_params !is null)
			m_params.Set(param, value);
	}

	void Update(int dt)
	{
		if (!m_looping)
		{
			m_ttl -= dt;
			if (m_ttl <= 0)
			{
				m_unit.Destroy();
				if (Network::IsServer())
				{
					for (uint i = 0; i < m_finishTriggers.length(); i++)
						m_finishTriggers[i].Execute();
				}
			}
		}
	}
}