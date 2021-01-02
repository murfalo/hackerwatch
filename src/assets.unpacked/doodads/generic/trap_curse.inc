<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		<dict name="effect">
			<string name="class">AddCurse</string>
			<int name="amount">1</int>
		</dict>
	</behavior>
	<scenes on="on" off="off">
		<scene name="shared">
			<sprite origin="16 16" texture="./trap_curse.png" material="system/default.mats:floor">
%if PYRAMID_SLUM
				<frame>0 32 32 32</frame>
%elif PYRAMID_FANCY
				<frame>32 32 32 32</frame>
%else
				<frame>0 0 32 32</frame>
%endif
			</sprite>
		</scene>
		<scene name="on" random-start="true" trigger-snd="event:/misc/trap_curse-on">
			<scene src="shared" />			
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<collision static="false">
				<rect sensor="true" shoot-through="true" aim-through="true">-14 -14 28 28</rect>
			</collision>
			<sprite ulayer="1" origin="16 16" texture="./trap_curse.png" material="system/default.mats:glow-both-bright">
				<frame time="250">64 32 32 32</frame>
			</sprite>
			<sprite ulayer="-1" origin="16 16" texture="./trap_curse.png" material="doodads/generic/traps.mats:spikes"> <!-- XRAY -->
				<frame time="250">96 32 32 32</frame>
			</sprite>
			<sprite ulayer="2"  origin="16 16" texture="./trap_curse.png" material="system/default.mats:glow-both-bright">
				<frame time="100">0 0 32 32</frame>
				<frame time="1000">0 0 0 0</frame>
				<frame time="100">32 0 32 32</frame>
				<frame time="1000">0 0 0 0</frame>
				<frame time="100">64 0 32 32</frame>
				<frame time="1000">0 0 0 0</frame>
				<frame time="100">96 0 32 32</frame>
				<frame time="1000">0 0 0 0</frame>
			</sprite>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="10"/>
				<looping value="true" />
				<cast-shadows value="true" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="52" />
				</sizes>
				<colors>
					<color value="150 170 0 0" />
				</colors>
			</light>
		</scene>
		<scene name="off" trigger-snd="event:/misc/trap_curse-off">
			<scene src="shared" />			
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />
		</scene>			
		
	</scenes>
</unit>
