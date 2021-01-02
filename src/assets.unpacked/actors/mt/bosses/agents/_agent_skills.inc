			%// Sword
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>enable_sword</string>
				</array>

				<string name="anim">sword 8</string>
				<string name="start-snd">event:/enemy/boss_agents/sword</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">50</int>
				<int name="castpoint">450</int>
				<int name="range">26</int>
				<int name="min-range">0</int>
				<bool name="good-aim">false</bool>
				<string name="offset">sword-pos</string>

				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">AGENTPATH/sword_impact.effect</string>
						<int name="min-radius">10</int>
						<int name="radius">10</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">75</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
							<dict>
								<string name="class">ApplyBuff</string>
								<string name="buff">actors/mt/bosses/agents/buffs.sval:SWORDBUFF</string>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_agents/sword-hit</string>
					</dict>
					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">true</bool>
						<string name="flag">SPINSKILLTOGGLE</string>
					</dict>
				</array>
			</dict>
	

			%// Whirlwind
%if AGENT_BLAZE || AGENT_DECAY
			<dict>
				<string name="class">WhirlwindSkill</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>enable_whirl</string>
					
					<!-- <string>flag</string><string>is</string><string>SPINSKILLTOGGLE</string> -->
					<string>flag</string><string>isnt</string><string>night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>

				<string name="anim">spin</string>
				<string name="snd">event:/enemy/boss_warden/attack-spin</string>
				<!-- <int name="cooldown-start">5000</int> -->
				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">800</int>
				<int name="range">WHIRLRANGE</int>
				<int name="min-range">0</int>
				<float name="acceleration">WHIRLACC</float>
				<float name="speed">WHIRLSPEED</float>
				<float name="turnspeed">WHIRLTURNSPEED</float>
				<int name="duration">WHIRLDUR</int>
				<int name="freq">240</int>

				<array name="effects">
					<dict>
						<string name="class">Explode</string>
						<int name="radius">16</int>
						<float name="dist-scaling">1000</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">75</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
							<dict>
								<string name="class">SpawnEffect</string>
								<string name="effect">AGENTPATH/sword_impact.effect</string>
							</dict>
							<dict>
								<string name="class">ApplyBuff</string>
								<string name="buff">actors/mt/bosses/agents/buffs.sval:SWORDBUFF</string>
							</dict>
							<dict>
								<string name="class">PlaySound</string>
								<string name="sound">event:/enemy/boss_agents/twirl-hit</string>
							</dict>
						</array>
					</dict>

					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">false</bool>
						<string name="flag">SPINSKILLTOGGLE</string>
					</dict>
				</array>
			</dict>
%endif


%if AGENT_RIME || AGENT_STAR
			%// Charge
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>enable_charge</string>
					
					<string>flag</string><string>isnt</string><string>night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>

				<string name="class">ChargeStrike</string>
				<string name="anim">charge 8</string>
				<string name="snd">event:/enemy/boss_agents/charge</string>				
				<string name="anim-stop">walk 8</string>
				<bool name="must-see">true</bool>
				<int name="cooldown">CHARGECD</int>
				<int name="hold-frame">100</int>
				<int name="min-range">40</int>
				<int name="range">CHARGERANGE</int>
				<float name="speed">CHARGESPEED</float>
				<int name="air-time">CHARGETIME</int>
				<int name="jump-height">0</int>
				<int name="ray-num">3</int>
				<int name="ray-width">12</int>
				<float name="ray-length">3</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">90</int>
						<float name="armor-mul">0.8</float>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">AGENTPATH/sword_impact.effect</string>
					</dict>
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/mt/bosses/agents/buffs.sval:SWORDBUFF</string>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_agents/charge-hit</string>
					</dict>					
				</array>
				<array name="finish-effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/mt/bosses/agents/buffs.sval:think</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
