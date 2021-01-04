namespace Upgrades
{
	class KeyUpgradeStep : UpgradeStep
	{
		int m_lock;
		int m_amount;

		KeyUpgradeStep(Upgrade@ upgrade, SValue@ params, int level)
		{
			super(upgrade, params, level);

			m_lock = GetParamInt(UnitPtr(), params, "lock");
			m_amount = GetParamInt(UnitPtr(), params, "amount");
		}

		string GetButtonText() override
		{
			return "";
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			return false;
		}

		bool ApplyNow(PlayerRecord@ record) override
		{
			record.keys[m_lock] += m_amount;
			return true;
		}
	}
}
