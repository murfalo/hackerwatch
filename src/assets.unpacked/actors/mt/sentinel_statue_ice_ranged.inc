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
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">IDLE</string>
				
				<int name="charges">1</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<int name="range">150</int>
				<bool name="must-see">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/sentinel_ice_ranged.unit</string>
						<bool name="aggro">true</bool>
						<bool name="no-loot">false</bool>
						<bool name="no-experience">false</bool>
					</dict>

					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>
	
	<scenes>
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="true">
				<circle offset="0 0" aim-through="true" radius="3.5" />
			</collision>
		</scene>
%if EAST
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_ranged.png" material="system/default.mats:default">
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>
%elif NORTH
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_ranged.png" material="system/default.mats:default">
				<frame time="100">128 0 64 64</frame>
			</sprite>
		</scene>
%elif WEST
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_ranged.png" material="system/default.mats:default">
				<frame time="100">256 0 64 64</frame>
			</sprite>
		</scene>
%else
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" looping="true" texture="./sentinel_ice_ranged.png" material="system/default.mats:default">
				<frame time="100">384 0 64 64</frame>
			</sprite>
		</scene>
%endif
  </scenes>
</unit>