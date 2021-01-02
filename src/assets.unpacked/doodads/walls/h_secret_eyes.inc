<unit slot="doodad">
	<scenes>
		<scene >
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 4 4" />			
			<shadow darkness="1">
				<rect>0 0 16 16</rect>
			</shadow>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame time="150">80 176 16 48</frame>
			</sprite>
			%if MINE_GRANITE		
			<sprite ulayer="1" origin="-6 -2" texture="./../_shared.png" material="system/default.mats:bright">
			%endif
			%if PRISON		
			<sprite ulayer="1" origin="-6 -2" texture="./../_shared.png" material="system/default.mats:bright">
			%endif
			%if CHAMBERS		
			<sprite ulayer="1" origin="-7 6" texture="./../_shared.png" material="system/default.mats:bright">
			%endif
			%if ARCHIVES	
			<sprite ulayer="1" origin="-7 2" texture="./../_shared.png" material="system/default.mats:bright">
			%endif
			%if ARMORY		
			<sprite ulayer="1" origin="-6 3" texture="./../_shared.png" material="system/default.mats:bright">
			%endif						
				<frame time="150">30 30 3 1</frame>
				<frame time="5000">30 30 0 0</frame>
			</sprite>
		</scene>			
	</scenes>
</unit>
