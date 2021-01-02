class ApplySoulDaggerBuff : IEffect
{
	bool m_ignoreIntensity;
	uint m_weaponInfo;

	ApplySoulDaggerBuff(UnitPtr unit, SValue& params)
	{
		m_ignoreIntensity = GetParamBool(unit, params, "ignore-intensity", false, false);
	}

	void SetWeaponInformation(uint weapon)
	{
		m_weaponInfo = weapon;
	}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		if (!FilterHuskDamage(owner, target, husk))
			return false;

		auto player = cast<PlayerBase>(owner);
		if (player is null)
			return false;

		auto skill = cast<Skills::MeleeSwing>(player.m_skills[0]);
		if (skill is null)
			return false;

		auto effect = cast<ApplyBuff>(skill.m_effects[0]);
		if (effect is null)
			return false;

		Actor@ actor = cast<Actor>(target.GetScriptBehavior());

		ActorBuff newBuff(owner, effect.m_buff, m_ignoreIntensity ? 1.0f : intensity, false, m_weaponInfo);
		newBuff.m_tickC = effect.m_buff.m_tickFreq;
		return actor.ApplyBuff(newBuff);
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		auto player = cast<PlayerBase>(owner);
		if (player is null)
			return false;

		if (intensity <= 0)
			return false;

		Actor@ actor = cast<Actor>(target.GetScriptBehavior());
		if (actor is null)
			return false;

		return true;
	}
}
