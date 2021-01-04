<unit slot="actor" netsync="position">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.ice_troll_shaman</string>
%else
		<string name="beastiary-override">actors/ice_troll_shaman.unit</string>
%endif
		<vec2 name="beastiary-offset">3 5</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">beast</string>
		<int name="hp">1300</int>
		<int name="armor">60</int>
		<int name="resistance">60</int>
		<int name="experience-reward">130</int>
		<float name="mp-scale-fact">0.65</float>

		<string name="death-snd">event:/enemy/ice_melee_troll/death</string>
		<string name="gore">effects/gibs/gib_troll_shaman.sval</string>
		<string name="loot">actors/loot.sval:ice_troll_melee</string>

		<int name="aggro-range">150</int>
		<float name="wind-scale">0</float>

%include "actors/extra/debuff_scaling_big.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.9</float>
			<float name="roaming">0.75</float>
			<int name="min-dist">60</int>
			<int name="dist">100</int>
		</dict>
		
		<array name="skills">
			%// Snowballs
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="start-snd">event:/enemy/ice_shaman_troll/snowball_shoot</string>

				<bool name="must-see">true</bool>
				<int name="cooldown-start">2000</int>
				<int name="cooldown">SNOWBALLSCD</int>
				<int name="castpoint">800</int>
				<int name="min-range">60</int>
				<int name="range">160</int>
				
				<array name="actions">
%if NORMAL
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">20</int>
						<vec2 name="offset">0 8</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">4 4</vec2>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">40</int>
						<vec2 name="offset">0 -8</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">4 4</vec2>
						<int name="delay">60</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">60</int>
						<vec2 name="offset">0 10</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">5 5</vec2>
						<int name="delay">120</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">80</int>
						<vec2 name="offset">0 -10</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">5 5</vec2>
						<int name="delay">180</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">100</int>
						<vec2 name="offset">0 12</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">6 6</vec2>
						<int name="delay">240</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">120</int>
						<vec2 name="offset">0 -12</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">6 6</vec2>
						<int name="delay">300</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">140</int>
						<vec2 name="offset">0 14</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">7 7</vec2>
						<int name="delay">360</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">160</int>
						<vec2 name="offset">0 -14</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">7 7</vec2>
						<int name="delay">420</int>
					</dict>

%else
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">20</int>
						<vec2 name="offset">0 18</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">5 5</vec2>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">30</int>
						<vec2 name="offset">0 0</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">4 4</vec2>
						<int name="delay">30</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">20</int>
						<vec2 name="offset">0 -18</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">5 5</vec2>
						<int name="delay">60</int>
					</dict>
					
					
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">60</int>
						<vec2 name="offset">0 24</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">6 6</vec2>
						<int name="delay">120</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">70</int>
						<vec2 name="offset">0 0</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">5 5</vec2>
						<int name="delay">150</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">60</int>
						<vec2 name="offset">0 -24</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">6 6</vec2>
						<int name="delay">180</int>
					</dict>
					
					
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">100</int>
						<vec2 name="offset">0 30</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">7 7</vec2>
						<int name="delay">240</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">110</int>
						<vec2 name="offset">0 0</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">6 6</vec2>
						<int name="delay">270</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">100</int>
						<vec2 name="offset">0 -30</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">7 7</vec2>
						<int name="delay">300</int>
					</dict>
					
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">140</int>
						<vec2 name="offset">0 36</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">8 8</vec2>
						<int name="delay">360</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">150</int>
						<vec2 name="offset">0 0</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">7 7</vec2>
						<int name="delay">390</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/snowball.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">140</int>
						<vec2 name="offset">0 -36</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">8 8</vec2>
						<int name="delay">420</int>
					</dict>
%endif
				</array>
			</dict>
			
			%// Snowbomb
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">bombattack 8</string>
				<string name="start-snd">event:/enemy/ice_shaman_troll/snow_bomb</string>

				<int name="cooldown-start">500</int>
				<int name="cooldown">SNOWBOMBCD</int>
				<int name="castpoint">950</int>
				<int name="range">120</int>
				<bool name="must-see">true</bool>
				
				<string name="offset">shoot-pos</string>	
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">SNOWBOMBPROJ</string>
					</dict>
				</array>
			</dict>
			
			%// NG+ Bloodlust Chant
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>1</int>
				</array>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">chant</string>
				<string name="start-snd">event:/enemy/ice_shaman_troll/chant</string>

				<int name="cooldown-start">200</int>
				<int name="cooldown">CHANTCD</int>
				<int name="castpoint">1500</int>
				<int name="range">150</int>
				<bool name="must-see">false</bool>

				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<int name="radius">150</int>
						
						<float name="enemy-dmg">0</float>
						<float name="self-dmg">1</float>
						<float name="team-dmg">1</float>
						<array name="effects">
							<dict>
								<string name="class">ApplyBuff</string>
								<string name="buff">actors/buffs.sval:bloodlust-shaman</string>
							</dict>
						</array>
					</dict>
				</array>
			</dict>
		</array>
		
		<dict name="effect-params"></dict>
	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" radius="8" aim-through="true" charge-through="false" density="20"/>
				<circle offset="0 -8" radius="8" sensor="true" shoot-through="false" aim-through="true" charge-through="false"/>
			</collision>
				
			<shadow>
				<sprite origin="12 12" texture="doodads/special/shadows.png">
					<frame>66 0 24 24</frame>
				</sprite>	
			</shadow>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
				<frame time="100">0 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">0 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
				<frame time="100">64 64 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">64 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">192 128 64 64</frame>
				<frame time="100">192 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
				<frame time="100">256 64 64 64</frame>
				<frame time="100">256 128 64 64</frame>
				<frame time="100">256 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
				<frame time="100">320 64 64 64</frame>
				<frame time="100">320 128 64 64</frame>
				<frame time="100">320 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
				<frame time="100">384 64 64 64</frame>
				<frame time="100">384 128 64 64</frame>
				<frame time="100">384 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
				<frame time="100">448 64 64 64</frame>
				<frame time="100">448 128 64 64</frame>
				<frame time="100">448 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">0 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">64 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">128 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">192 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">256 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">320 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">384 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">448 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="chant">
			<scene src="shared" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="500">0 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="200">64 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-0">
			<scene src="shared" />
			
			<effect pos="20 0" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="20 0" />
			
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">0 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-7">
			<scene src="shared" />
			<effect pos="16 -16" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="16 -16" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">64 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-6">
			<scene src="shared" />
			<effect pos="0 -20" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="0 -20" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">128 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-5">
			<scene src="shared" />
			<effect pos="-16 -16" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="-16 -16" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">192 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-4">
			<scene src="shared" />
			<effect pos="-20 0" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="-20 0" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">256 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-3">
			<scene src="shared" />
			<effect ulayer="1" pos="-16 16" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="-16 16" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">320 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-2">
			<scene src="shared" />
			<effect ulayer="1" pos="0 20" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="0 20" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">384 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bombattack-1">
			<scene src="shared" />
			<effect ulayer="1" pos="16 16" src="actors/projectiles/ice_troll_shaman_snowbomb_spawn.effect" />
			<locator name="shoot-pos" pos="16 16" />
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="1200">448 256 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="falling-2">
			<sprite origin="33 37" texture="actors/ice_troll_shaman.png" material="system/default.mats:actor">
				<frame time="100">384 256 64 64</frame>
			</sprite>
			<shadow>			
				<sprite origin="10 10" layer="-1" texture="doodads/special/shadows.png">
					<frame>46 0 20 20</frame>
				</sprite>
			</shadow>
		</scene>
		
	</scenes>
</unit>