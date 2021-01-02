<unit slot="doodad" layer="-20">
	<behavior class="DangerAreaBehavior">
		<int name="freq">500</int>
		<int name="ttl">-1</int>
		<dict name="effect">
			<string name="class">Damage</string>
			<int name="physical">TRAP_DAMAGE</int>
		</dict>
	</behavior>
	
	%if ARMORY
	<scenes on="on" off="off" disabled="disabled" flip="flip" flip-disabled="flip_disabled">
	%else
	<scenes on="on" off="off">
	%endif
		<scene name="shared">
			<sprite origin="16 16" texture="./trap_spikes.png" material="system/default.mats:floor">
%if MINE_GRANITE
				<frame>32 96 32 32</frame>
%elif PRISON
				<frame>64 96 32 32</frame>
%elif ARMORY
				<frame>96 96 32 32</frame>
%elif ARCHIVES
				<frame>0 96 32 32</frame>
%elif CHAMBERS
				<frame>0 96 32 32</frame>
%elif DESERT
				<frame>128 96 32 32</frame>
%elif ICE
				<frame>160 96 32 32</frame>
%else
				<frame>0 96 32 32</frame>
%endif
			</sprite>		
			<sprite ulayer="1" origin="16 16" texture="./trap_spikes.png" material="system/default.mats:floor">
				<frame>0 32 32 32</frame>
			</sprite>	
		</scene>		
		
		<scene name="on" trigger-snd="event:/misc/trap_spikes">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="33 8 8 8" />
			<collision static="false" nav-block="true">
				<rect sensor="true" shoot-through="true" aim-through="true">-14 -14 28 28</rect>
			</collision>
			<sprite ulayer="2" loopback="470" origin="16 16" texture="./trap_spikes.png" material="doodads/generic/traps.mats:spikes">
				%if !ICE
				<frame time="50">0 0 32 32</frame>
				<frame time="50">32 0 32 32</frame>
				<frame time="50">64 0 32 32</frame>
				<frame time="50">96 0 32 32</frame>
				%else
				<frame time="50">160 0 32 32</frame>
				<frame time="50">192 0 32 32</frame>
				<frame time="50">224 0 32 32</frame>
				<frame time="50">224 32 32 32</frame>
				%endif
				<frame time="50">0 0 0 0</frame>
				<frame time="40">32 32 32 32</frame>	
				<frame time="40">64 32 32 32</frame>
				<frame time="40">96 32 32 32</frame>
				<frame time="100">128 32 32 32</frame>

				<frame time="250">0 64 32 32</frame>
				<frame time="25">32 64 32 32</frame>
				<frame time="25">64 64 32 32</frame>
				<frame time="25">96 64 32 32</frame>
				<frame time="250">128 64 32 32</frame>
				<frame time="25">96 64 32 32</frame>
				<frame time="25">64 64 32 32</frame>
				<frame time="25">32 64 32 32</frame>
			</sprite>
		</scene>
		<scene name="off" trigger-snd="event:/misc/trap_default-off">
			<scene src="shared" />
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite ulayer="2" looping="false" origin="16 16" texture="./trap_spikes.png" material="system/default.mats:floor">
				%if !ICE
				<frame time="50">96 0 32 32</frame>
				<frame time="50">64 0 32 32</frame>
				<frame time="50">32 0 32 32</frame>
				<frame time="50">0 0 32 32</frame>
				%else
				<frame time="50">224 32 32 32</frame>
				<frame time="50">224 0 32 32</frame>
				<frame time="50">192 0 32 32</frame>
				<frame time="50">160 0 32 32</frame>
				%endif	
			</sprite>
		</scene>
		
		<scene name="disabled" trigger-snd="event:/misc/trap_default-off">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite looping="false" origin="16 16" texture="./trap_spikes_flip.png" material="system/default.mats:floor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>		
		
		<scene name="flip" trigger-snd="event:/misc/button_hatch">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite looping="false" origin="16 16" texture="./trap_spikes_flip.png" material="system/default.mats:floor">
				<frame time="500">32 0 32 32</frame>
				<frame time="150">64 0 32 32</frame>
				<frame time="150">96 0 32 32</frame>
				<frame time="150">128 0 32 32</frame>
				<frame time="150">160 0 32 32</frame>
				<frame time="150">192 0 32 32</frame>
				<frame time="999">224 0 32 32</frame>
			</sprite>
		</scene>	
		
		<scene name="flip_disabled">
			<minimap_sprite origin="4 4" texture="gui/minimap.png" frame="41 8 8 8" />				
			<sprite looping="false" origin="16 16" texture="./trap_spikes_flip.png" material="system/default.mats:floor">
				<frame time="75">192 0 32 32</frame>
				<frame time="75">160 0 32 32</frame>
				<frame time="75">128 0 32 32</frame>
				<frame time="75">96 0 32 32</frame>
				<frame time="75">64 0 32 32</frame>
				<frame time="75">32 0 32 32</frame>
				<frame time="75">0 0 32 32</frame>
			</sprite>
		</scene>				
		
	</scenes>
</unit>
