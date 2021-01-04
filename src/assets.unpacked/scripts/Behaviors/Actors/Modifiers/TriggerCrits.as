namespace Modifiers
{
	class TriggerCrits : Modifier, IBuffWidgetInfo
	{
		int m_count;
		int m_maxCount;

		int m_expireTime;
		int m_expireTimeC;

		float m_chance;

		ScriptSprite@ m_hudIcon;

		TriggerCrits() {}
		TriggerCrits(UnitPtr unit, SValue& params)
		{
			m_maxCount = GetParamInt(unit, params, "max-count", false, 3);

			m_expireTime = GetParamInt(unit, params, "expire-time", false, 1000);

			m_chance = GetParamFloat(unit, params, "crit-chance", false, 0.02f);

			auto arrIcon = GetParamArray(unit, params, "hud-icon", false);
			if (arrIcon !is null)
				@m_hudIcon = ScriptSprite(arrIcon);
		}

		Modifier@ Instance() override
		{
			auto ret = TriggerCrits();
			ret = this;
			ret.m_cloned++;
			return ret;
		}

		float CritChance(bool spell) override
		{
			return m_count * m_chance;
		}

		bool HasCrit() override { return true; }
		int Crit(PlayerBase@ player, Actor@ enemy, bool spell) override
		{
			if (!RollCrit(player, spell))
				return 0;
			return 1;
		}

		bool RollCrit(PlayerBase@ player, bool spell)
		{
			float chance = m_count * m_chance;
			return roll_chance(player, chance);
		}

		bool HasUpdate() override { return true; }
		void Update(PlayerBase@ player, int dt) override
		{
			m_expireTimeC -= dt;
			if (m_expireTimeC <= 0 && m_count > 0)
			{
				m_count--;
				if (m_count > 0)
					m_expireTimeC = m_expireTime;
			}
		}

		bool HasTriggerEffects() override { return true; }
		void TriggerEffects(PlayerBase@ player, Actor@ enemy, EffectTrigger trigger) override
		{
			if (trigger != EffectTrigger::CastSpell)
				return;

			m_count++;
			if (m_count > m_maxCount)
				m_count = m_maxCount;

			m_expireTimeC = m_expireTime;

			auto hud = GetHUD();
			if (hud !is null)
				hud.ShowBuffIcon(player, this);
		}

		ScriptSprite@ GetBuffIcon() { return m_hudIcon; }
		int GetBuffIconDuration() { return m_expireTimeC; }
		int GetBuffIconMaxDuration() { return m_expireTime; }
		int GetBuffIconCount() { return m_count; }
	}
}
