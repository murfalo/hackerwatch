<unit slot="doodad">
		%if MINE_GRANITE
		<scenes default="mines_granite">
		%elif PRISON
		<scenes default="prison">
		%elif ARMORY
		<scenes default="armory">
		%elif ARCHIVES
		<scenes default="archives">
		%elif TEMPLE
		<scenes default="temple">
		%else
		<scenes default="defualt">	
		%endif	
		<scene name="shared">
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 72 64 72</frame>
			</sprite>
		</scene>
		
		<scene name="defualt">
			<scene src="shared" />
			<minimap_sprite origin="0 10" layer="50" texture="gui/minimap.png" frame="8 14 16 14"/>
		</scene>		
			
		<scene name="mines_granite">
			<scene src="shared" />
			<minimap_sprite origin="0 10" layer="50" texture="gui/minimap.png" frame="100 8 16 11"/>
			<light pos="32 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<looping value="true" />
				<cast-shadows value="true" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="150" />
				</sizes>
				<colors>
					<color value="220 190 50 0" />
				</colors>
			</light>			
		</scene>		
		
		<scene name="temple">	
			<minimap_sprite origin="-2 4" layer="50" texture="gui/minimap.png" frame="220 211 12 13"/>
			<sprite layer="1" origin="-8 44" texture="./exit.png" material="system/default.mats:default">
				<frame>128 0 48 40</frame>
			</sprite>			
		</scene>		
	</scenes>
</unit>