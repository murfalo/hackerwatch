enum SpriteRectMode
{
	None,
	Horizontal,
	Vertical,
	Borders,
	All
}

class SpriteRect
{
	SpriteRectMode m_mode;

	vec4 m_background;

	array<array<ScriptSprite@>> m_variations;
	int m_variation;
	int m_width;
	int m_height;

	SpriteRect(const string &in filename)
	{
		auto sval = Resources::GetSValue(filename);
		if (sval is null)
		{
			PrintError("Couldn't load SpriteRect, sval does not exist: \"" + filename + "\"");
			return;
		}
		Load(sval);
	}

	SpriteRect(SValue@ sval)
	{
		Load(sval);
	}

	ScriptSprite@ LoadScriptSprite(SValue@ sval)
	{
		if (sval is null)
			return null;

		return ScriptSprite(sval.GetArray());
	}

	void Load(SValue@ sval)
	{
		if (sval is null)
		{
			PrintError("Couldn't load SpriteRect, sval was null!");
			return;
		}

		string strMode = GetParamString(UnitPtr(), sval, "mode");
		     if (strMode == "horizontal") m_mode = SpriteRectMode::Horizontal;
		else if (strMode == "vertical") m_mode = SpriteRectMode::Vertical;
		else if (strMode == "borders") m_mode = SpriteRectMode::Borders;
		else if (strMode == "all") m_mode = SpriteRectMode::All;
		else
		{
			PrintError("Unrecognized SpriteRect mode \"" + strMode + "\"");
			return;
		}

		string strBackground = GetParamString(UnitPtr(), sval, "background", false);
		if (strBackground != "")
			m_background = ParseColorRGBA(strBackground);

		auto arrSingleSprites = GetParamArray(UnitPtr(), sval, "sprites", false);
		if (arrSingleSprites !is null)
		{
			array<ScriptSprite@> sprites;
			for (uint i = 0; i < arrSingleSprites.length(); i++)
			{
				auto newSprite = ScriptSprite(arrSingleSprites[i].GetArray());
				sprites.insertLast(newSprite);
			}
			m_variations.insertLast(sprites);
		}
		else
		{
			auto arrVariations = GetParamArray(UnitPtr(), sval, "variations");
			for (uint i = 0; i < arrVariations.length(); i++)
			{
				auto arr = arrVariations[i].GetArray();

				array<ScriptSprite@> sprites;
				for (uint j = 0; j < arr.length(); j++)
				{
					auto newSprite = ScriptSprite(arr[j].GetArray());
					sprites.insertLast(newSprite);
				}
				m_variations.insertLast(sprites);
			}
		}

		vec4 topLeft = m_variations[0][0].GetFrame(0);
		vec4 bottomLeft = m_variations[0][m_variations[0].length() - 1].GetFrame(0);
		m_width = int((bottomLeft.x + bottomLeft.z) - topLeft.x);
		m_height = int((bottomLeft.y + bottomLeft.w) - topLeft.y);
	}

	int GetTop()
	{
		auto variation = m_variations[0];
		if (m_mode == SpriteRectMode::Vertical)
			return variation[0].GetHeight();
		else if (m_mode == SpriteRectMode::Borders || m_mode == SpriteRectMode::All)
			return variation[1].GetHeight();
		return 0;
	}

	int GetBottom()
	{
		auto variation = m_variations[0];
		if (m_mode == SpriteRectMode::Vertical)
			return variation[2].GetHeight();
		else if (m_mode == SpriteRectMode::Borders)
			return variation[6].GetHeight();
		else if (m_mode == SpriteRectMode::All)
			return variation[7].GetHeight();
		return 0;
	}

	int GetLeft()
	{
		auto variation = m_variations[0];
		if (m_mode == SpriteRectMode::Horizontal)
			return variation[0].GetWidth();
		else if (m_mode == SpriteRectMode::Borders || m_mode == SpriteRectMode::All)
			return variation[3].GetWidth();
		return 0;
	}

	int GetRight()
	{
		auto variation = m_variations[0];
		if (m_mode == SpriteRectMode::Horizontal)
			return variation[2].GetWidth();
		else if (m_mode == SpriteRectMode::Borders)
			return variation[4].GetWidth();
		else if (m_mode != SpriteRectMode::All)
			return variation[5].GetWidth();
		return 0;
	}

	void Draw(SpriteBatch& sb, vec2 pos, int width, int height, int variation = 0)
	{
		m_variation = variation;

		if (m_mode == SpriteRectMode::Horizontal)
			DrawHorizontal(sb, pos, width, height);
		else if (m_mode == SpriteRectMode::Vertical)
			DrawVertical(sb, pos, width, height);
		else if (m_mode == SpriteRectMode::Borders || m_mode == SpriteRectMode::All)
			DrawAll(sb, pos, width, height);
	}

