namespace Skills
{
	abstract class ActiveSkill : Skill
	{
		AnimString@ m_animation;
		int m_animCountdown;
		string m_fx;
		SoundEvent@ m_sound;
		SoundEvent@ m_soundStart;
		SoundEvent@ m_soundHold;
		SoundInstance@ m_soundHoldI;
		float m_speedMul;
		float m_idleCdMul;
		
		int m_cooldown;
		int m_cooldownC;
		bool m_cooldownOverride;
		int m_castpoint;
		int m_castingC;
		
		int m_burst;
		int m_burstC;
		int m_burstFreq;
		
		int m_costMana;
		int m_costStamina;
		int m_costHealth;
		
		float m_timeScale;
		bool m_blocking;

		bool m_netHold;
		
		
		vec2 m_queuedTarget;
		

		ActiveSkill(UnitPtr unit, SValue& params)
		{
			super(unit);
		
			@m_animation = AnimString(GetParamString(unit, params, "anim"));
			m_fx = GetParamString(unit, params, "fx", false);
			@m_sound = Resources::GetSoundEvent(GetParamString(unit, params, "snd", false));
			@m_soundStart = Resources::GetSoundEvent(GetParamString(unit, params, "start-snd", false));
			@m_soundHold = Resources::GetSoundEvent(GetParamString(unit, params, "snd-hold", false));
			
			m_castpoint = max(1, GetParamInt(unit, params, "castpoint", false, 0));
			m_cooldown = max(m_castpoint, GetParamInt(unit, params, "cooldown", true, 1000));
			
			
			m_burst = m_burstC = GetParamInt(unit, params, "burst", false, 0);
			m_burstFreq = GetParamInt(unit, params, "burst-freq", false, 100);
			
			
			m_costMana = GetParamInt(unit, params, "mana-cost", false, 0);
			m_costStamina = GetParamInt(unit, params, "stamina-cost", false, 0);
			m_costHealth = GetParamInt(unit, params, "health-cost", false, 0);
			
			m_speedMul = GetParamFloat(unit, params, "speed-mul", false, 1);
			m_idleCdMul = GetParamFloat(unit, params, "idle-cooldown-mul", false, 1);
			
			m_blocking = GetParamBool(unit, params, "blocking", false, false);

			m_animCountdown = 0;
			m_timeScale = 1.0f;
		}
		
		TargetingMode GetTargetingMode(int &out size) override { return TargetingMode::Direction; }

		void StartHoldSound()
		{
			if (m_soundHold is null)
				return;
			if (m_soundHoldI !is null)
				m_soundHoldI.Stop();
			@m_soundHoldI = m_soundHold.PlayTracked(m_owner.m_unit.GetPosition());
		}

		void StopHoldSound()
		{
			if (m_soundHold is null || m_soundHoldI is null)
				return;
			m_soundHoldI.Stop();
			@m_soundHoldI = null;
		}

		void Hold(int dt, vec2 target) override
		{
			if (m_soundHoldI is null)
				StartHoldSound();
		}

		void NetHold(int dt, vec2 target) override
		{
			if (m_soundHoldI is null)
				StartHoldSound();
		}
		
		bool Activate(vec2 target) override
		{
			int targetSz = 0;
			TargetingMode targetMode = GetTargetingMode(targetSz);

			if (m_cooldownC > 0)
			{
				m_owner.WarnCooldown(this, m_cooldownC);
				return false;
			}

			if (!m_owner.SpendCost(m_costMana, m_costStamina, m_costHealth))
				return false;
				
			if (m_skillId == 0)
				Tutorial::RegisterAction("attack1");
			else if (m_skillId == 1)
				Tutorial::RegisterAction("attack2");
		
			if (targetMode != TargetingMode::Toggle)
				m_cooldownC = m_cooldown;
			m_castingC = m_castpoint;

			PlaySound3D(m_soundStart, m_owner.m_unit.GetPosition());
			
			m_queuedTarget = target;
			m_animCountdown = m_owner.SetUnitScene(m_animation, true);

			(Network::Message("PlayerActiveSkillActivate") << int(m_skillId) << target).SendToAll();
			
			return true;
		}

