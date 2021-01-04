class RaiseMagicTiles : IAction
{
	UnitPtr m_unit;

	int m_count;
	int m_radius;
	int m_randomDelayMax;
	uint m_weaponInfo;

	RaiseMagicTiles(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_count = GetParamInt(unit, params, "count");
		m_radius = GetParamInt(unit, params, "radius");
		m_randomDelayMax = GetParamInt(unit, params, "random-max");
	}

	void SetWeaponInformation(uint weapon) 
	{ 
		m_weaponInfo = weapon;
	}
	
	void Update(int dt, int cooldown)
	{
	}

	bool NeedNetParams() { return true; }

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		array<UnitPtr> units = g_scene.FetchUnitsWithBehavior("MagicTile", xy(m_unit.GetPosition()), m_radius);
		int count = min(units.length(), m_count);

		builder.PushArray();

		for (int i = 0; i < count; i++)
		{
			int id = randi(units.length());
			int delay = randi(m_randomDelayMax);

			builder.PushInteger(units[id].GetId());
			builder.PushInteger(delay);

			MagicTile@ tile = cast<MagicTile>(units[id].GetScriptBehavior());
			tile.Activate(owner, null, delay, m_weaponInfo);

			units.removeAt(id);
		}

		builder.PopArray();

		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		array<SValue@>@ arr = param.GetArray();
		if (arr.length() % 2 != 0)
		{
			PrintError("Unevent number of elements: " + arr.length());
			return false;
		}

		for (uint i = 0; i < arr.length(); i += 2)
		{
			int id = arr[i].GetInteger();

			UnitPtr unit = g_scene.GetUnit(id);
			if (!unit.IsValid())
				continue;

			MagicTile@ tile = cast<MagicTile>(unit.GetScriptBehavior());
			if (tile is null)
			{
				PrintError("Unit " + id + " is not a MagicTile!");
				continue;
			}

			tile.Activate(owner, null, arr[i + 1].GetInteger(), m_weaponInfo);
		}

		return true;
	}
}
