class LootUnit
{
	int chance;
	UnitProducer@ unit;
	
	LootUnit()
	{
	}
	
	LootUnit(int chance, UnitProducer@ unit)
	{
		this.chance = chance;
		@(this.unit) = unit;
	}
	
	int opCmp(const LootUnit &in lootUnit) const
	{
		if(chance < lootUnit.chance) 
			return -1;
		else if(chance > lootUnit.chance) 
			return 1;
		return 0;
	}
}

class LootDef
{
	string m_path;

	vec2 m_offset;
	vec2 m_spread;
	
	array<array<LootUnit>@> m_loot;
	
	
	
	LootDef(string path, SValue& params)
	{
		m_path = path;
	
		if (params.GetType() != SValueType::Array)
			return;
		
		auto arr = params.GetArray();
		
		m_offset = arr[0].GetVector2();
		m_spread = arr[1].GetVector2();
		
		for (uint i = 2; i < arr.length(); i++)
		{
			auto loot = arr[i].GetArray();
			array<LootUnit>@ lootUnits = array<LootUnit>();
		
			for (uint j = 0; j < loot.length(); j += 2)
			{
				int chance = loot[j].GetInteger();
				auto unit = Resources::GetUnitProducer(loot[j+1].GetString());
				
				if (unit !is null)
					lootUnits.insertLast(LootUnit(chance, unit));
			}
			
			lootUnits.sortDesc();
			m_loot.insertLast(@lootUnits);
		}
	}
	
	
	void Spawn(vec2 pos)
	{
		if (!Network::IsServer())
			return;
	
		pos += m_offset;

		array<Tileset@>@ tilesets = g_scene.FetchTilesets(pos);
		for (uint i = 0; i < tilesets.length(); i++)
		{
			SValue@ tsd = tilesets[i].GetData();
			if (tsd is null)
				continue;

			SValue@ svNoLoot = tsd.GetDictionaryEntry("no-loot");
			if (svNoLoot is null or svNoLoot.GetType() != SValueType::Boolean)
				continue;

			if (svNoLoot.GetBoolean())
				return;
		}
		
		
		
		SValueBuilder sval;
		sval.PushArray();
		
		for (uint i = 0; i < m_loot.length(); i++)
		{
			int n = randi(1000);
			
			auto lList = m_loot[i];
			for (uint j = 0; j < lList.length(); j++)
			{
				n -= lList[j].chance;
				if (n < 0)
				{
					auto p = pos;
					p.x += (randf() * 2 - 1) * m_spread.x;
					p.y += (randf() * 2 - 1) * m_spread.y;
					
					auto u = lList[j].unit.Produce(g_scene, vec3(p.x, p.y, 0));
					
					if (!IsNetsyncedExistance(lList[j].unit.GetNetSyncMode()))
					{
						sval.PushInteger(lList[j].unit.GetResourceHash());
						sval.PushVector2(p);
					}
					
					break;
				}
			}
		}
		
		auto val = sval.Build();
		(Network::Message("SpawnLoot") << val).SendToAll();
	}
}

namespace LootDef
{
	void NetSpawnLoot(SValue@ param)
	{
		auto data = param.GetArray();
		for (uint i = 0; i < data.length(); i += 2)
		{
			uint hash = data[i].GetInteger();
			vec2 pos = data[i + 1].GetVector2();
			auto unit = Resources::GetUnitProducer(hash);
			
			if (unit !is null)
				unit.Produce(g_scene, vec3(pos.x, pos.y, 0));
			else
				PrintError("Failed to spawn unit, couldn't get UnitProducer from hash " + hash);
		}	
	}
}


array<LootDef@> g_lootDefs;

LootDef@ LoadLootDef(string path)
{
	if (path == "")
		return null;

	for (uint i = 0; i < g_lootDefs.length(); i++)
		if (g_lootDefs[i].m_path == path)
			return g_lootDefs[i];
	
	int i = path.findFirst(":");
	if (i == -1)
		return null;
		
	string file = path.substr(0, i);
	string name = path.substr(i + 1);
		
	SValue@ loot = Resources::GetSValue(file);
	if (loot is null)
		return null;
		
	auto lDef = loot.GetDictionaryEntry(name);
	if (lDef is null)
		return null;		
	
	auto ret = LootDef(path, lDef);
	g_lootDefs.insertLast(@ret);
	return ret;
}
