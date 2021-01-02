class SpawnTilesetEffect : IEffect, IAction
{
	string m_effectName;
	UnitScene@ m_effectFallback;

	SpawnTilesetEffect(UnitPtr unit, SValue& params)
	{
		m_effectName = GetParamString(unit, params, "name");
		@m_effectFallback = Resources::GetEffect(GetParamString(unit, params, "fallback"));
	}

	bool NeedNetParams() { return false; }
	void SetWeaponInformation(uint weapon) {}

	bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
	{
		Do(pos);
		return true;
	}

	bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
	{
		Do(pos);
		return true;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		Do(pos);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}

	void Do(vec2 pos)
	{
		array<Tileset@>@ tilesets = g_scene.FetchTilesets(pos);
		for (int i = tilesets.length() - 1; i >= 0; i--)
		{
			auto tsd = tilesets[i].GetData();
			if (tsd is null)
				continue;

			SValue@ svEffect = tsd.GetDictionaryEntry(m_effectName);
			if (svEffect is null || svEffect.GetType() != SValueType::String)
				continue;

			auto effect = Resources::GetEffect(svEffect.GetString());
			if (effect is null)
				break;

			PlayEffect(effect, pos);
			return;
		}
		PlayEffect(m_effectFallback, pos);
	}

	void Update(int dt, int cooldown)
	{
	}
}
