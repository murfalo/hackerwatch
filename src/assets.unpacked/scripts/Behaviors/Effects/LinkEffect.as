class LinkEffect : IEffect
{
	array<IEffect@>@ m_effects;
	int m_cooldown;

	array<ISkillConditional@>@ m_conditionals;
	bool m_conditionalsSelf;

	uint m_lastTrigger;

	LinkEffect(UnitPtr unit, SValue& params)
	{
		@m_effects = LoadEffects(unit, params);
		m_cooldown = GetParamInt(unit, params, "cooldown", false, 0);

		@m_conditionals = LoadSkillConditionals(unit, params);
		m_conditionalsSelf = GetParamBool(unit, params, "conditionals-self", false, true);
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		m_lastTrigger = g_scene.GetTime();

		return ApplyEffects(m_effects, owner, target, pos, dir, intensity, husk);
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity)
	{
		if (g_scene.GetTime() < uint(m_lastTrigger + m_cooldown))
			return false;

		if (m_conditionals !is null)
		{
			CompositeActorBehavior@ condActor = cast<CompositeActorBehavior>(owner);
			if (!m_conditionalsSelf)
				@condActor = cast<CompositeActorBehavior>(target.GetScriptBehavior());

			if (!CheckConditionals(m_conditionals, condActor))
				return false;
		}

		return CanApplyEffects(m_effects, owner, target, pos, dir, intensity);
	}

	void SetWeaponInformation(uint weapon)
	{
		for (uint i = 0; i < m_effects.length(); i++)
			m_effects[i].SetWeaponInformation(weapon);
	}
}
