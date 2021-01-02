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
		%endif
		<scene name="shared">
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>64 72 64 72</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 0 30 13</frame>
			</sprite>
			<light pos="32 -40">
				<sprite texture="../exit_light_cone_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="1500" />
				<overbright value="20"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="150" />
				</sizes>
				<colors>
					<color value="220 200 50 0" />
					<color value="220 170 50 0" />
				</colors>
			</light>	
			<effect ulayer="2" pos="4 -30" src="doodads/walls/exit_moth.effect" />
			<effect ulayer="2" pos="-3 -20" src="doodads/walls/exit_moth.effect" />
			<effect ulayer="2" pos="-5 -10" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="3 -8" src="doodads/walls/exit_moth.effect" />				
			<effect ulayer="2" pos="0 0" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="3 8" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="5 10" src="doodads/walls/exit_moth.effect" />							
		</scene>			
		<scene name="mines_granite">
			<scene src="shared" />
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="8 0 16 14"/>
		</scene>
		
		<scene name="prison">
			<scene src="shared" />
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="8 0 16 14"/>
		</scene>		

		<scene name="armory">
			<scene src="shared" />
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="8 0 16 14"/>
		</scene>
		
		<scene name="temple">
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="8 0 16 14"/>
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 56</frame>
			</sprite>			
			<sprite origin="0 16" texture="./exit.png" material="system/default.mats:default">
				<frame>0 56 64 16</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 26 30 13</frame>
			</sprite>
			<light pos="32 -40">
				<sprite texture="../exit_light_cone_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="1500" />
				<overbright value="20"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="150" />
				</sizes>
				<colors>
					<color value="220 200 50 0" />
					<color value="220 170 50 0" />
				</colors>
			</light>	
			<effect ulayer="2" pos="4 -30" src="doodads/walls/exit_moth.effect" />
			<effect ulayer="2" pos="-3 -20" src="doodads/walls/exit_moth.effect" />
			<effect ulayer="2" pos="-5 -10" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="3 -8" src="doodads/walls/exit_moth.effect" />				
			<effect ulayer="2" pos="0 0" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="3 8" src="doodads/walls/exit_moth.effect" />	
			<effect ulayer="2" pos="5 10" src="doodads/walls/exit_moth.effect" />	
		</scene>			
		
	</scenes>
</unit>