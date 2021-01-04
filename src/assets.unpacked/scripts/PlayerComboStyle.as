class PlayerComboStyle : SVO
{
	string m_name;
	string m_description;

	bool m_owned;
	int m_legacyPoints;

	ScriptSprite@ m_sprite;

	UnitScene@ m_effect;
	array<UnitProducer@> m_projectiles;

	vec4 m_color;

	PlayerComboStyle(SValue& params)
	{
		super(params);

		m_name = GetParamString(UnitPtr(), params, "name");
		m_description = GetParamString(UnitPtr(), params, "description", false);

		m_owned = GetParamBool(UnitPtr(), params, "owned", false);
		m_legacyPoints = GetParamInt(UnitPtr(), params, "legacy-points", false);

		auto arrSprite = GetParamArray(UnitPtr(), params, "sprite");
		if (arrSprite !is null)
			@m_sprite = ScriptSprite(arrSprite);

		m_color = ParseColorRGBA(GetParamString(UnitPtr(), params, "color", false, "#FFFFFFFF"));

		@m_effect = Resources::GetEffect(GetParamString(UnitPtr(), params, "effect"));

		auto arrProjectiles = GetParamArray(UnitPtr(), params, "projectiles");
		for (uint i = 0; i < arrProjectiles.length(); i++)
		{
			string prodPath = arrProjectiles[i].GetString();
			auto prod = Resources::GetUnitProducer(prodPath);
			if (prod is null)
			{
				PrintError("Unable to find projectile unit for \"" + prodPath + "\"");
				return;
			}
			m_projectiles.insertLast(prod);
		}
	}

	void OnBegin(PlayerBase@ player)
	{
		UnitPtr fxUnit = PlayEffect(m_effect, player.m_unit, {
			{ "cR", m_color.x },
			{ "cG", m_color.y },
			{ "cB", m_color.z }
		});
		@player.m_fxCombo = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
		if (player.m_fxCombo !is null)
			player.m_fxCombo.m_looping = true;
	}

	void OnEnd(PlayerBase@ player)
	{
		if (player.m_fxCombo !is null)
			player.m_fxCombo.m_unit.Destroy();
	}
}
