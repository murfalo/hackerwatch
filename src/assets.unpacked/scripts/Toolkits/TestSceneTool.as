%if TOOLKIT
namespace Toolkits
{
	class TestSceneTool : SceneTool
	{
		Tileset@ m_tileset;
		Environment@ m_env;

		BitmapFont@ m_fontSystem;

		bool m_optionsVisible;
		bool m_measureVisible;

		array<Tileset@> m_tilesets;
		array<Environment@> m_envs;

		array<TestSceneToolMeasurement@> m_measurements;
		bool m_holdMeasure;
		vec2 m_holdMeasureStart;
		vec2 m_holdMeasureScreenEnd;

		TestSceneTool(ToolkitScript@ script)
		{
			super(script);

			m_tilesets = Resources::GetTilesets(""".*\.tileset""");
			m_envs = Resources::GetEnvironments(""".*\.env""");

			@m_tileset = Resources::GetTileset("tilesets/______dev_16.tileset");
			if (m_tileset is null)
				@m_tileset = m_tilesets[0];

			@m_env = Resources::GetEnvironment("system/default.env");
			if (m_env is null)
				@m_env = m_envs[0];

			@m_fontSystem = Resources::GetBitmapFont("system/system.fnt");
		}

		void Save(SValueBuilder@ builder) override
		{
			SceneTool::Save(builder);

			builder.PushString("testscene-tileset", m_tileset.GetPath());
			builder.PushString("testscene-env", m_env.GetPath());

			builder.PushBoolean("testscene-options-visible", m_optionsVisible);
			builder.PushBoolean("testscene-measure-visible", m_measureVisible);
		}

		void Load(SValue@ data) override
		{
			SceneTool::Load(data);

			string strTileset = GetParamString(UnitPtr(), data, "testscene-tileset", false);
			if (strTileset != "")
			{
				@m_tileset = Resources::GetTileset(strTileset);
				//TODO: It would be nice to not have to reload the scene to re-paint the tileset
				LoadScene();
			}

			string strEnv = GetParamString(UnitPtr(), data, "testscene-env", false);
			if (strEnv != "")
			{
				@m_env = Resources::GetEnvironment(strEnv);
				cast<Scene>(m_scene).SetEnvironment(m_env);
			}

			m_optionsVisible = GetParamBool(UnitPtr(), data, "testscene-options-visible", false, m_optionsVisible);
			m_measureVisible = GetParamBool(UnitPtr(), data, "testscene-measure-visible", false, m_measureVisible);
		}

		void OnKeyPress(int scancode)
		{
			if (scancode == 18 /* O */)
				m_optionsVisible = !m_optionsVisible;
			else if (scancode == 16 /* M */)
				m_measureVisible = !m_measureVisible;
		}

		void OnMouseDown(vec2 pos, int button) override
		{
			if (button == 1)
			{
				m_holdMeasure = true;
				m_holdMeasureStart = m_panning.m_cam.GetWorldPos(pos);
				m_holdMeasureScreenEnd = pos;
			}
			else if (button == 3)
			{
				for (uint i = 0; i < m_measurements.length(); i++)
				{
					auto m = m_measurements[i];
					vec2 screenA = m_panning.m_cam.GetScreenPos(m.m_posA);
					vec2 screenB = m_panning.m_cam.GetScreenPos(m.m_posB);
					if (dist(screenA, pos) < 10.0f || dist(screenB, pos) < 10.0f)
					{
						m_measurements.removeAt(i);
						break;
					}
				}
			}

			SceneTool::OnMouseDown(pos, button);
		}

		void OnMouseUp(vec2 pos, int button) override
		{
			if (m_holdMeasure)
			{
				m_holdMeasure = false;

				vec2 releasePos = m_panning.m_cam.GetWorldPos(pos);
				if (dist(m_holdMeasureStart, releasePos) > 0.0f)
					m_measurements.insertLast(TestSceneToolMeasurement(m_holdMeasureStart, releasePos));
			}

			SceneTool::OnMouseUp(pos, button);
		}

		void OnMouseMove(vec2 pos) override
		{
			if (m_holdMeasure)
				m_holdMeasureScreenEnd = pos;

			SceneTool::OnMouseMove(pos);
		}

		void ResourcesToReload(array<string>@ res)
		{
			res.insertLast(m_tileset.GetPath());
			res.insertLast(m_env.GetPath());
		}

		void LoadScene() override
		{
			SceneTool::LoadScene();

			auto scene = cast<Scene>(m_scene);
			scene.PaintTileset(m_tileset, vec2(), 600);
			scene.SetEnvironment(m_env);
		}

