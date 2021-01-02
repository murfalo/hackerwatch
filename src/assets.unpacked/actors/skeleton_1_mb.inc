<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.skeleton_1_mb</string>
%else
		<string name="beastiary-override">actors/skeleton_1_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">0 9</vec2>
		<string name="quality">rare</string>
	
		<string name="type">undead</string>
		<int name="hp">800</int>
		<int name="armor">50</int>
		<int name="resistance">20</int>
		<int name="experience-reward">250</int>
		<float name="mp-scale-fact">0.85</float>

		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/skeleton/death</string>
		<string name="gore">effects/gibs/gib_skeleton_1_mb.sval</string>
		<string name="loot">actors/loot.sval:skeleton_1_mb</string>

		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_mb.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
			<string>buff</string>
		</array>
		
		<bool name="ignore-hit-effects">true</bool>
		<bool name="impenetrable">true</bool>
		<int name="aggro-range">150</int>

		<dict name="movement">
			<string name="class">MeleeMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<float name="speed">MOVESPEED</float>
			<int name="dist">20</int>
			<int name="stagger-threshold">0</int>
		</dict>

		<array name="skills">
			%// Normal Attack
			<dict>
				<array name="conditional">
					<string>ngp</string><string>lt</string><int>2</int>
				</array>
			
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">500</int>
				<int name="castpoint">500</int>
				<int name="arc">90</int>
				<int name="range">22</int>
				<int name="dmg-range">24</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">80</int>
					<float name="armor-mul">ARMORMUL</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			%// NG+2 Attack
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack-spin 8</string>

				<int name="cooldown">500</int>
				<int name="castpoint">500</int>
				<int name="arc">360</int>
				<int name="range">22</int>
				<int name="dmg-range">24</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">80</int>
					<float name="armor-mul">ARMORMUL</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			%// Whirlwind
			<dict>
				<string name="class">WhirlwindSkill</string>
				<string name="anim">whirlwind</string>

				<int name="cooldown-start">5000</int>
				<int name="cooldown">7500</int>
				<int name="castpoint">480</int>
				
				<int name="range">75</int>
				
				<float name="acceleration">WHIRLACC</float>
				<float name="speed">WHIRLSPEED</float>
				<float name="turnspeed">WHIRLTURNSPEED</float>
				<int name="duration">3600</int>
				<int name="freq">240</int>
				
				<dict name="effect">
					<string name="class">Explode</string>
					
					<int name="radius">22</int>
					<float name="dist-scaling">1000</float>
					
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">45</int>
					</dict>
				</dict>
			</dict>
			
			<dict>
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:protection</string>
				<int name="freq">250</int>
				<int name="range">PROTECTIONRANGE</int>
			</dict>
		</array>
		
		<dict name="effect-params">
			<float name="color_r">.75</float>
			<float name="color_g">.75</float>
			<float name="color_b">.75</float>
			<float name="size">PROTECTIONRANGE</float>
		</dict>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
			
			<effect src="actors/banners/banner_marker_protection.effect" />
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" density="20"/>
				<circle offset="0 -10" sensor="true" shoot-through="false" aim-through="true" radius="5" />
			</collision>
		</scene>

		<scene name="whirlwind">
			<scene src="shared" />
			<sprite origin="16 24" loopback="480" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="60">192 224 32 32</frame>
				<frame time="60">224 224 32 32</frame>
				<frame time="60">0 224 32 32</frame>
				<frame time="60">32 224 32 32</frame>
				<frame time="60">64 224 32 32</frame>
				<frame time="60">96 224 32 32</frame>
				<frame time="60">128 224 32 32</frame>
				<frame time="60">160 224 32 32</frame>

				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="250">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">0 32 32 32</frame>
				<frame time="150">0 96 32 32</frame>
				<frame time="150">0 64 32 32</frame>
				<frame time="150">0 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">32 32 32 32</frame>
				<frame time="150">32 96 32 32</frame>
				<frame time="150">32 64 32 32</frame>
				<frame time="150">32 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">64 32 32 32</frame>
				<frame time="150">64 96 32 32</frame>
				<frame time="150">64 64 32 32</frame>
				<frame time="150">64 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">96 32 32 32</frame>
				<frame time="150">96 96 32 32</frame>
				<frame time="150">96 64 32 32</frame>
				<frame time="150">96 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">128 32 32 32</frame>
				<frame time="150">128 96 32 32</frame>
				<frame time="150">128 64 32 32</frame>
				<frame time="150">128 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">160 32 32 32</frame>
				<frame time="150">160 96 32 32</frame>
				<frame time="150">160 64 32 32</frame>
				<frame time="150">160 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">192 32 32 32</frame>
				<frame time="150">192 96 32 32</frame>
				<frame time="150">192 64 32 32</frame>
				<frame time="150">192 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="150">224 32 32 32</frame>
				<frame time="150">224 96 32 32</frame>
				<frame time="150">224 64 32 32</frame>
				<frame time="150">224 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 128 32 32</frame>
				<frame time="250">0 160 32 32</frame>
				<frame time="200">0 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 128 32 32</frame>
				<frame time="250">32 160 32 32</frame>
				<frame time="200">32 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 128 32 32</frame>
				<frame time="250">64 160 32 32</frame>
				<frame time="200">64 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">96 128 32 32</frame>
				<frame time="250">96 160 32 32</frame>
				<frame time="300">96 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">128 128 32 32</frame>
				<frame time="250">128 160 32 32</frame>
				<frame time="200">128 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">160 128 32 32</frame>
				<frame time="250">160 160 32 32</frame>
				<frame time="200">160 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">192 128 32 32</frame>
				<frame time="250">192 160 32 32</frame>
				<frame time="200">192 192 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">224 128 32 32</frame>
				<frame time="250">224 160 32 32</frame>
				<frame time="200">224 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="attack-spin-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">0 128 32 32</frame>
				<frame time="250">0 160 32 32</frame>
				
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">32 128 32 32</frame>
				<frame time="250">32 160 32 32</frame>
				
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">64 128 32 32</frame>
				<frame time="250">64 160 32 32</frame>
				
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">96 128 32 32</frame>
				<frame time="250">96 160 32 32</frame>
				
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">128 128 32 32</frame>
				<frame time="250">128 160 32 32</frame>
				
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">160 128 32 32</frame>
				<frame time="250">160 160 32 32</frame>
				
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">192 128 32 32</frame>
				<frame time="250">192 160 32 32</frame>
				
				<frame time="30">192 224 32 32</frame>
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-spin-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="false" texture="actors/skeleton_1_mb.png" material="system/default.mats:actor">
				<frame time="200">224 128 32 32</frame>
				<frame time="250">224 160 32 32</frame>
				
				<frame time="30">224 224 32 32</frame>
				<frame time="30">0 224 32 32</frame>
				<frame time="30">32 224 32 32</frame>
				<frame time="30">64 224 32 32</frame>
				<frame time="30">96 224 32 32</frame>
				<frame time="30">128 224 32 32</frame>
				<frame time="30">160 224 32 32</frame>
				<frame time="30">192 224 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>