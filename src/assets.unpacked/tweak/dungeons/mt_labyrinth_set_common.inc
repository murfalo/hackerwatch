<loader>LoadLabyrinthSet</loader>
<dict>
	<string name="theme">moon_temple_common</string>
	
	<array name="reqs">
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
			<string name="name">gt</string>
			<int name="required">3</int>
			<int name="max">5</int>
		</dict>
		
		<dict>
			<string name="name">chest</string>
			<int name="required">3</int>
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
			<string name="name">special_big</string>
			<int name="max">1</int>
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
			<string name="name">large_cap</string>
			<int name="max">1</int>
		</dict>
	</array>
	
	<array name="constraints">
		<dict>
			<string name="a">entrance</string>
			<string name="b">exit</string>
			<int name="min-dist">2000</int>
		</dict>
		
		<dict>
			<string name="a">chest</string>
			<int name="min-dist">520</int>
		</dict>
		
		<!-- <dict> -->
			<!-- <string name="a">gt</string> -->
			<!-- <int name="min-dist">700</int> -->
		<!-- </dict> -->
	</array>
	
%if FILE_CONFIG_1	
	<string name="theme">moon_temple_common_1</string>	<!-- layout 1 hub 1 -->
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_common/layout/layout_1.pfb</string>
			
			<array name="layout">
				<a><s>x</s><s>N</s><s>x</s></a>
				<a><s>W</s><s>x</s><s>E</s></a>
				<a><s>x</s><s>S</s><s>x</s></a>
				<a><s></s><s>NS</s><s></s></a>
				<a><s></s><s>NSew</s><s></s></a>
				<a><s></s><s>NS</s><s></s></a>
				<a><s></s><s>N</s><s></s></a>
				<a><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<vec2 name="start-pos">384 1896</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>

		
%elif FILE_CONFIG_2		
	<string name="theme">moon_temple_common_2</string>	<!-- layout 2 hub 1 -->
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_common/layout/layout_2.pfb</string>
			
			<!-- <array name="layout"> -->
				<!-- <a><s>nw</s><s>Ns</s><s>Ns</s><s>ne</s></a> -->
				<!-- <a><s>WE</s><s></s><s></s><s>WE</s></a> -->
				<!-- <a><s>WE</s><s></s><s></s><s>WE</s></a> -->
				<!-- <a><s>sw</s><s>nS</s><s>nS</s><s>se</s></a> -->
				<!-- <a><s></s><s>N</s><s>N</s><s></s></a> -->
				<!-- <a><s>x</s><s>x</s><s>x</s><s>x</s></a> -->
			<!-- </array> -->
			
			<array name="layout">
				<a><s>x</s><s>Ns</s><s>Ns</s><s>x</s></a>
				<a><s>W</s><s></s><s></s><s>E</s></a>
				<a><s>W</s><s></s><s></s><s>E</s></a>
				<a><s>x</s><s>nS</s><s>nS</s><s>x</s></a>
				<a><s></s><s>N</s><s>N</s><s></s></a>
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<vec2 name="start-pos">512 1380</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>

			
%elif FILE_CONFIG_3
	<string name="theme">moon_temple_common_3</string>	<!-- layout 3 hub 1 -->
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_common/layout/layout_3.pfb</string>
			
			<array name="layout">
				<a><s>NW</s><s>NS</s><s>NS</s><s>NE</s></a>
				<a><s>WE</s><s>x</s><s>x</s><s>E</s></a>
				<a><s>WE</s><s>x</s><s>x</s><s>E</s></a>
				<a><s>SW</s><s>S</s><s>S</s><s>SE</s></a>
				<a><s></s><s>N</s><s>N</s><s></s></a>
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<vec2 name="start-pos">512 1380</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>

		
%elif FILE_CONFIG_4
	<string name="theme">moon_temple_common_4</string>	<!-- layout 4 hub 1 -->
	<array name="rooms">
		<dict>
			<string name="prefab">prefabs/moon_temple_common/layout/layout_4.pfb</string>
			
			<array name="layout">
				<a><s>W</s><s>x</s><s>E</s></a>
				<a><s>W</s><s>x</s><s>E</s></a>
				<a><s>W</s><s>S</s><s>E</s></a>
				<a><s></s><s>NS</s><s></s></a>
				<a><s></s><s>NSew</s><s></s></a>
				<a><s></s><s>NS</s><s></s></a>
				<a><s></s><s>N</s><s></s></a>
				<a><s>x</s><s>x</s><s>x</s></a>
			</array>
			
			<vec2 name="start-pos">384 1896</vec2>

			<string name="placement">middle</string>
			<int name="chance">1000000</int>
			<string name="reqs">entrance</string>
		</dict>
		
%endif
		<!-- EXIT -->
		<dict>
			<string name="prefab">prefabs/moon_temple_common/exit.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s><s>x</s><s>x</s></a>
				<a><s>x</s><s>s</s><s>s</s><s>x</s></a>
			</array>
			
			<string name="placement">top</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		<dict>
			<string name="prefab">prefabs/moon_temple_common/exit_e.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>w</s><s>x</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">top</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		<dict>
			<string name="prefab">prefabs/moon_temple_common/exit_w.pfb</string>
			<array name="layout">
				<a><s>x</s><s>x</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>e</s></a>
				<a><s>x</s><s>x</s></a>
			</array>
			
			<string name="placement">top</string>
			<int name="chance">0</int>
			<string name="reqs">exit</string>
		</dict>
		


%include "tweak/dungeons/mt_sets_common/set_gt_all.inc"

%include "tweak/dungeons/mt_sets_common/set_256x256_all.inc"
%include "tweak/dungeons/mt_sets_common/set_256x512_all.inc"
%include "tweak/dungeons/mt_sets_common/set_512x256_all.inc"
%include "tweak/dungeons/mt_sets_common/set_512x512_all.inc"

%include "tweak/dungeons/mt_sets_common/set_chests_all.inc"
	</array>
</dict>