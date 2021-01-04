namespace Upgrades
{
	class ChapelUpgrade : ModifierUpgrade
	{
		ChapelUpgrade(SValue& params)
		{
			super(params);
		}

		UpgradeStep@ LoadStep(SValue@ params, int level) override
		{
			return ChapelUpgradeStep(this, params, level);
		}
	}
}
