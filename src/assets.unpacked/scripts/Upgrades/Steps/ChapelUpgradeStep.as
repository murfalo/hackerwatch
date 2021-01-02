namespace Upgrades
{
	class ChapelUpgradeStep : ModifierUpgradeStep
	{
		ChapelUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);
		}

		void RegisterKnown(PlayerRecord@ record)
		{
			string id = m_upgrade.m_id;
			if (record.chapelUpgradesPurchased.find(id) == -1)
				record.chapelUpgradesPurchased.insertLast(id);
		}

		float PayScale(PlayerRecord@ record) override
		{
			if (record.chapelUpgradesPurchased.find(m_upgrade.m_id) != -1)
				return 0.0f;

			return ModifierUpgradeStep::PayScale(record);
		}

		void PayForUpgrade(PlayerRecord@ record) override
		{
			ModifierUpgradeStep::PayForUpgrade(record);
			RegisterKnown(record);
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			RegisterKnown(record);
			return ModifierUpgradeStep::ApplyNow(record);
		}
	}
}
