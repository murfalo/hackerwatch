class ActorColor
{
	vec4 m_dark;
	vec4 m_mid;
	vec4 m_bright;
}


ActorColor@ LoadColor(SValue& params, string prefix = "")
{
	SValue@ colorData = params.GetDictionaryEntry(prefix + "colors");
	if (colorData is null)
		return null;

	ActorColor color;
	color.m_dark = vec4(0, 0, 0, 1);
	color.m_bright = vec4(1, 1, 1, 1);
	
	if (colorData.GetType() == SValueType::Array)
	{
		auto cArr = colorData.GetArray();
		color.m_dark = cArr[0].GetVector4();
		color.m_mid = cArr[1].GetVector4();
		color.m_bright = cArr[2].GetVector4();
	}
	else if (colorData.GetType() == SValueType::Vector4)
		color.m_mid = colorData.GetVector4();
	
	return color;
}

class ActorBuff : IBuffWidgetInfo
{
	Actor@ m_owner;
	ActorBuffDef@ m_def;
	int m_duration;
	float m_intensity;
	EffectBehavior@ m_effect;
	ActorBuffIcon@ m_icon;
	Widget@ m_hudIcon;
	SoundInstance@ m_snd;
	bool m_husk;
	vec2 m_lastPos;
	float m_distMoved;
	int m_tickC;
	uint m_weaponInfo;
	int m_walkTimeC;
	
	ActorBuff(Actor@ owner, ActorBuffDef@ def, float intensity, bool husk, uint weapon = 0)
	{
		@m_owner = owner;
		@m_def = def;
		m_duration = def.m_duration;
		m_intensity = intensity;
		m_husk = husk;
		m_distMoved = 0;
		m_tickC = (def.m_tickMode == ActorBuffTickMode::Regular || def.m_tickMode == ActorBuffTickMode::OnlyOnReapply) ? def.m_tickFreq : 0;
		m_weaponInfo = weapon;
	}
	
	void Refresh(ActorBuff@ other)
	{
		m_duration = max(m_duration, other.m_duration);
		m_intensity = (m_intensity + other.m_intensity) / 2;
		@m_owner = other.m_owner;
		
		if (m_def.m_tickMode == ActorBuffTickMode::OnReapply || m_def.m_tickMode == ActorBuffTickMode::OnlyOnReapply)
			m_tickC = 0;
		
		if (m_effect !is null)
			m_effect.m_ttl = m_duration;

		if (m_icon !is null)
			m_icon.Refresh(m_duration);
	}
	
	void OnDeath(Actor@ actor)
	{
		if (randf() <= m_def.m_dieEffectChance)
		{
			PropagateWeaponInformation(m_def.m_dieEffects, m_weaponInfo);
			ApplyEffects(m_def.m_dieEffects, m_owner, actor.m_unit, xy(actor.m_unit.GetPosition()), vec2(), 1.0, m_husk);
		}

		auto owner = cast<PlayerBase>(m_owner);
		if (owner !is null && m_def.m_shatterable)
		{
			for (uint j = 0; j < owner.m_skills.length(); j++)
			{
				auto skillShatter = cast<Skills::Shatter>(owner.m_skills[j]);
				if (skillShatter !is null)
				{
					skillShatter.OnEnemyKilled(owner, actor);
					break;
				}
			}
		}
	}
	
	void Clear()
	{
		m_duration = 0;
	
		if (m_effect !is null)
			m_effect.m_ttl = 0;

		if (m_icon !is null)
			m_icon.Release();

		if (m_snd !is null)
			m_snd.Stop();

		if (m_hudIcon !is null)
			m_hudIcon.m_visible = false;
	}
	
	void Attach(Actor@ actor, ActorBuffList@ list)
	{
		m_lastPos = xy(actor.m_unit.GetPosition());
	
		if (m_def.m_effect !is null)
		{
			UnitPtr fxUnit = g_effectUnit.Produce(g_scene, actor.m_unit.GetPosition());
			auto eb = cast<EffectBehavior>(fxUnit.GetScriptBehavior());
			eb.Initialize(m_def.m_effect, dictionary());
			eb.m_ttl = m_duration;
			@m_effect = eb;
			
			AttachedEffect aFx;
			@(aFx.effect) = eb;
			aFx.unit = actor.m_unit;
			
			m_attachedEffects.insertLast(aFx);
		}

		m_walkTimeC = m_def.m_walkEffectTime;

		if (m_def.m_icon !is null)
		{
			if (m_def.m_iconScene == "")
			{
				auto sceneSet = m_def.m_icon.GetSceneSet("start");
				if (sceneSet.length() > 0)
					m_def.m_iconScene = sceneSet[0];
			}

			@m_icon = list.AddIcon(m_def.m_icon);
			if (m_icon.m_refCount == 1)
			{
				m_icon.m_attached.Initialize(m_def.m_icon, m_def.m_iconScene, m_def.m_iconLayer, actor.m_unit, vec2(), true, m_duration);
				@m_icon.m_attached.m_actor = actor;
				m_icon.m_attached.m_sizeX = m_def.m_iconSizeX;
			}
		}

		if (m_def.m_sound !is null)
		{
			@m_snd = m_def.m_sound.PlayTracked(actor.m_unit.GetPosition());
			m_snd.SetLooped(true);
			m_snd.SetPaused(false);
		}
	}
		
