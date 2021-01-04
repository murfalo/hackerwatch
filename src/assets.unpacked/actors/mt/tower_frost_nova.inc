<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_frost_nova</string>
%else
		<string name="beastiary-override">actors/mt/tower_frost_nova.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 4</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">construct</string>
		<int name="hp">1000</int>
		<int name="armor">75</int>
		<int name="resistance">75</int>
		<int name="experience-reward">600</int>
		<float name="mp-scale-fact">0.75</float>

		<string name="death-snd">event:/enemy/tower/death</string>
		<string name="gore">effects/gibs/gib_tower_frost.sval</string>
		<string name="loot">actors/loot.sval:tower_frost_nova</string>

		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">true</bool>
		<int name="aggro-range">200</int>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack</string>
				<string name="snd">event:/enemy/tower_frost/shoot</string>

				<int name="cooldown-start">500</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">650</int>
				<int name="min-range">0</int>
				<int name="range">175</int>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">SHOOTAIM</float>

				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/tower_frost_orb.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/tower_frost_orb_ng.unit</string>
%endif
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="default">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="8" />
			</collision>
			<shadow>
				<sprite origin="-1 18" texture="actors/mt/tower_frost_nova.png" material="system/default.mats:default">
					<frame time="100">90 0 11 25</frame>
				</sprite>
			</shadow>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="1" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="0 255 255 0" />
				</colors>
			</light>	
		</scene>

		<scene name="default">
			<scene src="shared" />
			<sprite origin="9 23" looping="true" texture="actors/mt/tower_frost_nova.png" material="system/default.mats:actor">
				<frame time="100">0 0 18 30</frame>
				<frame time="100">18 0 18 30</frame>
			</sprite>
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="1" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="90" />
					<size value="64" />
				</sizes>
				<colors>
					<color value="0 255 255 0" />
				</colors>
			</light>				
			<sprite origin="9 23" looping="true" texture="actors/mt/tower_frost_nova.png" material="system/default.mats:actor">
				<frame time="50">18 30 18 30</frame>
				<frame time="50">36 30 18 30</frame>
				<frame time="50">54 30 18 30</frame>
				<frame time="50">72 30 18 30</frame>
				<frame time="50">54 30 18 30</frame>
				<frame time="50">36 30 18 30</frame>
				<frame time="50">18 30 18 30</frame>
				<frame time="50">36 30 18 30</frame>
				<frame time="50">54 30 18 30</frame>
				<frame time="50">72 30 18 30</frame>
				<frame time="50">54 30 18 30</frame>
				<frame time="50">36 30 18 30</frame>
				<frame time="50">18 30 18 30</frame>
				<frame time="100">72 0 18 30</frame>
				<frame time="100">0 30 18 30</frame>
			</sprite>
		</scene>
		<scene name="portrait">
			<sprite origin="9 23" looping="false" texture="actors/mt/tower_frost_nova.png" material="system/default.mats:actor">
				<frame time="50">0 0 18 30</frame>
			</sprite>
		</scene>
	</scenes>
</unit>