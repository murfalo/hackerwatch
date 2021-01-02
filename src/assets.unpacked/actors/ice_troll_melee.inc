<unit slot="actor" netsync="position">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.ice_troll_melee</string>
%else
		<string name="beastiary-override">actors/ice_troll_melee.unit</string>
%endif
		<vec2 name="beastiary-offset">3 5</vec2>
		<string name="quality">uncommon</string>

		<string name="type">beast</string>
		<int name="hp">1500</int>
		<int name="armor">60</int>
		<int name="resistance">60</int>
		<int name="experience-reward">110</int>
		<float name="mp-scale-fact">0.65</float>

		<!-- <string name="aggro-snd">event:/enemy/ice_melee_troll/jump</string> -->
		<string name="death-snd">event:/enemy/ice_melee_troll/death</string>
		<string name="gore">effects/gibs/gib_troll_melee.sval</string>
		<string name="loot">actors/loot.sval:ice_troll_melee</string>

		<int name="aggro-range">150</int>
		<float name="wind-scale">0</float>

%include "actors/extra/debuff_scaling_big.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<float name="roaming">0.75</float>
			<int name="dist">12</int>
		</dict>
		
		<array name="skills">
			<dict>
%if NORMAL
				<string name="class">CompositeActorSkill</string>
%else
				<string name="class">CompositeActorBurstSkill</string>
				<int name="burst">MELEEBURST</int>
%endif
				<string name="anim">attack 8</string>
				<string name="offset">attack-pos</string>

				<int name="range">30</int>
				<int name="cooldown">1000</int>
				<int name="cooldown-start">500</int>
				<int name="castpoint">550</int>
				
				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">actors/ice_troll_club_hit.effect</string>
						<int name="min-radius">18</int>
						<int name="radius">18</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/ice_melee_troll/smash</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">jump 8</string>
				<string name="anim-stop">jump-attack 8</string>
				<string name="offset">attack-pos</string>
				<string name="snd">event:/enemy/ice_melee_troll/jump</string>
				
				<int name="range">80</int>
				<int name="min-range">50</int>
				
				<int name="cooldown">CHARGECD</int>
				<int name="cooldown-start">500</int>
				
				<int name="hold-frame">50</int>
				<float name="speed">4</float>
				<int name="air-time">600</int>
				<int name="jump-height">22</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">4</int>
				<int name="ray-width">3</int>
				<float name="ray-length">3</float>
				
				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">actors/ice_troll_club_hit.effect</string>
						<int name="min-radius">18</int>
						<int name="radius">18</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">80</int>
								<float name="armor-mul">0.8</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/ice_melee_troll/jump_strike</string>
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
				<circle offset="0 0" radius="8" aim-through="true" charge-through="false" density="20"/>
				<circle offset="0 -8" radius="8" sensor="true" shoot-through="false" aim-through="true" charge-through="false"/>
			</collision>
				
			<shadow>
				<sprite origin="12 12" texture="doodads/special/shadows.png">
					<frame>66 0 24 24</frame>
				</sprite>	
			</shadow>
		</scene>
		
		<scene name="shared-jump">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
		
			<collision static="false">
				<circle offset="0 0" sensor="false" radius="0.1" aim-through="true" shoot-through="true" charge-through="true" charging="true"/>
			</collision>
			
			<shadow>
				<sprite origin="12 12" texture="doodads/special/shadows.png">
					<frame>66 0 24 24</frame>
				</sprite>	
			</shadow>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
				<frame time="100">0 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">0 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
				<frame time="100">64 64 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">64 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">192 128 64 64</frame>
				<frame time="100">192 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
				<frame time="100">256 64 64 64</frame>
				<frame time="100">256 128 64 64</frame>
				<frame time="100">256 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
				<frame time="100">320 64 64 64</frame>
				<frame time="100">320 128 64 64</frame>
				<frame time="100">320 192 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
				<frame time="100">384 64 64 64</frame>
				<frame time="100">384 128 64 64</frame>
				<frame time="100">384 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
				<frame time="100">448 64 64 64</frame>
				<frame time="100">448 128 64 64</frame>
				<frame time="100">448 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">0 256 64 64</frame>
				<frame time="250">0 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">64 256 64 64</frame>
				<frame time="250">64 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">128 256 64 64</frame>
				<frame time="250">128 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">192 256 64 64</frame>
				<frame time="250">192 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">256 256 64 64</frame>
				<frame time="250">256 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">320 256 64 64</frame>
				<frame time="250">320 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">384 256 64 64</frame>
				<frame time="250">384 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="500">448 256 64 64</frame>
				<frame time="250">448 320 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-0">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">0 320 64 64</frame>
				<frame time="60">0 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-7">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">64 320 64 64</frame>
				<frame time="60">64 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-6">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">128 320 64 64</frame>
				<frame time="60">128 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-5">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">192 320 64 64</frame>
				<frame time="60">192 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-4">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">256 320 64 64</frame>
				<frame time="60">256 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-3">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">320 320 64 64</frame>
				<frame time="60">320 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-2">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">384 320 64 64</frame>
				<frame time="60">384 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-1">
			<!-- <scene src="shared" /> -->
			<scene src="shared-jump" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite origin="33 37" loopback="50" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="50">448 320 64 64</frame>
				<frame time="60">448 384 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="20 0"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">0 384 64 64</frame>
				<frame time="210">0 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 -12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">64 384 64 64</frame>
				<frame time="210">64 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -20"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">128 384 64 64</frame>
				<frame time="210">128 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 -12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">192 384 64 64</frame>
				<frame time="210">192 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-20 0"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">256 384 64 64</frame>
				<frame time="210">256 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-12 12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">320 384 64 64</frame>
				<frame time="210">320 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 20"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">384 384 64 64</frame>
				<frame time="210">384 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="jump-attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="12 12"/>
			<sprite origin="33 37" looping="false" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="30">448 384 64 64</frame>
				<frame time="210">448 448 64 64</frame>
			</sprite>
		</scene>
		
		
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">64 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">192 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">320 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">384 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">448 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="falling-3">
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">320 384 64 64</frame>
			</sprite>
			<shadow>			
				<sprite origin="10 10" layer="-1" texture="doodads/special/shadows.png">
					<frame>46 0 20 20</frame>
				</sprite>
			</shadow>	
		</scene>
		
		<scene name="falling-2">
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">384 384 64 64</frame>
			</sprite>
			<shadow>			
				<sprite origin="10 10" layer="-1" texture="doodads/special/shadows.png">
					<frame>46 0 20 20</frame>
				</sprite>
			</shadow>	
		</scene>
		
		<scene name="falling-1">
			<sprite origin="33 37" texture="actors/ice_troll_melee.png" material="system/default.mats:actor">
				<frame time="100">448 384 64 64</frame>
			</sprite>
			<shadow>			
				<sprite origin="10 10" layer="-1" texture="doodads/special/shadows.png">
					<frame>46 0 20 20</frame>
				</sprite>
			</shadow>	
		</scene>
	</scenes>
</unit>