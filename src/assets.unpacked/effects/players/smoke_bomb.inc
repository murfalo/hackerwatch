	<sprite origin="5 4" looping="false" texture="effects/players/player_effects.png" material="effects/effects.mats:lit"
		num-sprites="radius*radius/30*t"

		pos-x="cos(i)*(i/(radius*radius/30*t))*radius*t    +rand(-u*i)*10-5"
		pos-y="sin(i)*(i/(radius*radius/30*t))*radius*t    +rand(-u+i)*10-5"
		
		color-a="rand(u+i)/2+0.5"
		
		scale-x="rand(u+i+1)/2 + 0.75"
		scale-y="rand(u+i+1)/2 + 0.75"
	>
		<frame time="150">10 71 10 9</frame>
		<frame time="140">35 71 10 9</frame>
		<frame time="130">26 71 9 9</frame>
		<frame time="80">17 71 10 9</frame>
		<frame time="40">9 71 10 9</frame>
		<frame time="20">0 71 10 9</frame>
	</sprite>