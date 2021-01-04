namespace Pets
{
	array<PetDef@> g_defs;
	array<PetFlag@> g_flags;

	void LoadPets(SValue@ sv)
	{
		auto arrPets = sv.GetArray();
		for (uint i = 0; i < arrPets.length(); i++)
		{
			auto svPet = arrPets[i];
			g_defs.insertLast(PetDef(svPet));
		}
	}

	void LoadPetFlags(SValue@ sv)
	{
		auto arrFlags = sv.GetArray();
		for (uint i = 0; i < arrFlags.length(); i++)
		{
			auto svFlag = arrFlags[i];
			g_flags.insertLast(PetFlag(svFlag));
		}
	}

	PetDef@ GetDef(uint id)
	{
		for (uint i = 0; i < g_defs.length(); i++)
		{
			auto def = g_defs[i];
			if (def.m_idHash == id)
				return def;
		}
		return null;
	}

	PetDef@ GetDef(const string &in id)
	{
		return GetDef(HashString(id));
	}
}
