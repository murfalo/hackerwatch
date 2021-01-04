%if TOOLKIT
namespace Toolkits
{
	class ActorState
	{
		string m_name;
		int m_num;
		int m_length;
	}

	[Toolkit]
	class ActorViewer : TestSceneTool
	{
		array<UnitPtr> m_units;

		UnitProducer@ m_prod;
		string m_prodPath;

		array<ActorState@> m_states;

		ActorState@ m_currentState;
		float m_distance = 30.0f;
		bool m_loopScenes = false;
		bool m_showLocators = false;

		ActorViewer(ToolkitScript@ script)
		{
			super(script);

			m_panning.SetScale(4.0f);
			m_panning.Center();
		}

		ActorState@ GetActorState(const string &in name)
		{
			for (uint i = 0; i < m_states.length(); i++)
			{
				auto state = m_states[i];
				if (state.m_name == name)
					return state;
			}
			return null;
		}

		void LoadActor(const string &in path)
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Destroy();
			m_units.removeRange(0, m_units.length());
			m_states.removeRange(0, m_states.length());

			@m_prod = Resources::GetUnitProducer(path);
			m_prodPath = path;

			m_script.UpdateFileWatch();

			if (m_prod is null)
				return;

			auto arrScenes = m_prod.GetUnitScenes();
			for (uint i = 0; i < arrScenes.length(); i++)
			{
				auto scene = arrScenes[i];

				auto arrName = scene.GetName().split("-");
				if (arrName.length() == 1)
				{
					auto newState = ActorState();
					newState.m_name = scene.GetName();
					newState.m_num = 1;
					newState.m_length = scene.Length();
					m_states.insertLast(newState);
					continue;
				}

				string stateName = arrName[0];
				for (uint j = 1; j < arrName.length() - 1; j++)
					stateName += "-" + arrName[j];

				auto actorState = GetActorState(stateName);
				if (actorState is null)
				{
					@actorState = ActorState();
					actorState.m_name = stateName;
					m_states.insertLast(actorState);
				}

				int num = parseInt(arrName[arrName.length() - 1]) + 1;
				if (num > actorState.m_num)
					actorState.m_num = num;

				int len = scene.Length();
				if (len > actorState.m_length)
					actorState.m_length = len;
			}

			print("States:");
			for (uint i = 0; i < m_states.length(); i++)
			{
				auto state = m_states[i];
				print("  \"" + state.m_name + "\" with " + state.m_num + " angles");
			}

			@m_currentState = GetActorState("idle");
			if (m_currentState is null)
				@m_currentState = m_states[0];

			SpawnActor();
		}

		vec3 GetUnitPos(float rotationFactor)
		{
			vec3 ret;
			ret.x = cos(rotationFactor * PI * 2);
			ret.y = sin(rotationFactor * PI * 2);
			return ret * -m_distance;
		}

		void SpawnActor()
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Destroy();
			m_units.removeRange(0, m_units.length());

			if (m_currentState is null)
				return;

			if (m_currentState.m_num == 1)
			{
				UnitPtr unit = m_prod.Produce(m_scene, vec3());
				unit.SetUnitScene(m_currentState.m_name, true);
				m_units.insertLast(unit);
			}
			else
			{
				for (int i = 0; i < m_currentState.m_num; i++)
				{
					UnitPtr unit = m_prod.Produce(m_scene, vec3());
					unit.SetUnitScene(m_currentState.m_name + "-" + i, true);
					m_units.insertLast(unit);
				}
			}

