array<string> g_actorBuffTags;

int GetActorBuffTag(const string &in tag)
{
	if (tag == "")
		return 0;
		
	for (uint i = 0; i < g_actorBuffTags.length(); i++)
		if (tag == g_actorBuffTags[i])
			return i + 1;

	g_actorBuffTags.insertLast(tag);
	return g_actorBuffTags.length();
}

uint64 ApplyActorBuffTag(uint64 curr, const string &in tag)
{
	auto r = GetActorBuffTag(tag);
	if (r <= 0)
		return curr;
	
	return curr | (1 << r);
}

uint64 GetBuffTags(SValue& params, const string &in prefix = "")
{
	uint64 ret = 0;

	array<SValue@>@ tagArr = GetParamArray(UnitPtr(), params, prefix + "tags", false);
	if (tagArr !is null)
	{
		for (uint i = 0; i < tagArr.length(); i++)
			ret = ApplyActorBuffTag(ret, tagArr[i].GetString());
	}
	else
		ret = ApplyActorBuffTag(ret, GetParamString(UnitPtr(), params, prefix + "tag", false));

	return ret;
}

enum ActorBuffTickMode
{
	Regular,
	Immediate,
	OnReapply,
	OnlyOnReapply
}

class ActorBuffDef
{
	string m_name;
	string m_description;
	ScriptSprite@ m_effectIcon;

	uint m_pathHash;
	uint64 m_tags;
	int m_duration;
	bool m_debuff;

	float m_mulSlippery;
	float m_mulSpeed;
	float m_mulSpeedDash;
	float m_mulDamage;
	float m_mulDamageTaken;
	float m_mulExperience;
	vec2 m_mulArmor;
	float m_minSpeed;
	float m_setSpeed;
	float m_receiveCritChance;
	bool m_freeMana;
	bool m_disarm;
	bool m_silence;
	bool m_mute;
	bool m_confuse;
	bool m_lockMovement;
	bool m_lockRotation;
	bool m_antiConfuse;
	bool m_drifting;
	bool m_infDodge;
	bool m_darkness;
	bool m_shatterable;
	string m_playerHeadSuffix;
	uint8 m_buffDmgType;
	float m_mulWindScale;

	SoundEvent@ m_sound;
	ActorColor@ m_color;
	CleaveInfo@ m_cleave;
	
	int m_tickFreq;
	array<IEffect@>@ m_tickEffects;
	ActorBuffTickMode m_tickMode;
	
	int m_moveFreq;
	array<IEffect@>@ m_moveEffects;
	
	float m_dieEffectChance;
	array<IEffect@>@ m_dieEffects;

	array<Modifiers::Modifier@> m_modifiers;
	
	
	UnitScene@ m_effect;
	UnitScene@ m_walkEffect;
	int m_walkEffectTime;

	UnitProducer@ m_icon;
	string m_iconScene;
	int m_iconSizeX;
	int m_iconLayer;

	ScriptSprite@ m_hud;
	
	ActorBuffDef(uint pathHash)
	{
		m_pathHash = pathHash;
	}
	
	ActorBuffDef(uint pathHash, SValue& params)
	{
		m_pathHash = pathHash;
		LoadParams(params);
	}
	
