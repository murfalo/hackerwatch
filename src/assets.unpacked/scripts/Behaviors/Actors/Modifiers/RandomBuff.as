namespace Modifiers
{
	class RandomBuff : Modifier
	{
		float m_hpAdd;
		vec2 m_armorAdd;
		float m_expScale;
		float m_goldScale;
		float m_oreScale; 
		vec2 m_regenAdd;
		float m_dmgScale;
	
		RandomBuff(int positive, int negative)
		{
			m_hpAdd = (GetRandomBuffAmount(positive, MoreHp) - GetRandomBuffAmount(negative, LowerHp)) / 100.0f;
			m_armorAdd = vec2(GetRandomBuffAmount(positive, MoreArmor)) - vec2(GetRandomBuffAmount(negative, LowerArmor), GetRandomBuffAmount(negative, LowerResistance));
			m_expScale = 1.f + (GetRandomBuffAmount(positive, MoreExperience) - GetRandomBuffAmount(negative, NoExperience)) / 100.0f;
			m_goldScale = 1.f + (GetRandomBuffAmount(positive, MoreGold) - GetRandomBuffAmount(negative, NoGoldGain)) / 100.0f;
			m_oreScale = 1.f + GetRandomBuffAmount(positive, MoreOre) / 100.0f;
			m_regenAdd = vec2(GetRandomBuffAmount(positive, MoreHPRegen), GetRandomBuffAmount(positive, MoreMPRegen)) - vec2(GetRandomBuffAmount(negative, LowerHPRegen), GetRandomBuffAmount(negative, LowerMPRegen));
			m_dmgScale = 1.f + (GetRandomBuffAmount(positive, MoreDamage) - GetRandomBuffAmount(negative, LowerDamage)) / 100.0f;
		}
		
		bool HasStatsAdd() override { return true; }
		bool HasArmorAdd() override { return true; }
		bool HasExpMul() override { return true; }
		bool HasGoldGainScale() override { return true; }
		bool HasOreGainScale() override { return true; }
		bool HasRegenAdd() override { return true; }
		bool HasDamageMul() override { return true; }

		ivec2 StatsAdd(PlayerBase@ player) override { return ivec2(int(player.m_record.MaxHealth() * m_hpAdd), 0); }
		vec2 ArmorAdd(PlayerBase@ player, Actor@ enemy) override { return m_armorAdd; }
		float ExpMul(PlayerBase@ player, Actor@ enemy) override { return m_expScale; }
		float GoldGainScale(PlayerBase@ player) override { return m_goldScale; }
		float OreGainScale(PlayerBase@ player) override { return m_oreScale; }
		vec2 RegenAdd(PlayerBase@ player) override { return m_regenAdd; }
		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override { return vec2(m_dmgScale); }
	}
}

int GetRandomBuffAmount(int val, RandomBuffPositive comp)
{
	if ((val & comp) == 0)
		return 0;
	return GetRandomBuffAmount(comp);
}

int GetRandomBuffAmount(int val, RandomBuffNegative comp)
{
	if ((val & comp) == 0)
		return 0;
	return GetRandomBuffAmount(comp);
}

enum RandomBuffNegative
{
	None 			=   0,
	LowerHp 		=   1,
	LowerArmor 		=   2,
	LowerResistance	=   4,
	NoExperience	=   8,
	NoGoldGain		=  16,
	LowerHPRegen	=  32,
	LowerMPRegen	=  64,
	TakeDamage		= 128,
	LowerDamage		= 256
}

enum RandomBuffPositive
{
	None 			=   0,
	MoreHp			=   1,
	MoreArmor 		=   2,
	MoreExperience	=   4,
	MoreGold		=   8,
	MoreOre			=  16,
	MoreHPRegen		=  32,
	MoreMPRegen		=  64,
	MoreDamage		= 128
}

int GetRandomBuffAmount(RandomBuffNegative neg)
{
	switch(neg)
	{
	case RandomBuffNegative::LowerHp:
		return 50;
	case RandomBuffNegative::LowerArmor:
		return 15;
	case RandomBuffNegative::LowerResistance:
		return 15;
	case RandomBuffNegative::NoExperience:
		return 75;
	case RandomBuffNegative::NoGoldGain:
		return 75;
	case RandomBuffNegative::LowerHPRegen:
		return 1;
	case RandomBuffNegative::LowerMPRegen:
		return 2;
	case RandomBuffNegative::TakeDamage:
		return 150;
	case RandomBuffNegative::LowerDamage:
		return 15;
	}
	return 0;
}

int GetRandomBuffAmount(RandomBuffPositive pos)
{
	switch(pos)
	{
	case RandomBuffPositive::MoreHp:
		return 150;
	case RandomBuffPositive::MoreArmor:
		return 15;
	case RandomBuffPositive::MoreExperience:
		return 200;
	case RandomBuffPositive::MoreGold:
		return 150;
	case RandomBuffPositive::MoreOre:
		return 100;
	case RandomBuffPositive::MoreHPRegen:
		return 3;
	case RandomBuffPositive::MoreMPRegen:
		return 4;
	case RandomBuffPositive::MoreDamage:
		return 25;
	}
	return 0;
}