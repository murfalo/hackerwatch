%define THEME_VARS_1
<unit slot="doodad">
	<scenes>
		<scene>
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 4 4" />
			<collision static="true">
				<rect>-2 0 20 16</rect>
			</collision>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>16 128 16 48</frame>
			</sprite>
			<shadow darkness="1">
				<rect>0 0 16 16</rect>
			</shadow>
		</scene>
	</scenes>
</unit>