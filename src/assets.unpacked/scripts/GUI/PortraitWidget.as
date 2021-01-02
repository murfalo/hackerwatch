class PortraitWidget : DyeSpriteWidget
{
	PlayerRecord@ m_record;
	string m_recordClass;

	ClassFaceInfo@ m_faceInfo;
	int m_faceIndex;
	PlayerFrame@ m_frame;
	array<Materials::Dye@> m_dyes;

	bool m_portraitInvalidated;

	PortraitWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		PortraitWidget@ w = PortraitWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		DyeSpriteWidget::Load(ctx);

		m_autoSize = false;
		m_width = 28;
		m_height = 28;
	}

	void BindRecord(PlayerRecord@ record)
	{
		if (m_record is record)
			return;

		@m_record = record;
		SetRecord(record);
	}

	void CopyFrom(PortraitWidget@ wOther)
	{
		@m_record = wOther.m_record;

		@m_faceInfo = wOther.m_faceInfo;
		m_faceIndex = wOther.m_faceIndex;
		@m_frame = wOther.m_frame;
		m_dyes = wOther.m_dyes;

		UpdatePortrait();
	}

	void SetRecord(PlayerRecord@ record)
	{
		if (!SetFrame(record.currentFrame) && m_record is record)
			m_record.currentFrame = m_frame.m_idHash;

		SetClass(record.charClass);
		SetFace(record.face);
		SetDyes(record.colors);

		UpdatePortrait();
	}

	void SetFrame(PlayerFrame@ frame)
	{
		@m_frame = frame;
	}

	bool SetFrame(const string &in id)
	{
		return SetFrame(HashString(id));
	}

	bool SetFrame(uint idHash)
	{
		@m_frame = PlayerFrame::Get(idHash);

		if (m_frame is null)
		{
			PrintError("Couldn't find frame with ID " + idHash + ", falling back to default");
			@m_frame = PlayerFrame::Get("default");
			return false;
		}

		return true;
	}

	void SetClass(string charClass)
	{
		m_recordClass = charClass;
		@m_faceInfo = ClassFaceInfo(charClass);
		m_portraitInvalidated = true;
	}

	void SetFace(int faceIndex)
	{
		m_faceIndex = faceIndex;
		m_portraitInvalidated = true;
	}

	void SetDyes(array<Materials::Dye@> dyes) override
	{
		m_dyes = dyes;
		m_portraitInvalidated = true;
	}

	void UpdatePortrait()
	{
		SetSprite(m_faceInfo.GetSprite(m_faceIndex));

		m_dyeStates = Materials::MakeDyeStates(m_dyes);

		m_portraitInvalidated = false;
	}

	void Update(int dt) override
	{
		if (m_record !is null)
		{
			// Automatically update frame
			if (m_frame is null || m_frame.m_idHash != m_record.currentFrame)
			{
				if (!SetFrame(m_record.currentFrame))
					m_record.currentFrame = m_frame.m_idHash;
			}

			// Automatically update dyes
			if (m_record.colors != m_dyes)
				SetDyes(m_record.colors);

			// Automatically update class
			if (m_record.charClass != m_recordClass)
				SetClass(m_record.charClass);
		}

		if (m_portraitInvalidated)
			UpdatePortrait();

		DyeSpriteWidget::Update(dt);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		sb.FillRectangle(vec4(pos.x, pos.y, m_width, m_height), vec4(1, 0, 1, 1));

		// Small hack to have sprites rendered correctly
		_m_width = 24; _m_height = 24;
		DyeSpriteWidget::DoDraw(sb, pos + vec2(2, 2));
		_m_width = 28; _m_height = 28;

		if (m_frame !is null)
			m_frame.m_sprite.Draw(sb, pos, g_menuTime);
	}
}

ref@ LoadPortraitWidget(WidgetLoadingContext &ctx)
{
	PortraitWidget@ w = PortraitWidget();
	w.Load(ctx);
	return w;
}
