%if NON_FINAL
bool g_cvar_god = false;
%endif

class Player : PlayerBase
{
	array<PlayerUsable@> m_usables;
	
	vec2 m_lastDirection;
	vec2 m_lastSentPos;
	vec2 m_lastSentDir;
	float m_lastSentHP;
	float m_lastSentMana;
	pfloat m_hello;

	float m_queuedHealing = 0;


	UnitScene@ m_fxBlockProjectile;
	SoundEvent@ m_sndBlockProjectile; // TODO: Just move this sound to the effect??
	UnitScene@ m_fxBlockPhysical;
	UnitScene@ m_fxBlockMagical;
	UnitScene@ m_fxCurseCrit;
	UnitScene@ m_fxCurseMiss;
	UnitScene@ m_fxBlockLunarShield;
	UnitScene@ m_fxChargeLunarShield;
	
	SoundEvent@ m_sndNoMana;
	SoundEvent@ m_sndCooldown;
	SoundEvent@ m_sndEvade;

	bool m_returningDamage;
	bool m_insideJammable;

	int m_potionDelay;
	int m_cachedCurses;
	int m_cachedMtBlocks;
	
	float m_windScale;

	CurseBuffInfo@ m_curseBuffIcon;
	MtBlockBuffInfo@ m_mtBuffIcon;
	
	uint64 m_buffsImmuneTags;

%if HARDCORE
	int m_tmLegacyTitleCheck = 1000;
%endif

	Player(UnitPtr unit, SValue& params)
	{
		super(unit, params);

		//TODO: Replace check with something so that on splitscreen, only the first player can use cheats
		//if (Network::IsServer())
		{
			AddVar("noclip", false, SetNoClipCVar, 0);
			AddVar("god", false, SetGodmodeCVar, 0);
			AddVar("clientfollowshost", false, null, 0);
			AddVar("show_all_accomplishments", false, null, 0);
			AddVar("g_merc_all_skills", false, null, 0);

			{
				array<cvar_type> cfuncParams = { cvar_type::String };
				AddFunction("give_item", cfuncParams, GiveItemCFunc, 0);
				AddFunction("take_item", cfuncParams, TakeItemCFunc, 0);
				AddFunction("give_drink", cfuncParams, GiveDrinkCFunc, 0,
					"Consumes a drink. (give_drink <id>)");
				AddFunction("give_blueprint", cfuncParams, GiveBlueprintCFunc, 0);
				AddFunction("give_statue", { cvar_type::String, cvar_type::Int }, GiveStatueCFunc, 0,
					"Gives a statue. (give_statue <id> <level>)");
				AddFunction("give_statue_blueprint", cfuncParams, GiveStatueBlueprintCFunc, 0);
				AddFunction("set_trail", cfuncParams, SetTrailCFunc, 0);
				AddFunction("set_frame", cfuncParams, SetFrameCFunc, 0);
				AddFunction("set_combo", cfuncParams, SetComboCFunc, 0,
					"Sets the combo style. (set_combo <id>)");
				AddFunction("set_gravestone", cfuncParams, SetGravestoneCFunc, 0,
					"Sets the player corpse gravestone. (set_gravestone <id>)");
				AddFunction("give_insurance", cfuncParams, GiveInsuranceCFunc, 0,
					"Gives the player a mercenary life insurance. (give_insurance <campaign id>)");
			}

			{
				array<cvar_type> cfuncParams = { cvar_type::Int, cvar_type::Int, cvar_type::Int, cvar_type::Int, cvar_type::Int };
				AddFunction("give_items", cfuncParams, GiveItemsCFunc, 0,
					"Gives multiple random items. (give_items <common> <uncommon> <rare> <epic> <legendary>)");
				AddFunction("give_drinks", cfuncParams, GiveDrinksCFunc, 0,
					"Gives multiple random drinks. (give_drinks <common> <uncommon> <rare> <epic> <legendary>)");
			}

			AddFunction("clear_items", ClearItemsCfunc, 0);
			AddFunction("clear_mtblocks", ClearMtBlocksCfunc, 0);
			AddFunction("give_combo", GiveComboCfunc, 0);
			AddFunction("next_level", NextLevelCfunc, 0);
			AddFunction("unlock_merc", UnlockMercCfunc, 0);

			{
				array<cvar_type> cfuncParams = { cvar_type::Int };
				AddFunction("give_title", cfuncParams, GiveTitleCFunc, 0);
				AddFunction("give_experience", cfuncParams, GiveExperienceCFunc, 0);
				AddFunction("give_health", cfuncParams, GiveHealthCFunc, 0);
				AddFunction("give_mana", cfuncParams, GiveManaCFunc, 0);
				AddFunction("give_armor", cfuncParams, GiveArmorCFunc, 0);
				AddFunction("give_key", cfuncParams, GiveKeyCFunc, 0);
				AddFunction("give_curse", cfuncParams, GiveCurseCFunc, 0);
				AddFunction("levelup", cfuncParams, LevelupCFunc, 0);
				AddFunction("set_ngp", cfuncParams, SetNgpCFunc, 0,
					"Sets the NG+ value currently being played. (set_ngp <value>)");
				AddFunction("set_char_gladiator", cfuncParams, SetCharGladiatorCFunc, 0);

				AddFunction("give_gold", cfuncParams, GiveGoldCFunc, 0);
				AddFunction("give_ore", cfuncParams, GiveOreCFunc, 0);
				AddFunction("give_legacy", cfuncParams, GiveLegacyCFunc, 0,
					"Gives legacy points to use in the shop. (give_legacy <amount>)");
			}

			AddFunction("set_stat", { cvar_type::String, cvar_type::Int }, SetStatCFunc, 0,
				"Sets a stat to an absolute value. (set_stat <name> <value>)");

			AddFunction("set_char_ngp", { cvar_type::String, cvar_type::Int }, SetCharNgpCFunc, 0,
				"Sets the character's NG+ level. (set_char_ngp <name> <level>)");

			AddFunction("set_flag", { cvar_type::String, cvar_type::Bool, cvar_type::Bool }, SetFlagCFunc, 0,
				"Sets a flag. (set_flag <flag> <value> <persistent>)");

			AddFunction("set_town_flag", { cvar_type::String, cvar_type::Bool }, SetTownFlagCFunc, 0,
				"Sets a flag on the town persistence level. (set_town_flag <flag> <value>)");

			AddFunction("killall", KillAllCFunc, 0);
			AddFunction("revive", ReviveCFunc, 0);
			AddFunction("listenemies", ListEnemiesCFunc, 0);

			AddFunction("kill", KillCFunc);
			AddFunction("listmodifiers", ListModifiersCFunc);
		}

		@m_fxBlockProjectile = Resources::GetEffect("effects/players/block_projectile.effect");
		@m_sndBlockProjectile = Resources::GetSoundEvent("event:/player/projectile_block");
		@m_fxBlockPhysical = Resources::GetEffect("effects/players/block_physical.effect");
		@m_fxBlockMagical = Resources::GetEffect("effects/players/block_magical.effect");
		@m_fxCurseCrit = Resources::GetEffect("effects/curse_crit.effect");
		@m_fxCurseMiss = Resources::GetEffect("effects/curse_miss.effect");
		@m_fxBlockLunarShield = Resources::GetEffect("effects/players/lunar_shield.effect");
		@m_fxChargeLunarShield = Resources::GetEffect("effects/players/lunar_shield_charge.effect");
		
		@m_sndNoMana = Resources::GetSoundEvent("event:/player/no_mana");
		@m_sndCooldown = Resources::GetSoundEvent("event:/player/cooldown");
		@m_sndEvade = Resources::GetSoundEvent("event:/player/dodge");
		
		m_returningDamage = false;

		m_windScale = GetParamFloat(unit, params, "wind-scale", false, 1.0f);
		m_cachedCurses = 0;
		
		m_buffsImmuneTags = GetBuffTags(params, "buffs-immune-");
	}

	float GetWindScale() override { return m_windScale * m_buffs.WindScaleMul() * g_allModifiers.WindScale(this); }

