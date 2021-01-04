double __CalcTaxRate(int money, double midpoint)
{
	return pow(money / midpoint + 1, -1);
}

int ApplyTaxRate(int townMoney, int runMoney, float midpointMul = 1.0f)
{
	double midpoint = g_allModifiers.TaxMidpoint() * (midpointMul * g_allModifiers.TaxMidpointMul());
	if (Fountain::HasEffect("keep_all_gold"))
		midpoint *= 4;

	int64 money = 0;
	while (runMoney > 0)
	{
		money += int64(min(250, runMoney) * 1000 * __CalcTaxRate(townMoney + int(money / 1000), midpoint));
		runMoney -= 250;
	}

	return int(money / 1000);
}
