<unit slot="doodad">
	<behavior class="Breakable">
		<string name="hit-sound">event:/misc/wall_hit</string>	
 		<string name="break-sound">event:/misc/wall_break</string> 
		
		<bool name="scene-switching">true</bool>
		<bool name="scene-switching-passthrough">false</bool>
		
%if MINE_GRANITE
		<string name="corpse">doodads/walls/mine_granite/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_mines.sval</string>
%elif PRISON
		<string name="corpse">doodads/walls/prison/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_prison.sval</string>
%elif ARMORY
		<string name="corpse">doodads/walls/armory/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_armory.sval</string>
%elif ARCHIVES
		<string name="corpse">doodads/walls/archives/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%elif CHAMBERS
		<string name="corpse">doodads/walls/chambers/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_chambers.sval</string>
%elif P_FANCY
		<string name="corpse">doodads/walls/pyramid_fancy/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%elif P_SLUM
		<string name="corpse">doodads/walls/pyramid_slum/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%elif T_POOR
		<string name="corpse">doodads/walls/temple_poor/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%elif T_COMMON
		<string name="corpse">doodads/walls/temple_common/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%elif T_RICH
		<string name="corpse">doodads/walls/temple_rich/h_secret_dst_corpse.unit</string>
		<string name="gore">effects/gibs/doodads/gib_wall_secret_archives.sval</string>
%endif
		<bool name="impenetrable">true</bool>
	</behavior>
	
	<scenes default="default-1">
		<scene name="shared">
			<minimap_sprite origin="0 0" texture="gui/minimap.png" frame="0 0 4 4" />			
			<collision static="true">
				<rect>0 0 16 16</rect>
			</collision>
			<shadow darkness="1">
				<rect>0 0 16 16</rect>
			</shadow>		
		</scene>
		<scene name="default-1">
			<scene src="shared" />
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>0 176 16 48</frame>
			</sprite>
		</scene>
		<scene name="default-2">
			<scene src="shared" />
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>16 176 16 48</frame>
			</sprite>
		</scene>
		<scene name="default-3">
			<scene src="shared" />
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>32 176 16 48</frame>
			</sprite>
		</scene>		
		<scene name="default-4">
			<scene src="shared" />
			<sprite origin="0 32" texture="./base.png" material="system/default.mats:proj-wall">
				<frame>48 176 16 48</frame>
			</sprite>
		</scene>				
	</scenes>
</unit>
