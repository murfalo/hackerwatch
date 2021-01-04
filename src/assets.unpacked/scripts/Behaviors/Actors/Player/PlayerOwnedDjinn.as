class PlayerOwnedDjinn : PlayerOwnedActor
{
	PlayerOwnedDjinn(UnitPtr unit, SValue& params)
	{
		super(unit, params);
	}

	DamageInfo DamageActor(Actor@ actor, DamageInfo di) override
	{
		int level = m_ownerRecord.ngps["pop"];

		float dmgMul = 1.0f + (0.2f * level);

		di.PhysicalDamage = int(di.PhysicalDamage * dmgMul);
		di.MagicalDamage = int(di.MagicalDamage * dmgMul);

		return PlayerOwnedActor::DamageActor(actor, di);
	}

	void Initialize(Actor@ owner, float intensity, bool husk, uint weaponInfo = 0) override
	{
		PlayerOwnedActor::Initialize(owner, intensity, husk, weaponInfo);

		int level = m_ownerRecord.ngps["pop"];

		m_ttl += 2000 * level;

		auto color = xyz(ParseColorRGBA("#" + GetPlayerColor(m_ownerRecord.peer) + "ff"));
		m_unit.SetMultiColor(0, xyzw(color * 0.1, 1), xyzw(color * 0.5, 1), xyzw(color * 2, 1));
	}
}
