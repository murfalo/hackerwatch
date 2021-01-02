namespace Skills
{
	class ArenaMastery : Skill
	{
		int m_extraProjectiles;
		int m_extraSecutor;

		ArenaMastery(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_extraProjectiles = GetParamInt(unit, params, "extra-projectiles");
			m_extraSecutor = GetParamInt(unit, params, "extra-secutor");
		}

		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			auto player = cast<PlayerBase>(owner);
			if (player !is null)
			{
				// Net
				auto skillFanChargeUnit = cast<FanChargeUnit>(player.m_skills[1]);
				if (skillFanChargeUnit !is null)
					skillFanChargeUnit.m_numProjectiles = 1 + m_extraProjectiles;

				// Gladius
				auto skillShootProjectile = cast<ShootProjectile>(player.m_skills[2]);
				if (skillShootProjectile !is null)
					skillShootProjectile.m_projectiles = 1 + m_extraProjectiles;

				// Summon Secutors
				auto skillSummonSecutors = cast<StaggeredSpawnUnits>(player.m_skills[3]);
				if (skillSummonSecutors !is null)
				{
					if (skillSummonSecutors.m_positions.length() > 3)
						skillSummonSecutors.m_positions.removeRange(3, skillSummonSecutors.m_positions.length() - 3);

					float d = length(skillSummonSecutors.m_positions[0]);
					for (int i = 0; i < m_extraSecutor; i++)
					{
						float angle = randf() * (PI * 2);
						vec2 pos = vec2(cos(angle), sin(angle)) * d;
						skillSummonSecutors.m_positions.insertLast(d);
					}
				}
			}

			Skill::Initialize(owner, icon, id);
		}
	}
}
