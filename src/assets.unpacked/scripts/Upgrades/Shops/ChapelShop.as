namespace Upgrades
{
	class ChapelShop : UpgradeShop
	{
		array<array<Upgrade@>> m_rows;

		ChapelShop(SValue& params)
		{
			super(params);

			auto rows = GetParamArray(UnitPtr(), params, "rows");
			for (uint i = 0; i < rows.length(); i++)
			{
				m_rows.insertLast(array<Upgrade@>());

				auto row = rows[i].GetArray();
				for (uint j = 0; j < row.length(); j++)
				{
					auto upgrData = cast<SValue>(row[j]);
					string upgrClassName = GetParamString(UnitPtr(), upgrData, "class");

					auto upgr = cast<Upgrades::Upgrade>(InstantiateClass(upgrClassName, upgrData));
					if (upgr is null)
					{
						PrintError("Class \"" + upgrClassName + "\" is not of type Upgrades::Upgrade");
						continue;
					}

					m_upgrades.insertLast(upgr); // so that the iterator can find it (for remembered upgrades)
					m_rows[i].insertLast(upgr);
				}
			}
		}
	}
}
