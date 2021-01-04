class ExplodeChainLimit : Explode
{
	int m_currentChain;
	int m_limit;

	ExplodeChainLimit(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		m_limit = GetParamInt(unit, params, "limit", false, 1);
	}

	bool DoExplosion(Actor@ owner, vec2 pos, vec2 dir, float intensity, bool husk) override
	{
		bool ret = false;
		if (m_currentChain < m_limit)
		{
			m_currentChain++;
			ret = Explode::DoExplosion(owner, pos, dir, intensity, husk);
			m_currentChain--;
		}
		return ret;
	}
}
