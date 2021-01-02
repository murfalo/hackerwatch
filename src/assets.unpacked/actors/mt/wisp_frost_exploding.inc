<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.wisp_frost_exploding</string>
%else
		<string name="beastiary-override">actors/mt/wisp_frost_exploding.unit</string>
%endif
		<string name="beastiary-scene">idle</string>
		<vec2 name="beastiary-offset">-1 -2</vec2>
		<string name="quality">common</string>
		<string name="dlc">mt</string>

		<string name="type">aberration</string>
		<int name="hp">500</int>
		<int name="armor">15</int>
		<int name="resistance">15</int>
		<int name="experience-reward">45</int>

		<string name="death-snd">event:/enemy/wisp/death</string>
		<string name="loot">actors/loot.sval:wisp_frost</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
			<string>freezing</string>
			<string>slippery</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">idle</string>

			<float name="speed">2.2</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">explode</string>
				<string name="start-snd">event:/enemy/wisp/whirl</string>

				<int name="cooldown">0</int>
				<int name="castpoint">650</int>
				
				<int name="range">16</int>
				<bool name="must-see">false</bool>
				<array name="actions">
%if !NORMAL || TIER2
					<dict name="action">
						<string name="class">Nova</string>
						<string name="projectile">actors/mt/projectiles/wisp_ball.unit</string>
						<int name="projectiles">NOVANUM</int>
						<float name="proj-dist">6</float>
					</dict>
%endif
					<dict name="action">
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>

%if !NORMAL
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">SPEEDCD</int>
				
				<array name="effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:wisp-speed</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
%endif

<!-- %if !NORMAL -->
			<!-- <dict> -->
				<!-- <string name="class">CompositeActorAuraSkill</string> -->
				<!-- <bool name="friendly">false</bool> -->
				<!-- <string name="buff">actors/buffs.sval:freezing_short</string> -->
				<!-- <int name="freq">200</int> -->
				<!-- <int name="range">28</int> -->
			<!-- </dict> -->
<!-- %endif -->

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
%if NORMAL
						<string name="unit">actors/mt/wisp_frost_exploding_bomb.unit</string>
%else
						<string name="unit">actors/mt/wisp_frost_exploding_bomb_ng.unit</string>
%endif
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" />
			</collision>
			<light pos="0 -2">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<looping value="true" />
				<cast-shadows value="true" />
				<overbright value="3" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="50 150 200 1 255" />
				</colors>
			</light>
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<sprite ulayer="-1" origin="5 5" looping="true" texture="actors/mt/wisp_frost_exploding.png" material="system/default.mats:actor-noxray">
				<frame >8 21 10 10</frame>
			</sprite>
			<sprite ulayer="-2" origin="8 8" looping="true" texture="actors/mt/wisp_frost_exploding.png" material="system/default.mats:actor">
				<frame time="100">48 0 16 16</frame>
				<frame time="100">32 0 16 16</frame>
				<frame time="100">32 16 16 16</frame>
				<frame time="100">32 0 16 16</frame>
			</sprite>
			<effect ulayer="-3" pos="0 0" src="actors/mt/wisp_frost_exploding_idle.effect"/>
		</scene>

		<scene name="explode">
			<!-- <scene src="shared" /> -->
			<collision static="false">
				<circle offset="0 0" sensor="true" aim-through="true" radius="5" charge-through="true" />
			</collision>
			
			<effect ulayer="-3" pos="0 0" src="actors/mt/wisp_frost_exploding_attack.effect"/>
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="810" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="1" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="128" />
					<size value="0" />
				</sizes>
				<colors>
					<color value="50 150 200 25 255" />
				</colors>
			</light>
		</scene>
	</scenes>
</unit>