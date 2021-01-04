	<param name="ttl" default="1000" />
	
	<sprite origin="4 4" looping="true" texture="effects/empty.png" material="system/default.mats:glow-both-bright"
		num-sprites="radius * radius / 30/10"

		pos-x="cos(rand(u+27*i)*2*pi) * radius * pow(rand(u+67*i),0.5)"
        pos-y="sin(rand(u+27*i)*2*pi) * radius * pow(rand(u+67*i),0.5)  -10 * it"
		
        color-r="1 - mod(it+l+rand(u*i), 0.5)"
        color-g="0.5 - mod(it+l+rand(u*i), 1)"
        color-b="0"
        color-a="(1 - mod(it+l+rand(u*i), 1)) * saturate(ttl / 200)"
	>
        <frame time="600">0 0 1 1</frame>
	</sprite>

	<sprite origin="4 4" looping="true" texture="players/wizard/scorchedearth.png" material="effects/effects.mats:fire"
		num-sprites="radius * radius / 100"

		pos-x="cos(rand(u+13*i)*2*pi) * radius * pow(rand(u+37*i),0.5)"
        pos-y="sin(rand(u+13*i)*2*pi) * radius * pow(rand(u+37*i),0.5)"
		
		color-a="min(rand(u+i*47),(it+il)/2) * saturate(ttl / 200)"
	>
        <frame time="100" x="0" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="8" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="16" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="24" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="32" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
	</sprite>
	
	<!-- Ring edge -->
	<sprite origin="4 4" looping="true" texture="players/wizard/scorchedearth.png" material="effects/effects.mats:fire"
		num-sprites="radius / 3"

		pos-x="cos(i / (radius / 3) * pi*2) * lerp(rand(u+101*i), radius - 3, radius+2)"
        pos-y="sin(i / (radius / 3) * pi*2) * lerp(rand(u+141*i), radius - 3, radius+2)"
		
		color-a="saturate(t+l) * saturate(ttl / 200)"
	>
        <frame time="100" x="0" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="8" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="16" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="24" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
        <frame time="100" x="32" y="7 * floor(rand(u+i*97)*4)" w="8" h="7" />
	</sprite>
	<!-- <sprite origin="4 4" looping="true" texture="players/wizard/scorchedearth.png" material="effects/effects.mats:fire"
		num-sprites="radius / 2"

		pos-x="cos(i / (radius / 2) * pi*2) * radius * 1"
        pos-y="sin(i / (radius / 2) * pi*2) * radius * 1"
		
		color-a="saturate(t+l) * saturate(ttl / 200)"
	>
        <frame time="100">0 21 8 7</frame>
        <frame time="100">8 21 8 7</frame>
        <frame time="100">16 21 8 7</frame>
        <frame time="100">24 21 8 7</frame>
        <frame time="100">32 21 8 7</frame>
	</sprite> 
	
	<sprite origin="4 4" looping="true" texture="players/wizard/scorchedearth.png" material="effects/effects.mats:fire"
		num-sprites="radius / 2"

		pos-x="cos(i / (radius / 2) * pi*2) * radius * 1"
        pos-y="sin(i / (radius / 2) * pi*2) * radius * 1"
		
		color-a="saturate(t+l) * saturate(ttl / 200)"
	>
        <frame time="100">0 7 8 7</frame>
        <frame time="100">8 7 8 7</frame>
        <frame time="100">16 7 8 7</frame>
        <frame time="100">24 7 8 7</frame>
        <frame time="100">32 7 8 7</frame>
	</sprite>
	<sprite origin="4 4" looping="true" texture="players/wizard/scorchedearth.png" material="effects/effects.mats:fire"
		num-sprites="radius / 2"

		pos-x="cos(i / (radius / 2) * pi*2) * radius * 1"
        pos-y="sin(i / (radius / 2) * pi*2) * radius * 1"
		
		color-a="saturate(t+l) * saturate(ttl / 200)"
	>
        <frame time="100">0 0 8 7</frame>
        <frame time="100">8 0 8 7</frame>
        <frame time="100">16 0 8 7</frame>
        <frame time="100">24 0 8 7</frame>
        <frame time="100">32 0 8 7</frame>
	</sprite> -->
	
	
	
	
	
	<light pos-x="0" pos-y="0">
		<sprite texture="system/light_L.png">
			<frame time="500">0 0 128 128</frame>
		</sprite>

		<looping value="true" />

		<cast-shadows value="false" />

		<shadow-cast-pos-x value="0" />
		<shadow-cast-pos-y value="0" />

		<shadow-cast-pos-jitter value="0 0 0 0" />

		<size value="max(t*10, radius * 3 + 10)" />

		<color-r value="1 * saturate(ttl / 200)" />
		<color-g value="0.5 * saturate(ttl / 200)" />
		<color-b value="0" />
		<color-a value="0"/>
	</light>