<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_flower_frost</string>
%else
		<string name="beastiary-override">actors/mt/tower_flower_frost.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 -2</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">aberration</string>
		<int name="hp">500</int>
		<int name="armor">20</int>
		<int name="resistance">50</int>
		<int name="experience-reward">175</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/flower_frost/death</string>
		<string name="gore">effects/gibs/gib_flower_frost.sval</string>
		<string name="loot">actors/loot.sval:tower_flower_frost</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">300</int>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static_flower.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>
		
		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 4 45</string>
				<string name="snd">event:/enemy/flower_frost/attack</string>
				
				<bool name="must-see">false</bool>
				<int name="cooldown-start">0</int>
				<int name="cooldown">ATTACKCD</int>
				<int name="castpoint">900</int>
				<int name="min-range">0</int>
				<int name="range">ATTACKRANGE</int>
				<bool name="good-aim">true</bool>

				<dict name="action">
					<string name="class">DummyHitscan</string>
					<array name="effects">
						<dict>
							<string name="class">SpawnUnit</string>
%if NORMAL
							<string name="unit">actors/mt/projectiles/tower_flower_frost_spike_nova.unit</string>
%else
							<string name="unit">actors/mt/projectiles/tower_flower_frost_spike_nova_ng.unit</string>
%endif
							<bool name="safe-spawn">false</bool>
							<vec2 name="jitter">2 2</vec2>
						</dict>	
					</array>
				</dict>
			</dict>

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/tower_flower_frost_razed.unit</string>
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
			<sprite origin="17 16" looping="true" texture="actors/mt/tower_flower_frost.png" material="system/default.mats:actor">
				<frame time="100">0 132 34 33</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="17 16" looping="false" texture="actors/mt/tower_flower_frost.png" material="system/default.mats:actor">
				<frame time="200">0 0 34 33</frame>
				<frame time="200">34 0 34 33</frame>
				<frame time="500">68 0 34 33</frame>
				<frame time="80">102 0 34 33</frame>
				<frame time="500">136 0 34 33</frame>
				<frame time="100">170 0 34 33</frame>
				<frame time="100">204 0 34 33</frame>
			</sprite>
		</scene>
		
		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="17 16" looping="false" texture="actors/mt/tower_flower_frost.png" material="system/default.mats:actor">
				<frame time="200">0 33 34 33</frame>
				<frame time="200">34 33 34 33</frame>
				<frame time="500">68 33 34 33</frame>
				<frame time="80">102 33 34 33</frame>
				<frame time="500">136 33 34 33</frame>
				<frame time="100">170 33 34 33</frame>
				<frame time="100">204 33 34 33</frame>
			</sprite>
		</scene>
		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="17 16" looping="false" texture="actors/mt/tower_flower_frost.png" material="system/default.mats:actor">
				<frame time="200">0 66 34 33</frame>
				<frame time="200">34 66 34 33</frame>
				<frame time="500">68 66 34 33</frame>
				<frame time="80">102 66 34 33</frame>
				<frame time="500">136 66 34 33</frame>
				<frame time="100">170 66 34 33</frame>
				<frame time="100">204 66 34 33</frame>
			</sprite>
		</scene>
		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="17 16" looping="false" texture="actors/mt/tower_flower_frost.png" material="system/default.mats:actor">
				<frame time="200">0 99 34 33</frame>
				<frame time="200">34 99 34 33</frame>
				<frame time="500">68 99 34 33</frame>
				<frame time="80">102 99 34 33</frame>
				<frame time="500">136 99 34 33</frame>
				<frame time="100">170 99 34 33</frame>
				<frame time="100">204 99 34 33</frame>
			</sprite>
		</scene>

		<scene name="portrait">
			<sprite origin="10 10" looping="true" texture="actors/tower_flower_2.png" material="system/default.mats:actor">
				<frame time="100">10 10 20 20</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
