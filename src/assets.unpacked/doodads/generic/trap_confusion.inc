<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		
		<array name="effects">
			<dict>
				<string name="class">ApplyBuff</string>
				<string name="buff">actors/buffs.sval:trap_confusion</string>
			</dict>
		</array>		
	</behavior>
	
	<scenes on="on" off="off">
		<scene name="shared">
			<sprite ulayer="1" origin="16 16" texture="./trap_confusion.png" material="system/default.mats:floor">
%if DESERT
				<frame>0 32 32 32</frame>
%else
				<frame>0 0 32 32</frame>
%endif	
			</sprite>
			<effect ulayer="-1" pos="0 0" src="doodads/generic/trap_confusion.effect"/>					
		</scene>
		
		<scene name="on" trigger-snd="event:/misc/trap_default-on">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />

			<collision static="true">
				<circle sensor="true" shoot-through="true" aim-through="true" offset="0 0" radius="15" />
			</collision>			
			
			<sprite origin="16 16" ulayer="2" looping="false" texture="./trap_confusion.png" material="doodads/generic/traps.mats:spikes">
				<frame time="60">32 0 32 32</frame>
				<frame time="60">64 0 32 32</frame>
				<frame time="60">96 0 32 32</frame>
				<frame time="60">128 0 32 32</frame>
				<frame time="60">0 0 0 0</frame>
			</sprite>
			
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="400" />
				<overbright value="50" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="54"/>
				</sizes>
				<colors>
					<color value="60 40 20 0"/>
				</colors>
			</light>
		</scene>

		<scene name="off" trigger-snd="event:/misc/trap_default-off">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_confusion.png" material="system/default.mats:floor">
				<frame time="60">128 0 32 32</frame>
				<frame time="60">96 0 32 32</frame>
				<frame time="60">64 0 32 32</frame>
				<frame time="60">32 0 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
