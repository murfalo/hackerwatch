<unit slot="doodad" layer="-50">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 8 2"/>
			%if ARCHIVES || ARMORY 			
			<sprite origin="0 4" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>32 56 32 4</frame>
			</sprite>	
			%endif	
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 -8 32 8</rect>
			</collision>				
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>8 40 32 8</frame>
			</sprite>
		</scene>
	</scenes>
</unit>