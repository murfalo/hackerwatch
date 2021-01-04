<unit slot="doodad" layer="10">
	<scenes>
		<scene>
			<minimap_sprite origin="0 248" layer="100" texture="doodads/test.png" frame="0 0 256 256" />
			%if MINE_GRANITE
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:mine_granite">
			%elif PRISON
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:prison">
			%elif ARMORY
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:armory">
			%elif ARCHIVES
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:archives">
			%elif CHAMBERS
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:chambers">			
			%elif CHALLENGE
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:challenge">
			%elif BATTLEMENTS
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:battlements">
			%elif PYRAMID_FANCY
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:pyramid_fancy">
			%elif PYRAMID_SLUM
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:pyramid_slum">
			%elif TEMPLE_POOR
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:temple_poor">		
			%elif TEMPLE_COMMON
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:temple_common">					
			%elif TEMPLE_RICH
			<sprite origin="0 1024" texture="doodads/special/colors.png" material="doodads/special/colors.mats:temple_rich">				
			%endif	
				<frame>0 0 1024 1024</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
