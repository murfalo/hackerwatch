namespace Skills
{
	class ManaShieldMod : Modifiers::Modifier
	{
		ManaShield@ m_skill;

		ManaShieldMod(ManaShield@ skill)
		{
			@m_skill = skill;
		}

		bool HasDamageTakenMul() override { return true; }
		float DamageTakenMul(PlayerBase@ player, DamageInfo &di) override
		{
			float maxMana = player.m_record.MaxMana() + player.m_record.GetModifiers().StatsAdd(player).y;
			int mana = int(player.m_record.mana * maxMana);
			int removed = int(min(mana * m_skill.m_shieldDmgPerMana, di.Damage * m_skill.m_shieldDistr));
			int manaCost = int(removed / m_skill.m_shieldDmgPerMana);
			if (manaCost == 0)
				return 1.0f;

			m_skill.m_manaShieldC = 500;
			if (!player.SpendCost(manaCost, 0, 0))
				return 1.0f; // shouldn't happen

			return 1.0f - (removed / float(di.Damage));
		}
	}

	class ManaShield : Skill
	{
		array<Modifiers::Modifier@> m_modifiers;

		float m_shieldDistr;
		float m_shieldDmgPerMana;

		int m_manaShieldC;

		UnitScene@ m_manaShieldFx;

		ManaShield(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_shieldDistr = GetParamFloat(unit, params, "shield-distr");
			m_shieldDmgPerMana = GetParamFloat(unit, params, "shield-dmg-per-mana");

			m_modifiers.insertLast(ManaShieldMod(this));

			@m_manaShieldFx = Resources::GetEffect("effects/players/magicshield.effect");
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}

		void RefreshScene(CustomUnitScene@ scene) override
		{
			if (m_manaShieldC > 0)
				scene.AddScene(m_manaShieldFx, 0, vec2(), 0, 0);
		}

		void Update(int dt, bool walking) override
		{
			if (m_manaShieldC > 0)
				m_manaShieldC -= dt;
		}
	}
}
