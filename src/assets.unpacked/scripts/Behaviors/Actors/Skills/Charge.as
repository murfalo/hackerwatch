namespace Skills
{
	class Charge : ActiveSkill
	{
		array<IEffect@>@ m_effects;
		array<IEffect@>@ m_hitEffects;

		int m_speed;
		int m_duration;
		int m_durationC;
		vec2 m_dir;
		int m_dustC;
		string m_dustFx;
		bool m_husk;
		array<UnitPtr> m_hitUnits;
		
		string m_hitFx;
		SoundEvent@ m_hitSnd;

		bool m_hitSensors;
		bool m_stopOnHit;
		

		Charge(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			@m_effects = LoadEffects(unit, params);
			@m_hitEffects = LoadEffects(unit, params, "hit-");
			
			m_speed = GetParamInt(unit, params, "speed", false, 3);
			m_duration = GetParamInt(unit, params, "duration", false, 1000);
			m_durationC = 0;
			
			m_dustFx = GetParamString(unit, params, "dust-fx", false);
			
			m_hitFx = GetParamString(unit, params, "hit-fx", false);
			@m_hitSnd = Resources::GetSoundEvent(GetParamString(unit, params, "hit-snd", false));

			m_hitSensors = GetParamBool(unit, params, "hit-sensors", false);
			m_stopOnHit = GetParamBool(unit, params, "stop-on-hit", false);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
			PropagateWeaponInformation(m_hitEffects, id + 1);
			
			m_husk = cast<Player>(owner) is null;
		}
		
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			m_durationC = m_duration;
			m_dir = normalize(target);
			m_hitUnits.removeRange(0, m_hitUnits.length());
			cast<PlayerBase>(m_owner).SetCharging(true);
			PlaySkillEffect(m_dir);
		}
		
		void CancelCharge()
		{
			m_durationC = 0;
			cast<PlayerBase>(m_owner).SetCharging(false);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			cast<PlayerBase>(m_owner).SetCharging(true);
			PlaySkillEffect(target);

			m_durationC = m_duration;
			m_dir = normalize(target);
		}
		
		void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxOther) override
		{
			if (m_durationC <= 0)
				return;

			bool isSensor = fxOther.IsSensor();
			if (isSensor && !m_hitSensors)
				return;

			HitUnit(unit, pos, isSensor);
			/*
			else if (dot(normal, m_dir) > 0.75)
				CancelCharge();
			*/
		}
		
		void CollideWithSolid(UnitPtr unit, vec2 pos)
		{
			if (m_stopOnHit)
				CancelCharge();
				
			ApplyEffects(m_hitEffects, m_owner, unit, pos, m_dir, 1.0, m_husk);
		}
		
		vec2 GetMoveDir() override 
		{
			return (m_durationC > 0) ? (m_dir * m_speed) : vec2(); 
		}
		
		void PlayHitEffect(vec2 pos)
		{
			PlayEffect(m_hitFx, pos);
			PlaySound3D(m_hitSnd, xyz(pos));
		}

		bool HitUnit(UnitPtr unit, vec2 pos, bool sensor = false)
		{
			if (!unit.IsValid())
				return true;

			ref@ b = unit.GetScriptBehavior();

			if (cast<IProjectile>(b) !is null || cast<PlayerBase>(b) !is null || cast<PlayerOwnedActor>(b) !is null)
				return true;

			auto dt = cast<IDamageTaker>(b);
			if (dt !is null)
			{
				if (dt.ShootThrough(m_owner, pos, m_dir))
					return true;

				if (TryHit(unit))
				{
					ApplyEffects(m_effects, m_owner, unit, pos, m_dir, 1.0, m_husk, 0.0f, 0.0f, 1.0f);
					PlayHitEffect(pos);
					
					if (!dt.IsDead())
						CollideWithSolid(unit, pos);
					
					return !dt.Impenetrable();
				}
				
				return true;
			}

			if (TryHit(unit))
			{
				ApplyEffects(m_effects, m_owner, unit, pos, m_dir, 1.0f, m_husk, 0.0f, 0.0f, 1.0f);
				PlayHitEffect(pos);
				
				//if (!sensor)
				//	CollideWithSolid(unit, pos);
				
				return sensor;
			}
			
			return sensor;
		}
		
		bool TryHit(UnitPtr unit)
		{
			for (uint j = 0; j < m_hitUnits.length(); j++)
				if (m_hitUnits[j] == unit)
					return false;
				
			m_hitUnits.insertLast(unit);
			return true;
		}

		void DoUpdate(int dt) override
		{
			if (m_durationC > 0)
			{
				m_durationC -= g_wallDelta;
				m_owner.SetUnitScene(m_animation, false);
				
				m_dustC -= g_wallDelta;
				if (m_dustC <= 0)
				{
					m_dustC += randi(66) + 33;
					PlayEffect(m_dustFx, xy(m_owner.m_unit.GetPosition()));
				}
				
				vec2 from = xy(m_owner.m_unit.GetPosition()) ;//+ m_dir * 3;
				vec2 to = from + m_dir * m_speed * g_wallDelta / 33.0;
			
				array<RaycastResult>@ results = g_scene.RaycastWide(6, 12, from, to + m_dir * 3, ~0, RaycastType::Any);
				for (uint i = 0; i < results.length(); i++)
				{
					RaycastResult res = results[i];
					//if (res.fixture.IsSensor())
					//	continue;
					
					HitUnit(res.FetchUnit(g_scene), res.point, res.fixture.IsSensor());
				}
				
//				m_owner.m_unit.SetPosition(to.x, to.y, 0, true);

				if (m_durationC <= 0)
					CancelCharge();
			}
		}
	}
}