namespace Upgrades
{
	class RecordUpgrade : Upgrade
	{
		RecordUpgrade(SValue& params)
		{
			super(params);
		}

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return RecordUpgradeStep(this, params, level);
		}
	}
}
