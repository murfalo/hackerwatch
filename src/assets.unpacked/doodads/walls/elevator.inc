<unit slot="doodad">
	<scenes off="off" on="on" disabled="disabled">
		<scene name="shared">
			<collision static="true">
				<rect>-32 0 64 16</rect>
			</collision>
			<sprite ulayer="0" origin="32 56" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- base -->
				<frame>0 8 64 72</frame>
			</sprite>
			%if MINES || PRISON
				<sprite ulayer="2" origin="16 0" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- fence -->
					<frame>0 80 32 16</frame>
				</sprite>
				%if MINES
					<sprite ulayer="3" origin="22 -14" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>32 80 10 6</frame>
					</sprite>
					<sprite ulayer="3" origin="-18 -14" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>32 86 12 9</frame>
					</sprite>
				%endif
				%if PRISON
					<sprite ulayer="3" origin="29 -8" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>32 80 18 15</frame>
					</sprite>
					<sprite ulayer="4" origin="15 -14" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>50 80 9 8</frame>
					</sprite>
					<sprite ulayer="3" origin="-18 -14" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>50 88 10 6</frame>
					</sprite>
				%endif
			%endif
			%if ARMORY || ARCHIVES || CHAMBERS
				<sprite ulayer="2" origin="16 17" texture="./elevator.png" material="system/default.mats:floor"> 
					<frame>83 41 32 30</frame>
				</sprite>
				%if ARMORY
					<sprite ulayer="3" origin="-2 13" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>64 41 19 32</frame>
					</sprite>
				%endif
				%if ARCHIVES
					<sprite ulayer="3" origin="-2 13" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>64 41 19 32</frame>
					</sprite>
				%endif
				%if CHAMBERS
					<sprite ulayer="3" origin="-2 13" texture="./elevator.png" material="system/default.mats:floor"> <!-- deco -->
						<frame>64 41 19 32</frame>
					</sprite>
				%endif
			%endif
		</scene>
		<scene name="off">
			<scene src="shared"/>
			<minimap_sprite origin="8 6" layer="500" texture="gui/minimap.png" frame="88 20 16 10"/>
			%if MINES || PRISON
				<sprite ulayer="1" origin="9 28" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- empty cart -->
					<frame time="100">81 51 17 44</frame>
				</sprite>
			%endif
			%if ARMORY || ARCHIVES || CHAMBERS
				<sprite ulayer="1" origin="10 21" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- empty cart -->
					<frame time="100">110 13 18 28</frame>
				</sprite>
				<sprite  ulayer="4"  origin="16 36" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- cart rope -->
					<frame time="100">0 80 8 27</frame>
				</sprite>
			%endif
		</scene>
		<scene name="on" trigger-snd="event:/misc/elevator">
			<scene src="shared"/>
			<minimap_sprite origin="8 6" layer="500" texture="gui/minimap.png" frame="88 30 16 10"/>
			%if MINES || PRISON
				<sprite loopback="2500" ulayer="1" origin="9 28" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="300">64 51 17 44</frame>
					<frame time="200">64 52 17 44</frame>
					<frame time="2000">0 0 0 0</frame>
					%if MINES
						<frame time="50">64 0 17 44</frame>
						<frame time="50">64 1 17 44</frame>
					%endif
					%if PRISON
						<frame time="50">64 0 17 39</frame>
						<frame time="50">64 1 17 39</frame>
					%endif
				</sprite>
				<sprite loopback="500" ulayer="1" origin="3 37" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="300">0 96 19 20</frame>
					<frame time="200">95 96 19 20</frame>
					<frame time="50">0 96 19 20</frame>
					<frame time="50">19 96 19 20</frame>
					<frame time="50">38 96 19 20</frame>
					<frame time="50">57 96 19 20</frame>
					<frame time="50">76 96 19 20</frame>
					<frame time="50">95 96 19 20</frame>
				</sprite>
				%if MINES
					<effect delay="500" ulayer="1" src="doodads/walls/mine_granite/elevator.effect"/> 
				%endif
				%if PRISON
					<effect delay="500" ulayer="1" src="doodads/walls/prison/elevator.effect"/> 
				%endif
			%endif
			%if ARMORY || ARCHIVES || CHAMBERS
				<sprite ulayer="4" loopback="300" origin="16 36" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- cart rope -->
					<frame time="300">0 80 8 27</frame>
					<frame time="100">0 80 8 27</frame>
					<frame time="100">8 80 8 27</frame>
					<frame time="100">16 80 8 27</frame>
					<frame time="100">24 80 8 27</frame>
					<frame time="100">32 80 8 27</frame>
					<frame time="100">40 80 8 27</frame>
				</sprite>
				<sprite looping="false" ulayer="1" origin="11 21" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="300">86 12 19 29</frame>
					<!-- <frame time="200">85 11 20 30</frame>  jerk frame not being used atm (looked weird) -->
					<frame time="200">0 0 0 0</frame>
				</sprite>
				<effect delay="300" ulayer="1" src="doodads/walls/armory/elevator.effect"/> 
				<sprite looping="true" loopback="2300" ulayer="1" origin="10 13" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="300"> 0 107 2 14 </frame>
					<frame time="2000">0 0 0 0</frame>
					<frame time="100"> 0 107 24 14 </frame>
					<frame time="100"> 27 107 24 14 </frame>
				</sprite>
			%endif
		</scene>
		
		<scene name="disabled">
			<scene src="shared"/>
			<minimap_sprite origin="8 6" layer="500" texture="gui/minimap.png" frame="88 30 16 10"/>
			%if MINES || PRISON
				<sprite ulayer="1" origin="9 28" texture="./elevator.png" material="system/default.mats:proj-wall">
					%if MINES
						<frame time="50">64 0 17 44</frame>
					%endif
					%if PRISON
						<frame time="50">64 0 17 39</frame>
					%endif
				</sprite>
				<sprite ulayer="1" origin="3 37" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="50">0 96 19 20</frame>
				</sprite>
			%endif
			%if ARMORY || ARCHIVES || CHAMBERS
				<sprite ulayer="4" origin="16 36" texture="./elevator.png" material="system/default.mats:proj-wall"> <!-- cart rope -->
					<frame time="300">0 80 8 27</frame>
				</sprite>
				<sprite looping="false" ulayer="1" origin="11 21" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="200">0 0 0 0</frame>
				</sprite>
				<sprite looping="false" ulayer="1" origin="10 13" texture="./elevator.png" material="system/default.mats:proj-wall">
					<frame time="100"> 27 107 24 14 </frame>
				</sprite>
			%endif
		</scene>
	</scenes>
</unit>