class RefillPotion : IEffect
{
	int m_charges;

	UnitScene@ m_effect;
	SoundEvent@ m_snd;

	RefillPotion(UnitPtr unit, SValue& params)
	{
		m_charges = GetParamInt(unit, params, "charges", false, 1);

		@m_effect = Resources::GetEffect(GetParamString(unit, params, "effect", false));
		@m_snd = Resources::GetSoundEvent(GetParamString(unit, params, "sound", false));
	}

	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		if (!CanApply(owner, target, pos, dir, intensity))
			return false;

		auto player = cast<PlayerBase>(target.GetScriptBehavior());
		if (player is null)
			return false;

		player.m_record.GivePotionCharges(m_charges);

		if (m_effect !is null)
			PlayEffect(m_effect, pos);
		if (m_snd !is null && player.m_record.local)
			m_snd.Play(xyz(pos));

		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		if (!target.IsValid())
			return false;

		auto player = cast<PlayerBase>(target.GetScriptBehavior());
		if (player is null)
			return false;

		return player.m_record.potionChargesUsed > 0;
	}
}
