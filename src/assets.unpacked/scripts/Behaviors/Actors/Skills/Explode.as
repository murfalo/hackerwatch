namespace Skills
{
	class Explode : ActiveSkill
	{
		array<IEffect@>@ m_effects;
		array<IEffect@>@ m_selfEffects;

		int m_radius;
		int m_minRadius;
		float m_distScaling;
		float m_selfDmg;
		float m_teamDmg;
		float m_enemyDmg;
		bool m_destroyProjectiles;
		
		int m_tickRate;
		int m_tickRateC;
		
		bool m_active;
		

		Explode(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			
			@m_effects = LoadEffects(unit, params);
			@m_selfEffects = LoadEffects(unit, params, "self-");
			
			m_minRadius = GetParamInt(unit, params, "min-radius", false, 0);
			m_radius = GetParamInt(unit, params, "radius", false, m_minRadius);
			m_distScaling = GetParamFloat(unit, params, "dist-scaling", false, 3);
			m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
			m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
			m_enemyDmg = GetParamFloat(unit, params, "enemy-dmg", false, 1);
			m_destroyProjectiles = GetParamBool(unit, params, "destroy-projectiles", false, false);
		
			m_tickRate = GetParamInt(unit, params, "tick-rate", false, 0);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
			PropagateWeaponInformation(m_selfEffects, id + 1);
		}
		
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return m_tickRate > 0 ? TargetingMode::Channeling : TargetingMode::Direction;
		}
		
		bool Activate(vec2 target) override
		{
			if (m_cooldownC > 0)
			{
				m_owner.WarnCooldown(this, m_cooldownC);
				return false;
			}
			
			if (m_tickRate == 0)
			{
				if (!Trigger(target))
					return false;
			}
			else
				m_tickRateC = m_tickRate;

			m_cooldownC = m_cooldown;
			m_castingC = m_castpoint;
			m_queuedTarget = target;

			m_animCountdown = m_owner.SetUnitScene(m_animation, true);
			m_active = true;

			//NOTE: We override ActiveSkill::Activate() here instead of DoActivate because we don't want to spend mana on first activation
			//      That's also why we explicitly send the network message here
			(Network::Message("PlayerActiveSkillActivate") << int(m_skillId) << target).SendToAll();
			return true;
		}

		void NetActivate(vec2 target) override
		{
			m_animCountdown = m_owner.SetUnitScene(m_animation, true);
			m_active = true;
			
			if (m_tickRate == 0)
				NetTrigger(target);
			else
				m_netHold = true;
		}

		void DoTrigger(vec2 dir)
		{
			m_tickRateC = m_tickRate;
			PlaySkillEffect(dir);

			DoExplosion(m_owner, xy(m_owner.m_unit.GetPosition()), dir, 1.0, false);
		}

		bool Trigger(vec2 dir)
		{
			if (!m_owner.SpendCost(m_costMana, m_costStamina, m_costHealth))
				return false;
		
			DoTrigger(dir);
			return true;
		}

		bool NetTrigger(vec2 dir)
		{
			m_tickRateC = m_tickRate;
			PlaySkillEffect(dir);
			
			DoExplosion(m_owner, xy(m_owner.m_unit.GetPosition()), dir, 1.0, true);
			return true;
		}

		void Hold(int dt, vec2 target) override
		{
			if (!m_active)
				return;

			m_animCountdown = m_tickRate;
			m_cooldownC = m_cooldown;
			m_castingC = m_castpoint;

			m_tickRateC -= dt;
			if (m_tickRateC <= 0)
				Trigger(target);

			ActiveSkill::Hold(dt, target);
		}

		void NetHold(int dt, vec2 target) override
		{
			m_animCountdown = m_tickRate;
			m_tickRateC -= dt;
			if (m_tickRateC <= 0)
				NetTrigger(target);

			ActiveSkill::NetHold(dt, target);
		}

		void Release(vec2 target) override
		{
			ActiveSkill::Release(target);
			m_active = false;
		}

		void NetRelease(vec2 target) override
		{
			ActiveSkill::NetRelease(target);
			m_active = false;
		}

		void DoUpdate(int dt) override
		{
		}
		
		bool DoExplosion(Actor@ owner, vec2 pos, vec2 dir, float intensity, bool husk)
		{
			ApplyEffects(m_selfEffects, owner, owner.m_unit, pos, dir, intensity, husk);
			
			if (m_destroyProjectiles)
			{
				array<UnitPtr>@ projs = g_scene.FetchUnitsWithBehavior("IProjectile", pos, m_radius, true);
				for (uint i = 0; i < projs.length(); i++)
				{
					auto proj = cast<IProjectile>(projs[i].GetScriptBehavior());
					if (proj is null)
						continue;
					
					if (proj.IsBlockable())
						projs[i].Destroy();
				}
			}
			
			array<UnitPtr>@ directHits;
			
			if (m_minRadius > 0)
				@directHits = g_scene.QueryCircle(pos, m_minRadius, ~0, RaycastType::Shot, true);
			else
				@directHits = array<UnitPtr>();
				
			auto results = g_scene.QueryCircle(pos, m_radius, ~0, RaycastType::Shot, true);
			for (uint i = 0; i < results.length(); i++)
			{
				UnitPtr unit = results[i];
				vec2 upos = xy(unit.GetPosition());
				
				bool visible = true;
				float hitDist = m_radius + 1;
				
				for (uint j = 0; j < directHits.length(); j++)
				{
					if (results[i] == directHits[j])
					{
						hitDist = 0;
						break;
					}
				}
				
				if (hitDist > 0)
				{
					auto rayResults = g_scene.Raycast(pos, upos, ~0, RaycastType::Shot);
					if (rayResults.length() <= 0)
						hitDist = 0;
					
					for (uint j = 0; j < rayResults.length(); j++)
					{
						UnitPtr res_unit = rayResults[j].FetchUnit(g_scene);
						if (!res_unit.IsValid())
							continue;

						if (res_unit == unit)
						{
							hitDist = max(0.0, rayResults[j].fraction * length(upos - pos) - m_minRadius);
							upos = rayResults[j].point;
							break;
						}

						auto b = res_unit.GetScriptBehavior();
						auto d = cast<IDamageTaker>(b);
						if (d is null || d.Impenetrable())
						{
							visible = false;
							break;
						}
					}
				}

				if (!visible)
					continue;

				float d = 1.0;
				if (m_radius > m_minRadius)
					d = max(0.0, 1.0 - pow(hitDist / (m_radius - m_minRadius), m_distScaling));

				ApplyEffects(m_effects, owner, unit, upos, dir, intensity * d, husk, m_selfDmg, m_teamDmg, m_enemyDmg);
			}

			return true;
		}
	}
}