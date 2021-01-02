<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
		<string name="type">construct</string>
		<int name="hp">500</int>
		<int name="armor">40</int>
		<int name="resistance">40</int>
		<int name="experience-reward">150</int>
		
		<float name="evade-physical">1</float>
		<float name="evade-magical">1</float>

		<bool name="counts-as-kill">false</bool>
		<bool name="floating-hurt">false</bool>
		<bool name="crosshair-colors">false</bool>
		<bool name="targetable">false</bool>
		<bool name="must-see-target">true</bool>
		<int name="aggro-range">150</int>
		<bool name="impenetrable">true</bool>
		<bool name="no-buffs">true</bool>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack</string>
				<string name="start-snd">event:/enemy/tower_turret_wall/attack</string>
				<string name="offset">attack-pos</string>

				<int name="cooldown-start">100</int>
				<int name="cooldown">2200</int>
				<int name="castpoint">960</int>
				<int name="range">150</int>
				<bool name="must-see">true</bool>
				<bool name="good-aim">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">EFFECT</string>
					</dict>
					
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/mt/projectiles/turret_wall_lurker.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="default" attack="attack">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="128 0 5 5"/>
%if NORTH
			<collision static="true">
				<circle offset="0 1" radius="4" shoot-through="true"/>
			</collision>
%elif SOUTH
			<collision static="true">
				<circle offset="0 -1" radius="4" shoot-through="true"/>
			</collision>
			<sprite ulayer="1" origin="0 32" texture="./turret_wall_crystal.png" material="system/default.mats:shadow">
				<frame >57 0 8 35</frame>
			</sprite>
			<sprite layer="-10" origin="9 1" texture="./turret_wall_crystal.png" material="system/default.mats:floor">
				<frame >21 36 20 12</frame>
			</sprite>
			<light pos="0 -1">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="0.5" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="255 0 0 0" />
				</colors>
			</light>
%elif EAST
			<collision static="true">
				<circle offset="-1 0" radius="4" shoot-through="true"/>
			</collision>
			<sprite layer="-10" origin="1 10" texture="./turret_wall_crystal.png" material="system/default.mats:floor">
				<frame >0 88 12 20</frame>
			</sprite>
			<light pos="-1 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="0.5" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="255 0 0 0" />
				</colors>
			</light>
%elif WEST
			<collision static="true">
				<circle offset="1 0" radius="4" shoot-through="true"/>
			</collision>
			<sprite layer="-10" origin="11 10" texture="./turret_wall_crystal.png" material="system/default.mats:floor">
				<frame >12 88 12 20</frame>
			</sprite>
			<light pos="1 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="0.5" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="255 0 0 0" />
				</colors>
			</light>
%endif
		</scene>

		
		<scene name="default">
			<scene src="shared" />

%if NORTH
			<sprite layer="1" origin="5 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">24 48 11 11</frame>
			</sprite>
%elif SOUTH
			<sprite origin="11 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">0 0 21 41</frame>
			</sprite>
%elif EAST
			<sprite origin="5 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">0 48 12 40</frame>
			</sprite>
%elif WEST
			<sprite origin="7 37" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">12 48 12 40</frame>
			</sprite>
%endif
		</scene>

		
		<scene name="attack">
			<scene src="shared" />
%if NORTH
			<locator name="attack-pos" pos="0 -6"/>
			<light pos="0 -32">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="900" />
				<overbright value="1" />
				<looping value="false" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="64" />
				</sizes>
				<colors>
					<color value="254 49 0 20" />
				</colors>
			</light>
			<sprite layer="1" origin="5 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">24 48 11 11</frame>
			</sprite>		
			
			<sprite origin="3 35" layer="2" looping="false" texture="./turret_wall_crystal.png" material="system/default.mats:glow-both-bright">
				<frame time="300">22 0 6 6</frame>
				<frame time="300">29 0 6 6</frame>
				<frame time="300">36 0 6 6</frame>
				<frame time="240">0 0 0 0</frame>
			</sprite>
%elif SOUTH
			<locator name="attack-pos" pos="0 6"/>
			<light pos="-1 -28">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="900" />
				<overbright value="1" />
				<looping value="false" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="64" />
				</sizes>
				<colors>
					<color value="254 49 0 20" />
				</colors>
			</light>
			<sprite origin="11 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">0 0 21 41</frame>
			</sprite>			
			<sprite origin="4 33" ulayer="1" looping="false" texture="./turret_wall_crystal.png" material="system/default.mats:glow-both-bright">
				<frame time="300">21 0 7 36</frame>
				<frame time="300">28 0 7 36</frame>
				<frame time="300">35 0 7 36</frame>
				<frame time="60">42 0 7 36</frame>
				<frame time="80">49 0 7 36</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
%elif EAST
			<locator name="attack-pos" pos="6 0"/>
			<light pos="2 -32">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="900" />
				<overbright value="1" />
				<looping value="false" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="64" />
				</sizes>
				<colors>
					<color value="254 49 0 20" />
				</colors>
			</light>
			<sprite origin="5 38" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">0 48 12 40</frame>
			</sprite>		
			<sprite origin="1 35" ulayer="1" looping="false" texture="./turret_wall_crystal.png" material="system/default.mats:glow-both-bright">
				<frame time="300">54 64 6 37</frame>
				<frame time="300">60 64 6 37</frame>
				<frame time="300">66 64 6 37</frame>
				<frame time="60">72 64 6 37</frame>
				<frame time="80">78 64 6 37</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
%elif WEST
			<locator name="attack-pos" pos="-6 0"/>
			<light pos="-1 -31">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="900" />
				<overbright value="1" />
				<looping value="false" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="64" />
				</sizes>
				<colors>
					<color value="254 49 0 20" />
				</colors>
			</light>
			<sprite origin="7 37" looping="true" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="100">12 48 12 40</frame>
			</sprite>			
			
			<sprite origin="4 34" ulayer="1" looping="false" texture="./turret_wall_crystal.png" material="system/default.mats:glow-both-bright">
				<frame time="300">24 64 6 37</frame>
				<frame time="300">30 64 6 37</frame>
				<frame time="300">36 64 6 37</frame>
				<frame time="60">42 64 6 37</frame>
				<frame time="80">48 64 6 37</frame>
				<frame time="100">0 0 0 0</frame>
			</sprite>
%endif
		</scene>
		
		<scene name="portrait">
			<sprite origin="9 23" looping="false" texture="./turret_wall_crystal.png" material="system/default.mats:proj-wall">
				<frame time="50">0 0 18 30</frame>
			</sprite>
		</scene>
	</scenes>
</unit>