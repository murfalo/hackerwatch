<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.vampire_2_elite</string>
%else
		<string name="beastiary-override">actors/mt/vampire_2_elite.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">undead</string>
		<int name="hp">450</int>
		<int name="armor">60</int>
		<int name="resistance">30</int>
		<int name="experience-reward">100</int>
		<float name="mp-scale-fact">0.65</float>
		
		<string name="death-snd">event:/enemy/vampire/death</string>
		<string name="gore">effects/gibs/gib_vampire_2_elite.sval</string>
		<string name="loot">actor/loot.sval:vampire_2</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_sorcerer</string>
			<string>respawn_thrall</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.8</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">100</int>
				<int name="castpoint">450</int>
				<int name="range">14</int>
				<int name="dmg-range">18</int>
				<int name="arc">90</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/vampire/rapier_throw</string>

				<int name="cooldown-start">250</int>
				<int name="cooldown">2000</int>
				<int name="castpoint">450</int>
				<int name="range">140</int>
				<int name="min-range">50</int>
				<bool name="must-see">true</bool>
				
				<bool name="good-aim">true</bool>
				<float name="aim-interception">10</float>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<string name="projectile">actors/mt/projectiles/vampire_rapier_2.unit</string>
						<int name="projectiles">3</int>
						<int name="dist">6</int>
						<int name="spread">15</int>
					</dict>
				</array>
			</dict>
		
			<dict>
				<string name="class">BlinkSkill</string>
				<string name="anim">attack 8</string>
				<string name="fx">effects/animations/vampire_poof.effect</string>
				
				<int name="cooldown-start">2500</int>
				<int name="cooldown">5000</int>
				<int name="castpoint">50</int>
				<bool name="must-see">true</bool>
				<int name="min-range">50</int>
				<int name="range">60</int>

				<float name="distance">80</float>
				<float name="off-distance">20</float>
				
				<array name="blink-effects">
%if !NORMAL
					<dict name="effect">
						<string name="class">ShootRandomEnemy</string>
						<int name="range">100</int>
						<string name="projectile">actors/mt/projectiles/vampire_rapier_2.unit</string>
					</dict>
%endif
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:blink-stop-melee</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
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
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">0 24 24 24</frame>
				<frame time="225">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">24 24 24 24</frame>
				<frame time="225">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">48 24 24 24</frame>
				<frame time="225">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">72 24 24 24</frame>
				<frame time="225">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">96 24 24 24</frame>
				<frame time="225">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">120 24 24 24</frame>
				<frame time="225">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">144 24 24 24</frame>
				<frame time="225">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="225">168 24 24 24</frame>
				<frame time="225">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">72 72 24 24</frame>
				<frame time="200">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_2_elite.png" material="system/default.mats:actor">
				<frame time="400">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>