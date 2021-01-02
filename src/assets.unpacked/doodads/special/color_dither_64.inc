<unit slot="doodad">
	<scenes>
		<scene>
			<minimap_sprite origin="0 8" layer="100" texture="doodads/test.png" frame="0 0 16 16" />
			%if GAME
			%if MINE_GRANITE
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:mine_granite_dither">
			%elif PRISON
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:prison_dither">
			%elif ARMORY
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:armory_dither">
			%elif ARCHIVES
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:archives_dither">
			%elif CHAMBERS
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:chambers_dither">				
			%elif PYRAMID_SLUM
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:pyramid_slum_dither">			
			%elif PYRAMID_FANCY
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:pyramid_fancy_dither">			
			%endif	
			%endif
			%if EDITOR
			<sprite origin="0 64" texture="doodads/special/colors_dither.png" material="doodads/special/colors.mats:editor_dither">
			%endif
				<frame>0 0 64 64</frame>
			</sprite>				
		</scene>
	</scenes>
</unit>