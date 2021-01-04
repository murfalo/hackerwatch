float lerp(const float v0, const float v1, float t) 
{
	return (1.0 - t) * v0 + t * v1;
}

int lerp(const int v0, const int v1, float t) 
{
	return int((1.0 - t) * v0 + t * v1);
}

vec2 lerp(const vec2 v0, const vec2 v1, float t)
{
	return vec2((1.0 - t) * v0.x + t * v1.x, (1.0 - t) * v0.y + t * v1.y);
}

vec3 lerp(const vec3 v0, const vec3 v1, float t)
{
	return vec3((1.0 - t) * v0.x + t * v1.x, (1.0 - t) * v0.y + t * v1.y, (1.0 - t) * v0.z + t * v1.z);
}

vec4 lerp(const vec4 v0, const vec4 v1, float t)
{
	return vec4((1.0 - t) * v0.x + t * v1.x, (1.0 - t) * v0.y + t * v1.y, (1.0 - t) * v0.z + t * v1.z, (1.0 - t) * v0.w + t * v1.w);
}

float ilerp(const float v0, const float v1, const float v)
{
	return (v - v0) / (v1 - v0);
}

float ilerp(const int v0, const int v1, const int v)
{
	return (v - v0) / float(v1 - v0);
}

float clamp(const float val, const float minVal, const float maxVal)
{
	return (val < minVal) ? minVal : ((val > maxVal) ? maxVal : val);
}

int clamp(const int val, const int minVal, const int maxVal)
{
	return (val < minVal) ? minVal : ((val > maxVal) ? maxVal : val);
}

float min(const float v0, const float v1)
{
	return v0 < v1 ? v0 : v1;
}

int min(const int v0, const int v1)
{
	return v0 < v1 ? v0 : v1;
}

float max(const float v0, const float v1)
{
	return v0 > v1 ? v0 : v1;
}

int max(const int v0, const int v1)
{
	return v0 > v1 ? v0 : v1;
}

float abs(const float v)
{
	return v > 0 ? v : -v;
}

int abs(const int v)
{
	return v > 0 ? v : -v;
}

int64 abs(const int64 v)
{
	return v > 0 ? v : -v;
}

int sign(const int v)
{
	if (v < 0) return -1;
	if (v > 0) return 1;
	return 0;
}

int sign(const float v)
{
	if (v < 0) return -1;
	if (v > 0) return 1;
	return 0;
}

vec2 xy(vec3 v)
{
	return vec2(v.x, v.y);
}

vec2 xy(vec4 v)
{
	return vec2(v.x, v.y);
}

vec3 xyz(vec4 v)
{
	return vec3(v.x, v.y, v.z);
}

vec3 xyz(vec2 v)
{
	return vec3(v.x, v.y, 0);
}

vec3 xyz(vec2 v, float z)
{
	return vec3(v.x, v.y, z);
}

vec4 xyzw(vec3 v, float w)
{
	return vec4(v.x, v.y, v.z, w);
}

float randfn()
{
	return randf() * 2.0 - 1.0;
}

float rottowards(float source, float target, float amount)
{
	source = capangle(source);
	target = capangle(target);

	float difference = abs(source - target);
	amount = min(amount, difference % PI);

	if (difference < PI && target > source) return source + amount;
	if (difference < PI && target < source) return source - amount;

	if (difference > PI && target > source) return source - amount;
	if (difference > PI && target < source) return source + amount;

	if (difference == PI || difference == 0) return source + amount;
	return source;
}

// Source: https://stackoverflow.com/questions/2708476/rotation-interpolation
float lerprot(float source, float target, float amount)
{
	source = capangle(source);
	target = capangle(target);
	float shortest = ((((target - source) % TwoPI) + (TwoPI + PI)) % TwoPI) - PI;
	return capangle(source + (shortest * amount) % TwoPI);
}

float capangle(float angle)
{
	angle = angle % TwoPI;
	if (angle < 0)
		angle += TwoPI;

	return angle;
}

