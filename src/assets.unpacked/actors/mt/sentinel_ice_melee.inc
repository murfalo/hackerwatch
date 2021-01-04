<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.sentinel_ice_melee</string>
%else
		<string name="beastiary-override">actors/mt/sentinel_ice_melee.unit</string>
%endif
		<vec2 name="beastiary-offset">0 9</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>			
		
		<string name="type">construct</string>
		<int name="hp">700</int>
		<int name="armor">80</int>
		<int name="resistance">40</int>
		<int name="experience-reward">140</int>
		<float name="mp-scale-fact">0.65</float>
		
		<int name="unit-height">14</int>
		
		<string name="death-snd">event:/enemy/sentinel/death</string>
		<string name="gore">effects/gibs/gib_sentinel_ice.sval</string>
		<string name="loot">actors/loot.sval:sentinel_ice</string>
		
		<int name="aggro-range">130</int>
		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_big.inc"

		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
			<string>respawn_thrall</string>
			<string>bleeding</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<float name="roaming">0</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/sentinel_ice/ranged_shoot</string>

				<int name="cooldown">ATTACKCD</int>
				<int name="castpoint">700</int>
				<int name="range">22</int>
				<int name="dmg-range">32</int>
				<int name="arc">210</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">120</int>
						<float name="armor-mul">0.8</float>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">PlaySound</string>						
						<string name="sound">event:/enemy/sentinel_ice/melee_hit</string>
					</dict>
				</array>
			</dict>

%if !NORMAL
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">charge 8</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">CHARGECD</int>
				<int name="hold-frame">550</int>
				
				<int name="range">CHARGERANGE</int>
				<int name="min-range">50</int>

				<bool name="must-see">true</bool>
				
				<float name="speed">CHARGESPEED</float>
				<int name="air-time">350</int>
				<int name="jump-height">0</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">4</int>
				<int name="ray-width">12</int>
				<float name="ray-length">3</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">120</int>
						<float name="armor-mul">0.8</float>
					</dict>
					<dict>
						<string name="class">PlaySound</string>						
						<string name="sound">event:/enemy/sentinel_ice/melee_hit</string>
					</dict>
				</array>
			</dict>
%endif

