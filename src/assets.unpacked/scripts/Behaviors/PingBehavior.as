class PingBehavior
{
	UnitPtr m_unit;

	EffectBehavior@ m_effect;
	MinimapSprite@ m_minimapSprite;

	PlayerRecord@ m_owner;

	PingBehavior(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		UnitScene@ fx = Resources::GetEffect(GetParamString(unit, params, "effect"));
		if (fx is null)
		{
			PrintError("Couldn't find ping effect!");
			return;
		}

		UnitPtr fxUnit = g_effectUnit.Produce(g_scene, m_unit.GetPosition());
		auto eb = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
		eb.Initialize(fx, dictionary());
		eb.m_ttl = fx.Length();
		@m_effect = eb;

		auto scene = m_unit.GetCurrentUnitScene();
		@m_minimapSprite = scene.GetMinimapSprite();
	}

	void Update(int dt)
	{
		vec4 color = ParseColorRGBA("#" + GetPlayerColor(m_owner.peer) + "ff");

		m_effect.SetParam("colorr", color.x);
		m_effect.SetParam("colorg", color.y);
		m_effect.SetParam("colorb", color.z);

		if (m_minimapSprite !is null)
			m_minimapSprite.SetColor(color);
		else
			print("m_minimapSprite is null");

		if (m_effect.m_unit.IsDestroyed())
			m_unit.Destroy();
	}

	void Destroyed()
	{
		if (m_owner is null)
			return;

		m_owner.pingCount--;
	}
}
