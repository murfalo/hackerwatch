<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehaviorColorized">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.battlemage</string>
%else
		<string name="beastiary-override">actors/battlemage.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">-2 -2</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">undead</string>
		<int name="hp">275</int>
		<int name="armor">80</int>
		<int name="resistance">80</int>
		<int name="experience-reward">95</int>
		<float name="mp-scale-fact">0.65</float>
		
		<float name="evade-magical">EVASION</float>
		<string name="evade-fx">effects/mana_shield.effect</string>
		
		<string name="death-snd">event:/enemy/lich/death</string>
		<string name="gore">effects/gibs/gib_skeleton_battlemage.sval</string>
		<string name="loot">actors/loot.sval:lich_1</string>

%include "actors/extra/debuff_scaling_normal.inc"

		<int name="aggro-range">130</int>
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_paladin</string>
		</array>
		
		<float name="colorize-speed">4</float>
		<array name="colorize">
			<vec3>0.1 0.1 1</vec3>
			<vec3>0 1 0</vec3>
		</array>
		
		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.9</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">100</int>
				<int name="castpoint">500</int>
				<int name="range">14</int>
				<int name="dmg-range">18</int>
				<int name="arc">90</int>
				
				<dict name="effect">
					<string name="class">Damage</string>
					<int name="physical">30</int>
					<int name="magical">30</int>
					<float name="resistance-mul">0.8</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>
			
			<dict>
				<string name="class">BlinkSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/lich/blink</string>
				<string name="fx">effects/blink.effect</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown-start">2500</int>
				<int name="cooldown">BLINKCD</int>
				<int name="castpoint">500</int>

				<int name="spread">5</int>
				<int name="min-range">60</int>
				<int name="range">120</int>
				<float name="distance">100</float>
				<float name="off-distance">10</float>

				<array name="blink-effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:blink-stop-melee</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>

			%// Normal
<!-- 			<dict>
				<array name="conditional">
					<string>ngp</string><string>lt</string><int>1</int>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/battlemage/shoot</string>
				
				<bool name="good-aim">true</bool>
				<bool name="must-see">true</bool>
				<int name="cooldown">1500</int>
				<int name="castpoint">500</int>
				<int name="min-range">18</int>
				<int name="range">50</int>	
				
				<dict name="action">
					<string name="class">ShootProjectile</string>
					<int name="dist">10</int>
					<string name="projectile">actors/projectiles/battlemage_lurker.unit</string>
				</dict>
			</dict>
			
			%// NG+
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>1</int>
					<string>ngp</string><string>lt</string><int>2</int>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/battlemage/shoot</string>
				
				<bool name="good-aim">false</bool>
				<bool name="must-see">true</bool>
				<int name="cooldown">1500</int>
				<int name="castpoint">500</int>
				<int name="min-range">18</int>
				<int name="range">50</int>
				
				<dict name="action">
					<string name="class">ShootProjectileFan</string>
					<int name="projectiles">3</int>
					<int name="dist">10</int>
					<int name="spread">60</int>
					<string name="projectile">actors/projectiles/battlemage_lurker.unit</string>
				</dict>
			</dict>
			
			%// NG+2 Seeking
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/battlemage/shoot</string>
				
				<bool name="good-aim">true</bool>
				<bool name="must-see">true</bool>
				<int name="cooldown">3000</int>
				<int name="castpoint">500</int>
				<int name="range">120</int>	
				
				<dict name="action">
					<string name="class">ShootProjectile</string>
					<int name="dist">10</int>
					<string name="projectile">actors/projectiles/battlemage_lurker_seeking.unit</string>
				</dict>
			</dict> -->

			<dict>
				<string name="class">SpewSkill</string>
				<string name="anim">attack 8</string>
				<string name="first-fire-snd">event:/enemy/battlemage/shoot</string>
				<string name="fire-snd">event:/enemy/battlemage/shoot</string>
				
				<int name="cooldown">SPEWCD</int>
				<int name="castpoint">500</int>
				<int name="duration">SPEWDUR</int>
				
				<int name="range">100</int>
				<int name="min-range">20</int>
				<int name="spread">SPEWSPREAD</int>
				<int name="rate">SPEWRATE</int>
				<bool name="good-aim">true</bool>
				<bool name="must-see">true</bool>
				<bool name="hold-dir">false</bool>
%if NORMAL || TIER2
				<string name="projectile">actors/projectiles/battlemage_lurker.unit</string>
%else
				<string name="projectile">actors/projectiles/battlemage_lurker_seeking.unit</string>
%endif
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
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">0 24 24 24</frame>
				<frame time="225">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">24 24 24 24</frame>
				<frame time="225">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">48 24 24 24</frame>
				<frame time="225">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">72 24 24 24</frame>
				<frame time="225">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">96 24 24 24</frame>
				<frame time="225">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">120 24 24 24</frame>
				<frame time="225">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">144 24 24 24</frame>
				<frame time="225">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="225">168 24 24 24</frame>
				<frame time="225">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">72 72 24 24</frame>
				<frame time="200">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/battlemage.tif" material="system/default.mats:actor">
				<frame time="500">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
		
		<scene name="portrait">
			<sprite origin="8 8" looping="false" texture="actors/battlemage.png" material="system/default.mats:actor">
				<frame time="450">197 4 16 17</frame>
			</sprite>
		</scene>
	</scenes>
</unit>