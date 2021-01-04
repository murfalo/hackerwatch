namespace Skills
{
	class ShootRay : ActiveSkill
	{
		float m_distance;

		SoundEvent@ m_hitSnd;
		string m_hitFx;

		array<IAction@>@ m_actions;

		ShootRay(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_distance = GetParamFloat(unit, params, "dist", false, 50);

			@m_hitSnd = Resources::GetSoundEvent(GetParamString(unit, params, "hit-snd", false));
			m_hitFx = GetParamString(unit, params, "hit-fx", false);

			@m_actions = LoadActions(unit, params);
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) override
		{
			ActiveSkill::Initialize(owner, icon, id);
			PropagateWeaponInformation(m_actions, id + 1);
		}

		bool NeedNetParams() override { return true; }

		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			builder.PushArray();

			vec2 pos = xy(m_owner.m_unit.GetPosition());
			vec2 posHit = pos + target * m_distance;

			auto ray = g_scene.Raycast(pos, posHit, ~0, RaycastType::Shot);
			for (uint i = 0; i < ray.length(); i++)
			{
				UnitPtr unit = ray[i].FetchUnit(g_scene);
				if (!unit.IsValid())
					continue;

				if (cast<PlayerBase>(unit.GetScriptBehavior()) is null)
				{
					posHit = ray[i].point;
					break;
				}
			}

			builder.PushVector2(pos);
			builder.PushVector2(posHit);

			PlaySound3D(m_hitSnd, xyz(posHit));

			dictionary ePs = { { 'angle', atan(target.y, target.x) } };
			PlayEffect(m_hitFx, posHit, ePs);

			SValue@ params = DoActions(m_actions, m_owner, null, posHit, target);
			builder.PushSimple(params);

			builder.PopArray();
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			array<SValue@>@ pm = param.GetArray();

			vec2 pos = pm[0].GetVector2();
			vec2 posHit = pm[1].GetVector2();

			PlaySound3D(m_hitSnd, xyz(posHit));

			dictionary ePs = { { 'angle', atan(target.y, target.x) } };
			PlayEffect(m_hitFx, posHit, ePs);

			NetDoActions(m_actions, pm[2], m_owner, posHit, target);
		}
	}
}
