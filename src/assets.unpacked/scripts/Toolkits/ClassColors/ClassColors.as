%if TOOLKIT
namespace Toolkits
{
	[Toolkit]
	class ClassColors : TestSceneTool
	{
		UnitPtr m_unit;

		array<string> m_availableClasses;

		string m_currentClass = "";
		string m_currentScene = "";

		vec3 m_currentColor1 = vec3(0.1f, 0.2f, 0.1f);
		vec3 m_currentColor2 = vec3(0.3f, 0.5f, 0.3f);
		vec3 m_currentColor3 = vec3(0.6f, 0.9f, 0.6f);

		array<UnitScene@> m_availableScenes;

		uint m_layoutDockRight;

		ClassColors(ToolkitScript@ script)
		{
			super(script);

			m_panning.SetScale(8.0f);
			m_panning.Center();
		}

		void Initialize() override
		{
			auto classUnits = Resources::GetUnitProducers("""players\/[a-z]+\.unit""");
			for (uint i = 0; i < classUnits.length(); i++)
			{
				string classPath = classUnits[i].GetDebugName();
				string className = classPath.substr(8, classPath.length() - 8 - 5);

				// Ignore "players/player.unit"
				if (className == "player")
					continue;

				m_availableClasses.insertLast(className);
			}

			TestSceneTool::Initialize();
		}

		void LoadScene() override
		{
			TestSceneTool::LoadScene();

			if (m_currentClass == "")
			{
				int randomClassIndex = randi(m_availableClasses.length());
				m_currentClass = m_availableClasses[randomClassIndex];
			}

			ShowClass(m_currentClass);
		}

		void ShowClass(string charClass)
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			m_currentClass = charClass;

			auto prod = Resources::GetUnitProducer("players/" + charClass + ".unit");
			if (prod is null)
			{
				PrintError("Couldn't find unit producer for class " + charClass);
				m_availableScenes.removeRange(0, m_availableScenes.length());
				return;
			}

			m_unit = prod.Produce(m_scene, vec3());
			m_availableScenes = prod.GetUnitScenes();

			if (m_currentScene == "" || prod.GetUnitScene(m_currentScene) is null)
				m_currentScene = m_unit.GetCurrentUnitScene().GetName();

			ShowScene(m_currentScene);
		}

		void ShowScene(string sceneName)
		{
			m_currentScene = sceneName;

			m_unit.SetUnitScene(sceneName, true);

			ShowColor(m_currentColor1, m_currentColor2, m_currentColor3);
		}

		void ShowColor(const vec3 &in a, const vec3 &in b, const vec3 &in c)
		{
			//TODO: Allow coloring individual parts
			for (int i = 0; i < 8; i++)
			{
				m_unit.SetMultiColor(i,
					tocolor(xyzw(a, 1)),
					tocolor(xyzw(b, 1)),
					tocolor(xyzw(c, 1))
				);
			}
		}

		string HexNibble(uint8 n)
		{
			switch (n)
			{
			case 0: return "0"; case 1: return "1"; case 2: return "2"; case 3: return "3"; case 4: return "4";
			case 5: return "5"; case 6: return "6"; case 7: return "7"; case 8: return "8"; case 9: return "9";
			case 10: return "a"; case 11: return "b"; case 12: return "c"; case 13: return "d"; case 14: return "e";
			}
			return "f";
		}

		string HexByte(float a)
		{
			uint8 b = uint8(a * 255);
			return HexNibble(b / 16) + HexNibble(b % 16);
		}

		string HexColor(vec3 color)
		{
			return HexByte(color.r) + HexByte(color.g) + HexByte(color.b);
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			TestSceneTool::Render(sb, idt);

			if (UI::Begin("Class Colors"))
			{
				if (UI::Button("Make color"))
				{
					print(
						"<array name=\"shades\"><string>#" + HexColor(m_currentColor1) +
						"</string><string>#" + HexColor(m_currentColor2) +
						"</string><string>#" + HexColor(m_currentColor3) +
						"</string></array>"
					);
				}

				if (UI::BeginCombo("Class", m_currentClass))
				{
					for (uint i = 0; i < m_availableClasses.length(); i++)
					{
						string charClass = m_availableClasses[i];
						if (UI::Selectable(charClass, charClass == m_currentClass))
							ShowClass(charClass);

						if (charClass == m_currentClass)
							UI::SetItemDefaultFocus();
					}
					UI::EndCombo();
				}

				if (UI::BeginCombo("Scene", m_currentScene))
				{
					for (uint i = 0; i < m_availableScenes.length(); i++)
					{
						auto sceneName = m_availableScenes[i].GetName();
						if (UI::Selectable(sceneName, sceneName == m_currentScene))
							ShowScene(sceneName);

						if (sceneName == m_currentScene)
							UI::SetItemDefaultFocus();
					}
					UI::EndCombo();
				}

				if (UI::Button("Restart scene"))
					ShowScene(m_currentScene);

				m_currentColor1 = UI::ColorPicker3("Darks", m_currentColor1);
				m_currentColor2 = UI::ColorPicker3("Mids", m_currentColor2);
				m_currentColor3 = UI::ColorPicker3("Highlights", m_currentColor3);
				ShowColor(m_currentColor1, m_currentColor2, m_currentColor3);
			}
			UI::End();
		}
	}
}
%endif
