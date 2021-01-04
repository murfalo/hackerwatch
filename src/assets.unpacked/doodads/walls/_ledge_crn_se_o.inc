<unit slot="doodad" layer="-50">
	%if PYRAMID_SLUM
	<scenes default="default" snakes="snakes">
	%elif TEMPLE_POOR || TEMPLE_COMMON || TEMPLE_RICH
	<scenes default="default" ice="ice">
	%else
	<scenes default="default">
	%endif
		<scene name="default">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 2 10"/>
			%if ARCHIVES
			<sprite origin="-8 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>32 60 4 8</frame>
			</sprite>
			%endif
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 8 8</rect>
				<rect shoot-through="true" aim-through="true">8 0 8 16</rect>
			</collision>	
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>16 48 8 8</frame>
			</sprite>					
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:wall-noxray">
				<frame>16 48 8 40</frame>
			</sprite>
		</scene>
		<scene name="snakes">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 2 10"/>
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 8 8</rect>
				<rect shoot-through="true" aim-through="true">8 0 8 16</rect>
			</collision>	
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>112 64 8 8</frame>
			</sprite>					
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:wall-noxray">
				<frame>112 64 8 40</frame>
			</sprite>
		</scene>
		<scene name="ice">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 2 10"/>
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 8 8</rect>
				<rect shoot-through="true" aim-through="true">8 0 8 16</rect>
			</collision>	
			<!-- ICE -->
			<sprite origin="0 0" ulayer="2" texture="doodads/walls/_ledge_ice.png" material="system/default.mats:floor">
				<frame>16 48 8 40</frame>
			</sprite>
			<!-- LEDGE -->
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>16 48 8 8</frame>
			</sprite>					
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:wall-noxray">
				<frame>16 48 8 40</frame>
			</sprite>
		</scene>
	</scenes>
</unit>