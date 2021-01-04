namespace Upgrades
{
	class SingleStepUpgrade : Upgrade
	{
		UpgradeStep@ m_step;

		SingleStepUpgrade(SValue& sval)
		{
			super(sval);
		}

		bool ShouldBeVisible() override { return true; }

		bool ShouldRemember() override { return false; }
		UpgradeStep@ GetStep(int level) override { return m_step; }
		int GetNextLevel(PlayerRecord@ record) override { return 1; }
		UpgradeStep@ GetNextStep(PlayerRecord@ record) override { return m_step; }
	}
}
