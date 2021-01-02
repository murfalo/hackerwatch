namespace UnitMap
{
	class Replacement
	{
		UnitProducer@ m_prod;

		Replacement(SValue &params)
		{
			string strProdPath = GetParamString(UnitPtr(), params, "unit");
			@m_prod = Resources::GetUnitProducer(strProdPath);

			/*
			if (m_prod is null)
				PrintError("Unable to find unit producer: \"" + strProdPath + "\"");
			*/
		}

		UnitProducer@ Replace()
		{
			return m_prod;
		}
	}

	class SimpleReplacement : Replacement
	{
		UnitProducer@ m_replace;

		SimpleReplacement(SValue &params)
		{
			super(params);

			@m_replace = Resources::GetUnitProducer(GetParamString(UnitPtr(), params, "new-unit"));
		}

		UnitProducer@ Replace() override
		{
			return m_replace;
		}
	}

	class NGReplacementPair
	{
		int ng;
		UnitProducer@ prod;
	}

	class NGReplacement : Replacement
	{
		array<NGReplacementPair@> m_ngs;

		NGReplacement(SValue &params)
		{
			super(params);

			auto arrReplacements = GetParamArray(UnitPtr(), params, "ngs");
			for (uint i = 0; i < arrReplacements.length(); i += 2)
			{
				auto svNg = arrReplacements[i];
				auto svPath = arrReplacements[i + 1];

				auto pair = NGReplacementPair();
				pair.ng = svNg.GetInteger();
				@pair.prod = Resources::GetUnitProducer(svPath.GetString());
				
				if (pair.prod !is null)
					m_ngs.insertLast(pair);
			}
		}

		UnitProducer@ Replace() override
		{
			auto current = m_prod;
			int ngp = int(g_ngp);

			for (uint i = 0; i < m_ngs.length(); i++)
			{
				auto pair = m_ngs[i];
				if (ngp >= pair.ng)
					@current = pair.prod;
			}

			return current;
		}
	}

	array<Replacement@> g_replacements;

	void LoadFile(SValue@ sval)
	{
		auto arrUnits = sval.GetArray();
		for (uint i = 0; i < arrUnits.length(); i++)
		{
			SValue@ svUnit = arrUnits[i];
			if (svUnit.GetType() != SValueType::Dictionary)
				continue;

			string className = GetParamString(UnitPtr(), svUnit, "class");

			auto newReplacement = cast<Replacement>(InstantiateClass(className, svUnit));
			if (newReplacement is null)
			{
				PrintError("Couldn't instantiate class of name \"" + className + "\"!");
				continue;
			}

			g_replacements.insertLast(newReplacement);
		}
	}

	UnitProducer@ Replace(uint pathHash)
	{
		for (uint i = 0; i < g_replacements.length(); i++)
		{
			auto replacement = g_replacements[i];
			if (replacement.m_prod is null)
				continue;
			if (replacement.m_prod.GetResourceHash() == pathHash)
			{
				auto rep = replacement.Replace();
				if (rep !is null)
					return rep;
			}
		}
		return Resources::GetUnitProducer(pathHash);
	}

	UnitProducer@ Replace(UnitProducer@ prod)
	{
		if (prod is null)
			return null;

		for (uint i = 0; i < g_replacements.length(); i++)
		{
			auto replacement = g_replacements[i];
			if (replacement.m_prod is prod)
			{
				auto rep = replacement.Replace();
				if (rep !is null)
					return rep;
			}
		}
		return prod;
	}
}
