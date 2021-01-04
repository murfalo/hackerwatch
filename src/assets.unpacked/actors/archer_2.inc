<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.archer_2</string>
%else
		<string name="beastiary-override">actors/archer_2.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">common</string>
	
		<string name="type">undead</string>
		<int name="hp">150</int>
		<int name="armor">40</int>
		<int name="resistance">20</int>
		<int name="experience-reward">85</int>
		
		<string name="death-snd">event:/enemy/skeleton/death</string>
		<string name="gore">effects/gibs/gib_archer_2.sval</string>
		<string name="loot">actor/loot.sval:archer_2</string>
		
		<int name="aggro-range">150</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_paladin</string>
			<string>respawn_ghost_sorcerer</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.5</float>
			<int name="min-dist">75</int>
			<int name="dist">175</int>
		</dict>

		<array name="skills">
			<dict>
%if NORMAL || TIER2
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<int name="castpoint">500</int>
%else
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack-fast 8</string>
				<int name="castpoint">200</int>
				<int name="burst">SHOOTBURST</int>
%endif
				<int name="cooldown">900</int>
				<int name="range">200</int>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>

				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<int name="dist">4</int>
						<string name="projectile">actors/projectiles/arrow_3.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" charge-through="true" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">0 24 24 24</frame>
				<frame time="125">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">24 24 24 24</frame>
				<frame time="125">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">48 24 24 24</frame>
				<frame time="125">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">72 24 24 24</frame>
				<frame time="125">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">96 24 24 24</frame>
				<frame time="125">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">120 24 24 24</frame>
				<frame time="125">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">144 24 24 24</frame>
				<frame time="125">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="125">168 24 24 24</frame>
				<frame time="125">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">0 72 24 24</frame>
				<frame time="500">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">24 72 24 24</frame>
				<frame time="500">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">48 72 24 24</frame>
				<frame time="500">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">72 96 24 24</frame>
				<frame time="500">72 72 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">96 72 24 24</frame>
				<frame time="500">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">120 72 24 24</frame>
				<frame time="500">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">144 72 24 24</frame>
				<frame time="500">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="500">168 72 24 24</frame>
				<frame time="500">168 96 24 24</frame>
			</sprite>
		</scene>
		
		<scene name="attack-fast-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">72 96 24 24</frame>
				<frame time="200">72 72 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/archer_2.png" material="system/default.mats:actor">
				<frame time="200">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
