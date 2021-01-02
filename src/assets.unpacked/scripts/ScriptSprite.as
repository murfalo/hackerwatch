class ScriptSpriteFrame
{
	int time;
	vec4 frame;
	
	ScriptSpriteFrame(int time, vec4 frame)
	{
		this.time = time;
		this.frame = frame;
	}
}

class ScriptSprite
{
	Texture2D@ m_texture;
	TempTexture2D@ m_textureTemp;
	array<ScriptSpriteFrame@> m_frames;
	int m_length;
	vec2 m_srcOffset;

	ScriptSprite(array<SValue@>@ params)
	{
		@m_texture = Resources::GetTexture2D(params[0].GetString());
		m_length = 0;
		for (uint i = 1; i < params.length(); i += 2)
		{
			int time = params[i].GetInteger();
			m_frames.insertLast(ScriptSpriteFrame(time, params[i + 1].GetVector4()));
			m_length += time;
		}
	}

	ScriptSprite(Texture2D@ texture, vec4 frame)
	{
		@m_texture = texture;
		m_frames.insertLast(ScriptSpriteFrame(100, frame));
		m_length = 100;
	}

	ScriptSprite(TempTexture2D@ textureTemp, vec4 frame)
	{
		@m_textureTemp = textureTemp;
		@m_texture = textureTemp.GetTexture();
		m_frames.insertLast(ScriptSpriteFrame(100, frame));
		m_length = 100;
	}
	
	int GetWidth()
	{
		return int(m_frames[0].frame.z);
	}
	
	int GetHeight()
	{
		return int(m_frames[0].frame.w);
	}

	vec2 GetSize()
	{
		return vec2(GetWidth(), GetHeight());
	}
	
	vec4 GetFrame(int time)
	{
		vec4 ret = m_frames[0].frame;

		time %= m_length;
		for (uint i = 0; i < m_frames.length(); i++)
		{
			time -= m_frames[i].time;
			if (time <= 0)
			{
				ret = m_frames[i].frame;
				break;
			}
		}

		ret.x += m_srcOffset.x;
		ret.y += m_srcOffset.y;

		return ret;
	}
	
	void Draw(SpriteBatch& sb, vec2 pos, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		vec4 frame = GetFrame(time);
		vec4 p = vec4(pos.x, pos.y, frame.z, frame.w);
	
		sb.DrawSprite(m_texture, p, frame, color);
	}

	void Draw(SpriteBatch& sb, vec2 pos, vec2 src, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		vec4 frame = GetFrame(time);
		vec4 p = vec4(pos.x, pos.y, src.x, src.y);
	
		sb.DrawSprite(m_texture, p, vec4(frame.x, frame.y, src.x, src.y), color);
	}

	void Draw(SpriteBatch& sb, vec4 dest, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		vec4 frame = GetFrame(time);
		sb.DrawSprite(m_texture, dest, frame, color);
	}

	void DrawWrapped(SpriteBatch& sb, vec2 pos, vec2 size, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		vec4 frame = GetFrame(time);
		sb.DrawSpriteWrapped(m_texture, frame, pos, size, color);
	}

	void DrawWrapped(SpriteBatch& sb, vec4 dest, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		DrawWrapped(sb, vec2(dest.x, dest.y), vec2(dest.z, dest.w), time, color);
	}

	void DrawRadial(SpriteBatch& sb, vec2 pos, float r, int time, vec4 color = vec4(1, 1, 1, 1))
	{
		vec4 frame = GetFrame(time);
		vec4 p = vec4(pos.x, pos.y, frame.z, frame.w);

		sb.DrawSpriteRadial(m_texture, p, frame, r, color);
	}
}