	void Initialize(PlayerRecord@ record) override
	{
		PlayerBase::Initialize(record);

		EnableModifiers();

		@m_curseBuffIcon = CurseBuffInfo(this);
		m_curseBuffIcon.RefreshIcon();

		@m_mtBuffIcon = MtBlockBuffInfo(this);
		//m_mtBuffIcon.RefreshIcon();
	}

	void EnableModifiers()
	{
		g_allModifiers.Add(m_record.modifiers);
	}

	void DisableModifiers()
	{
		g_allModifiers.Remove(m_record.modifiers);
	}

	int FindUsable(IUsable@ usable)
	{
		for (uint i = 0; i < m_usables.length(); i++)
		{
			if (m_usables[i].m_usable is usable)
				return i;
		}
		return -1;
	}

	void AddUsable(IUsable@ usable)
	{
		int index = FindUsable(usable);
		if (index != -1)
		{
			m_usables[index].m_refCount++;
			return;
		}

		m_usables.insertLast(PlayerUsable(usable));
		m_usables.sortAsc();
	}

	void RemoveUsable(IUsable@ usable)
	{
		int index = FindUsable(usable);
		if (index != -1)
		{
			if (--m_usables[index].m_refCount <= 0)
				m_usables.removeAt(index);
			return;
		}
	}

	IUsable@ GetTopUsable()
	{
		for (uint i = 0; i < m_usables.length(); i++)
		{
			if (m_usables[i].m_usable.CanUse(this))
				return m_usables[i].m_usable;
		}
		if (m_usables.length() > 0)
			return m_usables[0].m_usable;
		return null;
	}

	void LoadPet() override
	{
		PlayerBase::LoadPet();

		SValueBuilder builder;
		builder.PushArray();
		for (uint i = 0; i < m_record.currentPetFlags.length(); i++)
			builder.PushInteger(m_record.currentPetFlags[i]);

		(Network::Message("PlayerLoadPet") << m_record.currentPet << m_record.currentPetSkin << builder.Build()).SendToAll();
	}

	void RefreshModifiers() override
	{
		PlayerBase::RefreshModifiers();

		// Modifiers for class title
		SValueBuilder builder;
		g_classTitles.RefreshModifiers(builder);
		(Network::Message("PlayerTitleModifiers") << builder.Build()).SendToAll();
	}

	void AddDrink(TavernDrink@ drink) override
	{
		PlayerBase::AddDrink(drink);

		(Network::Message("PlayerGiveDrink") << int(drink.idHash)).SendToAll();
	}

	void AddItem(ActorItem@ item) override
	{
		PlayerBase::AddItem(item);

		(Network::Message("PlayerGiveItem") << item.id).SendToAll();
		cast<Campaign>(g_gameMode).m_townLocal.FoundItem(item);

		item.inUse = true;
	}

	void TakeItem(ActorItem@ item) override
	{
		PlayerBase::TakeItem(item);

		(Network::Message("PlayerTakeItem") << item.id).SendToAll();

		//item.inUse = false;
	}

	void AttuneItem(ActorItem@ item) override
	{
		PlayerBase::AttuneItem(item);

		(Network::Message("PlayerItemAttuned") << item.id).SendToAll();
	}

	bool IsHusk() override { return false; }

	void DamagedActor(Actor@ actor, DamageInfo di) override
	{
		PlayerBase::DamagedActor(actor, di);

		if (di.Damage > 0 && m_returningDamage)
			Stats::Add("damage-returned", di.Damage, m_record);
	}

	DamageInfo DamageActor(Actor@ actor, DamageInfo di) override
	{
		if (m_cachedCurses > 0 && !roll_chance(this, pow(0.99f, m_cachedCurses)))
		{
			PlayEffect(m_fxCurseMiss, actor.m_unit.GetPosition());

			di.PhysicalDamage = 0;
			di.MagicalDamage = 0;
			di.Crit = 0;
			return di;
		}

		return PlayerBase::DamageActor(actor, di);
	}

	void NetShareExperience(int experience)
	{
		float xpReward = float(experience - m_record.level * 3);
		xpReward *= m_buffs.ExperienceMul();
		xpReward *= Tweak::ExperienceScale;

		float expMul = (g_allModifiers.ExpMul(this, null) + g_allModifiers.ExpMulAdd(this, null)) * g_mpExpScale;

		int xpr = int(xpReward * expMul);
		if (xpr > 0)
			m_record.GiveExperience(xpr);
	}

	void PlayerKilled(PlayerRecord@ player)
	{
	}
	
	void KilledActor(Actor@ killed, DamageInfo di) override
	{
		PlayerBase::KilledActor(killed, di);

		auto enemy = cast<CompositeActorBehavior>(killed);
	
		Stats::Add("enemies-killed", 1, m_record);
		if (enemy !is null && enemy.m_enemyType != "")
			Stats::Add(enemy.m_enemyType + "-killed", 1, m_record);
		
		cast<Campaign>(g_gameMode).m_townLocal.KilledEnemy(killed);
		g_allModifiers.TriggerEffects(this, killed, Modifiers::EffectTrigger::Kill);
		
		//TODO: Cache flag?
		if (g_flags.IsSet("unlock_combo") && !g_allModifiers.ComboDisabled(this))
		{
			m_comboCount++;

			Stats::Max("best-combo", m_comboCount, m_record);

			vec2 combo = GetComboBars();
			if (combo.x >= 1.0f)
				m_comboTime = 2000 + m_record.GetModifiers().ComboProps(this).z;
			else
				m_comboTime = 1000;
		}

		if (enemy !is null && enemy.m_expReward > 0)
		{
			int xp = int(enemy.m_expReward * (1.0f + float(g_ngp) * 0.1f) + 30 * float(g_ngp));
			(Network::Message("PlayerShareExperience") << xp).SendToAll();
			
			float xpReward = float(xp - m_record.level * 3);
			xpReward *= m_buffs.ExperienceMul();
			xpReward *= Tweak::ExperienceScale;

			float expMul = (g_allModifiers.ExpMul(this, killed) + g_allModifiers.ExpMulAdd(this, killed)) * g_mpExpScale;

			int xpr = int(xpReward * expMul);
			if (xpr > 0)
				m_record.GiveExperience(xpr);
		}
	}

	bool CanGiveArmor(int amt, ArmorDef@ def, bool replace)
	{
		return false;
	}

	bool GiveArmor(int amt, ArmorDef@ def, bool replace)
	{
		return false;
	}

	void Kill(Actor@ killer, uint weapon) override
	{
		OnDeath(DamageInfo(0, killer, 1, false, true, weapon), m_lastDirection);
		Actor::Kill(killer, weapon);
	}
	
	bool ApplyBuff(ActorBuff@ buff) override
	{ 
		if ((buff.m_def.m_tags & m_buffsImmuneTags) != 0)
			return false;
	
		if (BlockBuff(buff, m_record.armorDef, m_record.armor))
			return false;
	
		return PlayerBase::ApplyBuff(buff);
	}
	
	void GiveMana(int mana)
	{
		ivec2 stats = g_allModifiers.StatsAdd(this);
		float manaf = mana;
		
		if (manaf < 0)
			manaf *= g_allModifiers.ManaDamageTakenMul(this);

		AddFloatingGive(int(manaf), FloatingTextType::PlayerAmmo);
		m_record.mana = clamp(m_record.mana + manaf / float(m_record.MaxMana() + stats.y), 0.0f, 1.0f);

		//TODO: Netsync
	}

	void TakeMana(int mana)
	{
		ivec2 stats = g_allModifiers.StatsAdd(this);
		float manaf = float(mana) * g_allModifiers.ManaDamageTakenMul(this);
		
		AddFloatingGive(-int(manaf), FloatingTextType::PlayerAmmo);
		m_record.mana = clamp(m_record.mana - manaf / float(m_record.MaxMana() + stats.y), 0.0f, 1.0f);

		//TODO: Netsync
	}

	int Heal(int amount) override
	{
		int healAmnt = int(amount * g_allModifiers.AllHealthGainScale(this));
		m_queuedHealing += healAmnt;
		AddFloatingText(FloatingTextType::PlayerHealed, "" + healAmnt, m_unit.GetPosition());
		(Network::Message("PlayerHealed") << healAmnt << m_record.hp).SendToAll();
		Stats::Add("amount-healed", healAmnt, m_record);
		return healAmnt;
	}
	
