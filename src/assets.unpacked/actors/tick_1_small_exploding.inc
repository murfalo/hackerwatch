<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tick_1_small_exploding</string>
%else
		<string name="beastiary-override">actors/tick_1_small_exploding.unit</string>
%endif
		<string name="quality">common</string>

		<string name="type">beast</string>
		<int name="hp">6</int>
		<int name="armor">15</int>
		<int name="experience-reward">15</int>
		
		<string name="death-snd">event:/enemy/tick/death</string>
		<string name="gore">effects/gibs/gib_tick_exploding.sval</string>
	
		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<float name="speed">MOVESPEED</float>
			<float name="roaming">0.5</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">jump 8</string>
				<string name="anim-stop">idle</string>
				
				<int name="range">50</int>
				<int name="min-range">5</int>
				
				<int name="cooldown">50</int>
				
				<int name="hold-frame">500</int>
				<float name="speed">JUMPSPEED</float>	
				<int name="air-time">JUMPTIME</int>
				<int name="jump-height">10</int>
				<bool name="glide">false</bool>
				
				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">effects/players/ranger_bomb.effect</string>
						
						<int name="radius">16</int>
						
						<float name="dist-scaling">4</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">SUICIDEDMG</int>
								<float name="armor-mul">ARMORMUL</float>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/tick/death_explode</string>
					</dict>
					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" />
			</collision>				
			<sprite origin="6 7" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame>18 0 12 12</frame>
			</sprite>
		</scene>
		
		<scene name="shared-glow">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" radius="5" sensor="false" shoot-through="false" aim-through="true" charging="true" charge-through="true" />
			</collision>
			
			<sprite origin="6 7" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame time="500">18 0 12 12</frame>
				<frame time="500">0 0 0 0</frame>
			</sprite>
			<sprite origin="4 4" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame time="500">0 0 0 0</frame>
				<frame time="500">0 0 8 8</frame>
			</sprite>
		
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="10" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="80" />
				</sizes>
				<colors>
					<color value="80 40 0 0" />
				</colors>
			</light>			
			
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="15" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="32" />
				</sizes>
				<colors>
					<color value="80 50 0 0" />
				</colors>
			</light>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">40 20 20 20</frame>
				<frame time="150">100 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">40 0 20 20</frame>
				<frame time="150">100 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">20 0 20 20</frame>
				<frame time="150">80 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">0 0 20 20</frame>
				<frame time="150">60 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">0 20 20 20</frame>
				<frame time="150">60 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">0 40 20 20</frame>
				<frame time="150">60 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">20 40 20 20</frame>
				<frame time="150">80 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">40 40 20 20</frame>
				<frame time="150">100 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">160 20 20 20</frame>
				<frame time="150">220 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">160 0 20 20</frame>
				<frame time="150">220 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">140 0 20 20</frame>
				<frame time="150">200 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">120 0 20 20</frame>
				<frame time="150">180 0 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">120 20 20 20</frame>
				<frame time="150">180 20 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">120 40 20 20</frame>
				<frame time="150">180 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">140 40 20 20</frame>
				<frame time="150">200 40 20 20</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="10 12" looping="true" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="150">160 40 20 20</frame>
				<frame time="150">220 40 20 20</frame>
			</sprite>
		</scene>
		
		<scene name="jump-0">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">40 85 20 20</frame>
				<frame time="100">100 85 20 20</frame>
				<frame time="100">40 85 20 20</frame>
				<frame time="100">100 85 20 20</frame>
				<frame time="100">40 85 20 20</frame>
				<frame time="50">160 84 20 20</frame>
				<frame time="50">225 84 20 20</frame>
			</sprite>
		</scene>

		<scene name="jump-7">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">40 65 20 20</frame>
				<frame time="100">100 65 19 20</frame>
				<frame time="100">40 65 20 20</frame>
				<frame time="100">100 65 19 20</frame>
				<frame time="100">40 65 20 20</frame>
				<frame time="50">162 64 20 20</frame>
				<frame time="50">227 64 20 20</frame>
			</sprite>
		</scene>

		<scene name="jump-6">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">20 65 20 20</frame>
				<frame time="100">80 65 20 20</frame>
				<frame time="100">20 65 20 20</frame>
				<frame time="100">80 65 20 20</frame>
				<frame time="100">20 65 20 20</frame>
				<frame time="50">139 64 23 20</frame>
				<frame time="50">204 64 23 20</frame>
			</sprite>
		</scene>

		<scene name="jump-5">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">0 65 20 20</frame>
				<frame time="100">60 65 20 20</frame>
				<frame time="100">0 65 20 20</frame>
				<frame time="100">60 65 20 20</frame>
				<frame time="100">0 65 20 20</frame>
				<frame time="50">119 64 20 20</frame>
				<frame time="50">184 64 20 20</frame>
			</sprite>
		</scene>

		<scene name="jump-4">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">0 85 20 20</frame>
				<frame time="100">60 85 20 20</frame>
				<frame time="100">0 85 20 20</frame>
				<frame time="100">60 85 20 20</frame>
				<frame time="100">0 85 20 20</frame>
				<frame time="50">119 84 20 20</frame>
				<frame time="50">184 84 20 20</frame>
			</sprite>
		</scene>

		<scene name="jump-3">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">0 105 20 20</frame>
				<frame time="100">60 105 20 20</frame>
				<frame time="100">0 105 20 20</frame>
				<frame time="100">60 105 20 20</frame>
				<frame time="100">0 105 20 20</frame>
				<frame time="50">119 105 20 20</frame>
				<frame time="50">184 105 20 20</frame>
			</sprite>
		</scene>

		<scene name="jump-2">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">20 105 20 20</frame>
				<frame time="100">80 105 20 20</frame>
				<frame time="100">20 105 20 20</frame>
				<frame time="100">80 105 20 20</frame>
				<frame time="100">20 105 20 20</frame>
				<frame time="50">139 105 23 20</frame>
				<frame time="50">204 105 23 20</frame>
			</sprite>
		</scene>

		<scene name="jump-1">
			<scene src="shared-glow" />
			<sprite origin="10 12" loopback="500" texture="actors/tick_1_small_exploding.png" material="system/default.mats:actor">
				<frame time="100">40 105 20 20</frame>
				<frame time="100">100 105 20 20</frame>
				<frame time="100">40 105 20 20</frame>
				<frame time="100">100 105 20 20</frame>
				<frame time="100">40 105 20 20</frame>
				<frame time="50">162 105 20 20</frame>
				<frame time="50">227 105 20 20</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