%endif

			%// Shoot
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>enable_shoot</string>

					<string>flag</string><string>isnt</string><string>night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_beam</string>
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>

				%if !AGENT_RIME || AGENT_BLAZE
				<string name="class">CompositeActorSkill</string>
				%endif
				%if AGENT_RIME || AGENT_BLAZE
				<string name="class">CompositeActorBurstSkill</string>
				<int name="burst">SHOOTBURST</int>
				%endif
				<string name="anim">shoot 8</string>
				%if AGENT_STAR
				<string name="start-snd">event:/enemy/boss_agents/shoot_star</string>
				%endif
				%if AGENT_BLAZE
				<string name="start-snd">event:/enemy/boss_agents/shoot_blaze</string>
				%endif
				%if AGENT_RIME
				<string name="snd">event:/enemy/boss_agents/shoot_rime</string>
				%endif
				%if AGENT_DECAY
				<string name="snd">event:/enemy/boss_agents/shoot_decay</string>
				%endif

				<int name="cooldown-start">250</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">300</int>
				<int name="range">SHOOTRANGE</int>
				<int name="min-range">SHOOTMINRANGE</int>
				<bool name="must-see">true</bool>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				<string name="offset">shoot-pos</string>

				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
					%if AGENT_BLAZE
						<string name="projectile">actors/mt/bosses/agents/agent_blaze/fireball.unit</string>
					%elif AGENT_DECAY
						<string name="projectile">actors/mt/bosses/agents/agent_decay/rottenpart.unit</string>
					%elif AGENT_RIME
						<string name="projectile">actors/mt/bosses/agents/agent_rime/spear.unit</string>
					%elif AGENT_STAR
						<string name="projectile">actors/mt/bosses/agents/agent_star/starprojectile.unit</string>
					%endif
						<int name="projectiles">SHOOTPROJECTILES</int>
						<int name="spread">SHOOTSPREAD</int>
					</dict>
				</array>
			</dict>
						
			
			%//Shoot Night Power
			<dict>
				%if !AGENT_RIME || AGENT_BLAZE
				<string name="class">CompositeActorSkill</string>
				%endif
				%if AGENT_RIME || AGENT_BLAZE
				<string name="class">CompositeActorBurstSkill</string>
				<int name="burst">SHOOTNIGHTBURST</int>
				%endif
				<array name="conditional">
					<string>flag</string><string>is</string><string>enable_shoot</string>
					
					<string>buff</string><string>has</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>
				<string name="anim">shoot_night 8</string>
				%if AGENT_STAR
				<string name="start-snd">event:/enemy/boss_agents/shoot_star-night</string>
				%endif
				%if AGENT_BLAZE
				<string name="start-snd">event:/enemy/boss_agents/shoot_blaze-night</string>
				%endif
				%if AGENT_RIME
				<string name="snd">event:/enemy/boss_agents/shoot_rime</string>
				%endif
				%if AGENT_DECAY
				<string name="snd">event:/enemy/boss_agents/shoot_decay</string>
				%endif

				<int name="castpoint">300</int>
				<int name="cooldown">SHOOTNIGHTCD</int>
				<int name="range">300</int>
				<int name="min-range">SHOOTMINRANGE</int>
				<bool name="must-see">true</bool>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				<string name="offset">shoot-pos</string>

				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
					%if AGENT_BLAZE
						<string name="projectile">actors/mt/bosses/agents/agent_blaze/fireball_night.unit</string>
					%elif AGENT_DECAY
						<string name="projectile">actors/mt/bosses/agents/agent_decay/rottenpart_night.unit</string>
					%elif AGENT_RIME
						<string name="projectile">actors/mt/bosses/agents/agent_rime/spear_night.unit</string>
					%elif AGENT_STAR
						<string name="projectile">actors/mt/bosses/agents/agent_star/starprojectile_night.unit</string>
					%endif
						<int name="projectiles">SHOOTNIGHTPROJECTILES</int>
						<int name="spread">SHOOTNIGHTSPREAD</int>
					</dict>
				</array>
			</dict>
			
			
			%// Potion Immortality (all agents)
			<dict>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.7</float>
					<string>hp</string><string>gt</string><float>0.3</float>
					%if AGENT_STAR
					<string>flag</string><string>is</string><string>potion_star_immortal</string>
					%endif
					%if AGENT_BLAZE
					<string>flag</string><string>is</string><string>potion_blaze_immortal</string>
					%endif
					%if AGENT_RIME
					<string>flag</string><string>is</string><string>potion_rime_immortal</string>
					%endif
					%if AGENT_DECAY
					<string>flag</string><string>is</string><string>potion_decay_immortal</string>
					%endif
				</array>

				<string name="class">CompositeActorSkill</string>
				<int name="charges">IMMORTALITYPOTIONS</int>
				<string name="anim">potion</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">45000</int>
				<int name="castpoint">0</int>
				<bool name="must-see">false</bool>
				<int name="min-range">0</int>
				<int name="range">150</int>

				<array name="start-actions">
					<dict>
						<string name="class">RaiseUnitEvent</string>
						<string name="name">potionImmortal</string>
					</dict>
				</array>
			</dict>
			
			
			%// Potion Ointment (all agents)
			<dict>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.15</float>
					%if AGENT_STAR
					<string>flag</string><string>is</string><string>potion_star_hp</string>
					%endif
					%if AGENT_BLAZE
					<string>flag</string><string>is</string><string>potion_blaze_hp</string>
					%endif
					%if AGENT_RIME
					<string>flag</string><string>is</string><string>potion_rime_hp</string>
					%endif
					%if AGENT_DECAY
					<string>flag</string><string>is</string><string>potion_decay_hp</string>
					%endif
				</array>

				<string name="class">CompositeActorSkill</string>
				<int name="charges">HEALTHPOTIONS</int>
				<string name="anim">potion</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<bool name="must-see">false</bool>
				<int name="min-range">0</int>
				<int name="range">150</int>

				<array name="start-actions">
					<dict>
						<string name="class">RaiseUnitEvent</string>
						<string name="name">potionHP</string>
					</dict>
				</array>
			</dict>
			
			%// Potion Domain (end agent)
