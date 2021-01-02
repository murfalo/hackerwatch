namespace Currency
{
	bool CanAfford(int gold, int ore = 0) { return CanAfford(GetLocalPlayerRecord(), gold, ore); }
	bool CanAfford(PlayerRecord@ record, int gold, int ore = 0)
	{
		if (g_isTown)
		{
%if HARDCORE
			if (gold > record.mercenaryGold) return false;
			if (ore > record.mercenaryOre) return false;
%else
			auto gm = cast<Campaign>(g_gameMode);
			if (gold > gm.m_townLocal.m_gold) return false;
			if (ore > gm.m_townLocal.m_ore) return false;
%endif
		}
		else
		{
			if (gold > record.runGold) return false;
			if (ore > record.runOre) return false;
		}
		return true;
	}

	void Spend(int gold, int ore = 0) { Spend(GetLocalPlayerRecord(), gold, ore); }
	void Spend(PlayerRecord@ record, int gold, int ore = 0)
	{
		if (g_isTown)
		{
%if HARDCORE
			record.mercenaryGold -= gold;
			record.mercenaryOre -= ore;
%else
			auto gm = cast<Campaign>(g_gameMode);
			gm.m_townLocal.m_gold -= gold;
			gm.m_townLocal.m_ore -= ore;
%endif
		}
		else
		{
			record.runGold -= gold;
			record.runOre -= ore;
		}
	}

	void Give(int gold, int ore = 0) { Give(GetLocalPlayerRecord(), gold, ore); }
	void Give(PlayerRecord@ record, int gold, int ore = 0)
	{
		if (g_isTown)
			GiveHome(record, gold, ore);
		else
		{
			record.runGold += gold;
			record.runOre += ore;
		}
	}

	void GiveHome(int gold, int ore = 0) { GiveHome(GetLocalPlayerRecord(), gold, ore); }
	void GiveHome(PlayerRecord@ record, int gold, int ore = 0)
	{
%if HARDCORE
		record.mercenaryGold += gold;
		record.mercenaryOre += ore;
%else
		auto gm = cast<Campaign>(g_gameMode);
		gm.m_townLocal.m_gold += gold;
		gm.m_townLocal.m_ore += ore;
%endif
	}

	int GetGold() { return GetGold(GetLocalPlayerRecord()); }
	int GetGold(PlayerRecord@ record)
	{
		if (g_isTown)
			return GetHomeGold(record);
		else
			return record.runGold;
	}

	int GetOre() { return GetOre(GetLocalPlayerRecord()); }
	int GetOre(PlayerRecord@ record)
	{
		if (g_isTown)
			return GetHomeOre();
		else
			return record.runOre;
	}

	int GetHomeGold() { return GetHomeGold(GetLocalPlayerRecord()); }
	int GetHomeGold(PlayerRecord@ record)
	{
%if HARDCORE
		return record.mercenaryGold;
%else
		auto gm = cast<Campaign>(g_gameMode);
		return gm.m_townLocal.m_gold;
%endif
	}

	int GetHomeOre() { return GetHomeOre(GetLocalPlayerRecord()); }
	int GetHomeOre(PlayerRecord@ record)
	{
%if HARDCORE
		return record.mercenaryOre;
%else
		auto gm = cast<Campaign>(g_gameMode);
		return gm.m_townLocal.m_ore;
%endif
	}
}
