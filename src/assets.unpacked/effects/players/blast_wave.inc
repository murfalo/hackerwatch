	<sprite origin="8 8" looping="false" texture="./spray.png" material="system/default.mats:glow-both-bright"
		num-sprites="radius*radius/30*t"

		pos-x="cos(i)*(i/(radius*radius/30*t))*radius*t"
		pos-y="sin(i)*(i/(radius*radius/30*t))*radius*t"
		
		%//color-a="rand(u+i)/2+0.5"
		
		scale-x="rand(u+i+1)/2 + 0.25"
		scale-y="rand(u+i+1)/2 + 0.25"
	>
		<frame time="33">0 0 16 16</frame>
		<frame time="33">0 0 16 16</frame>	
		<frame time="33">16 0 16 16</frame>
		<frame time="33">16 0 16 16</frame>	
		<frame time="33">32 0 16 16</frame>	
		<frame time="33">64 0 16 16</frame>	
		<frame time="50">80 0 16 16</frame>	
		<frame time="50">96 0 16 16</frame>
		%//<frame time="100">112 0 16 16</frame>
	</sprite>
	
	
	%// Flash
	<light pos="0 15"> 
		<sprite texture="system/light_concentrated_L.png">
			<frame time="100">0 0 128 128</frame>
		</sprite>
		
		<length value="100" />
		
		<looping value="false" />

		%//<size value="pow((sin((pow(t, 0.1))+1)), 100) * 100" />
		
		<size value="2 * radius * t" />
		
		<color-r value="2" />
		<color-g value="0.8" />
		<color-b value="0.75" />
		<color-a value="0.05" />
	</light>

	%// Fade
	<light pos="0 15">
		<sprite texture="system/light_L.png">
			<frame time="0">0 0 0 0</frame>
			<frame time="100">0 0 128 128</frame>
		</sprite>
		
		<length value="300" />
		
		<looping value="false" />

		<size value="max(0,t * radius * 3) + 10" />
		
		<color-r value="2 - t" />
		<color-g value="(1 - t) * 0.8" />
		<color-b value="0" />
		<color-a value="0" />
	</light>