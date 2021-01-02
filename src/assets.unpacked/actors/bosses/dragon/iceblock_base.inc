	<scenes default="default">
		<scene name="default">
			<minimap_sprite origin="3 3" texture="gui/minimap.png" frame="0 20 6 6" />
			<collision static="true">
				<circle offset="0 0" aim-through="true" radius="13" />
			</collision>
			
			<sprite origin="16 13" layer="-15" looping="true" texture="./iceblock.png" material="system/default.mats:floor">
				<frame time="150">0 67 30 27</frame>
			</sprite>				
			<sprite origin="18 16" layer="-52" looping="true" texture="./iceblock.png" material="system/default.mats:floor">
				<frame time="150">0 94 36 34</frame>
			</sprite>				
			<sprite origin="13 28" looping="true" texture="./iceblock.png" material="system/default.mats:default-noxray">
				<frame time="150">0 0 29 39</frame>
			</sprite>
			
			<light pos="0 -5">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="3" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="60" />
				</sizes>
				<colors>
					<color value="75 150 250 10" />
				</colors>
			</light>
			
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="1" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="120" />
				</sizes>
				<colors>
					<color value="50 125 200 0" />
				</colors>
			</light>			
			
		</scene>

	</scenes>