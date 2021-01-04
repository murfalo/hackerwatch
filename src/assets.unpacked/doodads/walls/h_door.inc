<unit slot="doodad">
	<scenes close="close" open="open">

		<scene name="close">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 12 8 4" />
			<collision static="true">
				<rect>0 0 32 16</rect>
			</collision>
			<shadow darkness="1">
				<rect>0 0 32 16</rect>
			</shadow>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 48 32 48</frame>
			</sprite>
		</scene>
		<scene name="open">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 8 8 4" />
			<collision static="true">
				<rect>0 0 7 16</rect>
				<rect>25 0 7 16</rect>
			</collision>
			<shadow darkness="1">
				<rect>0 0 32 16</rect>
				<sprite project="false" origin="-7 0" texture="./base.png">
					<frame>96 6 8 10</frame>
				</sprite>				
			</shadow>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 96 32 48</frame>
			</sprite>
			<sprite layer="-10" origin="-7 -10" texture="./base.png" material="system/default.mats:floor">
				<frame>96 0 18 6</frame>
			</sprite>
			
		</scene>
	</scenes>
</unit>