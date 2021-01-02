namespace Skills
{
	class BuffAoe : ActiveSkill
	{
		ActorBuffDef@ m_buff;
		int m_timeActive;
		int m_range;
		int m_interval;
		int m_intervalC;

		array<Modifiers::Modifier@>@ m_modifiers;

		UnitScene@ m_auraFx;

		bool m_active;

		BuffAoe(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_timeActive = GetParamInt(unit, params, "active-time");
			m_range = GetParamInt(unit, params, "range");
			@m_buff = LoadActorBuff(GetParamString(unit, params, "buff"));
			m_interval = GetParamInt(unit, params, "interval");

			@m_modifiers = Modifiers::LoadModifiers(unit, params);

			@m_auraFx = Resources::GetEffect("effects/players/priest_cripple_aura.effect");
		}

		TargetingMode GetTargetingMode(int &out size) override { return TargetingMode::Toggle; }
		bool IgnoreForBlock() override { return true; }

		array<Modifiers::Modifier@>@ GetModifiers() override
		{
			if (m_active)
				return m_modifiers;

			return null;
		}

		void RefreshScene(CustomUnitScene@ scene) override
		{
			if (m_active)
				scene.AddScene(m_auraFx, 0, vec2(), 0, 0);
		}

		void DoActivate(SValueBuilder@ builder, vec2 target) override
		{
			m_active = true;

			auto player = cast<Player>(m_owner);
			if (player !is null)
				player.m_record.RefreshSkillModifiers();
		}

		void NetDoActivate(SValue@ param, vec2 target) override
		{
			m_active = true;
		}

		void DoDeactivate() override
		{
			m_active = false;

			auto player = cast<Player>(m_owner);
			if (player !is null)
				player.m_record.RefreshSkillModifiers();
		}

		void NetDoDeactivate() override
		{
			m_active = false;
		}

		void DoUpdate(int dt) override
		{
			if (!m_isActive)
				return;

			auto player = cast<Player>(m_owner);
			if (player is null)
				return;

			if (m_intervalC > 0)
			{
				m_intervalC -= dt;
				if (m_intervalC > 0)
					return;
			}
			m_intervalC = m_interval;

			array<UnitPtr>@ res = g_scene.FetchActorsWithOtherTeam(player.Team, xy(player.m_unit.GetPosition()), m_range);
			for (uint i = 0; i < res.length(); i++)
			{
				auto actor = cast<Actor>(res[i].GetScriptBehavior());
				if (actor is null)
					continue;

				actor.ApplyBuff(ActorBuff(player, m_buff, 1.0f, false));
			}
		}
	}
}
