<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_flower_1</string>
%else
		<string name="beastiary-override">actors/tower_flower_1.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 -2</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">aberration</string>
		<int name="hp">150</int>
		<int name="armor">5</int>
		<int name="resistance">20</int>
		<int name="experience-reward">65</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/flower/death</string>
		<string name="gore">effects/gibs/gib_flower_1.sval</string>
		<string name="loot">actors/loot.sval:tower_flower_1</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">150</int>		

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static_flower.inc"
		</array>

		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>
		
		<array name="skills">
			%// Attack
			<dict>
%if NORMAL || TIER2
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack</string>
				<int name="castpoint">250</int>
%else
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack-fast</string>
				<int name="burst">SHOOTBURST</int>
				<int name="castpoint">150</int>
%endif
				<string name="snd">event:/enemy/flower/hit</string>

				<int name="cooldown">SHOOTCD</int>
				<int name="range">200</int>	
				<bool name="good-aim">GOODAIM</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<int name="dist">18</int>
						<int name="spread">SHOOTSPREAD</int>				
						<string name="projectile">actors/projectiles/tower_groundspikes.unit</string>
					</dict>	
				</array>
			</dict>

			%// NG Nova
%if !NORMAL
			<dict>
				<string name="class">NovaSkill</string>
				<string name="anim">nova</string>
				<string name="fire-snd">event:/enemy/flower/hit</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown">NOVACD</int>
				<int name="castpoint">1200</int>
				<int name="range">200</int>
				
				<int name="proj-count">NOVACOUNT</int>
				<float name="proj-dist">18</float>
				<string name="projectile">actors/projectiles/tower_groundspikes.unit</string>
			</dict>
%endif

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/tower_flower_1_razed.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="default">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="15" />
			</collision>
		</scene>

		<scene name="default">
			<scene src="shared" />
			<sprite origin="20 20" looping="true" texture="actors/tower_flower_1.png" material="system/default.mats:actor">
				<frame time="100">120 0 40 40</frame>
			</sprite>
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<sprite origin="20 20" looping="false" texture="actors/tower_flower_1.png" material="system/default.mats:actor">
				<frame time="100">80 0 40 40</frame>
				<frame time="100">40 0 40 40</frame>
				<frame time="250">0 0 40 40</frame>
				<frame time="100">40 0 40 40</frame>
				<frame time="100">80 0 40 40</frame>
			</sprite>
		</scene>

		<scene name="attack-fast">
			<scene src="shared" />
			<sprite origin="20 20" looping="false" texture="actors/tower_flower_1.png" material="system/default.mats:actor">
				<frame time="50">80 0 40 40</frame>
				<frame time="50">40 0 40 40</frame>
				<frame time="100">0 0 40 40</frame>
				<frame time="50">40 0 40 40</frame>
				<frame time="50">80 0 40 40</frame>
			</sprite>
		</scene>

		<scene name="nova">
			<scene src="shared" />
			<sprite origin="20 20" looping="false" texture="actors/tower_flower_1.png" material="system/default.mats:actor">
				<frame time="500">120 0 40 40</frame>
				<frame time="150">80 0 40 40</frame>
				<frame time="150">40 0 40 40</frame>
				<frame time="150">0 0 40 40</frame>
				<frame time="150">40 0 40 40</frame>
				<frame time="50">80 0 40 40</frame>
				<frame time="50">40 0 40 40</frame>
				
				<frame time="250">0 0 40 40</frame>
				<frame time="100">40 0 40 40</frame>
				<frame time="100">80 0 40 40</frame>
				
				<frame time="1000">120 0 40 40</frame>
			</sprite>
		</scene>
		<scene name="portrait">
			<sprite origin="10 10" looping="true" texture="actors/tower_flower_1.png" material="system/default.mats:actor">
				<frame time="100">10 10 20 20</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
