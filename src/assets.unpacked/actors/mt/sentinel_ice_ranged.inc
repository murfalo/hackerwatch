<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.sentinel_ice_ranged</string>
%else
		<string name="beastiary-override">actors/mt/sentinel_ice_ranged.unit</string>
%endif
		<vec2 name="beastiary-offset">0 9</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>
		
		<string name="type">construct</string>
		<int name="hp">600</int>
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
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<float name="roaming">0</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">ATTACKCD</int>
				<int name="castpoint">600</int>
				<int name="range">22</int>
				<int name="dmg-range">28</int>
				<int name="arc">180</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">80</int>
						<float name="armor-mul">0.8</float>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/sentinel_ice/melee_hit</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">attack-pos</string>

				<int name="burst">SHOOTBURST</int>

				<int name="cooldown-start">500</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">550</int>
				<int name="min-range">24</int>
				<int name="range">150</int>
				<bool name="good-aim">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
%if NORMAL
						<string name="projectile">actors/mt/projectiles/sentinel_ice_slash.unit</string>
%else
						<string name="projectile">actors/mt/projectiles/sentinel_ice_slash_ng.unit</string>
%endif
					</dict>
				</array>
			</dict>
		</array>
		
		<dict name="effect-params"></dict>
		
	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" charge-through="true" density="20"/>
				<circle offset="0 -8" sensor="true" shoot-through="false" aim-through="true" radius="4" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">0 64 64 64</frame>
				<frame time="200">0 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">64 64 64 64</frame>
				<frame time="200">64 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">128 64 64 64</frame>
				<frame time="200">128 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">192 64 64 64</frame>
				<frame time="200">192 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">256 64 64 64</frame>
				<frame time="200">256 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">320 64 64 64</frame>
				<frame time="200">320 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">384 64 64 64</frame>
				<frame time="200">384 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="200">448 64 64 64</frame>
				<frame time="200">448 128 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<effect delay="500" pos="8 0" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">0 192 64 64</frame>
				<frame time="125">0 256 64 64</frame>
				<frame time="200">0 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<effect delay="500" pos="6 -6" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">64 192 64 64</frame>
				<frame time="125">64 256 64 64</frame>
				<frame time="200">64 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<effect delay="500" pos="0 -8" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">128 192 64 64</frame>
				<frame time="125">128 256 64 64</frame>
				<frame time="200">128 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<effect delay="500" pos="-6 -6" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">192 192 64 64</frame>
				<frame time="125">192 256 64 64</frame>
				<frame time="200">192 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<effect delay="500" pos="-8 0" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">256 192 64 64</frame>
				<frame time="125">256 256 64 64</frame>
				<frame time="200">256 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<effect delay="500" pos="-6 6" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">320 192 64 64</frame>
				<frame time="125">320 256 64 64</frame>
				<frame time="200">320 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<effect delay="500" pos="0 8" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">384 192 64 64</frame>
				<frame time="125">384 256 64 64</frame>
				<frame time="200">384 320 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<effect delay="500" pos="6 6" src="actors/mt/sentinel_ice_ranged_slash.effect" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="32 38" looping="false" texture="actors/mt/sentinel_ice_ranged.png" material="system/default.mats:actor">
				<frame time="500">448 192 64 64</frame>
				<frame time="125">448 256 64 64</frame>
				<frame time="200">448 320 64 64</frame>
			</sprite>
		</scene>
  </scenes>
</unit>