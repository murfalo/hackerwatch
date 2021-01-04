<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.vampire_2_ranged</string>
%else
		<string name="beastiary-override">actors/mt/vampire_2_ranged.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">common</string>
		<string name="dlc">mt</string>

		<string name="type">undead</string>
		<int name="hp">170</int>
		<int name="armor">50</int>
		<int name="resistance">20</int>
		<int name="experience-reward">95</int>
		
		<string name="death-snd">event:/enemy/vampire/death</string>
		<string name="gore">effects/gibs/gib_vampire_2_ranged.sval</string>
		<string name="loot">actor/loot.sval:vampire_2</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_paladin</string>
			<string>respawn_ghost_sorcerer</string>
			<string>respawn_thrall</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.3</float>
			<int name="min-dist">75</int>
			<int name="dist">150</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">SpewSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">attack-pos</string>
				<string name="first-fire-snd">event:/enemy/vampire/crossbow</string>

				<int name="range">170</int>
				<int name="min-range">50</int>
				<bool name="must-see">true</bool>
				
				<int name="cooldown-start">250</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">950</int>
				
				<int name="duration">SHOOTDUR</int>
				<int name="rate">SHOOTRATE</int>
				<int name="spread">SHOOTSPREAD</int>
				<bool name="hold-dir">false</bool>
				<bool name="ignore-is-casting">false</bool>
				<float name="aim-interception">-1</float>

				<string name="projectile">actors/mt/projectiles/vampire_2_crossbow_bolt.unit</string>
				
				<array name="start-actions">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:protection-pavise</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
		</array>
		
		<dict name="effect-params">
			<float name="length">170</float>
			<float name="height">3</float>
			<float name="arc">0.087</float>
		</dict>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" charge-through="true" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		</scene>
		
		<scene name="shared-attack">
			%if GAME
			<effect src="effects/aim_arc.effect" />
			%endif
		</scene>
		

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame>168 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">0 24 24 24</frame>
				<frame time="125">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">24 24 24 24</frame>
				<frame time="125">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">48 24 24 24</frame>
				<frame time="125">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">72 24 24 24</frame>
				<frame time="125">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">96 24 24 24</frame>
				<frame time="125">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">120 24 24 24</frame>
				<frame time="125">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">144 24 24 24</frame>
				<frame time="125">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="125">168 24 24 24</frame>
				<frame time="125">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">0 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">0 72 24 24</frame>
				<frame time="100">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">24 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">24 72 24 24</frame>
				<frame time="100">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">48 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">48 72 24 24</frame>
				<frame time="100">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">72 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">72 72 24 24</frame>
				<frame time="100">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">96 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">96 72 24 24</frame>
				<frame time="100">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">120 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">120 72 24 24</frame>
				<frame time="100">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">144 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">144 72 24 24</frame>
				<frame time="100">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="12 14" ulayer="1" looping="false" texture="actors/mt/vampire_2_ranged_eyes.png" material="system/default.mats:glow-both-bright">
				<frame time="950">168 0 24 16</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_ranged.png" material="system/default.mats:actor">
				<frame time="950">168 72 24 24</frame>
				<frame time="100">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
