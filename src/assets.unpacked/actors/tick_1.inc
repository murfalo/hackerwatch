<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tick_1</string>
%else
		<string name="beastiary-override">actors/tick_1.unit</string>
%endif
		<vec2 name="beastiary-offset">-3 0</vec2>
		<string name="quality">common</string>
	
		<string name="type">beast</string>
		<int name="hp">12</int>
		<int name="armor">25</int>
		<int name="experience-reward">20</int>
		<float name="mp-scale-fact">0.2</float>
		
		<int name="unit-height">14</int>
		
		<string name="death-snd">event:/enemy/tick/death</string>
		<string name="gore">effects/gibs/gib_tick_1.sval</string>
		<string name="loot">actors/loot.sval:tick_1</string>
		
		<int name="aggro-range">130</int>
		
%include "actors/extra/debuff_scaling_normal.inc"

		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<float name="speed">MOVESPEED</float>
			<int name="dist">12</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">100</int>
				<int name="castpoint">450</int>
				<int name="range">16</int>
				<int name="dmg-range">18</int>
				<int name="arc">90</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">20</int>
					<bool name="melee">true</bool>
				</dict>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" charge-through="true" radius="6" />
			</collision>
		</scene>

		<scene name="idle-0">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">40 20 20 20</frame>
				<frame time="1500">100 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">40 0 20 20</frame>
				<frame time="1500">100 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">20 0 20 20</frame>
				<frame time="1500">80 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">0 0 20 20</frame>
				<frame time="1500">60 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">0 20 20 20</frame>
				<frame time="1500">60 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">0 40 20 20</frame>
				<frame time="1500">60 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">20 40 20 20</frame>
				<frame time="1500">80 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">40 40 20 20</frame>
				<frame time="1500">100 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">160 20 20 20</frame>
				<frame time="150">220 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">160 0 20 20</frame>
				<frame time="150">220 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">140 0 20 20</frame>
				<frame time="150">200 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">120 0 20 20</frame>
				<frame time="150">180 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">120 20 20 20</frame>
				<frame time="150">180 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">120 40 20 20</frame>
				<frame time="150">180 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">140 40 20 20</frame>
				<frame time="150">200 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
		<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="150">160 40 20 20</frame>
				<frame time="150">220 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">40 80 20 20</frame>
				<frame time="200">100 80 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">40 60 20 20</frame>
				<frame time="200">100 60 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">20 60 20 20</frame>
				<frame time="200">80 60 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">0 60 20 20</frame>
				<frame time="200">60 60 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">0 80 20 20</frame>
				<frame time="200">60 80 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">0 100 20 20</frame>
				<frame time="200">60 100 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">20 100 20 20</frame>
				<frame time="200">80 100 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		<scene src="shared" />
			<sprite origin="10 12" looping="false" texture="actors/tick_1.png" material="system/default.mats:actor">
				<frame time="400">40 100 20 20</frame>
				<frame time="200">100 100 20 20</frame>
			</sprite>
		</scene>
	</scenes>
</unit>