		void NetActivate(vec2 target) override
		{
			m_animCountdown = m_owner.SetUnitScene(m_animation, true);

			int targetSz = 0;
			TargetingMode targetMode = GetTargetingMode(targetSz);

			if (targetMode == TargetingMode::Channeling)
				m_netHold = true;

			PlaySound3D(m_soundStart, m_owner.m_unit.GetPosition());
		}

		void Deactivate() override
		{
			int targetSz = 0;
			TargetingMode targetMode = GetTargetingMode(targetSz);

			if (targetMode == TargetingMode::Toggle)
				m_cooldownC = m_cooldown;

			(Network::Message("PlayerActiveSkillDeactivate") << int(m_skillId)).SendToAll();

			DoDeactivate();
		}

		void NetDeactivate() override
		{
			int targetSz = 0;
			TargetingMode targetMode = GetTargetingMode(targetSz);

			NetDoDeactivate();
		}

		void Release(vec2 target) override
		{
			StopHoldSound();

			(Network::Message("PlayerActiveSkillRelease") << int(m_skillId) << target).SendToAll();
		}

		void NetRelease(vec2 target) override
		{
			StopHoldSound();

			m_netHold = false;
		}
		
		void PlaySkillEffect(vec2 dir, dictionary ePs = { })
		{
			PlaySound3D(m_sound, m_owner.m_unit.GetPosition());
		
			if (m_fx == "")
				return;
			
			ePs["angle"] = atan(dir.y, dir.x);
			PlayEffect(m_fx, xy(m_owner.m_unit.GetPosition()), ePs);
		}
		
		float GetMoveSpeedMul() override { return m_animCountdown <= 0 ? 1.0 : m_speedMul; }
		bool IsActive() override { return m_isActive || m_animCountdown > 0; }
		bool IsBlocking() override { return m_blocking; }

		void Update(int dt, bool walking) override
		{
			dt = int(m_timeScale * dt);

			if (m_soundHoldI !is null)
				m_soundHoldI.SetPosition(m_owner.m_unit.GetPosition());
		
			DoUpdate(dt);

			if (m_netHold)
			{
				auto player = cast<PlayerHusk>(m_owner);
				if (player !is null)
					NetHold(dt, player.m_dir);
			}
		
			m_animCountdown -= dt;
			if (m_animCountdown > 0)
				m_owner.SetUnitScene(m_animation, false);
		
		
			int mdt = int(dt * (walking ? 1.0f : m_idleCdMul));
		
			if (m_cooldownC > 0)
				m_cooldownC -= mdt;
		
			if (m_castingC > 0)
			{
				m_castingC -= mdt;
				if (m_castingC <= 0)
				{
					//PlaySkillEffect(m_queuedTarget);

					SValue@ svalNetParams = null;

					if (NeedNetParams())
					{
						SValueBuilder builder;
						DoActivate(builder, m_queuedTarget);
						@svalNetParams = builder.Build();
					}
					else
						DoActivate(null, m_queuedTarget);

					(Network::Message("PlayerActiveSkillDoActivate") << int(m_skillId) << m_queuedTarget << svalNetParams).SendToAll();
					
					if (m_burstC > 0)
					{
						if (--m_burstC <= 0)
							m_burstC = m_burst;
						else
							m_castingC = m_burstFreq;
					}
				}
			}
		}
		
		float GetCooldownProgess(int idt) { return clamp((m_cooldownC - idt) / float(m_cooldown), 0.0f, 1.0f); }
		void DoActivate(SValueBuilder@ builder, vec2 target) {}
		void DoDeactivate() {}
		void NetDoActivate(SValue@ param, vec2 target) {}
		void NetDoDeactivate() {}
		void DoUpdate(int dt) {}
		bool NeedNetParams() { return false; }
	}
}