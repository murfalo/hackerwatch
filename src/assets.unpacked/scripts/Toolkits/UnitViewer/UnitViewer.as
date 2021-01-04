%if TOOLKIT
namespace Toolkits
{
	[Toolkit]
	class UnitViewer : TestSceneTool
	{
		array<UnitViewerUnit@> m_units;

		UnitViewer(ToolkitScript@ script)
		{
			super(script);

			m_panning.SetScale(4.0f);
			m_panning.Center();
		}

		void Save(SValueBuilder@ builder) override
		{
			TestSceneTool::Save(builder);

			builder.PushArray("units");
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Save(builder);
			builder.PopArray();
		}

		void Load(SValue@ data) override
		{
			TestSceneTool::Load(data);

			m_units.removeRange(0, m_units.length());
			auto arrUnits = GetParamArray(UnitPtr(), data, "units", false);
			if (arrUnits !is null)
			{
				for (uint i = 0; i < arrUnits.length(); i++)
				{
					auto svUnit = arrUnits[i];

					string strFilename = GetParamString(UnitPtr(), svUnit, "filename", false);

					auto newUnit = LoadUnit(strFilename);
					if (newUnit !is null)
						newUnit.Load(svUnit);
				}
			}
		}

		void OnKeyPress(int scancode) override
		{
			if (scancode == 20 /* Q */)
				AdvanceCurrentScene(-1);
			else if (scancode == 8 /* E */)
				AdvanceCurrentScene(+1);
			else if (scancode == 29 /* Z */)
				ToggleAllUnitWindows();
			else
				TestSceneTool::OnKeyPress(scancode);
		}

		void OnMouseDown(vec2 pos, int button) override
		{
			if (button == 3)
			{
				for (uint i = 0; i < m_units.length(); i++)
					m_units[i].m_unit.SetUnitSceneTime(0);
			}

			TestSceneTool::OnMouseDown(pos, button);
		}

		void LoadScene() override
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Destroy();

			TestSceneTool::LoadScene();

			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Make(m_scene);
		}

		void OnResourcesReloaded()
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Make(m_scene);

			m_script.UpdateFileWatch();
		}

		void ResourcesToReload(array<string>@ res) override
		{
			TestSceneTool::ResourcesToReload(res);

			for (uint i = 0; i < m_units.length(); i++)
				res.insertLast(m_units[i].m_producer.GetDebugName());
		}

		void ToggleAllUnitWindows()
		{
			bool anyVisible = false;
			for (uint i = 0; i < m_units.length(); i++)
			{
				if (m_units[i].m_uiVisible)
				{
					anyVisible = true;
					break;
				}
			}

			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].m_uiVisible = !anyVisible;
		}

		void AdvanceCurrentScene(int offset)
		{
			for (uint i = 0; i < m_units.length(); i++)
			{
				auto unit = m_units[i];
				if (!unit.m_uiVisible || unit.m_scenes.length() == 0)
					continue;

				int currentSceneIndex = -1;
				for (uint j = 0; j < unit.m_scenes.length(); j++)
				{
					auto scene = unit.m_scenes[j];
					if (scene.GetName() == unit.m_currentScene)
					{
						currentSceneIndex = j;
						break;
					}
				}

				int newSceneIndex = currentSceneIndex;
				if (currentSceneIndex == -1)
					newSceneIndex = 0;
				else
					newSceneIndex += offset;

				if (newSceneIndex < 0)
					newSceneIndex = unit.m_scenes.length() - 1;
				else
					newSceneIndex = newSceneIndex % unit.m_scenes.length();

				unit.SetScene(unit.m_scenes[newSceneIndex].GetName());
			}
		}

		UnitViewerUnit@ GetUnit(UnitProducer@ prod)
		{
			for (uint i = 0; i < m_units.length(); i++)
			{
				if (m_units[i].m_producer is prod)
					return m_units[i];
			}
			return null;
		}

		void ClearUnits()
		{
			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Destroy();
			m_units.removeRange(0, m_units.length());
		}

		UnitViewerUnit@ LoadUnit(const string &in path)
		{
			auto newUnit = UnitViewerUnit(this, path);
			if (!newUnit.Make(m_scene))
			{
				PrintError("Failed to load unit \"" + path + "\"");
				return null;
			}

			print("Loaded unit \"" + path + "\" with " + newUnit.m_scenes.length() + " scenes");

			m_units.insertLast(newUnit);
			m_script.UpdateFileWatch();

			return newUnit;
		}

		void Update(int dt) override
		{
			TestSceneTool::Update(dt);

			for (uint i = 0; i < m_units.length(); i++)
				m_units[i].Update(dt);
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			TestSceneTool::Render(sb, idt);

			if (!m_playing)
				idt = 0;

			for (uint i = 0; i < m_units.length(); i++)
			{
				auto u = m_units[i];
				u.Render(sb, idt, i);
				if (!u.m_unit.IsValid() || u.m_unit.IsDestroyed())
					m_units.removeAt(i--);
			}
		}

		void RenderMenu() override
		{
			TestSceneTool::RenderMenu();

			if (UI::BeginMenu("Unit Viewer"))
			{
				if (m_units.length() > 0)
				{
					for (uint i = 0; i < m_units.length(); i++)
					{
						auto unit = m_units[i];
						if (UI::MenuItem(unit.m_producer.GetDebugName(), "", unit.m_uiVisible))
							unit.m_uiVisible = !unit.m_uiVisible;
					}

					UI::Separator();
				}

				if (UI::MenuItem("Open Unit")) //TODO: Add Ctrl+O shortcut
				{
					string unitPath;
					if (Window::OpenFileDialog("unit", unitPath))
						LoadUnit(unitPath);
				}

				if (UI::MenuItem("Replace Unit", "", false, m_units.length() > 0))
				{
					string unitPath;
					if (Window::OpenFileDialog("unit", unitPath))
					{
						ClearUnits();
						LoadUnit(unitPath);
					}
				}

				if (UI::MenuItem("Clear Units", "", false, m_units.length() > 0))
					ClearUnits();

				UI::Separator();

				if (UI::MenuItem("Previous scene", "Q"))
					AdvanceCurrentScene(-1);
				if (UI::MenuItem("Next scene", "E"))
					AdvanceCurrentScene(+1);

				UI::Separator();

				if (UI::MenuItem("Toggle all unit windows", "Z"))
					ToggleAllUnitWindows();

				UI::EndMenu();
			}
		}
	}
}
%endif
