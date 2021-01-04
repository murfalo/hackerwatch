namespace Pets
{
	class FlagRequirement
	{
		string m_flag;
		string m_text;

		FlagRequirement(SValue@ sv)
		{
			m_flag = GetParamString(UnitPtr(), sv, "flag");
			m_text = GetParamString(UnitPtr(), sv, "text");
		}
	}

	class PetDef
	{
		uint m_idHash;
		string m_id;

		string m_name;
		string m_description;

		int m_cost;

		string m_requiredClass;
		array<string> m_requiredDlcs;
		array<FlagRequirement@> m_requiredFlags;

		array<PetSkin@> m_skins;
		array<PetFlag@> m_flags;

		PetDef(SValue@ sv)
		{
			m_id = GetParamString(UnitPtr(), sv, "id");
			m_idHash = HashString(m_id);

			m_name = GetParamString(UnitPtr(), sv, "name");
			m_description = GetParamString(UnitPtr(), sv, "description", false);

			m_cost = GetParamInt(UnitPtr(), sv, "cost", false);

			m_requiredClass = GetParamString(UnitPtr(), sv, "required-class", false);

			auto arrRequiredDlcs = GetParamArray(UnitPtr(), sv, "required-dlcs", false);
			if (arrRequiredDlcs !is null)
			{
				for (uint i = 0; i < arrRequiredDlcs.length(); i++)
					m_requiredDlcs.insertLast(arrRequiredDlcs[i].GetString());
			}

			auto arrRequiredFlags = GetParamArray(UnitPtr(), sv, "required-flags", false);
			if (arrRequiredFlags !is null)
			{
				for (uint i = 0; i < arrRequiredFlags.length(); i++)
				{
					auto svRequiredFlag = arrRequiredFlags[i];
					m_requiredFlags.insertLast(FlagRequirement(svRequiredFlag));
				}
			}

			auto arrSkins = GetParamArray(UnitPtr(), sv, "skins");
			for (uint i = 0; i < arrSkins.length(); i++)
				m_skins.insertLast(PetSkin(arrSkins[i]));

			auto arrFlags = GetParamArray(UnitPtr(), sv, "flags", false);
			if (arrFlags !is null)
			{
				for (uint i = 0; i < arrFlags.length(); i++)
					m_flags.insertLast(PetFlag(arrFlags[i]));
			}
		}

		ScriptSprite@ GetIcon()
		{
			return m_skins[0].m_icon;
		}

		PetFlag@ GetFlag(uint id)
		{
			for (uint i = 0; i < m_flags.length(); i++)
			{
				auto flag = m_flags[i];
				if (flag.m_idHash == id)
					return flag;
			}
			return null;
		}

		PetFlag@ GetFlag(const string &in id)
		{
			return GetFlag(HashString(id));
		}

		bool HasLegacySkins()
		{
			for (int i = int(m_skins.length() - 1); i >= 0; i--)
			{
				if (m_skins[i].m_legacyPoints > 0)
					return true;
			}
			return false;
		}
	}
}
