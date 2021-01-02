<unit netsync="position" slot="actor" layer="-1">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_battlement_archer_1_elite</string>
%else
		<string name="beastiary-override">actors/tower_battlement_archer_1_elite.unit</string>
%endif
		<vec2 name="beastiary-offset">-1 2</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">construct</string>
		<int name="hp">300</int>
		<int name="armor">40</int>
		<int name="resistance">20</int>
		<int name="experience-reward">125</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/tower/death</string>
		<string name="gore">effects/gibs/gib_generic_stone.sval</string>
		<string name="loot">actors/loot.sval:tower_battlement.unit</string>
		
		<int name="aggro-range">150</int>
		<bool name="impenetrable">true</bool>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>

		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">idle 8</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">walk 8</string>
				
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">500</int>
				<int name="range">215</int>
				<bool name="good-aim">GOODAIM</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">PROJECTILENUM</int>
						<int name="spread">35</int>
						<string name="projectile">actors/projectiles/arrow_1.unit</string>
					</dict>
				</array>
			</dict>

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tower_battlement_archer_razed.unit</string>
					</dict>
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/archer_1_elite.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<rect shoot-through="false" aim-through="true">-16 -16 32 32</rect>
			</collision>	
		</scene>

		<scene name="idle-0">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>0 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-7">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>32 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>64 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-5">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>96 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-4">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>128 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-3">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>160 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-2">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>192 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-1">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="true" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame>224 0 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-0">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">0 0 32 32</frame>
			<frame time="SHOOTCD">0 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-7">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">32 0 32 32</frame>
			<frame time="SHOOTCD">32 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-6">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">64 0 32 32</frame>
			<frame time="SHOOTCD">64 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-5">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">96 0 32 32</frame>
			<frame time="SHOOTCD">96 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-4">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">128 0 32 32</frame>
			<frame time="SHOOTCD">128 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-3">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">160 0 32 32</frame>
			<frame time="SHOOTCD">160 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-2">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">192 0 32 32</frame>
			<frame time="SHOOTCD">192 32 32 32</frame>
		  </sprite>
		</scene>

		<scene name="walk-1">
		  <scene src="shared" />
		  <sprite origin="16 16" looping="false" texture="actors/tower_battlement_archer_1_elite.png" material="system/default.mats:actor">
			<frame time="500">224 0 32 32</frame>
			<frame time="SHOOTCD">224 32 32 32</frame>
		  </sprite>
		</scene>
	</scenes>
</unit>
