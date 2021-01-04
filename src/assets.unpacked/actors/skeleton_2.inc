<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.skeleton_2</string>
%else
		<string name="beastiary-override">actors/skeleton_2.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">common</string>

		<string name="type">undead</string>
		<int name="hp">210</int>
		<int name="armor">60</int>
		<int name="resistance">20</int>
		<int name="experience-reward">75</int>
		<float name="mp-scale-fact">0.2</float>
		
		<string name="death-snd">event:/enemy/skeleton/death</string>
		<string name="gore">effects/gibs/gib_skeleton_2.sval</string>
		<string name="loot">actor/loot.sval:skeleton_2</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_sorcerer</string>
		</array>
		
		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
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
					<int name="physical">90</int>
					<float name="armor-mul">ARMORMUL</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" charge-through="true" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">0 24 24 24</frame>
				<frame time="225">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">24 24 24 24</frame>
				<frame time="225">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">48 24 24 24</frame>
				<frame time="225">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">72 24 24 24</frame>
				<frame time="225">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">96 24 24 24</frame>
				<frame time="225">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">120 24 24 24</frame>
				<frame time="225">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">144 24 24 24</frame>
				<frame time="225">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="225">168 24 24 24</frame>
				<frame time="225">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">72 72 24 24</frame>
				<frame time="200">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/skeleton_2.png" material="system/default.mats:actor">
				<frame time="400">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>