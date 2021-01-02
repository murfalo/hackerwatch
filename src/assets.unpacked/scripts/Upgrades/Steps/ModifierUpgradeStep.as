namespace Upgrades
{
	class ModifierUpgradeStep : UpgradeStep
	{
		array<Modifiers::Modifier@> m_modifiers;

		ModifierUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			m_modifiers = Modifiers::LoadModifiers(UnitPtr(), params, "", Modifiers::SyncVerb::Upgrade, HashString(m_upgrade.m_id));
		}

		bool BuyNow(PlayerRecord@ record) override
		{
			//TODO: Husk?
			if (cast<Player>(record.actor) is null)
				return false;

			return true;
		}

		void PayForUpgrade(PlayerRecord@ record) override
		{
			UpgradeStep::PayForUpgrade(record);

			Stats::Add("upgrades-bought", 1, record);

			auto player = cast<Player>(record.actor);
			if (player !is null)
				player.RefreshModifiers();
		}

		array<Modifiers::Modifier@>@ GetModifiers()
		{
			return m_modifiers;
		}
	}
}
