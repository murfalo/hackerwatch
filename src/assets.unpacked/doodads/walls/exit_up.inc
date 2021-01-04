<unit slot="doodad">
	<scenes on="on" off="off" disabled="disabled" blocked="blocked">
		<scene name="on">
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="8 0 16 14"/>
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>
			%if TEMPLE
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 56</frame>
			</sprite>			
			<sprite origin="0 16" texture="./exit.png" material="system/default.mats:default">
				<frame>0 56 64 16</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 26 30 13</frame>
			</sprite>
			%elif TEMPLE_RICH
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 72</frame>
			</sprite>	
			<sprite layer="-1" origin="-16 19" texture="./exit.png" material="system/default.mats:default">
				<frame>160 0 34 21</frame>
			</sprite>
			<sprite origin="-16 -2" layer="-9" texture="./exit.png" material="system/default.mats:floor">
				<frame>160 21 32 14</frame>
			</sprite>
			%else
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 0 64 72</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 0 30 13</frame>
			</sprite>
			%endif
			%if CHAMBERS
				<effect ulayer="100" src="doodads/walls/chambers/door_open.effect"/>
				<sprite ulayer="100" looping="false" origin="-19 24" texture="./exit.png" material="system/default.mats:default-noxray">
					<frame time="2000">0 0 0 0</frame>
					<frame>74 209 26 5</frame>
				</sprite>
			%endif
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
		
		<scene name="off">
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="240 134 16 14"/>
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>			
			%if TEMPLE
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 56</frame>
			</sprite>			
			<sprite origin="0 16" texture="./exit.png" material="system/default.mats:default">
				<frame>0 56 64 16</frame>
			</sprite>
			%elif TEMPLE_RICH
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 72</frame>
			</sprite>	
			<sprite layer="-1" origin="-16 19" texture="./exit.png" material="system/default.mats:default">
				<frame>160 0 34 21</frame>
			</sprite>
			%else
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 0 64 72</frame>
			</sprite>
%//			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
%//				<frame>0 0 30 13</frame>
%//			</sprite>
			%endif
			%if CHAMBERS
				<effect ulayer="100" src="doodads/walls/chambers/door_closed.effect"/>
			%endif
		</scene>	
		
		<scene name="disabled">
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="72 32 16 14"/>
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>		
			%if TEMPLE
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 56</frame>
			</sprite>			
			<sprite origin="0 16" texture="./exit.png" material="system/default.mats:default">
				<frame>0 56 64 16</frame>
			</sprite>
			%elif TEMPLE_RICH
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 72</frame>
			</sprite>	
			<sprite layer="-1" origin="-16 19" texture="./exit.png" material="system/default.mats:default">
				<frame>160 0 34 21</frame>
			</sprite>
			%endif
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 0 64 72</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 0 30 13</frame>
			</sprite>
			%if CHAMBERS
				<effect ulayer="100" src="doodads/walls/chambers/door_closed.effect"/>
			%endif
		</scene>		
		<scene name="blocked">
			<minimap_sprite origin="0 10" layer="500" texture="gui/minimap.png" frame="240 134 16 14"/>
			<collision static="true">
				<rect>0 -16 64 16</rect>
			</collision>		
			%if TEMPLE
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 56</frame>
			</sprite>			
			<sprite origin="0 16" texture="./exit.png" material="system/default.mats:default">
				<frame>0 56 64 16</frame>
			</sprite>
			%elif TEMPLE_RICH
			<sprite layer="1" origin="0 72" texture="./exit.png" material="system/default.mats:default-noxray">
				<frame>0 0 64 72</frame>
			</sprite>	
			<sprite layer="-1" origin="-16 19" texture="./exit.png" material="system/default.mats:default">
				<frame>160 0 34 21</frame>
			</sprite>
			%elif PYRAMID_FANCY
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 144 64 72</frame>
			</sprite>
			<sprite origin="0 0" layer="-9" texture="./exit.png" material="system/default.mats:floor">
				<frame>0 216 64 11</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 0 30 13</frame>
			</sprite>
			%else
			<sprite origin="0 72" texture="./exit.png" material="system/default.mats:proj-wall">
				<frame>0 0 64 72</frame>
			</sprite>
			<sprite origin="-17 -1" layer="-10" texture="./../_shared.png" material="system/default.mats:floor">
				<frame>0 0 30 13</frame>
			</sprite>
			%endif
			%if CHAMBERS
				<effect ulayer="100" src="doodads/walls/chambers/door_closed.effect"/>
			%endif
		</scene>			
					
	</scenes>
</unit>