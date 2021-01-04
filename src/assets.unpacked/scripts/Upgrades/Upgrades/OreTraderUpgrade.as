namespace Upgrades
{
	class OreTraderUpgrade : Upgrade
	{
		OreTraderUpgrade(SValue& params)
		{
			super(params);
		}

		bool ShouldRemember() override { return false; }

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return OreTraderUpgradeStep(this, params, level);
		}
	}
}