<loader>LoadLabyrinthSet</loader>
<dict>
	<string name="theme">moon_temple_rich</string>
	
	<array name="reqs">
		<dict>
			<string name="name">portals</string>
			<int name="required">3</int>
			<int name="max">3</int>
		</dict>
	
		<dict>
			<string name="name">entrance</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">special_big</string>
			<int name="required">1</int>
			<int name="max">3</int>
		</dict>
		
		<dict>
			<string name="name">objective1</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">objective2</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">objective3</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">disconnected</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">disconnected2</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">disconnected3</string>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="name">disconnected_more</string>
			<int name="required">0</int>
			<int name="max">0</int>
			
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
	</array>
	
	<array name="constraints">
		<dict>
			<string name="a">portals</string>
			<int name="min-dist">1500</int>
		</dict>
		
		<dict>
			<string name="a">special_big</string>
			<int name="min-dist">500</int>
		</dict>
		
		<dict>
			<string name="a">objective1</string>
			<string name="b">objective2</string>
			<int name="min-dist">1000</int>
		</dict>
		
		<dict>
			<string name="a">objective1</string>
			<string name="b">objective3</string>
			<int name="min-dist">1000</int>
		</dict>
		
		<dict>
			<string name="a">objective2</string>
			<string name="b">objective3</string>
			<int name="min-dist">1000</int>
		</dict>
	</array>

%if FILE_CONFIG_1
	<string name="theme">moon_temple_rich_1</string>	<!-- HUGE CORRIDOR HUB -->
	<array name="rooms">
	
		<dict>
			<string name="prefab">prefabs/moon_temple_rich/layout/layout_1.pfb</string>
			
			<array name="layout">
				<a><s></s><s></s><s></s><s>x</s><s>nS</s><s>nS</s><s>x</s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s>wE</s><s></s><s></s><s>We</s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s>wE</s><s></s><s></s><s>We</s><s></s><s></s><s></s></a>
				<a><s>x</s><s>nS</s><s>nS</s><s>x</s><s>NS</s><s>NS</s><s>x</s><s>nS</s><s>nS</s><s>x</s></a>
				<a><s>wE</s><s></s><s></s><s>WE</s><s>NW</s><s>NE</s><s>WE</s><s></s><s></s><s>We</s></a>
				<a><s>wE</s><s></s><s></s><s>WE</s><s>SW</s><s>SE</s><s>WE</s><s></s><s></s><s>We</s></a>
				<a><s>x</s><s>Ns</s><s>Ns</s><s>x</s><s>ns</s><s>ns</s><s>x</s><s>Ns</s><s>Ns</s><s>x</s></a>
				<a><s></s><s></s><s></s><s>wE</s><s></s><s></s><s>We</s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s>wE</s><s></s><s></s><s>We</s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s>x</s><s>Ns</s><s>Ns</s><s>x</s><s></s><s></s><s></s></a>
			</array>
			
			<!-- <array name="layout"> -->
				<!-- <a><s></s><s></s><s></s><s>x</s><s>ns</s><s>ns</s><s>x</s><s></s><s></s><s></s></a> -->
				<!-- <a><s></s><s></s><s></s><s>we</s><s></s><s></s><s>we</s><s></s><s></s><s></s></a> -->
				<!-- <a><s></s><s></s><s></s><s>we</s><s></s><s></s><s>we</s><s></s><s></s><s></s></a> -->
				<!-- <a><s>x</s><s>ns</s><s>ns</s><s>x</s><s>ns</s><s>ns</s><s>x</s><s>ns</s><s>ns</s><s>x</s></a> -->
				<!-- <a><s>we</s><s></s><s></s><s>we</s><s>NW</s><s>NE</s><s>we</s><s></s><s></s><s>we</s></a> -->
				<!-- <a><s>we</s><s></s><s></s><s>we</s><s>SW</s><s>SE</s><s>we</s><s></s><s></s><s>we</s></a> -->
				<!-- <a><s>x</s><s>ns</s><s>ns</s><s>x</s><s>ns</s><s>ns</s><s>x</s><s>ns</s><s>ns</s><s>x</s></a> -->
				<!-- <a><s></s><s></s><s></s><s>we</s><s></s><s></s><s>we</s><s></s><s></s><s></s></a> -->
				<!-- <a><s></s><s></s><s></s><s>we</s><s></s><s></s><s>we</s><s></s><s></s><s></s></a> -->
				<!-- <a><s></s><s></s><s></s><s>x</s><s>ns</s><s>ns</s><s>x</s><s></s><s></s><s></s></a> -->
			<!-- </array> -->
			
			<vec2 name="start-pos">1280 1096</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_rich/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_rich/set_256x512_room_x_diag.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x256_room_x_diag.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x512_room_x_diag.inc"

	
