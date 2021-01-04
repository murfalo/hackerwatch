<unit slot="doodad" layer="-50">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="32 0 2 8"/>
			%if ARCHIVES || ARMORY
			<sprite origin="-8 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>32 60 6 32</frame>
			</sprite>	
			%endif	
			<collision static="true">
				<rect shoot-through="true" aim-through="true">8 0 8 32</rect>
			</collision>			
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>0 8 8 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>