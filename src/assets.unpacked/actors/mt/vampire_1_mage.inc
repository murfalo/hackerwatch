<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.vampire_1_mage</string>
%else
		<string name="beastiary-override">actors/mt/vampire_1_mage.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">common</string>
		<string name="dlc">mt</string>

		<string name="type">undead</string>
		<int name="hp">150</int>
		<int name="armor">20</int>
		<int name="resistance">40</int>
		<int name="experience-reward">70</int>
		<float name="mp-scale-fact">0.2</float>
		
		<string name="death-snd">event:/enemy/vampire/death</string>
		<string name="gore">effects/gibs/gib_vampire_1.sval</string>
		<string name="loot">actors/loot.sval:vampire_mage</string>

		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_paladin</string>
			<string>respawn_thrall</string>
		</array>
		
		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.7</float>
			<int name="min-dist">40</int>
			<int name="dist">100</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/vampire/crescent_shoot</string>

				<int name="burst">SHOOTBURST</int>

				<int name="cooldown-start">250</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">500</int>
				<int name="range">140</int>
				<int name="min-range">40</int>
				<bool name="must-see">true</bool>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">16</float>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/vampire_mage_crescent.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/vampire_mage_crescent_ng.unit</string>
%endif
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">BlinkSkill</string>
				<string name="anim">attack 8</string>
				<string name="fx">effects/animations/vampire_poof.effect</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">BLINKCD</int>
				<int name="castpoint">500</int>
				<bool name="must-see">true</bool>
				<int name="min-range">0</int>
				<int name="range">40</int>
				
				<int name="spread">10</int>
				<float name="distance">100</float>
				<float name="off-distance">10</float>
				
				<array name="blink-effects">
<!-- 					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">0</int>
					</dict> -->
<!-- 					<dict name="effect">
						<string name="class">ShootRandomEnemy</string>
						<int name="range">100</int>
						<string name="projectile">actors/mt/projectiles/vampire_mage_crescent.unit</string>
					</dict> -->
<!-- 					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/projectiles/vampire_mage_crescent_area.unit</string>
					</dict> -->
%if !NORMAL
					<dict>
						<string name="class">Nova</string>
						<string name="projectile">actors/mt/projectiles/vampire_mage_crescent.unit</string>
						<int name="projectiles">3</int>
						<float name="proj-dist">6</float>
					</dict>
%endif
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:blink-stop-ranged</string>
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
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">0 24 24 24</frame>
				<frame time="125">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">24 24 24 24</frame>
				<frame time="125">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">48 24 24 24</frame>
				<frame time="125">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">72 24 24 24</frame>
				<frame time="125">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">96 24 24 24</frame>
				<frame time="125">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">120 24 24 24</frame>
				<frame time="125">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">144 24 24 24</frame>
				<frame time="125">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="125">168 24 24 24</frame>
				<frame time="125">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">0 72 24 24</frame>
				<frame time="500">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">24 72 24 24</frame>
				<frame time="500">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">48 72 24 24</frame>
				<frame time="500">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">72 72 24 24</frame>
				<frame time="500">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">96 72 24 24</frame>
				<frame time="500">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">120 72 24 24</frame>
				<frame time="500">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">144 72 24 24</frame>
				<frame time="500">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="500">168 72 24 24</frame>
				<frame time="500">168 96 24 24</frame>
			</sprite>
		</scene>
		
		<scene name="attack-fast-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">0 72 24 24</frame>
				<frame time="300">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">24 72 24 24</frame>
				<frame time="300">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">48 72 24 24</frame>
				<frame time="300">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">72 72 24 24</frame>
				<frame time="300">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">96 72 24 24</frame>
				<frame time="300">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">120 72 24 24</frame>
				<frame time="300">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">144 72 24 24</frame>
				<frame time="300">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/mt/vampire_1_mage.png" material="system/default.mats:actor">
				<frame time="300">168 72 24 24</frame>
				<frame time="300">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>