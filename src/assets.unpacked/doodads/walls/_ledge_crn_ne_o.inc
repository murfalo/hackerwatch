<unit slot="doodad" layer="-50">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="24 0 2 2"/>
			%if ARCHIVES
			<sprite origin="0 4" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>56 56 8 4</frame>
			</sprite>
			<sprite origin="-8 0" ulayer="1" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>32 60 4 8</frame>
			</sprite>
			%endif
			<collision static="true">
				<rect shoot-through="true" aim-through="true">0 -8 8 8</rect>
				<rect shoot-through="true" aim-through="true">8 -8 8 16</rect>
			</collision>			
			<sprite origin="0 0" texture="./_ledge.png" material="system/default.mats:floor">
				<frame>40 48 8 8</frame>
			</sprite>
		</scene>
	</scenes>
</unit>