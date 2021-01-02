class DungeonPropertiesLevel
{
	string m_filename;
	int m_act;
	int m_level;

	string m_theme;
	int m_width;
	int m_height;

	string m_startId;

	DungeonPropertiesLevel(SValue@ sval)
	{
		if (sval.GetType() == SValueType::Array)
		{
			auto arr = sval.GetArray();

			m_filename = arr[0].GetString();
			m_act = arr[1].GetInteger();
			m_level = arr[2].GetInteger();

			if (arr.length() >= 4) m_theme = arr[3].GetString();
			if (arr.length() >= 5) m_width = arr[4].GetInteger();
			if (arr.length() >= 6) m_height = arr[5].GetInteger();
		}
		else if (sval.GetType() == SValueType::Dictionary)
		{
			m_filename = GetParamString(UnitPtr(), sval, "filename");
			m_act = GetParamInt(UnitPtr(), sval, "act");
			m_level = GetParamInt(UnitPtr(), sval, "level");

			m_theme = GetParamString(UnitPtr(), sval, "theme", false);
			m_width = GetParamInt(UnitPtr(), sval, "width", false);
			m_height = GetParamInt(UnitPtr(), sval, "height", false);

			m_startId = GetParamString(UnitPtr(), sval, "start-id", false);
		}
	}
}

class DungeonProperties : SVO
{
	string m_name;

	array<DungeonPropertiesLevel@> m_levels;

	array<string> m_areaNames;
	array<string> m_actNames;

	string m_statusPrefix;
	string m_discordState;
	array<string> m_discordActImages;

	string m_townSpawn;

	array<string> m_flags;

	string m_dlcReq;

	string m_strCharInfoNgp;
	string m_strNotifyCharNgp;

	int m_mercenaryInsuranceCost;
	int m_mercenaryInsuranceCostPerNG;

	DungeonProperties(SValue& sv)
	{
		super(sv);

		if (sv.GetType() != SValueType::Dictionary)
		{
			PrintError("Dungeon properties must be a dictionary!");
			return;
		}

		m_name = GetParamString(UnitPtr(), sv, "name");

		auto arrAreaNames = GetParamArray(UnitPtr(), sv, "area-names", false);
		if (arrAreaNames !is null)
		{
			for (uint i = 0; i < arrAreaNames.length(); i++)
				m_areaNames.insertLast(arrAreaNames[i].GetString());
		}

		auto arrActNames = GetParamArray(UnitPtr(), sv, "act-names", false);
		if (arrActNames !is null)
		{
			for (uint i = 0; i < arrActNames.length(); i++)
				m_actNames.insertLast(arrActNames[i].GetString());
		}

		m_statusPrefix = GetParamString(UnitPtr(), sv, "status-prefix", false);
		m_discordState = GetParamString(UnitPtr(), sv, "discord-state", false);

		auto arrDiscordActImages = GetParamArray(UnitPtr(), sv, "discord-act-images", false);
		if (arrDiscordActImages !is null)
		{
			for (uint i = 0; i < arrDiscordActImages.length(); i++)
				m_discordActImages.insertLast(arrDiscordActImages[i].GetString());
		}

		m_townSpawn = GetParamString(UnitPtr(), sv, "town-spawn", false);

		auto arrFlags = GetParamArray(UnitPtr(), sv, "flags", false);
		if (arrFlags !is null)
		{
			for (uint i = 0; i < arrFlags.length(); i++)
				m_flags.insertLast(arrFlags[i].GetString());
		}

		m_dlcReq = GetParamString(UnitPtr(), sv, "dlc-req", false);

		auto arrLevels = GetParamArray(UnitPtr(), sv, "levels", false);
		if (arrLevels !is null)
		{
			for (uint i = 0; i < arrLevels.length(); i++)
			{
				auto level = DungeonPropertiesLevel(arrLevels[i]);
				m_levels.insertLast(level);
			}
		}

		m_strCharInfoNgp = GetParamString(UnitPtr(), sv, "str-char-info-ngp", false);
		m_strNotifyCharNgp = GetParamString(UnitPtr(), sv, "str-notify-char-ngp", false);

		m_mercenaryInsuranceCost = GetParamInt(UnitPtr(), sv, "mercenary-insurance-cost", false, 5000);
		m_mercenaryInsuranceCostPerNG = GetParamInt(UnitPtr(), sv, "mercenary-insurance-cost-per-ng", false, 5000);
	}

	void OnEndOfGame()
	{
		auto record = GetLocalPlayerRecord();
		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_townLocal;

		int highestTownNgp = town.m_highestNgps.GetHighest();
		int currentNgp = int(float(g_ngp));

		auto ngp = record.ngps.Get(m_idHash, true);
		if (ngp.m_ngp <= currentNgp)
		{
%if HARDCORE
			//ngp.m_ngp++;
			ngp.m_ngp = min(record.ngps.GetHighest(), currentNgp) + 1;
%else
			ngp.m_ngp = min(highestTownNgp, currentNgp) + 1;
%endif
		}

		auto highestNgp = town.m_highestNgps.Get(m_idHash, true);
		if (highestNgp.m_ngp < ngp.m_ngp)
		{
			highestNgp.m_ngp = ngp.m_ngp;
			town.m_currentNgp = ngp.m_ngp;
		}
	}

	DungeonPropertiesLevel@ GetLevel(int index)
	{
		if (index < 0 || index >= int(m_levels.length()))
			return null;
		return m_levels[index];
	}

	int GetNextActIndex(int index)
	{
		auto level = GetLevel(index);
		if (level is null)
			return -1;

		for (uint i = index; i < m_levels.length(); i++)
		{
			if (m_levels[i].m_act != level.m_act)
				return i;
		}
		return -1;
	}

	string GetAreaName(DungeonPropertiesLevel@ level)
	{
		if (level.m_act < int(m_areaNames.length()))
			return Resources::GetString(m_areaNames[level.m_act]);

		return "";
	}

	string GetActName(DungeonPropertiesLevel@ level, bool useFallbackLanguage = false)
	{
		if (level.m_act < int(m_actNames.length()))
			return Resources::GetString(m_actNames[level.m_act], useFallbackLanguage);

		return Resources::GetString(".world.act", {
			{ "num", level.m_act + 1 }
		}, useFallbackLanguage);
	}

	string GetFloorName(DungeonPropertiesLevel@ level)
	{
		return Resources::GetString(".world.floor", {
			{ "num", level.m_level + 1 }
		});
	}

	string GetDiscordActImage(DungeonPropertiesLevel@ level)
	{
		if (level.m_act < int(m_discordActImages.length()))
			return m_discordActImages[level.m_act];
		return "act_" + level.m_act;
	}

	bool ShouldExploreMinimap() { return true; }
}
