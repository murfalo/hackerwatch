<unit netsync="position" slot="actor" layer="20">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.elemental_ice_ranged</string>
%else
		<string name="beastiary-override">actors/elemental_ice_ranged.unit</string>
%endif
		<vec2 name="beastiary-offset">3 14</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">aberration</string>
		<int name="hp">200</int>
		<int name="armor">60</int>
		<int name="resistance">60</int>
		<int name="experience-reward">50</int>
		<float name="mp-scale-fact">0.65</float>
		
		<int name="unit-height">24</int>
		
		<string name="death-snd">event:/misc/iceblock_break</string>
		<string name="gore">effects/gibs/gib_elemental_ice.sval</string>

		<int name="aggro-range">999</int>
		<bool name="must-see-target">false</bool>
		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_big.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying.inc"
			<string>freezing</string>
		</array>
		
		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">idle 8</string>

			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
			<int name="min-dist">75</int>
			<int name="dist">150</int>
		</dict>

		<array name="skills">
			<dict>
%if NORMAL || TIER2
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<int name="castpoint">450</int>
%else
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack-fast 8</string>
				<int name="castpoint">250</int>
				<int name="burst">SHOOTBURST</int>
%endif
				<string name="snd">event:/enemy/elemental_ice/shoot</string>
				<string name="offset">shoot-pos</string>

				<int name="cooldown">500</int>
				<int name="castpoint">450</int>
				<int name="range">175</int>
				<int name="min-range">50</int>
				<bool name="good-aim">GOODAIM</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<int name="spread">2</int>
						<string name="projectile">actors/projectiles/elemental_ice_spear.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 -4" aim-through="true" charge-through="true" radius="4" />
				<circle offset="0 -4" sensor="true" aim-through="true" shoot-through="false" radius="6" />
				<circle offset="0 -16" sensor="true" aim-through="true" shoot-through="false" radius="6" />
			</collision>
			
			<effect pos="0 -10" src="actors/elemental_ice_dust.effect" />
			
			<sprite origin="8 14" ulayer="1" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
				<frame time="50">0 277 13 14</frame>
				<frame time="50">13 277 13 14</frame>
				<frame time="50">26 277 13 14</frame>
				<frame time="50">39 277 13 14</frame>
				<frame time="50">52 277 13 14</frame>
				<frame time="50">65 277 13 14</frame>
			</sprite>
			
			<light pos="0 -12">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="10" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="0 100 150 0" />
				</colors>
			</light>  			
			
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="2" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">198 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="2" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">231 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">0 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">33 0 33 31</frame> 
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">66 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">99 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
			<frame time="75">132 0 33 31</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="19 37" ulayer="0" looping="true" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="75">165 0 33 31</frame>
			</sprite>
		</scene>


		<scene name="attack-0">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="5 0"/>
			<sprite origin="19 37" ulayer="2" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">198 31 33 31</frame>
				<frame time="100">198 62 33 31</frame>
				<frame time="250">198 93 33 31</frame>
				<frame time="100">198 124 33 31</frame>
				<frame time="100">198 155 33 31</frame>
				<frame time="100">198 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="11 11"/>
			<sprite origin="19 37" ulayer="2" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">231 31 33 31</frame>
				<frame time="100">231 62 33 31</frame>
				<frame time="250">231 93 33 31</frame>
				<frame time="100">231 124 33 31</frame>
				<frame time="100">231 155 33 31</frame>
				<frame time="100">231 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-8 17"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">0 31 33 31</frame>
				<frame time="100">0 62 33 31</frame>
				<frame time="250">0 93 33 31</frame>
				<frame time="100">0 124 33 31</frame>
				<frame time="100">0 155 33 31</frame>
				<frame time="100">0 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-17 -5"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">33 31 33 31</frame>
				<frame time="100">33 62 33 31</frame>
				<frame time="250">33 93 33 31</frame>
				<frame time="100">33 124 33 31</frame>
				<frame time="100">33 155 33 31</frame>
				<frame time="100">33 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-18 -18"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">66 31 33 31</frame>
				<frame time="100">66 62 33 31</frame>
				<frame time="250">66 93 33 31</frame>
				<frame time="100">66 124 33 31</frame>
				<frame time="100">66 155 33 31</frame>
				<frame time="100">66 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-4 -25"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">99 31 33 31</frame>
				<frame time="100">99 62 33 31</frame>
				<frame time="250">99 93 33 31</frame>
				<frame time="100">99 124 33 31</frame>
				<frame time="100">99 155 33 31</frame>
				<frame time="100">99 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="8 -25"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">132 31 33 31</frame>
				<frame time="100">132 62 33 31</frame>
				<frame time="250">132 93 33 31</frame>
				<frame time="100">132 124 33 31</frame>
				<frame time="100">132 155 33 31</frame>
				<frame time="100">132 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="13 -13"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">165 31 33 31</frame>
				<frame time="100">165 62 33 31</frame>
				<frame time="250">165 93 33 31</frame>
				<frame time="100">165 124 33 31</frame>
				<frame time="100">165 155 33 31</frame>
				<frame time="100">165 186 33 31</frame>
			</sprite>
		</scene>
		
		<scene name="attack-fast-0">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="5 0"/>
			<sprite origin="19 37" ulayer="2" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">198 31 33 31</frame>
				<frame time="50">198 62 33 31</frame>
				<frame time="100">198 93 33 31</frame>
				<frame time="50">198 124 33 31</frame>
				<frame time="50">198 155 33 31</frame>
				<frame time="50">198 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-1">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="11 11"/>
			<sprite origin="19 37" ulayer="2" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">231 31 33 31</frame>
				<frame time="50">231 62 33 31</frame>
				<frame time="100">231 93 33 31</frame>
				<frame time="50">231 124 33 31</frame>
				<frame time="50">231 155 33 31</frame>
				<frame time="50">231 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-2">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-8 17"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">0 31 33 31</frame>
				<frame time="50">0 62 33 31</frame>
				<frame time="100">0 93 33 31</frame>
				<frame time="50">0 124 33 31</frame>
				<frame time="50">0 155 33 31</frame>
				<frame time="50">0 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-3">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-17 -5"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">33 31 33 31</frame>
				<frame time="50">33 62 33 31</frame>
				<frame time="100">33 93 33 31</frame>
				<frame time="50">33 124 33 31</frame>
				<frame time="50">33 155 33 31</frame>
				<frame time="50">33 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-4">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-18 -18"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">66 31 33 31</frame>
				<frame time="50">66 62 33 31</frame>
				<frame time="100">66 93 33 31</frame>
				<frame time="50">66 124 33 31</frame>
				<frame time="50">66 155 33 31</frame>
				<frame time="50">66 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-5">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="-4 -25"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">99 31 33 31</frame>
				<frame time="50">99 62 33 31</frame>
				<frame time="100">99 93 33 31</frame>
				<frame time="50">99 124 33 31</frame>
				<frame time="50">99 155 33 31</frame>
				<frame time="50">99 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-6">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="8 -25"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">132 31 33 31</frame>
				<frame time="50">132 62 33 31</frame>
				<frame time="100">132 93 33 31</frame>
				<frame time="50">132 124 33 31</frame>
				<frame time="50">132 155 33 31</frame>
				<frame time="50">132 186 33 31</frame>
			</sprite>
		</scene>

		<scene name="attack-fast-7">
		  <scene src="shared" />
		  <locator name="shoot-pos" pos="13 -13"/>
			<sprite origin="19 37" ulayer="0" looping="false" texture="actors/elemental_ice_ranged.png" material="system/default.mats:actor">
				<frame time="50">165 31 33 31</frame>
				<frame time="50">165 62 33 31</frame>
				<frame time="100">165 93 33 31</frame>
				<frame time="50">165 124 33 31</frame>
				<frame time="50">165 155 33 31</frame>
				<frame time="50">165 186 33 31</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