	bool Update(int dt, Actor@ actor)
	{
		if (actor !is null)
		{
			auto pos = actor.m_unit.GetPosition();
			auto moveDir = xy(pos) - m_lastPos;
			m_lastPos = xy(pos);
			
			if (m_effect !is null)
			{
				m_effect.SetParam("angle", atan(moveDir.y, moveDir.x));
				
				auto plr = cast<PlayerBase>(actor);
				if (plr !is null)
					m_effect.SetParam("aim_angle", plr.m_dirAngle);
			}

			if (m_def.m_walkEffect !is null)
			{
				if (m_walkTimeC > 0)
					m_walkTimeC -= dt;

				if (m_walkTimeC <= 0 && length(actor.m_unit.GetPhysicsBody().GetLinearVelocity()) > 0.5f)
				{
					m_walkTimeC = m_def.m_walkEffectTime;
					PlayEffect(m_def.m_walkEffect, actor.m_unit.GetPosition());
				}
			}
		
			if (m_def.m_moveFreq > 0)
			{
				auto movedDt = length(moveDir);
				if (m_intensity > 0)
				{
					if ((m_distMoved % m_def.m_moveFreq) < movedDt)
					{
						PropagateWeaponInformation(m_def.m_moveEffects, m_weaponInfo);
						ApplyEffects(m_def.m_moveEffects, m_owner, actor.m_unit, xy(actor.m_unit.GetPosition()), vec2(), m_intensity, m_husk);
					}
				}
				
				m_distMoved += movedDt;
			}
			
			if (m_intensity > 0 && m_def.m_tickFreq > 0)
			{
				m_tickC -= dt;
				if (m_tickC <= 0)
				{
					PropagateWeaponInformation(m_def.m_tickEffects, m_weaponInfo);
					ApplyEffects(m_def.m_tickEffects, m_owner, actor.m_unit, xy(actor.m_unit.GetPosition()), vec2(), m_intensity, m_husk);
					m_tickC += m_def.m_tickFreq;
				}
			}
			
			if (m_snd !is null)
				m_snd.SetPosition(pos);
		}
		else
			return true;
			
		
		m_duration -= dt;
		if (m_duration > 0)
		{
			UpdateHudIcon();
			return true;
		}

		if (m_icon !is null && !m_icon.m_attached.m_unit.IsDestroyed())
			m_icon.Release();

		if (m_snd !is null)
			m_snd.Stop();

		return false;
	}

	void UpdateHudIcon()
	{
		if (m_hudIcon is null)
			return;

		auto wNum = cast<TextWidget>(m_hudIcon.GetWidgetById("num"));
		if (wNum !is null)
			wNum.SetText("" + max(0.0, ceil(m_duration / 1000)));
	}

	ScriptSprite@ GetBuffIcon() { return m_def.m_hud; }
	int GetBuffIconDuration() { return m_duration; }
	int GetBuffIconMaxDuration() { return m_def.m_duration; }
	int GetBuffIconCount() { return -1; }
}

array<ActorBuffDef@> g_actorBuffDefs;

ActorBuffDef@ LoadActorBuff(string path)
{
	if (path == "")
		return null;
		
	return LoadActorBuff(HashString(path));
}

ActorBuffDef@ LoadActorBuff(uint pathHash)
{
	for (uint i = 0; i < g_actorBuffDefs.length(); i++)
		if (g_actorBuffDefs[i].m_pathHash == pathHash)
			return g_actorBuffDefs[i];
	
	SValue@ buff = Resources::GetSValue(pathHash);
	if (buff is null)
		return null;
	
	auto ret = ActorBuffDef(pathHash);
	g_actorBuffDefs.insertLast(@ret);
	ret.LoadParams(buff);
	return ret;
}