<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_frost_bomber</string>
%else
		<string name="beastiary-override">actors/mt/tower_frost_bomber.unit</string>
%endif
		<string name="beastiary-scene">idle-6</string>
		<vec2 name="beastiary-offset">0 4</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">construct</string>
		<int name="hp">500</int>
		<int name="armor">75</int>
		<int name="resistance">75</int>
		<int name="experience-reward">250</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/tower/death</string>
		<string name="gore">effects/gibs/gib_tower_frost.sval</string>
		<string name="loot">actors/loot.sval:tower_frost_bomber</string>

		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">true</bool>
		<bool name="hold-angle-on-cast">true</bool>
		<int name="aggro-range">175</int>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">idle 16</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack 16</string>
				<string name="offset">shoot-pos</string>

				<int name="burst">SHOOTBURST</int>

				<int name="cooldown-start">250</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">500</int>
				<int name="min-range">0</int>
				<int name="range">175</int>
				<bool name="good-aim">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<int name="spread">20</int>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/tower_frost_bomb.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/tower_frost_bomb_ng.unit</string>
%endif
					</dict>
				</array>
			</dict>

%if !NORMAL
			<dict>
				<string name="class">CompositeActorAuraSkill</string>
				<bool name="friendly">false</bool>
				<string name="buff">actors/buffs.sval:slippery</string>
				<int name="freq">200</int>
				<int name="range">14</int>
			</dict>
%endif
		</array>
	</behavior>

	<scenes>
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<sprite ulayer="0" origin="7 23" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>0 0 14 30</frame>
			</sprite>
			<shadow>
				<sprite origin="-1 18" texture="actors/mt/tower_frost_nova.png" material="system/default.mats:default">
					<frame time="100">90 0 11 25</frame>
				</sprite>
			</shadow>
			<collision static="true">
				<circle radius="8" />
			</collision>
%if !NORMAL
			<sprite origin="20 19" layer="-14" looping="true" texture="actors/mt/projectiles/ice_patch.png" material="system/default.mats:floor">
				<frame>0 0 41 39</frame>
			</sprite>
%endif
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>15 0 12 11</frame>
			</sprite>
		</scene>
	
 		<scene name="idle-1">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>27 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-2">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>39 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-3">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>51 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-4">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>63 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-5">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>75 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-6">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>87 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-7">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>15 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-8">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>27 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-9">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>39 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-10">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>51 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-11">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-12">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-13">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-14">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>63  11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="idle-15">
 			<scene src="shared" />
			<sprite ulayer="1"  origin="6 7" looping="true" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame>75 11 12 11</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="6 -1" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">15 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-1">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="6 0" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">27 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-2">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="5 1"/>
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">39 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-3">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="3 3"/>
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">51 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-4">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="0 3"/>
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">63 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-5">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-3 2"/>
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">75 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-6">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-4 1"/>
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">87 0 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-7">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-5 1" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">15 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-8">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-6 -1" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">27 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-9">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-5 -5" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">39 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-10">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-4 -6" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">51 11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-11">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="-2 -8" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-12">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="0 -7" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-13">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="2 -7" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">0 0 0 0</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-14">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="4 -6" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">63  11 12 11</frame>
			</sprite>
		</scene>
		
 		<scene name="attack-15">
 			<scene src="shared" />
			<locator name="shoot-pos" pos="5 -5" />
			<sprite ulayer="1"  origin="6 7" looping="false" texture="actors/mt/tower_frost_bomber.png" material="system/default.mats:actor">
				<frame time="500">75 11 12 11</frame>
			</sprite>
		</scene>	
	</scenes>
</unit>