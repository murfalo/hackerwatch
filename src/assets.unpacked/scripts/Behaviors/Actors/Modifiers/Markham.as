namespace Modifiers
{
	class Markham : Modifier
	{
		vec2 m_stats;
		vec2 m_damageMulAdd;
		vec2 m_power;
		vec2 m_armor;
		float m_oreScale;
		float m_goldScale;
		float m_skillMul;
		float m_attackMul;

		Markham(UnitPtr unit, SValue& params)
		{
			m_stats = vec2(
				GetParamFloat(unit, params, "health", false, 0),
				GetParamFloat(unit, params, "mana", false, 0)
			);

			m_damageMulAdd = vec2(
				GetParamFloat(unit, params, "attack-mul-add", false, 0),
				GetParamFloat(unit, params, "spell-mul-add", false, 0)
			);

			m_power = vec2(
				GetParamFloat(unit, params, "attack-power", false, 0),
				GetParamFloat(unit, params, "spell-power", false, 0)
			);

			m_armor = vec2(
				GetParamFloat(unit, params, "armor", false, 0),
				GetParamFloat(unit, params, "resistance", false, 0)
			);

			m_oreScale = GetParamFloat(unit, params, "ore-scale", false, 0);
			m_goldScale = GetParamFloat(unit, params, "gold-scale", false, 0);
			m_skillMul = GetParamFloat(unit, params, "skill-mul", false, 0);
			m_attackMul = GetParamFloat(unit, params, "attack-mul", false, 0);
		}

		bool HasStatsAdd() override { return true; }
		bool HasDamageMul() override { return true; }
		bool HasDamagePower() override { return true; }
		bool HasArmorAdd() override { return true; }

		bool HasOreGainScale() override { return true; }
		bool HasGoldGainScale() override { return true; }
		bool HasSkillTimeMul() override { return true; }
		bool HasAttackTimeMul() override { return true; }


		ivec2 StatsAdd(PlayerBase@ player) override { return ToIVec(m_stats * GetNumItems(player)); }
		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override { return vec2(1.0f, 1.0f) + m_damageMulAdd * float(player.m_markhamComboCount); }
		ivec2 DamagePower(PlayerBase@ player, Actor@ enemy) override { return ToIVec(m_power * GetNumItems(player)); }
		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override { return m_armor * GetNumItems(player); }

		float OreGainScale(PlayerBase@ player) override { return 1 + m_oreScale * GetNumItems(player); }
		float GoldGainScale(PlayerBase@ player) override { return 1 + m_goldScale * GetNumItems(player); }
		float SkillTimeMul(PlayerBase@ player) override { return 1 + m_skillMul * GetNumItems(player); }
		float AttackTimeMul(PlayerBase@ player) override { return 1 + m_attackMul * GetNumItems(player); }

		int GetNumItems(PlayerBase@ player) { return player.m_record.items.length(); }
		ivec2 ToIVec(vec2 v) { return ivec2(int(v.x), int(v.y)); }
	}
}
