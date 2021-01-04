
		<scene name="firearc-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="32 -18" />
			<effect delay="500" pos="10 0" src="actors/pop/bosses/djinn/sword_e.effect" />
			 
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="4" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">0 134 63 67</frame>
				<frame time="50">0 201 63 67</frame>
				<frame time="50">0 268 63 67</frame>
				<frame time="75">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="2" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">0 0 100 100</frame>
				<frame time="100">0 100 100 100</frame>
				<frame time="75">0 200 100 100</frame>
				<frame time="175">0 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">0 96 64 32</frame>
				<frame time="200">0 128 64 32</frame>
				<frame time="175">0 160 64 32</frame>
				<frame time="175">0 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">0 240 64 80</frame>
				<frame time="200">0 320 64 80</frame>
				<frame time="100">0 640 64 80</frame>
				<frame time="75">0 400 64 80</frame>
				<frame time="175">0 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-1">
			<locator name="shoot-pos" pos="14 -7" />
			<scene src="shared" />

			<effect delay="500" pos="10 10" src="actors/pop/bosses/djinn/sword_se.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">63 134 63 67</frame>
				<frame time="50">63 201 63 67</frame>
				<frame time="50">63 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">100 0 100 100</frame>
				<frame time="100">100 100 100 100</frame>
				<frame time="75">100 200 100 100</frame>
				<frame time="175">100 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">64 96 64 32</frame>
				<frame time="200">64 128 64 32</frame>
				<frame time="175">64 160 64 32</frame>
				<frame time="175">64 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">64 240 64 80</frame>
				<frame time="200">64 320 64 80</frame>
				<frame time="100">64 640 64 80</frame>
				<frame time="75">64 400 64 80</frame>
				<frame time="175">64 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-2">
			<locator name="shoot-pos" pos="0 8" />
			<scene src="shared" />

			<effect delay="500" pos="0 15" src="actors/pop/bosses/djinn/sword_s.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">126 134 63 67</frame>
				<frame time="50">126 201 63 67</frame>
				<frame time="50">126 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">200 0 100 100</frame>
				<frame time="100">200 100 100 100</frame>
				<frame time="75">200 200 100 100</frame>
				<frame time="175">200 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">128 96 64 32</frame>
				<frame time="200">128 128 64 32</frame>
				<frame time="175">128 160 64 32</frame>
				<frame time="175">128 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">128 240 64 80</frame>
				<frame time="200">128 320 64 80</frame>
				<frame time="100">128 640 64 80</frame>
				<frame time="75">128 400 64 80</frame>
				<frame time="175">128 480 64 80</frame>
			</sprite>
			<!-- 
			<sprite origin="48 91" ulayer="8" looping="false" texture="./djinn_test.png" material="system/default.mats:actor">
				 
				<frame time="300">100 0 100 100</frame>
				<frame time="200">500 0 100 100</frame>
				<frame time="50">600 0 100 100</frame>
				<frame time="125">700 0 100 100</frame>
				<frame time="175">800 0 100 100</frame>
				
			</sprite> -->
		</scene>
		<scene name="firearc-3">
			<locator name="shoot-pos" pos="-14 -7" />
			<scene src="shared" />

			<effect delay="500" pos="-10 10" src="actors/pop/bosses/djinn/sword_sw.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">189 134 63 67</frame>
				<frame time="50">189 201 63 67</frame>
				<frame time="50">189 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">300 0 100 100</frame>
				<frame time="100">300 100 100 100</frame>
				<frame time="75">300 200 100 100</frame>
				<frame time="175">300 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">192 96 64 32</frame>
				<frame time="200">192 128 64 32</frame>
				<frame time="175">192 160 64 32</frame>
				<frame time="175">192 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">192 240 64 80</frame>
				<frame time="200">192 320 64 80</frame>
				<frame time="100">192 640 64 80</frame>
				<frame time="75">192 400 64 80</frame>
				<frame time="175">192 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-4">
			<locator name="shoot-pos" pos="-32 -18" />
			<scene src="shared" />

			<effect delay="500" pos="-15 0" src="actors/pop/bosses/djinn/sword_w.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">252 134 63 67</frame>
				<frame time="50">252 201 63 67</frame>
				<frame time="50">252 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">400 0 100 100</frame>
				<frame time="100">400 100 100 100</frame>
				<frame time="75">400 200 100 100</frame>
				<frame time="175">400 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">256 96 64 32</frame>
				<frame time="200">256 128 64 32</frame>
				<frame time="175">256 160 64 32</frame>
				<frame time="175">256 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">256 240 64 80</frame>
				<frame time="200">256 320 64 80</frame>
				<frame time="100">256 640 64 80</frame>
				<frame time="75">256 400 64 80</frame>
				<frame time="175">256 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-5">
			<locator name="shoot-pos" pos="-18 -42" />
			<scene src="shared" />

			<effect delay="500" pos="-10 -10" src="actors/pop/bosses/djinn/sword_nw.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">315 134 63 67</frame>
				<frame time="50">315 201 63 67</frame>
				<frame time="50">315 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">500 0 100 100</frame>
				<frame time="100">500 100 100 100</frame>
				<frame time="75">500 200 100 100</frame>
				<frame time="175">500 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">320 96 64 32</frame>
				<frame time="200">320 128 64 32</frame>
				<frame time="175">320 160 64 32</frame>
				<frame time="175">320 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">320 240 64 80</frame>
				<frame time="200">320 320 64 80</frame>
				<frame time="100">320 640 64 80</frame>
				<frame time="75">320 400 64 80</frame>
				<frame time="175">320 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-6">
			<locator name="shoot-pos" pos="0 -56" />
			<scene src="shared" />

			<effect delay="500" pos="0 -15" src="actors/pop/bosses/djinn/sword_n.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">378 134 63 67</frame>
				<frame time="50">378 201 63 67</frame>
				<frame time="50">378 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">600 0 100 100</frame>
				<frame time="100">600 100 100 100</frame>
				<frame time="75">600 200 100 100</frame>
				<frame time="175">600 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">384 96 64 32</frame>
				<frame time="200">384 128 64 32</frame>
				<frame time="175">384 160 64 32</frame>
				<frame time="175">384 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">384 240 64 80</frame>
				<frame time="200">384 320 64 80</frame>
				<frame time="100">384 640 64 80</frame>
				<frame time="75">384 400 64 80</frame>
				<frame time="175">384 480 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearc-7">
			<locator name="shoot-pos" pos="18 -42" />
			<scene src="shared" />

			<effect delay="500" pos="10 -10" src="actors/pop/bosses/djinn/sword_ne.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">441 134 63 67</frame>
				<frame time="50">441 201 63 67</frame>
				<frame time="50">441 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">700 0 100 100</frame>
				<frame time="100">700 100 100 100</frame>
				<frame time="75">700 200 100 100</frame>
				<frame time="175">700 300 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">448 96 64 32</frame>
				<frame time="200">448 128 64 32</frame>
				<frame time="175">448 160 64 32</frame>
				<frame time="175">448 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">448 240 64 80</frame>
				<frame time="200">448 320 64 80</frame>
				<frame time="100">448 640 64 80</frame>
				<frame time="75">448 400 64 80</frame>
				<frame time="175">448 480 64 80</frame>
			</sprite>
		</scene>
		
		<scene name="shared-fireburst">
			<effect delay="500" pos="10 0" src="actors/pop/bosses/djinn/firemuzzle_burst.effect" />
			<effect delay="1250" pos="0 0" src="actors/pop/bosses/djinn/firemuzzle_burst.effect" />
			<effect delay="750" pos="-10 0" src="actors/pop/bosses/djinn/firemuzzle_burst.effect" />
		</scene>
		<scene name="firearcburst-0">
			<locator name="shoot-pos" pos="32 -18" />
			<scene src="shared" />
			<scene src="shared-fireburst" />
			<effect delay="500" pos="10 0" src="actors/pop/bosses/djinn/sword_e.effect" />
			 
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="4" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">0 134 63 67</frame>
				<frame time="50">0 201 63 67</frame>
				<frame time="50">0 268 63 67</frame>
				<frame time="75">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="2" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">0 0 100 100</frame>
				<frame time="100">0 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">0 96 64 32</frame>
				<frame time="200">0 128 64 32</frame>
				<frame time="175">0 160 64 32</frame>
				<frame time="175">0 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">0 240 64 80</frame>
				<frame time="200">0 320 64 80</frame>
				<frame time="100">0 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-1">
			<locator name="shoot-pos" pos="14 -7" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="10 10" src="actors/pop/bosses/djinn/sword_se.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">63 134 63 67</frame>
				<frame time="50">63 201 63 67</frame>
				<frame time="50">63 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">100 0 100 100</frame>
				<frame time="100">100 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">64 96 64 32</frame>
				<frame time="200">64 128 64 32</frame>
				<frame time="175">64 160 64 32</frame>
				<frame time="175">64 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">64 240 64 80</frame>
				<frame time="200">64 320 64 80</frame>
				<frame time="100">64 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-2">
			<locator name="shoot-pos" pos="0 8" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="0 15" src="actors/pop/bosses/djinn/sword_s.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">126 134 63 67</frame>
				<frame time="50">126 201 63 67</frame>
				<frame time="50">126 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">200 0 100 100</frame>
				<frame time="100">200 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">128 96 64 32</frame>
				<frame time="200">128 128 64 32</frame>
				<frame time="175">128 160 64 32</frame>
				<frame time="175">128 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">128 240 64 80</frame>
				<frame time="200">128 320 64 80</frame>
				<frame time="100">128 640 64 80</frame>
			</sprite>
			<!-- 
			<sprite origin="48 91" ulayer="8" looping="false" texture="./djinn_test.png" material="system/default.mats:actor">
				 
				<frame time="300">100 0 100 100</frame>
				<frame time="200">500 0 100 100</frame>
				<frame time="50">600 0 100 100</frame>
				<frame time="125">700 0 100 100</frame>
				<frame time="175">800 0 100 100</frame>
				
			</sprite> -->
		</scene>
		<scene name="firearcburst-3">
			<locator name="shoot-pos" pos="-14 -7" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="-10 10" src="actors/pop/bosses/djinn/sword_sw.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">189 134 63 67</frame>
				<frame time="50">189 201 63 67</frame>
				<frame time="50">189 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">300 0 100 100</frame>
				<frame time="100">300 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">192 96 64 32</frame>
				<frame time="200">192 128 64 32</frame>
				<frame time="175">192 160 64 32</frame>
				<frame time="175">192 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">192 240 64 80</frame>
				<frame time="200">192 320 64 80</frame>
				<frame time="100">192 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-4">
			<locator name="shoot-pos" pos="-32 -18" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="-15 0" src="actors/pop/bosses/djinn/sword_w.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">252 134 63 67</frame>
				<frame time="50">252 201 63 67</frame>
				<frame time="50">252 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">400 0 100 100</frame>
				<frame time="100">400 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">256 96 64 32</frame>
				<frame time="200">256 128 64 32</frame>
				<frame time="175">256 160 64 32</frame>
				<frame time="175">256 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">256 240 64 80</frame>
				<frame time="200">256 320 64 80</frame>
				<frame time="100">256 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-5">
			<locator name="shoot-pos" pos="-18 -42" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="-10 -10" src="actors/pop/bosses/djinn/sword_nw.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">315 134 63 67</frame>
				<frame time="50">315 201 63 67</frame>
				<frame time="50">315 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">500 0 100 100</frame>
				<frame time="100">500 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">320 96 64 32</frame>
				<frame time="200">320 128 64 32</frame>
				<frame time="175">320 160 64 32</frame>
				<frame time="175">320 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">320 240 64 80</frame>
				<frame time="200">320 320 64 80</frame>
				<frame time="100">320 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-6">
			<locator name="shoot-pos" pos="0 -56" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="0 -15" src="actors/pop/bosses/djinn/sword_n.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">378 134 63 67</frame>
				<frame time="50">378 201 63 67</frame>
				<frame time="50">378 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">600 0 100 100</frame>
				<frame time="100">600 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">384 96 64 32</frame>
				<frame time="200">384 128 64 32</frame>
				<frame time="175">384 160 64 32</frame>
				<frame time="175">384 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">384 240 64 80</frame>
				<frame time="200">384 320 64 80</frame>
				<frame time="100">384 640 64 80</frame>
			</sprite>
		</scene>
		<scene name="firearcburst-7">
			<locator name="shoot-pos" pos="18 -42" />
			<scene src="shared" />
			<scene src="shared-fireburst" />

			<effect delay="500" pos="10 -10" src="actors/pop/bosses/djinn/sword_ne.effect" />
			<!-- sword fire spawn -->
			<sprite origin="33 72" ulayer="5" looping="false" texture="./djinn_sword.png" material="effects/effects.mats:fire">
				<frame time="50">441 134 63 67</frame>
				<frame time="50">441 201 63 67</frame>
				<frame time="50">441 268 63 67</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<!-- sword -->
			<sprite origin="51 88" ulayer="4" looping="false" texture="./djinn_attack_sword_firearc.png" material="system/default.mats:glow-both-bright">
				<frame time="25">0 0 0 0</frame>
				<frame time="475">700 0 100 100</frame>
				<frame time="100">700 100 100 100</frame>
			</sprite>
			<!-- djinn arms (layer sorting) -->
			<!-- <sprite origin="32 33" ulayer="3" looping="false" texture="./djinn_arms.png" material="system/default.mats:actor">
				 
				<frame time="300">448 96 64 32</frame>
				<frame time="200">448 128 64 32</frame>
				<frame time="175">448 160 64 32</frame>
				<frame time="175">448 192 64 32</frame>
			</sprite> -->
			<!-- djinn -->
			<sprite origin="32 81" ulayer="1" looping="false" texture="./djinn.png" material="system/default.mats:actor">
				 
				<frame time="300">448 240 64 80</frame>
				<frame time="200">448 320 64 80</frame>
				<frame time="100">448 640 64 80</frame>
			</sprite>
		</scene>
		
		