		void RenderMenu()
		{
			if (UI::BeginMenu("Scene"))
			{
				if (UI::MenuItem("Options", "O", m_optionsVisible))
					m_optionsVisible = !m_optionsVisible;
				if (UI::MenuItem("Measurements", "M", m_measureVisible))
					m_measureVisible = !m_measureVisible;
				UI::EndMenu();
			}
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			SceneTool::Render(sb, idt);

			if (m_optionsVisible)
			{
				if (UI::Begin("Scene options", m_optionsVisible))
				{
					// State control
					string playButtonText = "Play";
					if (m_playing)
						playButtonText = "Pause";

					if (UI::Button(playButtonText))
						m_playing = !m_playing;

					m_timeScale = UI::SliderFloat("Timescale", m_timeScale * 100.0f, 0.0f, 200.0f, "%.01f%%") / 100.0f;

					UI::Separator();

					// Layout settings
					string currentTilesetPath = m_tileset.GetPath();
					if (UI::BeginCombo("Tileset", currentTilesetPath))
					{
						for (uint i = 0; i < m_tilesets.length(); i++)
						{
							auto tileset = m_tilesets[i];
							string tilesetPath = tileset.GetPath();
							if (UI::Selectable(tilesetPath, tilesetPath == currentTilesetPath))
							{
								@m_tileset = tileset;
								//TODO: It would be nice to not have to reload the scene to re-paint the tileset
								LoadScene();
							}

							if (tilesetPath == currentTilesetPath)
								UI::SetItemDefaultFocus();
						}
						UI::EndCombo();
					}

					string currentEnvPath = m_env.GetPath();
					if (UI::BeginCombo("Environment", currentEnvPath))
					{
						for (uint i = 0; i < m_envs.length(); i++)
						{
							auto env = m_envs[i];
							string envPath = env.GetPath();
							if (UI::Selectable(envPath, envPath == currentEnvPath))
							{
								@m_env = env;
								cast<Scene>(m_scene).SetEnvironment(m_env);
							}

							if (envPath == currentEnvPath)
								UI::SetItemDefaultFocus();
						}
						UI::EndCombo();
					}

					UI::Separator();

					// Camera
					vec2 camPos = UI::InputFloat2("Camera", m_panning.m_cam.target);
					if (camPos.x != m_panning.m_cam.target.x || camPos.y != m_panning.m_cam.target.y)
						m_panning.m_cam.SetTarget(camPos, true);

					float camScale = UI::InputFloat("Zoom", m_panning.m_cam.scale);
					if (camScale != m_panning.m_cam.scale)
						m_panning.SetScale(camScale, Window::GetWindowSize() / 2.0f);

					UI::Separator();

					// Misc options
					if (UI::Button("Reload scene"))
						LoadScene();

					UI::SameLine();

					if (UI::Button("Clear gibs"))
					{
						for (uint i = 0; i < m_gibs.length(); i++)
							m_gibs[i].unit.Destroy();
						m_gibs.removeRange(0, m_gibs.length());
					}
				}
				UI::End();
			}

			if (m_measureVisible)
			{
				if (UI::Begin("Measurements", m_measureVisible))
				{
					if (UI::Button("Clear"))
						m_measurements.removeRange(0, m_measurements.length());

					UI::Text("Left click and drag to measure. Right click near a measurement point to delete it.");

					for (uint i = 0; i < m_measurements.length(); i++)
					{
						auto m = m_measurements[i];
						UI::Bullet();
						UI::SameLine();
						UI::TextColored(m.m_color, i + ": Distance: " + m.GetDistance());
					}
				}
				UI::End();
			}

			if (m_holdMeasure)
			{
				vec2 worldEnd = m_panning.m_cam.GetWorldPos(m_holdMeasureScreenEnd);
				RenderMeasurement(sb, m_holdMeasureStart, worldEnd, vec4(1, 1, 1, 1));
			}

			for (uint i = 0; i < m_measurements.length(); i++)
			{
				auto m = m_measurements[i];
				RenderMeasurement(sb, m.m_posA, m.m_posB, m.m_color, 3.0f);
			}
		}

		void RenderMeasurement(SpriteBatch& sb, const vec2 &in a, const vec2 &in b, const vec4 &in color, const string &in name = "", float width = 1.0f)
		{
			vec2 screenA = m_panning.m_cam.GetScreenPos(a);
			vec2 screenB = m_panning.m_cam.GetScreenPos(b);
			float d = dist(a, b);

			sb.DrawCircle(screenA, 10, color);
			sb.DrawCircle(screenB, 10, color);
			sb.DrawArrow(screenA, screenB, width, 5.0f, color);

			string text;
			if (name != "")
				text = name + ": ";

			auto str = m_fontSystem.BuildText(text + d);
			str.SetColor(color);

			vec2 strPos = lerp(screenA, screenB, 0.5f);
			strPos.x = int(strPos.x);
			strPos.y = int(strPos.y);

			sb.DrawString(strPos, str);
		}
	}
}
%endif
