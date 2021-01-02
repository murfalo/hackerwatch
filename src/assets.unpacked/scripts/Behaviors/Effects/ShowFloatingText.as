class ShowFloatingText : IEffect
{
	string m_text;
	vec2 m_offset;
	FloatingTextType m_type;

	ShowFloatingText(UnitPtr unit, SValue& params)
	{
		m_offset = GetParamVec2(unit, params, "offset", false);
		m_text = Resources::GetString(GetParamString(unit, params, "text"));

		string type = GetParamString(unit, params, "type", false, "Pickup");

		if (type == "Pickup")
			m_type = FloatingTextType::Pickup;
		else if (type == "PlayerHurt")
			m_type = FloatingTextType::PlayerHurt;
		else if (type == "PlayerHurtMagical")
			m_type = FloatingTextType::PlayerHurtMagical;
		else if (type == "PlayerHealed")
			m_type = FloatingTextType::PlayerHealed;
		else if (type == "PlayerArmor")
			m_type = FloatingTextType::PlayerArmor;
		else if (type == "PlayerAmmo")
			m_type = FloatingTextType::PlayerAmmo;
		else if (type == "EnemyHurt")
			m_type = FloatingTextType::EnemyHurt;
		else if (type == "EnemyHurtLocal")
			m_type = FloatingTextType::EnemyHurtLocal;
		else if (type == "EnemyHurtHusk")
			m_type = FloatingTextType::EnemyHurtHusk;
		else if (type == "EnemyHealed")
			m_type = FloatingTextType::EnemyHealed;
		else if (type == "EnemyImmortal")
			m_type = FloatingTextType::EnemyImmortal;
	}
	
	void SetWeaponInformation(uint weapon) {}

	bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
	{
		vec3 p = target.GetPosition();
		p.x += m_offset.x;
		p.y += m_offset.y;
		AddFloatingText(m_type, m_text, p);
		return true;
	}

	bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override
	{
		return true;
	}
}
