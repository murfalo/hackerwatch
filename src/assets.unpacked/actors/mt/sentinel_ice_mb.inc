<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.sentinel_ice_mb</string>
%else
		<string name="beastiary-override">actors/mt/sentinel_ice_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">0 11</vec2>
		<string name="quality">rare</string>
		<string name="dlc">mt</string>
		
		<string name="type">construct</string>
		<int name="hp">2000</int>
		<int name="armor">120</int>
		<int name="resistance">50</int>
		<int name="experience-reward">500</int>
		<float name="mp-scale-fact">0.85</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/sentinel/death</string>
		<string name="gore">effects/gibs/gib_sentinel_ice.sval</string>
		<string name="loot">actors/loot.sval:sentinel_mb</string>
		
		<int name="aggro-range">200</int>
		<bool name="must-see-target">false</bool>
		<float name="wind-scale">0.5</float>
		
%include "actors/extra/debuff_scaling_mb.inc"

		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
			<string>respawn_thrall</string>
			<string>bleeding</string>
			<string>stun</string>
			<string>disarm</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.2</float>
			<int name="dist">120</int>
		</dict>

		<array name="skills">
			<dict>
				<array name="conditional">
					<string>buff</string><string>has</string><string>actors/buffs.sval:sentinel-ice-mb-buff</string>
				</array>

				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack-fast 8</string>
				<string name="offset">attack-pos</string>

				<int name="burst">999</int>

				<int name="cooldown-start">0</int>
				<int name="cooldown">500</int>
				<int name="castpoint">400</int>
				<int name="range">300</int>
				<bool name="good-aim">true</bool>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/sentinel_ice_mb_projectile.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/sentinel_ice_mb_projectile_ng.unit</string>
%endif
						<int name="dist">10</int>
					</dict>
				</array>
			</dict>

%if OBJECTIVE
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">summon</string>
				<string name="start-snd">event:/enemy/sentinel_ice_mb/beams</string>

				<int name="cooldown-start">3000</int>
				<int name="cooldown">CAGECD</int>
				<int name="castpoint">800</int>
				<int name="range">150</int>
				<bool name="good-aim">true</bool>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnPrefab</string>
						<string name="prefab">actors/mt/projectiles/sentinel_ice_mb_cage.pfb</string>
					</dict>
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:sentinel-ice-mb-buff</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
%endif

			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="start-snd">event:/enemy/sentinel_ice_mb/charge</string>
				<string name="offset">attack-pos</string>

				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">700</int>
				<int name="range">200</int>
				<bool name="good-aim">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/sentinel_ice_mb_projectile.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/sentinel_ice_mb_projectile_ng.unit</string>
%endif
						<int name="dist">10</int>
					</dict>
				</array>
			</dict>

%if OBJECTIVE
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnPrefab</string>
						<string name="prefab">prefabs/moon_temple/pickups/objective_rich.pfb</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">0</int>
					</dict>
				</array>	
			</dict>
%endif
		</array>
		<dict name="effect-params" />

	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
%if OBJECTIVE
			<minimap_sprite origin="4 5" layer="120" texture="gui/minimap.png" frame="249 272 7 9" />
