array<FloatingText@> g_floatingTexts;
dictionary _cachedText;
bool _loadingColors;

enum FloatingTextType
{
	PlayerHurt,
	PlayerHurtMagical,
	PlayerHealed,
	PlayerArmor,
	PlayerAmmo,
	EnemyHurt,
	EnemyHurtLocal,
	EnemyHurtHusk,
	EnemyHealed,
	EnemyImmortal,
	Pickup
}

class FloatingText
{
	BitmapString@ m_text;
	FloatingTextType m_type;

	string m_consoleColor;
	string m_floatingText;
	int m_num;
	vec3 m_pos;

	int m_ttl;
	int m_timeLived;
	bool m_alive;

	FloatingText(FloatingTextType type, string color, string text, vec3 pos)
	{
		if (type == FloatingTextType::Pickup)
			@m_text = g_floatTextFontBig.BuildText(color + text, -1, TextAlignment::Center);
		else
		{
			string txt = color + text;
			bool short = (text.length() <= 4);
			if (short)
				_cachedText.get(txt, @m_text);

			if (m_text is null)
			{
				@m_text = g_floatTextFont.BuildText(txt, -1, TextAlignment::Center);
				if (short)
					_cachedText.set(txt, @m_text);
			}
		}

		m_type = type;

		m_consoleColor = color;
		m_floatingText = text;
		m_pos = pos;
		m_pos.x += randi(8) - 4;
		m_pos.y += randi(8) - 4;

		m_ttl = Tweak::FloatingTextTime;
		m_alive = true;
	}
	
	void Update(int dt)
	{
		m_ttl -= dt;
		m_timeLived += dt;
		m_pos.y -= dt * FloatingTextSpeed;

		if (m_ttl <= 0)
			m_alive = false;
	}

	void Draw(int idt, SpriteBatch &sb)
	{
		vec3 pos = m_pos;
		pos.y -= idt * FloatingTextSpeed;

		vec2 p = ToScreenspace(pos);
		p.x -= m_text.GetWidth();

		sb.DrawString(p / g_gameMode.m_wndScale, m_text);
	}
}

void InitializeFloatingText()
{
	_loadingColors = true;
	AddVar("ui_txt", true, UpdateFloatingTextColorsCFuncB);
	AddVar("ui_txt_plr_hurt", Tweak::FloatingTextColor_PlayerHurt, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_plr_hurt_magic", Tweak::FloatingTextColor_PlayerHurtMagical, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_enemy_hurt", Tweak::FloatingTextColor_EnemyHurt, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_enemy_hurt_local", Tweak::FloatingTextColor_EnemyHurtLocal, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_enemy_hurt_husk", Tweak::FloatingTextColor_EnemyHurtHusk, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_plr_heal", Tweak::FloatingTextColor_PlayerHeal, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_enemy_heal", Tweak::FloatingTextColor_EnemyHeal, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_enemy_immortal", Tweak::FloatingTextColor_EnemyImmortal, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_plr_armor", Tweak::FloatingTextColor_PlayerArmor, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_plr_ammo", Tweak::FloatingTextColor_PlayerAmmo, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_plr_ammo_max", Tweak::FloatingTextColor_PlayerAmmoMax, UpdateFloatingTextColorsCFuncS);
	AddVar("ui_txt_pickup", Tweak::FloatingTextColor_Pickup, UpdateFloatingTextColorsCFuncS);
	_loadingColors = false;
	UpdateFloatingTextColorsCFuncB(false);
}

string GetConsoleColor(string name)
{
	string c = GetVarString(name);
	if (c == "")
		return "";

	return "\\c" + c;
}

void UpdateFloatingTextColorsCFuncS(string val)
{
	UpdateFloatingTextColorsCFuncB(false);
}

