<unit slot="doodad" layer="-20">

	<behavior class="ProximityTrap">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		<array name="effects">
			<dict>
				<string name="class">Damage</string>
				<int name="magical">50</int>
			</dict>
			<dict>
				<string name="class">ApplyBuff</string>
				<string name="buff">actors/buffs.sval:burning_strong</string>
			</dict>
		</array>
	</behavior>

	<scenes off="off" on="on" disabled="disabled">
		<scene name="shared">
%if DESERT
			<sprite origin="16 16" ulayer="4" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 64 32 32</frame>
			</sprite>	
%else
			%//nothing
%endif				
			<collision static="true">
				<!-- Damaging sensor -->
				<rect sensor="true" shoot-through="true" aim-through="true">-14 -14 28 28</rect>
				<!-- Proximity sensor -->
				<rect sensor="true" shoot-through="true" aim-through="true">-21 -21 42 42</rect>
			</collision>	
			
		</scene>

		<scene name="off">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />
			<scene src="shared" />
			<sprite origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="-2" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>32 32 32 32</frame>
			</sprite>			
		</scene>

		<scene name="on" trigger-snd="event:/misc/trap_fire">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<scene src="shared" />
			
			<sprite origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="-2" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>32 32 32 32</frame>
			</sprite>				
			
			<effect ulayer="20" pos="0 0" src="doodads/generic/trap_fire_particles.effect"/>
			<effect ulayer="-1" pos="0 0" src="doodads/generic/trap_fire_wave.effect"/>
			
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="50" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="54" />
				</sizes>
				<colors>
					<color value="50 20 0 15" />
					<color value="25 10 0 10" />
				</colors>
			</light>		
			
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="2" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="80" />
				</sizes>
				<colors>
					<color value="255 20 0 15" />
				</colors>
			</light>		
		</scene>

		<scene name="activate">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<scene src="shared" />
			
			<sprite origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="-2" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>32 32 32 32</frame>
			</sprite>				
			
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame time="25">0 0 32 32</frame>	
				<frame time="25">32 0 32 32</frame>
				<frame time="25">64 0 32 32</frame>
				<frame time="25">96 0 32 32</frame>
				<frame time="25">128 0 32 32</frame>
				<frame time="25">160 0 32 32</frame>
			</sprite>
			
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="100" />
				<overbright value="5" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="80" />
				</sizes>
				<colors>
					<color value="255 0 0 15" />
				</colors>
			</light>			
			
		</scene>

		<scene name="deactivate">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />
			<scene src="shared" />
			
			<sprite origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="-2" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>32 32 32 32</frame>
			</sprite>				
			
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame time="25">160 0 32 32</frame>	
				<frame time="25">128 0 32 32</frame>
				<frame time="25">96 0 32 32</frame>
				<frame time="25">64 0 32 32</frame>
				<frame time="25">32 0 32 32</frame>
				<frame time="25">0 0 32 32</frame>
				<frame time="25">0 0 0 0</frame>
			</sprite>	
		</scene>
		
		<scene name="disabled">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />
			<sprite origin="16 16" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>
			<sprite origin="16 16" ulayer="-2" texture="./trap_fire.png" material="system/default.mats:floor">
				<frame>32 32 32 32</frame>
			</sprite>	
		</scene>
	</scenes>
</unit>