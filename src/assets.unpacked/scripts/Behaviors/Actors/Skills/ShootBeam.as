namespace Skills
{
	class BeamRayResult
	{
		int m_distSq;
		vec2 m_point;
		UnitPtr m_unit;

		int opCmp(const BeamRayResult &other)
		{
			if (m_distSq < other.m_distSq)
				return -1;
			else if (m_distSq > other.m_distSq)
				return 1;
			return 0;
		}
	}

	class ShootBeam : ActiveSkill
	{
		UnitPtr m_unitBeamFx;
		SoundInstance@ m_beamSndI;

		float m_distance;
		float m_width;

		SoundEvent@ m_hitSnd;
		string m_hitFx;

		float m_holdDir;
		float m_holdDirNext;

		float m_holdLength;
		float m_holdLengthNext;

		array<IEffect@>@ m_effects;
		array<IEffect@>@ m_effectsTeam;

		int m_interval;
		int m_intervalC;

		int m_buildupTime;
		int m_buildupTimeC;

		array<BeamRayResult> m_unitsHit;

		UnitPtr m_unitHit;
		bool m_isUnitHit;
		vec2 m_unitHitPos;

		ShootBeam(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_distance = GetParamFloat(unit, params, "distance", false, 100.0f);
			m_width = GetParamFloat(unit, params, "width", false, 4.0f);

			@m_hitSnd = Resources::GetSoundEvent(GetParamString(unit, params, "hit-snd", false));
			m_hitFx = GetParamString(unit, params, "hit-fx", false);

			@m_effects = LoadEffects(unit, params);
			@m_effectsTeam = LoadEffects(unit, params, "team-");

			m_interval = GetParamInt(unit, params, "interval", false, 100);

			m_buildupTime = GetParamInt(unit, params, "buildup-time", false, 1000);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
			PropagateWeaponInformation(m_effectsTeam, id + 1);
		}
		
		TargetingMode GetTargetingMode(int &out size) override { return TargetingMode::Channeling; }

		void Hold(int dt, vec2 target) override
		{
			HandleBeam(dt, target, false);

			ActiveSkill::Hold(dt, target);
		}

		void NetHold(int dt, vec2 target) override
		{
			HandleBeam(dt, target, true);

			ActiveSkill::NetHold(dt, target);
		}

		void HandleBeam(int dt, vec2 target, bool husk)
		{
			if (husk && !m_netHold)
				return;

			m_intervalC -= dt;

			m_cooldownC = m_cooldown;
			if (!husk)
				m_castingC = m_castpoint;

			bool intervalTrigger = (m_intervalC <= 0);
			bool withEffects = (/*!husk &&*/ intervalTrigger);
			if (withEffects)
			{
				m_intervalC += m_interval;
				if (!m_owner.SpendCost(m_costMana, m_costStamina, m_costHealth))
				{
					Release(target);
					return;
				}
			}

			vec2 pos = xy(m_owner.m_unit.GetPosition());
			vec2 posEndpoint = pos + target * m_distance;

			float posDirAngle = atan(target.y, target.x) + PI / 2;
			vec2 posDir = vec2(cos(posDirAngle), sin(posDirAngle)) * m_width;

			m_unitsHit.removeRange(0, m_unitsHit.length());
			DoBeamRay(1, pos, posEndpoint);
			DoBeamRay(2, pos - posDir, posEndpoint - posDir);
			DoBeamRay(3, pos + posDir, posEndpoint + posDir);

			vec2 posHit = posEndpoint;

			m_isUnitHit = false;

			m_unitsHit.sortAsc();
			for (uint i = 0; i < m_unitsHit.length(); i++)
			{
				BeamRayResult@ res = m_unitsHit[i];
				if (HandleHitUnit(res.m_unit, withEffects))
				{
					posHit = res.m_point;

					m_isUnitHit = true;
					m_unitHit = res.m_unit;
					break;
				}
			}

			float facing = atan(target.y, target.x);
			float length = dist(pos, posHit);

			if (m_isUnitHit)
				m_unitHitPos = pos + target * length;

			if (!m_unitBeamFx.IsValid())
			{
				if (intervalTrigger)
				{
					m_holdDir = m_holdDirNext = facing;
					m_holdLength = m_holdLengthNext = length;

					m_buildupTimeC = 0;

					vec3 uPos = m_owner.m_unit.GetPosition();

					dictionary ePs = {
						{ 'angle', m_holdDir },
						{ 'length', m_holdLength }
					};
					m_unitBeamFx = PlayEffect(m_fx, xy(uPos), ePs);

					if (m_sound !is null)
					{
						@m_beamSndI = m_sound.PlayTracked(uPos);
						m_beamSndI.SetLooped(true);
					}

					auto behavior = cast<EffectBehavior>(m_unitBeamFx.GetScriptBehavior());
					behavior.m_looping = true;

					m_preRenderables.insertLast(this);
				}
			}
			else
			{
				if (m_buildupTimeC < m_buildupTime)
					m_buildupTimeC += dt;

				m_holdDir = m_holdDirNext;
				m_holdLength = m_holdLengthNext;

				m_holdDirNext = facing;
				m_holdLengthNext = dist(pos, posHit);

				// deal with 360 to 0 wrapping
				if (abs(m_holdDirNext - m_holdDir) > PI / 2.0)
					m_holdDir = m_holdDirNext;
			}
		}

		void DestroyBeam()
		{
			if (!m_unitBeamFx.IsValid())
				return;

			m_unitBeamFx.Destroy();
			m_unitBeamFx = UnitPtr();

			if (m_beamSndI !is null)
			{
				m_beamSndI.Stop();
				@m_beamSndI = null;
			}

			m_buildupTimeC = 0;
		}
		
		void OnDestroy() override
		{
			DestroyBeam();
		}

		void Release(vec2 target) override
		{
			ActiveSkill::Release(target);
			DestroyBeam();

			m_isUnitHit = false;
		}

		void NetRelease(vec2 target) override
		{
			ActiveSkill::NetRelease(target);
			DestroyBeam();

			m_isUnitHit = false;
		}

		bool PreRender(int idt) override
		{
			if (!m_unitBeamFx.IsValid())
				return true;

			vec3 uPos = m_owner.m_unit.GetInterpolatedPosition(idt);

			m_beamSndI.SetPosition(uPos);
			m_unitBeamFx.SetPosition(uPos);

			auto behavior = cast<EffectBehavior>(m_unitBeamFx.GetScriptBehavior());
			if (behavior is null)
				return true;

			float mul = idt / 33.0f;
			behavior.SetParam("angle", lerp(m_holdDir, m_holdDirNext, mul));
			behavior.SetParam("length", lerp(m_holdLength, m_holdLengthNext, mul));

			return false;
		}

		float GetBuildupIntensity()
		{
			if (m_buildupTimeC > m_buildupTime)
				return 1.0f;

			return 0.25f + (m_buildupTimeC / float(m_buildupTime) * 0.75f);
		}

		void DoBeamRay(int id, vec2 pos, vec2 posEndpoint)
		{
			auto ray = g_scene.Raycast(pos, posEndpoint, ~0, RaycastType::Shot);
			for (uint i = 0; i < ray.length(); i++)
			{
				UnitPtr unit = ray[i].FetchUnit(g_scene);

				BeamRayResult result;
				result.m_distSq = int(distsq(pos, ray[i].point));
				result.m_point = ray[i].point;
				result.m_unit = unit;
				m_unitsHit.insertLast(result);
			}
		}

		bool HandleHitUnit(UnitPtr unit, bool withEffects)
		{
			vec2 upos = xy(unit.GetPosition());

			auto actor = cast<Actor>(unit.GetScriptBehavior());
			if (actor !is null && actor.Team == m_owner.Team)
			{
				if (withEffects)
					ApplyEffects(m_effectsTeam, m_owner, unit, upos, m_holdDir, GetBuildupIntensity(), false);
				return false;
			}

			if (withEffects)
				ApplyEffects(m_effects, m_owner, unit, upos, m_holdDir, GetBuildupIntensity(), false);

			if (actor !is null && actor.Team != m_owner.Team)
				return true;

			return (cast<IDamageTaker>(unit.GetScriptBehavior()) is null);
		}
	}
}