	void SoulLinkKill(PlayerHusk@ killer)
	{
		OnDeath(DamageInfo(killer, 1, 1, false, true, 0), m_lastDirection);
		Actor::Kill(killer, 0);
	}
	
	void SoulLinkDamage(int dmg)
	{
	/*
		if (
%if NON_FINAL
			g_cvar_god ||
%endif
			m_record.IsDead() || dmg <= 0)
		{
			return;
		}

		int maxHp = m_record.MaxHealth();
		
		m_record.hp -= float(dmg) / float(maxHp);
		AddFloatingHurt(dmg, 0, FloatingTextType::PlayerHurt);
		m_dmgColor = vec4(1, 0, 0, 1);
		
		Stats::Add("damage-taken", dmg, m_record);
		Stats::Max("damage-taken-max", dmg, m_record);

		if (m_record.CurrentHealth() <= 0)
			OnDeath(DamageInfo(null, dmg, 0, false, true, 0), m_lastDirection);
		else
		{
			if (m_gore !is null)
				m_gore.OnHit(float(dmg) / float(maxHp), xy(m_unit.GetPosition()), m_dirAngle);

			dictionary params = { { "damage", float(dmg) } };
			PlaySound3D(m_voice.m_soundHurt, m_unit, params);
		}
	*/
	}

	void NetDecimate(int hp, int mana) override
	{
		int maxHp = int((m_record.MaxHealth() + g_allModifiers.StatsAdd(this).x) * g_allModifiers.MaxHealthMul(this));
		m_record.hp -= float(hp) / float(maxHp);
		
		if (hp < 0)
			AddFloatingHurt(-hp, 0, FloatingTextType::PlayerHealed);
		else if (hp > 0)
			AddFloatingHurt(hp, 0, FloatingTextType::PlayerHurt);
	}
		
	int Decimate(DecimateInfo dec, vec2 pos, vec2 dir) override
	{
		if (
%if NON_FINAL
			g_cvar_god ||
%endif
			m_record.IsDead())
		{
			return 0;
		}

		if (g_gameMode.m_gameTime - m_spawnTime < Tweak::SpawnInvulnTime)
			return 0;

		int maxHp = int((m_record.MaxHealth() + g_allModifiers.StatsAdd(this).x) * g_allModifiers.MaxHealthMul(this));
		int maxMp = m_record.MaxMana() + g_allModifiers.StatsAdd(this).y;
		int preHp = int(m_record.hp * maxHp);
		int preMp = int(m_record.mana * maxMp);
		
		float new = clamp((m_record.hp - dec.HealthMax) * (1.0f - dec.HealthCurr), 0.0f, 1.0f);
		
		m_record.hp = new;
		m_record.mana = clamp((m_record.mana - dec.ManaMax) * (1.0f - dec.ManaCurr), 0.0f, 1.0f);
		
		assert(m_record.hp, new);
		
		int dmgAmnt = preHp - int(m_record.hp * maxHp);
		int mpLoss = preMp - int(m_record.mana * maxMp);

		if (dmgAmnt < 0)
		{
			AddFloatingHurt(-dmgAmnt, 0, FloatingTextType::PlayerHealed);
			Stats::Add("amount-healed", -dmgAmnt, m_record);
		}
		else if (dmgAmnt > 0)
		{
			AddFloatingHurt(dmgAmnt, 0, FloatingTextType::PlayerHurt);
			//Stats::Add("damage-taken", dmgAmnt, m_record);
		}
		
		(Network::Message("UnitDecimated") << m_unit << dmgAmnt << mpLoss).SendToAll();
		return dmgAmnt;
	}
	
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		if (
%if NON_FINAL
			g_cvar_god ||
%endif
			m_record.IsDead())
		{
			return 0;
		}

		if (g_gameMode.m_gameTime - m_spawnTime < Tweak::SpawnInvulnTime)
			return 0;

		bool isTrapDamage = (dmg.Attacker is null);

		bool selfDmg = false;
		if (dmg.Attacker is this)
		{
			@dmg.Attacker = null;
			selfDmg = true;
		}

		int maxHp = m_record.MaxHealth();		
		vec2 armor(m_record.Armor(), m_record.Resistance());
		ivec2 block;
		float dmgTakenMul = 1.0f;

		if (g_allModifiers.NonLethalDamage(this, dmg))
			dmg.CanKill = false;

		if (dmg.DamageType != 0)
		{
			if (!dmg.TrueStrike)
			{
				if (g_allModifiers.Evasion(this, dmg.Attacker))
				{
					Stats::Add("evade-amount", 1, m_record);
					g_allModifiers.TriggerEffects(this, dmg.Attacker, Modifiers::EffectTrigger::Evade);
					m_dmgColor = vec4(0, 0, 0, 2.0);
					PlaySound3D(m_sndEvade, m_unit);
					return 0;
				}
				
				block += g_allModifiers.DamageBlock(this, dmg.Attacker);

				vec2 blockMul = g_allModifiers.DamageBlockMul(this, dmg.Attacker);

				if (m_record.mtBlocks > 0 && m_mtBlocksCooldown <= 0)
				{
					m_record.mtBlocks--;
					m_mtBlocksCooldown = Tweak::MtBlocksCooldown;

					blockMul *= 0.5f;

					Stats::Add("mt-blocks", 1, m_record);

					PlayEffect(m_fxBlockLunarShield, pos);
				}

				if (blockMul.x < 1.0f)
					block.x += int((1.0f - blockMul.x) * dmg.PhysicalDamage);
				if (blockMul.y < 1.0f)
					block.y += int((1.0f - blockMul.y) * dmg.MagicalDamage);
				
				if (block.x + block.y > 0)
				{
					Stats::Add("damage-blocked", block.x + block.y, m_record);
					
					if (block.x > 0)
						PlayEffect(m_fxBlockPhysical, pos);
					else
						PlayEffect(m_fxBlockMagical, pos);
				}
				
				if (dmg.PhysicalDamage > 0)
					dmg.PhysicalDamage = max(0, dmg.PhysicalDamage - block.x);
				
				if (dmg.MagicalDamage > 0)
					dmg.MagicalDamage = max(0, dmg.MagicalDamage - block.y);
			}
			
			armor += g_allModifiers.ArmorAdd(this, dmg.Attacker);
			maxHp += g_allModifiers.StatsAdd(this).x;
			maxHp = int(maxHp * g_allModifiers.MaxHealthMul(this));
			maxHp = max(1, maxHp);

			float trapMultiplier = 1.0f;
			if (isTrapDamage)
			{
				if (Fountain::HasEffect("reduced_trap_damage"))
					trapMultiplier *= 0.5f;
				if (Fountain::HasEffect("more_trap_damage"))
					trapMultiplier *= 2.0f;
			}

			float hc = 1.0f; //lerp(1.0f, 0.8f, m_record.GetHandicap());
			dmgTakenMul *= hc * trapMultiplier * g_allModifiers.DamageTakenMul(this, dmg) * m_buffs.DamageTakenMul();
		}

		auto enemy = cast<CompositeActorBehavior>(dmg.Attacker);
		if (enemy !is null)
		{
			auto entry = enemy.GetBestiaryAttunement();
			if (entry !is null)
				dmgTakenMul *= pow(0.95, entry.m_attuned);
		}
		
		if (m_cachedCurses > 0 && !roll_chance(this, pow(0.99f, m_cachedCurses)))
		{
			PlayEffect(m_fxCurseCrit, m_unit.GetPosition());
			dmgTakenMul *= 2.0f + 0.01f * m_cachedCurses;
		}
		
		dmgTakenMul *= GetVarFloat("hx_dmg_taken");
		vec2 armorMul = g_allModifiers.ArmorMul(this, null) * m_buffs.ArmorMul();
		int dmgAmnt = ApplyArmor(dmg, armorMul * armor * dmg.ArmorMul - Tweak::NewGamePlusNegArmor(g_ngp), dmgTakenMul);

