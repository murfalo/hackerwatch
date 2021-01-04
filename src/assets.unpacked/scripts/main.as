Scene@ g_scene;
AGameMode@ g_gameMode;
uint g_menuTime;


UnitProducer@ g_effectUnit;
BitmapFont@ g_floatTextFont;
BitmapFont@ g_floatTextFontBig;

float FloatingTextSpeed = 0.05;

const string g_strGamepadA = "A";
const string g_strGamepadB = "B";
const string g_strGamepadX = "X";
const string g_strGamepadY = "Y";
const string g_strGamepadBack = "BACK";
const string g_strGamepadGuide = "GUIDE";
const string g_strGamepadStart = "START";
const string g_strGamepadLeftStick = "L3";
const string g_strGamepadRightStick = "R3";
const string g_strGamepadLeftTrigger = "LT";
const string g_strGamepadRightTrigger = "RT";
const string g_strGamepadLeftShoulder = "LB";
const string g_strGamepadRightShoulder = "RB";
const string g_strGamepadDpadUp = "UP";
const string g_strGamepadDpadDown = "DOWN";
const string g_strGamepadDpadLeft = "LEFT";
const string g_strGamepadDpadRight = "RIGHT";

float g_mpEnemyHealthScale;
float g_mpExpScale;

bool g_owns_dlc_pop = Platform::HasDLC("pop");

bool HasDLC(string dlc)
{
	if (dlc == "")
		return true;

	if (dlc == "pop" && g_owns_dlc_pop)
		return true;

	return Platform::HasDLC(dlc);
}


class AttachedSound
{
	SoundInstance@ sound;
	UnitPtr unit;
}

class AttachedEffect
{
	EffectBehavior@ effect;
	UnitPtr unit;
}



array<IPreRenderable@> m_preRenderables;
array<AttachedSound> m_attachedSounds;
array<AttachedEffect> m_attachedEffects;
array<WorldScript::LevelStart@> m_levelStarts;

FlagBank g_flags;

bool g_useSpawnPos;
vec2 g_spawnPos;
string g_startId;




void dbgArgs(vec2 spawnPos)
{
	g_spawnPos = spawnPos;
	g_useSpawnPos = true;
}


array<PlayerRecord@> g_players;

int NumConnectedPlayers()
{
	int ret = 0;
	for (uint i = 0; i < g_players.length(); i++)
	{
		if (g_players[i].peer != 255)
			ret++;
	}
	return ret;
}


array<Gib> m_gibs;
int m_gibsSpawned;


void AddGib(Gib gib)
{
	m_gibsSpawned++;
	m_gibs.insertLast(gib);
}

void UpdateGibs(int ms)
{
%PROFILE_START Gibs
	m_gibsSpawned = 0;
	for (uint i = 0; i < m_gibs.length();)
	{
		if (m_gibs[i].Update(ms))
		{
			m_gibs[i].unit.SetPositionZ(0);
			m_gibs.removeAt(i);
		}
		else
			i++;
	}
%PROFILE_STOP
}



GoreSpawner@ m_safeGore;
array<GoreSpawner@> m_goreSpawners;

GoreSpawner@ LoadGore(string path)
{
	for (uint i = 0; i < m_goreSpawners.length(); i++)
		if (m_goreSpawners[i].m_path == path)
			return m_goreSpawners[i];
		
	SValue@ gore = Resources::GetSValue(path);
	if (gore is null)
		return null;
	
	GoreSpawner @ret = GoreSpawner(path, gore);
	m_goreSpawners.insertLast(@ret);
	return ret;
}









UnitPtr PlayEffect(string effect, UnitPtr unit)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
	
	return PlayEffect(fx, unit);
}

UnitPtr PlayEffect(string effect, UnitPtr unit, dictionary params)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
	
	return PlayEffect(fx, unit, params);
}

UnitPtr PlayEffect(UnitScene@ effect, UnitPtr unit)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, unit.GetPosition());
	auto eb = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	eb.Initialize(effect, true);
	
	AttachedEffect aFx;
	@(aFx.effect) = eb;
	aFx.unit = unit;
	
	m_attachedEffects.insertLast(aFx);
	return fxUnit;
}

UnitPtr PlayEffect(UnitScene@ effect, UnitPtr unit, dictionary params)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, unit.GetPosition());
	auto eb = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	eb.Initialize(effect, params, true);
	
	AttachedEffect aFx;
	@(aFx.effect) = eb;
	aFx.unit = unit;
	
	m_attachedEffects.insertLast(aFx);
	return fxUnit;
}

UnitPtr PlayEffect(string effect, vec2 pos)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
		
	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(fx);
	return fxUnit;
}

UnitPtr PlayEffect(UnitScene@ effect, vec2 pos)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(effect);
	return fxUnit;
}

UnitPtr PlayEffect(string effect, vec3 pos)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
		
	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, pos);
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(fx);
	return fxUnit;
}

UnitPtr PlayEffect(UnitScene@ effect, vec3 pos)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, pos);
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(effect);
	return fxUnit;
}

