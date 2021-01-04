enum SliderLabelType
{
	None,
	Percentage,
	PercentageAbsolute,
	Value,
	RealValue
}

class SliderWidget : Widget
{
	float m_value;
	float m_min;
	float m_max;
	float m_epsilon;
	float m_default;
	float m_orig;

	bool m_enabled;
	bool m_allowMouseWheel;

	string m_func;
	string m_funcOnChange;
	bool m_float;

	float m_skew;

	string m_maxString;

	Sprite@ m_spriteValue;
	SpriteRect@ m_spriteContainer;
	SpriteRect@ m_spriteContainerDisabled;
	SpriteRect@ m_spriteBlock;
	array<Sprite@> m_spriteButtonLeft; // normal, hover, down
	array<Sprite@> m_spriteButtonRight; // normal, hover, down

	bool m_overHandle;
	int m_overHandleX;

	int m_buttonsSize;
	int m_troughContentOffset;
	int m_troughOffset;
	int m_troughSize;

	int m_handleX;
	int m_handleSize;

	bool m_handleHover;
	bool m_buttonLeftHover;
	bool m_buttonLeftPressed;
	bool m_buttonRightHover;
	bool m_buttonRightPressed;

	SoundEvent@ m_pressSound;
	SoundEvent@ m_selectSound;

	SliderLabelType m_labelType;
	BitmapFont@ m_labelFont;
	BitmapString@ m_labelText;
	vec4 m_labelColor;

	BitmapFont@ m_font;
	BitmapString@ m_text;
	vec4 m_textColor;

	bool m_changed;

	void Load(WidgetLoadingContext &ctx) override
	{
		m_enabled = ctx.GetBoolean("enabled", false, true);
		m_allowMouseWheel = ctx.GetBoolean("allow-mousewheel", false, true);

		m_value = ctx.GetFloat("value", false, 0.0);
		m_min = ctx.GetFloat("min", false, 0.0);
		m_max = ctx.GetFloat("max", false, 1.0);
		m_epsilon = ctx.GetFloat("epsilon", false, 0.025);

		m_func = ctx.GetString("func", false);
		m_funcOnChange = ctx.GetString("func-on-change", false);
		m_float = ctx.GetBoolean("float", false, true);

		m_skew = ctx.GetFloat("skew", false, 0.5f);

		m_maxString = ctx.GetString("max-string", false);

		Widget::Load(ctx);

		LoadWidthHeight(ctx);

		GUIDef@ def = ctx.GetGUIDef();

		string spriteSet = ctx.GetString("spriteset");
		@m_spriteValue = def.GetSprite(spriteSet + "-value");
		@m_spriteContainer = SpriteRect("gui/variable/" + spriteSet + "/inside_borders.sval");
		@m_spriteContainerDisabled = SpriteRect("gui/variable/" + spriteSet + "/inside_disabled_borders.sval");
		@m_spriteBlock = SpriteRect("gui/variable/" + spriteSet + "/handle_borders.sval");
		m_spriteButtonLeft.insertLast(def.GetSprite(spriteSet + "-button-left"));
		m_spriteButtonLeft.insertLast(def.GetSprite(spriteSet + "-button-left-hover"));
		m_spriteButtonLeft.insertLast(def.GetSprite(spriteSet + "-button-left-down"));
		m_spriteButtonLeft.insertLast(def.GetSprite(spriteSet + "-button-left-disabled"));
		m_spriteButtonRight.insertLast(def.GetSprite(spriteSet + "-button-right"));
		m_spriteButtonRight.insertLast(def.GetSprite(spriteSet + "-button-right-hover"));
		m_spriteButtonRight.insertLast(def.GetSprite(spriteSet + "-button-right-down"));
		m_spriteButtonRight.insertLast(def.GetSprite(spriteSet + "-button-right-disabled"));

		@m_pressSound = Resources::GetSoundEvent("event:/ui/button_click");
		@m_selectSound = Resources::GetSoundEvent("event:/ui/button_hover");

		string labelType = ctx.GetString("label-type", false, "none");
		     if (labelType == "none") m_labelType = SliderLabelType::None;
		else if (labelType == "percentage") m_labelType = SliderLabelType::Percentage;
		else if (labelType == "percentage-absolute") m_labelType = SliderLabelType::PercentageAbsolute;
		else if (labelType == "value") m_labelType = SliderLabelType::Value;
		else if (labelType == "realvalue") m_labelType = SliderLabelType::RealValue;
		else
			print("WARNING: Unknown slider label type '" + labelType + "'");

		m_troughContentOffset = 4;
		m_troughOffset = m_spriteButtonLeft[0].GetWidth() + m_troughContentOffset;
		if (m_labelType != SliderLabelType::None && m_spriteValue !is null)
			m_troughOffset += m_spriteValue.GetWidth();
		m_troughSize = m_width - m_troughOffset - m_troughContentOffset - m_spriteButtonRight[0].GetWidth();

		if (m_func != "")
		{
			float v = 0.0;
			if (m_float)
				v = GetVarFloat(m_func);
			else
				v = float(GetVarInt(m_func));
			m_value = (v - m_min) / (m_max - m_min);
		}

		if (m_labelType != SliderLabelType::None)
		{
			@m_labelFont = Resources::GetBitmapFont(ctx.GetString("label-font", false));
			m_labelColor = ctx.GetColorRGBA("label-color", false, vec4(1, 1, 1, 1));
			UpdateText();
		}

		@m_font = Resources::GetBitmapFont(ctx.GetString("font", false));
		if (m_font !is null)
		{
			string text = Resources::GetString(ctx.GetString("text"));
			@m_text = m_font.BuildText(text, -1, TextAlignment::Center);
			m_text.SetColor(ctx.GetColorRGBA("textcolor", false, vec4(1, 1, 1, 1)));
		}

		if (m_float)
		{
			m_orig = GetVarFloat(m_func);
			m_default = GetVarFloatDefault(m_func);
		}
		else
		{
			m_orig = float(GetVarInt(m_func));
			m_default = float(GetVarIntDefault(m_func));
		}

		m_canFocus = true;
	}

