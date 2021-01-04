<loader>LoadLabyrinthSet</loader>
<dict>
	<array name="reqs">
		<dict>
			<string name="name">hub</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
	
		<dict>
			<string name="name">entrance</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">exit</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">special_big</string>
			<int name="required">1</int>
			<int name="max">3</int>
		</dict>
		
		<dict>
			<string name="name">gt</string>
			<int name="required">3</int>
			<int name="max">5</int>
		</dict>
		
		<dict>
			<string name="name">chest</string>
			<int name="required">2</int>
			<int name="max">3</int>

			<array name="modifiers">
				<dict>
					<string name="flag">fountain_chests_more</string>
					<int name="required">0</int>
					<int name="max">1</int>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="name">hallway</string>
			<int name="max">3</int>
		</dict>
		
		<dict>
			<string name="name">small_cap</string>
			<int name="max">2</int>
		</dict>
		
		<dict>
			<string name="name">medium_cap</string>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">large_room</string>
			<int name="max">2</int>
		</dict>
	</array>
	
	<array name="constraints">
		<dict>
			<string name="a">entrance</string>
			<string name="b">exit</string>
			<int name="min-dist">1600</int>
		</dict>
		
		<!-- <dict> -->
			<!-- <string name="a">special_big</string> -->
			<!-- <int name="min-dist">260</int> -->
		<!-- </dict> -->
		
		<dict>
			<string name="a">chest</string>
			<int name="min-dist">260</int>
		</dict>
		
		<!-- <dict> -->
			<!-- <string name="a">gt</string> -->
			<!-- <int name="min-dist">260</int> -->
		<!-- </dict> -->
	</array>

<!-- VERTICAL NO HUB -->
%if FILE_CONFIG_1
	<string name="theme">moon_temple_poor_1</string>
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/entrance.pfb</string>
			<array name="layout">
				<a><s>x</s><s>n</s><s>n</s><s>x</s></a>
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">bottom</string>
			<int name="chance">0</int>
			<string name="reqs">entrance</string>
			<vec2 name="start-pos">512 374</vec2>
		</dict>
		
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/exit.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
				<a><s>x</s><s>s</s><s>s</s><s>x</s></a>
			</array>
			
			<string name="placement">top</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_poor/set_gt_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_hallway_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_cap_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_crn.inc"

%include "tweak/dungeons/mt_sets_poor/set_256x512_all.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x256_room_x_diag.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x512_all.inc"


<!-- VERTICAL HUB -->
%elif FILE_CONFIG_2
	<string name="theme">moon_temple_poor_2</string>
	<array name="rooms">
		
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/entrance.pfb</string>
			<array name="layout">
				<a><s>x</s><s>n</s><s>n</s><s>x</s></a>
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">bottom</string>
			<int name="chance">0</int>
			<string name="reqs">entrance</string>
			<vec2 name="start-pos">512 374</vec2>
		</dict>
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/exit.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
				<a><s>x</s><s>s</s><s>s</s><s>x</s></a>
			</array>
			
			<string name="placement">top</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/layout/hub_v_1.pfb</string>
			
			<array name="layout">
				<a><s>NWE</s></a>
				<a><s>WE</s></a>
				<a><s>WE</s></a>
				<a><s>SWE</s></a>
			</array>
			
			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">hub</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_poor/set_gt_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_hallway_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_cap_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_crn.inc"

%include "tweak/dungeons/mt_sets_poor/set_256x512_all.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x256_room_x_diag.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x512_all.inc"


<!-- HORIZONTAL WEST EAST HUB -->
%elif FILE_CONFIG_3
	<string name="theme">moon_temple_poor_3</string>
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/entrance_w.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">left</string>
			<int name="chance">0</int>
			<string name="reqs">entrance</string>
			<vec2 name="start-pos">128 696</vec2>
		</dict>
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/exit_e.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">right</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/layout/hub_h_1.pfb</string>
			
			<array name="layout">
				<a><s>NWS</s><s>NS</s><s>NS</s><s>NS</s><s>NES</s></a>
			</array>
			
			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">hub</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_poor/set_gt_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_hallway_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_cap_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_crn.inc"

%include "tweak/dungeons/mt_sets_poor/set_256x512_room_x_diag.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x256_all.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x512_all.inc"


<!-- HORIZONTAL EAST WEST HUB -->
%elif FILE_CONFIG_4
	<string name="theme">moon_temple_poor_4</string>
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/exit_w.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">left</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/entrance_e.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">right</string>
			<int name="chance">0</int>
			<string name="reqs">entrance</string>
			<vec2 name="start-pos">384 696</vec2>
		</dict>
		
		
		<dict>
			<string name="prefab">prefabs/moon_temple_poor/layout/hub_h_1.pfb</string>
			
			<array name="layout">
				<a><s>NWS</s><s>NS</s><s>NS</s><s>NS</s><s>NES</s></a>
			</array>
			
			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">hub</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_poor/set_gt_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_hallway_h.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_cap_v.inc"
%include "tweak/dungeons/mt_sets_poor/set_256x256_crn.inc"

%include "tweak/dungeons/mt_sets_poor/set_256x512_room_x_diag.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x256_all.inc"

%include "tweak/dungeons/mt_sets_poor/set_512x512_all.inc"

%endif

%include "tweak/dungeons/mt_sets_poor/set_chests_all.inc"
		
	</array>
</dict>