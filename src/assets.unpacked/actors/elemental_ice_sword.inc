<unit netsync="position" slot="actor" layer="20">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.elemental_ice_sword</string>
%else
		<string name="beastiary-override">actors/elemental_ice_sword.unit</string>
%endif
		<vec2 name="beastiary-offset">3 14</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">aberration</string>
		<int name="hp">300</int>
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
			<string name="class">MeleeMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">idle 8</string>

			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
			<int name="dist">20</int>
		</dict>

		<array name="skills">
			%// Normal
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">100</int>
				<int name="castpoint">350</int>
				<int name="range">22</int>
				<int name="dmg-range">26</int>
				<int name="arc">160</int>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">60</int>
						<int name="magical">60</int>
						<float name="armor-mul">ARMORMUL</float>
						<float name="resistance-mul">RESISTANCEMUL</float>
						<bool name="melee">true</bool>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:freezing</string>
					</dict>
%endif
				</array>
			</dict>
			
			%// NG+2 Whirlwind
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">WhirlwindSkill</string>
				<string name="anim">whirlwind</string>

				<int name="cooldown-start">2500</int>
				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">480</int>
				
				<int name="min-range">50</int>
				<int name="range">120</int>
				
				<int name="duration">WHIRLDUR</int>
				<float name="acceleration">WHIRLACC</float>
				<float name="speed">WHIRLSPEED</float>
				<float name="turnspeed">WHIRLTURNSPEED</float>
				<int name="freq">240</int>
				
				<dict name="effect">
					<string name="class">Explode</string>
					
					<int name="radius">22</int>
					<float name="dist-scaling">1000</float>
					
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">30</int>
						<int name="magical">30</int>
						<float name="armor-mul">ARMORMUL</float>
						<float name="resistance-mul">RESISTANCEMUL</float>
						<bool name="melee">true</bool>
					</dict>
				</dict>
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
		  <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">240 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-1">
		  <scene src="shared" />
		  <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">280 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-2">
		  <scene src="shared" />
		  <sprite origin="21 37" ulayer="0" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">0 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-3">
		  <scene src="shared" />
		  <sprite origin="21 37" ulayer="0" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">40 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-4">
		  <scene src="shared" />
		  <sprite origin="21 37" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">80 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-5">
		  <scene src="shared" />
		  <sprite origin="21 37" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">120 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="21 37" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">160 0 40 39</frame>
		  </sprite>
		</scene>

		<scene name="idle-7">
		  <scene src="shared" />
		  <sprite origin="21 37" ulayer="0" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="75">200 0 40 39</frame>
		  </sprite>
		</scene>


		<scene name="attack-0">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">240 39 40 39</frame>
			<frame time="100">240 78 40 39</frame>
			<frame time="100">240 117 40 39</frame>
			<frame time="100">240 156 40 39</frame>
			<frame time="100">240 195 40 39</frame>
			<frame time="100">240 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-1">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">280 39 40 39</frame>
			<frame time="100">280 78 40 39</frame>
			<frame time="100">280 117 40 39</frame>
			<frame time="100">280 156 40 39</frame>
			<frame time="100">280 195 40 39</frame>
			<frame time="100">280 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-2">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">0 39 40 39</frame>
			<frame time="100">0 78 40 39</frame>
			<frame time="100">0 117 40 39</frame>
			<frame time="100">0 156 40 39</frame>
			<frame time="100">0 195 40 39</frame>
			<frame time="100">0 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-3">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">40 39 40 39</frame>
			<frame time="100">40 78 40 39</frame>
			<frame time="100">40 117 40 39</frame>
			<frame time="100">40 156 40 39</frame>
			<frame time="100">40 195 40 39</frame>
			<frame time="100">40 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-4">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">80 39 40 39</frame>
			<frame time="100">80 78 40 39</frame>
			<frame time="100">80 117 40 39</frame>
			<frame time="100">80 156 40 39</frame>
			<frame time="100">80 195 40 39</frame>
			<frame time="100">80 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-5">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">120 39 40 39</frame>
			<frame time="100">120 78 40 39</frame>
			<frame time="100">120 117 40 39</frame>
			<frame time="100">120 156 40 39</frame>
			<frame time="100">120 195 40 39</frame>
			<frame time="100">120 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-6">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">160 39 40 39</frame>
			<frame time="100">160 78 40 39</frame>
			<frame time="100">160 117 40 39</frame>
			<frame time="100">160 156 40 39</frame>
			<frame time="100">160 195 40 39</frame>
			<frame time="100">160 234 40 39</frame>
		  </sprite>
		</scene>

		<scene name="attack-7">
		  <scene src="shared" />
		   <sprite origin="21 37" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
			<frame time="100">200 39 40 39</frame>
			<frame time="100">200 78 40 39</frame>
			<frame time="100">200 117 40 39</frame>
			<frame time="100">200 156 40 39</frame>
			<frame time="100">200 195 40 39</frame>
			<frame time="100">200 234 40 39</frame>
		  </sprite>
		</scene>
		
		<scene name="whirlwind">
			<scene src="shared" />
			<sprite origin="21 37" loopback="480" ulayer="2" looping="true" texture="actors/elemental_ice_sword.png" material="system/default.mats:actor">
				<frame time="60">0 117 40 39</frame>
				<frame time="60">280 117 40 39</frame>
				<frame time="60">240 117 40 39</frame>
				<frame time="60">200 117 40 39</frame>
				<frame time="60">160 117 40 39</frame>
				<frame time="60">120 117 40 39</frame>
				<frame time="60">80 117 40 39</frame>
				<frame time="60">40 117 40 39</frame>

				<frame time="30">0 117 40 39</frame>
				<frame time="30">280 117 40 39</frame>
				<frame time="30">240 117 40 39</frame>
				<frame time="30">200 117 40 39</frame>
				<frame time="30">160 117 40 39</frame>
				<frame time="30">120 117 40 39</frame>
				<frame time="30">80 117 40 39</frame>
				<frame time="30">40 117 40 39</frame>
			</sprite>
		</scene>
	</scenes>
</unit>