float angdiff(float a, float b)
{
    if (abs(b - a) < PI)
        return b - a;
    if (b > a)
        return b - a - TwoPI;
    return b - a + TwoPI;
}

vec2 addrot(vec2 v, float rad)
{
	float ang = atan(v.y, v.x);
	return vec2(cos(ang + rad), sin(ang + rad));
}

int distsq(Actor@ a, Actor@ b)
{
	vec3 pa = a.m_unit.GetPosition();
	vec3 pb = b.m_unit.GetPosition();

	float dx = pa.x - pb.x;
	float dy = pa.y - pb.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(UnitPtr a, UnitPtr b)
{
	vec3 pa = a.GetPosition();
	vec3 pb = b.GetPosition();

	float dx = pa.x - pb.x;
	float dy = pa.y - pb.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(Actor@ a, UnitPtr b)
{
	vec3 pa = a.m_unit.GetPosition();
	vec3 pb = b.GetPosition();

	float dx = pa.x - pb.x;
	float dy = pa.y - pb.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(UnitPtr a, Actor@ b)
{
	vec3 pa = a.GetPosition();
	vec3 pb = b.m_unit.GetPosition();

	float dx = pa.x - pb.x;
	float dy = pa.y - pb.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(UnitPtr a, vec2 b)
{
	vec3 pa = a.GetPosition();

	float dx = pa.x - b.x;
	float dy = pa.y - b.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(Actor@ a, vec2 b)
{
	vec3 pa = a.m_unit.GetPosition();

	float dx = pa.x - b.x;
	float dy = pa.y - b.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(vec2 b, UnitPtr a)
{
	vec3 pa = a.GetPosition();

	float dx = pa.x - b.x;
	float dy = pa.y - b.y;
	
	return int(dx * dx + dy * dy);
}

int distsq(vec2 b, Actor@ a)
{
	vec3 pa = a.m_unit.GetPosition();

	float dx = pa.x - b.x;
	float dy = pa.y - b.y;
	
	return int(dx * dx + dy * dy);
}

vec4 desaturate(const vec4 &in color)
{
	ColorHSV hsv(color);
	hsv.Saturation *= 0.5f;
	hsv.Value *= 0.35f;
	return tocolor(hsv.ToColorRGBA());
}

string formatTime(double tm, bool fractions = false, bool forceMinutes = false, bool forceHours = false, bool letters = false, bool short = false)
{
	string str = "";

	int milliseconds = int((tm % 1.0) * 1000);
	int seconds = int(tm % 60);
	int minutes = int(tm / 60) % 60;
	int hours = int(tm / 60 / 60);

	if (hours > 0 || forceHours)
	{
		str += hours;
		if (letters)
			str += Resources::GetString(".misc.timeletters.hours") + " ";
		else
			str += ":";
	}
	if (minutes > 0 || hours > 0 || forceMinutes)
	{
		str += formatInt(minutes, "0", (hours > 0 || forceHours) ? 2 : 1);
		if (letters)
			str += Resources::GetString(".misc.timeletters.minutes") + " ";
		else
			str += ":";
	}
	
	str += formatInt(seconds, "0", (minutes > 0 || hours > 0 || forceMinutes) ? 2 : 1);
	if (fractions)
	{
		str += ".";
		
		if (short)
			str += formatInt(max(1, milliseconds / 100), "0", 1);
		else
			str += formatInt(milliseconds, "0", 3);
	}
	
	if (letters)
		str += Resources::GetString(".misc.timeletters.seconds");

	return str;
}

enum EasingFunction
{
	Linear,
	Smoothstep,
	Quad,
	QuadIn,
	QuadOut,
	Cubic,
	CubicIn,
	CubicOut,
	Sine,
	Elastic
};

EasingFunction ParseEasingFunction(const string &in str)
{
	if (str == "" || str == "linear") return EasingFunction::Linear;
	else if (str == "ss" || str == "smoothstep") return EasingFunction::Smoothstep;
	else if (str == "quad") return EasingFunction::Quad;
	else if (str == "quad-in") return EasingFunction::QuadIn;
	else if (str == "quad-out") return EasingFunction::QuadOut;
	else if (str == "cubic") return EasingFunction::Cubic;
	else if (str == "cubic-in") return EasingFunction::CubicIn;
	else if (str == "cubic-out") return EasingFunction::CubicOut;
	else if (str == "sine") return EasingFunction::Sine;
	else if (str == "elastic") return EasingFunction::Elastic;

	PrintError("Unrecognized easing function \"" + str + "\"");
	return EasingFunction::Linear;
}

float ease(float x, EasingFunction func)
{
	switch (func)
	{
		case EasingFunction::Smoothstep: return smoothstep(x);
		case EasingFunction::Quad: return easeQuad(x);
		case EasingFunction::QuadIn: return easeQuadIn(x);
		case EasingFunction::QuadOut: return easeQuadOut(x);
		case EasingFunction::Cubic: return easeCubic(x);
		case EasingFunction::CubicIn: return easeCubicIn(x);
		case EasingFunction::CubicOut: return easeCubicOut(x);
		case EasingFunction::Sine: return easeSine(x);
		case EasingFunction::Elastic: return easeElastic(x);
	}
	return x;
}

float smoothstep(float x)
{
	return x * x * (3.0f - 2.0f * x);
}

float easeQuad(float x)
{
	if ((x /= 0.5) < 1) return 0.5 * x * x;
	return -0.5 * ((--x) * (x - 2) - 1);
}

float easeQuadIn(float x)
{
	return x * x;
}

float easeQuadOut(float x)
{
	return -x * (x - 2);
}

float easeCubic(float x)
{
	if ((x /= 0.5) < 1) return 0.5 * x * x * x;
	return 0.5 * ((x -= 2) * x * x + 2);
}

float easeCubicIn(float x)
{
	return x * x * x;
}

float easeCubicOut(float x)
{
	return (x -= 1) * x * x + 1;
}

float easeSine(float x)
{
	return -0.5 * (cos(PI * x) - 1);
}

float easeElastic(float x)
{
	float s = 0.1125;
	if (x == 0) return 0;
	if ((x /= 0.5) == 2) return 1;
	if (x < 1) return -0.5 * (pow(2, 10 * (x -= 1)) * sin((x - s) * (2 * PI) / 0.45));
	return pow(2, -10 * (x -= 1)) * sin((x - s) * (2 * PI) / 0.45) * 0.5 + 1;
}

//TODO: Move to engine?
string strTrim(string str, string chars = " \n")
{
	if (str.isEmpty())
		return str;

	for (uint i = 0; i < str.length(); i++)
	{
		string c = str.substr(i, 1);
		if (chars.findFirst(c) == -1)
		{
			str = str.substr(i);
			break;
		}
	}

	for (int i = int(str.length()) - 1; i >= 0; i--)
	{
		string c = str.substr(i, 1);
		if (chars.findFirst(c) == -1)
		{
			str = str.substr(0, i + 1);
			break;
		}
	}

	if (chars.findFirst(str.substr(0, 1)) != -1)
		return "";

	return str;
}

string strJoin(const array<string> &in arr, const string &in glue, bool skipEmpty = false)
{
	string ret;

	bool second = false;
	for (uint i = 0; i < arr.length(); i++)
	{
		string str = arr[i];
		if (skipEmpty && str == "")
			continue;

		if (second)
			ret += glue;
		second = true;

		ret += str;
	}

	return ret;
}

int strCountWords(string str)
{
	int ret = 0;
	int chars = 0;
	str = strTrim(str);
	auto space = " "[0];
	for (uint i = 0; i < str.length(); i++)
	{
		if (str[i] == space)
		{
			ret++;
			chars = 0;
		}
		else
			chars++;
	}
	if (chars > 0)
		ret++;
	return ret;
}

array<string> strCommandLineParse(string str, bool bUseLiterals = true)
{
	array<string> ret;

	string buffer = "";
	bool inStr = false;

	for (uint i = 0; i < str.length(); i++)
	{
		string c = str.substr(i, 1);

		// literals
		if (c == "\\")
		{
			if (bUseLiterals)
			{
				if (i + 1 < str.length())
					buffer += c;
			}
			else
				buffer += "\\";
		}

		// strings
		else if (c == "\"")
		{
			if (inStr)
			{
				// string ends
				inStr = false;
				ret.insertLast(buffer);
				buffer = "";
				if (i + 1 < str.length() && str.substr(i + 1, 1) == " ")
					i++;
			}
			else
			{
				// string starts
				inStr = true;
			}
		}

		// words
		else if (c == " ")
		{
			if (inStr)
				buffer += " ";
			else
			{
				ret.insertLast(buffer);
				buffer = "";
			}
		}

		// characters
		else
			buffer += c;
	}

	// last word
	if (buffer != "")
		ret.insertLast(buffer);

	return ret;
}

bool g_cvar_format_letters = false;

string formatThousands(int64 number, bool letters = false)
{
	if (number < 1000 && number > -1000)
		return "" + number;

	bool negative = (number < 0);
	number = abs(number);

	string ret = "";

	if (letters || g_cvar_format_letters)
	{
		if (number > 1000000)
			ret = formatFloat(number / 1000000.0, "", 0, 2) + "m";
		else if (number > 1000)
			ret = formatFloat(number / 1000.0, "", 0, 1) + "k";
		else
			ret = "" + number;
	}
	else
	{
		int64 curr = number;
		while (curr > 0)
		{
			if (ret != "")
				ret = "\u2005" + ret;

			string str;
			if (curr >= 1000)
				str = formatInt(curr % 1000, "0", 3);
			else
				str = formatInt(curr);
			ret = str + ret;

			curr /= 1000;
		}
	}

	if (negative)
		ret = "-" + ret;

	return ret;
}

string toRoman(int num)
{
	array<string> m = { "", "M", "MM", "MMM" };
	array<string> c = { "", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM" };
	array<string> x = { "", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC" };
	array<string> i = { "", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" };
	return m[num / 1000] + c[(num % 1000) / 100] + x[(num % 100) / 10] + i[num % 10];
}

string formatMeters(int units)
{
	int meters = int(units / Tweak::PixelsPerMeter);
	if (meters >= 10000)
		return round(meters / 1000.0f, 2) + " km";
	else
		return formatThousands(meters) + " m";
}

string formatMeters(int64 units)
{
	int64 meters = int64(units / Tweak::PixelsPerMeter);
	if (meters >= 10000)
		return round(meters / 1000.0f, 2) + " km";
	else
		return formatThousands(meters) + " m";
}

RaycastResult rayClosestFromUnit(UnitPtr unit, vec2 toPos, uint slots, RaycastType type)
{
	return rayClosestWithoutUnit(xy(unit.GetPosition()), toPos, slots, type, unit);
}

RaycastResult rayClosestWithoutUnit(vec2 fromPos, vec2 toPos, uint slots, RaycastType type, UnitPtr unit)
{
	array<RaycastResult>@ res = g_scene.Raycast(fromPos, toPos, slots, type);
	for (uint i = 0; i < res.length(); i++)
	{
		if (res[i].FetchUnit(g_scene) != unit)
			return res[i];
	}
	RaycastResult ret;
	return ret;
}

bool rayCanSee(UnitPtr a, UnitPtr b, RaycastType type = RaycastType::Aim)
{
	if (!a.IsValid() || !b.IsValid())
		return false;

	RaycastResult res = g_scene.RaycastClosest(xy(a.GetPosition()), xy(b.GetPosition()), ~0, type);
	UnitPtr res_unit = res.FetchUnit(g_scene);

	if (!res_unit.IsValid())
		return true;

	return (res_unit == b);
}

bool rayCanSee(vec2 p, UnitPtr b, RaycastType type = RaycastType::Aim)
{
	if (!b.IsValid())
		return false;

	RaycastResult res = g_scene.RaycastClosest(p, xy(b.GetPosition()), ~0, type);
	UnitPtr res_unit = res.FetchUnit(g_scene);

	if (!res_unit.IsValid())
		return true;

	return (res_unit == b);
}

bool rayCanSeeWithoutUnit(vec2 p, UnitPtr b, UnitPtr unitIgnore, uint slots = ~0, RaycastType type = RaycastType::Aim)
{
	RaycastResult res = rayClosestWithoutUnit(p, xy(b.GetPosition()), slots, type, unitIgnore);
	UnitPtr res_unit = res.FetchUnit(g_scene);

	if (!res_unit.IsValid())
		return true;

	return (res_unit == b);
}

bool IsNetsyncedExistance(NetSyncMode mode)
{
	return mode == NetSyncMode::Existance || mode == NetSyncMode::Position;
}

string GetNamePart(string resname)
{
	return resname.substr(resname.findLast(":") + 1);
}

int roll_round(float f)
{
	int v = abs(int(f));
	if (randf() < (f - v))
		v++;

	return (f < 0) ? -v : v;
}

vec2 intercept(vec2 srcPos, vec2 dstPos, vec2 dstVel, float vel)
{
	vec2 t = dstPos - srcPos;
	vec2 tv = dstVel;

	// Get quadratic equation components
	float a = tv.x*tv.x + tv.y*tv.y - vel*vel;
	float b = 2 * (tv.x * t.x + tv.y * t.y);
	float c = t.x*t.x + t.y*t.y;

	vec2 ts = quad(a, b, c);

	float res = min(ts.x, ts.y);
	if (res < 0) 
		res = max(ts.x, ts.y);
		
	if (res > 0) 
		return dstPos + dstVel * res;

	return dstPos;
}

vec2 quad(float a, float b, float c)
{
	if (abs(a) < 0.0001)
	{
		if (abs(b) < 0.0001)
			return vec2(0, 0);
		else
			return vec2(-c / b, -c / b);
	} 
	else 
	{
		auto disc = b * b - 4 * a * c;
		if (disc >= 0) 
		{
			disc = sqrt(disc);
			a = 2 * a;
			
			return vec2((-b - disc) / a, (-b + disc) / a);
		}
	}
	
	return vec2(0, 0);
}

string GetCurrentDifficultyName()
{
%if DIFF_EASY
	return Resources::GetString(".difficulty.easy");
%elif DIFF_NORMAL
	return Resources::GetString(".difficulty.normal");
%elif DIFF_HARD
	return Resources::GetString(".difficulty.hard");
%elif DIFF_SERIOUS
	return Resources::GetString(".difficulty.serious");
%else
	return "??";
%endif
}

bool AnyPressed(GameInput@ gi, MenuInput@ mi)
{
	if (gi.Attack1.Pressed) return true;
	if (gi.Attack2.Pressed) return true;
	if (gi.Attack3.Pressed) return true;
	if (gi.Attack4.Pressed) return true;
	if (gi.Use.Pressed) return true;
	if (gi.Potion.Pressed) return true;
	if (gi.PlayerMenu.Pressed) return true;
	if (gi.Ping.Pressed) return true;

	if (mi.Up.Pressed) return true;
	if (mi.Down.Pressed) return true;
	if (mi.Left.Pressed) return true;
	if (mi.Right.Pressed) return true;
	if (mi.Forward.Pressed) return true;
	if (mi.ChatAll.Pressed) return true;

	return false;
}

string UcFirst(string str, bool forced = false)
{
	if (str == "")
		return "";

	if (forced)
		return str.substr(0, 1).toUpper() + str.substr(1).toLower();
	return str.substr(0, 1).toUpper() + str.substr(1);
}

utf8string UcFirst(utf8string str, bool forced = false)
{
	if (str.size() == 0)
		return "";

	utf8string ret;

	ret += str.substr(0, 1).toUpper();

	if (forced)
		ret += str.substr(1).toLower();
	else
		ret += str.substr(1);

	return ret;
}

string GetTownLevelFilename()
{
	string townLevelOverride = GetVarString("g_town_level");
	if (townLevelOverride != "")
		return townLevelOverride;

	return "levels/town.lvl";
}
