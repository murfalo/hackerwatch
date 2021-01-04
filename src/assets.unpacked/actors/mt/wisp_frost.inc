<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.wisp_frost</string>
%else
		<string name="beastiary-override">actors/mt/wisp_frost.unit</string>
%endif
		<string name="beastiary-scene">idle</string>
		<vec2 name="beastiary-offset">-1 -2</vec2>
		<string name="quality">common</string>
		<string name="dlc">mt</string>

		<string name="type">aberration</string>
		<int name="hp">110</int>
		<int name="armor">35</int>
		<int name="resistance">35</int>
		<int name="experience-reward">80</int>

		<string name="death-snd">event:/enemy/mt_wisp/death</string>
		<string name="gore">effects/gibs/gib_wisp_1.sval</string>
		<string name="loot">actors/loot.sval:wisp_frost</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
			<string>freezing</string>
			<string>slippery</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">idle</string>

			<float name="speed">2.2</float>
			<int name="min-dist">70</int>
			<int name="dist">140</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">WhirlNovaSkill</string>
				<string name="anim">attack</string>
				<string name="fire-snd">event:/enemy/mt_wisp/attack</string>
				
				<int name="cooldown-start">400</int>
				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">500</int>
				<int name="min-range">50</int>
				<int name="range">140</int>
				<bool name="must-see">true</bool>
				
				<bool name="hold-dir">true</bool>
				<int name="duration">WHIRLDUR</int>
				<bool name="targeted">true</bool>
				<int name="angle-offset">ANGLEOFFSET</int>
				
				<string name="projectile">actors/mt/projectiles/wisp_ball.unit</string>
				<float name="proj-dist">6</float>
				<int name="proj-delay">WHIRLPROJDELAY</int>
				<int name="per-revolution">WHIRLPERREV</int>
			</dict>

<!--  			<dict>
				<string name="class">CompositeActorPeriodicTriggeredSkill</string>
				<string name="trigger">OnTime</string>
				<string name="anim">attack</string>
				<int name="period">2000</int>
				
				<int name="range">200</int>
				<bool name="must-see">true</bool>
				
				<dict name="action">
					<string name="class">Nova</string>
					<string name="projectile">actors/mt/projectiles/wisp_ball.unit</string>
					<int name="projectiles">5</int>
					<float name="proj-dist">6</float>
				</dict>
			</dict> -->
			
%if !NORMAL
			<dict>
				<string name="class">CompositeActorAuraSkill</string>
				<bool name="friendly">false</bool>
				<string name="buff">actors/buffs.sval:freezing_short</string>
				<int name="freq">200</int>
				<int name="range">28</int>
			</dict>
%endif

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
%if NORMAL
						<string name="unit">actors/mt/wisp_frost_bomb.unit</string>
%else
						<string name="unit">actors/mt/wisp_frost_bomb_ng.unit</string>
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
			<sprite ulayer="-1" origin="7 7" looping="true" texture="actors/mt/wisp_frost.png" material="system/default.mats:actor">
				<frame >0 0 14 14</frame>
			</sprite>
			<sprite ulayer="-2" origin="10 10" looping="true" texture="actors/mt/wisp_frost.png" material="system/default.mats:actor">
				<frame >0 44 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<sprite ulayer="1" origin="8 5" looping="true" texture="actors/mt/wisp_frost.png" material="system/default.mats:actor">
				<frame time="250">14 0 16 11</frame>
				<frame time="250">14 11 16 11</frame>
				<frame time="250">14 22 16 11</frame>
				<frame time="250">14 33 16 11</frame>
			</sprite>
			<effect pos="0 0" src="actors/mt/wisp_frost_idle.effect"/>
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<light pos="0 -2">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="500" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="3" />
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
			<sprite ulayer="1" origin="8 5" looping="true" texture="actors/mt/wisp_frost.png" material="system/default.mats:actor">
				<frame time="50">14 0 16 11</frame>
				<frame time="50">14 11 16 11</frame>
				<frame time="50">14 22 16 11</frame>
				<frame time="50">14 33 16 11</frame>
			</sprite>
			<effect  pos="0 0" src="actors/mt/wisp_frost_attack.effect"/>
		</scene>
	</scenes>
</unit>