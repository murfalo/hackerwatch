<unit layer="20">
	<behavior class="BombBehavior">
		<string name="spawn-sound">event:/misc/spawn_tele</string>
		
		<int name="delay-random">0</int>
		<int name="delay">300</int>
			<array name="actions">
				<dict>
					<string name="class">SpawnUnit</string>
					<bool name="aggro">true</bool>
					<string name="unit">GHOST</string>
					<bool name="no-loot">true</bool>
					<bool name="no-experience">true</bool>
				</dict>
			</array>
	</behavior>

	<scenes start="visible">
		<scene name="visible">			
			<effect src="actors/ghost_spawn.effect" />
		</scene>
	</scenes>
</unit>
