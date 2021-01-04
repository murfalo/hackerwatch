<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
	
		<string name="type">construct</string>
		<int name="hp">200</int>
		<int name="armor">50</int>
		<int name="resistance">50</int>
		<float name="mp-scale-fact">1</float>
		<bool name="counts-as-kill">false</bool>
		
		<string name="gore">effects/gibs/gib_generic_stone.sval</string>
		<string name="death-snd">event:/enemy/tower/death</string>
		
		<bool name="impenetrable">true</bool>
		<array name="buffs-immune-tags">
			<string>poison</string>
			<string>confusion</string>
			<string>debuff</string>
			<string>disarm</string>
			<string>root</string>
			<string>stun</string>
			<string>slow</string>
			<string>buff</string>
			<string>bleeding</string>
			<string>respawn_ghost</string>
			<string>freezing</string>
		</array>

		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>

		<array name="skills">

		</array>
	</behavior>
	
	<scenes default="default">
		<scene name="shared">
			<collision static="true">
				<rect aim-through="false" shoot-through="false">-8 -8 16 16</rect>		
			</collision>
			
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			
			<shadow>
				<sprite origin="-8 11" texture="./statue.png">
					<frame>69 103 3 19</frame>
				</sprite>
			</shadow>
		</scene>

		<scene name="default">
			<scene src="shared" />
			<sprite origin="10 32" texture="./statue.png" material="system/default.mats:default">
%if a_1
				<frame>0 82 19 40</frame>
%elif a_2
				<frame>23 82 19 40</frame>
%elif a_3
				<frame>46 82 19 40</frame>
%elif b_1
				<frame>0 42 23 40</frame>
%elif b_2
				<frame>23 42 23 40</frame>
%elif b_3
				<frame>46 42 23 40</frame>
%elif c_1
				<frame>0 0 23 42</frame>
%elif c_2
				<frame>23 0 23 42</frame>
%elif c_3
				<frame>46 0 23 42</frame>
%endif
			</sprite>	
		</scene>
	</scenes>
</unit>
