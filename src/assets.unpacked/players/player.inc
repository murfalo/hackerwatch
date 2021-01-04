<unit slot="actor" netsync="manual">
%if PLAYER_HUSK
	<behavior class="PlayerHusk">
%else
	<behavior class="Player">
%endif
		<string name="anim-idle">idle 8</string>
		<string name="anim-walk">walk 8</string>
		<string name="anim-dash">dash 8</string>
		<dict name="footsteps">
			<int name="delay">100</int>
			<int name="feet-distance">4</int>
		</dict>
		<dict name="footsteps-dash">
			<int name="delay">30</int>
			<int name="feet-distance">0</int>
		</dict>
		<float name="wind-scale">1.0</float>
		
		<array name="buffs-immune-tags">
	 		<string>notplayer</string>
		</array>		
		
	</behavior>
	
	<scenes start="shared">
		<scene name="light">
			<minimap_sprite layer="100" origin="4 4" texture="gui/minimap.png" frame="99 0 8 8"/>
		
			<effect ulayer="-100" src="players/player_regen.effect" />
			<sprite origin="6 5" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow-player">
				<frame>16 12 11 11</frame>
			</sprite>
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="2000" />
				<looping value="true" />
				<cast-shadows value="true" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="175" />
				</sizes>
				<colors>
					<color value="100 100 100 0" />
				</colors>
			</light>
		</scene>
	
		<scene name="shared-charge">
			<collision bullet="true" static="false">
				<circle charging="true" offset="0 0" radius="3.5" density="3" non-player="false" />
			</collision>
			<scene src="light" />
		</scene>
		
		<scene name="shared">
			<collision bullet="true" static="false">
				<circle offset="0 0" radius="3.5" density="10" charge-through="true" aim-through="true" non-player="false" />
			</collision>
			<scene src="light" />
		</scene>
	</scenes>
</unit>
