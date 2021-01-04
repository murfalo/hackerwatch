<unit slot="doodad">
	<scenes close="close" open="open">
		<scene name="shared">
			<sprite origin="32 26" texture="./door_shortcut.png" material="system/default.mats:proj-wall">
				%if MINE_GRANITE
				<frame time="50">64 0 3 42</frame>
				%elif PRISON
				<frame time="50">64 42 3 42</frame>
				%elif ARMORY
				<frame time="50">64 42 3 42</frame>
				%endif	
			</sprite>
			<sprite origin="-29 26" texture="./door_shortcut.png" material="system/default.mats:proj-wall">
				%if MINE_GRANITE
				<frame time="50">64 0 3 42</frame>
				%elif PRISON
				<frame time="50">64 42 3 42</frame>
				%elif ARMORY
				<frame time="50">64 42 3 42</frame>
				%endif				
			</sprite>
			<sprite layer="-30" origin="32 4" texture="./door_shortcut.png" material="system/default.mats:floor">
				%if MINE_GRANITE
				<frame time="50">0 0 64 24</frame>
				%elif PRISON
				<frame time="50">0 24 64 24</frame>
				%elif ARMORY
				<frame time="50">0 24 64 24</frame>
				%endif
			</sprite>
		</scene>

		<scene name="close" trigger-snd="event:/misc/wall_move">
			<scene src="shared" />
			<collision static="true">
				<rect>-32 0 64 16</rect>
			</collision>
			<sprite origin="29 24" looping="false" texture="./door_shortcut.png" material="system/default.mats:proj-wall">
				<frame time="30">67 0 58 40</frame>
				<frame time="30">67 40 58 40</frame>
				<frame time="30">67 80 58 40</frame>
				<frame time="30">125 0 58 40</frame>
				<frame time="30">125 40 58 40</frame>
				<frame time="30">125 80 58 40</frame>
				<frame time="30">183 0 58 40</frame>
				<frame time="30">183 40 58 40</frame>
			</sprite>
		</scene>
		
		<scene name="open" trigger-snd="event:/misc/wall_move">
			<scene src="shared" />
			<sprite origin="29 24" looping="false" texture="./door_shortcut.png" material="system/default.mats:proj-wall">
				<frame time="30">183 40 58 40</frame>
				<frame time="30">183 0 58 40</frame>
				<frame time="30">125 80 58 40</frame>
				<frame time="30">125 40 58 40</frame>
				<frame time="30">125 0 58 40</frame>
				<frame time="30">67 80 58 40</frame>
				<frame time="30">67 40 58 40</frame>
				<frame time="30<">67 0 58 40</frame>
			</sprite>
		</scene>		
	</scenes>
</unit>