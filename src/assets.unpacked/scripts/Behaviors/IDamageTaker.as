enum DamageType
{
	//HEAL		=   0,
	TRAP 		=   1,
	PIERCING 	=   2,
	BLUNT		=   4,
	EXPLOSION	=   8,
	BIO			=  16,
	FIRE		=  32,
	ENERGY		=  64,
	FROST		= 128,
}

class CleaveInfo
{
	int16 Range;
	
	float PhysicalDamageMul;
	int32 PhysicalDamageAdd;
	float MagicalDamageMul;
	int32 MagicalDamageAdd;
	
	UnitScene@ Effect;
}

CleaveInfo@ LoadCleave(SValue& dat, string prefix = "")
{
	SValue@ params = GetParamDictionary(UnitPtr(), dat, prefix + "cleave", false);
	if (params is null)
		return null;

	CleaveInfo cleave;
	
	cleave.Range = GetParamInt(UnitPtr(), params, "range");
	
	cleave.PhysicalDamageAdd = GetParamInt(UnitPtr(), params, "physical", false, 0);
	cleave.PhysicalDamageMul = GetParamFloat(UnitPtr(), params, "physical-mul", false, 0);
	cleave.MagicalDamageAdd = GetParamInt(UnitPtr(), params, "magical", false, 0);
	cleave.MagicalDamageMul = GetParamFloat(UnitPtr(), params, "magical-mul", false, 0);
	
	string fx = GetParamString(UnitPtr(), params, "fx", false);
	if (fx != "")
		@cleave.Effect = Resources::GetEffect(fx);

	return cleave;
}

class DamageInfo
{
	uint8 DamageType;
	int32 Damage;
	
	Actor@ Attacker;
	int32 PhysicalDamage;
	int32 MagicalDamage;
	int32 DamageDealt;
	bool Melee;
	bool CanKill;
	uint Weapon;
	int Crit;
	vec2 ArmorMul;
	float LifestealMul;
	bool TrueStrike;
	CleaveInfo@ Cleave;
	
	DamageInfo()
	{
		DamageType = uint8(DamageType::PIERCING);
		@Attacker = null;
		CanKill = true;
		Crit = 0;
		ArmorMul = vec2(1, 1);
		LifestealMul = 1;
		TrueStrike = false;
	}

	DamageInfo(uint8 dmgType, Actor@ attacker, int16 dmg, bool melee, bool canKill, uint weapon)
	{
		DamageType = dmgType;
		@Attacker = attacker;
		PhysicalDamage = dmg;
		Melee = melee;
		CanKill = canKill;
		Weapon = weapon;
		Crit = 0;
		ArmorMul = vec2(1, 1);
		LifestealMul = 1;
	}
	
	
	DamageInfo(Actor@ attacker, int32 physDmg, int magicDmg, bool melee, bool canKill, uint weapon)
	{
		DamageType = DamageType::TRAP;
		Damage = physDmg + magicDmg;
		
		@Attacker = attacker;
		PhysicalDamage = physDmg;
		MagicalDamage = magicDmg;
		Melee = melee;
		CanKill = canKill;
		Weapon = weapon;
		Crit = 0;
		ArmorMul = vec2(1, 1);
		LifestealMul = 1;
	}
}

uint8 GetParamDamageType(UnitPtr owner, SValue@ params, string name, bool required = true, uint8 def = uint8(DamageType::PIERCING))
{
	string dt = GetParamString(owner, params, name, required, "");
	if (dt == "")
		return def;

	uint8 ret = 0;
		
	auto dts = dt.split(" ");
	for (uint i = 0; i < dts.length(); i++)
	{
		if (dts[i] == "heal")
			return 0;
		else if (dts[i] == "trap")
			ret |= uint8(DamageType::TRAP);
		else if (dts[i] == "pierce")
			ret |= uint8(DamageType::PIERCING);
		else if (dts[i] == "piercing")
			ret |= uint8(DamageType::PIERCING);
		else if (dts[i] == "blunt")
			ret |= uint8(DamageType::BLUNT);
		else if (dts[i] == "explosion")
			ret |= uint8(DamageType::EXPLOSION);
		else if (dts[i] == "bio")
			ret |= uint8(DamageType::BIO);
		else if (dts[i] == "fire")
			ret |= uint8(DamageType::FIRE);
		else if (dts[i] == "energy")
			ret |= uint8(DamageType::ENERGY);
		else if (dts[i] == "frost")
			ret |= uint8(DamageType::FROST);
		else
			print("Damage type not found: " + dts[i]);
	}
	
	return ret;
}


class DecimateInfo
{
	Actor@ Attacker;
	uint Weapon;
	
	float HealthCurr;
	float HealthMax;
	float ManaCurr;
	float ManaMax;
	
	DecimateInfo(Actor@ attacker, float hpCurr, float hpMax, float manaCurr, float manaMax, uint weapon)
	{
		@Attacker = attacker;
		Weapon = weapon;
		HealthCurr = hpCurr;
		HealthMax = hpMax;
		ManaCurr = manaCurr;
		ManaMax = manaMax;
	}
}

interface IDamageTaker
{
	int Decimate(DecimateInfo dec, vec2 pos, vec2 dir);
	void NetDecimate(int hp, int mana);
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir);
	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir);
	bool Impenetrable();
	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir);
	bool IsDead();
	bool Ricochets();
}

class ADamageTaker : IDamageTaker
{
	int Decimate(DecimateInfo dec, vec2 pos, vec2 dir) override { return 0; }
	void NetDecimate(int hp, int mana) override {}
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override { return 0; }
	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override {}
	bool Impenetrable() override { return false; }
	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override { return false; }
	bool IsDead() override { return false; }
	bool Ricochets() override { return true; }
}