void UpdateFloatingTextColorsCFuncB(bool val)
{
	if (_loadingColors)
		return;

	if (GetVarBool("ui_txt"))
	{
		Tweak::FloatingTextColor_PlayerHurt = GetConsoleColor("ui_txt_plr_hurt");
		Tweak::FloatingTextColor_PlayerHurtMagical = GetConsoleColor("ui_txt_plr_hurt_magic");
		Tweak::FloatingTextColor_EnemyHurt = GetConsoleColor("ui_txt_enemy_hurt");
		Tweak::FloatingTextColor_EnemyHurtLocal = GetConsoleColor("ui_txt_enemy_hurt_local");
		Tweak::FloatingTextColor_EnemyHurtHusk = GetConsoleColor("ui_txt_enemy_hurt_husk");
		Tweak::FloatingTextColor_PlayerHeal = GetConsoleColor("ui_txt_plr_heal");
		Tweak::FloatingTextColor_EnemyHeal = GetConsoleColor("ui_txt_enemy_heal");
		Tweak::FloatingTextColor_EnemyImmortal = GetConsoleColor("ui_txt_enemy_immortal");
		Tweak::FloatingTextColor_PlayerArmor = GetConsoleColor("ui_txt_plr_armor");
		Tweak::FloatingTextColor_PlayerAmmo = GetConsoleColor("ui_txt_plr_ammo");
		Tweak::FloatingTextColor_PlayerAmmoMax = GetConsoleColor("ui_txt_plr_ammo_max");
		Tweak::FloatingTextColor_Pickup = GetConsoleColor("ui_txt_pickup");
	}
	else
	{
		Tweak::FloatingTextColor_PlayerHurt = "";
		Tweak::FloatingTextColor_PlayerHurtMagical = "";
		Tweak::FloatingTextColor_EnemyHurt = "";
		Tweak::FloatingTextColor_EnemyHurtLocal = "";
		Tweak::FloatingTextColor_EnemyHurtHusk = "";
		Tweak::FloatingTextColor_PlayerHeal = "";
		Tweak::FloatingTextColor_EnemyHeal = "";
		Tweak::FloatingTextColor_EnemyImmortal = "";
		Tweak::FloatingTextColor_PlayerArmor = "";
		Tweak::FloatingTextColor_PlayerAmmo = "";
		Tweak::FloatingTextColor_PlayerAmmoMax = "";
		Tweak::FloatingTextColor_Pickup = "";
	}
}

FloatingText@ AddFloatingText(FloatingTextType type, string text, vec3 pos)
{
%if MOD_NO_HUD
	return null;
%else
	vec2 p = ToScreenspace(pos) / g_gameMode.m_wndScale;
	if (p.x < 0 || p.x > g_gameMode.m_wndWidth || p.y < 0 || p.y > g_gameMode.m_wndHeight)
		return null;

	string color;

	switch(type)
	{
	case FloatingTextType::PlayerHurt:
		color = Tweak::FloatingTextColor_PlayerHurt;
		break;
	case FloatingTextType::PlayerHurtMagical:
		color = Tweak::FloatingTextColor_PlayerHurtMagical;
		break;
	case FloatingTextType::EnemyHurt:
		color = Tweak::FloatingTextColor_EnemyHurt;
		break;
	case FloatingTextType::EnemyHurtLocal:
		color = Tweak::FloatingTextColor_EnemyHurtLocal;
		break;
	case FloatingTextType::EnemyHurtHusk:
		color = Tweak::FloatingTextColor_EnemyHurtHusk;
		break;
	case FloatingTextType::PlayerHealed:
		color = Tweak::FloatingTextColor_PlayerHeal;
		break;
	case FloatingTextType::EnemyHealed:
		color = Tweak::FloatingTextColor_EnemyHeal;
		break;
	case FloatingTextType::EnemyImmortal:
		color = Tweak::FloatingTextColor_EnemyImmortal;
		break;
	case FloatingTextType::PlayerArmor:
		color = Tweak::FloatingTextColor_PlayerArmor;
		break;
	case FloatingTextType::PlayerAmmo:
		color = Tweak::FloatingTextColor_PlayerAmmo;
		break;
	case FloatingTextType::Pickup:
		color = Tweak::FloatingTextColor_Pickup;
		break;
	}

	if (color == "")
		return null;

	FloatingText@ fTxt = FloatingText(type, color, text, pos);
	g_floatingTexts.insertLast(fTxt);

	return fTxt;
%endif
}

FloatingText@ AddFloatingNumber(FloatingTextType type, int num, vec3 pos)
{
	FloatingText@ fTxt = AddFloatingText(type, "" + num, pos);
	if (fTxt !is null)
		fTxt.m_num = num;
	return fTxt;
}
