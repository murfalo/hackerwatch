class HUDSurvival : IWidgetHoster
{
	Widget@ m_wFaceList;
	Widget@ m_wFaceTemplate;
	Widget@ m_wArrowTemplate;

	TextWidget@ m_wWave;
	array<SpriteWidget@> m_faces;
	SpriteWidget@ m_wArrow;

	SpriteWidget@ m_wShrineIcon;
	RadialSpriteWidget@ m_wShrine;

	int m_shrineTimeC;
	int m_shrineTime;

	float m_lastDelta;

	HUDSurvival(GUIBuilder@ b)
	{
		LoadWidget(b, "gui/hud/survival.gui");

		@m_wFaceList = m_widget.GetWidgetById("face-list");
		@m_wFaceTemplate = m_widget.GetWidgetById("face-template");
		@m_wArrowTemplate = m_widget.GetWidgetById("arrow-template");

		@m_wWave = cast<TextWidget>(m_widget.GetWidgetById("wave"));

		@m_wShrineIcon = cast<SpriteWidget>(m_widget.GetWidgetById("shrine-icon"));
		@m_wShrine = cast<RadialSpriteWidget>(m_widget.GetWidgetById("shrine"));

		for (int i = 0; i < 10; i++)
		{
			auto wNewFace = cast<SpriteWidget>(m_wFaceTemplate.Clone());
			wNewFace.SetID("");
			wNewFace.m_visible = true;
			wNewFace.m_fixedTime = randi(10);
			m_faces.insertLast(wNewFace);
			m_wFaceList.AddChild(wNewFace);
		}

		@m_wArrow = cast<SpriteWidget>(m_wArrowTemplate.Clone());
		m_wArrow.SetID("");
		m_wArrow.m_visible = true;
		m_wFaceList.AddChild(m_wArrow);

		Invalidate();
	}

	void UpdateFaces(int value) // 60
	{
		int perGroup = 20;
		value = max(0, value - 10); // 50
		float factor = value / float(perGroup); // 2.5f
		int startId = clamp(int(factor) + 1, 0, 5); // 3
		int nextId = clamp(startId + 1, 0, 5); // 4
		factor = factor % 1.0f; // 0.5f

		array<SpriteWidget@> faces = m_faces;

		for (uint i = 0; i < m_faces.length(); i++)
		{
			int faceIndex = randi(faces.length());
			auto face = faces[faceIndex];
			faces.removeAt(faceIndex);

			int id = startId;
			if (i / float(m_faces.length()) < factor)
				id = nextId;

			face.SetSprite("face-" + id);
		}
	}

	void SetShrine(int time)
	{
		m_shrineTimeC = m_shrineTime = time;
		m_wShrineIcon.SetSprite("icon-shrine-on");
	}

	void OnValueChange(float delta)
	{
		auto gm = cast<Survival>(g_gameMode);
		int value = int(round(gm.m_crowdValue));

		if (delta > 0)
			m_wArrow.SetSprite("icon-arrow-up");
		else if (delta < 0)
			m_wArrow.SetSprite("icon-arrow-down");

		if (int(delta) != 0)
			UpdateFaces(value);

		m_lastDelta = delta;
	}

	void Update(int dt) override
	{
		auto gm = cast<Survival>(g_gameMode);

		if (gm.m_totalWaveCount > 0)
			m_wWave.SetText(gm.m_waveCount + " / " + gm.m_totalWaveCount);
		else
			m_wWave.SetText("" + gm.m_waveCount);

		if (m_shrineTime > 0)
		{
			if (m_shrineTimeC > 0)
			{
				m_shrineTimeC -= dt;
				if (m_shrineTimeC <= 0)
					m_wShrineIcon.SetSprite("icon-shrine-off");
			}
			m_wShrine.m_scale = 1.0f - (m_shrineTimeC / float(m_shrineTime));
		}
		else
			m_wShrine.m_scale = 0.0f;
	}
}
