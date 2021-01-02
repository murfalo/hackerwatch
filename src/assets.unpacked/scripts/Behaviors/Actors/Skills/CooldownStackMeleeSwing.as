namespace Skills
{
	class CooldownStackMeleeSwingModifier : Modifiers::Modifier
	{
		CooldownStackMeleeSwing@ m_skill;

		CooldownStackMeleeSwingModifier(CooldownStackMeleeSwing@ skill)
		{
			@m_skill = skill;
		}

		bool HasCooldownClear() override { return true; }
		bool CooldownClear(PlayerBase@ player, ActiveSkill@ skill) override
		{
			if (skill !is m_skill)
				return false;

			if (m_skill.m_cooldownC <= 0)
				return false;

			if (m_skill.m_count > 0)
				return m_skill.TakeStack();

			return false;
		}
	}

	class CooldownStackMeleeSwing : MeleeSwing, IBuffWidgetInfo, IStackSkill
	{
		int m_timer;
		int m_timerC;

		int m_maxCount;
		int m_count;

		bool m_loseAll;

		UnitScene@ m_fxAddStack;
		UnitScene@ m_fxTakeStack;
		UnitScene@ m_fxLoseStack;

		ScriptSprite@ m_hud;

		bool m_destroyed;

		array<Modifiers::Modifier@> m_modifiers;

		CooldownStackMeleeSwing(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_timerC = m_timer = GetParamInt(unit, params, "stack-duration");
			m_maxCount = GetParamInt(unit, params, "max-stacks");

			m_loseAll = GetParamBool(unit, params, "lose-all", false);

			@m_fxAddStack = Resources::GetEffect(GetParamString(unit, params, "fx-add-stack", false));
			@m_fxTakeStack = Resources::GetEffect(GetParamString(unit, params, "fx-take-stack", false));
			@m_fxLoseStack = Resources::GetEffect(GetParamString(unit, params, "fx-lose-stack", false));

			auto arrIcon = GetParamArray(unit, params, "hud", false);
			if (arrIcon !is null)
				@m_hud = ScriptSprite(arrIcon);

			m_modifiers.insertLast(CooldownStackMeleeSwingModifier(this));
		}

		array<Modifiers::Modifier@>@ GetModifiers() override { return m_modifiers; }

		void OnDestroy() override
		{
			m_destroyed = true;

			MeleeSwing::OnDestroy();
		}

		void AddStack(int num = 1)
		{
			NetAddStack(num);

			if (cast<Player>(m_owner) !is null)
				(Network::Message("PlayerStackSkillAdd") << m_skillId << num).SendToAll();
		}

		void NetAddStack(int num)
		{
			int countBefore = m_count;

			m_count = min(m_maxCount, m_count + num);

			RefreshCount();

			if (m_count > countBefore)
				PlayEffect(m_fxAddStack, m_owner.m_unit);
		}

		bool TakeStack(int num = 1)
		{
			if (num > m_count)
				return false;

			NetTakeStack(num);

			if (cast<Player>(m_owner) !is null)
				(Network::Message("PlayerStackSkillTake") << m_skillId << num).SendToAll();

			return true;
		}

		void NetTakeStack(int num)
		{
			m_count--;
			m_timerC = m_timer;
			RefreshCount();

			PlayEffect(m_fxTakeStack, m_owner.m_unit);
		}

		void RefreshCount()
		{
			BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
			auto player = cast<PlayerBase>(m_owner);
			if (gm is null || player is null)
				return;

			auto hud = GetHUD();
			if (hud !is null)
				hud.ShowBuffIcon(player, this);
		}

		void Update(int dt, bool walking) override
		{
			MeleeSwing::Update(dt, walking);

			if (m_count < m_maxCount)
			{
				m_timerC -= dt;
				if (m_timerC <= 0)
				{
					m_timerC = m_timer;
					AddStack();
				}
			}
		}

		ScriptSprite@ GetBuffIcon()
		{
			return m_hud;
		}

		int GetBuffIconDuration()
		{
			if (m_destroyed)
				return 0;

			int ret = m_timer - m_timerC;
			if (ret <= 0)
				return m_timer;

			return ret;
		}

		int GetBuffIconMaxDuration()
		{
			return m_timer;
		}

		int GetBuffIconCount()
		{
			if (m_destroyed)
				return 0;

			if (m_count == 0)
				return -1;
			return m_count;
		}
	}
}
