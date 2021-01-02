<unit netsync="position">
	<behavior class="CompositeActorBehavior">
		<string name="type">construct</string>
		<int name="hp">500000</int>
		<int name="armor">1000</int>
		<int name="resistance">1000</int>

		<float name="evade-physical">1</float>
		<float name="evade-magical">1</float>
		
		<string name="death-snd">event:/enemy/sentinel/spawn</string>
		
		<int name="aggro-range">150</int>
		<bool name="no-buffs">true</bool>
		<bool name="targetable">false</bool>
		<bool name="counts-as-kill">true</bool>
		<bool name="floating-hurt">false</bool>
		<bool name="crosshair-colors">false</bool>
		<bool name="impenetrable">false</bool>

		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">IDLE</string>

			<float name="speed">0</float>
		</dict>

		<array name="skills">
%if OBJECTIVE
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">IDLE</string>
				
				<int name="charges">1</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<int name="range">200</int>
				<bool name="must-see">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/sentinel_ice_mb_obj.unit</string>
						<bool name="safe-spawn">false</bool>
						<bool name="aggro">true</bool>
						<bool name="no-loot">false</bool>
						<bool name="no-experience">false</bool>
					</dict>

					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
%else
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">IDLE</string>
				
				<int name="charges">1</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<int name="range">200</int>
				<bool name="must-see">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/sentinel_ice_mb.unit</string>
						<bool name="safe-spawn">false</bool>
						<bool name="aggro">true</bool>
						<bool name="no-loot">false</bool>
						<bool name="no-experience">false</bool>
					</dict>

					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
%endif
		</array>
	</behavior>
	
	<scenes>
		<scene name="shared">
%if OBJECTIVE
			<minimap_sprite origin="5 7" layer="120" texture="gui/minimap.png" frame="104 19 10 14" />
%else
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
%endif
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6" />
			</collision>
		</scene>
%if EAST
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_mb.png" material="system/default.mats:default">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>
%elif NORTH
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_mb.png" material="system/default.mats:default">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>
%elif WEST
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_mb.png" material="system/default.mats:default">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>
%else
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_mb.png" material="system/default.mats:default">
				<frame time="250">384 0 64 64</frame>
			</sprite>
		</scene>
%endif
  </scenes>
</unit>