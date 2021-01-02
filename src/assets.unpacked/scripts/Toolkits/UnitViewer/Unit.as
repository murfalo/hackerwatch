%if TOOLKIT
namespace Toolkits
{
	class UnitViewerUnit
	{
		UnitViewer@ m_viewer;

		UnitProducer@ m_producer;
		string m_producerPath;

		string m_currentScene;
		vec3 m_position;

		array<UnitScene@> m_scenes;
		UnitPtr m_unit;

		bool m_showLocators = true;
		array<string> m_locators;

		bool m_uiVisible = true;

		int m_damageAmount = 1;

		bool m_loop = false;
		int m_loopStart = 0;
		int m_loopEnd = 100;

		UnitViewerUnit(UnitViewer@ viewer, string path)
		{
			@m_viewer = viewer;
			SetProducer(path);
		}

		void Save(SValueBuilder@ builder)
		{
			builder.PushDictionary();

			builder.PushString("filename", m_producerPath);

			builder.PushString("scene", m_currentScene);
			builder.PushVector3("position", m_position);

			builder.PushBoolean("show-locators", m_showLocators);
			builder.PushBoolean("visible", m_uiVisible);
			builder.PushInteger("damage-amount", m_damageAmount);

			builder.PushBoolean("loop", m_loop);
			builder.PushInteger("loop-start", m_loopStart);
			builder.PushInteger("loop-end", m_loopEnd);

			builder.PopDictionary();
		}

		void Load(SValue@ data)
		{
			m_currentScene = GetParamString(UnitPtr(), data, "scene", false, m_currentScene);
			m_position = GetParamVec3(UnitPtr(), data, "position", false, m_position);

			m_showLocators = GetParamBool(UnitPtr(), data, "show-locators", false, m_showLocators);
			m_uiVisible = GetParamBool(UnitPtr(), data, "visible", false, m_uiVisible);
			m_damageAmount = GetParamInt(UnitPtr(), data, "damage-amount", false, m_damageAmount);

			m_loop = GetParamBool(UnitPtr(), data, "loop", false, m_loop);
			m_loopStart = GetParamInt(UnitPtr(), data, "loop-start", false, m_loopStart);
			m_loopEnd = GetParamInt(UnitPtr(), data, "loop-end", false, m_loopEnd);

			if (m_unit.IsValid())
			{
				SetScene(m_currentScene);
				m_unit.SetPosition(m_position);
			}
		}

		void SetProducer(string path)
		{
			@m_producer = Resources::GetUnitProducer(path);
			m_producerPath = path;

			m_scenes = m_producer.GetUnitScenes();
			if (m_scenes.length() == 0)
				PrintError("Can't load unit \"" + path + "\" because there are no scenes!");
		}

		void Destroy()
		{
			m_unit.Destroy();
			m_unit = UnitPtr();
		}

		bool Make(Scene@ scene)
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			SetProducer(m_producerPath);

			m_unit = m_producer.Produce(scene, m_position);
			if (!m_unit.IsValid())
				return false;

			if (m_currentScene == "")
			{
				auto currentScene = m_unit.GetCurrentUnitScene();
				if (currentScene !is null)
					m_currentScene = currentScene.GetName();
			}
			else
				SetScene(m_currentScene);

			return true;
		}

		void SetScene(string newScene)
		{
			int prevLength = 0;
			auto currentScene = m_unit.GetCurrentUnitScene();
			if (currentScene !is null)
				prevLength = currentScene.Length();

			m_unit.SetUnitScene(newScene, true);
			m_currentScene = newScene;

			auto scene = m_unit.GetUnitScene(newScene);
			m_locators = scene.GetLocators();

			m_loopStart = min(m_loopStart, scene.Length());

			if (m_loopEnd == prevLength)
				m_loopEnd = scene.Length();
			else
				m_loopEnd = min(m_loopEnd, scene.Length());
		}

