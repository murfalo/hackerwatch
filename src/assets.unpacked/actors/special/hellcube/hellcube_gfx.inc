	<scenes default="idle">
		<scene name="shared">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="true">
				<polygon aim-through="false" shoot-through="false" charge-through="false">
					<point>-13 0</point>
					<point>-13 -1</point>
					<point>0 -14</point>
					<point>1 -14</point>
					<point>14 -1</point>
					<point>14 0</point>
					<point>1 13</point>
					<point>0 13</point>
				</polygon>
			</collision>
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="2"/>
				<looping value="true" />
				<cast-shadows value="true" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="200" />
				</sizes>
				<colors>
					%if STAGE1
					<color value="220 170 50 0" />
					%elif STAGE2
					<color value="220 120 40 0" />
					%elif STAGE3
					<color value="220 100 20 0" />
					%elif STAGE4
					<color value="220 80 0 0" />
					%elif STAGE5
					<color value="220 60 0 0" />
					%elif STAGE6
					<color value="220 40 0 0" />
					%elif STAGE7
					<color value="220 20 0 0" />
					%elif STAGE8
					<color value="220 0 0 0" />
					%endif
				</colors>
			</light>	
			%if STAGE8
			<light pos="0 -8">
				<sprite texture="./flare3_L.png">
					<frame>0 0 256 256</frame>
				</sprite>
				<length value="250" />
				<overbright value="2"/>
				<looping value="true" />
				<cast-shadows value="all" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="512" />
				</sizes>
				<colors>
					<color value="255 0 0 0" />
					<color value="200 50 0 0" />
				</colors>
			</light>	
			%endif	
			<sprite origin="14 29" ulayer="1" texture="./hellcube.png" material="system/default.mats:default-noxray">
				%if STAGE1
				<frame>0 0 30 42</frame>
				%elif STAGE2
				<frame>30 0 30 42</frame>
				%elif STAGE3
				<frame>60 0 30 42</frame>
				%elif STAGE4
				<frame>90 0 30 42</frame>
				%elif STAGE5
				<frame>0 42 30 42</frame>
				%elif STAGE6
				<frame>30 42 30 42</frame>
				%elif STAGE7
				<frame>60 42 30 42</frame>
				%elif STAGE8
				<frame>90 42 30 42</frame>
				%endif
			</sprite>
			<sprite origin="14 29" texture="./hellcube.png" material="system/default.mats:glow-both-bright">
				%if !STAGE8 <!-- defines if NOT stage8 /hipshot -->
				<frame time="150">0 84 30 42</frame>
				<frame time="150">30 84 30 42</frame>
				<frame time="150">60 84 30 42</frame>
				<frame time="150">30 84 30 42</frame>
				%else
				<frame time="75">0 84 30 42</frame>
				<frame time="75">30 84 30 42</frame>
				%endif
			</sprite>				
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<effect ulayer="-1" pos="0 0" src="./fx_under.effect" />
		</scene>

		<scene name="attack">
			<scene src="shared" />
			<effect layer="-8" pos="0 -8" src="./fx_attack.effect" />
		</scene>
		
	</scenes>