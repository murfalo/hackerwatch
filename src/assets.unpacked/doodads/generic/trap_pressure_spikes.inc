<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		<dict name="effect">
			<string name="class">Damage</string>
			<int name="physical">TRAP_DAMAGE</int>
		</dict>
	</behavior>
	
	<scenes on="on" off="off" open="open" close="close">
		<scene name="shared">
			%if MOON_TEMPLE
			<sprite origin="16 16" texture="./trap_pressure_spikes.png" material="system/default.mats:floor">
				<frame>128 96 32 32</frame>
			</sprite>
			%else
			<sprite origin="16 16" texture="./trap_pressure_spikes.png" material="system/default.mats:floor">
				<frame>96 96 32 32</frame>
			</sprite>
			<sprite ulayer="1" origin="16 16" texture="./trap_pressure_spikes.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			%endif						
		</scene>

		<scene name="open">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_pressure_spikes.png" material="doodads/generic/traps.mats:spikes">
				<frame time="125">0 0 32 32</frame>	
				<frame time="125">32 0 32 32</frame>
				<frame time="125">64 0 32 32</frame>
				<frame time="125">96 0 32 32</frame>
				<frame time="125">128 0 32 32</frame>
				<frame time="125">160 0 32 32</frame>
				<frame time="125">192 0 32 32</frame>
				<frame time="125">0 0 0 0</frame>
			</sprite>
		</scene>		
		<scene name="on">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<collision static="false" nav-block="true">
				<rect sensor="true" shoot-through="true" aim-through="true">-14 -14 28 28</rect>
			</collision>
			<sprite ulayer="2" looping="true" origin="16 16" texture="./trap_pressure_spikes.png" material="doodads/generic/traps.mats:spikes">
				<frame time="250">0 64 32 32</frame>
				<frame time="25">32 64 32 32</frame>
				<frame time="25">64 64 32 32</frame>
				<frame time="25">96 64 32 32</frame>
				<frame time="250">128 64 32 32</frame>
				<frame time="25">96 64 32 32</frame>
				<frame time="25">64 64 32 32</frame>
				<frame time="25">32 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="close">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_pressure_spikes.png" material="system/default.mats:floor">
				<frame time="50">96 0 32 32</frame>	
				<frame time="50">64 0 32 32</frame>
				<frame time="50">32 0 32 32</frame>
				<frame time="50">0 0 32 32</frame>		
			</sprite>
		</scene>
		
		<scene name="off">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_pressure_spikes.png" material="system/default.mats:floor">
				<frame time="50">0 0 32 32</frame>		
			</sprite>
		</scene>
	</scenes>
</unit>
