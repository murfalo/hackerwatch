class SimpleBreakable : ADamageTaker
{
	UnitPtr m_unit;

	SoundEvent@ m_breakSound;
	UnitScene@ m_breakEffect;

	GoreSpawner@ m_gore;
	UnitProducer@ m_corpse;

	bool m_impenetrable;
	bool m_shootThrough;
	bool m_walkThrough;

	
	
	SimpleBreakable(UnitPtr unit, SValue& params)
	{
		m_unit = unit;
		
		@m_breakSound = Resources::GetSoundEvent(GetParamString(unit, params, "break-sound", false));
		@m_breakEffect = Resources::GetEffect(GetParamString(unit, params, "break-effect", false));

		@m_gore = LoadGore(GetParamString(unit, params, "gore", false));

		@m_corpse = Resources::GetUnitProducer(GetParamString(unit, params, "corpse", false));
		
		m_impenetrable = GetParamBool(unit, params, "impenetrable", false, false);
		m_walkThrough = GetParamBool(unit, params, "walk-through", false, false);
		m_shootThrough = GetParamBool(unit, params, "shoot-through", false, false);
		
		if (m_corpse !is null && IsNetsyncedExistance(m_corpse.GetNetSyncMode()))
			PrintError("SimpleBreakable cannot have a netsynced corpse");
		
		if (IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode()))
			PrintError("SimpleBreakable cannot be netsynced");
	}

	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override
	{
		if (!m_shootThrough)
			return false;
	
		if ((attacker is null && Network::IsServer()) || (attacker !is null && !attacker.IsHusk()))
		{
			UnitHandler::NetSendUnitDamaged(m_unit, 1, pos, dir, attacker);
			DamageEffects(1, pos, dir);
		}

		return true;
	}
	
	int DamageEffects(int dmg, vec2 pos, vec2 dir)
	{
		if (!m_unit.IsValid() || m_unit.IsDestroyed() || m_unit.GetPhysicsBody() is null)
			return 0;

		PlaySound3D(m_breakSound, m_unit.GetPosition());
		PlayEffect(m_breakEffect, xy(m_unit.GetPosition()));
		
		if (m_gore !is null)
			m_gore.OnDeath(dmg / 100.0, xy(m_unit.GetPosition()), atan(dir.y, dir.x));

		m_unit.Destroy();
		return dmg;
	}
	
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		return DamageEffects(dmg.Damage, pos, dir);
	}
	
	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		if (!m_walkThrough)
			return;
	
		auto a = cast<Actor>(unit.GetScriptBehavior());
		if (a !is null)
			DamageEffects(100, pos, normal);
	}
	
	bool Impenetrable() override { return m_impenetrable; }
		
	bool IsDead() override
	{
		return !m_unit.IsValid();
	}
}
