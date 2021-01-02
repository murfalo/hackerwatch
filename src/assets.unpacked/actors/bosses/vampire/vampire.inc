<unit slot="actor" netsync="position">
	<behavior class="BossVampire">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bosses.vampire</string>
%else
		<string name="beastiary-override">actors/bosses/vampire/vampire.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">-1 12</vec2>
		<string name="quality">epic</string>

		<string name="type">undead</string>
		<int name="hp">14000</int>
		<int name="armor">100</int>
		<int name="resistance">100</int>
		<int name="experience-reward">7500</int>
		<float name="mp-scale-fact">1.25</float>
		<float name="ngp-scale">1.5</float>

		<string name="death-snd">event:/enemy/boss_vampire/death</string>
		<string name="loot">actors/loot.sval:boss_vampire</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">1000</int>
		<int name="unit-height">28</int>
		<float name="debuff-scale">0.5</float>

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_boss.inc"
		</array>
		
		<dict name="movement">
			<string name="class">BossVampireMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">bat 8</string>

			<float name="speed">MSPEED</float>
			<float name="speed-roam">RSPEED</float>

			<int name="node-wait-time">3000</int>
			<int name="node-wait-time-random">1500</int>
			<int name="center-count">5</int>

			<string name="transform-fx">actors/bosses/vampire/poof.effect</string>
		</dict>
		
		<int name="roaming">RTIMES</int>
		<float name="roam-chance">0.4</float>
		<string name="roam-unit">actors/bosses/vampire/fire_area.unit</string>
		<string name="roam-unit-snd">event:/enemy/boss_vampire/fire_wall</string>
		<int name="roam-unit-interval">50</int>
		
		<array name="skills">
%include "actors/bosses/vampire/vampire_skills.inc"
		</array>	
		
		<dict name="effect-params"></dict>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="true">
				<circle offset="0 -2" radius="8" />
			</collision>
			<sprite origin="9 10" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
                <frame>85 32 19 19</frame>
            </sprite>
		</scene>
		
		<scene name="shared-bat">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="false">
				<circle offset="0 -2" radius="1" sensor="true" shoot-through="true" aim-through="true" density="100"/>
			</collision>
			<sprite origin="9 10" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
                <frame>85 32 19 19</frame>
            </sprite>
		</scene>

%include "actors/bosses/vampire/vampire_scenes.inc"

	</scenes>
</unit>