<!-- 			<dict>
				<string name="class">WhirlwindSkill</string>
				<string name="anim">walk 8</string>

				<int name="cooldown-start">2000</int>
				<int name="cooldown">7500</int>
				<int name="castpoint">600</int>
				
				<int name="range">75</int>
				
				<float name="acceleration">3</float>
				<float name="speed">1</float>
				<float name="turnspeed">0.2</float>
				<int name="duration">3600</int>
				<int name="freq">200</int>
				
				<dict name="effect">
					<string name="class">Explode</string>
					
					<int name="radius">22</int>
					<float name="dist-scaling">1000</float>
					
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">45</int>
					</dict>
				</dict>
			</dict> -->
		</array>
	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" charge-through="true" density="20"/>
				<circle offset="0 -8" sensor="true" shoot-through="false" aim-through="true" radius="4" />
			</collision>
		</scene>

		<scene name="shared-charge">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" charge-through="true" density="20" charging="true"/>
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">0 64 64 64</frame>
				<frame time="200">0 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">64 64 64 64</frame>
				<frame time="200">64 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">128 64 64 64</frame>
				<frame time="200">128 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">192 64 64 64</frame>
				<frame time="200">192 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">256 64 64 64</frame>
				<frame time="200">256 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">320 64 64 64</frame>
				<frame time="200">320 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">384 64 64 64</frame>
				<frame time="200">384 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="200">448 64 64 64</frame>
				<frame time="200">448 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">0 192 64 64</frame>
				<frame time="75">0 256 64 64</frame>
				<frame time="75">0 320 64 64</frame>
				<frame time="75">0 384 64 64</frame>
				<frame time="150">0 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">64 192 64 64</frame>
				<frame time="75">64 256 64 64</frame>
				<frame time="75">64 320 64 64</frame>
				<frame time="75">64 384 64 64</frame>
				<frame time="150">64 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">128 192 64 64</frame>
				<frame time="75">128 256 64 64</frame>
				<frame time="75">128 320 64 64</frame>
				<frame time="75">128 384 64 64</frame>
				<frame time="150">128 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">192 192 64 64</frame>
				<frame time="75">192 256 64 64</frame>
				<frame time="75">192 320 64 64</frame>
				<frame time="75">192 384 64 64</frame>
				<frame time="150">192 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">256 192 64 64</frame>
				<frame time="75">256 256 64 64</frame>
				<frame time="75">256 320 64 64</frame>
				<frame time="75">256 384 64 64</frame>
				<frame time="150">256 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">320 192 64 64</frame>
				<frame time="75">320 256 64 64</frame>
				<frame time="75">320 320 64 64</frame>
				<frame time="75">320 384 64 64</frame>
				<frame time="150">320 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">384 192 64 64</frame>
				<frame time="75">384 256 64 64</frame>
				<frame time="75">384 320 64 64</frame>
				<frame time="75">384 384 64 64</frame>
				<frame time="150">384 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">448 192 64 64</frame>
				<frame time="75">448 256 64 64</frame>
				<frame time="75">448 320 64 64</frame>
				<frame time="75">448 384 64 64</frame>
				<frame time="150">448 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-0">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">0 192 64 64</frame>
				<frame time="200">0 256 64 64</frame>
				<frame time="50">0 320 64 64</frame>
				<frame time="50">0 384 64 64</frame>
				<frame time="50">0 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-7">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">64 192 64 64</frame>
				<frame time="200">64 256 64 64</frame>
				<frame time="50">64 320 64 64</frame>
				<frame time="50">64 384 64 64</frame>
				<frame time="50">64 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-6">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">128 192 64 64</frame>
				<frame time="200">128 256 64 64</frame>
				<frame time="50">128 320 64 64</frame>
				<frame time="50">128 384 64 64</frame>
				<frame time="50">128 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-5">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">192 192 64 64</frame>
				<frame time="200">192 256 64 64</frame>
				<frame time="50">192 320 64 64</frame>
				<frame time="50">192 384 64 64</frame>
				<frame time="50">192 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-4">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">256 192 64 64</frame>
				<frame time="200">256 256 64 64</frame>
				<frame time="50">256 320 64 64</frame>
				<frame time="50">256 384 64 64</frame>
				<frame time="50">256 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-3">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">320 192 64 64</frame>
				<frame time="200">320 256 64 64</frame>
				<frame time="50">320 320 64 64</frame>
				<frame time="50">320 384 64 64</frame>
				<frame time="50">320 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-2">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">384 192 64 64</frame>
				<frame time="200">384 256 64 64</frame>
				<frame time="50">384 320 64 64</frame>
				<frame time="50">384 384 64 64</frame>
				<frame time="50">384 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="charge-1">
			<scene src="shared-charge" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="600">448 192 64 64</frame>
				<frame time="200">448 256 64 64</frame>
				<frame time="50">448 320 64 64</frame>
				<frame time="50">448 384 64 64</frame>
				<frame time="50">448 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="whirlwind">
			<scene src="shared" />
			<sprite origin="32 38" loopback="600" texture="actors/mt/sentinel_ice_melee.png" material="system/default.mats:actor">
				<frame time="75">0 256 64 64</frame>
				<frame time="75">64 256 64 64</frame>
				<frame time="75">128 256 64 64</frame>
				<frame time="75">192 256 64 64</frame>
				<frame time="75">256 256 64 64</frame>
				<frame time="75">320 256 64 64</frame>
				<frame time="75">384 256 64 64</frame>
				<frame time="75">448 256 64 64</frame>

				<frame time="50">0 256 64 64</frame>
				<frame time="50">64 256 64 64</frame>
				<frame time="50">128 256 64 64</frame>
				<frame time="50">192 256 64 64</frame>
				<frame time="50">256 256 64 64</frame>
				<frame time="50">320 256 64 64</frame>
				<frame time="50">384 256 64 64</frame>
				<frame time="50">448 256 64 64</frame>
			</sprite>
		</scene>
  </scenes>
</unit>