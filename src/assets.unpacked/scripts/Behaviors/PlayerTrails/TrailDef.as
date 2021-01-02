namespace PlayerTrails
{
	class TrailDef
	{
		string m_id;
		uint m_idHash;

		string m_name;
		string m_description;

		UnitScene@ m_fx;

		UnitScene@ m_walkFx;
		int m_walkTime;

		int m_legacyPoints;

		ScriptSprite@ m_icon;

		TrailDef(SValue@ sval)
		{
			m_id = GetParamString(UnitPtr(), sval, "id", false);
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), sval, "name");
			m_description = GetParamString(UnitPtr(), sval, "description", false);

			@m_fx = Resources::GetEffect(GetParamString(UnitPtr(), sval, "fx", false));

			@m_walkFx = Resources::GetEffect(GetParamString(UnitPtr(), sval, "walk-fx", false));
			m_walkTime = GetParamInt(UnitPtr(), sval, "walk-time", false, 100);

			m_legacyPoints = GetParamInt(UnitPtr(), sval, "legacy-points", false, 10);

			auto arrIcon = GetParamArray(UnitPtr(), sval, "icon", false);
			if (arrIcon !is null)
				@m_icon = ScriptSprite(arrIcon);
		}
	}

	array<TrailDef@> g_trails;

	TrailDef@ GetTrail(const string &in id)
	{
		return GetTrail(HashString(id));
	}

	TrailDef@ GetTrail(uint idHash)
	{
		for (uint i = 0; i < g_trails.length(); i++)
		{
			auto trail = g_trails[i];
			if (trail.m_idHash == idHash)
				return trail;
		}
		return null;
	}

	void LoadTrail(SValue@ sval)
	{
		if (sval.GetType() != SValueType::Dictionary)
		{
			PrintError("Trail sval must be a dictionary!");
			return;
		}

		g_trails.insertLast(TrailDef(sval));
	}

	void LoadTrails(SValue@ sval)
	{
		if (sval.GetType() != SValueType::Array)
		{
			PrintError("Trails sval must be an array!");
			return;
		}

		auto arrTrails = sval.GetArray();
		for (uint i = 0; i < arrTrails.length(); i++)
			LoadTrail(arrTrails[i]);
	}
}
