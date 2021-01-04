namespace Skills
{
	class Shatter : Skill
	{
		float m_chance;
		Modifiers::EffectTrigger m_effectTrigger;
		float m_requiredHp;

		Skills::ShootProjectileFan@ m_skill;
		array<IAction@>@ m_actions;

		bool m_triggering;

		Shatter(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_chance = GetParamFloat(unit, params, "chance", false, 0.5);
			m_effectTrigger = Modifiers::ParseEffectTrigger(GetParamString(unit, params, "trigger", false, "kill"));
			m_requiredHp = GetParamFloat(unit, params, "required-hp", false, 1.0f);

			int skillIndex = GetParamInt(unit, params, "skill-index", false, -1);
			if (skillIndex != -1)
				@m_skill = cast<Skills::ShootProjectileFan>(cast<PlayerBase>(m_owner).m_skills[skillIndex]);

			@m_actions = LoadActions(unit, params);
		}

		void OnEnemyKilled(PlayerBase@ player, Actor@ enemy)
		{
			if (!player.m_record.local)
				return;

			if (m_triggering)
				return;

			if (m_effectTrigger != Modifiers::EffectTrigger::Kill)
				return; // What then??

			if (enemy.GetHealth() > m_requiredHp)
				return;

			if (randf() > m_chance)
				return;

			// Avoid going too far into the level
			auto pos = xy(enemy.m_unit.GetPosition());
			if (dist(xy(player.m_unit.GetPosition()), pos) > 250)
				return;

			m_triggering = true;

			if (m_skill !is null)
			{
				SValueBuilder builder;
				m_skill.DoShoot(builder, pos, vec2(1, 0));
				(Network::Message("PlayerActiveSkillDoActivate") << m_skill.m_skillId << vec2() << builder.Build()).SendToAll();
			}
			else
				Do(cast<PlayerBase>(m_owner), enemy);

			if (!enemy.IsDead())
				enemy.Kill(cast<PlayerBase>(m_owner), 0);

			m_triggering = false;
		}

		void Do(PlayerBase@ player, Actor@ enemy)
		{
			if (m_actions is null)
				return;

			SValue@ params = DoActions(m_actions, player, null, xy(enemy.m_unit.GetPosition()), vec2());
			(Network::Message("PlayerShatterActivate") << enemy.m_unit << params).SendToAll();
		}

		void NetDo(Actor@ enemy, SValue@ params)
		{
			if (enemy is null)
			{
				PrintError("Enemy behavior is null or not an actor!");
				return;
			}

			if (m_actions is null)
				return;

			NetDoActions(m_actions, params, m_owner, xy(enemy.m_unit.GetPosition()), vec2());
		}
	}
}
