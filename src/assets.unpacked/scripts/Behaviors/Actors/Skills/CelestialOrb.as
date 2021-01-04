namespace Skills
{
	class CelestialOrb
	{
		int m_index;
		CelestialOrbs@ m_skill;

		int m_intervalC;

		vec2 m_offset;

		vec2 m_overrideTarget;
		bool m_overrideTargetSet;

		UnitPtr m_target;
		UnitPtr m_beam;

		SoundInstance@ m_sndI;

		CelestialOrb(int index, CelestialOrbs@ skill)
		{
			m_index = index;
			@m_skill = skill;

			m_intervalC = m_skill.m_effectInterval;
		}

		vec2 GetOwnerPosition()
		{
			return xy(m_skill.m_owner.m_unit.GetPosition());
		}

		vec2 GetOrbPosition()
		{
			return xy(m_skill.m_owner.m_unit.GetPosition()) + m_offset;
		}

		vec2 GetTargetPosition()
		{
			if (m_overrideTargetSet)
				return m_overrideTarget;
			return xy(m_target.GetPosition());
		}

		float GetOrbBeamDirection()
		{
			vec2 orbPos = GetOrbPosition();
			vec2 actorPos = GetTargetPosition();
			vec2 dir = normalize(actorPos - orbPos);
			return atan(dir.y, dir.x);
		}

		float GetOrbBeamLength()
		{
			vec2 orbPos = GetOrbPosition();
			vec2 actorPos = GetTargetPosition();
			return dist(orbPos, actorPos);
		}

		void RefreshScene(CustomUnitScene@ scene)
		{
			int layerOffset = 0;
			if (m_offset.y < 0)
				layerOffset = -1;
			scene.AddScene(m_skill.m_orbFx, 0, m_offset, layerOffset, 0);
		}

		void Update(int dt)
		{
			UnitPtr newTarget;

			// Check if we should override the target
			auto owner = cast<PlayerBase>(m_skill.m_owner);
			if (owner !is null)
			{
				Skills::ShootBeam@ skillBeam = null;
				for (uint i = 0; i < owner.m_skills.length(); i++)
				{
					auto s = cast<Skills::ShootBeam>(owner.m_skills[i]);
					if (s is null)
						continue;

					@skillBeam = s;
					break;
				}

				if (skillBeam !is null)
				{
					m_overrideTargetSet = skillBeam.m_isUnitHit;

					if (m_overrideTargetSet)
					{
						m_overrideTarget = skillBeam.m_unitHitPos;
						newTarget = skillBeam.m_unitHit;
					}
				}
			}

			// Find offset of orb from player
			float angle = (m_index / float(m_skill.m_numOrbs)) * PI * 2;
			angle += m_skill.m_tmNow / 1000.0f;
			vec2 dir = vec2(cos(angle), sin(angle));

			float distance;
			vec2 ownerPos = GetOwnerPosition();
			auto rayRes = g_scene.Raycast(ownerPos, ownerPos + dir * m_skill.m_orbDistance, ~0, RaycastType::Shot);
			if (rayRes.length() > 0)
				distance = max(0.0f, dist(ownerPos, rayRes[0].point) - 4.0f);
			else
				distance = m_skill.m_orbDistance;
			m_offset = dir * distance;

			vec2 orbPos = GetOrbPosition();

			if (!m_overrideTargetSet)
			{
				// Find closest unit
				float closestDistance = (m_skill.m_orbRange * m_skill.m_orbRange) + 1.0f;

				array<UnitPtr>@ results = g_scene.FetchActorsWithOtherTeam(m_skill.m_owner.Team, orbPos, m_skill.m_orbRange);
				for (uint i = 0; i < results.length(); i++)
				{
					Actor@ actor = cast<Actor>(results[i].GetScriptBehavior());
					if (!actor.IsTargetable())
						continue;

					bool canSee = true;
					auto canSeeRes = g_scene.Raycast(orbPos, xy(results[i].GetPosition()), ~0, RaycastType::Shot);
					for (uint j = 0; j < canSeeRes.length(); j++)
					{
						UnitPtr canSeeUnit = canSeeRes[j].FetchUnit(g_scene);
						if (canSeeUnit == results[i])
							break;

						auto canSeeActor = cast<Actor>(canSeeUnit.GetScriptBehavior());
						if (canSeeActor is m_skill.m_owner)
							continue;

						canSee = false;
						break;
					}
					if (!canSee)
						continue;

					vec2 actorPos = xy(results[i].GetPosition());
					float d = distsq(orbPos, actorPos);
					if (d < closestDistance)
					{
						newTarget = results[i];
						closestDistance = d;
					}
				}
			}

			// Start, stop, or update beam
			UnitPtr prevTarget = m_target;
			m_target = newTarget;

			if (!prevTarget.IsValid() && newTarget.IsValid())
				BeamStart();
			else if (prevTarget.IsValid() && !newTarget.IsValid())
				BeamStop();
			else if (m_beam.IsValid())
			{
				m_sndI.SetPosition(xyz(orbPos));
				m_beam.SetPosition(xyz(orbPos));
				auto beamBehavior = cast<EffectBehavior>(m_beam.GetScriptBehavior());
				if (beamBehavior !is null)
				{
					beamBehavior.SetParam("angle", GetOrbBeamDirection());
					beamBehavior.SetParam("length", GetOrbBeamLength());
				}
			}

			// Maybe apply effects
			m_intervalC -= dt;
			if (m_intervalC <= 0)
			{
				m_intervalC += m_skill.m_effectInterval;
				vec2 targetPos = GetTargetPosition();
				vec2 targetDir = normalize(targetPos - orbPos);
				ApplyEffects(m_skill.m_effects, m_skill.m_owner, m_target, targetPos, targetDir, 1.0f, m_skill.m_owner.IsHusk());
			}
		}

		void BeamStart()
		{
			vec2 orbPos = GetOrbPosition();

			dictionary ePs = {
				{ 'angle', GetOrbBeamDirection() },
				{ 'length', GetOrbBeamLength() }
			};
			m_beam = PlayEffect(m_skill.m_orbBeamFx, orbPos, ePs);

			@m_sndI = m_skill.m_snd.PlayTracked(xyz(orbPos));

			auto behavior = cast<EffectBehavior>(m_beam.GetScriptBehavior());
			behavior.m_looping = true;
		}

		void BeamStop()
		{
			if (m_beam.IsValid())
				m_beam.Destroy();

			m_beam = UnitPtr();

			if (m_sndI !is null)
				m_sndI.Stop();
				
			@m_sndI = null;
		}
	}

	class CelestialOrbs : Skill
	{
		int m_numOrbs;

		float m_orbDistance;
		int m_orbRange;
		UnitScene@ m_orbFx;
		UnitScene@ m_orbBeamFx;

		SoundEvent@ m_snd;

		int m_tmNow;

		array<IEffect@>@ m_effects;
		int m_effectInterval;

		array<CelestialOrb@> m_orbs;

		CelestialOrbs(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_numOrbs = GetParamInt(unit, params, "num-orbs");

			m_orbDistance = GetParamFloat(unit, params, "orb-distance");
			m_orbRange = GetParamInt(unit, params, "orb-range");
			@m_orbFx = Resources::GetEffect(GetParamString(unit, params, "orb-fx"));
			@m_orbBeamFx = Resources::GetEffect(GetParamString(unit, params, "orb-beam-fx"));

			@m_snd = Resources::GetSoundEvent(GetParamString(unit, params, "orb-snd"));

			@m_effects = LoadEffects(unit, params);
			m_effectInterval = GetParamInt(unit, params, "effect-interval");

			for (int i = 0; i < m_numOrbs; i++)
				m_orbs.insertLast(CelestialOrb(m_orbs.length(), this));
		}

		void RefreshScene(CustomUnitScene@ scene) override
		{
			for (uint i = 0; i < m_orbs.length(); i++)
				m_orbs[i].RefreshScene(scene);
		}

		void Update(int dt, bool walking) override
		{
			m_tmNow += dt;

			for (uint i = 0; i < m_orbs.length(); i++)
				m_orbs[i].Update(dt);
		}
		
		void OnDestroy() override
		{
			for (uint i = 0; i < m_orbs.length(); i++)
				m_orbs[i].BeamStop();
		}
	}
}
