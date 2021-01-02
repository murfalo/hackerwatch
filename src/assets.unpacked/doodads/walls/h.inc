<unit slot="doodad">
		%if MINE_GRANITE
		<scenes default="1 2 3 4">
		%elif PRISON
		<scenes default="1 2 3">
		%elif ARMORY
		<scenes default="1">
		%elif CHAMBERS
		<scenes default="1">
		%elif CHALLANGE
		<scenes default="1 1 1 2">
		%elif TEMPLE_RICH
		<scenes default="1 2 3 ">
		%else
		<scenes default="1">
		%endif	
		<scene name="shared">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 8 4" />
			<collision static="true">
				<rect>-2 0 36 16</rect>
			</collision>
			<shadow darkness="1">
				<rect>0 0 32 16</rect>
			</shadow>
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>0 0 32 48</frame>
			</sprite>
		</scene>		
		<scene name="1">
			<scene src="shared" />
		</scene>			
		<scene name="2">
			<scene src="shared" />
			%if MINE_GRANITE	
			<sprite ulayer="1" origin="-20 -2" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>82 0 6 14</frame>
			</sprite>				
			%endif
			%if PRISON	
			<sprite ulayer="1" origin="-4 -10" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 0 24 6</frame>
			</sprite>				
			%endif
			%if CHALLANGE
			<sprite ulayer="1" origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>96 0 32 48</frame>
			</sprite>				
			%endif		
			%if TEMPLE_RICH	
			<sprite ulayer="1" origin="-4 5" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 0 24 18</frame>
			</sprite>				
			%endif			
		</scene>	
		<scene name="3">
			<scene src="shared" />			
			%if MINE_GRANITE	
			<sprite ulayer="1" origin="-13 3" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>64 0 7 15</frame>
			</sprite>				
			%endif
			%if PRISON	
			<sprite ulayer="1" origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>96 0 32 48</frame>
			</sprite>			
			%endif	
			%if TEMPLE_RICH	
			<sprite ulayer="1" origin="-2 6" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>88 0 28 21</frame>
			</sprite>				
			%endif					
		</scene>
		<scene name="4">
			<scene src="shared" />			
			%if MINE_GRANITE	
			<sprite ulayer="1" origin="-13 22" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>71 0 11 27</frame>
			</sprite>				
			%endif				
		</scene>								
	</scenes>
</unit>