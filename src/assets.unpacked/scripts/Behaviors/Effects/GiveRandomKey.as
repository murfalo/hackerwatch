class GiveRandomKeyItem
{
	int lock;
	float chance;
}

class GiveRandomKey : GiveKey
{
	array<GiveRandomKeyItem@> m_items;

	GiveRandomKey(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		auto arrItems = GetParamArray(unit, params, "locks");
		for (uint i = 0; i < arrItems.length(); i++)
		{
			auto arrItem = arrItems[i].GetArray();

			auto newItem = GiveRandomKeyItem();
			newItem.lock = arrItem[0].GetInteger();
			newItem.chance = arrItem[1].GetFloat();
			m_items.insertLast(newItem);
		}
	}

	int GetLock() override
	{
		float r = randf();
		float c = 0.0f;
		for (uint i = 0; i < m_items.length(); i++)
		{
			auto item = m_items[i];
			c += item.chance;
			if (r <= c)
				return item.lock;
		}
		PrintError("Couldn't find random key to give!");
		return 0;
	}
}
