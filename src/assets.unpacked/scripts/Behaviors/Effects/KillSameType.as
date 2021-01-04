class KillSameType : IEffect
{
	int m_range;
	uint m_weaponInfo;
	UnitScene@ m_effect;
	uint m_effectHash;
	bool m_disabled;

	KillSameType(UnitPtr unit, SValue& params)
	{
		m_range = GetParamInt(unit, params, "range");
		m_effectHash = HashString(GetParamString(UnitPtr(), params, "fx", false, ""));
		@m_effect = Resources::GetEffect(m_effectHash);
		m_disabled = false;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (m_disabled)
			return false;
			
		if (target.IsDestroyed() || !target.IsValid())
			return false;
	
		auto ta = cast<Actor>(target.GetScriptBehavior());
		if (ta is null)
			return false;
			
		if (!husk)
		{
			auto@ upr = target.GetUnitProducer();
			auto enemies = g_scene.FetchActorsWithTeam(ta.Team, pos, m_range);
			for (int i = 0; i < int(enemies.length()); i++)
			{
				if (enemies[i] == target)
				{
					enemies.removeAt(i--);
					continue;
				}
				
				if (enemies[i].GetUnitProducer() !is upr)
				{
					enemies.removeAt(i--);
					continue;
				}
				
				auto actor = cast<Actor>(enemies[i].GetScriptBehavior());
				if (actor is null || !actor.IsTargetable())
				{
					enemies.removeAt(i--);
					continue;
				}
			}

			if (enemies.length() == 0)
				return false;

			m_disabled = true;
			
			UnitPtr enemy = enemies[randi(enemies.length())];
			auto actor = cast<Actor>(enemy.GetScriptBehavior());
			actor.Kill(owner, m_weaponInfo);
			if (m_effect !is null)
			{
				auto ePos = xy(enemy.GetPosition());
				PlayEffect(m_effect, ePos);
				(Network::Message("PlayEffect") << m_effectHash << ePos).SendToAll();
			}
			
			m_disabled = false;
		}

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		if (m_disabled)
			return false;

		if (!target.IsValid())
			return false;

		return true;
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}
}
