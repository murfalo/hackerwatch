<unit slot="doodad">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 8 4" />
			<collision static="true">
				<rect>0 0 32 16</rect>
			</collision>
			
			<shadow darkness="1">
				<rect>0 0 32 16</rect>
			</shadow>

			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 0 32 48</frame>
			</sprite>			
		</scene>						
	</scenes>
</unit>