%elif FILE_CONFIG_2
	<string name="theme">moon_temple_rich_2</string>	<!-- PORTAL ROOMS -->
	<array name="rooms">
	
		<dict>
			<string name="prefab">prefabs/moon_temple_rich/layout/layout_2.pfb</string>
			
			<array name="layout">
				<a><s>nSwE</s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s>nSWe</s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s>x</s><s>x</s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s>x</s><s>x</s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s></a>
				<a><s>NswE</s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s></s><s>NsWe</s></a>
			</array>
			
			<vec2 name="start-pos">1280 1096</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>

%include "tweak/dungeons/mt_sets_rich/set_256x256_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_256x512_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x256_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x512_room_x_diag.inc"


%elif FILE_CONFIG_3
	<string name="theme">moon_temple_rich_3</string>	<!-- RANDOM PORTALS -->
	<array name="rooms">
 		<dict>
			<string name="prefab">prefabs/moon_temple_rich/layout/layout_3.pfb</string>
			
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<vec2 name="start-pos">256 72</vec2>

			<string name="placement">middle</string>
			<int name="chance">10000</int>
			<string name="reqs">entrance</string>
		</dict>
		
		<dict>
			<string name="prefab">prefabs/moon_temple_rich/256x256/256x256_room_selector.pfb</string>
			<array name="layout">
				<a><s>nswe</s></a>
			</array>
			
			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<int name="required">1</int>
			<int name="max">1</int>
		</dict>
		
		<dict>
			<string name="prefab">prefabs/moon_temple_rich/layout/hub_portal_room_random.pfb</string>
			<array name="layout">
				<a><s>nswe</s></a>
			</array>
			
			<string name="placement">spread</string>
			<int name="chance">0</int>
			<string name="reqs">portals</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_rich/set_256x256_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_256x512_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x256_all.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x512_room_x_diag.inc"
		
	
%elif FILE_CONFIG_4
	<string name="theme">moon_temple_rich_4</string>	<!-- SMALL HUB TIGHT -->
	<array name="rooms">
	
		<dict>
			<string name="prefab">prefabs/moon_temple_rich/entrance.pfb</string>
			
			<array name="layout">
				<a><s>nw</s><s>ne</s></a>
				<a><s>sw</s><s>se</s></a>
			</array>
			
			<vec2 name="start-pos">256 72</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>
		
%include "tweak/dungeons/mt_sets_rich/set_256x256_room_x.inc"
%include "tweak/dungeons/mt_sets_rich/set_256x512_room_x_diag.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x256_room_x_diag.inc"
%include "tweak/dungeons/mt_sets_rich/set_512x512_room_x_diag.inc"

%endif

<!-- ALL -->
%include "tweak/dungeons/mt_sets_rich/set_256x256_special_big.inc"
%include "tweak/dungeons/mt_sets_rich/set_objective.inc"
%include "tweak/dungeons/mt_sets_rich/set_disconnected.inc"
		
<!-- TEST -->
<!-- %include "tweak/dungeons/mt_sets_rich/set_256x256_all.inc" -->		
<!-- %include "tweak/dungeons/mt_sets_rich/set_256x256_room_x.inc" -->

<!-- %include "tweak/dungeons/mt_sets_rich/set_256x512_all.inc" -->
<!-- %include "tweak/dungeons/mt_sets_rich/set_256x512_room_x_diag.inc" -->
<!-- %include "tweak/dungeons/mt_sets_rich/set_512x256_all.inc" -->
<!-- %include "tweak/dungeons/mt_sets_rich/set_512x256_room_x_diag.inc" -->

		
<!-- %include "tweak/dungeons/mt_sets_rich/set_512x512_room_x_diag.inc" -->

<!-- %include "tweak/dungeons/mt_sets_rich/set_objective.inc" -->
	</array>
</dict>