<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.lich_mb</string>
%else
		<string name="beastiary-override">actors/lich_1_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">0 6</vec2>
		<string name="quality">rare</string>
	
		<string name="type">undead</string>
		<int name="hp">1750</int>
		<int name="armor">75</int>
		<int name="resistance">100</int>
		<int name="experience-reward">400</int>
		<float name="mp-scale-fact">0.85</float>
		
		<float name="evade-magical">EVASION</float>
		<string name="evade-fx">effects/mana_shield_big.effect</string>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/lich/death</string>
		<string name="gore">effects/gibs/gib_lich_mb.sval</string>
		<string name="loot">actors/loot.sval:lich_1_mb</string>

		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_mb.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>
		
		<bool name="ignore-hit-effects">true</bool>
		<bool name="impenetrable">true</bool>
		<int name="aggro-range">150</int>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<float name="speed">1.4</float>
			<int name="min-dist">50</int>
			<int name="dist">110</int>
			<int name="stagger-threshold">0</int>
		</dict>

		<array name="skills">
			%// Nova
			<dict>
				<string name="class">BossScatterBurstSkill</string>
				<string name="anim">nova</string>
				<string name="snd">event:/enemy/lich_mb/attack</string>
				
				<int name="burst">NOVABURST</int>
				<int name="cooldown">NOVACD</int>	
				<int name="castpoint">500</int>
				<int name="range">130</int>
				<bool name="must-see">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">NOVANUM</int>
						<int name="dist">5</int>
						<int name="spread">NOVASPREAD</int>
						<string name="projectile">PROJECTILE</string>
					</dict>
				</array>
			</dict>

			<dict>
				<string name="class">SpewSkill</string>
				<string name="anim">attack 8</string>
				<string name="first-fire-snd">event:/enemy/lich_mb/attack</string>
				<string name="fire-snd">event:/enemy/lich_mb/attack</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">SPEWCD</int>
				<int name="castpoint">500</int>
				<int name="duration">SPEWDUR</int>
				
				<int name="min-range">80</int>
				<int name="range">200</int>
				<int name="spread">40</int>
				<int name="rate">SPEWRATE</int>
				<bool name="good-aim">true</bool>
				<bool name="must-see">true</bool>
				<bool name="hold-dir">false</bool>

				<string name="projectile">PROJECTILE</string>
			</dict>

			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/lich_mb/area</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown">AREACD</int>	
				<int name="castpoint">400</int>
				<int name="range">130</int>
				<bool name="good-aim">true</bool>
				
				<dict name="action">
					<string name="class">DummyHitscan</string>
					
					<array name="effects">
%if NORMAL
						<dict>
							<string name="class">SpawnUnit</string>
							<string name="unit">actors/projectiles/lich_1_mb_glyph.unit</string>
							<bool name="safe-spawn">false</bool>
							<bool name="players-in-sight">false</bool>
							<vec2 name="jitter">16 16</vec2>
						</dict>
%else
						<dict>
							<string name="class">SpawnUnit</string>
							<string name="unit">actors/projectiles/lich_1_mb_glyph.unit</string>
							<bool name="safe-spawn">false</bool>
							<bool name="players-in-sight">false</bool>
							<vec2 name="offset">-40 0</vec2>
							<bool name="rotate-offset">true</bool>
							<vec2 name="jitter">15 15</vec2>
						</dict>
						<dict>
							<string name="class">SpawnUnit</string>
							<string name="unit">actors/projectiles/lich_1_mb_glyph.unit</string>
							<bool name="safe-spawn">false</bool>
							<bool name="players-in-sight">false</bool>
							<vec2 name="offset">40 40</vec2>
							<bool name="rotate-offset">true</bool>
							<vec2 name="jitter">15 15</vec2>
							<int name="delay">500</int>
						</dict>
						<dict>
							<string name="class">SpawnUnit</string>
							<string name="unit">actors/projectiles/lich_1_mb_glyph.unit</string>
							<bool name="safe-spawn">false</bool>
							<bool name="players-in-sight">false</bool>
							<vec2 name="offset">40 -40</vec2>
							<bool name="rotate-offset">true</bool>
							<vec2 name="jitter">15 15</vec2>
							<int name="delay">1000</int>
						</dict>
%endif
					</array>
				</dict>		
			</dict>

			<dict>
				<string name="class">BlinkSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/lich/blink</string>
				<string name="fx">effects/blink.effect</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown">BLINKCD</int>
				<int name="castpoint">500</int>

				<int name="spread">30</int>
				<float name="off-distance">5</float>
				<int name="range">50</int>
				<float name="distance">-80</float>

				<array name="blink-effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:blink-stop-ranged</string>
						<bool name="target-self">true</bool>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/projectiles/lich_1_mb_glyph.unit</string>
						<bool name="safe-spawn">false</bool>
						<bool name="players-in-sight">true</bool>
						<vec2 name="offset">0 0</vec2>
						<bool name="rotate-offset">true</bool>
						<vec2 name="jitter">0 0</vec2>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/lich_mb/area</string>
					</dict>
%endif
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 4"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" density="100" />
				<circle offset="0 -10" sensor="true" shoot-through="false" aim-through="true" radius="5" />
			</collision>
		</scene>

		<scene name="nova">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="500">192 128 32 32</frame>
				<frame time="500">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="250">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">0 32 32 32</frame>
				<frame time="150">0 64 32 32</frame>
				<frame time="150">0 96 32 32</frame>
				<frame time="150">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">32 32 32 32</frame>
				<frame time="150">32 64 32 32</frame>
				<frame time="150">32 96 32 32</frame>
				<frame time="150">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">64 32 32 32</frame>
				<frame time="150">64 64 32 32</frame>
				<frame time="150">64 96 32 32</frame>
				<frame time="150">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">96 32 32 32</frame>
				<frame time="150">96 64 32 32</frame>
				<frame time="150">96 96 32 32</frame>
				<frame time="150">96 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">128 32 32 32</frame>
				<frame time="150">128 64 32 32</frame>
				<frame time="150">128 96 32 32</frame>
				<frame time="150">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">160 32 32 32</frame>
				<frame time="150">160 64 32 32</frame>
				<frame time="150">160 96 32 32</frame>
				<frame time="150">160 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">192 32 32 32</frame>
				<frame time="150">192 64 32 32</frame>
				<frame time="150">192 96 32 32</frame>
				<frame time="150">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="150">224 32 32 32</frame>
				<frame time="150">224 64 32 32</frame>
				<frame time="150">224 96 32 32</frame>
				<frame time="150">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 128 32 32</frame>
				<frame time="250">0 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 128 32 32</frame>
				<frame time="250">32 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 128 32 32</frame>
				<frame time="250">64 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">96 128 32 32</frame>
				<frame time="250">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">128 128 32 32</frame>
				<frame time="250">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">160 128 32 32</frame>
				<frame time="250">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">192 128 32 32</frame>
				<frame time="250">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="200">224 128 32 32</frame>
				<frame time="250">224 160 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="attack-slow-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">0 128 32 32</frame>
				<frame time="250">0 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">32 128 32 32</frame>
				<frame time="250">32 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">64 128 32 32</frame>
				<frame time="250">64 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">96 128 32 32</frame>
				<frame time="250">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">128 128 32 32</frame>
				<frame time="250">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">160 128 32 32</frame>
				<frame time="250">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">192 128 32 32</frame>
				<frame time="250">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-slow-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/lich_1_mb.png" material="system/default.mats:actor">
				<frame time="900">224 128 32 32</frame>
				<frame time="250">224 160 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>