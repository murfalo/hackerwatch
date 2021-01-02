<unit slot="actor" netsync="position">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bosses.wolf_boss</string>
%else
		<string name="beastiary-override">actors/mt/bosses/wolf/wolf_boss.unit</string>
%endif
		<vec2 name="beastiary-offset">10 -10</vec2>
		<string name="quality">epic</string>
		<string name="dlc">mt</string>
	
		<string name="type">beast</string>
		<int name="hp">12000</int>
		<int name="armor">80</int>
		<int name="resistance">50</int>
		<int name="experience-reward">4000</int>
		<float name="mp-scale-fact">1.25</float>
		<float name="ngp-scale">1.5</float>

		<string name="death-snd">event:/enemy/boss_wolf/death</string>
		<string name="loot">actors/loot.sval:boss_wolf</string>

		<int name="aggro-range">1000</int>
		<float name="debuff-scale">0.5</float>
		<float name="wind-scale">0</float>
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">999</int>

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_boss.inc"
		</array>
		
		<dict name="movement">
			<string name="class">ChargeMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<bool name="search-while-breaking">false</bool>
			<bool name="stop-when-casting">true</bool>

			<float name="speed">CHARGESPEED</float>
			<float name="turnspeed">TURNSPEED</float>

			<int name="acceleration-timer">1200</int>
			<int name="deceleration-timer">400</int>
			<float name="crashangle">1</float>
			<int name="wait-after-lost">500</int>
			<int name="wait-sight-time">1000</int>
			<int name="sight-arc">180</int>
			<int name="time-limit">4500</int>
		</dict>
		
 		<array name="skills">
			<dict>
				<string name="class">ConstantSoundSkill</string>
				<bool name="only-walking">true</bool>
				<string name="sound">event:/enemy/boss_wolf/run</string>
			</dict>
			<dict>
				<array name="conditional">
					<string>charging</string><bool>true</bool>
				</array>

				<string name="class">WerebullChargeHitSkill</string>
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">60</int>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/item/skullsmasher</string>
					</dict>
				</array>
			</dict>
			
			%// Howl
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>howl</string>
					<string>charging</string><bool>false</bool>
				</array>
				
				<string name="class">CompositeActorSkill</string>
				<string name="anim">howl</string>
				<string name="snd">event:/enemy/boss_wolf/howl</string>
				
				<int name="charges">3</int>
				<int name="cooldown-start">1000</int>
				<int name="cooldown">32000</int>
				<int name="castpoint">750</int>
				<int name="range">999</int>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">howl</string>
					</dict>
				</array>
			</dict>	
			
			%// Groundspikes
			<dict>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.6</float>
					<string>charging</string><bool>false</bool>
				</array>
			
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">groundslam 8</string>
				<string name="start-snd">event:/enemy/boss_wolf/stomp</string>
				<string name="offset">groundslam-pos</string>

				<int name="burst">GSPIKESBURST</int>

				<int name="cooldown">GSPIKESCD</int>
				<int name="castpoint">1100</int>
				<int name="range">500</int>
				<bool name="good-aim">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/ice_troll_club_hit.effect</string>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_worm/stone_big_impact</string>
					</dict>
					
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">GSPIKESNUM</int>
						<int name="spread">GSPIKESSPREAD</int>
						<int name="dist">30</int>
						<string name="projectile">actors/mt/bosses/wolf/foot_groundspikes.unit</string>
					</dict>
				</array>
			</dict>
			
			%// Breath
			<dict>				
				<array name="conditional">
					<string>charging</string><bool>false</bool>
				</array>
				
				<string name="class">SpewSkill</string>
				<string name="anim">breath 8</string>
				<string name="offset">attack-pos</string>
				<string name="first-fire-snd">event:/enemy/boss_wolf/breath</string>
				
				<bool name="must-see">false</bool>
				<bool name="hold-dir">true</bool>
				<bool name="good-aim">true</bool>
				<int name="cooldown">4000</int>
				<int name="castpoint">650</int>
				<int name="duration">700</int>
				
				<int name="range">80</int>
				<int name="min-range">50</int>
				
				<int name="spread">BREATHSPREAD</int>
				<int name="rate">BREATHRATE</int>

				<string name="projectile">actors/mt/bosses/wolf/frost_breath.unit</string>
			</dict>

			%// Short Jump
			<dict>
				<array name="conditional">
					<string>charging</string><bool>false</bool>
				</array>
			
				<string name="class">ChargeStrike</string>
				<string name="anim">jump 8</string>
				<string name="anim-stop">land 8</string>
				<string name="snd">event:/enemy/boss_wolf/jump</string>
				<string name="offset">attack-pos</string>
				
				<bool name="must-see">false</bool>
				<!-- <int name="cooldown-start">100</int> -->
				<int name="cooldown">SHORTJUMPCD</int>
				<int name="range">80</int>
				<!-- <int name="min-range">32</int> -->
				<float name="speed">4.5</float>
				<int name="air-time">600</int>
				<int name="hold-frame">200</int>
				<int name="jump-height">18</int>
				<bool name="good-aim">true</bool>
				
				<int name="ray-num">0</int>
				<int name="ray-width">1</int>
				<float name="ray-length">1</float>
				
				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<int name="min-radius">24</int>
						<int name="radius">24</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">120</int>
								<float name="armor-mul">0.7</float>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/ice_troll_club_hit.effect</string>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wolf/land</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEventRanged</string>
						<string name="name">raise_spikes</string>
						<int name="radius">80</int>
					</dict>
				</array>
			</dict>

			%// Bite
			<dict>
				<array name="conditional">
					<string>charging</string><bool>false</bool>
				</array>

				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">attack-pos</string>

				<int name="burst">3</int>
				<int name="cooldown">1750</int>
				<int name="castpoint">550</int>
				<int name="range">36</int>
				
				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<int name="min-radius">18</int>
						<int name="radius">18</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wolf/attack</string>
					</dict>
				</array>
			</dict>

			%// Running Jump
			<dict>
				<array name="conditional">
					<string>charging</string><bool>true</bool>
				</array>
			
				<string name="class">ChargeStrike</string>
				<string name="anim">jump 8</string>
				<string name="anim-stop">land 8</string>
				<string name="snd">event:/enemy/boss_wolf/jump</string>
				<string name="offset">attack-pos</string>
				
				<bool name="must-see">false</bool>
				<int name="cooldown-start">4000</int>
				<int name="cooldown">RUNNINGJUMPCD</int>
				<int name="range">140</int>
				<int name="min-range">80</int>
				<float name="speed">7</float>
				<int name="air-time">600</int>
				<int name="hold-frame">200</int>
				<int name="jump-height">18</int>
				<bool name="good-aim">true</bool>
				
				<int name="ray-num">0</int>
				<int name="ray-width">1</int>
				<float name="ray-length">1</float>
				
				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<int name="min-radius">24</int>
						<int name="radius">24</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">120</int>
								<float name="armor-mul">0.7</float>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/ice_troll_club_hit.effect</string>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wolf/land</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEventRanged</string>
						<string name="name">raise_spikes</string>
						<int name="radius">80</int>
					</dict>
				</array>
			</dict>

			%// Running Bite
			<dict>
				<array name="conditional">
					<string>charging</string><bool>true</bool>
				</array>

				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack-running 8</string>
				<string name="offset">attack-pos</string>

				<int name="cooldown-start">2000</int>
				<int name="cooldown">5000</int>
				<int name="castpoint">100</int>
				<int name="range">20</int>
				
				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<int name="min-radius">18</int>
						<int name="radius">18</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wolf/attack</string>
					</dict>
				</array>
			</dict>
			
			%// Death
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/wolf/wolf_boss_corpse.unit</string>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/wolf/wolf_boss_head.unit</string>
					</dict>
				</array>
			</dict>
		</array> 
		
		<dict name="effect-params"></dict>
	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			
			<collision static="false">
				<circle offset="0 0" radius="17" aim-through="true" charge-through="false" charging="false" density="20"/>
			</collision>
			<shadow>
				<sprite origin="16 16" texture="doodads/special/shadows.png">
					<frame>90 0 32 32</frame>
				</sprite>	
			</shadow>
		</scene>
		
		<scene name="shared-charge">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="false">
				<circle offset="0 0" sensor="false" radius="12" aim-through="true" shoot-through="false" charge-through="false" charging="false" density="20"/>
			</collision>
			<shadow>
				<sprite origin="16 16" texture="doodads/special/shadows.png">
					<frame>90 0 32 32</frame>
				</sprite>	
			</shadow>
		</scene>
		
		<scene name="shared-jump">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="false">
				<circle offset="0 0" sensor="true" radius="0.1" aim-through="true" shoot-through="true" charge-through="true" charging="true" density="20"/>
			</collision>
			<shadow>
				<sprite origin="16 16" texture="doodads/special/shadows.png">
					<frame>90 0 32 32</frame>
				</sprite>	
			</shadow>
		</scene>
		
		<scene name="walk-0">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">0 400 80 80</frame>
				<frame time="90">0 480 80 80</frame>
				<frame time="90">0 560 80 80</frame>
				<frame time="90">0 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-1">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">80 400 80 80</frame>
				<frame time="90">80 480 80 80</frame>
				<frame time="90">80 560 80 80</frame>
				<frame time="90">80 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-2">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">160 400 80 80</frame>
				<frame time="90">160 480 80 80</frame>
				<frame time="90">160 560 80 80</frame>
				<frame time="90">160 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-3">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">240 400 80 80</frame>
				<frame time="90">240 480 80 80</frame>
				<frame time="90">240 560 80 80</frame>
				<frame time="90">240 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-4">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">320 400 80 80</frame>
				<frame time="90">320 480 80 80</frame>
				<frame time="90">320 560 80 80</frame>
				<frame time="90">320 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-5">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">400 400 80 80</frame>
				<frame time="90">400 480 80 80</frame>
				<frame time="90">400 560 80 80</frame>
				<frame time="90">400 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-6">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">480 400 80 80</frame>
				<frame time="90">480 480 80 80</frame>
				<frame time="90">480 560 80 80</frame>
				<frame time="90">480 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="walk-7">
			<scene src="shared-charge" />
			<sprite  origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="90">560 400 80 80</frame>
				<frame time="90">560 480 80 80</frame>
				<frame time="90">560 560 80 80</frame>
				<frame time="90">560 640 80 80</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">0 80  80 80</frame>
				<frame time="100">0 160 80 80</frame>
				<frame time="100">0 240 80 80</frame>
				<frame time="100">0 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">80 80  80 80</frame>
				<frame time="100">80 160 80 80</frame>
				<frame time="100">80 240 80 80</frame>
				<frame time="100">80 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">160 80  80 80</frame>
				<frame time="100">160 160 80 80</frame>
				<frame time="100">160 240 80 80</frame>
				<frame time="100">160 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">240 80  80 80</frame>
				<frame time="100">240 160 80 80</frame>
				<frame time="100">240 240 80 80</frame>
				<frame time="100">240 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">320 80  80 80</frame>
				<frame time="100">320 160 80 80</frame>
				<frame time="100">320 240 80 80</frame>
				<frame time="100">320 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">400 80  80 80</frame>
				<frame time="100">400 160 80 80</frame>
				<frame time="100">400 240 80 80</frame>
				<frame time="100">400 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">480 80  80 80</frame>
				<frame time="100">480 160 80 80</frame>
				<frame time="100">480 240 80 80</frame>
				<frame time="100">480 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="500">560 80  80 80</frame>
				<frame time="100">560 160 80 80</frame>
				<frame time="100">560 240 80 80</frame>
				<frame time="100">560 320 80 80</frame>
			</sprite>
		</scene>

		<scene name="attack-running-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">0 160 80 80</frame>
				<frame time="100">0 240 80 80</frame>
				<frame time="100">0 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">80 160 80 80</frame>
				<frame time="100">80 240 80 80</frame>
				<frame time="100">80 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">160 160 80 80</frame>
				<frame time="100">160 240 80 80</frame>
				<frame time="100">160 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">240 160 80 80</frame>
				<frame time="100">240 240 80 80</frame>
				<frame time="100">240 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">320 160 80 80</frame>
				<frame time="100">320 240 80 80</frame>
				<frame time="100">320 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">400 160 80 80</frame>
				<frame time="100">400 240 80 80</frame>
				<frame time="100">400 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">480 160 80 80</frame>
				<frame time="100">480 240 80 80</frame>
				<frame time="100">480 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="attack-running-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">560 160 80 80</frame>
				<frame time="100">560 240 80 80</frame>
				<frame time="100">560 320 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">0 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">80 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">160 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">240 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">320 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">400 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">480 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="idle-7">
			<scene src="shared" /> 
			<sprite origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">560 0  80 80</frame>
			</sprite>
		</scene>
		
		<scene name="jump-0">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">640 0 80 80</frame>
				<frame time="100">640 80 80 80</frame> 
				<frame time="100">640 160 80 80</frame>
				<frame time="300">640 240 80 80</frame>
				<frame time="100">640 320 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-1">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">720 0 80 80</frame>
				<frame time="100">720 80 80 80</frame> 
				<frame time="100">720 160 80 80</frame>
				<frame time="300">720 240 80 80</frame>
				<frame time="100">720 320 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-2">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">800 0 80 80</frame>
				<frame time="100">800 80 80 80</frame> 
				<frame time="100">800 160 80 80</frame>
				<frame time="300">800 240 80 80</frame>
				<frame time="100">800 320 80 80</frame> 
			</sprite>
		</scene>		
		<scene name="jump-3">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">880 0 80 80</frame>
				<frame time="100">880 80 80 80</frame> 
				<frame time="100">880 160 80 80</frame>
				<frame time="300">880 240 80 80</frame>
				<frame time="100">880 320 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-4">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">0   720 80 80</frame>
				<frame time="100">80  720 80 80</frame> 
				<frame time="100">160 720 80 80</frame>
				<frame time="300">240 720 80 80</frame>
				<frame time="100">320 720 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-5">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">0   800 80 80</frame>
				<frame time="100">80  800 80 80</frame> 
				<frame time="100">160 800 80 80</frame>
				<frame time="300">240 800 80 80</frame>
				<frame time="100">320 800 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-6">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">0   880 80 80</frame>
				<frame time="100">80  880 80 80</frame> 
				<frame time="100">160 880 80 80</frame>
				<frame time="300">240 880 80 80</frame>
				<frame time="100">320 880 80 80</frame>
			</sprite>
		</scene>		
		<scene name="jump-7">
			<scene src="shared-jump" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="200">640 560 80 80</frame>
				<frame time="100">720 560 80 80</frame> 
				<frame time="100">800 560 80 80</frame>
				<frame time="300">880 560 80 80</frame>
				<frame time="100">640 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="land-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">640 400 80 80</frame>
				<frame time="100">640 480 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">720 400 80 80</frame>
				<frame time="100">720 480 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">800 400 80 80</frame>
				<frame time="100">800 480 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">880 400 80 80</frame>
				<frame time="100">880 480 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">400 720 80 80</frame>
				<frame time="100">480 720 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">400 800 80 80</frame>
				<frame time="100">480 800 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">400 880 80 80</frame>
				<frame time="100">480 880 80 80</frame>
			</sprite>
		</scene>		
		<scene name="land-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">720 640 80 80</frame>
				<frame time="100">800 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="howl">
			<scene src="shared" />
			<sprite looping="false" origin="40 48" texture="./wolf_boss.png" material="system/default.mats:actor">
				<frame time="100">560 720 80 80</frame>
				<frame time="200">640 720 80 80</frame>
				<frame time="250">720 720 80 80</frame>
				<frame time="300">800 720 80 80</frame>
				<frame time="1800">880 720 80 80</frame>
				<frame time="200">800 720 80 80</frame>
				<frame time="100">720 720 80 80</frame>
				<frame time="100">640 720 80 80</frame> 
				<frame time="100">560 720 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-0">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">0 0 80 80</frame>
				<frame time="150">0 80 80 80</frame> 
				<frame time="100">0 160 80 80</frame> 
				<frame time="100">0 240 80 80</frame>
				<frame time="250">0 320 80 80</frame>
				<frame time="250">0 400 80 80</frame>
				<frame time="50">0 480 80 80</frame>
				<frame time="50">0 560 80 80</frame>
				<frame time="50">0 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-1">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">80 0 80 80</frame>
				<frame time="150">80 80 80 80</frame> 
				<frame time="100">80 160 80 80</frame>
				<frame time="100">80 240 80 80</frame>
				<frame time="250">80 320 80 80</frame>
				<frame time="250">80 400 80 80</frame>
				<frame time="50">80 480 80 80</frame>
				<frame time="50">80 560 80 80</frame>
				<frame time="50">80 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-2">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="0 20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">160 0 80 80</frame>
				<frame time="150">160 80 80 80</frame> 
				<frame time="100">160 160 80 80</frame> 
				<frame time="100">160 240 80 80</frame>
				<frame time="250">160 320 80 80</frame>
				<frame time="250">160 400 80 80</frame>
				<frame time="50">160 480 80 80</frame>
				<frame time="50">160 560 80 80</frame>
				<frame time="50">160 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-3">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="-12 12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">240 0 80 80</frame>
				<frame time="150">240 80 80 80</frame> 
				<frame time="100">240 160 80 80</frame> 
				<frame time="100">240 240 80 80</frame>
				<frame time="250">240 320 80 80</frame>
				<frame time="250">240 400 80 80</frame>
				<frame time="50">240 480 80 80</frame>
				<frame time="50">240 560 80 80</frame>
				<frame time="50">240 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-4">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="-20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">320 0 80 80</frame>
				<frame time="150">320 80 80 80</frame> 
				<frame time="100">320 160 80 80</frame> 
				<frame time="100">320 240 80 80</frame>
				<frame time="250">320 320 80 80</frame>
				<frame time="250">320 400 80 80</frame>
				<frame time="50">320 480 80 80</frame>
				<frame time="50">320 560 80 80</frame>
				<frame time="50">320 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-5">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="-12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">400 0 80 80</frame>
				<frame time="150">400 80 80 80</frame> 
				<frame time="100">400 160 80 80</frame> 
				<frame time="100">400 240 80 80</frame>
				<frame time="250">400 320 80 80</frame>
				<frame time="250">400 400 80 80</frame>
				<frame time="50">400 480 80 80</frame>
				<frame time="50">400 560 80 80</frame>
				<frame time="50">400 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-6">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="0 -20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">480 0 80 80</frame>
				<frame time="150">480 80 80 80</frame> 
				<frame time="100">480 160 80 80</frame> 
				<frame time="100">480 240 80 80</frame>
				<frame time="250">480 320 80 80</frame>
				<frame time="250">480 400 80 80</frame>
				<frame time="50">480 480 80 80</frame>
				<frame time="50">480 560 80 80</frame>
				<frame time="50">480 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="groundslam-7">
			<scene src="shared" />
			<locator name="groundslam-pos" pos="12 -12"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="150">560 0 80 80</frame>
				<frame time="150">560 80 80 80</frame> 
				<frame time="100">560 160 80 80</frame> 
				<frame time="100">560 240 80 80</frame>
				<frame time="250">560 320 80 80</frame>
				<frame time="250">560 400 80 80</frame>
				<frame time="50">560 480 80 80</frame>
				<frame time="50">560 560 80 80</frame>
				<frame time="50">560 640 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">0 720 80 80</frame>
				<frame time="300">0 800 80 80</frame>
				<frame time="1000">0 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="16 16"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">80 720 80 80</frame>
				<frame time="300">80 800 80 80</frame>
				<frame time="1000">80 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">160 720 80 80</frame>
				<frame time="300">160 800 80 80</frame>
				<frame time="1000">160 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-16 16"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">240 720 80 80</frame>
				<frame time="300">240 800 80 80</frame>
				<frame time="1000">240 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">320 720 80 80</frame>
				<frame time="300">320 800 80 80</frame>
				<frame time="1000">320 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-16 -16"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">400 720 80 80</frame>
				<frame time="300">400 800 80 80</frame>
				<frame time="1000">400 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">480 720 80 80</frame>
				<frame time="300">480 800 80 80</frame>
				<frame time="1000">480 880 80 80</frame>
			</sprite>
		</scene>
		
		<scene name="breath-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="16 -16"/>
			<sprite looping="false" origin="40 48" texture="./wolf_boss_skills.png" material="system/default.mats:actor">
				<frame time="300">560 720 80 80</frame>
				<frame time="300">560 800 80 80</frame>
				<frame time="1000">560 880 80 80</frame>
			</sprite>
		</scene>
	</scenes>
</unit>