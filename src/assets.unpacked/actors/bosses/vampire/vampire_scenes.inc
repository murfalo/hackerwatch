		<scene name="sword">
			<scene src="shared" />
			<locator name="shoot-pos" pos="20 -17" />
			<sprite looping="false" origin="36 40" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="50">0 0 64 61</frame>
				<frame time="50">64 0 64 61</frame>
				<frame time="50">128 0 64 61</frame>
				<frame time="50">192 0 64 61</frame>
				<frame time="50">256 0 64 61</frame>
				<frame time="50">320 0 64 61</frame>
				<frame time="50">384 0 64 61</frame>
				<frame time="50">448 0 64 61</frame>
				<frame time="50">0 61 64 61</frame>
				<frame time="50">64 61 64 61</frame>
				<frame time="50">128 61 64 61</frame>
				<frame time="50">192 61 64 61</frame>
				<frame time="50">256 61 64 61</frame> <!-- swipe 1 -->
				<frame time="50">320 61 64 61</frame>
				<frame time="50">384 61 64 61</frame>
				<frame time="50">448 61 64 61</frame>
				<frame time="50">0 122 64 61</frame> <!-- swipe 2 -->
				<frame time="50">64 122 64 61</frame>
				<frame time="50">128 122 64 61</frame>
				<frame time="50">192 122 64 61</frame>
				<frame time="50">256 122 64 61</frame> <!-- swipe 3 -->
				<frame time="50">320 122 64 61</frame>
				<frame time="50">384 122 64 61</frame>
				<frame time="50">448 122 64 61</frame>
				<frame time="50">0 183 64 61</frame>
				<frame time="50">64 183 64 61</frame>
				<frame time="50">128 183 64 61</frame>
				<frame time="50">192 183 64 61</frame>
			</sprite>
		</scene>
		
		<scene name="feeding">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 0" />
			<sprite looping="false" ulayer="1" pos="0 -15" origin="18 19" texture="actors/bosses/vampire/vampire_leach.png" material="system/default.mats:glow-both-bright">
				<frame time="100">0 0 37 38</frame>
				<frame time="100">37 0 37 38</frame>
				<frame time="100">74 0 37 38</frame>
				<frame time="100">111 0 37 38</frame>
				<frame time="100">148 0 37 38</frame>
				<frame time="100">185 0 37 38</frame>
				<frame time="100">0 0 37 38</frame>
				<frame time="100">37 0 37 38</frame>
				<frame time="100">74 0 37 38</frame>
				<frame time="100">111 0 37 38</frame>
				<frame time="100">148 0 37 38</frame>
				<frame time="100">185 0 37 38</frame>
				<frame time="100">0 0 37 38</frame>
				<frame time="100">37 0 37 38</frame>
				<frame time="100">74 0 37 38</frame>
				<frame time="100">111 0 37 38</frame>
				<frame time="100">148 0 37 38</frame>
				<frame time="100">185 0 37 38</frame>
				<frame time="100">0 0 37 38</frame>
				<frame time="100">37 0 37 38</frame>
				<frame time="100">74 0 37 38</frame>
				<frame time="100">111 0 37 38</frame>
				<frame time="100">148 0 37 38</frame>
				<frame time="100">185 0 37 38</frame>
				
				<frame time="100">0 38 37 38</frame>
				<frame time="100">37 38 37 38</frame>
				<frame time="600">74 38 37 38</frame>
				<frame time="100">111 38 37 38</frame>
				<frame time="100">148 38 37 38</frame>
				<frame time="100">185 38 37 38</frame>
				
				<frame time="100">0 76 37 38</frame>
				<frame time="100">37 76 37 38</frame>
				<frame time="100">74 76 37 38</frame>
				<frame time="100">111 76 37 38</frame>
				
				<frame time="100">0 0 0 0</frame>
			</sprite>
			<sprite looping="false" origin="32 38" texture="actors/bosses/vampire/vampire_attack.png" material="system/default.mats:actor">
				<frame time="100">0 0 64 64</frame>
				<frame time="100">64 0 64 64</frame>
				<frame time="100">128 0 64 64</frame>
				<frame time="100">192 0 64 64</frame>
				<frame time="2800">0 64 64 64</frame>
				
				<frame time="100">64 64 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">0 128 64 64</frame>
				<frame time="100">64 128 64 64</frame>
				<frame time="100">128 128 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				<frame time="100">128 64 64 64</frame>
				<frame time="100">192 64 64 64</frame>
				
				<!-- <frame time="100">0 128 64 64</frame> -->
				<!-- <frame time="100">64 128 64 64</frame> -->
				<!-- <frame time="100">128 128 64 64</frame> -->
				<!-- <frame time="100">128 64 64 64</frame> -->
				<!-- <frame time="100">192 64 64 64</frame> -->
			</sprite>
		</scene>
		
		<scene name="attack-hand-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="10 0"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">0 0 64 64</frame>
				<frame time="700">0 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-7">
			<scene src="shared" />
			<locator name="shoot-pos" pos="13 -13"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">64 0 64 64</frame>
				<frame time="700">64 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-6">
			<scene src="shared" />
			<locator name="shoot-pos" pos="8 -25"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">128 0 64 64</frame>
				<frame time="700">128 64 64 64</frame>		
			</sprite>
		</scene>
		<scene name="attack-hand-5">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-4 -25"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">192 0 64 64</frame>
				<frame time="700">192 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-4">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-18 -18"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">256 0 64 64</frame>
				<frame time="700">256 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-3">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-17 -5"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">320 0 64 64</frame>
				<frame time="700">320 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-2">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-8 17"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">384 0 64 64</frame>
				<frame time="700">384 64 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-hand-1">
			<scene src="shared" />
			<locator name="shoot-pos" pos="11 11"/>
			<sprite origin="32 38" looping="false" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="800">448 0 64 64</frame>
				<frame time="700">448 64 64 64</frame>	
			</sprite>
		</scene>
		
		<scene name="attack-sword-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="18 -5"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">0 256 68 65</frame>
				<frame time="300">68 256 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-7">
			<scene src="shared" />
			<locator name="shoot-pos" pos="14 -21"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">136 256 68 65</frame>
				<frame time="300">204 256 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-6">
			<scene src="shared" />
			<locator name="shoot-pos" pos="8 -25"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">272 256 68 65</frame>
				<frame time="300">340 256 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-5">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-11 -25"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">408 256 68 65</frame>
				<frame time="300">0 321 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-4">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-18 -16"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">68 321 68 65</frame>
				<frame time="300">136 321 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-3">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-17 -9"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">204 321 68 65</frame>
				<frame time="300">272 321 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-2">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-8 12"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">340 321 68 65</frame>
				<frame time="300">408 321 68 65</frame>
			</sprite>
		</scene>
		<scene name="attack-sword-1">
			<scene src="shared" />
			<locator name="shoot-pos" pos="15 8"/>
			<sprite origin="34 49" looping="false" texture="actors/bosses/vampire/vampire_sword.png" material="system/default.mats:actor">
				<frame time="800">0 386 68 65</frame>
				<frame time="300">68 386 68 65</frame>
			</sprite>
		</scene>
		
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">0 0 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">64 0 64 64</frame>
			</sprite>
		</scene>
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">128 0 64 64</frame>		
			</sprite>
			
		</scene>
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">192 0 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">256 0 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">320 0 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">384 0 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire.png" material="system/default.mats:actor">
				<frame time="150">448 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="bat-0">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">0 0 44 44</frame>
				<frame time="70">0 44 44 44</frame>
				<frame time="70">0 88 44 44</frame>
				<frame time="70">0 132 44 44</frame>
				<frame time="70">0 176 44 44</frame>
				<frame time="70">0 220 44 44</frame>
				<frame time="70">0 264 44 44</frame>
				<frame time="70">0 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-7">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">44 0 44 44</frame>
				<frame time="70">44 44 44 44</frame>
				<frame time="70">44 88 44 44</frame>
				<frame time="70">44 132 44 44</frame>
				<frame time="70">44 176 44 44</frame>
				<frame time="70">44 220 44 44</frame>
				<frame time="70">44 264 44 44</frame>
				<frame time="70">44 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-6">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">88 0 44 44</frame>
				<frame time="70">88 44 44 44</frame>
				<frame time="70">88 88 44 44</frame>
				<frame time="70">88 132 44 44</frame>
				<frame time="70">88 176 44 44</frame>
				<frame time="70">88 220 44 44</frame>
				<frame time="70">88 264 44 44</frame>
				<frame time="70">88 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-5">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">132 0 44 44</frame>
				<frame time="70">132 44 44 44</frame>
				<frame time="70">132 88 44 44</frame>
				<frame time="70">132 132 44 44</frame>
				<frame time="70">132 176 44 44</frame>
				<frame time="70">132 220 44 44</frame>
				<frame time="70">132 264 44 44</frame>
				<frame time="70">132 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-4">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">176 0 44 44</frame>
				<frame time="70">176 44 44 44</frame>
				<frame time="70">176 88 44 44</frame>
				<frame time="70">176 132 44 44</frame>
				<frame time="70">176 176 44 44</frame>
				<frame time="70">176 220 44 44</frame>
				<frame time="70">176 264 44 44</frame>
				<frame time="70">176 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-3">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">220 0 44 44</frame>
				<frame time="70">220 44 44 44</frame>
				<frame time="70">220 88 44 44</frame>
				<frame time="70">220 132 44 44</frame>
				<frame time="70">220 176 44 44</frame>
				<frame time="70">220 220 44 44</frame>
				<frame time="70">220 264 44 44</frame>
				<frame time="70">220 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-2">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">264 0 44 44</frame>
				<frame time="70">264 44 44 44</frame>
				<frame time="70">264 88 44 44</frame>
				<frame time="70">264 132 44 44</frame>
				<frame time="70">264 176 44 44</frame>
				<frame time="70">264 220 44 44</frame>
				<frame time="70">264 264 44 44</frame>
				<frame time="70">264 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="bat-1">
			<scene src="shared-bat" />
			<sprite origin="22 37" texture="actors/bosses/vampire/vampire_bat.png" material="system/default.mats:actor">
				<frame time="70">308 0 44 44</frame>
				<frame time="70">308 44 44 44</frame>
				<frame time="70">308 88 44 44</frame>
				<frame time="70">308 132 44 44</frame>
				<frame time="70">308 176 44 44</frame>
				<frame time="70">308 220 44 44</frame>
				<frame time="70">308 264 44 44</frame>
				<frame time="70">308 308 44 44</frame>
			</sprite>
		</scene>
		
		<scene name="spawn">
			<scene src="shared" />
			<sprite looping="false" origin="32 38" texture="actors/bosses/vampire/vampire_attack.png" material="system/default.mats:actor">
				<frame time="600">0 64 64 64</frame>
				<frame time="100">192 0 64 64</frame>
				<frame time="100">128 0 64 64</frame>
				<frame time="100">64 0 64 64</frame>
				<frame time="100">0 0 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="escape">
			<scene src="shared" />
			<!-- <effect src="actors/bosses/vampire/poof.effect" /> -->
			<sprite looping="false" origin="32 38" texture="actors/bosses/vampire/vampire_attack.png" material="system/default.mats:actor">
				<frame time="50">0 0 64 64</frame>
				<frame time="50">64 0 64 64</frame>
				<frame time="50">128 0 64 64</frame>
				<frame time="50">192 0 64 64</frame>
				<frame time="500">0 64 64 64</frame>
			</sprite>
		</scene>

		<scene name="portrait">
			<sprite origin="32 38" texture="actors/bosses/vampire/vampire_attack.png" material="system/default.mats:actor">
				<frame time="600">0 64 64 64</frame>
			</sprite>
		</scene>