namespace Modifiers
{
	class SealOfGeneric : Modifier
	{
		vec2 m_stats;
		
		float m_movement;
		float m_movementMul;
		float m_skillSpeedMul;
		float m_attackSpeedMul;
		
	
		SealOfGeneric(UnitPtr unit, SValue& params)
		{
			m_stats = vec2(
				GetParamFloat(unit, params, "health", false, 0),
				GetParamFloat(unit, params, "mana", false, 0));

			m_movement = GetParamFloat(unit, params, "movement", false, 0);
			m_movementMul = GetParamFloat(unit, params, "movement-mul", false, 0);
			m_skillSpeedMul = GetParamFloat(unit, params, "skill-speed-mul", false, 0);
			m_attackSpeedMul = GetParamFloat(unit, params, "attack-speed-mul", false, 0);
		}
		
		
		bool HasStatsAdd() override { return m_stats.x != 0 || m_stats.y != 0; }
		ivec2 StatsAdd(PlayerBase@ player) override 
		{
			if (player is null)
				return ivec2();
		
			auto r = m_stats * clamp(1.0f - player.m_record.hp, 0.0f, 1.0f);
			return ivec2(int(r.x), int(r.y));
		}
		
		
		bool HasMoveSpeedAdd() override { return m_movement != 0; }
		bool HasMoveSpeedMul() override { return m_movementMul != 0; }
		
		float MoveSpeedAdd(PlayerBase@ player, float slowScale) override 
		{ 
			if (player is null)
				return 0;
		
			auto mov = m_movement * clamp(1.0f - player.m_record.hp, 0.0f, 1.0f);
			return ((mov < 0) ? slowScale * mov : mov); 
		}
		
		float MoveSpeedMul(PlayerBase@ player, float slowScale) override 
		{
			if (player is null)
				return 1;
		
			float mMul = 1.0f + m_movementMul * clamp(1.0f - player.m_record.hp, 0.0f, 1.0f);
			if (mMul < 1.0f)
				return lerp(1.0f, mMul, slowScale);
			return mMul; 
		}
		
		
		bool HasSkillTimeMul() override { return m_skillSpeedMul != 0; }
		bool HasAttackTimeMul() override { return m_attackSpeedMul != 0; }
		
		float SkillTimeMul(PlayerBase@ player) override 
		{ 
			if (player is null)
				return 1;
		
			return 1.0f + m_skillSpeedMul * clamp(1.0f - player.m_record.hp, 0.0f, 1.0f);
		}
		
		float AttackTimeMul(PlayerBase@ player) override 
		{ 
			if (player is null)
				return 1;
				
			return 1.0f + m_attackSpeedMul * clamp(1.0f - player.m_record.hp, 0.0f, 1.0f);
		}
	}
}