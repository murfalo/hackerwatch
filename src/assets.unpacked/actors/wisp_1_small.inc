<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.wisp_1_small</string>
%else
		<string name="beastiary-override">actors/wisp_1.unit</string>
%endif
		<string name="beastiary-scene">idle</string>
		<vec2 name="beastiary-offset">-1 0</vec2>
		<string name="quality">common</string>

		<string name="type">aberration</string>
		<int name="hp">70</int>
		<int name="armor">25</int>
		<int name="resistance">25</int>
		<int name="experience-reward">50</int>

		<string name="death-snd">event:/enemy/wisp/death</string>
		<string name="gore">effects/gibs/gib_wisp_1_small.sval</string>
		<string name="loot">actors/loot.sval:wisp_1_small</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">walk</string>

			<float name="speed">2</float>
			<int name="min-dist">60</int>
			<int name="dist">120</int>
		</dict>

		<array name="skills">
			<dict>
%if NORMAL || TIER2
				<string name="class">CompositeActorSkill</string>
%else
				<string name="class">CompositeActorBurstSkill</string>
				<int name="burst">SHOOTBURST</int>
%endif
				<string name="anim">attack</string>
				<string name="snd">event:/enemy/wisp/attack</string>

				<int name="cooldown">400</int>
				<int name="castpoint">500</int>
				<int name="range">160</int>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">12</float>

				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/projectiles/wisp_1_small.unit</string>
%elif TIER2
						<string name="projectile">actors/projectiles/wisp_1_small_ng.unit</string>
%else
						<string name="projectile">actors/projectiles/wisp_1_small_ng.unit</string>
						<int name="spread">SHOOTSPREAD</int>
%endif
					</dict>
				</array>
			</dict>

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
%if NORMAL
						<string name="unit">actors/wisp_1_small_bomb.unit</string>
%elif TIER2
						<string name="unit">actors/wisp_1_bomb_ng.unit</string>
%else
						<string name="unit">actors/wisp_1_bomb_ng_2.unit</string>
%endif
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<sprite origin="10 12" looping="true" texture="actors/wisp_1_small.png" material="system/default.mats:xray">
				<frame time="125">0 0 20 20</frame>
			</sprite>
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
					<size value="50" />
				</sizes>
				<colors>
					<color value="150 255 150 1 255" />
				</colors>
			</light>
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/wisp_1_small.png" material="system/default.mats:actor-noxray">
				<frame time="125">0 0 20 20</frame>
				<frame time="125">20 0 20 20</frame>
				<frame time="125">40 0 20 20</frame>
				<frame time="125">60 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/wisp_1_small.png" material="system/default.mats:actor-noxray">
				<frame time="125">0 0 20 20</frame>
				<frame time="125">20 0 20 20</frame>
				<frame time="125">40 0 20 20</frame>
				<frame time="125">60 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<sprite origin="20 12" looping="false" texture="actors/wisp_1_small.png" material="system/default.mats:actor-noxray">
				<frame time="300">0 20 40 20</frame>
				<frame time="200">40 20 40 20</frame>
				<frame time="100">80 20 40 20</frame>
				<frame time="50">40 20 40 20</frame>
				<frame time="50">0 20 40 20</frame>
			</sprite>
		</scene>
	</scenes>
</unit>