UnitPtr PlayEffect(string effect, vec2 pos, dictionary params)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
		
	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(fx, params);
	return fxUnit;
}

UnitPtr PlayEffect(UnitScene@ effect, vec2 pos, dictionary params)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(effect, params);
	return fxUnit;
}

UnitPtr PlayEffect(string effect, vec2 pos, EffectParams@ params)
{
	UnitScene@ fx = Resources::GetEffect(effect);
	if (fx is null)
		return UnitPtr();
		
	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(fx, params);
	return fxUnit;
}

UnitPtr PlayEffect(UnitScene@ effect, vec2 pos, EffectParams@ params)
{
	if (effect is null)
		return UnitPtr();

	UnitPtr fxUnit = g_effectUnit.Produce(g_scene, vec3(pos.x, pos.y, 0));
	auto ret = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
	ret.Initialize(effect, params);
	return fxUnit;
}



void PlaySound3D(SoundEvent@ snd, UnitPtr unit)
{
	if (snd is null)
		return;

	SoundInstance@ si = snd.PlayTracked(unit.GetPosition());
	si.SetPaused(false);
	
	int l = si.GetLength();
	if (l > -1 && l <= 350)
		return;
	
	AttachedSound aSnd;
	@(aSnd.sound) = si;
	aSnd.unit = unit;
	
	m_attachedSounds.insertLast(aSnd);
}

void PlaySound3D(SoundEvent@ snd, vec3 pos)
{
	if (snd is null)
		return;

	snd.Play(pos);
}


void PlaySound3D(SoundEvent@ snd, UnitPtr unit, dictionary params)
{
	if (snd is null)
		return;

	SoundInstance@ si = snd.PlayTracked(unit.GetPosition());
	
	auto keys = params.getKeys();
	for (uint i = 0; i < keys.length(); i++)
	{
		float val;
		params.get(keys[i], val);
		si.SetParameter(keys[i], val);
	}
	
	si.SetPaused(false);
	
	int l = si.GetLength();
	if (l > -1 && l <= 350)
		return;
	
	AttachedSound aSnd;
	@(aSnd.sound) = si;
	aSnd.unit = unit;
	
	m_attachedSounds.insertLast(aSnd);
}

void PlaySound3D(SoundEvent@ snd, vec3 pos, dictionary params)
{
	if (snd is null)
		return;
		
	SoundInstance@ si = snd.PlayTracked(pos);
	
	auto keys = params.getKeys();
	for (uint i = 0; i < keys.length(); i++)
	{
		float val;
		params.get(keys[i], val);
		si.SetParameter(keys[i], val);
	}
	
	si.SetPaused(false);
}


void PlaySound2D(SoundEvent@ snd)
{
	if (snd is null)
		return;

	snd.Play();
}





GameInput@ GetInput()
{
	return g_gameMode.m_currInput;
}

MenuInput@ GetMenuInput()
{
	return g_gameMode.m_currInputMenu;
}

// Kind of an ugly function.. can we get rid of this?
vec2 GetGameModeMousePosition()
{
	BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
	if (gm !is null)
		return gm.GetMousePos();

	return vec2();
}

HUD@ GetHUD()
{
	return g_gameMode.GetHUD();
}

Player@ GetLocalPlayer()
{
	for (uint i = 0; i < g_players.length(); i++)
	{
		if (g_players[i].peer == 255)
			continue;
	
		if (g_players[i].local)
			return cast<Player>(g_players[i].actor);
	}

	return null;
}

PlayerRecord@ GetLocalPlayerRecord()
{
	for (uint i = 0; i < g_players.length(); i++)
	{
		if (g_players[i].peer == 255)
			continue;
	
		if (g_players[i].local)
			return g_players[i];
	}

	return null;
}

PlayerRecord@ GetPlayerRecordByPeer(uint8 peer)
{
	for (uint i = 0; i < g_players.length(); i++)
	{
		if (g_players[i].peer == 255)
			continue;

		if (g_players[i].peer == peer)
			return g_players[i];
	}
	return null;
}

void SetGamepadRumble(float strength, int length)
{
	auto input = GetInput();
	if (input is null || !input.UsingGamepad)
		return;
	RumbleGamepad(strength, length);
}


EffectParams@ LoadEffectParams(UnitPtr unit, SValue& params)
{
	SValue@ dat = GetParamDictionary(unit, params, "effect-params", false);
	if (dat !is null && dat.GetType() == SValueType::Dictionary)
	{
		EffectParams@ effectParams = unit.CreateEffectParams();

		auto epKeys = dat.GetDictionary().getKeys();
		for (uint i = 0; i < epKeys.length(); i++)
		{
			auto d = dat.GetDictionaryEntry(epKeys[i]);
			if (d !is null && d.GetType() == SValueType::Float && effectParams !is null)
				effectParams.Set(epKeys[i], d.GetFloat());
		}
		
		return effectParams;
	}
	
	return null;
}