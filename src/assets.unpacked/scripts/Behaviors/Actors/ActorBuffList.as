class ActorBuffList
{
	array<ActorBuff@> m_buffs;
	Actor@ m_actor;
	ActorColor m_color;
	array<ActorBuffIcon@> m_icons;

	void Initialize(Actor@ actor)
	{
		@m_actor = actor;
	}

	ActorBuffIcon@ AddIcon(UnitProducer@ prod)
	{
		auto icon = GetIcon(prod);
		if (icon !is null)
		{
			icon.AddRef();
			return icon;
		}

		auto newIcon = ActorBuffIcon(prod, m_actor);
		m_icons.insertLast(newIcon);
		return newIcon;
	}

	ActorBuffIcon@ GetIcon(UnitProducer@ prod)
	{
		for (uint i = 0; i < m_icons.length(); i++)
		{
			auto icon = m_icons[i];
			if (icon.m_prod is prod)
				return m_icons[i];
		}
		return null;
	}

	void Add(ActorBuff@ buff)
	{
		if (m_actor is null)
			return;
	
		if (!buff.m_husk)
		{
			auto owner = (buff.m_owner !is null) ? buff.m_owner.m_unit : UnitPtr();
			(Network::Message("UnitBuffed") << m_actor.m_unit << owner << buff.m_def.m_pathHash << buff.m_intensity << buff.m_weaponInfo << buff.m_duration).SendToAll();
		}
	
		for (uint i = 0; i < m_buffs.length(); i++)
		{
			if (m_buffs[i].m_def is buff.m_def)
			{
				m_buffs[i].Refresh(buff);
				UpdateVisual();
				return;
			}
		}
	
		m_buffs.insertLast(buff);
		buff.Attach(m_actor, this);

		auto player = cast<PlayerBase>(m_actor);
		if (player !is null)
			player.RefreshModifiersBuffs();
		
		UpdateVisual();
	}

	void Remove(uint buffPathHash)
	{
		for (uint i = 0; i < m_buffs.length(); i++)
		{
			if (m_buffs[i].m_def.m_pathHash == buffPathHash)
			{
				m_buffs[i].Clear();
				m_buffs.removeAt(i);
				OnBuffRemoved();
				break;
			}
		}
	}
	
	void OnDeath(Actor@ actor)
	{
		for (uint i = 0; i < m_buffs.length(); i++)
			m_buffs[i].OnDeath(actor);
	}

	void Clear()
	{
		for (uint i = 0; i < m_buffs.length(); i++)
			m_buffs[i].Clear();
			
		m_buffs.removeRange(0, m_buffs.length());

		OnBuffRemoved();
		
		@m_actor = null;
	}
	
	void UpdateVisual()
	{
		if (m_actor is null)
			return;

		auto hud = GetHUD();
		
		int numColors = 0;

		vec4 darkC(0,0,0,0);
		vec4 midC(0,0,0,0);
		vec4 brightC(0,0,0,0);

		bool gotHead = false;
		for (uint i = 0; i < m_buffs.length(); i++)
		{
			auto buff = m_buffs[i];
			auto color = buff.m_def.m_color;
			
			if (color !is null)
			{
				numColors++;
				darkC += color.m_dark;
				midC += color.m_mid;
				brightC += color.m_bright;
			}
			
			@buff.m_hudIcon = hud.ShowBuffIcon(cast<PlayerBase>(m_actor), buff);
		}
		
		if (numColors > 0)
		{
			auto d = vec4(numColors);
			m_color.m_dark = darkC / d;
			m_color.m_mid = midC / d;
			m_color.m_bright = brightC / d;
			
			//print(":" + numColors + " :: " + m_color.m_mid.x + ", " + m_color.m_mid.y + ", " + m_color.m_mid.z + ", " + m_color.m_mid.w);
			//print(":  :: " + midC.x + ", " + midC.y + ", " + midC.z + ", " + midC.w);
		}
		else
		{
			m_color.m_dark = darkC;
			m_color.m_mid = midC;
			m_color.m_bright = brightC;
		}
		
		m_actor.m_unit.Colorize(m_color.m_dark, m_color.m_mid, m_color.m_bright);
		
	}

	void OnBuffRemoved()
	{
		auto player = cast<PlayerBase>(m_actor);
		if (player !is null)
			player.RefreshModifiersBuffs();

		UpdateVisual();
	}

	void Update(int dt)
	{
		if (m_actor is null)
			return;
	
		bool buffRemoved = false;
		for (uint i = 0; i < m_buffs.length();)
		{
			if (!m_buffs[i].Update(dt, m_actor))
			{
				buffRemoved = true;
				
				if (m_buffs.length() == 0)
					break;
			
				m_buffs[i].Clear();
				m_buffs.removeAt(i);
				
			}
			else
				i++;
		}
		
		if (buffRemoved)
			OnBuffRemoved();

		for (int i = int(m_icons.length()) - 1; i >= 0; i--)
		{
			if (m_icons[i].m_attached.m_unit.IsDestroyed())
				m_icons.removeAt(i);
		}
	}

	bool HasTags(uint64 tags)
	{
		for (uint i = 0; i < m_buffs.length(); i++)
		{
			auto buff = m_buffs[i];
			if ((buff.m_def.m_tags & tags) != 0)
				return true;
		}
		return false;
	}

	bool HasBuff(uint pathHash)
	{
		for (uint i = 0; i < m_buffs.length(); i++)
		{
			auto buff = m_buffs[i];
			if (buff.m_def.m_pathHash == pathHash)
				return true;
		}
		return false;
	}	
	
	// Multiplier vectors
	vec2 ArmorMul() { vec2 v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulArmor; } return v; }

	// Multiplier floats
	float MoveSlipperyMul() { float v = 1.0f; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulSlippery; } return v; }
	float MoveSpeedMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulSpeed; } return v; }
	float MoveSpeedMul(float slowScale) { 
		float v = 1.0; 
		for (uint i = 0; i < m_buffs.length(); i++) { 
			if (m_buffs[i].m_def.m_mulSpeed < 1.0f)
				v *= lerp(1.0f, m_buffs[i].m_def.m_mulSpeed, slowScale);
			else
				v *= m_buffs[i].m_def.m_mulSpeed;
		} 
		return v; 
	}
	float MoveSpeedDashMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulSpeedDash; } return v; }
	float DamageMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulDamage; } return v; }
	float DamageTakenMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulDamageTaken; } return v; }
	float ExperienceMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulExperience; } return v; }
	float WindScaleMul() { float v = 1.0; for (uint i = 0; i < m_buffs.length(); i++) { v *= m_buffs[i].m_def.m_mulWindScale; } return v; }

	// Additive floats
	float ReceiveCritChance() { float v = 0.0; for (uint i = 0; i < m_buffs.length(); i++) { v += m_buffs[i].m_def.m_receiveCritChance; } return v; }

	// Minimum floats
	float MinSpeed() { float v = 0.0; for (uint i = 0; i < m_buffs.length(); i++) { v = max(v, m_buffs[i].m_def.m_minSpeed); } return v; }
	float SetSpeed() { float v = -1.0f; for (uint i = 0; i < m_buffs.length(); i++) { v = max(v, m_buffs[i].m_def.m_setSpeed); } return v; }

	// Bools
	bool FreeMana() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_freeMana) return true; } return false; }
	bool Disarm() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_disarm) return true; } return false; }
	bool Silence() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_silence) return true; } return false; }
	bool Mute() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_mute) return true; } return false; }
	bool Confuse() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_confuse) return true; } return false; }
	bool LockMovement() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_lockMovement) return true; } return false; }
	bool LockRotation() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_lockRotation) return true; } return false; }
	bool AntiConfuse() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_antiConfuse) return true; } return false; }
	bool Drifting() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_drifting) return true; } return false; }
	bool InfDodge() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_infDodge) return true; } return false; }
	bool Darkness() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_darkness) return true; } return false; }
	bool Shatterable() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_shatterable) return true; } return false; }
	
	// Cleave
	CleaveInfo@ Cleave() { for (uint i = 0; i < m_buffs.length(); i++) { if (m_buffs[i].m_def.m_cleave !is null) return m_buffs[i].m_def.m_cleave; } return null; }
}