	void Reset()
	{
		SetValue((m_default - m_min) / (m_max - m_min));
	}

	void SetValue(float scale)
	{
		m_value = scale;
		if (m_func != "")
		{
			if (m_float)
				SetVar(m_func, m_default);
			else
				SetVar(m_func, int(m_default));
		}
		m_changed = false;
		UpdateText();
	}

	void SetValueInt(int value)
	{
		m_value = value / m_max;
		if (m_func != "")
		{
			if (m_float)
				SetVar(m_func, m_default);
			else
				SetVar(m_func, int(m_default));
		}
		m_changed = false;
		UpdateText();
	}

	void Cancel()
	{
		m_value = (m_orig - m_min) / (m_max - m_min);
		if (m_float)
			SetVar(m_func, m_orig);
		else
			SetVar(m_func, int(m_orig));
	}

	void Save()
	{
		m_changed = false;
		Config::SaveVar(m_func);
	}

	bool IsChanged()
	{
		return m_changed;
	}

	void UpdateText()
	{
		if (m_labelFont is null)
			return;

		float value = GetScaleValue();
		float realValue = lerp(m_min, m_max, value);

		string str = "";
		switch (m_labelType)
		{
			case SliderLabelType::Percentage:
				str = "" + int(value * 100);
				break;

			case SliderLabelType::PercentageAbsolute:
				str = "" + int(realValue * 100);
				break;

			case SliderLabelType::Value:
				str = "" + round(value, 1);
				break;

			case SliderLabelType::RealValue:
				if (m_float)
					str = "" + round(realValue, 1);
				else
					str = "" + int(realValue);
				break;
		}

		if (m_maxString != "")
		{
			if ((m_float && realValue == m_max) || (!m_float && int(realValue) == int(m_max)))
				str = Resources::GetString(m_maxString);
		}

		@m_labelText = m_labelFont.BuildText(str, -1, TextAlignment::Center);
		m_labelText.SetColor(m_labelColor);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		Widget::DoDraw(sb, pos);

		auto tm = g_menuTime;
		
		Sprite@ leftButton = m_spriteButtonLeft[0];
		if (!m_enabled)
			@leftButton = m_spriteButtonLeft[3];
		else if (m_buttonLeftPressed)
			@leftButton = m_spriteButtonLeft[2];
		else if (m_buttonLeftHover)
			@leftButton = m_spriteButtonLeft[1];
		sb.DrawSprite(pos, leftButton, tm);

		Sprite@ rightButton = m_spriteButtonRight[0];
		if (!m_enabled)
			@rightButton = m_spriteButtonRight[3];
		else if (m_buttonRightPressed)
			@rightButton = m_spriteButtonRight[2];
		else if (m_buttonRightHover)
			@rightButton = m_spriteButtonRight[1];
		sb.DrawSprite(pos + vec2(m_width - rightButton.GetWidth(), 0), rightButton, tm);

		if (m_labelType != SliderLabelType::None && m_spriteValue !is null)
			sb.DrawSprite(pos + vec2(leftButton.GetWidth(), 0), m_spriteValue, tm);

		float troughX = leftButton.GetWidth();
		if (m_labelType != SliderLabelType::None && m_spriteValue !is null)
			troughX += m_spriteValue.GetWidth();
		float troughMidW = (m_troughSize + m_troughContentOffset * 2);

		if (m_enabled)
			m_spriteContainer.Draw(sb, pos + vec2(troughX, 0), int(troughMidW), m_height);
		else
			m_spriteContainerDisabled.Draw(sb, pos + vec2(troughX, 0), int(troughMidW), m_height);

		if (m_text !is null)
		{
			if (m_enabled)
				m_text.SetColor(m_textColor);
			else
				m_text.SetColor(vec4(0.5, 0.5, 0.5, 1));

			sb.DrawString(pos + vec2(
				m_width / 2 - m_text.GetWidth() / 2,
				m_height / 2 - m_text.GetHeight() / 2
			), m_text);
		}

		int blockIndex = 0;
		if (m_overHandle)
			blockIndex = 2;
		else if (m_handleHover)
			blockIndex = 1;

		if (m_enabled)
		{
			float blockStart = m_troughOffset;
			float blockLength = m_troughSize - 11;
			m_spriteBlock.Draw(sb, pos + vec2(lerp(blockStart, blockStart + blockLength, m_value), 1), 11, m_height - 2, blockIndex);
		}

		if (m_labelText !is null && m_spriteValue !is null)
		{
			sb.DrawString(pos + vec2(
				m_spriteButtonLeft[0].GetWidth() + 2 + m_spriteValue.GetWidth() / 2 - m_labelText.GetWidth() / 2,
				m_spriteValue.GetHeight() / 2 - m_labelText.GetHeight() / 2
			), m_labelText);
		}
	}

