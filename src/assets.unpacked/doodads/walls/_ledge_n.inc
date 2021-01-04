<unit slot="doodad" layer="-50">
	%if PYRAMID_SLUM
	<scenes default="default" snakes="snakes">
	%elif TEMPLE_POOR || TEMPLE_COMMON || TEMPLE_RICH
	<scenes default="default" ice="ice">
	%else
	<scenes default="default">
	%endif
		<scene name="default">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 8 10"/>			
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 32 8</rect>
			</collision>
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>8 0 32 8</frame>
			</sprite>						
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:wall-noxray">
				<frame>8 0 32 40</frame>
			</sprite>
		</scene>
		<scene name="snakes">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 8 10"/>			
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 32 8</rect>
			</collision>
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>64 64 32 8</frame>
			</sprite>						
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:wall-noxray">
				<frame>64 64 32 40</frame>
			</sprite>
		</scene>
		<scene name="ice">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 8 10"/>			
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 8 32 8</rect>
			</collision>
			<!-- ICE -->
			<sprite origin="0 0" ulayer="2" texture="doodads/walls/_ledge_ice.png" material="system/default.mats:floor">
				<frame>8 0 32 40</frame>
			</sprite>
			<!-- LEDGE -->
			<sprite origin="0 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>8 0 32 8</frame>
			</sprite>						
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>8 0 32 40</frame>
			</sprite>					
		</scene>
	</scenes>
</unit>