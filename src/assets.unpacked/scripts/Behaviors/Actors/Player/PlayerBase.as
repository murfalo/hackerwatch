class PlayerBase : Actor, IPlayerActorDamager, IPreRenderable
{
	AnimString@ m_idleAnim;
	AnimString@ m_walkAnim;
	AnimString@ m_dashAnim;

	vec2 m_dashDir;
	int m_dashTime;
	
	UnitProducer@ m_body;
	UnitScene@ m_aimLaser;
	CustomUnitScene@ m_unitScene;
	UnitScene@ m_markerFx;
	GoreSpawner@ m_gore;

	UnitScene@ m_fxLifesteal;
	
	Voices::VoiceDef@ m_voice;
	
	string m_bodySceneName;
	int m_bodySceneTimeOffset;
	
	PlayerRecord@ m_record;
	array<Materials::IDyeState@> m_dyeStates;
	
	EffectParams@ m_effectParams;
	vec4 m_dmgColor;

	ActorFootsteps@ m_footsteps;
	ActorFootsteps@ m_footstepsDash;
	
	ActorBuffList m_buffs;

	bool m_playerBobbing;
	bool m_charging;

	bool m_comboActive;
	ActorBuffDef@ m_comboBuff;
	PlayerComboStyle@ m_comboStyle;
	EffectBehavior@ m_fxCombo;
	int m_comboTime;
	int m_comboCount;
	int m_comboEffectsTime;
	int m_markhamComboCount;
	int m_mtBlocksCooldown;

	array<Skills::Skill@> m_skills;
	float m_currLuck;

	vec2 m_currentArmor;
	vec2 m_currentAttackSpeed;

	int m_djinnSpawnTime;
	vec3 m_djinnSpawnPos;
	UnitPtr m_djinnSpawnEffect;
	UnitPtr m_djinn;

	uint64 m_spawnTime;
	UnitPtr m_fxSpawnInvuln;

	MiniPet@ m_pet;

	PlayerTrails::TrailDef@ m_trail;

	UnitPtr m_trailFx;
	int m_trailWalkTimeC;

	PlayerBase() { super(UnitPtr()); }
	PlayerBase(UnitPtr unit, SValue& params)
	{
		SetTeam("player", false);
		super(unit);
		
		m_unit.SetCollisionTeam(uint16(GetActorListId(Team)));
		
		
		@m_idleAnim = AnimString(GetParamString(unit, params, "anim-idle"));
		@m_walkAnim = AnimString(GetParamString(unit, params, "anim-walk"));
		@m_dashAnim = AnimString(GetParamString(unit, params, "anim-dash"));

		@m_unitScene = CustomUnitScene();
		
		@m_markerFx = Resources::GetEffect("actors/players/marker.effect");

		@m_fxLifesteal = Resources::GetEffect("effects/players/lifesteal.effect");
		
		
		
		@m_effectParams = m_unit.CreateEffectParams();
		m_effectParams.Set("height", Tweak::PlayerCameraHeight);
		m_effectParams.Set("frenzy", 1.0f);
		
		m_dmgColor = vec4(0, 0, 0, 0);

%if !GFX_VFX_LOW
		auto svFootsteps = GetParamDictionary(unit, params, "footsteps", false);
		if (svFootsteps !is null)
			@m_footsteps = ActorFootsteps(unit, svFootsteps);
%endif

		auto svFootstepsDash = GetParamDictionary(unit, params, "footsteps-dash", false);
		if (svFootstepsDash !is null)
			@m_footstepsDash = ActorFootsteps(unit, svFootstepsDash);
			
		m_buffs.Initialize(this);

		m_playerBobbing = GetParamBool(unit, params, "bobbing", false, true);
		m_charging = false;

		@m_comboBuff = LoadActorBuff("players/buffs.sval:combo");

		if (g_gameMode !is null)
			m_spawnTime = g_gameMode.m_gameTime;

		if (m_spawnTime > 2000)
			m_fxSpawnInvuln = PlayEffect("effects/players/spawn_shield.effect", m_unit);
	}

	vec2 GetComboBars()
	{
		auto props = ivec3(10, 1000, 2000) + m_record.GetModifiers().ComboProps(this);
	
		float amnt = m_comboCount / float(props.x);
		if (amnt >= 1.0f)
			return vec2(amnt, m_comboTime / float(props.z));

		return vec2(amnt, m_comboTime / float(props.y));
	}

	void LoadStats(SValue@ charFile)
	{
		auto statsData = charFile;
		m_record.classStats.base_health = GetParamFloat(m_unit, statsData, "base-health", false, 100);
		m_record.classStats.level_health = GetParamFloat(m_unit, statsData, "level-health", false, 0);
		m_record.classStats.base_health_regen = GetParamFloat(m_unit, statsData, "base-health-regen", false, 0);
		m_record.classStats.level_health_regen = GetParamFloat(m_unit, statsData, "level-health-regen", false, 0.05);
		
		m_record.classStats.base_mana = GetParamFloat(m_unit, statsData, "base-mana", false, 100);
		m_record.classStats.level_mana = GetParamFloat(m_unit, statsData, "level-mana", false, 0);
		m_record.classStats.base_mana_regen = GetParamFloat(m_unit, statsData, "base-mana-regen", false, 0.3);
		m_record.classStats.level_mana_regen = GetParamFloat(m_unit, statsData, "level-mana-regen", false, 0.15);
		
		m_record.classStats.base_armor = GetParamFloat(m_unit, statsData, "base-armor", false, 0);
		m_record.classStats.level_armor = GetParamFloat(m_unit, statsData, "level-armor", false, 0);
		m_record.classStats.base_resistance = GetParamFloat(m_unit, statsData, "base-resistance", false, 0);
		m_record.classStats.level_resistance = GetParamFloat(m_unit, statsData, "level-resistance", false, 0);
	}

	void LoadPet()
	{
		if (m_pet !is null)
		{
			m_pet.m_unit.Destroy();
			@m_pet = null;
		}

		if (m_record.currentPet == 0)
			return;

		auto petDef = Pets::GetDef(m_record.currentPet);
		if (petDef is null)
		{
			PrintError("Tried loading pet that doesn't exist!");
			return;
		}

		if (uint(m_record.currentPetSkin) >= petDef.m_skins.length())
		{
			PrintError("Pet skin index was invalid (" + m_record.currentPetSkin + "), reverting to default skin!");
			m_record.currentPetSkin = 0;
		}

		auto petSkin = petDef.m_skins[m_record.currentPetSkin];

		if (petSkin.m_prod is null)
		{
			PrintError("Pet skin unit producer \"" + petSkin.m_id + "\" doesn't exist, reverting to default skin!");
			m_record.currentPetSkin = 0;
			@petSkin = petDef.m_skins[0];
		}

		UnitPtr pet = petSkin.m_prod.Produce(g_scene, m_unit.GetPosition());
		@m_pet = cast<MiniPet>(pet.GetScriptBehavior());
		m_pet.Initialize(this, m_record.currentPetFlags);
	}

	void LoadTrail()
	{
		if (m_trailFx.IsValid())
		{
			m_trailFx.Destroy();
			m_trailFx = UnitPtr();
		}

		if (m_record.currentTrail == 0)
		{
			@m_trail = null;
			return;
		}

		@m_trail = PlayerTrails::GetTrail(m_record.currentTrail);
		if (m_trail is null)
		{
			PrintError("Unable to load trail with ID " + m_record.currentTrail + "!");
			return;
		}

		m_trailFx = PlayEffect(m_trail.m_fx, m_unit, dictionary());
		auto eb = cast<EffectBehavior>(m_trailFx.GetScriptBehavior());
		if (eb !is null)
			eb.m_looping = true;

		if (m_trail.m_walkFx !is null)
			m_trailWalkTimeC = m_trail.m_walkTime;
	}

	void CacheMarkhamComboCount()
	{
		m_markhamComboCount = int(m_record.items.length());
		for (uint i = 0; i < m_record.items.length(); i++)
		{
			if (m_record.items[i].findFirst("sphere") != -1)
				m_markhamComboCount++;
		}
	}

	void AddItem(ActorItem@ item)
	{
		int numActiveBonusesBefore = 0;

		if (item.set !is null)
		{
			OwnedItemSet@ ownedItemSet = m_record.GetOwnedItemSet(item.set);
			if (ownedItemSet !is null)
				numActiveBonusesBefore = ownedItemSet.GetNumBonusesActive();
		}

		m_record.items.insertLast(item.id);
		RefreshModifiers();

		if (item.set !is null)
		{
			OwnedItemSet@ ownedItemSet = m_record.GetOwnedItemSet(item.set);
			int numActiveBonusesAfter = ownedItemSet.GetNumBonusesActive();
			if (numActiveBonusesAfter > numActiveBonusesBefore && numActiveBonusesAfter == int(item.set.bonuses.length()))
			{
				print("New completed set: \"" + Resources::GetString(item.set.name) + "\"");
				Stats::Add("sets-completed", 1, m_record);
			}
		}
	}

	void TakeItem(ActorItem@ item)
	{
		int index = m_record.items.find(item.id);
		if (index == -1)
			return;

		m_record.items.removeAt(index);
		RefreshModifiers();
	}

	void AddDrink(TavernDrink@ drink)
	{
		m_record.tavernDrinks.insertLast(drink.id);
		RefreshModifiers();

		Stats::Add("drinks-consumed", 1, m_record);
	}

	void AttuneItem(ActorItem@ item)
	{
		m_record.itemForgeAttuned.insertLast(item.idHash);
		RefreshModifiers();

		Stats::Add("items-attuned", 1, m_record);
	}

	void RefreshSkills()
	{
		auto charData = Resources::GetSValue("players/" + m_record.charClass + "/char.sval");
		LoadSkills(charData);

		m_record.RefreshSkillModifiers();
	}

	void RefreshModifiers()
	{
		CacheMarkhamComboCount();

		for (uint j = 0; j < m_record.tavernDrinks.length(); j++)
		{
			auto drink = GetTavernDrink(HashString(m_record.tavernDrinks[j]));
			if (drink.buff is null)
				continue;

			auto buff = ActorBuff(this, drink.buff, 1.0f, IsHusk());
			buff.m_duration = 1000000000;
			m_buffs.Add(buff);
		}

		for (uint j = 0; j < m_record.temporaryBuffs.length(); j += 2)
		{
			auto buffDef = LoadActorBuff(m_record.temporaryBuffs[j]);
			if (buffDef is null)
				continue;

			auto buff = ActorBuff(this, buffDef, 1.0f, IsHusk());
			buff.m_duration = m_record.temporaryBuffs[j + 1];
			m_buffs.Add(buff);
		}

		m_record.RefreshModifiers();

		RefreshModifiersBuffs();
	}

	void RefreshModifiersBuffs()
	{
		m_record.RefreshModifiersBuffs();

		for (uint i = 0; i < m_buffs.m_buffs.length(); i++)
		{
			auto buff = m_buffs.m_buffs[i];
			auto buffDef = buff.m_def;

			for (uint j = 0; j < buffDef.m_modifiers.length(); j++)
				m_record.modifiersBuffs.Add(buffDef.m_modifiers[j]);
		}

		m_record.EnableItemModifiers(!m_buffs.Mute());
	}

	void LoadSkills(SValue@ charFile)
	{
		for (uint i = 0; i < m_skills.length(); i++)
			m_skills[i].OnDestroy();
		m_skills.removeRange(0, m_skills.length());

		array<SValue@>@ skillsArr = GetParamArray(m_unit, charFile, "skills", true);

%if HARDCORE
		// Primary skill
		m_skills.insertLast(LoadHardcorePrimarySkill(skillsArr[0].GetString()));

		// Load other skills
		for (uint i = 0; i < m_record.hardcoreSkills.length(); i++)
		{
			int skillId = i + 1;

			auto hardcoreSkill = m_record.hardcoreSkills[i];
			if (hardcoreSkill is null)
			{
				m_skills.insertLast(LoadSingleSkill("", null, null, skillId));
				continue;
			}

			auto skill = LoadSingleSkill(
				hardcoreSkill.m_name,
				hardcoreSkill.m_icon,
				hardcoreSkill.m_data,
				skillId
			);
			skill.m_description = hardcoreSkill.m_description;
			m_skills.insertLast(skill);
		}
%else
		for (uint i = 0; i < skillsArr.length(); i++)
			m_skills.insertLast(LoadSkill(skillsArr[i].GetString(), i));
%endif
	}

%if HARDCORE
	Skills::Skill@ LoadHardcorePrimarySkill(string path)
	{
		auto skillData = Resources::GetSValue(path);

		string skillName = GetParamString(m_unit, skillData, "name", false);
		auto icon = ScriptSprite(GetParamArray(m_unit, skillData, "icon", false));

		auto svSkill = skillData.GetDictionaryEntry("mercenary-primary");
		string skillDescription = GetParamString(m_unit, skillData, "mercenary-primary-description", false);

		auto ret = LoadSingleSkill(skillName, icon, svSkill, 0);
		ret.m_description = Resources::GetString(skillDescription);
		return ret;
	}
%endif

	Skills::Skill@ LoadSkill(string path, int skillId)
	{
		auto skillData = Resources::GetSValue(path);

		string skillName = GetParamString(m_unit, skillData, "name", false);
		auto icon = ScriptSprite(GetParamArray(m_unit, skillData, "icon", false));
		auto skillsArr = GetParamArray(m_unit, skillData, "skills", true);

		int skillLevel = m_record.levelSkills[skillId];
		int skillIndex = min(skillsArr.length() - 1, skillLevel);

		return LoadSingleSkill(skillName, icon, skillsArr[skillIndex], skillId);
	}

	Skills::Skill@ LoadSingleSkill(string skillName, ScriptSprite@ icon, SValue@ skillData, int skillId)
	{
		Skills::Skill@ skill;

		if (skillData is null || skillData.GetType() == SValueType::Null || skillData.GetType() == SValueType::Integer)
			@skill = Skills::NullSkill(m_unit);
		else
		{
			string c = GetParamString(m_unit, skillData, "class");
			@skill = cast<Skills::Skill>(InstantiateClass(c, m_unit, skillData));
			if (skill is null)
			{
				PrintError("Unable to instantiate class \"" + c + "\" for player skill!");
				return null;
			}
		}

		skill.Initialize(this, icon, skillId);
		skill.m_name = skillName;

		return skill;
	}

	int IconHeight() override { return -24; }
	bool IsTargetable() override { return true; }
	
	vec4 GetOverlayColor()
	{
		return m_dmgColor;
	}
	
	
	float m_dirAngle;
	void SetAngle(float angle)
	{
		m_effectParams.Set("angle", angle);
		m_dirAngle = angle;
		
		if (m_footsteps !is null)
			m_footsteps.m_facingDirection = angle;
		if (m_footstepsDash !is null)
			m_footstepsDash.m_facingDirection = angle;
	}
	
	void Initialize(PlayerRecord@ record)
	{
		@m_record = record;
		
		auto charData = Resources::GetSValue("players/" + m_record.charClass + "/char.sval");

		if (charData is null && m_record.charClass != "paladin")
		{
			PrintError("Couldn't initialize player with class \"" + m_record.charClass + "\" due to missing char.sval! Falling back to Paladin!");
			m_record.charClass = "paladin";
			Initialize(m_record);
			return;
		}

		LoadSkills(charData);
		LoadStats(charData);

		auto color = ParseColorRGBA("#" + GetPlayerColor(m_record.peer) + "ff");
		m_effectParams.Set("color_r", color.r);
		m_effectParams.Set("color_g", color.g);
		m_effectParams.Set("color_b", color.b);

		InitSkin();
		SetVoice();

		RefreshModifiers();
		m_record.RefreshSkillModifiers();

		LoadPet();
		LoadTrail();

		m_preRenderables.insertLast(this);
	}
	
	void Refresh()
	{
		Initialize(m_record);
	}
	
	void SetShades(int c, const array<vec4> &in shades)
	{
		m_unit.SetMultiColor(c, shades[0], shades[1], shades[2]);
	}

	void UpdateProperties()
	{
		m_dyeStates = Materials::MakeDyeStates(m_record);
		for (uint i = 0; i < m_dyeStates.length(); i++)
			SetShades(i, m_dyeStates[i].GetShades(0));

		SetVoice();

		LoadTrail();
	}
	
	void InitSkin()
	{
		@m_body = Resources::GetUnitProducer("players/" + m_record.charClass + ".unit");
		@m_aimLaser = Resources::GetEffect("actors/players/aim_laser.effect");

		UpdateProperties();
	}

	void SetVoice()
	{
		@m_voice = Voices::GetVoice(m_record.voice);
		if (m_voice is null)
		{
			PrintError("Can't find voice \"" + m_record.voice + "\", using default as fallback!");
			@m_voice = Voices::g_voiceDefault;
			m_record.voice = "default";
		}
	}
	
	bool ApplyBuff(ActorBuff@ buff) override
	{ 
		if (m_unit.IsDestroyed())
			return false;
	
		if (IsHusk() && !buff.m_husk)
			return false;

		auto modifiers = m_record.GetModifiers();

		if ((buff.m_def.m_tags & modifiers.ImmuneBuffs(this)) != 0)
			return false;
			
		if (buff.m_def.m_debuff)
		{
			buff.m_duration = int(buff.m_duration * (buff.m_def.m_debuff ? modifiers.DebuffScale(this) : modifiers.BuffScale(this)));
			if (buff.m_duration <= 0)
				return false;
		}

		m_buffs.Add(buff);
		return true;
	}

	bool HasBuff(uint buff) override
	{
		for (uint i = 0; i < m_buffs.m_buffs.length(); i++)
		{
			auto b = m_buffs.m_buffs[i];
			if (b.m_def.m_pathHash == buff)
				return true;
		}
		return false;
	}
	
	int SetUnitScene(AnimString@ anim, bool resetScene)  override
	{
		auto sceneName = anim.GetSceneName(m_dirAngle);
		SetBodyAnim(sceneName, resetScene);
		auto scene = m_body.GetUnitScene(sceneName);
		if (scene is null)
		{
			PrintError("Couldn't find scene '" + sceneName + "'");
			return 0;
		}
		return scene.Length();
	}
	
	void SetCharging(bool charging)
	{
		m_charging = charging;
		RefreshScene();
	}

	int RefreshScene()
	{
		if (IsDead())
			return 0; //TODO: Corpse scene?

		int time = 0;

		m_unitScene.Clear();
		m_unitScene.AddScene(m_unit.GetUnitScene((m_charging ? "shared-charge" : "shared")), m_bodySceneTimeOffset, vec2(), 0, 0);
		m_unitScene.AddScene(m_body.GetUnitScene(m_bodySceneName), m_bodySceneTimeOffset, vec2(), 0, 0);

		for (uint i = 0; i < m_skills.length(); i++)
			m_skills[i].RefreshScene(m_unitScene);

		if (m_record.local)
		{
			if (GetVarBool("g_local_player_marker"))
				m_unitScene.AddScene(m_markerFx, 0, vec2(), 0, 0);

			int laserSight = GetVarInt("g_laser_sight");
			if ((laserSight == -1 && GetInput().UsingGamepad) || laserSight == 1)
				m_unitScene.AddScene(m_aimLaser, 0, vec2(), 0, 0);
		}
		else
		{
			if (GetVarBool("g_player_markers"))
				m_unitScene.AddScene(m_markerFx, 0, vec2(), 0, 0);
		}

		BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
		if (gm !is null)
			gm.RefreshPlayerScene(this, m_unitScene);

		Hooks::Call("PlayerRefreshScene", @this);

		m_unit.SetUnitScene(m_unitScene, false);
		return time;
	}

	void SetBodyAnim(string scene, bool resetTime)
	{
		m_bodySceneName = scene;

		if (resetTime)
			m_bodySceneTimeOffset = -m_unit.GetUnitSceneTime();

		RefreshScene();
	}

	void Destroyed()
	{
		for (uint i = 0; i < m_skills.length(); i++)
			m_skills[i].OnDestroy();
	
		m_buffs.Clear();
		@m_record.actor = null;

		if (m_pet !is null)
		{
			m_pet.m_unit.Destroy();
			@m_pet = null;
		}
	}
	
	float GetHealth() override
	{
		return m_record.hp;
	}

	void DamagedActor(Actor@ actor, DamageInfo di)
	{
		auto eb = cast<CompositeActorBehavior>(actor);
		if (!(eb !is null && eb.m_enemyType == "construct" && di.LifestealMul > 0))
		{
			auto modifiers = m_record.GetModifiers();

			float ls = di.LifestealMul * modifiers.Lifesteal(this, actor, (di.Weapon != 1), di.Crit);
			ls *= modifiers.AllHealthGainScale(this) * eb.m_debuffScale;

			if (ls > 0)
			{
				ivec2 stats = modifiers.StatsAdd(this);
				float maxHealth = (m_record.MaxHealth() + stats.x) * modifiers.MaxHealthMul(this);
				int stealHealth = max(0, roll_round(di.DamageDealt * ls));
				if (m_record.hp * maxHealth + stealHealth > maxHealth)
					stealHealth = int(maxHealth - m_record.hp * maxHealth);

				if (stealHealth > 0)
				{
					Heal(stealHealth);
					//m_queuedHealing += stealHealth;
					Stats::Add("lifesteal-amount", stealHealth, m_record);
				}
				else if (stealHealth < 0)
					PrintError("Lifesteal value " + stealHealth + " is invalid!");

				PlayEffect(m_fxLifesteal, xy(m_unit.GetPosition()) + vec2(0, 1));
			}
		}

		if (di.Damage > 0)
		{
			Stats::Add("damage-dealt", di.Damage, m_record);
			Stats::Max("damage-dealt-max", di.Damage, m_record);

			Stats::Add("damage-dealt-physical", di.PhysicalDamage, m_record);
			Stats::Add("damage-dealt-magical", di.MagicalDamage, m_record);
		}
	}

	DamageInfo DamageActor(Actor@ actor, DamageInfo di)
	{
		auto modifiers = m_record.GetModifiers();

		ivec2 dmgPowerV = modifiers.DamagePower(this, actor);
		float dmgMul = m_buffs.DamageMul();

		int crit;
		int dmgPower;
		vec2 armorIg;
		ivec2 dmgAddV;

		if (di.Weapon == 1)
		{
			dmgPower = dmgPowerV.x;
			dmgMul *= modifiers.DamageMul(this, actor).x;
			crit = modifiers.Crit(this, actor, false);
			armorIg = modifiers.ArmorIgnore(this, actor, false);
			dmgAddV = modifiers.AttackDamageAdd(this, actor, di);
			modifiers.TriggerEffects(this, actor, Modifiers::EffectTrigger::Hit);
		}
		else
		{
			dmgPower = dmgPowerV.y;
			dmgMul *= modifiers.DamageMul(this, actor).y;
			crit = modifiers.Crit(this, actor, true);
			armorIg = modifiers.ArmorIgnore(this, actor, true);
			dmgAddV = modifiers.SpellDamageAdd(this, actor, di);
			modifiers.TriggerEffects(this, actor, Modifiers::EffectTrigger::SpellHit);
		}

		auto enemy = cast<CompositeActorBehavior>(actor);
		if (enemy !is null)
		{
			float receiveCritChance = enemy.m_buffs.ReceiveCritChance();
			if (receiveCritChance > 0.0f && randf() < receiveCritChance)
				crit++;

			auto entry = enemy.GetBestiaryAttunement();
			if (entry !is null)
				dmgMul *= 1 + 0.2f * entry.m_attuned;
		}

		if (crit > 0)
		{
			Stats::Add("crit-count", 1, m_record);
			float critMul = modifiers.CritMul(this, actor, di.Weapon != 1);
			critMul += modifiers.CritMulAdd(this, actor, di.Weapon != 1);
			dmgMul *= (2.0f + (critMul - 1.0f)) * crit;
		}

		di.PhysicalDamage = damage_round(((di.PhysicalDamage + dmgAddV.x) * (50.0 + dmgPower) / 50.0) * dmgMul);
		di.MagicalDamage = damage_round(((di.MagicalDamage + dmgAddV.y) * (50.0 + dmgPower) / 50.0) * dmgMul);
		di.Crit = crit;
		di.ArmorMul *= armorIg;

		if (crit > 0)
		{
			auto trigger = Modifiers::EffectTrigger::CriticalHit;
			if (di.Weapon != 1)
				trigger = Modifiers::EffectTrigger::SpellCriticalHit;

			modifiers.TriggerEffects(this, actor, trigger);
		}

		return di;
	}

	void KilledActor(Actor@ killed, DamageInfo di) override
	{
		Actor::KilledActor(killed, di);

		Hooks::Call("PlayerKilledActor", @this, @killed, di);
	}
	
	void OnDeath(DamageInfo di, vec2 dir)
	{
		if (m_record.IsDead())
			return;

		auto gm = cast<BaseGameMode>(g_gameMode);

		auto otherPlayer = cast<PlayerHusk>(di.Attacker);
		if (otherPlayer !is null)
		{
			// If soul link kill
			SValueBuilder builder;
			builder.PushString(Resources::GetString(".menu.lobby.chat.soullinkdeath", {
				{ "name", "\\c" + GetPlayerColor(m_record.peer) + gm.GetPlayerDisplayName(m_record, false) + "\\d" },
				{ "killer", "\\c" + GetPlayerColor(otherPlayer.m_record.peer) + gm.GetPlayerDisplayName(otherPlayer.m_record, false) + "\\d" }
			}));
			SendSystemMessage("AddChat", builder.Build());
		}
		else if (di.Attacker !is null)
		{
			// If monster kill
			auto unit = di.Attacker.m_unit;
			auto@ unitProd = unit.GetUnitProducer();
			auto params = unitProd.GetBehaviorParams();

			string unitName = GetParamString(unit, params, "beastiary-name", false);

			SValueBuilder builder;
			builder.PushString(Resources::GetString(".menu.lobby.chat.death", {
				{ "name", "\\c" + GetPlayerColor(m_record.peer) + gm.GetPlayerDisplayName(m_record, false) + "\\d" },
				{ "killer", Resources::GetString(unitName) }
			}));
			SendSystemMessage("AddChat", builder.Build());
		}
		else
		{
			// If suicide
			SValueBuilder builder;
			builder.PushString(Resources::GetString(".menu.lobby.chat.suicide", {
				{ "name", "\\c" + GetPlayerColor(m_record.peer) + gm.GetPlayerDisplayName(m_record, false) + "\\d" }
			}));
			SendSystemMessage("AddChat", builder.Build());
		}

		m_buffs.Clear();

		m_record.deadTime = max(1, g_scene.GetTime());

%if HARDCORE
		m_record.mercenaryLocked = true;
		print("Locked Mercenary - Death");
%endif

		PlaySound3D(m_voice.m_soundDeath, m_unit.GetPosition());

		if (otherPlayer !is null)
			PlayEffect("effects/players/soullink_death.effect", m_unit);

		if (m_gore !is null)
			m_gore.OnDeath(1.0f, xy(m_unit.GetPosition()), atan(dir.y, dir.x));

		auto corpse = Resources::GetUnitProducer("players/player_corpse.unit").Produce(g_scene, xyz(xy(m_unit.GetPosition()), 0));
		@m_record.corpse = cast<PlayerCorpse>(corpse.GetScriptBehavior());
		m_record.corpse.Initialize(m_record);
		
		m_unit.Destroy();
		m_unit = UnitPtr();

		if (m_fxSpawnInvuln.IsValid())
		{
			m_fxSpawnInvuln.Destroy();
			m_fxSpawnInvuln = UnitPtr();
		}

		if (m_comboActive)
			OnComboEnd();
	}
	
	SValue@ Save()
	{
		return null;
	}

	void OnComboBegin()
	{
		m_comboEffectsTime = 0;

		if (m_comboStyle is null || m_comboStyle.m_idHash != m_record.currentComboStyle)
			@m_comboStyle = PlayerComboStyle::Get(m_record.currentComboStyle);

		if (m_comboStyle !is null)
			m_comboStyle.OnBegin(this);
		else
			PrintError("Unable to find style with ID " + m_record.currentComboStyle + "!");
	}

	void OnComboEnd()
	{
		if (m_comboStyle !is null)
			m_comboStyle.OnEnd(this);
	}

	void OnPotionCharged()
	{
		PlayEffect("effects/players/potion_charge.effect", m_unit);

		m_record.GetModifiers().TriggerEffects(this, null, Modifiers::EffectTrigger::PotionCharge);
	}

	void Update(int dt)
	{
		if (m_fxSpawnInvuln.IsValid())
		{
			if (g_gameMode.m_gameTime - m_spawnTime >= Tweak::SpawnInvulnTime)
			{
				m_fxSpawnInvuln.Destroy();
				m_fxSpawnInvuln = UnitPtr();
			}
		}

		if (m_trail !is null && m_trail.m_walkFx !is null)
		{
			if (m_trailWalkTimeC > 0)
				m_trailWalkTimeC -= dt;

			if (m_trailWalkTimeC <= 0 && length(m_unit.GetMoveDir()) > 0.5f)
			{
				m_trailWalkTimeC = m_trail.m_walkTime;
				PlayEffect(m_trail.m_walkFx, m_unit.GetPosition());
			}
		}

		m_buffs.Update(dt);

		for (uint i = 0; i < m_dyeStates.length(); i++)
			m_dyeStates[i].Update(dt);
	
		if (m_dmgColor.a > 0)
			m_dmgColor.a -= dt / 100.0;
		
		for (uint j = 0; j < m_record.temporaryBuffs.length(); j += 2)
		{
			if (m_record.temporaryBuffs[j + 1] > uint(dt))
				m_record.temporaryBuffs[j + 1] -= uint(dt);
			else
				m_record.temporaryBuffs[j + 1] = 0;
		}

		if (m_comboTime > 0)
		{
			m_comboTime -= dt;
			if (m_comboTime <= 0)
			{
				m_comboCount = 0;

				if (m_comboActive)
					PlaySound3D(Resources::GetSoundEvent("event:/player/combo/deactivate"), m_unit.GetPosition());
				else
					PlaySound3D(Resources::GetSoundEvent("event:/player/combo/failed"), m_unit.GetPosition());
			}
		}
		else
			m_comboCount = 0;

		if (m_comboEffectsTime > 0)
			m_comboEffectsTime -= dt;

		bool comboPrev = m_comboActive;

		m_comboActive = false;
		if (GetComboBars().x >= 1.0f)
			m_comboActive = true;

		if (comboPrev != m_comboActive)
		{
			if (m_comboActive)
				OnComboBegin();
			else
				OnComboEnd();
		}

		if (m_comboActive)
		{
			this.ApplyBuff(ActorBuff(this, m_comboBuff, 1.0f, false, 0));

			float t = g_scene.GetTime() / 250.0;
			float st = 0.25;
			m_unit.Colorize(vec4(0.5,0,0.5, st), vec4(1,0,1, st), vec4(1,0.75,1,1));

			if (m_comboEffectsTime <= 0)
			{
				m_comboEffectsTime += 1000;

				vec2 aimDir = vec2(cos(m_dirAngle), sin(m_dirAngle));

				auto effects = m_record.GetModifiers().ComboEffects(this);
				if (effects.length() > 0)
					ApplyEffects(effects, this, UnitPtr(), xy(m_unit.GetPosition()), aimDir, 1.0, false);
			}
		}
		else
			m_unit.Colorize(m_buffs.m_color.m_dark, m_buffs.m_color.m_mid, m_buffs.m_color.m_bright);

		auto modifiers = m_record.GetModifiers();

		vec2 negArmor = Tweak::NewGamePlusNegArmor(g_ngp);
		vec2 armorAdd = modifiers.ArmorAdd(this, null);
		vec2 armorMul = modifiers.ArmorMul(this, null) * m_buffs.ArmorMul();
		
		m_currentArmor.x = (m_record.Armor() + armorAdd.x) * armorMul.x - negArmor.x;
		m_currentArmor.y = (m_record.Resistance() + armorAdd.y) * armorMul.y - negArmor.y;

		m_currentAttackSpeed.x = modifiers.AttackTimeMul(this);
		m_currentAttackSpeed.y = modifiers.SkillTimeMul(this);
	}
	
	void UpdateFootsteps(int dt, bool dashing, bool force = false)
	{
		if (!dashing)
		{
			if (m_footsteps !is null)
				m_footsteps.Update(dt, force);
		}
		else
		{
			if (m_footstepsDash !is null)
				m_footstepsDash.Update(dt, force);
		}
	}

	void NetHeal(int amt) override
	{
		AddFloatingText(FloatingTextType::PlayerHealed, "" + amt, m_unit.GetPosition());
		m_dmgColor = vec4(0, 1, 0, 1);

		auto modifiers = m_record.GetModifiers();
		float maxHp = (m_record.MaxHealth() + modifiers.StatsAdd(this).x) * modifiers.MaxHealthMul(this);

		m_record.hp = min(1.0f, m_record.hp + (float(amt) / maxHp));
	}

	bool PreRender(int idt)
	{
		if (m_unit.IsDestroyed())
			return true;

		for (uint i = 0; i < m_dyeStates.length(); i++)
			SetShades(i, m_dyeStates[i].GetShades(idt));
		return false;
	}
}