	float GetScaleValue()
	{
		float skewFactor = 1.0f;

		if (m_skew != 0.5f && m_skew > 0.0f && m_skew < 1.0f)
			skewFactor = 1.0f / (m_value + (1.0f - (1.0f / m_skew)) * (m_value - 1.0f));

		return m_value * skewFactor;
	}

	float GetValue()
	{
		return lerp(m_min, m_max, GetScaleValue());
	}

	int GetValueInt()
	{
		return int(GetValue());
	}

	void UpdateVar()
	{
		if (m_func != "")
		{
			m_changed = true;
			if (m_float)
				SetVar(m_func, GetValue());
			else
				SetVar(m_func, int(GetValue()));
		}

		if (m_funcOnChange != "")
			m_host.OnFunc(this, m_funcOnChange);
	}

	void Update(int dt) override
	{
		Widget::Update(dt);

		if (!m_enabled)
			return;

		vec2 mousePos = (GetGameModeMousePosition() / g_gameMode.m_wndScale) - m_origin;
		MenuInput@ input = GetMenuInput();

		int handleSize = 11;

		if (input.Forward.Down)
		{
			if (m_overHandle)
			{
				int moveHandleX = int(mousePos.x - m_troughOffset - m_overHandleX);
				if (moveHandleX < 0)
					moveHandleX = 0;
				else if (moveHandleX > m_troughSize - handleSize)
					moveHandleX = m_troughSize - handleSize;

				m_value = moveHandleX / float(m_troughSize - handleSize);
				UpdateText();
				UpdateVar();
			}

			int scrollSpeed = 3;
			if (m_buttonLeftPressed)
			{
				m_value -= 0.025f;
				if (m_value > 1.0f)
					m_value = 1.0f;
				else if (m_value < 0.0f)
					m_value = 0.0f;
				UpdateText();
				UpdateVar();
			}
			else if (m_buttonRightPressed)
			{
				m_value += 0.025f;
				if (m_value > 1.0f)
					m_value = 1.0f;
				else if (m_value < 0.0f)
					m_value = 0.0f;
				UpdateText();
				UpdateVar();
			}
		}
		else
		{
			m_overHandle = false;
			m_buttonLeftPressed = false;
			m_buttonRightPressed = false;
		}

		float posFactor = m_value;
		if (posFactor < m_epsilon)
			posFactor = 0;
		else if (posFactor > 1 - m_epsilon)
			posFactor = 1;

		m_handleX = int(posFactor * (m_troughSize - handleSize));

		m_buttonLeftHover = (m_hovering && mousePos.x < m_spriteButtonLeft[0].GetWidth());
		m_buttonRightHover = (m_hovering && mousePos.x > m_width - m_spriteButtonRight[0].GetWidth());
		m_handleHover = (m_overHandle || (m_hovering && mousePos.x > m_troughOffset + m_handleX && mousePos.x < m_troughOffset + m_handleX + handleSize));
	}

