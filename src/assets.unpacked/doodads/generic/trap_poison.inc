<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		
		<array name="effects">
			<dict>
				<string name="class">ApplyBuff</string>
				<string name="buff">actors/buffs.sval:poison_strong</string>
			</dict>
		</array>		
	</behavior>
	
	<scenes on="on" off="off">
		<scene name="shared">
			<sprite ulayer="1" origin="16 16" texture="./trap_poison.png" material="system/default.mats:floor">
%if DESERT
				<frame>0 32 32 32</frame>
%else
				<frame>0 0 32 32</frame>
%endif	
			</sprite>
			<effect ulayer="-1" pos="0 0" src="./trap_poison.effect"/>
		</scene>
		
		<scene name="on" random-start="true" trigger-snd="event:/misc/trap_default-on">
			<scene src="shared" />
			%if GAME
			<effect ulayer="3" pos="-24 -28" src="./trap_poison_smoke.effect"/>
			%endif
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />

			<collision static="false">
				<rect sensor="true" shoot-through="true" aim-through="true">-14 -14 28 28</rect>
			</collision>			
			
			<sprite origin="16 16" ulayer="2" looping="false" texture="./trap_poison.png" material="doodads/generic/traps.mats:spikes">
				<frame time="60">32 0 32 32</frame>
				<frame time="60">64 0 32 32</frame>
				<frame time="60">96 0 32 32</frame>
				<frame time="60">128 0 32 32</frame>
				<frame time="60">0 0 0 0</frame>
			</sprite>
			
			<light pos="0 0">
				<sprite texture="./trap_poison_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="500" />
				<overbright value="10"/>
				<looping value="true" />
				<cast-shadows value="true" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="48" />
				</sizes>
				<colors>
					<color value="0 200 0 0" />
					<color value="0 175 0 0" />
				</colors>
			</light>			
			
		</scene>

		<scene name="off" trigger-snd="event:/misc/trap_default-off">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_poison.png" material="system/default.mats:floor">
				<frame time="60">128 0 32 32</frame>
				<frame time="60">96 0 32 32</frame>
				<frame time="60">64 0 32 32</frame>
				<frame time="60">32 0 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
