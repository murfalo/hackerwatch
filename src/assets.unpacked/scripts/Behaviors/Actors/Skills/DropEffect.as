namespace Skills
{
	class DropEffect : ActiveSkill, IOnDropped
	{
		UnitScene@ m_dropFx;
		UnitScene@ m_droppedFx;
		
		array<IEffect@>@ m_effects;

		int m_radius;
		float m_selfDmg;
		float m_teamDmg;
		float m_enemyDmg;
		
		int m_dropDist;
		vec2 m_offset;
		

		DropEffect(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			
			@m_effects = LoadEffects(unit, params);
			
			m_radius = GetParamInt(unit, params, "radius", true);
			m_selfDmg = GetParamFloat(unit, params, "self-dmg", false, 0);
			m_teamDmg = GetParamFloat(unit, params, "team-dmg", false, 0);
			m_enemyDmg = GetParamFloat(unit, params, "enemy-dmg", false, 1);
			
			@m_dropFx = Resources::GetEffect(GetParamString(unit, params, "drop-fx", false));
			@m_droppedFx = Resources::GetEffect(GetParamString(unit, params, "dropped-fx", false));
			m_dropDist = GetParamInt(unit, params, "drop-dist", false);
			m_offset = GetParamVec2(unit, params, "offset", false);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_effects, id + 1);
		}
		
		TargetingMode GetTargetingMode(int &out size) override
		{
			size = 0;
			return TargetingMode::Direction;
		}
		
		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			SpawnDropEffect(target);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			SpawnDropEffect(target);
		}
		
		void SpawnDropEffect(vec2 dir)
		{
			PlaySkillEffect(dir);
			vec2 pos = xy(m_owner.m_unit.GetPosition()) + dir * m_dropDist;
			
			if (m_dropFx is null)
				return;
		
			float Height = 100.0;
			float InitialFallSpeed = 0.2;
			float MaxFallSpeed = 0.6;
			float FallSpeedMultiplier = 1.15;
			
			auto prod = Resources::GetUnitProducer("system/drop_spawn.unit");
			UnitPtr u = prod.Produce(g_scene, xyz(pos));
			u.SetUnitScene(m_dropFx, true);
			
			auto dropper = cast<DropSpawnBehavior>(u.GetScriptBehavior());
			dropper.Initialize(this, null, InitialFallSpeed, MaxFallSpeed, FallSpeedMultiplier, Height);
		}
		
		void OnDropped(DropSpawnBehavior@ dropSpawn, UnitPtr unit)
		{
			DoExplosion(m_owner, xy(unit.GetPosition()), m_owner.IsHusk());
		}

		bool DoExplosion(Actor@ owner, vec2 pos, bool husk)
		{
			PlayEffect(m_droppedFx, pos);
		
			auto results = g_scene.QueryCircle(pos, m_radius, ~0, RaycastType::Shot, true);
			
			int num = 0;
			for (uint i = 0; i < results.length(); i++)
			{
				auto a = cast<Actor>(results[i].GetScriptBehavior());
				
				if (a is null)
					continue;
				
				if (FilterAction(a, m_owner, m_selfDmg, m_teamDmg, m_enemyDmg) > 0)
					num++;
			}

			float intensity = (num > 0) ? (1.0f / num) : 1.0f;
			for (uint i = 0; i < results.length(); i++)
			{
				UnitPtr unit = results[i];
				vec2 upos = xy(unit.GetPosition());

				ApplyEffects(m_effects, m_owner, unit, upos, vec2(), intensity, husk, m_selfDmg, m_teamDmg, m_enemyDmg);
			}

			return true;
		}
	}
}