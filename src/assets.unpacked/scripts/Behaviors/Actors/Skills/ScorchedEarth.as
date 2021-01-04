namespace Skills
{
	class ScorchedEarth : Skill
	{
		UnitProducer@ m_unit;
		float m_durationMul;

		ScorchedEarth(UnitPtr unit, SValue& params)
		{
			super(unit);
			@m_unit = Resources::GetUnitProducer(GetParamString(unit, params, "unit"));
			m_durationMul = GetParamFloat(unit, params, "duration-mul", true, 1.0f);
		}
		
		UnitPtr Trigger(vec2 pos, string scene, Actor@ owner, int duration, float intensity, bool husk, int id = 0)
		{
			auto unit = m_unit.Produce(g_scene, xyz(pos), id);
			unit.SetUnitScene(scene, true);
			
			if (owner !is null)
			{
				auto ownedUnit = cast<IOwnedUnit>(unit.GetScriptBehavior());
				if (ownedUnit !is null)
				{
					ownedUnit.Initialize(owner, intensity, husk);
				
					// TODO: Remove
					auto area = cast<DangerAreaBehavior>(ownedUnit);
					PropagateWeaponInformation(area.m_effects, m_skillId + 1);
					area.m_ttl = int(duration * m_durationMul);
				}
			}

			return unit;
		}
	}
	
	class ScorchEarth : IEffect, IAction
	{
		string m_scene;
		float m_chance;
		int m_duration;

		ScorchEarth(UnitPtr unit, SValue& params)
		{
			m_scene = GetParamString(unit, params, "scene");
			m_duration = GetParamInt(unit, params, "duration", false, 2000);
			m_chance = GetParamFloat(unit, params, "chance", false, 1.0);
		}
		
		void SetWeaponInformation(uint weapon) {}
		bool CanApply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity) override { return true; }

		bool Apply(Actor@ owner, UnitPtr target, vec2 pos, vec2 dir, float intensity, bool husk)
		{
			if (randf() > m_chance)
				return false;
		
			auto player = cast<PlayerBase>(owner);
			if (player !is null)
			{
				auto scorch = cast<ScorchedEarth>(player.m_skills[6]);
				if (scorch is null)
					return false;
			
				scorch.Trigger(pos, m_scene, owner, m_duration, intensity, husk);
			}

			return true;
		}
		
		void Update(int dt, int cooldown) override {}
		bool NeedNetParams() override { return false; }
		
		bool DoAction(SValueBuilder@ builder, Actor@ owner, Actor@ target, vec2 pos, vec2 dir, float intensity)
		{
			return Apply(owner, UnitPtr(), pos, dir, 1.0, false);
		}
		
		bool NetDoAction(SValue@ param, Actor@ owner, vec2 pos, vec2 dir)
		{
			return Apply(owner, UnitPtr(), pos, dir, 1.0, true);
		}
	}
}