	void DrawHorizontal(SpriteBatch& sb, vec2 pos, int width, int height)
	{
		auto variation = m_variations[m_variation];
		auto sLeft = variation[0];
		auto sMid = variation[1];
		auto sRight = variation[2];

		sLeft.Draw(sb, pos, g_menuTime);
		if (sMid.GetWidth() == 1)
		{
			vec4 dst = vec4(pos.x + sLeft.GetWidth(), pos.y, width - sLeft.GetWidth() - sRight.GetWidth(), height);
			sMid.Draw(sb, dst, g_menuTime);
		}
		else
			sMid.DrawWrapped(sb, pos + vec2(sLeft.GetWidth(), 0), vec2(width - sLeft.GetWidth() - sRight.GetWidth(), height), g_menuTime);
		sRight.Draw(sb, pos + vec2(max(sLeft.GetWidth(), width - sRight.GetWidth()), 0), g_menuTime);
	}

	void DrawVertical(SpriteBatch& sb, vec2 pos, int width, int height)
	{
		auto variation = m_variations[m_variation];
		auto sTop = variation[0];
		auto sMid = variation[1];
		auto sBottom = variation[2];

		sTop.Draw(sb, pos, g_menuTime);
		if (sMid.GetWidth() == 1)
		{
			vec4 dst = vec4(pos.x, pos.y + sTop.GetHeight(), width, height - sTop.GetHeight() - sBottom.GetHeight());
			sMid.Draw(sb, dst, g_menuTime);
		}
		else
			sMid.DrawWrapped(sb, pos + vec2(0, sTop.GetHeight()), vec2(width, height - sTop.GetHeight() - sBottom.GetHeight()), g_menuTime);
		sBottom.Draw(sb, pos + vec2(0, height - sBottom.GetHeight()), g_menuTime);
	}

	void DrawAll(SpriteBatch& sb, vec2 pos, int width, int height)
	{
		auto variation = m_variations[m_variation];

		ScriptSprite@ sNW, sN, sNE, sW, sFill, sE, sSW, sS, sSE;

		if (m_mode == SpriteRectMode::Borders)
		{
			@sNW = variation[0]; @sN = variation[1]; @sNE = variation[2];
			@sW = variation[3]; @sE = variation[4];
			@sSW = variation[5]; @sS = variation[6]; @sSE = variation[7];
		}
		else if (m_mode == SpriteRectMode::All)
		{
			@sNW = variation[0]; @sN = variation[1]; @sNE = variation[2];
			@sW = variation[3]; @sFill = variation[4]; @sE = variation[5];
			@sSW = variation[6]; @sS = variation[7]; @sSE = variation[8];
		}

		if (m_background.a > 0)
		{
			vec4 p(
				pos.x + sNW.GetWidth(),
				pos.y + sNW.GetHeight(),
				width - sNW.GetWidth() - sNE.GetWidth(),
				height - sNW.GetHeight() - sSW.GetHeight()
			);
			sb.DrawSprite(null, p, p, m_background);
		}

		if (sFill !is null)
			sFill.DrawWrapped(sb, pos, vec2(width, height), g_menuTime);

		int sizeN = width - sNW.GetWidth() - sNE.GetWidth();
		int sizeS = width - sSW.GetWidth() - sSE.GetWidth();
		int sizeW = height - sNW.GetHeight() - sSW.GetHeight();
		int sizeE = height - sNE.GetHeight() - sSE.GetHeight();

		sNW.Draw(sb, pos, g_menuTime);
		sN.Draw(sb, vec4(pos.x + sNW.GetWidth(), pos.y, sizeN, sN.GetHeight()), g_menuTime);
		sNE.Draw(sb, pos + vec2(sNW.GetWidth() + sizeN, 0), g_menuTime);

		sW.Draw(sb, vec4(pos.x, pos.y + sNW.GetHeight(), sW.GetWidth(), sizeW), g_menuTime);
		sE.Draw(sb, vec4(pos.x + width - sE.GetWidth(), pos.y + sNE.GetHeight(), sE.GetWidth(), sizeE), g_menuTime);

		sSW.Draw(sb, pos + vec2(0, height - sSW.GetHeight()), g_menuTime);
		sS.Draw(sb, vec4(pos.x + sSW.GetWidth(), pos.y + height - sS.GetHeight(), sizeS, sS.GetHeight()), g_menuTime);
		sSE.Draw(sb, pos + vec2(width - sSE.GetWidth(), height - sSE.GetHeight()), g_menuTime);
	}
}
