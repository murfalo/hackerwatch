<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.wisp_2</string>
%else
		<string name="beastiary-override">actors/wisp_2.unit</string>
%endif
		<string name="beastiary-scene">idle</string>
		<vec2 name="beastiary-offset">-1 0</vec2>
		<string name="quality">uncommon</string>

		<string name="type">aberration</string>
		<int name="hp">180</int>
		<int name="armor">45</int>
		<int name="resistance">45</int>
		<int name="experience-reward">90</int>

		<string name="death-snd">event:/enemy/wisp/death</string>
		<string name="gore">effects/gibs/gib_wisp_2.sval</string>
		<string name="loot">actors/loot.sval:wisp_2</string>
		
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
			<string>burning</string>
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">walk</string>

			<float name="speed">1.6</float>
			<int name="min-dist">50</int>
			<int name="dist">100</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">WhirlNovaSkill</string>
				<string name="anim">attack</string>
				<string name="start-snd">event:/enemy/wisp/whirl</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">500</int>
				<int name="duration">WHIRLDUR</int>
				<int name="min-range">0</int>
				<int name="range">300</int>
				<bool name="must-see">true</bool>
				<bool name="targeted">true</bool>
				<int name="angle-offset">WHIRLANGLEOFFSET</int>

%if NORMAL || TIER2
				<string name="projectile">actors/projectiles/wisp_2.unit</string>
%else
				<string name="projectile">actors/projectiles/wisp_2_ng.unit</string>
%endif
				<float name="proj-dist">6</float>
				<int name="proj-delay">WHIRLPROJDELAY</int>
				<int name="per-revolution">WHIRLPROJPERREV</int>
			</dict>

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
%if NORMAL
						<string name="unit">actors/wisp_2_bomb.unit</string>
%elif TIER2
						<string name="unit">actors/wisp_2_bomb_ng.unit</string>
%elif TIER3
						<string name="unit">actors/wisp_2_bomb_ng_2.unit</string>
%else
						<array name="units">
							<int>500</int><string>actors/wisp_2_bomb_ng_2.unit</string>
							<int>500</int><string>actors/wisp_2_bomb_ng_3.unit</string>
						</array>
%endif
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<sprite origin="12 14" looping="true" texture="actors/wisp_1.png" material="system/default.mats:xray">
				<frame time="125">0 0 24 24</frame>
			</sprite>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6" charge-through="true" />
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
					<color value="255 150 0 1 255" />
				</colors>
			</light>
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/wisp_2.png" material="system/default.mats:actor-noxray">
				<frame time="125">0 0 24 24</frame>
				<frame time="125">24 0 24 24</frame>
				<frame time="125">48 0 24 24</frame>
				<frame time="125">72 0 24 24</frame>
			</sprite>
		</scene>


		<scene name="walk">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/wisp_2.png" material="system/default.mats:actor-noxray">
				<frame time="125">0 0 24 24</frame>
				<frame time="125">24 0 24 24</frame>
				<frame time="125">48 0 24 24</frame>
				<frame time="125">72 0 24 24</frame>
			</sprite>
			</scene>

		<scene name="attack">
			<scene src="shared" />
			<sprite origin="24 14" looping="true" texture="actors/wisp_2.png" material="system/default.mats:actor-noxray">
				<frame time="200">0 24 48 24</frame>
				<frame time="200">48 24 48 24</frame>
				<frame time="200">96 24 48 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>