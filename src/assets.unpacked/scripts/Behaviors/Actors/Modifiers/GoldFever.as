namespace Modifiers
{
	class GoldFever : Modifiers::Modifier
	{
		float m_dmgScale;

		GoldFever(UnitPtr unit, SValue& params)
		{
			m_dmgScale = GetParamFloat(unit, params, "mul-add", false, 0.0f);
		}

		bool HasDamageMul() override { return true; }
		vec2 DamageMul(PlayerBase@ player, Actor@ enemy) override
		{
			return vec2(1.0f + float(player.m_record.runGold) * m_dmgScale);
		}
	}
}
