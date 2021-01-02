<unit layer="-20" slot="doodad">
  <scenes 
	on_empty="on_empty" 
	on_nova_1="on_nova_1" 
	on_nova_2="on_nova_2" 
	on_beamo="on_beamo"
	on_pyramid_rock="on_pyramid_rock" 	
	on_pyramid_laser="on_pyramid_laser" 	
	on_ballista_javelin="on_ballista_javelin" 	
	on_ballista_splitshot="on_ballista_splitshot" 
	on="on"
	off_nova_1="off_nova_1" 
	off_nova_2="off_nova_2" 
	off_beamo="off_beamo"
	off_pyramid_rock="off_pyramid_rock" 	
	off_pyramid_laser="off_pyramid_laser" 	
	off_ballista_javelin="off_ballista_javelin" 	
	off_ballista_splitshot="off_ballista_splitshot" 
	off="off" 
	disabled="disabled"
	>
	<scene name="shared">
		<sprite ulayer="-1" origin="16 16" texture="./tower_retractable.png" material="system/default.mats:floor">
			%if MINE_GRANITE
							<frame>96 0 32 32</frame>
			%elif PRISON
							<frame>128 0 32 32</frame>
			%elif ARMORY
							<frame>160 0 32 32</frame>
			%elif ARCHIVES
							<frame>160 32 32 32</frame>
			%elif CHAMBERS
							<frame>64 0 32 32</frame>
			%elif DESERT
							<frame>64 32 32 32</frame>
			%elif PYRAMID_SLUM
							<frame>128 32 32 32</frame>
			%elif PYRAMID_FANCY
							<frame>96 32 32 32</frame>
			%elif ARENA
							<frame>64 32 32 32</frame>
			%else
							<frame>0 0 0 0</frame>
			%endif
		</sprite>	
		<sprite ulayer="-2" looping="false" origin="16 16" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame>0 0 32 32</frame>
		</sprite>
	</scene>
	
	<scene name="shared-collision">
		<collision>
			<circle aim-through="true" shoot-through="true" radius="13"/>
		</collision>
	</scene>

<!-- ON -->
	
	<scene name="on_empty" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
	</scene>

	<scene name="on_nova_1" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_nova_1.effect" /> 
	</scene>

	<scene name="on_nova_2" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_nova_2.effect" /> 
	</scene>

	<scene name="on_beamo" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_beamo.effect" /> 
	</scene>
		
	<scene name="on_pyramid_rock" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_pyramid_rock.effect" /> 
	</scene>
	
	<scene name="on_pyramid_laser" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_pyramid_laser.effect" /> 
	</scene>
	
	<scene name="on_ballista_javelin" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_ballista_javelin.effect" /> 
	</scene>
	
	<scene name="on_ballista_splitshot" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame time="1600">0 0 0 0</frame>
			<frame>0 32 28 28</frame>
		</sprite>
 		<effect delay="600" src="doodads/generic/tower_retractable_on.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_on_ballista_splitshot.effect" /> 
	</scene>
	
	<scene name="on">
		<scene src="shared"/>
		<sprite looping="false" origin="14 12" texture="./tower_retractable.png" material="system/default.mats:floor">
			<frame>0 32 28 28</frame>
		</sprite>
	</scene>
	

<!-- /ON -->
	
<!-- OFF -->

	<scene name="off_nova_1" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_nova_1.effect" /> 
	</scene>

	<scene name="off_nova_2" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_nova_2.effect" /> 
	</scene>

	<scene name="off_beamo" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_beamo.effect" /> 
	</scene>
		
	<scene name="off_pyramid_rock" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_pyramid_rock.effect" /> 
	</scene>
	
	<scene name="off_pyramid_laser" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_pyramid_laser.effect" /> 
	</scene>
	
	<scene name="off_ballista_javelin" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_ballista_javelin.effect" /> 
	</scene>
	
	<scene name="off_ballista_splitshot" trigger-snd="event:/enemy/tower/elevate">
		<scene src="shared"/>
		<scene src="shared-collision"/>

 		<effect  src="doodads/generic/tower_retractable_off.effect" />
		<effect ulayer="1" src="doodads/generic/tower_retractable_off_ballista_splitshot.effect" /> 
	</scene>

    <scene name="off">
		<scene src="shared"/>
		<scene src="shared-collision"/>
 		<effect src="doodads/generic/tower_retractable_off.effect" />
    </scene>
	
	<scene name="disabled">
		<scene src="shared"/>
		<scene src="shared-collision"/>

    </scene>
	
<!-- /OFF -->
  </scenes>
</unit>