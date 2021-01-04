<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
		<!-- <string name="beastiary-name">.bestiary.name.pylon</string> -->
		<!-- <string name="beastiary-scene">idle</string> -->
		<!-- <vec2 name="beastiary-offset">0 15</vec2> -->
		<!-- <string name="quality">rare</string> -->
	
		<string name="type">construct</string>
		<int name="hp">1500</int>
		<int name="armor">20</int>
		<int name="resistance">30</int>
		<float name="mp-scale-fact">1.25</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">28</int>
		
		<string name="gore">effects/gibs/gib_boss_wisp_pylon.sval</string>
		<string name="death-snd">event:/enemy/boss_wisp/pylon_break</string>

		<bool name="impenetrable">true</bool>
		<bool name="collide-with-team">false</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">9999</int>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">idle</string>
		</dict>

		<array name="skills">
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>links_broken</string>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">overload</string>
				<string name="start-snd">event:/enemy/boss_wisp/pylon_down</string>

				<int name="cooldown">0</int>
				<int name="castpoint">1000</int>
				
				<int name="range">1000</int>
				<bool name="must-see">false</bool>

				<array name="actions">
					<dict name="action">
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">ConstantSoundSkill</string>
				<bool name="only-walking">false</bool>
				<string name="sound">event:/enemy/boss_wisp/pylon_beam</string>
			</dict>
		
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>HUNKERDOWN</string>
				</array>
				
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>
				<string name="anim">hunkerdown</string>
				<string name="start-snd">event:/enemy/boss_wisp/pylon_down</string>
				
				<int name="castpoint">20000</int>
				<int name="cooldown-start">0</int>
				<int name="cooldown">100</int>
				
				<int name="range">9999</int>
				<bool name="must-see">false</bool>
				
				<array name="start-actions">
					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">false</bool>
						<string name="flag">LINK</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">LINK</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">HUNKERDOWN</string>
					</dict>
				</array>
				
				<array name="actions">
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wisp/pylon_up</string>
					</dict>
				
					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">true</bool>
						<string name="flag">LINK</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">LINK</string>
					</dict>
					
					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">false</bool>
						<string name="flag">HUNKERDOWN</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">HUNKERDOWN</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				
				<array name="actions">
					<dict>
						<string name="class">SetFlag</string>
						<bool name="value">false</bool>
						<string name="flag">LINK</string>
					</dict>
					
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">DEST</string>
					</dict>
				
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/giant_wisp/pylon_razed.unit</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes>
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>			
			<collision static="true">
				<circle offset="0 10" radius="8" />
			</collision>	
		</scene>
		


		<scene name="idle">
			<scene src="shared" />
			<effect src="./pylon_active.effect" />
			<sprite origin="0 0" looping="false" texture="./giant_wisp.png" material="system/default.mats:default"
			>		
				<frame time="20000">0 0 0 0</frame>
			</sprite>
		</scene>

				
 		<scene name="hunkerdown">
 			<scene src="shared" />
			<effect src="./pylon_deactivated.effect" />
			<sprite origin="0 0" looping="false" texture="./giant_wisp.png" material="system/default.mats:default"
			>		
				<frame time="20000">0 0 0 0</frame>
			</sprite>	

			<effect delay="20000" src="./pylon_active.effect" />
		</scene>
	</scenes>
</unit>