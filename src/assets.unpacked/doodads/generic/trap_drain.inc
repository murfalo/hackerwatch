<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		<int name="actor-filter">2</int>
		
		<array name="effects">
			<dict>
				<string name="class">ApplyBuff</string>
				<string name="buff">actors/buffs.sval:drain_strong</string>
			</dict>
			<dict>
				<string name="class">ApplyBuff</string>
				<string name="buff">actors/buffs.sval:darkness</string>
			</dict>
		</array>		
	</behavior>
	
	<scenes on="on" off="off">
		<scene name="shared">
			<sprite origin="16 16" ulayer="-1" texture="./trap_drain.png" material="system/default.mats:floor">
%if DESERT
				<frame>0 128 32 32</frame>
%else
				<frame>0 0 32 32</frame>
%endif	
			</sprite>
		</scene>
		
		<scene name="on" trigger-snd="event:/misc/trap_default-on">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />

			<collision static="true">
				<polygon sensor="true" shoot-through="true" aim-through="true" decompose="2">
					<point>-9 -15</point> <!-- NE -->
					<point>9 -15</point>
					<point>15 -9</point>					
					<point>15 9</point>
					<point>9 15</point>						
					<point>-9 15</point> 
					<point>-15 9</point> <!-- SW -->
					<point>-15 -9</point> <!-- NW -->
				</polygon>
			</collision>			
			
			
			<sprite origin="16 16" ulayer="1" looping="false" texture="./trap_drain.png" material="system/default.mats:floor">
				<frame time="50">32 0 32 32</frame>
				<frame time="50">64 0 32 32</frame>
				<frame time="50">96 0 32 32</frame>
				<frame time="50">128 0 32 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="16 16" ulayer="0" looping="true" texture="./trap_drain.png" material="system/default.mats:floor">
				<frame time="50">0 32 32 32</frame>
				<frame time="50">32 32 32 32</frame>
				<frame time="50">64 32 32 32</frame>
				<frame time="50">96 32 32 32</frame>
				<frame time="50">128 32 32 32</frame>
				<frame time="50">160 32 32 32</frame>
				<frame time="50">192 32 32 32</frame>
				<frame time="50">224 32 32 32</frame>
				<frame time="50">0 64 32 32</frame>
				<frame time="50">32 64 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="0" looping="true" texture="./trap_drain.png" material="system/default.mats:floor">
				<frame time="50">96 64 32 32</frame>
				<frame time="50">128 64 32 32</frame>
				<frame time="50">160 64 32 32</frame>
				<frame time="50">224 64 32 32</frame>
				<frame time="50">0 96 32 32</frame>
			</sprite>			
			<sprite origin="16 16" ulayer="0" looping="true" texture="./trap_drain.png" material="system/default.mats:floor">
				<frame time="200">64 64 32 32</frame>
				<frame time="200">0 0 0 0</frame>
			</sprite>
			<light pos="0 0">
				<sprite texture="./trap_drain_L.png">
					<frame>0 0 64 64</frame>
				</sprite>
				<length value="2000" />
				<overbright value="50" />a
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="64" />
				</sizes>
				<colors>
					<color value="100 0 100 0" />
					<color value="0 0 100 0" />
					<color value="50 50 50 0" />					
				</colors>
			</light>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="2000" />
				<overbright value="50" />a
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="80" />
				</sizes>
				<colors>
					<color value="25 0 25 0" />					
				</colors>
			</light>			
		</scene>

		<scene name="off" trigger-snd="event:/misc/trap_default-off">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			
			<sprite origin="16 16" ulayer="1" looping="false" texture="./trap_drain.png" material="system/default.mats:floor">
				<frame time="50">128 0 32 32</frame>
				<frame time="50">96 0 32 32</frame>
				<frame time="50">64 0 32 32</frame>
				<frame time="50">32 0 32 32</frame>
			</sprite>			
				
		</scene>
	</scenes>
</unit>
