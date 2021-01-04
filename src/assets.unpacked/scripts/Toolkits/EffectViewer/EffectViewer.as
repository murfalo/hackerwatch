%if TOOLKIT
namespace Toolkits
{
	[Toolkit]
	class EffectViewer : TestSceneTool
	{
		UnitScene@ m_currentEffect;
		string m_currentEffectPath;

		UnitProducer@ m_effectUnit;

		UnitPtr m_unit;
		EffectBehavior@ m_behavior;

		bool m_rotate;
		bool m_cameraFollows;

		bool m_useTtl;
		int m_ttl;
		int m_ttlC;

		uint64 m_sceneTimePrev;
		uint64 m_sceneTime;

		EffectViewer(ToolkitScript@ script)
		{
			super(script);

			m_panning.SetScale(2.0f);
			m_panning.Center();
		}

		void Save(SValueBuilder@ builder) override
		{
			TestSceneTool::Save(builder);

			builder.PushString("filename", m_currentEffectPath);

			builder.PushBoolean("rotate", m_rotate);
			builder.PushBoolean("camera-follows", m_cameraFollows);

			builder.PushBoolean("use-ttl", m_useTtl);
			builder.PushInteger("ttl", m_ttl);
			builder.PushInteger("ttl-c", m_ttlC);

			builder.PushLong("scene-time", m_sceneTime);
		}

		void Load(SValue@ data) override
		{
			TestSceneTool::Load(data);

			string strFilename = GetParamString(UnitPtr(), data, "filename", false, m_currentEffectPath);
			if (strFilename != "")
				LoadEffect(strFilename);

			m_rotate = GetParamBool(UnitPtr(), data, "rotate", false, m_rotate);
			m_cameraFollows = GetParamBool(UnitPtr(), data, "camera-follows", false, m_cameraFollows);

			m_useTtl = GetParamBool(UnitPtr(), data, "use-ttl", false, m_useTtl);
			m_ttl = GetParamInt(UnitPtr(), data, "ttl", false, m_ttl);
			m_ttlC = GetParamInt(UnitPtr(), data, "ttl-c", false, m_ttlC);

			m_sceneTime = uint64(GetParamLong(UnitPtr(), data, "scene-time", false, m_sceneTime));
		}

		void OnMouseDown(vec2 pos, int button) override
		{
			if (button == 3)
				SpawnEffect();

			TestSceneTool::OnMouseDown(pos, button);
		}

		void ResourcesToReload(array<string>@ res) override
		{
			TestSceneTool::ResourcesToReload(res);

			res.insertLast(m_currentEffectPath);
			res.insertLast(g_effectUnitPath);
		}

		void OnResourcesReloaded()
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			@m_effectUnit = null;

			LoadEffect(m_currentEffectPath);
		}

		void LoadScene() override
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			TestSceneTool::LoadScene();

			if (m_currentEffectPath != "")
				LoadEffect(m_currentEffectPath);
		}

		void LoadEffect(string path)
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			@m_currentEffect = Resources::GetEffect(path);
			m_currentEffectPath = path;

			if (m_currentEffect is null)
			{
				PrintError("Couldn't find effect " + path);
				return;
			}

			auto rend = m_currentEffect.GetEffectRenderable();
			m_useTtl = !rend.IsLooping();
			m_ttlC = m_ttl = (m_useTtl ? rend.GetLength() : 0);

			SpawnEffect();

			m_script.UpdateFileWatch();
		}

		void SpawnEffect()
		{
			if (m_unit.IsValid())
			{
				m_unit.Destroy();
				m_unit = UnitPtr();
			}

			if (m_currentEffect is null)
				return;

			if (m_effectUnit is null)
				@m_effectUnit = Resources::GetUnitProducer(g_effectUnitPath);

			m_unit = m_effectUnit.Produce(g_scene, GetEffectPos(0));
			@m_behavior = cast<EffectBehavior>(m_unit.GetScriptBehavior());
			m_behavior.Initialize(m_currentEffect, { });
		}

		vec2 GetEffectDir(int idt)
		{
			vec2 ret;

			if (m_rotate)
			{
				vec2 pos = xy(GetEffectPos(idt));
				vec2 npos = normalize(pos);
				ret = addrot(npos, PI / 2.0f);
			}

			return ret;
		}

		vec3 GetEffectPos(int idt)
		{
			vec3 ret;

			if (m_rotate)
			{
				uint64 tm = m_sceneTimePrev + uint64(lerp(0.0f, float(m_sceneTime - m_sceneTimePrev), idt / 33.0f));
				float t = tm / 1000.0f;
				float d = 70.0f;
				ret.x = cos(t) * d;
				ret.y = sin(t) * (d * 0.5f);
			}

			return ret;
		}

		void Update(int dt) override
		{
			TestSceneTool::Update(dt);

			m_panning.m_frozen = m_cameraFollows;

			m_sceneTimePrev = m_sceneTime;
			m_sceneTime += dt;

			if (m_currentEffect !is null)
			{
				if (!m_behavior.m_looping && m_behavior.m_ttl <= 0)
					SpawnEffect();

				if (m_useTtl)
				{
					m_ttlC += dt;
					if (m_ttlC >= m_ttl)
					{
						SpawnEffect();
						m_ttlC = 0;
					}
				}
			}
		}

		void Render(SpriteBatch& sb, int idt) override
		{
			TestSceneTool::Render(sb, idt);

			if (m_currentEffect is null)
				return;

			vec3 pos = GetEffectPos(idt);
			m_unit.SetPosition(pos);

			vec2 dir = GetEffectDir(idt);
			m_behavior.SetParam("angle", atan(dir.y, dir.x));

			if (m_cameraFollows)
				m_panning.m_cam.MoveTo(xy(pos));

			if (UI::Begin(m_currentEffectPath + "###Effect"))
			{
				m_rotate = UI::Checkbox("Rotate", m_rotate);
				m_cameraFollows = UI::Checkbox("Camera follows", m_cameraFollows);

				m_useTtl = UI::Checkbox("Use TTL", m_useTtl);
				if (m_useTtl)
					m_ttl = UI::SliderInt("Time to live", m_ttl, 1, 10000);
			}
			UI::End();
		}

		void RenderMenu() override
		{
			TestSceneTool::RenderMenu();

			if (UI::BeginMenu("Effect Viewer"))
			{
				if (UI::MenuItem("Open effect"))
				{
					string effectPath;
					if (Window::OpenFileDialog("effect", effectPath))
						LoadEffect(effectPath);
				}
				UI::EndMenu();
			}
		}
	}
}
%endif