	bool UpdateInput(vec2 origin, vec2 parentSz, vec3 mousePos) override
	{
		if (m_hovering && mousePos.z != 0.0f && m_allowMouseWheel)
		{
			m_value += mousePos.z * (1.0f / m_max);
			if (m_value > 1.0f)
				m_value = 1.0f;
			else if (m_value < 0.0f)
				m_value = 0.0f;

			UpdateText();
			UpdateVar();
		}

		return Widget::UpdateInput(origin, parentSz, mousePos);
	}

	bool OnMouseDown(vec2 mousePos) override
	{
		if (!m_enabled)
			return false;

		if (mousePos.x > m_troughOffset && mousePos.x < m_troughOffset + m_troughSize)
		{
			int handleSize = 11;

			if (mousePos.x <= m_troughOffset + m_handleX || mousePos.x >= m_troughOffset + m_handleX + handleSize)
			{
				m_value = (mousePos.x - m_troughOffset) / m_troughSize;

				float posFactor = m_value;
				if (posFactor < m_epsilon)
					posFactor = 0;
				else if (posFactor > 1 - m_epsilon)
					posFactor = 1;

				m_handleX = int(posFactor * (m_troughSize - handleSize));
			}
			vec2 absMousePos = (GetGameModeMousePosition() / g_gameMode.m_wndScale) - m_origin;
			m_overHandle = true;
			m_overHandleX = int(absMousePos.x - m_troughOffset) - m_handleX;
		}

		if (m_buttonLeftHover)
			m_buttonLeftPressed = true;

		if (m_buttonRightHover)
			m_buttonRightPressed = true;

		return true;
	}
}

ref@ LoadSliderWidget(WidgetLoadingContext &ctx)
{
	SliderWidget@ w = SliderWidget();
	w.Load(ctx);
	return w;
}