		void DrawCross(SpriteBatch& sb, vec2 pos, float dist = 4.0f, vec4 color = vec4(1, 0, 0, 1))
		{
			sb.DrawLine(pos - vec2(0, dist), pos + vec2(0, dist), 1.0f, color);
			sb.DrawLine(pos - vec2(dist, 0), pos + vec2(dist, 0), 1.0f, color);
		}

		void Update(int dt)
		{
			m_unit.SetPosition(m_position);
		}

		void Render(SpriteBatch& sb, int idt, uint index)
		{
			if (!m_uiVisible || !m_unit.IsValid())
				return;

			auto currentScene = m_unit.GetCurrentUnitScene();
			if (currentScene !is null)
				m_currentScene = currentScene.GetName();

			if (m_loop)
			{
				int sceneTime = m_unit.GetUnitSceneTime();
				if (sceneTime >= m_loopEnd)
				{
					int delta = sceneTime - m_loopEnd;
					m_unit.SetUnitSceneTime(m_loopStart + delta);
				}
			}

			if (UI::Begin(m_producer.GetDebugName() + "###Unit_" + index, m_uiVisible))
			{
				if (UI::Button("Destroy"))
				{
					Destroy();
					UI::End();
					return;
				}

				UI::SameLine();

				bool isHidden = m_unit.IsHidden();
				bool setHidden = UI::Checkbox("Hidden", isHidden);
				if (setHidden != isHidden)
					m_unit.SetHidden(setHidden);

				if (UI::BeginCombo("Scene", m_currentScene))
				{
					for (uint i = 0; i < m_scenes.length(); i++)
					{
						auto scene = m_scenes[i];
						string sceneName = scene.GetName();

						if (UI::Selectable(scene.GetName(), sceneName == m_currentScene))
							SetScene(sceneName);

						if (sceneName == m_currentScene)
							UI::SetItemDefaultFocus();
					}
					UI::EndCombo();
				}

				m_position = UI::SliderFloat3("Position", m_position, -50.0f, 50.0f);
				m_unit.SetPosition(m_position, true);

				m_showLocators = UI::Checkbox("Show locators", m_showLocators);
				SetVar("r_draw_locators", m_showLocators);
				if (m_showLocators)
				{
					for (uint i = 0; i < m_locators.length(); i++)
					{
						string locatorName = m_locators[i];
						vec2 pos = m_unit.FetchLocator(locatorName);
						UI::BulletText(locatorName + ": " + pos.x + ", " + pos.y);
					}
				}

				UI::Separator();

				int sceneTime = m_unit.GetUnitSceneTime();
				if (currentScene !is null)
				{
					int newSceneTime = UI::SliderInt("Time", sceneTime, 0, currentScene.Length());
					if (newSceneTime != sceneTime)
						m_unit.SetUnitSceneTime(newSceneTime);

					m_loop = UI::Checkbox("Time loop", m_loop);
					if (m_loop)
					{
						m_loopStart = UI::SliderInt("Loop start", m_loopStart, 0, currentScene.Length());
						m_loopEnd = UI::SliderInt("Loop end", m_loopEnd, 0, currentScene.Length());

						if (m_loopStart > m_loopEnd)
							m_loopStart = m_loopEnd;
						if (m_loopEnd < m_loopStart)
							m_loopEnd = m_loopStart;
					}

					UI::Separator();
				}

				auto b = m_unit.GetScriptBehavior();
				if (b is null)
					UI::Text("No behavior.");
				else
				{
					UI::Text(Reflect::GetTypeName(b));

					auto actor = cast<Actor>(b);
					if (actor !is null)
					{
						if (UI::Button("Kill"))
							actor.Kill(null, 0);

						if (UI::Button("Damage"))
						{
							DamageInfo di(null, m_damageAmount, 0, false, true, 0);
							actor.Damage(di, vec2(), vec2());
						}
						UI::SameLine();
						UI::SliderInt("###DamageSlider", m_damageAmount, 1, 100);
					}
				}
			}
			UI::End();
		}
	}
}
%endif
