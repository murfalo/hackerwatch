namespace Crowd
{
	class ValueAction : CrowdAction
	{
		float m_amountNegative;
		float m_amountNeutral;
		float m_amountPositive;

		float m_amountNegativeRatingAdd;
		float m_amountNeutralRatingAdd;
		float m_amountPositiveRatingAdd;

		ValueAction(SValue &params)
		{
			super(params);

			m_amountNegative = GetParamFloat(UnitPtr(), params, "amount-negative", false, 0.0f);
			m_amountNeutral = GetParamFloat(UnitPtr(), params, "amount-neutral", false, 0.0f);
			m_amountPositive = GetParamFloat(UnitPtr(), params, "amount-positive", false, 0.0f);

			m_amountNegativeRatingAdd = GetParamFloat(UnitPtr(), params, "amount-negative-ratingadd", false, 0.0f);
			m_amountNeutralRatingAdd = GetParamFloat(UnitPtr(), params, "amount-neutral-ratingadd", false, 0.0f);
			m_amountPositiveRatingAdd = GetParamFloat(UnitPtr(), params, "amount-positive-ratingadd", false, 0.0f);
		}

		float GetRatingAdd(float mul)
		{
			return mul * float(g_gladiatorRating);
		}

		float AmountNegative()
		{
			float ret = m_amountNegative;
			ret += GetRatingAdd(m_amountNegativeRatingAdd);
			return ret;
		}

		float AmountNeutral()
		{
			float ret = m_amountNeutral;
			ret += GetRatingAdd(m_amountNeutralRatingAdd);
			return ret;
		}

		float AmountPositive()
		{
			float ret = m_amountPositive;
			ret += GetRatingAdd(m_amountPositiveRatingAdd);
			return ret;
		}
	}

	class IntValueAction : ValueAction
	{
		int m_thresholdNegative;
		int m_thresholdPositive;

		float m_thresholdNegativeRatingAdd;
		float m_thresholdPositiveRatingAdd;

		IntValueAction(SValue &params)
		{
			super(params);

			m_thresholdNegative = GetParamInt(UnitPtr(), params, "threshold-negative", false, 0);
			m_thresholdPositive = GetParamInt(UnitPtr(), params, "threshold-positive", false, 1);

			m_thresholdNegativeRatingAdd = GetParamFloat(UnitPtr(), params, "threshold-negative-ratingadd", false, 0.0f);
			m_thresholdPositiveRatingAdd = GetParamFloat(UnitPtr(), params, "threshold-positive-ratingadd", false, 0.0f);
		}

		int ThresholdNegative()
		{
			int ret = m_thresholdNegative;
			ret += int(GetRatingAdd(m_thresholdNegativeRatingAdd));
			return max(ret, m_thresholdNegative);
		}

		int ThresholdPositive()
		{
			int ret = m_thresholdPositive;
			ret += int(GetRatingAdd(m_thresholdPositiveRatingAdd));
			return max(ret, m_thresholdPositive);
		}
	}

	class FloatValueAction : ValueAction
	{
		float m_thresholdNegative;
		float m_thresholdPositive;

		float m_thresholdNegativeRatingAdd;
		float m_thresholdPositiveRatingAdd;

		FloatValueAction(SValue &params)
		{
			super(params);

			m_thresholdNegative = GetParamFloat(UnitPtr(), params, "threshold-negative", false, 0.0f);
			m_thresholdPositive = GetParamFloat(UnitPtr(), params, "threshold-positive", false, 1.0f);

			m_thresholdNegativeRatingAdd = GetParamFloat(UnitPtr(), params, "threshold-negative-ratingadd", false, 0.0f);
			m_thresholdPositiveRatingAdd = GetParamFloat(UnitPtr(), params, "threshold-positive-ratingadd", false, 0.0f);
		}

		float ThresholdNegative()
		{
			float ret = m_thresholdNegative;
			ret += GetRatingAdd(m_thresholdNegativeRatingAdd);
			return max(ret, m_thresholdNegative);
		}

		float ThresholdPositive()
		{
			float ret = m_thresholdPositive;
			ret += GetRatingAdd(m_thresholdPositiveRatingAdd);
			return max(ret, m_thresholdPositive);
		}
	}
}
