namespace Modifiers
{
	class DungeonStoreItems : Modifier
	{
		int m_num;

		DungeonStoreItems(UnitPtr unit, SValue& params)
		{
			m_num = GetParamInt(unit, params, "num");
		}

		int DungeonStoreItemsAdd() override
		{
			return m_num;
		}
	}
}