<!-- 			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.5</float>
					%if AGENT_STAR
					<string>flag</string><string>is</string><string>potion_star_domain</string>
					%endif
					%if AGENT_BLAZE
					<string>flag</string><string>is</string><string>potion_blaze_domain</string>
					%endif
					%if AGENT_RIME
					<string>flag</string><string>is</string><string>potion_rime_domain</string>
					%endif
					%if AGENT_DECAY
					<string>flag</string><string>is</string><string>potion_decay_domain</string>
					%endif
				</array>
				<int name="charges">0</int>
				<string name="anim">potion</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<bool name="must-see">false</bool>
				<int name="min-range">0</int>
				<int name="range">150</int>
				<array name="start-actions">
					<dict>
						<string name="class">RaiseUnitEvent</string>
						<string name="name">domain</string>
					</dict>
				</array>
				<array name="actions">
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">domain</string>
					</dict>
				</array>
			</dict> -->
			
			%// Death
			<dict>
				<array name="conditional">
					<string>buff</string><string>hasnt</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>

				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">AGENTPATH/death.effect</string>
					</dict>
					<dict>
						<string name="class">SpawnPrefab</string>
						<string name="prefab">AGENTPATH/deatharea.pfb</string>
						<bool name="safe-spawn">false</bool>
					</dict>
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">AGENTPATH/death.effect</string>
					</dict>
				</array>
			</dict>
			
			
			%// Death Night Power
			<dict>
				<array name="conditional">
					<string>buff</string><string>has</string><string>actors/mt/bosses/agents/buffs.sval:night_power</string>
				</array>

				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/mt/bosses/agents/death.effect</string>
					</dict>
					<dict>
						<string name="class">SpawnPrefab</string>
						<string name="prefab">actors/mt/bosses/agents/deatharea.pfb</string>
						<bool name="safe-spawn">false</bool>
					</dict>
				</array>
			</dict>			