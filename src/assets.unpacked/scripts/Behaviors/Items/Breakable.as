class Breakable : IDamageTaker
{
	UnitPtr m_unit;

	bool m_alwaysHitGore;

	SoundEvent@ m_hitSound;
	UnitScene@ m_hitEffect;
	SoundEvent@ m_switchSound;
	UnitScene@ m_switchEffect;
	SoundEvent@ m_breakSound;
	UnitScene@ m_breakEffect;

	int m_effectsDelay;
	int m_effectsDelayC;
	string m_effectsDelayScene;
	CustomUnitScene@ m_effectsDelaySceneC;

	int m_delayedDmg;
	vec2 m_delayedPos;
	vec2 m_delayedDir;
	Actor@ m_delayedAttacker;

	array<IEffect@>@ m_effects;
	GoreSpawner@ m_gore;
	UnitProducer@ m_corpse;
	LootDef@ m_lootDef;

	bool m_sceneSwitching;
	bool m_sceneSwitchingPass;
	bool m_impenetrable;
	bool m_shootThrough;
	bool m_walkThrough;

	UnitScene@ m_stillScene;
	UnitScene@ m_collideAnimScene;
	UnitScene@ m_windAnimScene;

	int m_timeToSceneBack;
	bool m_useRegularAnims;
	int m_timeToAnim;
	int m_timeOffset;

	int m_health = -1;
	float m_mpScaleFact;

	float m_dmgColor = 0.0;
	bool m_showDmgColor;

	Breakable(UnitPtr unit, SValue& params)
	{
		m_unit = unit;

		m_alwaysHitGore = GetParamBool(unit, params, "always-hit-gore", false, false);
		
		@m_hitSound = Resources::GetSoundEvent(GetParamString(unit, params, "hit-sound", false));
		@m_hitEffect = Resources::GetEffect(GetParamString(unit, params, "hit-effect", false));
		
		@m_switchSound = Resources::GetSoundEvent(GetParamString(unit, params, "switch-sound", false));
		@m_switchEffect = Resources::GetEffect(GetParamString(unit, params, "switch-effect", false));

		if (m_switchSound is null)
			@m_switchSound = m_hitSound;
		if (m_switchEffect is null)
			@m_switchEffect = m_hitEffect;


		@m_breakSound = Resources::GetSoundEvent(GetParamString(unit, params, "break-sound", false));
		@m_breakEffect = Resources::GetEffect(GetParamString(unit, params, "break-effect", false));
		
		@m_lootDef = LoadLootDef(GetParamString(unit, params, "loot", false));
		@m_gore = LoadGore(GetParamString(unit, params, "gore", false));
		
		m_effectsDelay = GetParamInt(unit, params, "effectsdelay", false);
		int delayRandomMax = GetParamInt(unit, params, "effectsdelay-random", false);
		if (delayRandomMax > 0)
			m_effectsDelay += randi(delayRandomMax);
		m_effectsDelayScene = GetParamString(unit, params, "effectsdelay-scene", false);
		@m_effectsDelaySceneC = CustomUnitScene();

		@m_corpse = Resources::GetUnitProducer(GetParamString(unit, params, "corpse", false));
		@m_effects = LoadEffects(unit, params);
		
		m_sceneSwitching = GetParamBool(unit, params, "scene-switching", false, false);
		m_sceneSwitchingPass = GetParamBool(unit, params, "scene-switching-passthrough", false, false);
		
		m_impenetrable = GetParamBool(unit, params, "impenetrable", false, false);
		m_walkThrough = GetParamBool(unit, params, "walk-through", false, false);
		m_shootThrough = GetParamBool(unit, params, "shoot-through", false, false);

		@m_stillScene = m_unit.GetCurrentUnitScene();

		string suffixCollideAnim = GetParamString(unit, params, "collide-anim-suffix", false);
		if (suffixCollideAnim != "")
			@m_collideAnimScene = m_unit.GetUnitScene(m_stillScene.GetName() + suffixCollideAnim);

		string suffixWindAnim = GetParamString(unit, params, "wind-anim-suffix", false);
		if (suffixWindAnim != "")
			@m_windAnimScene = m_unit.GetUnitScene(m_stillScene.GetName() + suffixWindAnim);

		m_useRegularAnims = GetParamBool(unit, params, "regular-anims", false, true);

		m_showDmgColor = GetParamBool(unit, params, "show-dmg-color", false, true);
		
		m_mpScaleFact = GetParamFloat(unit, params, "mp-scale-fact", false, 0);
		

		m_timeToSceneBack = -1;
		m_timeToAnim = 2500 + randi(10000);
		m_timeOffset = randi(33) - int(m_unit.GetPosition().x * 1.5);

		ResetHealth();
		
		m_unit.SetUpdateDistanceLimit(300);
	}

	void ResetHealth()
	{
		auto svHealth = m_unit.FetchData("health");
		if (svHealth !is null)
			m_health = svHealth.GetInteger();
		else
			m_health = 1;
	}

	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override
	{
		if (!m_shootThrough)
			return false;

		if ((attacker is null && Network::IsServer()) || (attacker !is null && !attacker.IsHusk()))
		{
			UnitHandler::NetSendUnitDamaged(m_unit, 1, pos, dir, attacker);
			DamageEffects(1, pos, dir, null);
		}

		return true;
	}
	
	int TransformDmg(int dmg)
	{
		return max(1, int(dmg / (1.0f + g_mpEnemyHealthScale * m_mpScaleFact)));
	}

	int DamageEffects(int dmg, vec2 pos, vec2 dir, Actor@ attacker)
	{
		if (!m_unit.IsValid() || m_unit.IsDestroyed() || m_unit.GetPhysicsBody() is null)
			return 0;

		if (m_health != -1)
		{
			m_health -= TransformDmg(dmg);
			if (m_health > 0)
			{
				PlaySound3D(m_hitSound, m_unit.GetPosition());
				PlayEffect(m_hitEffect, xy(m_unit.GetPosition()));

				if (m_alwaysHitGore)
				{				
					if (m_gore !is null)
						m_gore.OnHit(dmg / 100.0, xy(m_unit.GetPosition()), atan(dir.y, dir.x));
				}	
				return dmg;
			}
		}

		UnitScene@ nextScene = null;
		UnitScene@ currScene = m_unit.GetCurrentUnitScene();
		
		if (m_sceneSwitching)
		{
			do
			{
				string sceneName = currScene.GetName();
				int idx = sceneName.findLast("-");
				if (idx != -1)
				{
					idx += 1;

					int id = parseInt(sceneName.substr(idx));
					@nextScene = m_unit.GetUnitScene(sceneName.substr(0, idx) + (id + 1));
					@currScene = nextScene;
				}

				if (currScene is null)
					break;

				if (m_sceneSwitchingPass)
				{
					auto svHealth = currScene.FetchData("health");
					if (svHealth !is null)
					{
						m_health += svHealth.GetInteger();
						if (m_health < 0)
							m_unit.SetUnitScene(nextScene, true);
					}
					else
						break;
				}
			} while (m_sceneSwitchingPass && m_health < 0);
		}
		if (nextScene !is null)
		{
			PlaySound3D(m_switchSound, m_unit.GetPosition());
			PlayEffect(m_switchEffect, xy(m_unit.GetPosition()));
		
			@m_stillScene = nextScene;
			m_unit.SetUnitScene(nextScene, true);
			ResetHealth();

			if (m_gore !is null)
				m_gore.OnHit(dmg / 100.0, xy(m_unit.GetPosition()), atan(dir.y, dir.x));

			return dmg;
		}
		else
		{
			PlaySound3D(m_breakSound, m_unit.GetPosition());
			PlayEffect(m_breakEffect, xy(m_unit.GetPosition()));
			
			if (m_gore !is null)
				m_gore.OnDeath(dmg / 100.0, xy(m_unit.GetPosition()), atan(dir.y, dir.x));

			bool netsynced = IsNetsyncedExistance(m_unit.GetUnitProducer().GetNetSyncMode());
			if (!netsynced || Network::IsServer())
				m_unit.Destroy();

			ApplyEffects(m_effects, attacker, m_unit, pos, dir, 1.0, !Network::IsServer());

			bool netsyncedCorpse = m_corpse !is null && IsNetsyncedExistance(m_corpse.GetNetSyncMode());
			if (Network::IsServer())
			{
				if (m_lootDef !is null)
					m_lootDef.Spawn(xy(m_unit.GetPosition()));
					
				if (m_corpse !is null)
					m_corpse.Produce(g_scene, m_unit.GetPosition());
			}
			else if (!netsyncedCorpse && m_corpse !is null)
				m_corpse.Produce(g_scene, m_unit.GetPosition());
			
			@m_corpse = null;
		}

		return dmg;
	}

	void NetDecimate(int hp, int mana) override {}
	int Decimate(DecimateInfo dec, vec2 pos, vec2 dir) override { return 0; }
	
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		m_unit.SetUpdateDistanceLimit(0);

		if (m_showDmgColor)
			m_dmgColor = 1.0;

		dmg.Damage = max(dmg.Damage, dmg.PhysicalDamage + dmg.MagicalDamage);

		if (m_effectsDelay == 0 || m_health - dmg.Damage > 0)
		{
			UnitHandler::NetSendUnitDamaged(m_unit, int(dmg.Damage), pos, dir, dmg.Attacker);
			return DamageEffects(dmg.Damage, pos, dir, dmg.Attacker);
		}
		if (m_effectsDelayC > 0)
			return dmg.Damage;

		m_effectsDelayC = m_effectsDelay;
		m_delayedDmg = dmg.Damage;
		m_delayedPos = pos;
		m_delayedDir = dir;
		@m_delayedAttacker = dmg.Attacker;

		m_effectsDelaySceneC.AddScene(m_unit.GetCurrentUnitScene(), 0, vec2(), 0, 0);
		m_effectsDelaySceneC.AddScene(m_unit.GetUnitScene(m_effectsDelayScene), 0, vec2(), 0, 0);
		m_unit.SetUnitScene(m_effectsDelaySceneC, true);

		return dmg.Damage;
	}

	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override
	{
		if (m_showDmgColor)
			m_dmgColor = 1.0;

		DamageEffects(dmg.Damage, pos, dir, dmg.Attacker);
	}

	void Collide(UnitPtr unit, vec2 pos, vec2 normal)
	{
		Actor@ a = cast<Actor>(unit.GetScriptBehavior());
		if (m_collideAnimScene !is null && a !is null)
			PlayAnim(m_collideAnimScene);

		if (!m_walkThrough)
			return;
	
		if (a !is null)
		{
			UnitHandler::NetSendUnitDamaged(m_unit, 1, pos, normal, null);
			DamageEffects(1, pos, normal, a);
		}
	}

	bool Impenetrable() override { return m_impenetrable; }

	bool IsDead() override
	{
		return !m_unit.IsValid();
	}

	void Update(int dt)
	{
		if (m_dmgColor > 0)
			m_dmgColor -= dt / 100.0;

		if (!m_unit.IsValid())
			return;

		if (m_effectsDelayC > 0)
		{
			m_effectsDelayC -= dt;
			if (m_effectsDelayC <= 0)
			{
				UnitHandler::NetSendUnitDamaged(m_unit, m_delayedDmg, m_delayedPos, m_delayedDir, m_delayedAttacker);
				DamageEffects(m_delayedDmg, m_delayedPos, m_delayedDir, m_delayedAttacker);
			}
		}

		if (m_unit.IsDestroyed())
			return;

		if (m_windAnimScene !is null)
		{
			uint t = (g_scene.GetTime() + m_timeOffset) % 15000;
			if (t + dt > 15000)
				PlayAnim(m_windAnimScene);
		}

		if (m_timeToSceneBack > 0)
		{
			m_timeToSceneBack -= dt;
			if (m_timeToSceneBack <= 0)
			{
				m_unit.SetUnitScene(m_stillScene, true);
				m_timeToSceneBack = -1;
				m_timeToAnim = 2500 + randi(10000);
			}
		}

		if (m_useRegularAnims and m_timeToAnim > 0)
		{
			m_timeToAnim -= dt;
			if (m_timeToAnim <= 0)
				PlayAnim(m_windAnimScene);
		}
	}

	void PlayAnim(UnitScene@ scene)
	{
		if (scene is null or m_timeToSceneBack > 0 or !m_unit.IsValid() or m_unit.IsDestroyed())
			return;

		if (m_unit.GetCurrentUnitScene() !is scene)
			m_unit.SetUnitScene(scene, true);

		m_timeToSceneBack = scene.Length();
		m_timeToAnim = -1;
	}
/*
	vec4 GetOverlayColor()
	{
		return vec4(1, 1, 1, 0.5 * m_dmgColor);
	}
*/
	bool Ricochets() override { return false; }
}
