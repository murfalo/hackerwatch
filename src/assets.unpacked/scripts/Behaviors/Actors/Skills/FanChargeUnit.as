namespace Skills
{
	class FanChargeUnit : ChargeUnit
	{
		int m_numProjectiles;
		float m_spread;

		FanChargeUnit(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_numProjectiles = GetParamInt(unit, params, "num", false, 1);
			m_spread = GetParamFloat(unit, params, "spread", false) * PI / 180.0f;
		}

		void Release(vec2 target) override
		{
			ActiveSkill::Release(target);

			if (!m_pressOk)
				return;

			if (m_chargeFx.IsValid())
			{
				m_chargeFx.Destroy();
				m_chargeFx = UnitPtr();
			}

			if (m_chargeFullFx.IsValid())
			{
				m_chargeFullFx.Destroy();
				m_chargeFullFx = UnitPtr();
			}

			float angle = atan(target.y, target.x);
			float x = m_spread * (m_numProjectiles - 1);

			float charge = m_tmCharge / float(m_tmChargeMax);

			SValueBuilder builder;
			builder.PushArray();
			for (int i = 0; i < m_numProjectiles; i++)
			{
				float dx = (angle - x / 2.0f) + i * m_spread;
				vec2 dir = vec2(cos(dx), sin(dx));
				UnitPtr unit = DoShoot(charge, dir);
				builder.PushInteger(unit.GetId());
			}
			builder.PopArray();

			m_pressOk = false;
			m_tmCharge = 0;

			(Network::Message("PlayerFanChargeUnit") << m_skillId << charge << target << builder.Build()).SendToAll();
		}

		void NetShoot(float charge, vec2 target, array<SValue@>@ arr)
		{
			float angle = atan(target.y, target.x);
			float x = m_spread * (arr.length() - 1);

			for (uint i = 0; i < arr.length(); i++)
			{
				int id = arr[i].GetInteger();
				float dx = (angle - x / 2.0f) + i * m_spread;
				vec2 dir = vec2(cos(dx), sin(dx));
				UnitPtr unit = DoShoot(charge, dir, id);
			}
		}
	}
}
