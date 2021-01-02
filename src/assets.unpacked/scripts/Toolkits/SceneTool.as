%if TOOLKIT
namespace Toolkits
{
	class SceneTool : BaseTool
	{
		TScene@ m_scene;
		MousePanning@ m_panning;

		bool m_playing = true;
		float m_timeScale = 1.0f;

		bool m_rendering = true;

		SceneTool(ToolkitScript@ script)
		{
			super(script);
			@m_panning = MousePanning();
		}

		void Save(SValueBuilder@ builder)
		{
			builder.PushDictionary("scene-camera");
			m_panning.m_cam.Save(builder);
			builder.PopDictionary();

			builder.PushBoolean("scene-playing", m_playing);
			builder.PushFloat("scene-timescale", m_timeScale);
		}

		void Load(SValue@ data)
		{
			auto svCamera = data.GetDictionaryEntry("scene-camera");
			if (svCamera !is null)
				m_panning.m_cam.Load(svCamera);

			m_playing = GetParamBool(UnitPtr(), data, "scene-playing", false, m_playing);
			m_timeScale = GetParamFloat(UnitPtr(), data, "scene-timescale", false, m_timeScale);
		}

		void OnShow()
		{
			@g_scene = cast<Scene>(m_scene);
		}

		void Initialize()
		{
			LoadScene();
		}

		void LoadScene()
		{
			SValueBuilder sceneBuilder;
			sceneBuilder.PushDictionary();
			sceneBuilder.PushInteger("version", 1);
			sceneBuilder.PopDictionary();

			@m_scene = m_script.CreateScene();
			m_scene.Load(sceneBuilder.Build());

			OnShow(); //TODO: Only call this if currently visible? Or, make a separate script module for each tool script so we can do whatever
		}

		void OnMouseDown(vec2 pos, int button) { m_panning.OnMouseDown(pos, button); }
		void OnMouseUp(vec2 pos, int button) { m_panning.OnMouseUp(pos, button); }
		void OnMouseMove(vec2 pos) { m_panning.OnMouseMove(pos); }
		void OnMouseWheel(vec2 delta) { m_panning.OnMouseWheel(delta); }

		void Update(int dt)
		{
			if (m_playing)
			{
				m_scene.Update(int(dt * m_timeScale));
				UpdateGibs(dt);
			}
		}

		void Render(SpriteBatch& sb, int idt)
		{
			m_panning.Set();

			if (!m_playing)
				idt = 0;

			if (m_rendering)
				m_scene.Render(int(idt * m_timeScale), m_panning.GetMidpoint(), m_panning.GetScale());
		}
	}
}
%endif
