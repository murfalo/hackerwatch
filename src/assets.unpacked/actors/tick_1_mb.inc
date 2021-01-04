<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tick_1_mb</string>
%else
		<string name="beastiary-override">actors/tick_1_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">2 0</vec2>
		<string name="quality">rare</string>
	
		<string name="type">beast</string>
		<int name="hp">200</int>
		<int name="armor">40</int>
		<int name="resistance">15</int>
		<int name="experience-reward">125</int>
		<float name="mp-scale-fact">0.85</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">16</int>
		
		<string name="gore">effects/gibs/gib_tick_mb.sval</string>
		<string name="death-snd">event:/enemy/tick/death</string>
		<string name="loot">actors/loot.sval:tick_1_mb</string>
		
		<float name="wind-scale">0.5</float>
		
%include "actors/extra/debuff_scaling_mb.inc"

		<array name="buffs-immune">
			<string>actors/buffs.sval:bloodlust</string>
		</array>
		
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

			<float name="speed">MOVESPEED</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">200</int>
				<int name="castpoint">500</int>
				<int name="range">20</int>
				<int name="dmg-range">22</int>
				<int name="arc">90</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">40</int>
					<float name="armor-mul">ARMORMUL</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>mode_arena</string>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">idle-8</string>
				
				<int name="charges">SPAWNCHARGES</int>
				<bool name="must-see">true</bool>
				<int name="cooldown">5000</int>
				<int name="castpoint">200</int>
				<int name="range">80</int>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tick_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tick_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tick_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
%if NORMAL || TIER2 || TIER3
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tick_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tick_1_small.unit</string>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
%else 
					<dict>
						<string name="class">SpawnUnit</string>
						<array name="units">
							<int>500</int><string>actors/tick_1_small.unit</string>
							<int>500</int><string>actors/tick_1_small_exploding.unit</string>
						</array>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<array name="units">
							<int>500</int><string>actors/tick_1_small.unit</string>
							<int>500</int><string>actors/tick_1_small_exploding.unit</string>
						</array>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">16</int>
					</dict>
%endif
				</array>
			</dict>
			
			%// NG+ Rage
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>1</int>
				</array>
			
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>
				<array name="effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:rage_tick</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>mode_arena</string>
				</array>
			
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<bool name="aggro">true</bool>
						<string name="unit">actors/tick_1_elite.unit</string>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<bool name="aggro">true</bool>
						<string name="unit">actors/tick_1_elite.unit</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:bloodlust</string>
				<int name="freq">250</int>
				<int name="range">BLOODLUSTRANGE</int>
			</dict>
		</array>
		
		<dict name="effect-params">
			<float name="color_r">1</float>
			<float name="color_g">0</float>
			<float name="color_b">0</float>
			<float name="size">BLOODLUSTRANGE</float>
		</dict>			
		
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
			
			<effect src="actors/banners/banner_marker_bloodlust.effect" />	
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="8" charge-through="true" density="20"/>
			</collision>
		</scene>

		<scene name="idle-0">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">32 64 32 32</frame>
				<frame time="1500">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">64 128 32 32</frame>
				<frame time="150">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">64 96 32 32</frame>
				<frame time="150">160 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">32 96 32 32</frame>
				<frame time="150">128 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">0 96 32 32</frame>
				<frame time="150">96 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">0 128 32 32</frame>
				<frame time="150">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">0 160 32 32</frame>
				<frame time="150">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">32 160 32 32</frame>
				<frame time="150">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="150">64 160 32 32</frame>
				<frame time="150">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">64 224 32 32</frame>
				<frame time="200">160 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">64 192 32 32</frame>
				<frame time="200">160 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">32 192 32 32</frame>
				<frame time="200">128 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">0 192 32 32</frame>
				<frame time="200">96 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">0 224 32 32</frame>
				<frame time="200">96 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">0 256 32 32</frame>
				<frame time="200">96 256 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">32 256 32 32</frame>
				<frame time="200">128 256 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		<scene src="shared" />
			<sprite origin="16 17" looping="false" texture="actors/tick_1_mb.png" material="system/default.mats:actor">
				<frame time="450">64 256 32 32</frame>
				<frame time="200">160 256 32 32</frame>
			</sprite>
		</scene>

	</scenes>

</unit>
