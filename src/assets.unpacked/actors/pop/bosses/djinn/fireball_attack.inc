		
		<scene name="shared-fireball">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" radius="12" aim-through="true" charge-through="true" density="999"/>
				<circle offset="0 -10" radius="12" sensor="true" shoot-through="false" aim-through="true" charge-through="false"/>
				<circle offset="0 -20" radius="12" sensor="true" shoot-through="false" aim-through="true" charge-through="false"/>
			</collision>
		 
			<sprite origin="18 27" ulayer="2" looping="true" texture="./djinn_fire_smoke.png" material="effects/effects.mats:fire">
				<frame time="120">0 0 37 37</frame>
				<frame time="120">37 0 37 37</frame>
				<frame time="120">74 0 37 37</frame>
				<frame time="120">0 37 37 37</frame>
				<frame time="120">37 37 37 37</frame>
			</sprite>
			
			
			<effect delay="150" src="actors/pop/bosses/djinn/sword.effect" />
			
			
			<light pos="0 0">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="7" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="128" />
				</sizes>
				<colors>
					<color value="225 50 0 0" />
				</colors>
			</light>  
			
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="3" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="300" />
				</sizes>
				<colors>
					<color value="225 0 0 0" />
				</colors>
			</light>			
		  
		</scene>
		
		<scene name="fireball-0">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="32 -18" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">0 32 64 32</frame>
				<frame time="50">0 64 64 32</frame>
				<frame time="75">0 96 64 32</frame>
				<frame time="50">0 160 64 32</frame>
				<frame time="50">0 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">0 80 64 80</frame>
				<frame time="50">0 160 64 80</frame>
				<frame time="75">0 240 64 80</frame>
				<frame time="50">0 400 64 80</frame>
				<frame time="50">0 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-1">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="14 -7" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">64 32 64 32</frame>
				<frame time="50">64 64 64 32</frame>
				<frame time="75">64 96 64 32</frame>
				<frame time="50">64 160 64 32</frame>
				<frame time="50">64 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">64 80 64 80</frame>
				<frame time="50">64 160 64 80</frame>
				<frame time="75">64 240 64 80</frame>
				<frame time="50">64 400 64 80</frame>
				<frame time="50">64 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-2">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="0 8" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">128 32 64 32</frame>
				<frame time="50">128 64 64 32</frame>
				<frame time="75">128 96 64 32</frame>
				<frame time="50">128 160 64 32</frame>
				<frame time="50">128 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">128 80 64 80</frame>
				<frame time="50">128 160 64 80</frame>
				<frame time="75">128 240 64 80</frame>
				<frame time="50">128 400 64 80</frame>
				<frame time="50">128 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-3">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="-14 -7" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">192 32 64 32</frame>
				<frame time="50">192 64 64 32</frame>
				<frame time="75">192 96 64 32</frame>
				<frame time="50">192 160 64 32</frame>
				<frame time="50">192 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">192 80 64 80</frame>
				<frame time="50">192 160 64 80</frame>
				<frame time="75">192 240 64 80</frame>
				<frame time="50">192 400 64 80</frame>
				<frame time="50">192 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-4">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="-32 -18" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">256 32 64 32</frame>
				<frame time="50">256 64 64 32</frame>
				<frame time="75">256 96 64 32</frame>
				<frame time="50">256 160 64 32</frame>
				<frame time="50">256 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">256 80 64 80</frame>
				<frame time="50">256 160 64 80</frame>
				<frame time="75">256 240 64 80</frame>
				<frame time="50">256 400 64 80</frame>
				<frame time="50">256 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-5">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="-18 -42" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">320 32 64 32</frame>
				<frame time="50">320 64 64 32</frame>
				<frame time="75">320 96 64 32</frame>
				<frame time="50">320 160 64 32</frame>
				<frame time="50">320 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">320 80 64 80</frame>
				<frame time="50">320 160 64 80</frame>
				<frame time="75">320 240 64 80</frame>
				<frame time="50">320 400 64 80</frame>
				<frame time="50">320 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-6">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="0 -56" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">384 32 64 32</frame>
				<frame time="50">384 64 64 32</frame>
				<frame time="75">384 96 64 32</frame>
				<frame time="50">384 160 64 32</frame>
				<frame time="50">384 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">384 80 64 80</frame>
				<frame time="50">384 160 64 80</frame>
				<frame time="75">384 240 64 80</frame>
				<frame time="50">384 400 64 80</frame>
				<frame time="50">384 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="fireball-7">
			<scene src="shared-fireball" />
			<locator name="shoot-pos" pos="18 -42" />
			<sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				<frame time="50">448 32 64 32</frame>
				<frame time="50">448 64 64 32</frame>
				<frame time="75">448 96 64 32</frame>
				<frame time="50">448 160 64 32</frame>
				<frame time="50">448 192 64 32</frame>
			</sprite>
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				<frame time="50">448 80 64 80</frame>
				<frame time="50">448 160 64 80</frame>
				<frame time="75">448 240 64 80</frame>
				<frame time="50">448 400 64 80</frame>
				<frame time="50">448 480 64 80</frame>
			</sprite>
		</scene>