	void LoadParams(SValue& params)
	{
		m_name = GetParamString(UnitPtr(), params, "name", false);
		m_description = GetParamString(UnitPtr(), params, "description", false);
		auto arrEffectIcon = GetParamArray(UnitPtr(), params, "effect-icon", false);
		if (arrEffectIcon !is null)
			@m_effectIcon = ScriptSprite(arrEffectIcon);

		m_tags = GetBuffTags(params);
		m_duration = GetParamInt(UnitPtr(), params, "duration", false, 1000);
		m_debuff = GetParamBool(UnitPtr(), params, "debuff", false, false);
		
		m_mulSlippery = GetParamFloat(UnitPtr(), params, "slippery-mul", false, 1.0f);
		m_mulSpeed = GetParamFloat(UnitPtr(), params, "speed-mul", false, 1.0);
		m_mulSpeedDash = GetParamFloat(UnitPtr(), params, "speed-dash-mul", false, 1.0);
		m_mulDamage = GetParamFloat(UnitPtr(), params, "dmg-mul", false, 1.0);
		m_mulDamageTaken = GetParamFloat(UnitPtr(), params, "dmg-taken-mul", false, 1.0);
		m_mulExperience = GetParamFloat(UnitPtr(), params, "experience-mul", false, 1.0);
		m_mulArmor = vec2(
			GetParamFloat(UnitPtr(), params, "armor-mul", false, 1.0),
			GetParamFloat(UnitPtr(), params, "resistance-mul", false, 1.0));
		
		m_minSpeed = GetParamFloat(UnitPtr(), params, "min-speed", false, 0.0);
		m_setSpeed = GetParamFloat(UnitPtr(), params, "set-speed", false, -1.0f);
		m_receiveCritChance = GetParamFloat(UnitPtr(), params, "receive-crit-chance", false, 0.0f);

		m_freeMana = GetParamBool(UnitPtr(), params, "free-mana", false, false);
		m_disarm = GetParamBool(UnitPtr(), params, "disarm", false, false);
		m_silence = GetParamBool(UnitPtr(), params, "silence", false, false);
		m_mute = GetParamBool(UnitPtr(), params, "mute", false, false);
		m_confuse = GetParamBool(UnitPtr(), params, "confuse", false, false);
		m_lockMovement = GetParamBool(UnitPtr(), params, "lock-movement", false, false);
		m_lockRotation = GetParamBool(UnitPtr(), params, "lock-rotation", false, false);
		m_antiConfuse = GetParamBool(UnitPtr(), params, "anti-confuse", false, false);
		m_drifting = GetParamBool(UnitPtr(), params, "drifting", false, false);
		m_infDodge = GetParamBool(UnitPtr(), params, "inf-dodge", false, false);
		m_playerHeadSuffix = GetParamString(UnitPtr(), params, "player-head-suffix", false, "");
		m_buffDmgType = GetParamDamageType(UnitPtr(), params, "buff-dmg-type", false, 0);
		
		auto tick = GetParamDictionary(UnitPtr(), params, "tick", false);
		if (tick !is null)
		{
			m_tickFreq = GetParamInt(UnitPtr(), tick, "freq", false, 0);
			@m_tickEffects = LoadEffects(UnitPtr(), tick);

			m_tickMode = ActorBuffTickMode::Regular;
			
			bool immediate = GetParamBool(UnitPtr(), tick, "immediate", false, false);
			bool onReapply = GetParamBool(UnitPtr(), tick, "on-reapply", false, false);
			
			if (immediate)
			{
				if (onReapply)
					m_tickMode = ActorBuffTickMode::OnReapply;
				else
					m_tickMode = ActorBuffTickMode::Immediate;
			}
			else if (onReapply)
				m_tickMode = ActorBuffTickMode::OnlyOnReapply;
			
		}
		
		auto move = GetParamDictionary(UnitPtr(), params, "move", false);
		if (move !is null)
		{
			m_moveFreq = GetParamInt(UnitPtr(), move, "freq", false, 0);
			@m_moveEffects = LoadEffects(UnitPtr(), move);
		}
		
		@m_dieEffects = LoadEffects(UnitPtr(), params, "die-");
		if (m_dieEffects !is null && m_dieEffects.length() > 0)
			m_dieEffectChance = GetParamFloat(UnitPtr(), params, "die-effect-chance", false, 1.0f);
		

		m_modifiers = Modifiers::LoadModifiers(UnitPtr(), params, "", Modifiers::SyncVerb::Buff, m_pathHash);
		
		@m_effect = Resources::GetEffect(GetParamString(UnitPtr(), params, "fx", false, ""));
		@m_color = LoadColor(params);
		@m_cleave = LoadCleave(params);

		@m_walkEffect = Resources::GetEffect(GetParamString(UnitPtr(), params, "walk-fx", false, ""));
		m_walkEffectTime = GetParamInt(UnitPtr(), params, "walk-fx-time", false, 100);

		string iconUnit = GetParamString(UnitPtr(), params, "icon", false, "");
		if (iconUnit != "")
		{
			@m_icon = Resources::GetUnitProducer(iconUnit);
			m_iconScene = GetParamString(UnitPtr(), params, "icon-scene", false, "");
			m_iconSizeX = GetParamInt(UnitPtr(), params, "icon-size-x", false, 10);
			m_iconLayer = GetParamInt(UnitPtr(), params, "icon-layer", false, -1);
		}

		@m_sound = Resources::GetSoundEvent(GetParamString(UnitPtr(), params, "sound", false, ""));

		auto arr = GetParamArray(UnitPtr(), params, "hud", false);
		if (arr !is null)
			@m_hud = ScriptSprite(arr);

		m_darkness = GetParamBool(UnitPtr(), params, "darkness", false, false);

		m_shatterable = GetParamBool(UnitPtr(), params, "shatterable", false, false);

		m_mulWindScale = GetParamFloat(UnitPtr(), params, "wind-scale", false, 1.0f);
	}
}