		if (dmgAmnt > 0)
		{
			if (!dmg.CanKill || g_isTown)
				dmgAmnt = min(m_record.CurrentHealth() - 1, dmgAmnt);
			
			bool evadable = dmg.Melee && dmg.Attacker !is null && !dmg.Attacker.IsDead();
			
			m_returningDamage = true;
			
			if (selfDmg)
				g_allModifiers.TriggerEffects(this, dmg.Attacker, Modifiers::EffectTrigger::HurtSelf);
			else
				g_allModifiers.TriggerEffects(this, dmg.Attacker, Modifiers::EffectTrigger::HurtNonSelf);
			
			g_allModifiers.TriggerEffects(this, dmg.Attacker, Modifiers::EffectTrigger::Hurt);
			g_allModifiers.DamageTaken(this, dmg.Attacker, dmgAmnt);
			m_returningDamage = false;

			if (m_record.IsLocalPlayer() || m_record.items.find("phoenix-feather") != -1)
			{
				int testHealth = m_record.CurrentHealth() - dmgAmnt;
				while (testHealth <= 0)
				{
					int charges = 1 + g_allModifiers.PotionCharges();
					int availableCharges = charges - m_record.potionChargesUsed;
					if (availableCharges <= 0)
						break;

					int healed = ForceDrinkPotion();
					testHealth += healed;
					dmgAmnt -= healed;
				}
			}
		
			if (evadable && dmg.Attacker.IsDead())
			{
				g_allModifiers.TriggerEffects(this, dmg.Attacker, Modifiers::EffectTrigger::Evade);
				m_dmgColor = vec4(0, 0, 0, 2.0);
				PlaySound3D(m_sndEvade, m_unit);
				return 0;
			}
			
			float new = float(m_record.hp) - float(dmgAmnt) / float(maxHp);
			m_record.hp = new;
			assert(m_record.hp, new);
			AddFloatingHurt(dmgAmnt, dmg.Crit, dmg.MagicalDamage > dmg.PhysicalDamage ? FloatingTextType::PlayerHurtMagical : FloatingTextType::PlayerHurt);
			m_dmgColor = vec4(1, 0, 0, 1);
			
			int manaFromDamage = g_allModifiers.ManaFromDamage(this, dmgAmnt);
			if (manaFromDamage > 0)
				this.GiveMana(manaFromDamage);

			Stats::Add("damage-instances-taken", 1, m_record);
			Stats::Add("damage-taken", dmgAmnt, m_record);
			Stats::Max("damage-taken-max", dmgAmnt, m_record);
			

			//if (dmgAmnt > 5)
			//	MusicManager::AddTension(2.5);
			
			if (m_record.CurrentHealth() <= 0)
			{
				//dmg.Damage = dmgAmnt;
				//BroadcastNetDamage(dmg);
				OnDeath(dmg, dir);
				return dmgAmnt;
			}
			else
			{
				if (m_gore !is null)
					m_gore.OnHit(float(dmgAmnt) / float(maxHp), pos, atan(dir.y, dir.x));

				dictionary params = { { "damage", float(dmgAmnt) } };

				if (!selfDmg)
					PlaySound3D(m_voice.m_soundHurt, m_unit, params);
			}
		}
		else if (dmgAmnt < 0)
		{
			if (m_record.hp < 1.0)
				return -Heal(-dmgAmnt);
			else
				return 0;
		}
		else
		{
			AddFloatingHurt(0, dmg.Crit, dmg.MagicalDamage > dmg.PhysicalDamage ? FloatingTextType::PlayerHurtMagical : FloatingTextType::PlayerHurt);
		}

