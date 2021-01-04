		<scene name="shared-global">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="MINIMAPICON"/>
			<effect src="AGENTPATH/marker.effect" />
			<effect src="actors/mt/bosses/agents/shadow.effect" />
		</scene>

		<scene name="shared">
			<collision static="false">
				<circle offset="0 0" radius="8" aim-through="false" charge-through="false" density="999"/>
				<circle offset="0 -10" radius="5" sensor="true" shoot-through="false" aim-through="true" charge-through="false" density="1"/>
			</collision>
			<light pos="0 -8">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="300" />
				<overbright value="1"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="64" />
				</sizes>
				<colors>
					<color value="150 150 150 0" />
				</colors>
			</light>
		</scene>
		
		<scene name="shared-charge">
			<collision static="false">
				<circle radius="8" charging="true" sensor="false" shoot-through="false" aim-through="false" density="1"/>
			</collision>
			<light pos="0 -8">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="300" />
				<overbright value="1"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="64" />
				</sizes>
				<colors>
					<color value="150 150 150 0" />
				</colors>
			</light>			
		</scene>
		
		<scene name="shared-shield">
			<collision static="true">
				<circle sensor="true" offset="0 0" radius="2"/>
			</collision>
			<light pos="0 -8">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="300" />
				<overbright value="1"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="64" />
				</sizes>
				<colors>
					<color value="150 150 150 0" />
				</colors>
			</light>			
		</scene>			
		
		<scene name="sword-light">
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="450" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="6" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="0" />
					<size value="48" />
					<size value="64" />
				</sizes>
				<colors>
					%if AGENT_STAR
					<color value="255 255 300 0" />
					%endif
					%if AGENT_BLAZE
					<color value="300 100 0 0" />
					%endif
					%if AGENT_RIME
					<color value="0 150 300 0" />
					%endif
					%if AGENT_DECAY
					<color value="0 300 0 0" />
					%endif
				</colors>
			</light>			
		</scene>
		
		<scene name="charge-light">
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="1000" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="6" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="0" />
					<size value="48" />
					<size value="64" />
				</sizes>
				<colors>
					%if AGENT_STAR
					<color value="255 255 300 0" />
					%endif
					%if AGENT_BLAZE
					<color value="300 100 0 0" />
					%endif
					%if AGENT_RIME
					<color value="0 150 300 0" />
					%endif
					%if AGENT_DECAY
					<color value="0 300 0 0" />
					%endif
				</colors>
			</light>			
		</scene>		

		<scene name="shoot-light">
			<light pos="0 0">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="300" />
				<overbright value="4"/>
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="0" />
				<size value="40" />
				</sizes>
				<colors>
					%if AGENT_STAR
					<color value="0 0 0 0" />
					<color value="236 236 255 1" />
					%endif
					%if AGENT_BLAZE
					<color value="0 0 0 0" />
					<color value="236 50 0 1" />
					%endif
					%if AGENT_RIME
					<color value="0 0 0 0" />
					<color value="0 236 255 1" />
					%endif
					%if AGENT_DECAY
					<color value="0 0 0 0" />
					<color value="0 236 0 1" />
					%endif
				</colors>
			</light>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="400" />
				<overbright value="4"/>
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="0" />
				<size value="80" />
				</sizes>
				<colors>
					%if AGENT_STAR
					<color value="0 0 0 0" />
					<color value="0 138 184 1" />
					<color value="0 0 0 0" />
					%endif
					%if AGENT_BLAZE
					<color value="0 0 0 0" />
					<color value="200 50 0 1" />
					<color value="0 0 0 0" />
					%endif
					%if AGENT_RIME
					<color value="0 0 0 0" />
					<color value="0 150 255 1" />
					<color value="0 0 0 0" />
					%endif
					%if AGENT_DECAY
					<color value="0 0 0 0" />
					<color value="0 200 0 1" />
					<color value="0 0 0 0" />
					%endif
				</colors>
			</light>
		</scene>
		
		<scene name="shoot_night-light">
			<light pos="0 0">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="300" />
				<overbright value="4"/>
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="0" />
				<size value="40" />
				</sizes>
				<colors>
					<color value="150 0 220 1" />
				</colors>
			</light>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
				<frame>0 0 128 128</frame>
				</sprite>
				<length value="400" />
				<overbright value="4"/>
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
				<size value="0" />
				<size value="80" />
				</sizes>
				<colors>
					<color value="0 0 0 0" />
					<color value="138 0 184 1" />
					<color value="0 0 0 0" />
				</colors>
			</light>
		</scene>		

		<scene name="idle-0">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-1">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-2">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-3">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-4">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-5">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-6">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">192 0 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="idle-7">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>		

		<scene name="walk-0">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">0 32 32 32</frame>
				<frame time="200">0 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-1">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">32 32 32 32</frame>
				<frame time="200">32 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-2">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">64 32 32 32</frame>
				<frame time="200">64 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-3">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">96 32 32 32</frame>
				<frame time="200">96 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-4">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">128 32 32 32</frame>
				<frame time="200">128 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-5">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">160 32 32 32</frame>
				<frame time="200">160 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-6">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">192 32 32 32</frame>
				<frame time="200">192 64 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="walk-7">
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="200">224 32 32 32</frame>
				<frame time="200">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="sword-0">
			<locator name="sword-pos" pos="11 0"/>
			<scene src="sword-light" pos="12 -4"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">256 0 32 32</frame>
				<frame time="250">256 32 32 32</frame>
				<frame time="50"> 256 64 32 32</frame>
				<frame time="200">256 96 32 32</frame>
				<frame time="25">256 128 32 32</frame>
				<frame time="25">256 160 32 32</frame>
				<frame time="25">256 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-1">
			<locator name="sword-pos" pos="7 7"/>
			<scene src="sword-light" pos="8 8"/>
			<scene src="shared-global" />
			<scene src="shared" />			
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">288 0 32 32</frame>
				<frame time="250">288 32 32 32</frame>
				<frame time="50"> 288 64 32 32</frame>
				<frame time="200">288 96 32 32</frame>
				<frame time="25">288 128 32 32</frame>
				<frame time="25">288 160 32 32</frame>
				<frame time="25">288 192 32 32</frame>
			</sprite>			
		</scene>
		
		<scene name="sword-2">
			<locator name="sword-pos" pos="0 10"/>
			<scene src="sword-light" pos="0 10"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">320 0 32 32</frame>
				<frame time="250">320 32 32 32</frame>
				<frame time="50"> 320 64 32 32</frame>
				<frame time="200">320 96 32 32</frame>
				<frame time="25">320 128 32 32</frame>
				<frame time="25">320 160 32 32</frame>
				<frame time="25">320 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-3">
			<locator name="sword-pos" pos="-7 7"/>
			<scene src="sword-light" pos="-8 8"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">352 0 32 32</frame>
				<frame time="250">352 32 32 32</frame>
				<frame time="50"> 352 64 32 32</frame>
				<frame time="200">352 96 32 32</frame>
				<frame time="25">352 128 32 32</frame>
				<frame time="25">352 160 32 32</frame>
				<frame time="25">352 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-4">
			<locator name="sword-pos" pos="-11 0"/>
			<scene src="sword-light" pos="-12 -4"/>
			<scene src="shared-global" />
			<scene src="shared" />				
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">384 0 32 32</frame>
				<frame time="250">384 32 32 32</frame>
				<frame time="50"> 384 64 32 32</frame>
				<frame time="200">384 96 32 32</frame>
				<frame time="25">384 128 32 32</frame>
				<frame time="25">384 160 32 32</frame>
				<frame time="25">384 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-5">
			<locator name="sword-pos" pos="-7 -7"/>
			<scene src="sword-light" pos="-7 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />				
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">416 0 32 32</frame>
				<frame time="250">416 32 32 32</frame>
				<frame time="50"> 416 64 32 32</frame>
				<frame time="200">416 96 32 32</frame>
				<frame time="25">416 128 32 32</frame>
				<frame time="25">416 160 32 32</frame>
				<frame time="25">416 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-6">
			<locator name="sword-pos" pos="0 -10"/>
			<scene src="sword-light" pos="0 -12"/>
			<scene src="shared-global" />
			<scene src="shared" />				
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">448 0 32 32</frame>
				<frame time="250">448 32 32 32</frame>
				<frame time="50"> 448 64 32 32</frame>
				<frame time="200">448 96 32 32</frame>
				<frame time="25">448 128 32 32</frame>
				<frame time="25">448 160 32 32</frame>
				<frame time="25">448 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="sword-7">
			<locator name="sword-pos" pos="7 -7"/>
			<scene src="sword-light" pos="7 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />				
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="50">480 0 32 32</frame>
				<frame time="250">480 32 32 32</frame>
				<frame time="50"> 480 64 32 32</frame>
				<frame time="200">480 96 32 32</frame>
				<frame time="25">480 128 32 32</frame>
				<frame time="25">480 160 32 32</frame>
				<frame time="25">480 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-0">
			<locator name="sword-pos" pos="11 0"/>
			<scene src="charge-light" pos="12 -4"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">256 0 32 32</frame> -->
				<frame time="50">256 32 32 32</frame>
				<frame time="50"> 256 64 32 32</frame>
				<frame time="2000">256 96 32 32</frame>
				<frame time="25">256 128 32 32</frame>
				<frame time="25">256 160 32 32</frame>
				<frame time="25">256 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-1">
			<locator name="sword-pos" pos="7 7"/>
			<scene src="charge-light" pos="8 8"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />			
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">288 0 32 32</frame> -->
				<frame time="50">288 32 32 32</frame>
				<frame time="50"> 288 64 32 32</frame>
				<frame time="2000">288 96 32 32</frame>
				<frame time="25">288 128 32 32</frame>
				<frame time="25">288 160 32 32</frame>
				<frame time="25">288 192 32 32</frame>
			</sprite>			
		</scene>
		
		<scene name="charge-2">
			<locator name="sword-pos" pos="0 10"/>
			<scene src="charge-light" pos="0 10"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">320 0 32 32</frame> -->
				<frame time="50">320 32 32 32</frame>
				<frame time="50"> 320 64 32 32</frame>
				<frame time="2000">320 96 32 32</frame>
				<frame time="25">320 128 32 32</frame>
				<frame time="25">320 160 32 32</frame>
				<frame time="25">320 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-3">
			<locator name="sword-pos" pos="-7 7"/>
			<scene src="charge-light" pos="-8 8"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">352 0 32 32</frame> -->
				<frame time="50">352 32 32 32</frame>
				<frame time="50"> 352 64 32 32</frame>
				<frame time="2000">352 96 32 32</frame>
				<frame time="25">352 128 32 32</frame>
				<frame time="25">352 160 32 32</frame>
				<frame time="25">352 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-4">
			<locator name="sword-pos" pos="-11 0"/>
			<scene src="charge-light" pos="-12 -4"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">384 0 32 32</frame> -->
				<frame time="50">384 32 32 32</frame>
				<frame time="50"> 384 64 32 32</frame>
				<frame time="2000">384 96 32 32</frame>
				<frame time="25">384 128 32 32</frame>
				<frame time="25">384 160 32 32</frame>
				<frame time="25">384 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-5">
			<locator name="sword-pos" pos="-7 -7"/>
			<scene src="charge-light" pos="-7 -7"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />				
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">416 0 32 32</frame> -->
				<frame time="50">416 32 32 32</frame>
				<frame time="50"> 416 64 32 32</frame>
				<frame time="2000">416 96 32 32</frame>
				<frame time="25">416 128 32 32</frame>
				<frame time="25">416 160 32 32</frame>
				<frame time="25">416 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-6">
			<locator name="sword-pos" pos="0 -10"/>
			<scene src="charge-light" pos="0 -12"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">448 0 32 32</frame> -->
				<frame time="50">448 32 32 32</frame>
				<frame time="50"> 448 64 32 32</frame>
				<frame time="2000">448 96 32 32</frame>
				<frame time="25">448 128 32 32</frame>
				<frame time="25">448 160 32 32</frame>
				<frame time="25">448 192 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="charge-7">
			<locator name="sword-pos" pos="7 -7"/>
			<scene src="charge-light" pos="7 -7"/>
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<!-- <frame time="200">480 0 32 32</frame> -->
				<frame time="50">480 32 32 32</frame>
				<frame time="50"> 480 64 32 32</frame>
				<frame time="2000">480 96 32 32</frame>
				<frame time="25">480 128 32 32</frame>
				<frame time="25">480 160 32 32</frame>
				<frame time="25">480 192 32 32</frame>
			</sprite>
		</scene>		

		<scene name="shoot-0">
			<locator name="shoot-pos" pos="6 -10"/>
			<scene src="shoot-light" pos="4 -11"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">0 96 32 32</frame>
				<frame time="100">0 128 32 32</frame>
				<frame time="100">0 160 32 32</frame>
				<frame time="50">0 192 32 32</frame>
				<frame time="50">0 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-1">
			<locator name="shoot-pos" pos="5 -6"/>
			<scene src="shoot-light" pos="1 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">32 96 32 32</frame>
				<frame time="100">32 128 32 32</frame>
				<frame time="100">32 160 32 32</frame>
				<frame time="50">32 192 32 32</frame>
				<frame time="50">32 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-2">
			<locator name="shoot-pos" pos="0 -4"/>
			<scene src="shoot-light" pos="0 -9"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">64 96 32 32</frame>
				<frame time="100">64 128 32 32</frame>
				<frame time="100">64 160 32 32</frame>
				<frame time="50">64 192 32 32</frame>
				<frame time="50">64 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-3">
			<locator name="shoot-pos" pos="-6 -6"/>
			<scene src="shoot-light" pos="-2 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">96 96 32 32</frame>
				<frame time="100">96 128 32 32</frame>
				<frame time="100">96 160 32 32</frame>
				<frame time="50">96 192 32 32</frame>
				<frame time="50">96 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-4">
			<locator name="shoot-pos" pos="-6 -10"/>
			<scene src="shoot-light" pos="-5 -10"/>
			<scene src="shared-global" />
			<scene src="shared" />		
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">128 96 32 32</frame>
				<frame time="100">128 128 32 32</frame>
				<frame time="100">128 160 32 32</frame>
				<frame time="50">128 192 32 32</frame>
				<frame time="50">128 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-5">
			<locator name="shoot-pos" pos="-8 -10"/>
			<scene src="shoot-light" pos="-5 -8"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">160 96 32 32</frame>
				<frame time="100">160 128 32 32</frame>
				<frame time="100">160 160 32 32</frame>
				<frame time="50">160 192 32 32</frame>
				<frame time="50">160 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-6">
			<locator name="shoot-pos" pos="0 -10"/>
			<scene src="shoot-light" pos="0 -10"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">192 96 32 32</frame>
				<frame time="100">192 128 32 32</frame>
				<frame time="100">192 160 32 32</frame>
				<frame time="50">192 192 32 32</frame>
				<frame time="50">192 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot-7">
			<locator name="shoot-pos" pos="9 -12"/>
			<scene src="shoot-light" pos="3 -9"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">224 96 32 32</frame>
				<frame time="100">224 128 32 32</frame>
				<frame time="100">224 160 32 32</frame>
				<frame time="50">224 192 32 32</frame>
				<frame time="50">224 224 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-0">
			<locator name="shoot-pos" pos="6 -10"/>
			<scene src="shoot_night-light" pos="4 -11"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">0 352 32 32</frame>
				<frame time="100">0 384 32 32</frame>
				<frame time="100">0 416 32 32</frame>
				<frame time="50">0 448 32 32</frame>
				<frame time="50">0 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-1">
			<locator name="shoot-pos" pos="5 -6"/>
			<scene src="shoot_night-light" pos="1 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">32 352 32 32</frame>
				<frame time="100">32 384 32 32</frame>
				<frame time="100">32 416 32 32</frame>
				<frame time="50">32 448 32 32</frame>
				<frame time="50">32 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-2">
			<locator name="shoot-pos" pos="0 -4"/>
			<scene src="shoot_night-light" pos="0 -9"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">64 352 32 32</frame>
				<frame time="100">64 384 32 32</frame>
				<frame time="100">64 416 32 32</frame>
				<frame time="50">64 448 32 32</frame>
				<frame time="50">64 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-3">
			<locator name="shoot-pos" pos="-6 -6"/>
			<scene src="shoot_night-light" pos="-2 -7"/>
			<scene src="shared-global" />
			<scene src="shared" />
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">96 352 32 32</frame>
				<frame time="100">96 384 32 32</frame>
				<frame time="100">96 416 32 32</frame>
				<frame time="50">96 448 32 32</frame>
				<frame time="50">96 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-4">
			<locator name="shoot-pos" pos="-6 -10"/>
			<scene src="shoot_night-light" pos="-5 -10"/>
			<scene src="shared-global" />
			<scene src="shared" />		
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">128 352 32 32</frame>
				<frame time="100">128 384 32 32</frame>
				<frame time="100">128 416 32 32</frame>
				<frame time="50">128 448 32 32</frame>
				<frame time="50">128 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-5">
			<locator name="shoot-pos" pos="-8 -10"/>
			<scene src="shoot_night-light" pos="-5 -8"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">160 352 32 32</frame>
				<frame time="100">160 384 32 32</frame>
				<frame time="100">160 416 32 32</frame>
				<frame time="50">160 448 32 32</frame>
				<frame time="50">160 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-6">
			<locator name="shoot-pos" pos="0 -10"/>
			<scene src="shoot_night-light" pos="0 -10"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">192 352 32 32</frame>
				<frame time="100">192 384 32 32</frame>
				<frame time="100">192 416 32 32</frame>
				<frame time="50">192 448 32 32</frame>
				<frame time="50">192 480 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="shoot_night-7">
			<locator name="shoot-pos" pos="9 -12"/>
			<scene src="shoot_night-light" pos="3 -9"/>
			<scene src="shared-global" />
			<scene src="shared" />	
			<sprite looping="false" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">224 352 32 32</frame>
				<frame time="100">224 384 32 32</frame>
				<frame time="100">224 416 32 32</frame>
				<frame time="50">224 448 32 32</frame>
				<frame time="50">224 480 32 32</frame>
			</sprite>
		</scene>		
	
		<scene name="spin">
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="true" loopback="700" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">256 32 32 32</frame>
				<frame time="100">288 32 32 32</frame>
				<frame time="100">320 32 32 32</frame>
				<frame time="100">352 32 32 32</frame>
				<frame time="75">384 32 32 32</frame>
				<frame time="75">416 32 32 32</frame>
				<frame time="75">448 32 32 32</frame>
				<frame time="75">480 32 32 32</frame>
		
				<frame time="25">256 224 32 32</frame>
				<frame time="25">288 224 32 32</frame>
				<frame time="25">320 224 32 32</frame>
				<frame time="25">352 224 32 32</frame>
				<frame time="25">384 224 32 32</frame>
				<frame time="25">416 224 32 32</frame>
				<frame time="25">448 224 32 32</frame>
				<frame time="25">480 224 32 32</frame>
			</sprite>
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="3200" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="4" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="80" />
					<size value="80" />
					<size value="80" />
					<size value="80" />
				</sizes>
				<colors>
					%if AGENT_STAR
					<color value="200 200 250 0" />
					%endif
					%if AGENT_BLAZE
					<color value="300 50 0 0" />
					%endif
					%if AGENT_RIME
					<color value="0 100 300 0" />
					%endif
					%if AGENT_DECAY
					<color value="0 300 0 0" />
					%endif
				</colors>
			</light>
		</scene>
		
		<scene name="spin_night">
			<scene src="shared-global" />
			<scene src="shared-charge" />
			<sprite looping="true" loopback="700" origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="100">256 288 32 32</frame>
				<frame time="100">288 288 32 32</frame>
				<frame time="100">320 288 32 32</frame>
				<frame time="100">352 288 32 32</frame>
				<frame time="75">384 288 32 32</frame>
				<frame time="75">416 288 32 32</frame>
				<frame time="75">448 288 32 32</frame>
				<frame time="75">480 288 32 32</frame>
		
				<frame time="25">256 480 32 32</frame>
				<frame time="25">288 480 32 32</frame>
				<frame time="25">320 480 32 32</frame>
				<frame time="25">352 480 32 32</frame>
				<frame time="25">384 480 32 32</frame>
				<frame time="25">416 480 32 32</frame>
				<frame time="25">448 480 32 32</frame>
				<frame time="25">480 480 32 32</frame>
			</sprite>
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="3200" />
				<looping value="false" />
				<cast-shadows value="true" />
				<overbright value="6" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="80" />
					<size value="80" />
					<size value="80" />
					<size value="80" />
				</sizes>
				<colors>
					<color value="200 0 300 0" />
				</colors>
			</light>
		</scene>
		
		<scene name="shield">
			<scene src="shared-global" />
			<scene src="shared-shield" />
			<sprite  origin="16 24" texture="./base.png"  material="system/default.mats:actor">
				<frame time="999999">0 0 0 0</frame>
			</sprite>
		</scene>
		
		<scene name="hidden">
			<scene src="shared-global" />
			<collision static="false">
				<circle offset="0 0" sensor="true" shoot-through="true" aim-through="true" charge-through="true" radius="3" />
			</collision>
			<sprite origin="25 32" texture="./base.png" material="system/default.mats:actor">
				<frame>0 0 0 0</frame>
			</sprite>
		</scene>

		<scene name="potion" trigger-snd="event:/player/drink_potion">
			<scene src="shared-global" />
			<scene src="shared" />
			<effect src="actors/mt/bosses/agents/nightpower.effect" />
			<sprite  origin="16 24" texture="./base_skills.png"  material="system/default.mats:actor">
				<frame time="100">0 96 32 32</frame>
				<frame time="200">32 96 32 32</frame>
				<frame time="100">64 96 32 32</frame>
				<frame time="200">96 96 32 32</frame>
				<frame time="300">128 96 32 32</frame>
				<frame time="300">160 96 32 32</frame>
				<frame time="200">192 96 32 32</frame>
				<frame time="100">224 96 32 32</frame>
			</sprite>
		</scene>