%else
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
%endif
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6" charge-through="true" density="20"/>
				<circle offset="0 -10" sensor="true" shoot-through="false" aim-through="true" radius="6" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="250">384 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">0 64 64 64</frame>
				<frame time="200">0 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">64 64 64 64</frame>
				<frame time="200">64 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">128 64 64 64</frame>
				<frame time="200">128 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">192 64 64 64</frame>
				<frame time="200">192 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">256 64 64 64</frame>
				<frame time="200">256 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">320 64 64 64</frame>
				<frame time="200">320 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">384 64 64 64</frame>
				<frame time="200">384 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">448 64 64 64</frame>
				<frame time="200">448 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="15 -5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">0 192 64 64</frame>
				<frame time="400">0 256 64 64</frame>
				<frame time="75">0 0 64 64</frame>
			</sprite>
			<effect delay="700" pos="15 -5"src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />
			<effect pos="-7 0" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect layer="-2" pos="-7 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="10 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">64 192 64 64</frame>
				<frame time="400">64 256 64 64</frame>
				<frame time="75">64 0 64 64</frame>
			</sprite>
			<effect pos="10 -20" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect pos="6 -2" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">128 192 64 64</frame>
				<frame time="400">128 256 64 64</frame>
				<frame time="75">128 0 64 64</frame>
			</sprite>
			<effect pos="0 -20" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 0" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect pos="11 0" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-10 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">192 192 64 64</frame>
				<frame time="400">192 256 64 64</frame>
				<frame time="75">192 0 64 64</frame>
			</sprite>
			<effect pos="-10 -20" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect pos="-6 -2" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-15 -5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">256 192 64 64</frame>
				<frame time="400">256 256 64 64</frame>
				<frame time="75">256 0 64 64</frame>
			</sprite>
			<effect delay="700" pos="-15 -5"src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />
			<effect pos="7 0" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect layer="-2" pos="7 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-15 5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">320 192 64 64</frame>
				<frame time="400">320 256 64 64</frame>
				<frame time="75">320 0 64 64</frame>
			</sprite>
			<effect pos="-15 5" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="10 -6" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect layer="-2" pos="-4 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">384 192 64 64</frame>
				<frame time="400">384 256 64 64</frame>
				<frame time="75">384 0 64 64</frame>
			</sprite>
			<effect pos="0 0" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect pos="11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="15 5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="700">448 192 64 64</frame>
				<frame time="400">448 256 64 64</frame>
				<frame time="75">448 0 64 64</frame>
			</sprite>
			<effect pos="15 5" delay="700" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-10 -6" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect layer="-2" pos="4 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>
 
		<scene name="attack-fast-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="-7 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">0 192 64 64</frame>
				<frame time="400">0 256 64 64</frame>
			</sprite>
			<effect delay="200" pos="15 -5"src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />
			<effect pos="-7 0" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect layer="-2" pos="-7 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" /> 
		</scene>

		<scene name="attack-fast-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="10 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">64 192 64 64</frame>
				<frame time="400">64 256 64 64</frame>
			</sprite>
			<effect pos="10 -20" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect pos="6 -2" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">128 192 64 64</frame>
				<frame time="400">128 256 64 64</frame>
			</sprite>
			<effect pos="0 -20" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 0" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect pos="11 0" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-10 -20"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">192 192 64 64</frame>
				<frame time="400">192 256 64 64</frame>
			</sprite>
			<effect pos="-10 -20" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect pos="-6 -2" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-15 -5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">256 192 64 64</frame>
				<frame time="400">256 256 64 64</frame>
			</sprite>
			<effect delay="200" pos="-15 -5"src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />
			<effect pos="7 0" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect layer="-2" pos="7 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-15 5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">320 192 64 64</frame>
				<frame time="400">320 256 64 64</frame>
			</sprite>
			<effect pos="-15 5" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="10 -6" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect layer="-2" pos="-4 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">384 192 64 64</frame>
				<frame time="400">384 256 64 64</frame>
			</sprite>
			<effect pos="0 0" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect pos="11 -12" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>

		<scene name="attack-fast-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="15 5"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">448 192 64 64</frame>
				<frame time="400">448 256 64 64</frame>
			</sprite>
			<effect pos="15 5" delay="200" src="actors/mt/projectiles/sentinel_ice_mb_muzzle.effect" />

			<effect pos="-10 -6" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
			<effect layer="-2" pos="4 -15" src="actors/mt/projectiles/sentinel_ice_mb_charge_fast.effect" />
		</scene>
		<scene name="summon">
			<scene src="shared" />
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_mb.png" material="system/default.mats:actor">
				<frame time="200">384 0 64 64</frame>
				<frame time="100">0 320 64 64</frame>
				<frame time="850">64 320 64 64</frame>
				<frame time="100">0 320 64 64</frame>
				<frame time="200">384 0 64 64</frame>
			</sprite>

			<effect pos="0 -8" layer="1" delay="300"src="actors/mt/projectiles/sentinel_ice_mb_beams.effect" />
			<effect pos="0 -8" layer="1" delay="300"src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
			<effect pos="0 -8" layer="1" delay="500" src="actors/mt/projectiles/sentinel_ice_mb_charge.effect" />
		</scene>
  </scenes>
</unit>