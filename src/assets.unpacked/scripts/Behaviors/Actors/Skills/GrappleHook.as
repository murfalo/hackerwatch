namespace Skills
{
	class GrappleEvasionMod : Modifiers::Modifier
	{
		Skills::GrappleHook@ m_grapple;

		GrappleEvasionMod(Skills::GrappleHook@ grapple)
		{
			@m_grapple = grapple;
		}

		bool HasEvasion() override { return true; }
		bool Evasion(PlayerBase@ player, Actor@ enemy) override { return m_grapple.m_durationC > 0; }
	}

	class GrappleHook : ActiveSkill
	{
		array<IEffect@>@ m_effects;
		array<IEffect@>@ m_hitEffects;

		int m_speed;
		int m_durationC;
		vec2 m_to;
		int m_range;
		
		int m_dustC;
		string m_dustFx;
		bool m_husk;
		UnitPtr m_lastCollision;
		
		string m_hitFx;
		UnitScene@ m_chainFx;
		SoundEvent@ m_hitSnd;
		SoundEvent@ m_missSnd;

		array<Modifiers::Modifier@> m_modifiers;

		GrappleHook(UnitPtr unit, SValue& params)
		{
			super(unit, params);
		
			@m_effects = LoadEffects(unit, params);
			@m_hitEffects = LoadEffects(unit, params, "hit-");
			
			m_speed = GetParamInt(unit, params, "speed", false, 3);
			m_range = GetParamInt(unit, params, "range", false, 10);
			m_durationC = 0;
			
			m_dustFx = GetParamString(unit, params, "dust-fx", false);
			@m_chainFx = Resources::GetEffect(GetParamString(unit, params, "chain-fx", false));
			
			m_hitFx = GetParamString(unit, params, "hit-fx", false);
			@m_hitSnd = Resources::GetSoundEvent(GetParamString(unit, params, "hit-snd", false));
			@m_missSnd = Resources::GetSoundEvent(GetParamString(unit, params, "miss-snd", false));

			m_modifiers.insertLast(GrappleEvasionMod(this));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			return m_modifiers;
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
			PropagateWeaponInformation(m_hitEffects, id + 1);
			
			m_husk = false;
		}
		
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void MakeChain(vec2 from, vec2 to)
		{
			if (m_chainFx is null)
				return;
		
			int numChains = int(dist(from, to) / 4);
			vec2 d = normalize(to - from);
			
			for (int i = 1; i < numChains; i++)
			{
				auto u = PlayEffect(m_chainFx, from + d * 4 * i);
				auto fx = cast<EffectBehavior>(u.GetScriptBehavior());
				fx.m_ttl = int(i * 4.0f / m_speed * 33.0f);
			}
		}

		bool NeedNetParams() override { return true; }

		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			auto from = xy(m_owner.m_unit.GetPosition());
			vec2 to = from + target * m_range;
			int toRadius = 0;
			UnitPtr hitUnit;

			auto results = g_scene.RaycastWide(3, 2, from, to, ~0, RaycastType::Shot);
			for (uint j = 0; j < results.length(); j++)
			{
				RaycastResult res = results[j];
				UnitPtr res_unit = res.FetchUnit(g_scene);
				
				auto actor = cast<Actor>(res_unit.GetScriptBehavior());
				if (actor !is null && actor.Team == m_owner.Team)
					continue;

				auto body = res_unit.GetPhysicsBody();
				if (body !is null)
					toRadius = body.GetEstimatedRadius();
				
				to = res.point;
				hitUnit = res_unit;
				break;
			}

			builder.PushArray();
			builder.PushVector2(from);
			builder.PushVector2(to);
			builder.PushBoolean(hitUnit.IsValid());
			builder.PopArray();
			
			MakeChain(from, to);
		
			if (!hitUnit.IsValid())
			{
				PlaySound3D(m_missSnd, xyz(from));
				return;
			}
			
			PlaySound3D(m_hitSnd, xyz(from));
			ApplyEffects(m_effects, m_owner, hitUnit, to, target, 1.0f, m_husk);
		
			float ds = dist(from, to) - (toRadius + 4);
			if (ds <= 3.5f)
				return;

			m_durationC = int(ds / m_speed * 33.f);
			m_to = to;
			m_lastCollision = UnitPtr();
			PlaySkillEffect(target);
			cast<PlayerBase>(m_owner).SetCharging(true);
		}
		
		void CancelCharge()
		{
			m_durationC = 0;
			cast<PlayerBase>(m_owner).SetCharging(false);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			auto arr = param.GetArray();
			vec2 from = arr[0].GetVector2();
			vec2 to = arr[1].GetVector2();
			bool hasHit = arr[2].GetBoolean();

			MakeChain(from, to);

			if (!hasHit)
			{
				PlaySound3D(m_missSnd, xyz(from));
				return;
			}

			PlaySound3D(m_hitSnd, xyz(from));

			cast<PlayerBase>(m_owner).SetCharging(true);
			PlaySkillEffect(target);
		}
		
		void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxOther) override
		{
			if (m_durationC <= 0)
				return;
			
			HitUnit(unit, pos, normal * -1, fxOther.IsSensor());
		}
		
		vec2 GetMoveDir() override 
		{
			return (m_durationC > 0) ? (normalize(m_to - xy(m_owner.m_unit.GetPosition())) * m_speed) : vec2(); 
		}
		
		bool HitUnit(UnitPtr unit, vec2 pos, vec2 dir, bool sensor = false)
		{
			if (!unit.IsValid())
				return true;
			
			ref@ b = unit.GetScriptBehavior();
			IProjectile@ p = cast<IProjectile>(b);
			if (p !is null)
				return true;
			
			auto dt = cast<IDamageTaker>(b);
			if (dt !is null)
			{
				if (dt.ShootThrough(m_owner, pos, dir))
					return true;

				if (m_lastCollision != unit)
				{
					m_lastCollision = unit;
					ApplyEffects(m_hitEffects, m_owner, unit, pos, dir, 1.0, m_husk);
					
					return !dt.Impenetrable();
				}
			}

			if (m_lastCollision != unit)
			{
				m_lastCollision = unit;
				ApplyEffects(m_hitEffects, m_owner, unit, pos, dir, 1.0f, m_husk);
				return sensor;
			}
			
			return sensor;
		}


		void DoUpdate(int dt) override
		{
			if (m_durationC <= 0)
				return;
		
			m_owner.SetUnitScene(m_animation, false);
			
			m_dustC -= g_wallDelta;
			if (m_dustC <= 0)
			{
				m_dustC += randi(66) + 33;
				PlayEffect(m_dustFx, xy(m_owner.m_unit.GetPosition()));
			}
			
			
			vec2 from = xy(m_owner.m_unit.GetPosition()) ;//+ m_dir * 3;
			vec2 to = from + GetMoveDir() * g_wallDelta / 33.0;
		
			array<RaycastResult>@ results = g_scene.Raycast(from, to, ~0, RaycastType::Any);
			for (uint i = 0; i < results.length(); i++)
			{
				RaycastResult res = results[i];
				//if (res.fixture.IsSensor())
				//	continue;
				
				if (!HitUnit(res.FetchUnit(g_scene), res.point, res.normal * -1, res.fixture.IsSensor()))
				{
					CancelCharge();
					return;
				}
			}
			
			//m_owner.m_unit.SetPosition(to.x, to.y, 0, true);
			
			
			if (m_durationC > 0)
			{
				m_durationC -= g_wallDelta;
				if (m_durationC <= 0)
					CancelCharge();
			}
			if (distsq(from, m_to) <= 4.0f * 4.0f)
				CancelCharge();
		}
	}
}
