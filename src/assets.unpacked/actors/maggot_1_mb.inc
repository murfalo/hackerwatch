<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.maggot_1_mb</string>
%else
		<string name="beastiary-override">actors/maggot_1_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">4 -6</vec2>
		<string name="quality">rare</string>
	
		<string name="type">beast</string>
		<int name="hp">400</int>
		<int name="armor">30</int>
		<int name="resistance">50</int>
		<int name="experience-reward">175</int>
		<float name="mp-scale-fact">0.85</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">17</int>		
		
		<string name="gore">effects/gibs/gib_maggot_mb.sval</string>
		<string name="death-snd">event:/enemy/maggot/death</string>
		<string name="loot">actors/loot.sval:maggot_1_mb</string>

		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_mb.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>
		
		<bool name="ignore-hit-effects">true</bool>
		<bool name="impenetrable">true</bool>
		<int name="aggro-range">150</int>

		<dict name="movement">
			<string name="class">MeleeMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.45</float>
			<int name="dist">40</int>
			<int name="stagger-threshold">0</int>
		</dict>

		<array name="skills">
			%// Nova
			<dict>
				<string name="class">NovaSkill</string>
				<string name="anim">attack</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown">SHOOTCD</int>
				<int name="min-range">0</int>
				<int name="range">140</int>
				
				<int name="proj-count">SHOOTNUM</int>
				<string name="projectile">SHOOTPROJ</string>
			</dict>

			%// Spawns
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>mode_arena</string>
				</array>
				
				<string name="class">CompositeActorPeriodicTriggeredSkill</string>
				<string name="trigger">OnMove</string>
				<int name="period">40</int>
				<int name="charges">SPAWNCHARGES</int>
				
				<dict name="action">
					<string name="class">SpawnUnit</string>
%if NORMAL
					<array name="units">
						<int>500</int><string>actors/maggot_1_small.unit</string>
						<int>500</int><string>actors/maggot_1.unit</string>
					</array>
%else
					<array name="units">
						<int>250</int><string>actors/maggot_1_small.unit</string>
						<int>500</int><string>actors/maggot_1.unit</string>
						<int>250</int><string>actors/maggot_1_elite.unit</string>
					</array>
%endif
					<bool name="aggro">true</bool>
					<bool name="safe-spawn">true</bool>
					<int name="spawn-dist">-20</int>
					<bool name="no-loot">true</bool>
					<bool name="no-experience">true</bool>
				</dict>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="8" charge-through="true" density="20"/>
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 32 32 32</frame>
				<frame time="200">64 128 32 32</frame>
				<frame time="200">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 0 32 32</frame>
				<frame time="200">64 96 32 32</frame>
				<frame time="200">160 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 0 32 32</frame>
				<frame time="200">32 96 32 32</frame>
				<frame time="200">128 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 0 32 32</frame>
				<frame time="200">0 96 32 32</frame>
				<frame time="200">96 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 32 32 32</frame>
				<frame time="200">0 128 32 32</frame>
				<frame time="200">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 64 32 32</frame>
				<frame time="200">0 160 32 32</frame>
				<frame time="200">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 64 32 32</frame>
				<frame time="200">32 160 32 32</frame>
				<frame time="200">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 16" looping="true" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 64 32 32</frame>
				<frame time="200">64 160 32 32</frame>
				<frame time="200">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<sprite origin="16 16" looping="false" texture="actors/maggot_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 192 32 32</frame>
				<frame time="100">32 192 32 32</frame>
				<frame time="100">0 192 32 32</frame>
				<frame time="100">32 192 32 32</frame>
				<frame time="100">64 192 32 32</frame>
				<frame time="100">32 192 32 32</frame>
				<frame time="100">96 192 32 32</frame>
				<frame time="100">64 192 32 32</frame>
				<frame time="100">96 192 32 32</frame>
				<frame time="100">128 192 32 32</frame>
				<frame time="100">96 192 32 32</frame>
				<frame time="100">128 192 32 32</frame>
				<frame time="100">160 192 32 32</frame>
			</sprite>
			<sprite origin="16 16" looping="false" texture="actors/maggot_1_mb.png" material="system/default.mats:glow">
				<frame time="100">0 224 32 32</frame>
				<frame time="100">32 224 32 32</frame>
				<frame time="100">0 224 32 32</frame>
				<frame time="100">32 224 32 32</frame>
				<frame time="100">64 224 32 32</frame>
				<frame time="100">32 224 32 32</frame>
				<frame time="100">96 224 32 32</frame>
				<frame time="100">64 224 32 32</frame>
				<frame time="100">96 224 32 32</frame>
				<frame time="100">128 224 32 32</frame>
				<frame time="100">96 224 32 32</frame>
				<frame time="100">128 224 32 32</frame>
				<frame time="100">160 224 32 32</frame>
			</sprite>
		</scene>

	</scenes>

</unit>
