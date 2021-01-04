<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.eye_1_small</string>
%else
		<string name="beastiary-override">actors/eye_1_small.unit</string>
%endif
		<string name="quality">common</string>
		
		<string name="type">aberration</string>
		<int name="hp">80</int>
		<int name="armor">20</int>
		<int name="resistance">40</int>
		<int name="experience-reward">55</int>
		
		<int name="unit-height">14</int>

		<string name="death-snd">event:/enemy/eye/death</string>
		<string name="gore">effects/gibs/gib_eye_1_small.sval</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<float name="roaming">1</float>
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
					<int name="physical">45</int>
					<float name="armor-mul">ARMORMUL</float>
					<bool name="melee">true</bool>
				</dict>
			</dict>

			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">ChargeStrike</string>
				<string name="anim">charge 8</string>

				<int name="range">70</int>
				<int name="min-range">50</int>
				
				<int name="cooldown">CHARGECD</int>
				
				<int name="hold-frame">200</int>
				<float name="speed">6</float>	
				<int name="air-time">400</int>
				<int name="jump-height">10</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">3</int>
				<int name="ray-width">4</int>
				<float name="ray-length">3</float>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">20</int>
						<float name="armor-mul">ARMORMUL</float>
						<bool name="melee">true</bool>
					</dict>
				</array>
				
				<array name="finish-effects">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">effects/animations/dust.effect</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" charge-through="true" />
			</collision>
		</scene>
		
		<scene name="shared-charge">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" radius="4" sensor="false" shoot-through="false" aim-through="true" charging="true" charge-through="true" />
			</collision>
			<sprite origin="4 4" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame>0 0 8 8</frame>
			</sprite>
		</scene>

		<scene name="idle-0">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">40 20 20 20</frame>
			<frame time="250">100 20 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-7">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">40 0 20 20</frame>
			<frame time="250">100 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">20 0 20 20</frame>
			<frame time="250">80 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-5">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">0 0 20 20</frame>
			<frame time="250">60 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-4">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">0 20 20 20</frame>
			<frame time="250">60 20 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-3">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">0 40 20 20</frame>
			<frame time="250">60 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-2">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">20 40 20 20</frame>
			<frame time="250">80 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="idle-1">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="250">40 40 20 20</frame>
			<frame time="250">100 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-0">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">160 20 20 20</frame>
			<frame time="150">220 20 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-7">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">160 0 20 20</frame>
			<frame time="150">220 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-6">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">140 0 20 20</frame>
			<frame time="150">200 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-5">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">120 0 20 20</frame>
			<frame time="150">180 0 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-4">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">120 20 20 20</frame>
			<frame time="150">180 20 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-3">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">120 40 20 20</frame>
			<frame time="150">180 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-2">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">140 40 20 20</frame>
			<frame time="150">200 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="walk-1">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="true" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="150">160 40 20 20</frame>
			<frame time="150">220 40 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-0">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">40 80 20 20</frame>
			<frame time="200">100 80 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-7">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">40 60 20 20</frame>
			<frame time="200">100 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-6">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">20 60 20 20</frame>
			<frame time="200">80 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-5">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">0 60 20 20</frame>
			<frame time="200">60 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-4">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">0 80 20 20</frame>
			<frame time="200">60 80 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-3">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">0 100 20 20</frame>
			<frame time="200">60 100 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-2">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">20 100 20 20</frame>
			<frame time="200">80 100 20 20</frame>
		  </sprite>
		</scene>

		<scene name="attack-1">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="400">40 100 20 20</frame>
			<frame time="200">100 100 20 20</frame>
		  </sprite>
		</scene>
		
		<scene name="charge-0">
		  <scene src="shared" />
		  <sprite origin="10 12" looping="false" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="550">40 80 20 20</frame>
			<frame time="50">100 80 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-0">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">100 80 20 20</frame>
			<frame time="50">40 80 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-7">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">100 60 20 20</frame>
			<frame time="50">40 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-6">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">80 60 20 20</frame>
			<frame time="50">20 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-5">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">60 60 20 20</frame>
			<frame time="50">0 60 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-4">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">60 80 20 20</frame>
			<frame time="50">0 80 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-3">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">60 100 20 20</frame>
			<frame time="50">0 100 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-2">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">80 100 20 20</frame>
			<frame time="50">20 100 20 20</frame>
		  </sprite>
		</scene>

		<scene name="charge-1">
		  <scene src="shared-charge" />
		  <sprite origin="10 12" loopback="200" texture="actors/eye_1_small.png" material="system/default.mats:actor">
			<frame time="200">100 100 20 20</frame>
			<frame time="50">40 100 20 20</frame>
		  </sprite>
		</scene>
	</scenes>
</unit>