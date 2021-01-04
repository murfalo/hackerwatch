namespace Skills
{
	interface IStackSkill
	{
		void AddStack(int num = 1);
		bool TakeStack(int num = 1);
		void NetAddStack(int num);
		void NetTakeStack(int num);
	}

	class StackSkill : Skill, IBuffWidgetInfo, IStackSkill
	{
		int m_timerC;
		int m_timer;

		int m_maxCount;
		int m_count;

		bool m_loseAll;

		UnitScene@ m_fxAddStack;
		UnitScene@ m_fxTakeStack;
		UnitScene@ m_fxLoseStack;

		ScriptSprite@ m_hud;

		bool m_destroyed;

		StackSkill(UnitPtr unit, SValue& params)
		{
			super(unit);

			m_timer = GetParamInt(unit, params, "duration", false, -1);
			m_maxCount = GetParamInt(unit, params, "max-stacks");

			m_loseAll = GetParamBool(unit, params, "lose-all", false);

			@m_fxAddStack = Resources::GetEffect(GetParamString(unit, params, "fx-add-stack", false));
			@m_fxTakeStack = Resources::GetEffect(GetParamString(unit, params, "fx-take-stack", false));
			@m_fxLoseStack = Resources::GetEffect(GetParamString(unit, params, "fx-lose-stack", false));

			auto arrIcon = GetParamArray(unit, params, "hud", false);
			if (arrIcon !is null)
				@m_hud = ScriptSprite(arrIcon);
		}

		void OnDestroy() override
		{
			m_destroyed = true;
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

			m_timerC = m_timer;
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
			if (m_timer == -1)
				return;

			if (m_count <= 0)
			{
				m_count = 0;
				return;
			}

			m_timerC -= dt;
			if (m_timerC > 0)
				return;

			if (m_loseAll)
				m_count = 0;
			else
				m_count--;

			if (m_count == 0)
				m_timerC = 0;
			else
				m_timerC += m_timer;

			RefreshCount();
			PlayEffect(m_fxLoseStack, m_owner.m_unit);
		}

		ScriptSprite@ GetBuffIcon()
		{
			return m_hud;
		}

		int GetBuffIconDuration()
		{
			if (m_destroyed)
				return 0;

			if (m_timer != -1)
				return m_timerC;
			else
				return m_count;
		}

		int GetBuffIconMaxDuration()
		{
			if (m_timer != -1)
				return m_timer;
			else
				return m_maxCount;
		}

		int GetBuffIconCount()
		{
			if (m_destroyed)
				return 0;
			return m_count;
		}
	}
}
