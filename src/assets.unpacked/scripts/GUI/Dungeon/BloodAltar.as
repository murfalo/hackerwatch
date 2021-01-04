namespace BloodAltar
{
	class Interface : UserWindow
	{
		WorldScript::RandomBuff@ m_script;

		bool m_accepted = false;

		ScalableSpriteButtonWidget@ m_wButtonYes;
		ScalableSpriteButtonWidget@ m_wButtonNo;
		TextWidget@ m_wReward;

		Interface(GUIBuilder@ b, WorldScript::RandomBuff@ script)
		{
			super(b, "gui/dungeon/bloodaltar.gui");

			@m_script = script;
		}

		void Show() override
		{
			UserWindow::Show();

			@m_wButtonYes = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("yes"));
			@m_wButtonNo = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("no"));
			@m_wReward = cast<TextWidget>(m_widget.GetWidgetById("reward"));

			PauseGame(true, true);
		}

		void Close() override
		{
			UserWindow::Close();

			PauseGame(false, true);
		}

		void OnFunc(Widget@ sender, string name) override
		{
			if (name == "no")
				Close();
			else if (name == "yes")
			{
				if (m_accepted)
				{
					Close();
					return;
				}

				m_accepted = true;

				auto reward = m_script.Accept();

				m_wButtonYes.m_enabled = false;
				m_wButtonNo.m_enabled = false;
				m_wReward.SetText(Resources::GetString(".bloodaltar.reward.prompt", { { "name", Resources::GetString(reward.name) } }));
			}
			else
				UserWindow::OnFunc(sender, name);
		}
	}

	class Reward
	{
		string id;
		uint idHash;

		string name;
		string description;

		ScriptSprite@ icon;

		array<Modifiers::Modifier@>@ modifiers;
		array<Modifiers::Modifier@>@ modifiersInc;
	}

	array<Reward@> g_rewards;

	void LoadRewards(SValue@ sv)
	{
		auto arrRewards = sv.GetArray();
		for (uint i = 0; i < arrRewards.length(); i++)
		{
			auto svReward = arrRewards[i];

			auto newReward = Reward();
			newReward.id = GetParamString(UnitPtr(), svReward, "id");
			newReward.idHash = HashString(newReward.id);

			newReward.name = GetParamString(UnitPtr(), svReward, "name");
			newReward.description = GetParamString(UnitPtr(), svReward, "description");

			@newReward.icon = ScriptSprite(GetParamArray(UnitPtr(), svReward, "icon"));

			@newReward.modifiers = Modifiers::LoadModifiers(UnitPtr(), svReward);
			@newReward.modifiersInc = Modifiers::LoadModifiers(UnitPtr(), svReward, "inc-");

			g_rewards.insertLast(newReward);
		}
	}

	Reward@ GetRandomReward()
	{
		int randomIndex = randi(g_rewards.length());
		return g_rewards[randomIndex];
	}

	Reward@ GetReward(uint id)
	{
		for (uint i = 0; i < g_rewards.length(); i++)
		{
			auto reward = g_rewards[i];
			if (reward.idHash == id)
				return reward;
		}
		return null;
	}

	Reward@ GetReward(const string &in id)
	{
		return GetReward(HashString(id));
	}
}
