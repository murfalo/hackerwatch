namespace Skills
{
	class ExtendedDomain : Skill
	{
		array<Modifiers::Modifier@> m_modifiers;

		float m_rangeMul;

		ExtendedDomain(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_modifiers = Modifiers::LoadModifiers(unit, params);

			m_rangeMul = GetParamFloat(unit, params, "range-mul", false, 1.0f);
		}

		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			auto player = cast<PlayerBase>(owner);
			if (player !is null)
			{
				for (uint i = 0; i < player.m_skills.length(); i++)
				{
					auto skill = player.m_skills[i];

					auto skillMeleeSwing = cast<Skills::MeleeSwing>(skill);
					if (skillMeleeSwing !is null)
						skillMeleeSwing.m_distMul = m_rangeMul;

					auto skillShootProjectile = cast<Skills::ShootProjectile>(skill);
					if (skillShootProjectile !is null)
						skillShootProjectile.m_rangeMul = m_rangeMul;

					auto skillDropUnit = cast<Skills::DropUnitWarlock>(skill);
					if (skillDropUnit !is null)
						skillDropUnit.m_rangeMul = m_rangeMul;
				}
			}

			Skill::Initialize(owner, icon, id);
		}

		array<Modifiers::Modifier@>@ GetModifiers() override { return m_modifiers; }
	}
}
