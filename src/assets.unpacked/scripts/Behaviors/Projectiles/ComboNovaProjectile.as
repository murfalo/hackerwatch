class ComboNovaProjectile : Projectile
{
	ComboNovaProjectile(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}

	void Initialize(Actor@ owner, vec2 dir, float intensity, bool husk, Actor@ target, uint weapon) override
	{
		Projectile::Initialize(owner, dir, intensity, husk, target, weapon);

		if (m_effectParams is null)
		{
			PrintError("Effect params in combo nova projectile is null!");
			return;
		}

		auto player = cast<PlayerBase>(owner);
		if (player is null)
			return;

		auto style = player.m_comboStyle;
		if (style is null)
			return;

		m_effectParams.Set("cR", style.m_color.x);
		m_effectParams.Set("cG", style.m_color.y);
		m_effectParams.Set("cB", style.m_color.z);
	}
}
