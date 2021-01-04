namespace Upgrades
{
	class DesertMapUpgrade : SingleStepUpgrade
	{
		DesertMapUpgrade(SValue& params)
		{
			super(params);

			@m_step = DesertMapUpgradeStep(this, params, 1);
		}

		bool IsOwned(PlayerRecord@ record) override
		{
			return m_step.IsOwned(record);
		}
	}
}
