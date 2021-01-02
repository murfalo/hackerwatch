<unit netsync="position" slot="actors">
	<behavior class="CompositeActorBehavior">

		<string name="type">construct</string>
		<int name="hp">VALUE_HP</int>
		<int name="armor">VALUE_ARMOR</int>
		<int name="resistance">VALUE_RESISTANCE</int>
		<float name="mp-scale-fact">1</float>
		
		<string name="gore">effects/gibs/gib_hellcube.sval</string>
%if STAGE8
        <string name="death-snd">event:/enemy/hellcube/death</string>
%else
        <string name="death-snd">event:/enemy/hellcube/damage</string>
%endif
		
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
			<string name="anim-idle">idle</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict name="action">
						<string name="class">RaiseUnitEvent</string>
						<string name="name">destroyed</string>
					</dict>
					%if !STAGE8
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/special/hellcube/fx_switch.effect</string>
					</dict>
					%endif
					%if STAGE8
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/special/hellcube/fx_implode.effect</string>
					</dict>					
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/special/hellcube/fx_splash.effect</string>
					</dict>					
					%endif					
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">1000</int>

				<dict name="action">
					<string name="class">RaiseUnitEvent</string>
					<string name="name">spawnunits</string>
				</dict>
			</dict>
			
			%if PRISON
				%if STAGE7 || STAGE8
					%include "actors/special/hellcube/hellcube_attack.inc"
				%endif
			%endif
			
			%if ARMORY
				%if STAGE6 || STAGE7 || STAGE8
					%include "actors/special/hellcube/hellcube_attack.inc"
				%endif
			%endif
			
			%if ARCHIVES
				%if STAGE5 || STAGE6 || STAGE7 || STAGE8
					%include "actors/special/hellcube/hellcube_attack.inc"
				%endif
			%endif			
			
		</array>
	</behavior>

%include "actors/special/hellcube/hellcube_gfx.inc"

</unit>
