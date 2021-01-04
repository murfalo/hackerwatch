<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.eye_1_mb</string>
%else
		<string name="beastiary-override">actors/eye_1_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">-2 -1</vec2>
		<string name="quality">rare</string>
	  
		<string name="type">aberration</string>
		<int name="hp">1200</int>
		<int name="armor">40</int>
		<int name="resistance">80</int>
		<int name="experience-reward">350</int>
		<float name="mp-scale-fact">0.85</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/eye/death</string>
		<string name="gore">effects/gibs/gib_eye_1_mb.sval</string>

		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_mb.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
			<string>confusion</string>
		</array>
		
		<bool name="ignore-hit-effects">true</bool>
		<bool name="impenetrable">true</bool>
		<int name="aggro-range">150</int>
		
		<dict name="movement">
			<string name="class">MeleeMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<int name="stagger-threshold">0</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">500</int>
				<int name="castpoint">400</int>
				<int name="arc">120</int>
				<int name="range">20</int>
				<int name="dmg-range">22</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">90</int>
					<float name="armor-mul">0.75</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			%// Spawns
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>mode_arena</string>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">summon 8</string>
				<string name="snd">event:/enemy/mb_eye/summon</string>
				
				
				<int name="charges">SPAWNCHARGES</int>
				<bool name="must-see">true</bool>
				<int name="cooldown">SPAWNCD</int>
				<int name="castpoint">400</int>
				<int name="range">SPAWNRANGE</int>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/eye_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="no-experience">true</bool>
						<bool name="no-loot">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/eye_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="no-experience">true</bool>
						<bool name="no-loot">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/eye_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="no-experience">true</bool>
						<bool name="no-loot">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/eye_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="no-experience">true</bool>
						<bool name="no-loot">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
				</array>
			</dict>
			
			%// Beam
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">beam 8</string>
				<string name="start-snd">event:/enemy/mb_eye/beam</string>
				
				<bool name="must-see">true</bool>		
				<int name="cooldown">BEAMCD</int>	
				<int name="castpoint">500</int>
				<int name="min-range">30</int>
				<int name="range">200</int>
				<bool name="good-aim">false</bool>	

				<dict name="action">
					<string name="class">Hitscan</string>
					<int name="penetrating">10000</int>
					<float name="team-dmg">0</float>
					<int name="rays">BEAMRAYS</int>
					<int name="spread">BEAMSPREAD</int>
					<bool name="miss-fx">true</bool>
					<string name="shoot-fx">actors/projectiles/eye_1_mb_beam.effect</string>
					<string name="hit-fx">actors/projectiles/rail_hit.effect</string>
					
					<array name="effects">
						<dict>
							<string name="class">Damage</string>
							<int name="magical">35</int>
						</dict>
					
						<dict>
							<string name="class">ApplyBuff</string>
							<string name="buff">actors/buffs.sval:confusion</string>
						</dict>
					</array>
					
					<dict name="range">
						<int name="min">300</int>
						<int name="max">300</int>
					</dict>
				</dict>		
			</dict>

			%// NG+ Aura
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:bloodlust</string>
				<int name="freq">250</int>
				<int name="range">80</int>
			</dict>
		</array>
		
		<bool name="hold-angle-on-cast">true</bool>
		
		<dict name="effect-params">
			<float name="color_r">1</float>
			<float name="color_g">0</float>
			<float name="color_b">0</float>
			<float name="size">80</float>
			<float name="length">150</float>
			<float name="height">10</float>
		</dict>	
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
		
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" density="20"/>
				<circle sensor="true" offset="0 0" radius="8" aim-through="true" shoot-through="false" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="250">32 64 32 32</frame>
				<frame time="250">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-0">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">256 32 32 32</frame>
				<frame time="150">352 32 32 32</frame>
				<frame time="150">256 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-7">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">256 0 32 32</frame>
				<frame time="150">352 0 32 32</frame>
				<frame time="150">256 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-6">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">224 0 32 32</frame>
				<frame time="150">320 0 32 32</frame>
				<frame time="150">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-5">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">192 0 32 32</frame>
				<frame time="150">288 0 32 32</frame>
				<frame time="150">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-4">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">192 32 32 32</frame>
				<frame time="150">288 32 32 32</frame>
				<frame time="150">192 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-3">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">192 64 32 32</frame>
				<frame time="150">288 64 32 32</frame>
				<frame time="150">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-2">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">224 64 32 32</frame>
				<frame time="150">320 64 32 32</frame>
				<frame time="150">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="summon-1">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="150">256 64 32 32</frame>
				<frame time="150">352 64 32 32</frame>
				<frame time="150">256 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 128 32 32</frame>
				<frame time="100">160 128 32 32</frame>
				<frame time="100">256 128 32 32</frame>
				<frame time="100">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 96 32 32</frame>
				<frame time="100">160 96 32 32</frame>
				<frame time="100">256 96 32 32</frame>
				<frame time="100">160 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 96 32 32</frame>
				<frame time="100">128 96 32 32</frame>
				<frame time="100">224 96 32 32</frame>
				<frame time="100">128 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 96 32 32</frame>
				<frame time="100">96 96 32 32</frame>
				<frame time="100">192 96 32 32</frame>
				<frame time="100">96 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 128 32 32</frame>
				<frame time="100">96 128 32 32</frame>
				<frame time="100">192 128 32 32</frame>
				<frame time="100">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 160 32 32</frame>
				<frame time="100">96 160 32 32</frame>
				<frame time="100">192 160 32 32</frame>
				<frame time="100">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 160 32 32</frame>
				<frame time="100">128 160 32 32</frame>
				<frame time="100">224 160 32 32</frame>
				<frame time="100">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 160 32 32</frame>
				<frame time="100">160 160 32 32</frame>
				<frame time="100">256 160 32 32</frame>
				<frame time="100">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 224 32 32</frame>
				<frame time="100">160 224 32 32</frame>
				<frame time="100">256 224 32 32</frame>
				<frame time="100">160 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 192 32 32</frame>
				<frame time="100">160 192 32 32</frame>
				<frame time="100">256 192 32 32</frame>
				<frame time="100">160 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 192 32 32</frame>
				<frame time="100">128 192 32 32</frame>
				<frame time="100">224 192 32 32</frame>
				<frame time="100">128 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 192 32 32</frame>
				<frame time="100">96 192 32 32</frame>
				<frame time="100">192 192 32 32</frame>
				<frame time="100">96 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 224 32 32</frame>
				<frame time="100">96 224 32 32</frame>
				<frame time="100">192 224 32 32</frame>
				<frame time="100">96 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 256 32 32</frame>
				<frame time="100">96 256 32 32</frame>
				<frame time="100">192 256 32 32</frame>
				<frame time="100">96 256 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 256 32 32</frame>
				<frame time="100">128 256 32 32</frame>
				<frame time="100">224 256 32 32</frame>
				<frame time="100">128 256 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 256 32 32</frame>
				<frame time="100">160 256 32 32</frame>
				<frame time="100">256 256 32 32</frame>
				<frame time="100">160 256 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="beam-0">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="0 0" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">256 32 32 32</frame>
				<frame time="100">352 32 32 32</frame>
				<frame time="200">256 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-7">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="7 -31" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">256 0 32 32</frame>
				<frame time="100">352 0 32 32</frame>
				<frame time="200">256 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-6">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="-20 -27" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">224 0 32 32</frame>
				<frame time="100">320 0 32 32</frame>
				<frame time="200">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-5">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="-34 -13" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">192 0 32 32</frame>
				<frame time="100">288 0 32 32</frame>
				<frame time="200">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-4">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="-8 7" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">192 32 32 32</frame>
				<frame time="100">288 32 32 32</frame>
				<frame time="200">192 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-3">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="3 20"/>
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">192 64 32 32</frame>
				<frame time="100">288 64 32 32</frame>
				<frame time="200">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-2">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="19 16"/>
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">224 64 32 32</frame>
				<frame time="100">320 64 32 32</frame>
				<frame time="200">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="beam-1">
			<scene src="shared" />
			%if GAME
			<effect src="actors/eye_mb_trail_aim_attack.effect" />
			%endif
			<locator name="shoot-pos" pos="29 -1" />
			<sprite origin="16 17" looping="false" texture="actors/eye_1_mb.png" material="system/default.mats:actor">
				<frame time="450">256 64 32 32</frame>
				<frame time="100">352 64 32 32</frame>
				<frame time="200">256 64 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>