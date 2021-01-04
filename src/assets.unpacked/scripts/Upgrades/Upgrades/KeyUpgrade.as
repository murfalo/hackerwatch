namespace Upgrades
{
	class KeyUpgrade : Upgrade
	{
		KeyUpgrade(SValue& params)
		{
			super(params);
		}

		bool ShouldRemember() override { return false; }

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return KeyUpgradeStep(this, params, level);
		}
	}
}
