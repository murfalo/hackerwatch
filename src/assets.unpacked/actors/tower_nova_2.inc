<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_nova_2</string>
%else
		<string name="beastiary-override">actors/tower_nova_2.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">-1 10</vec2>
		<string name="quality">uncommon</string>

		<string name="type">construct</string>
		<int name="hp">800</int>
		<int name="armor">70</int>
		<int name="resistance">70</int>
		<int name="experience-reward">350</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/tower/death</string>
		<string name="gore">effects/gibs/gib_tower_nova_1.sval</string>
		<string name="loot">actors/loot.sval:tower_nova_2</string>

		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">200</int>
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">NovaSkill</string>
				<string name="anim">attack</string>
				<string name="fire-snd">event:/enemy/tower/shoot</string>
				
				<bool name="must-see">false</bool>
				<int name="cooldown-start">500</int>
				<int name="cooldown">NOVACD</int>
				<int name="min-range">0</int>
				<int name="range">250</int>
				
				<int name="proj-count">NOVACOUNT</int>
%if NORMAL || TIER2
				<string name="projectile">actors/projectiles/tower_nova_2.unit</string>
%else
				<string name="projectile">actors/projectiles/tower_nova_2_ng.unit</string>
%endif
			</dict>
		</array>
	</behavior>

	<scenes start="default">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="8" />
			</collision>
			
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
			<sprite origin="13 24" looping="true" texture="actors/tower_nova_2.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
				<frame time="100">32 0 32 32</frame>
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
			<sprite origin="13 24" looping="false" texture="actors/tower_nova_2.png" material="system/default.mats:actor">
				<frame time="50">0 32 32 32</frame>
				<frame time="50">32 32 32 32</frame>
				<frame time="50">64 32 32 32</frame>
				<frame time="50">96 32 32 32</frame>
				<frame time="50">64 32 32 32</frame>
				<frame time="50">32 32 32 32</frame>
				<frame time="50">0 32 32 32</frame>
				<frame time="50">32 32 32 32</frame>
				<frame time="50">64 32 32 32</frame>
				<frame time="50">96 32 32 32</frame>
				<frame time="50">64 32 32 32</frame>
				<frame time="50">32 32 32 32</frame>
				<frame time="50">0 32 32 32</frame>
				<frame time="100">64 0 32 32</frame>
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>
		<scene name="portrait">
			<sprite origin="13 24" looping="false" texture="actors/tower_nova_2.png" material="system/default.mats:actor">
				<frame time="50">0 32 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>