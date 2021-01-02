<effect layer="-9" looping="true" material="effects/effects.mats:no-height">

	<param name="radius" default="RADIUS" />
	<param name="colorr" default="COLORR" />
	<param name="colorg" default="COLORG" />
	<param name="colorb" default="COLORB" />

	<sprite looping="true" origin="128 128" mask="1001" texture="doodads/generic/trap_indicator.png" material="system/default.mats:bright-noxray"
		
		scale-x="(min(1,(t*4 + l)) * (radius/256*2)-3/256"
		scale-y="(min(1,(t*4 + l)) * (radius/256*2)-3/256"
		
		>
		<frame time="1000">0 0 256 256</frame>
	</sprite>

	<sprite looping="true" origin="128 128" masked="1001" texture="doodads/generic/trap_indicator.png" material="system/default.mats:bright-noxray"
	
		scale-x="min(1,(t*4 + l)) * (radius/256*2)"
		scale-y="min(1,(t*4 + l)) * (radius/256*2)"
		
		color-r="colorr"
		color-g="colorg"
		color-b="colorb"
		color-a="0.5"
		
		>
		<frame time="1000">0 0 256 256</frame>
	</sprite>
	
</effect>