			RepositionActor();
		}

		void RepositionActor()
		{
			for (uint i = 0; i < m_units.length(); i++)
			{
				float rotationFactor = i / float(m_currentState.m_num);
				vec3 unitPos = GetUnitPos(rotationFactor);

				m_units[i].SetPosition(unitPos);
			}
		}

		int GetActorTime()
		{
			if (m_units.length() == 0)
				return 0;

			return m_units[0].GetUnitSceneTime();
		}

		void SetActorTime(int time)
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].SetUnitSceneTime(time);
		}

		void Save(SValueBuilder@ builder) override
		{
			TestSceneTool::Save(builder);

			if (m_prod !is null)
				builder.PushString("unit", m_prodPath);

			if (m_currentState !is null)
				builder.PushString("state", m_currentState.m_name);

			builder.PushFloat("distance", m_distance);
			builder.PushBoolean("loop-scenes", m_loopScenes);
			builder.PushBoolean("show-locators", m_showLocators);
		}

		void Load(SValue@ data) override
		{
			TestSceneTool::Load(data);

			string strUnit = GetParamString(UnitPtr(), data, "unit", false);
			if (strUnit != "")
				LoadActor(strUnit);

			@m_currentState = GetActorState(GetParamString(UnitPtr(), data, "state", false));
			SpawnActor();

			m_distance = GetParamFloat(UnitPtr(), data, "distance", false, m_distance);
			RepositionActor();

			m_loopScenes = GetParamBool(UnitPtr(), data, "loop-scenes", false, m_loopScenes);

			m_showLocators = GetParamBool(UnitPtr(), data, "show-locators", false, m_showLocators);
		}

		void OnMouseDown(vec2 pos, int button) override
		{
			if (button == 3)
				SetActorTime(0);

			TestSceneTool::OnMouseDown(pos, button);
		}

		void OnResourcesReloaded()
		{
			string currentState = m_currentState !is null ? m_currentState.m_name : "";

			int actorTime = GetActorTime();

			LoadActor(m_prodPath);

			auto newState = GetActorState(currentState);
			if (newState !is null)
			{
				@m_currentState = newState;
				SpawnActor();
			}

			SetActorTime(actorTime);

			m_script.UpdateFileWatch();
		}

		void ResourcesToReload(array<string>@ res) override
		{
			TestSceneTool::ResourcesToReload(res);

			if (m_prod !is null)
				res.insertLast(m_prodPath);
		}

		void Update(int dt) override
		{
			TestSceneTool::Update(dt);

			if (m_loopScenes && m_units.length() > 0 && m_currentState !is null)
			{
				int time = m_units[0].GetUnitSceneTime();
				if (time >= m_currentState.m_length)
				{
					int delta = time - m_currentState.m_length;
					SetActorTime(delta % m_currentState.m_length);
				}
			}
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			TestSceneTool::Render(sb, idt);

			if (UI::Begin("Actor Viewer"))
			{
				if (m_currentState is null)
					UI::Text("No actor loaded.");
				else
				{
					if (UI::BeginCombo("State", m_currentState.m_name))
					{
						for (uint i = 0; i < m_states.length(); i++)
						{
							auto state = m_states[i];

							if (UI::Selectable(state.m_name, state is m_currentState))
							{
								@m_currentState = state;
								SpawnActor();
							}

							if (state is m_currentState)
								UI::SetItemDefaultFocus();
						}
						UI::EndCombo();
					}

					UI::LabelText("Angles", m_currentState.m_num);

					float d = UI::SliderFloat("Distance", m_distance, -100.0f, 100.0f);
					if (d != m_distance)
					{
						m_distance = d;
						RepositionActor();
					}

					m_loopScenes = UI::Checkbox("Loop scenes", m_loopScenes);

					int time = m_units[0].GetUnitSceneTime();
					int newTime = UI::SliderInt("Time", time, 0, m_currentState.m_length);
					if (newTime != time)
						SetActorTime(newTime);

					m_showLocators = UI::Checkbox("Show locators", m_showLocators);
					SetVar("r_draw_locators", m_showLocators);
				}
			}
			UI::End();
		}

		void RenderMenu() override
		{
			TestSceneTool::RenderMenu();

			if (UI::BeginMenu("Actor Viewer"))
			{
				if (UI::MenuItem("Open actor"))
				{
					string unitPath;
					if (Window::OpenFileDialog("unit", unitPath))
						LoadActor(unitPath);
				}

				UI::EndMenu();
			}
		}
	}
}
