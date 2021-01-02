namespace Skills
{
	class TempBuffAoe : ActiveSkill
	{
		ActorBuffDef@ m_buff;
		ActorBuffDef@ m_buffTeam;
		int m_range;
		int m_interval;
		int m_intervalC;
		int m_activeTime;
		int m_activeTimeC;

		array<Modifiers::Modifier@>@ m_modifiers;

		UnitScene@ m_auraFx;

		TempBuffAoe(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_range = GetParamInt(unit, params, "range");
			@m_buff = LoadActorBuff(GetParamString(unit, params, "buff"));
			@m_buffTeam = LoadActorBuff(GetParamString(unit, params, "buff-team"));
			m_interval = GetParamInt(unit, params, "interval");
			m_activeTime = GetParamInt(unit, params, "active-time");

			@m_modifiers = Modifiers::LoadModifiers(unit, params);

			@m_auraFx = Resources::GetEffect(GetParamString(unit, params, "aura-fx"));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			if (m_activeTimeC > 0)
				return m_modifiers;

			return null;
		}

		void RefreshScene(CustomUnitScene@ scene) override
		{
			if (m_activeTimeC > 0)
				scene.AddScene(m_auraFx, 0, vec2(), 0, 0);
		}

		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			m_activeTimeC = m_activeTime;

			auto player = cast<Player>(m_owner);
			if (player !is null)
				player.RefreshModifiers();

			PlaySkillEffect(target);
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			m_activeTimeC = m_activeTime;

			PlaySkillEffect(target);
		}

		void DoUpdate(int dt) override
		{
			if (m_activeTimeC <= 0)
				return;

			m_activeTimeC -= dt;

			if (m_intervalC > 0)
			{
				m_intervalC -= dt;
				if (m_intervalC > 0)
					return;
			}
			m_intervalC = m_interval;

			auto player = cast<PlayerBase>(m_owner);
			if (player.m_record.local)
			{
				array<UnitPtr>@ res = g_scene.FetchActorsWithOtherTeam(player.Team, xy(player.m_unit.GetPosition()), m_range);
				for (uint i = 0; i < res.length(); i++)
				{
					auto actor = cast<Actor>(res[i].GetScriptBehavior());
					if (actor is null)
						continue;

					actor.ApplyBuff(ActorBuff(player, m_buff, 1.0f, false));
				}
			}

			array<UnitPtr>@ resTeam = g_scene.FetchActorsWithTeam(player.Team, xy(player.m_unit.GetPosition()), m_range);
			for (uint i = 0; i < resTeam.length(); i++)
			{
				auto actor = cast<PlayerBase>(resTeam[i].GetScriptBehavior());
				if (actor is null)
					continue;

				actor.ApplyBuff(ActorBuff(player, m_buffTeam, 1.0f, !actor.m_record.local));
			}
		}
	}
}
