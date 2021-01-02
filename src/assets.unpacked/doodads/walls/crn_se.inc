%define THEME_VARS_1
<unit slot="doodad">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 4 4" />
			<collision static="true">
				<rect>-2 0 18 16</rect>
				<rect>0 -2 16 18</rect>
			</collision>
			<shadow darkness="1">
				<rect>0 0 16 16</rect>
			</shadow>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>16 64 16 48</frame>
			</sprite>			
		</scene>
	</scenes>
</unit>