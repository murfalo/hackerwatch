<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.maggot_1_elite</string>
%else
		<string name="beastiary-override">actors/maggot_1_elite.unit</string>
%endif
		<string name="quality">uncommon</string>

		<string name="type">beast</string>
		<int name="hp">50</int>
		<int name="armor">10</int>
		<int name="resistance">20</int>
		<int name="experience-reward">35</int>
		<float name="mp-scale-fact">0.65</float>
		
		<int name="unit-height">14</int>
		
		<string name="death-snd">event:/enemy/maggot/death</string>
		<string name="gore">effects/gibs/gib_maggot_elite.sval</string>
		<string name="loot">actors/loot.sval:maggot_1_elite</string>
	
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"

		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<bool name="strafing">false</bool>
			<float name="speed">1.125</float>
			<int name="dist">90</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">shoot-pos</string>

				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">500</int>
				<int name="range">110</int>
				<bool name="good-aim">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">SHOOTNUM</int>
						<int name="spread">SHOOTSPREAD</int>
						<string name="projectile">SHOOTPROJ</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6" charge-through="true" />
			</collision>
		</scene>

		<scene name="idle-0">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame>64 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame>0 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="150">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">160 32 32 32</frame>
				<frame time="200">256 32 32 32</frame>
				<frame time="150">64 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">160 0 32 32</frame>
				<frame time="200">256 0 32 32</frame>
				<frame time="150">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">128 0 32 32</frame>
				<frame time="200">224 0 32 32</frame>
				<frame time="150">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">96 0 32 32</frame>
				<frame time="200">192 0 32 32</frame>
				<frame time="150">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">96 32 32 32</frame>
				<frame time="200">192 32 32 32</frame>
				<frame time="150">0 32 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">96 64 32 32</frame>
				<frame time="200">192 64 32 32</frame>
				<frame time="150">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">128 64 32 32</frame>
				<frame time="200">224 64 32 32</frame>
				<frame time="150">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
		<scene src="shared" />
			<sprite origin="16 17" looping="true" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="300">160 64 32 32</frame>
				<frame time="200">256 64 32 32</frame>
				<frame time="150">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
		<scene src="shared" />
		<locator name="shoot-pos" pos="12 1" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">64 128 32 32</frame>
				<frame time="300">160 128 32 32</frame>
				<frame time="100">256 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		<scene src="shared" />
		<locator name="shoot-pos" pos="8 -6" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">64 96 32 32</frame>
				<frame time="300">160 96 32 32</frame>
				<frame time="100">256 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
		<scene src="shared" />
		<locator name="shoot-pos" pos="0 -10" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">32 96 32 32</frame>
				<frame time="300">128 96 32 32</frame>
				<frame time="100">224 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		<scene src="shared" />
		<locator name="shoot-pos" pos="-8 -6" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">0 96 32 32</frame>
				<frame time="300">96 96 32 32</frame>
				<frame time="100">192 96 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		<scene src="shared" />
		<locator name="shoot-pos" pos="-12 1" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">0 128 32 32</frame>
				<frame time="300">96 128 32 32</frame>
				<frame time="100">192 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		<scene src="shared" />
		<locator name="shoot-pos" pos="-8 6" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">0 160 32 32</frame>
				<frame time="300">96 160 32 32</frame>
				<frame time="100">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		<scene src="shared" />
		<locator name="shoot-pos" pos="1 12" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">32 160 32 32</frame>
				<frame time="300">128 160 32 32</frame>
				<frame time="100">224 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		<scene src="shared" />
		<locator name="shoot-pos" pos="8 6" />
			<sprite origin="16 17" looping="false" texture="actors/maggot_1_elite.png" material="system/default.mats:actor">
				<frame time="200">64 160 32 32</frame>
				<frame time="300">160 160 32 32</frame>
				<frame time="100">256 160 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
