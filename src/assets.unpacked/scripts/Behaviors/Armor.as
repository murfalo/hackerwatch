float CalcArmor(float armor)
{
	float a = armor * 0.02;
	return 1.0f - a / (1.0f + max(0.0f, a));
}

vec2 ApplyArmorParts(DamageInfo dmg, vec2 armor, float damageMul)
{
	float physDmg = CalcArmor(armor.x) * damageMul * dmg.PhysicalDamage;
	float magicDmg = CalcArmor(armor.y) * damageMul * dmg.MagicalDamage;

	return vec2(physDmg, magicDmg);
}

int ApplyArmor(DamageInfo dmg, vec2 armor, float damageMul)
{
	if (dmg.DamageType == 0)
		return -dmg.PhysicalDamage;

	vec2 ret = ApplyArmorParts(dmg, armor, damageMul);

	return max(0, damage_round(ret.x + ret.y));
}


class ArmorDef
{
	uint m_pathHash;

	SoundEvent@ m_sound;

	float m_mulTrap;
	float m_mulPierce;
	float m_mulBlunt;
	float m_mulExplosion;
	float m_mulBio;
	float m_mulFire;
	float m_mulEnergy;
	float m_mulFrost;
	
	ArmorDef(uint pathHash, SValue& params)
	{
		m_pathHash = pathHash;

		@m_sound = Resources::GetSoundEvent(GetParamString(UnitPtr(), params, "sound", false));

		m_mulTrap = GetParamFloat(UnitPtr(), params, "trap", false, 1.0);
		m_mulPierce = GetParamFloat(UnitPtr(), params, "pierce", false, 1.0) * GetParamFloat(UnitPtr(), params, "piercing", false, 1.0);
		m_mulBlunt = GetParamFloat(UnitPtr(), params, "blunt", false, 1.0);
		m_mulExplosion = GetParamFloat(UnitPtr(), params, "explosion", false, 1.0);
		m_mulBio = GetParamFloat(UnitPtr(), params, "bio", false, 1.0);
		m_mulFire = GetParamFloat(UnitPtr(), params, "fire", false, 1.0);
		m_mulEnergy = GetParamFloat(UnitPtr(), params, "energy", false, 1.0);
		m_mulFrost = GetParamFloat(UnitPtr(), params, "frost", false, 1.0);
	}
}

bool BlockBuff(ActorBuff@ buff, ArmorDef@ armor, int armorAmnt)
{
	if (armorAmnt <= 0)
		return false;

	auto dmgType = buff.m_def.m_buffDmgType;
	if (dmgType == 0)
		return false;
	
	if (armor !is null)
	{
		float dmgMul = 0;
		if (dmgType & uint8(DamageType::TRAP) != 0) 		{ dmgMul += armor.m_mulTrap; }
		if (dmgType & uint8(DamageType::PIERCING) != 0) 	{ dmgMul += armor.m_mulPierce; }
		if (dmgType & uint8(DamageType::BLUNT) != 0) 		{ dmgMul += armor.m_mulBlunt; }
		if (dmgType & uint8(DamageType::EXPLOSION) != 0)	{ dmgMul += armor.m_mulExplosion; }
		if (dmgType & uint8(DamageType::BIO) != 0) 			{ dmgMul += armor.m_mulBio; }
		if (dmgType & uint8(DamageType::FIRE) != 0) 		{ dmgMul += armor.m_mulFire; }
		if (dmgType & uint8(DamageType::ENERGY) != 0) 		{ dmgMul += armor.m_mulEnergy; }
		if (dmgType & uint8(DamageType::FROST) != 0) 		{ dmgMul += armor.m_mulFrost; }

		if (dmgMul <= 0)
			return true;
	}
	
	return false;
}

int damage_round(float f)
{	
	if (f == 0)
		return 0;

	int i;
	if (f < 0)
		i = int(f - 0.5f);
	else
		i = int(f + 0.5f);
	
	if (f > 0.01 && f < 1)
		i = 1;
	else if (f < 0.01 && f > -1)
		i = -1;

	return i;
}

int armor_round(float f)
{
	int i = int(f + 0.5f);
	if (i == 0)
	{
		if (f > 0)
			return 1;
		if (f < 0)
			return -1;
	}

	return i;
}

int ApplyArmor(ArmorDef@ armor, DamageInfo dmg, int armorIn, int &out armorOut, float damageMul = 1.0f, vec3 pos = vec3())
{
	armorOut = armorIn;
	
	if (dmg.DamageType == 0)
		return -dmg.Damage;

	float incDmg = dmg.Damage * damageMul;
	if (armorIn <= 0)
		return armor_round(incDmg);
		
	float dmgMul = 0;
	if (armor !is null)
	{
		int dmgTypeNum = 0;

		if (dmg.DamageType & uint8(DamageType::TRAP) != 0) 		{ dmgTypeNum++; dmgMul += armor.m_mulTrap; }
		if (dmg.DamageType & uint8(DamageType::PIERCING) != 0) 	{ dmgTypeNum++; dmgMul += armor.m_mulPierce; }
		if (dmg.DamageType & uint8(DamageType::BLUNT) != 0) 	{ dmgTypeNum++; dmgMul += armor.m_mulBlunt; }
		if (dmg.DamageType & uint8(DamageType::EXPLOSION) != 0)	{ dmgTypeNum++; dmgMul += armor.m_mulExplosion; }
		if (dmg.DamageType & uint8(DamageType::BIO) != 0) 		{ dmgTypeNum++; dmgMul += armor.m_mulBio; }
		if (dmg.DamageType & uint8(DamageType::FIRE) != 0) 		{ dmgTypeNum++; dmgMul += armor.m_mulFire; }
		if (dmg.DamageType & uint8(DamageType::ENERGY) != 0) 	{ dmgTypeNum++; dmgMul += armor.m_mulEnergy; }
		if (dmg.DamageType & uint8(DamageType::FROST) != 0) 	{ dmgTypeNum++; dmgMul += armor.m_mulFrost; }

		dmgMul /= dmgTypeNum;
		
		if (armor.m_sound !is null)
			PlaySound3D(armor.m_sound, pos, { { "dmg-mul", dmgMul } });
	}
	else
		dmgMul = 1.0;
		
	float res = incDmg * dmgMul;
	float diff = abs(incDmg - res);
	
	if (diff == 0)
		return armor_round(incDmg);

	int finalDmg = int(lerp(incDmg, res, min(1.0f, armorIn / diff)) + 0.5f);
	armorOut = max(0, armorIn - (max(0, int(incDmg) - finalDmg)));
	return finalDmg;
}



array<ArmorDef@> g_armorDefs;

ArmorDef@ LoadArmorDef(string path)
{
	if (path == "")
		return null;
		
	return LoadArmorDef(HashString(path));
}

ArmorDef@ LoadArmorDef(uint pathHash)
{
	for (uint i = 0; i < g_armorDefs.length(); i++)
		if (g_armorDefs[i].m_pathHash == pathHash)
			return g_armorDefs[i];
	
	SValue@ armor = Resources::GetSValue(pathHash);
	if (armor is null)
		return null;
	
	auto ret = ArmorDef(pathHash, armor);
	g_armorDefs.insertLast(@ret);
	return ret;
}