		dmg.Damage = dmgAmnt;
		BroadcastNetDamage(dmg);
		return dmgAmnt;
	}

	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		this.Damage(dmg, pos, dir);
	}

	void BroadcastNetDamage(DamageInfo di)
	{
		int damager = 0;
		if (di.Attacker !is null && di.Attacker.m_unit.IsDestroyed())
			damager = di.Attacker.m_unit.GetId();

		m_lastSentHP = m_record.hp;
		(Network::Message("PlayerDamaged") << di.DamageType << damager << di.Damage << m_record.hp << di.Weapon).SendToAll();
	}

	void OnDeath(DamageInfo di, vec2 dir) override
	{
		PlayerBase::OnDeath(di, dir);

		DisableModifiers();

		auto gm = cast<Campaign>(g_gameMode);

		Stats::Add("death-count", 1, m_record);

		if (cast<Town>(gm) is null)
			Stats::Add("floor-deaths-" + (gm.m_levelCount + 1), 1, m_record);

		int killerPeer = -1;
		
		auto plyKiller = cast<PlayerBase>(di.Attacker);
		if (plyKiller !is null)
			killerPeer = plyKiller.m_record.peer;
		
		m_record.deaths++;
		m_record.deathsTotal++;
		(Network::Message("PlayerDied") << killerPeer << int(di.DamageType) << int(di.Damage) << di.Melee << di.Weapon).SendToAll();

		PlayerRecord@ killerRecord;
		if (plyKiller !is null)
			@killerRecord = plyKiller.m_record;
		else if (di.Attacker !is null)
			cast<Campaign>(g_gameMode).m_townLocal.EnemyKilledPlayer(di.Attacker);	
			
		gm.PlayerDied(m_record, killerRecord, di);

		auto hud = GetHUD();
		if (hud !is null)
			hud.OnDeath();
	}

	bool IsDead() override { return !m_unit.IsValid() || m_record.IsDead(); }

	void OnNewTitle(Titles::Title@ title)
	{
		auto gm = cast<Campaign>(g_gameMode);
		gm.SavePlayer(m_record);

%if HARDCORE
		switch (int(m_record.titleIndex))
		{
			case 1: Platform::Service.UnlockAchievement("merc_corporal"); break;
			case 2: Platform::Service.UnlockAchievement("merc_sergeant"); break;
			case 3: Platform::Service.UnlockAchievement("merc_lieutenant"); break;
			case 4: Platform::Service.UnlockAchievement("merc_captain"); break;
			case 5: Platform::Service.UnlockAchievement("merc_major"); break;
			case 6: Platform::Service.UnlockAchievement("merc_colonel"); break;
			case 7: Platform::Service.UnlockAchievement("merc_general"); break;
		}
%endif

		dictionary paramsTitle = { { "title", Resources::GetString(title.m_name) } };
		gm.m_notifications.Add(
			Resources::GetString(
%if HARDCORE
				".hud.newtitle.character.mercenary",
%else
				".hud.newtitle.character",
%endif
				paramsTitle
			),
			ParseColorRGBA("#" + Tweak::NotificationColors_NewTitle + "FF")
		);

		RefreshModifiers();
	}

	void OnLevelUp(int levels)
	{
		(Network::Message("PlayerLevelUp")).SendToAll();

		auto hud = GetHUD();
		hud.PlayPickup();
		
		PlaySound3D(Resources::GetSoundEvent("event:/player/levelup"), m_unit);
		PlayEffect("effects/players/levelup.effect", m_unit);

		AddFloatingText(FloatingTextType::Pickup, Resources::GetString(".hud.levelup"), m_unit.GetPosition());

		m_record.hp = 1.0;
		m_record.mana = 1.0;

		Stats::Add("levels-gained", levels, m_record);
		Stats::Add("avg-levels-gained", levels, m_record);
		Stats::Max("max-level-" + m_record.charClass, m_record.level);
	}

	void WarnCooldown(Skills::Skill@ skill, int ms) override
	{
		if (skill.m_skillId == 0)
			return;
		
		AddFloatingText(FloatingTextType::PlayerArmor, "[" + formatTime(ms / 1000.0f / m_currentAttackSpeed.y, true, false, false, false, true) + "]", m_unit.GetPosition());
		PlaySound3D(m_sndCooldown, m_unit.GetPosition());
	}

	bool SpendCost(int mana, int stamina, int health) override
	{
		ivec2 stats = g_allModifiers.StatsAdd(this);
		
		float manaCostMul = g_allModifiers.SpellCostMul(this);
		float manaCost = float(mana) / float(m_record.MaxMana() + stats.y) * manaCostMul;
	
		if (manaCost > 0 && !m_buffs.FreeMana())
		{
			if (m_record.mana < manaCost)
			{
				int diff = int(ceil((manaCost - m_record.mana) * float(m_record.MaxMana())));
				AddFloatingText(FloatingTextType::PlayerArmor, "(-" + diff + ")", m_unit.GetPosition());
				PlaySound3D(m_sndNoMana, m_unit.GetPosition());
				return false;
			}

			m_record.mana -= manaCost;
			//m_record.stamina -= stamina;

			Stats::Add("spent-mana", int(mana * manaCostMul), m_record);
		}
		
		/*
		if (stamina > 0)
		{
			if (m_record.stamina < stamina)
			{
				AddFloatingText(FloatingTextType::EnemyImmortal, "Stamina!", m_unit.GetPosition());
				return false;
			}
		}
		*/
		
		return true; 
	}
	
	
	
	uint m_lastCollideTime;
	UnitPtr m_lastCollideUnit;
	
	void Collide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxSelf, Fixture@ fxOther)
	{
		for (uint i = 0; i < m_skills.length(); i++)
			m_skills[i].OnCollide(unit, pos, normal, fxOther);
			

		
		if (fxOther.IsSensor())
			return;
			
		auto nowT = g_scene.GetTime();
		if (m_lastCollideUnit == unit)
		{
			if ((m_lastCollideTime + 100) > nowT)
				return;
		}
			
		m_lastCollideUnit = unit;
		
		auto actor = cast<Actor>(unit.GetScriptBehavior());
		if (actor is null)
			return;

		auto player = cast<PlayerBase>(actor);
		if (player !is null)
			return;

		g_allModifiers.TriggerEffects(this, actor, Modifiers::EffectTrigger::Collide);
		m_lastCollideTime = nowT;
	}
	
	bool BlockProjectile(IProjectile@ proj) override
	{
		auto block = g_allModifiers.ProjectileBlock(this, proj);
		if (block)
		{
			auto pb = cast<ProjectileBase>(proj);
			vec3 pos;
			
			if (pb !is null)
				pos = pb.m_unit.GetPosition();
			else
				pos = m_unit.GetPosition();
			
			PlayEffect(m_fxBlockProjectile, xy(pos));
			PlaySound3D(m_sndBlockProjectile, pos);
			return true;
		}
	
		return false;
	}
	
	
	bool CheckSkillBlocked(Skills::Skill@ skill)
	{
		int firstSkill = (skill is m_skills[0]) ? 0 : 1;
		if (skill.IsBlocking())
		{
			for (uint i = firstSkill; i < m_skills.length(); i++)
			{
				if (m_skills[i].IgnoreForBlock())
					continue;
			
				if (skill !is m_skills[i] && m_skills[i].IsActive())
					return true;
			}
		}
		else
		{
			for (uint i = firstSkill; i < m_skills.length(); i++)
				if (skill !is m_skills[i] && m_skills[i].IsActive() && m_skills[i].IsBlocking())
					return true;
		}
		
		return false;
	}
	
	void CheckUseSkill(int dt, ButtonState &in btn, Skills::Skill@ skill, vec2 aimDir)
	{
		int targetSz = 0;
		auto targetMode = skill.GetTargetingMode(targetSz);
	
		if (CheckSkillBlocked(skill))
		{
			if (targetMode == Skills::TargetingMode::Channeling && skill.IsActive())
			{
				skill.Release(aimDir);
				skill.m_isActive = false;
			}
		
			return;
		}

		if (btn.Pressed)
		{
			if (targetMode == Skills::TargetingMode::Toggle)
			{
				if (!skill.m_isActive && skill.Activate(aimDir))
				{
					g_allModifiers.TriggerEffects(this, null, Modifiers::EffectTrigger::CastSpell);
					skill.m_isActive = true;
				}
				else if (skill.m_isActive)
				{
					skill.Deactivate();
					skill.m_isActive = false;
				}
			}
			else if (skill.Activate(aimDir) && skill !is m_skills[0])
				g_allModifiers.TriggerEffects(this, null, Modifiers::EffectTrigger::CastSpell);
		}
		
		if (targetMode == Skills::TargetingMode::Channeling)
		{
			if (btn.Down)
			{
				skill.Hold(dt, aimDir);
				skill.m_isActive = true;
			}

			if (btn.Released || (!btn.Down && skill.m_isActive))
			{
				skill.Release(aimDir);
				skill.m_isActive = false;
			}
		}
	}

	void OnComboBegin() override
	{
		(Network::Message("PlayerCombo") << true << m_comboTime << m_comboCount).SendToAll();
		PlayerBase::OnComboBegin();
	}

	void OnComboEnd() override
	{
		(Network::Message("PlayerCombo") << false << 0 << 0).SendToAll();
		PlayerBase::OnComboEnd();
	}

	void OnPotionCharged() override
	{
		(Network::Message("PlayerPotionCharged")).SendToAll();
		PlayerBase::OnPotionCharged();
	}

	void DrinkPotion()
	{
		if (m_record.hp >= 1.0 && m_record.mana >= 1.0)
			return;

		if (!g_flags.IsSet("unlock_apothecary"))
			return;

		ForceDrinkPotion();
	}

	int ForceDrinkPotion()
	{
		float healAmnt = 50 * g_allModifiers.PotionHealMul(this);
		float manaAmnt = 50 * g_allModifiers.PotionManaMul(this);
		int charges = 1 + g_allModifiers.PotionCharges();

		if (charges <= m_record.potionChargesUsed)
			return 0;

		int djinnLevel = m_record.ngps["pop"];
		if (djinnLevel > 0)
		{
			healAmnt += 25 * djinnLevel;
			manaAmnt += 25 * djinnLevel;
		}

		m_record.potionChargesUsed++;
		int heal = int((healAmnt + 0.5f) * g_allModifiers.AllHealthGainScale(this));

		NetHeal(heal);
		(Network::Message("PlayerHealed") << int(healAmnt) << m_record.hp).SendToAll();
		Stats::Add("amount-healed", heal, m_record);

		this.GiveMana(int(manaAmnt + 0.5f));

		PlaySound3D(Resources::GetSoundEvent("event:/player/drink_potion"), m_unit.GetPosition());
		Stats::Add("potion-charges-used", 1, m_record);
		g_allModifiers.TriggerEffects(this, null, Modifiers::EffectTrigger::DrinkPotion);

		if (djinnLevel > 0)
			SpawnDjinn();

		return heal;
	}

	void SpawnDjinn()
	{
		if (m_record.ngps["pop"] <= 0)
			return;

		if (m_djinn.IsValid())
		{
			if (Network::IsServer())
				m_djinn.Destroy();
			m_djinn = UnitPtr();
		}

		if (m_djinnSpawnEffect.IsValid())
		{
			m_djinnSpawnEffect.Destroy();
			m_djinnSpawnEffect = UnitPtr();
		}

		auto effect = Resources::GetEffect("players/summons/potion_djinn_spawn.effect");
		m_djinnSpawnTime = effect.Length();
		m_djinnSpawnEffect = PlayEffect(effect, m_unit.GetPosition());
		m_djinnSpawnPos = m_unit.GetPosition();

		(Network::Message("PlayerPotionDjinnBegin")).SendToAll();
	}

	void Update(int dt) override
	{
%PROFILE_START BaseUpdate
		PlayerBase::Update(dt);
%PROFILE_STOP

%if HARDCORE
		m_tmLegacyTitleCheck -= dt;
		if (m_tmLegacyTitleCheck <= 0)
		{
			m_tmLegacyTitleCheck = 1000;

			int currentPrestige = m_record.GetPrestige();
			int mercenaryTitleIndex = g_classTitles.m_titlesMercenary.GetTitleIndexFromPoints(currentPrestige);

			if (mercenaryTitleIndex != m_record.titleIndex)
				m_record.GiveTitle(mercenaryTitleIndex);
		}
%endif

		if (m_mtBlocksCooldown > 0)
		{
			m_mtBlocksCooldown -= dt;
			if (m_mtBlocksCooldown <= 0 && m_record.mtBlocks > 0)
				PlayEffect(m_fxChargeLunarShield, m_unit);
		}

		if (m_potionDelay > 0)
			m_potionDelay -= dt;
		
		auto input = GetInput();
		
		auto aimDir = input.AimDir;
		auto moveDir = input.MoveDir;
		if (m_buffs.Confuse() && !m_buffs.AntiConfuse())
		{
			aimDir *= -1;
			moveDir *= -1;
		}
		
		int cc = max(0, m_record.curses + g_allModifiers.CursesAdd(this));
		if (m_cachedCurses != cc)
		{
			m_cachedCurses = cc;
			m_curseBuffIcon.RefreshIcon();
		}

		if (m_cachedMtBlocks != m_record.mtBlocks)
		{
			m_cachedMtBlocks = m_record.mtBlocks;
			m_mtBuffIcon.RefreshIcon();
		}
		
		if (m_buffs.Drifting())
		{
			m_record.driftingOffset += 0.75f / dt;
			
			float ang = (sin(m_record.driftingOffset * 0.5f) - m_record.driftingOffset * 0.15f) * 0.4f;
			float a;
			
			a = atan(aimDir.y, aimDir.x) + ang;
			aimDir = vec2(cos(a), sin(a)) * length(aimDir);
			
			a = atan(moveDir.y, moveDir.x) + ang;
			moveDir = vec2(cos(a), sin(a)) * length(moveDir);
		}
		else
			m_record.driftingOffset = 0.0f;

		if (m_buffs.LockMovement())
			moveDir = vec2();

		if (m_buffs.LockRotation())
			aimDir = vec2(cos(m_dirAngle), sin(m_dirAngle));
			
		g_allModifiers.Update(this, dt);
		m_currLuck = g_allModifiers.LuckAdd(this);

		{ if (m_hello < 2.0f) { m_hello = randf(); } float x = m_hello * randf(); x = m_hello / randf(); if (m_hello >= 2.0f) { m_unit.SetPosition(vec3()); } }

		vec2 regen = (vec2(m_record.HealthRegen(), m_record.ManaRegen()) + g_allModifiers.RegenAdd(this)) * g_allModifiers.RegenMul(this);
		ivec2 stats = g_allModifiers.StatsAdd(this);
		
		m_effectParams.Set("hp_regen", (m_record.hp < 1.0f) ? regen.x : 0.f);
		m_effectParams.Set("mp_regen", (m_record.mana < 1.0f) ? regen.y : 0.f);

		float hpGainScale = g_allModifiers.AllHealthGainScale(this);
		float hpMax = (m_record.MaxHealth() + stats.x) * g_allModifiers.MaxHealthMul(this);
		
		m_record.hp = clamp(m_record.hp + dt / 1000.0f * (regen.x * hpGainScale) / hpMax, 0.0f, 1.0f);
		m_record.mana = clamp(m_record.mana + dt / 1000.0f * regen.y / (m_record.MaxMana() + stats.y), 0.0f, 1.0f);

		if (m_queuedHealing > 0)
		{
			float healing = min(hpMax / 1000.0f * dt, m_queuedHealing);
			if (m_record.hp * hpMax + healing > hpMax)
			{
				healing = float(hpMax - m_record.hp * hpMax);
				m_queuedHealing = 0;
			}
			else
				m_queuedHealing -= healing;
				
			m_record.hp = min(1.f, m_record.hp + healing / hpMax);
		}
		
		if (abs(m_lastSentHP - m_record.hp) > 0.001f || abs(m_lastSentMana - m_record.mana) > 0.001f)
		{
			m_lastSentHP = m_record.hp;
			m_lastSentMana = m_record.mana;
			(Network::Message("PlayerSyncStats") << m_lastSentHP << m_lastSentMana).SendToAll();
		}

		auto baseGameMode = cast<BaseGameMode>(g_gameMode);

		HUD@ hud = GetHUD();
		bool freezeControls = IsDead() or baseGameMode.ShouldFreezeControls();
			
		
		int snapAngleCount = GetVarInt("g_movedir_snap");
		if (snapAngleCount > 0 && lengthsq(moveDir) > 0)
		{
			float snapAngle = TwoPI / float(snapAngleCount);
			float curAngle = atan(moveDir.y, moveDir.x);
			float snappedAngle = round(curAngle / snapAngle) * snapAngle;
			moveDir.x = cos(snappedAngle);
			moveDir.y = sin(snappedAngle);
		}

		if (m_djinnSpawnTime > 0)
		{
			m_djinnSpawnTime -= dt;
			if (m_djinnSpawnTime <= 0)
			{
				m_djinnSpawnEffect.Destroy();
				m_djinnSpawnEffect = UnitPtr();

				auto prodGenie = Resources::GetUnitProducer("players/summons/potion_djinn.unit");
				if (prodGenie !is null)
				{
					if (Network::IsServer())
					{
						m_djinn = prodGenie.Produce(g_scene, m_djinnSpawnPos);
						auto newGenie = cast<PlayerOwnedActor>(m_djinn.GetScriptBehavior());
						newGenie.Initialize(this, 1.0f, false);

						(Network::Message("SetOwnedUnit") << m_djinn << m_unit << 1.0f).SendToAll();
					}
					else
						(Network::Message("PlayerPotionDjinn")).SendToHost();
				}
			}
		}
		
%PROFILE_START SkillInput

		int skillDt = int(m_currentAttackSpeed.y * dt);
		if (!freezeControls)
		{
			if (!m_buffs.Silence())
			{
				CheckUseSkill(skillDt, input.Attack4, m_skills[3], aimDir);
				CheckUseSkill(skillDt, input.Attack3, m_skills[2], aimDir);
				CheckUseSkill(skillDt, input.Attack2, m_skills[1], aimDir);

				if (input.Attack1.Pressed)
				{
					auto skill = cast<Skills::ActiveSkill>(m_skills[0]);
					if (skill !is null)
					{
						if (skill.m_cooldownC > 0 && g_allModifiers.CooldownClear(this, skill))
						{
							skill.m_cooldownC = 0;
							skill.m_cooldownOverride = true;
						}
						else
							skill.m_cooldownOverride = false;
					}
				}
			}

			if (input.Attack1.Down && !input.Ping.Down && !m_buffs.Disarm() && !CheckSkillBlocked(m_skills[0]))
			{
				if (m_skills[0].Activate(aimDir))
					g_allModifiers.TriggerEffects(this, null, Modifiers::EffectTrigger::Attack);
			}

			if (input.Potion.Pressed && m_potionDelay <= 0)
			{
				DrinkPotion();
				m_potionDelay = GetVarInt("g_potion_delay");
				Tutorial::RegisterAction("potion");
			}

			if (input.Use.Pressed)
			{
				auto usable = GetTopUsable();
				if (usable !is null && usable.CanUse(this))
				{
					Tutorial::RegisterAction("use");
				
					UnitPtr unit = usable.GetUseUnit();
					UnitProducer@ prod = unit.GetUnitProducer();
					if (prod !is null && prod.GetNetSyncMode() == NetSyncMode::None)
						usable.Use(this);
					else if (Network::IsServer())
					{
						(Network::Message("UseUnit") << unit << m_unit).SendToAll();
						usable.Use(this);
					}
					else
						(Network::Message("UseUnitSecure") << unit).SendToHost();
				}
			}
		}

%PROFILE_STOP

		PhysicsBody@ bdy = m_unit.GetPhysicsBody();
		vec2 dir = vec2(cos(m_dirAngle), sin(m_dirAngle));

		// If we have no physics body, we can't do much (player died)
		if (bdy is null)
			return;

%PROFILE_START Moving

		float moveSpeed = Tweak::PlayerSpeed;
		
		float slowScale = g_allModifiers.SlowScale(this);
		moveSpeed += g_allModifiers.MoveSpeedAdd(this, slowScale);
		moveSpeed *= g_allModifiers.MoveSpeedMul(this, slowScale);
		moveSpeed *= m_buffs.MoveSpeedMul(slowScale);

		float buffSetSpeed = m_buffs.SetSpeed();
		if (buffSetSpeed >= 0.0f)
			moveSpeed = buffSetSpeed;

		for (uint i = 0; i < m_skills.length(); i++)
		{
			auto skill = m_skills[i];
			float speedMod = skill.GetMoveSpeedMul();

			if (skill.IsActive())
			{
				speedMod *= g_allModifiers.SkillMoveSpeedMul(this, speedMod);

				if (g_allModifiers.SkillMoveSpeedClear(this, speedMod))
					speedMod = 1;
			}

			if (speedMod >= 1.0f || !m_comboActive)
				moveSpeed *= speedMod;
			else
				moveSpeed *= lerp(speedMod, 1.0, 0.5);
		}

		array<Tileset@>@ tilesets = g_scene.FetchTilesets(xy(m_unit.GetPosition()));
		for (int i = tilesets.length() - 1; i >= 0; i--)
		{
			auto tsd = tilesets[i].GetData();
			if (tsd is null)
				continue;

			SValue@ tilesetSpeed = tsd.GetDictionaryEntry("walk-speed");
			if (tilesetSpeed !is null && tilesetSpeed.GetType() == SValueType::Float)
			{
				moveSpeed *= tilesetSpeed.GetFloat();
				break;
			}
		}
		
		moveSpeed = min(moveSpeed, Tweak::PlayerSpeedMax);
		float minSpeed = m_buffs.MinSpeed();
		auto moveDirLen = length(moveDir);
		
		if (moveDirLen < minSpeed)
			moveDir = normalize((moveDirLen > 0) ? moveDir : aimDir) * minSpeed;

		moveDir = freezeControls ? vec2() : (moveDir * moveSpeed);
		
		for (uint i = 0; i < m_skills.length(); i++)
		{
			vec2 skillMoveDir = m_skills[i].GetMoveDir();
			if (skillMoveDir.x != 0 || skillMoveDir.y != 0)
			{
				moveDir = skillMoveDir;
				break;
			}
		}

		float slippery = m_buffs.MoveSlipperyMul();
		if (slippery < 1.0f)
		{
			vec2 currentVelocity = bdy.GetLinearVelocity();
			moveDir = lerp(currentVelocity, moveDir, slippery * (dt / 1000.0f));
		}

		int distance = int(length(moveDir));
		if (distance > 0)
			Stats::Add("units-traveled", distance, m_record);
		
		bdy.SetLinearVelocity(moveDir);
		
		float facing = atan(aimDir.y, aimDir.x);
		SetAngle(facing);
		
		bool walking = (lengthsq(bdy.GetLinearVelocity()) > 0.1);
		
		string scene = walking ? m_walkAnim.GetSceneName(facing) : m_idleAnim.GetSceneName(facing);
		SetBodyAnim(scene, false);
		if (m_playerBobbing)
			m_unit.SetPositionZ(walking ? ((m_unit.GetUnitSceneTime() / 125) % 2) : 0);
			
		UpdateFootsteps(dt, false);
		
%PROFILE_STOP
		
		
%PROFILE_START SkillUpdate

		m_skills[0].Update(int(m_currentAttackSpeed.x * dt), walking);
		for (uint i = 1; i < m_skills.length(); i++)
			m_skills[i].Update(skillDt, walking);

%PROFILE_STOP

		vec2 currDir = bdy.GetLinearVelocity();
		if (length(currDir) > 0.2)
			m_lastDirection = currDir;
		
		SendPlayerMove(dir);
	}
	
	void SendPlayerMove(vec2 dir, bool force = false)
	{
		auto pos = xy(m_unit.GetPosition());

		if (!force)
		{
			if (distsq(m_lastSentPos, pos) > 1 || distsq(m_lastSentDir, dir) > 0.01)
			{
				m_lastSentPos = pos;
				m_lastSentDir = dir;
				(Network::Message("PlayerMove") << pos << dir).SendToAll();
			}
		}
		else
		{
			m_lastSentPos = pos;
			m_lastSentDir = dir;
			(Network::Message("PlayerMoveForce") << pos << dir).SendToAll();
		}
	}
}


