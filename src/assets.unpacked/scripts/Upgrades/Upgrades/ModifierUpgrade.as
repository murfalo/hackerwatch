namespace Upgrades
{
	class ModifierUpgrade : Upgrade
	{
		ModifierUpgrade(SValue& params)
		{
			super(params);
		}

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return ModifierUpgradeStep(this, params, level);
		}
	}
}