void SetNoClipCVar(bool val)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
		
	ply.m_unit.SetShouldCollide(!val);
}

void SetGodmodeCVar(bool val)
{
%if NON_FINAL
	g_cvar_god = val;
%endif
}


void GiveRandomItems(Player@ ply, ActorItemQuality quality, int num)
{
	for (int i = 0; i < num; i++)
	{
		auto item = g_items.TakeRandomItem(quality);
		if (item is null)
			return;
			
		ply.AddItem(item);
	}
}

void GiveItemsCFunc(cvar_t@ arg0, cvar_t@ arg1, cvar_t@ arg2, cvar_t@ arg3, cvar_t@ arg4)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
	
	GiveRandomItems(ply, ActorItemQuality::Common, arg0.GetInt());
	GiveRandomItems(ply, ActorItemQuality::Uncommon, arg1.GetInt());
	GiveRandomItems(ply, ActorItemQuality::Rare, arg2.GetInt());
	GiveRandomItems(ply, ActorItemQuality::Epic, arg3.GetInt());
	GiveRandomItems(ply, ActorItemQuality::Legendary, arg4.GetInt());

	ply.RefreshModifiers();
}

void GiveDrinksCFunc(cvar_t@ arg0, cvar_t@ arg1, cvar_t@ arg2, cvar_t@ arg3, cvar_t@ arg4)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
	
	for (int i = 0; i < arg0.GetInt(); i++)
		GiveTavernBarrelImpl(GetTavernDrink(ActorItemQuality::Common), ply, false);
		
	for (int i = 0; i < arg1.GetInt(); i++)
		GiveTavernBarrelImpl(GetTavernDrink(ActorItemQuality::Uncommon), ply, false);
		
	for (int i = 0; i < arg2.GetInt(); i++)
		GiveTavernBarrelImpl(GetTavernDrink(ActorItemQuality::Rare), ply, false);
	
	for (int i = 0; i < arg3.GetInt(); i++)
		GiveTavernBarrelImpl(GetTavernDrink(ActorItemQuality::Rare), ply, false);
	
	for (int i = 0; i < arg4.GetInt(); i++)
		GiveTavernBarrelImpl(GetTavernDrink(ActorItemQuality::Legendary), ply, false);
}

void GiveItemCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
	
	auto item = g_items.TakeItem(arg0.GetString());
	if (item is null)
	{
		print("No item '" + arg0.GetString() + "' found");
		return;
	}
	
	ply.AddItem(item);
	ply.RefreshModifiers();
}

void TakeItemCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayerRecord();
	if (ply is null)
		return;

	int index = ply.items.find(arg0.GetString());
	if (index == -1)
	{
		PrintError("Item not in inventory.");
		return;
	}

	auto item = g_items.GetItem(arg0.GetString());
	item.inUse = false;

	ply.items.removeAt(index);
	cast<Player>(ply.actor).RefreshModifiers();
}

void GiveDrinkCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
	
	auto drink = GetTavernDrink(HashString(arg0.GetString()));
	if (drink is null)
	{
		print("No drink '" + arg0.GetString() + "' found");
		return;
	}
	
	ply.AddDrink(drink);
	ply.RefreshModifiers();
}


void ClearItemsCfunc()
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.m_record.items.removeRange(0, ply.m_record.items.length());
	ply.RefreshModifiers();
}

void ClearMtBlocksCfunc()
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.m_record.mtBlocks = 0;
}

void GiveComboCfunc()
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	if (ply.m_comboCount < 10)
		ply.m_comboCount = 10;
	ply.m_comboTime = 2000;
}

void NextLevelCfunc()
{
	if (!Network::IsServer())
		return;

	auto script = WorldScript::LevelExitNext();
	script.ServerExecute();
}

void UnlockMercCfunc()
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.m_record.mercenaryLocked = false;
	print("Unlocked Mercenary - Cheat");
}

void GiveTitleCFunc(cvar_t@ arg0)
{
	auto record = GetLocalPlayerRecord();

	// Give it, triggering notification if higher than current
	record.GiveTitle(arg0.GetInt());

	// Force set it afterwards anyway, in case it's lower than current
	record.titleIndex = arg0.GetInt();
}

void GiveExperienceCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
		
	ply.m_record.GiveExperience(arg0.GetInt());
}

void GiveHealthCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
		
	ply.Damage(DamageInfo(0, ply, arg0.GetInt(), false, true, 0), vec2(), vec2());
}

void GiveManaCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.GiveMana(arg0.GetInt());
}

void GiveArmorCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
		
	ply.GiveArmor(arg0.GetInt(), null, false);
}

void GiveKeyCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.m_record.keys[arg0.GetInt()] += 1;
}

void GiveCurseCFunc(cvar_t@ arg0)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	ply.m_record.GiveCurse(arg0.GetInt());
}

void LevelupCFunc(cvar_t@ arg0)
{
	auto record = GetLocalPlayerRecord();
	int levels = arg0.GetInt();

	for (int i = 0; i < levels; i++)
	{
		int level = record.level;
		int64 xp = record.LevelExperience(level) - record.LevelExperience(level - 1);
		record.GiveExperience(xp);
	}
}

void SetNgpCFunc(cvar_t@ arg0)
{
	g_ngp = arg0.GetInt();
}

void SetStatCFunc(cvar_t@ arg0, cvar_t@ arg1)
{
	auto record = GetLocalPlayerRecord();

	auto statRecord = record.statistics.GetStat(arg0.GetString());
	if (statRecord !is null)
		statRecord.m_valueInt = arg1.GetInt();

	auto statSession = record.statisticsSession.GetStat(arg0.GetString());
	if (statSession !is null)
		statSession.m_valueInt = arg1.GetInt();
}

void SetCharNgpCFunc(cvar_t@ arg0, cvar_t@ arg1)
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;

	auto dungeonId = arg0.GetString();
	auto dungeon = DungeonProperties::Get(dungeonId);
	if (dungeon is null)
	{
		PrintError("Unable to find dungeon with ID \"" + dungeonId + "\"!");
		return;
	}

	auto ngp = ply.m_record.ngps.Get(dungeon.m_idHash, true);
	ngp.m_ngp = arg1.GetInt();
	ngp.m_presented = ngp.m_ngp;

	auto gm = cast<Campaign>(g_gameMode);
	auto town = gm.m_townLocal;
	auto highestNgp = town.m_highestNgps.Get(dungeon.m_idHash, true);
	if (ngp.m_ngp > highestNgp.m_ngp)
		highestNgp.SetBoth(ngp.m_ngp);
}

void SetCharGladiatorCFunc(cvar_t@ arg0)
{
	GetLocalPlayerRecord().gladiatorPoints = arg0.GetInt();
}

void KillCFunc()
{
	auto ply = GetLocalPlayer();
	if (ply is null)
		return;
		
	ply.Kill(null, 0);
}

void KillAllCFunc()
{
	auto enemies = g_scene.FetchAllActorsWithOtherTeam(g_team_player);

	for (uint i = 0; i < enemies.length(); i++)
	{
		Actor@ a = cast<Actor>(enemies[i].GetScriptBehavior());
		if (a.IsTargetable())
			a.Kill(null, 0);
	}
}

void ReviveCFunc()
{
	auto record = GetLocalPlayerRecord();
	if (record is null)
		return;

	record.corpse.NetRevive(record);
}

void ListEnemiesCFunc()
{
	auto enemies = g_scene.FetchAllActorsWithOtherTeam(g_team_player);

	for (uint i = 0; i < enemies.length(); i++)
	{
		print(enemies[i].GetDebugName());
	}
}

void ListModifiersEx(Modifiers::ModifierList@ list, int indentSize = 1)
{
	string indent = "";
	for (int i = 0; i < indentSize; i++)
		indent += "  ";

	for (uint i = 0; i < list.m_modifiers.length(); i++)
	{
		auto mod = list.m_modifiers[i];
		auto modList = cast<Modifiers::ModifierList>(mod);

		if (modList !is null)
		{
			print(indent + modList.m_name + ":");
			ListModifiersEx(modList, indentSize + 1);
		}
		else
		{
			if (mod.m_cloned > 0)
				print(indent + Reflect::GetTypeName(mod) + " (clone " + mod.m_cloned + ")");
			else
				print(indent + Reflect::GetTypeName(mod));
		}
	}
}

void ListModifiersCFunc()
{
	print("Dumping all modifiers:");
	ListModifiersEx(g_allModifiers);
}

void GiveBlueprintCFunc(cvar_t@ arg0)
{
	string id = arg0.GetString();

	auto item = g_items.GetItem(id);
	if (item is null)
		return;

	GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);
}

void GiveStatueCFunc(cvar_t@ arg0, cvar_t@ arg1)
{
	string id = arg0.GetString();
	int level = arg1.GetInt();

	auto gm = cast<Campaign>(g_gameMode);
	gm.m_townLocal.GiveStatue(id, level);
}

void GiveStatueBlueprintCFunc(cvar_t@ arg0)
{
	string id = arg0.GetString();

	// Ensure that the statue level 0 is unlocked in town
	auto gm = cast<Campaign>(g_gameMode);
	gm.m_townLocal.GiveStatue(id, 0);

	// Get the statue and add a blueprint
	auto statue = gm.m_townLocal.GetStatue(id);
	statue.m_blueprint++;
}

void SetTrailCFunc(cvar_t@ arg0)
{
	auto record = GetLocalPlayerRecord();
	record.currentTrail = HashString(arg0.GetString());

	auto player = GetLocalPlayer();
	if (player !is null)
		player.LoadTrail();
}

void SetFrameCFunc(cvar_t@ arg0)
{
	string id = arg0.GetString();
	auto frame = PlayerFrame::Get(id);
	if (frame is null)
	{
		PrintError("Unable to find frame with ID \"" + id + "\"");
		return;
	}

	auto record = GetLocalPlayerRecord();
	record.currentFrame = frame.m_idHash;
}

void SetComboCFunc(cvar_t@ arg0)
{
	string id = arg0.GetString();
	auto style = PlayerComboStyle::Get(id);
	if (style is null)
	{
		PrintError("Unable to find combo style with ID \"" + id + "\"");
		return;
	}

	auto record = GetLocalPlayerRecord();
	record.currentComboStyle = style.m_idHash;
}

void SetGravestoneCFunc(cvar_t@ arg0)
{
	string id = arg0.GetString();
	auto gravestone = PlayerCorpseGravestone::Get(id);
	if (gravestone is null)
	{
		PrintError("Unable to find gravestone with ID \"" + id + "\"");
		return;
	}

	auto record = GetLocalPlayerRecord();
	record.currentCorpse = gravestone.m_idHash;
}

void GiveInsuranceCFunc(cvar_t@ arg0)
{
	string campaignId = arg0.GetString();
	if (DungeonProperties::Get(campaignId) is null)
	{
		PrintError("Unable to find dungeon with ID '" + campaignId + "'");
		return;
	}

	auto record = GetLocalPlayerRecord();
	record.GiveInsurance(campaignId);
}

void SetFlagCFunc(cvar_t@ arg0, cvar_t@ arg1, cvar_t@ arg2)
{
	string flag = arg0.GetString();
	bool value = arg1.GetBool();
	bool persistent = arg2.GetBool();

	if (!value)
		g_flags.Delete(flag);
	else
		g_flags.Set(flag, persistent ? FlagState::Run : FlagState::Level);

	(Network::Message("SyncFlag") << flag << value << persistent).SendToAll();
}

void SetTownFlagCFunc(cvar_t@ arg0, cvar_t@ arg1)
{
	string flag = arg0.GetString();
	bool value = arg1.GetBool();

	if (!value)
		g_flags.Delete(flag);
	else
		g_flags.Set(flag, FlagState::Town);
}

void GiveGoldCFunc(cvar_t@ arg0)
{
	int amount = arg0.GetInt();
	Currency::Give(amount);
}

void GiveOreCFunc(cvar_t@ arg0)
{
	int amount = arg0.GetInt();
	Currency::Give(0, amount);
}

void GiveLegacyCFunc(cvar_t@ arg0)
{
	int amount = arg0.GetInt();
	auto gm = cast<Campaign>(g_gameMode);
	gm.m_townLocal.m_legacyPoints += amount;
}
