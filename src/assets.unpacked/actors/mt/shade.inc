<unit netsync="position" slot="actor" layer="20">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.shade</string>
%else
		<string name="beastiary-override">actors/mt/shade.unit</string>
%endif
		<vec2 name="beastiary-offset">1 8</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">aberration</string>
		<int name="hp">800</int>
		<int name="armor">30</int>
		<int name="resistance">60</int>
		<int name="experience-reward">130</int>
		<float name="mp-scale-fact">0.65</float>
		
		<int name="unit-height">24</int>
		
		<string name="death-snd">event:/enemy/shade/death</string>
		<string name="gore">effects/gibs/gib_djinn.sval</string>

		<int name="aggro-range">999</int>
		<bool name="must-see-target">false</bool>
		<float name="wind-scale">0</float>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying.inc"
			<string>nightbeamdeath</string>
			<string>player</string>
			<string>agents</string>
		</array>
		
		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">idle 8</string>

			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
		</dict>

		<array name="skills">
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>great_threat</string>
				</array>
				
				<string name="class">CompositeActorPeriodicTriggeredSkill</string>
				<string name="trigger">OnTime</string>
				<int name="period">750</int>
				
				<int name="min-range">200</int>
				<int name="range">9999</int>
				<bool name="must-see">false</bool>
				
				<dict name="action">
					<string name="class">ApplyBuff</string>
					<string name="buff">actors/buffs.sval:mt-gt-speed</string>
					<bool name="target-self">true</bool>
				</dict>
			</dict>
			
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/shade/attack</string>

				<int name="cooldown">100</int>
				<int name="castpoint">450</int>
				<int name="range">20</int>
				<int name="dmg-range">24</int>
				<int name="arc">160</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="magical">75</int>
						<float name="resistance-mul">0.8</float>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:darkness</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorBurstSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/shade/shoot</string>
				<!-- <string name="offset">attack-pos</string> -->

				<int name="burst">SHOOTBURST</int>

				<int name="cooldown-start">500</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">450</int>
				<int name="min-range">50</int>
				<int name="range">150</int>
				<bool name="good-aim">true</bool>
				<float name="aim-interception">AIMINTERCEPTION</float>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/mt/projectiles/shade_ball.unit</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>		
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/mt/shade_explosion.effect</string>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/shade_deatharea.unit</string>
						<bool name="safe-spawn">false</bool>
					</dict>
%endif
				</array>
			</dict>			
			
		</array>
		
		<bool name="hold-angle-on-cast">true</bool>
		<dict name="effect-params" />
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
		
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" />
				<circle offset="0 -7" sensor="true" shoot-through="false" aim-through="true" radius="5" />
			</collision>
			
			<effect pos="0 -10" src="actors/mt/shade_dust.effect" />
			
			<sprite origin="4 5" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="100">35 72 7 10</frame>
				<frame time="100">42 72 7 10</frame>
				<frame time="100">49 7 10</frame>
				<frame time="100">56 72 7 10</frame>
				<frame time="100">63 72 7 10</frame>
			</sprite>
		</scene>
		
		<scene name="shared-attack">
 			<light pos="0 -6">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="1000" />
				<overbright value="1"/>
				<overlay value="false"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="40" />
					<size value="35" />
				</sizes>
				<colors>
					<color value="95 80 255 0" />
					<color value="105 90 255 0" />
				</colors>
			</light>
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="4" />
				<circle offset="0 -7" sensor="true" shoot-through="false" aim-through="true" radius="5" />
			</collision>
			
			<effect pos="0 -10" src="actors/mt/shade_dust.effect" />
			
			<sprite origin="4 5" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="100">0 72 7 10</frame>
				<frame time="100">7 72 7 10</frame>
				<frame time="100">14 72 7 10</frame>
				<frame time="100">21 72 7 10</frame>
				<frame time="100">28 72 7 10</frame>
			</sprite>
		</scene>
		
		
		<scene name="idle-0">
		  <scene src="shared" />
		  <sprite origin="12 20" ulayer="1" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">0 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-1">
		  <scene src="shared" />
		  <sprite origin="12 20" ulayer="1" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">24 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-2">
		  <scene src="shared" />
		  <sprite origin="12 20" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">48 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-3">
		  <scene src="shared" />
		  <sprite origin="12 20" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">72 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-4">
		  <scene src="shared" />
		  <sprite origin="12 20" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">96 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-5">
		  <scene src="shared" />
		  <sprite origin="12 20" ulayer="1" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">120 0 24 24</frame>
		  </sprite>
		</scene>
		
		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="12 20" ulayer="1" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">144 0 24 24</frame>
		  </sprite>
		</scene>

		<scene name="idle-7">
		  <scene src="shared" />
		  <sprite origin="12 20" ulayer="1" looping="true" texture="actors/mt/shade.png" material="system/default.mats:actor">
			<frame time="75">168 0 24 24</frame>
		  </sprite>
		</scene>
		
		<scene name="attack-0">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">0 24 24 24</frame>
				<frame time="100">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">24 24 24 24</frame>
				<frame time="100">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene 
			src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">48 24 24 24</frame>
				<frame time="100">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">72 24 24 24</frame>
				<frame time="100">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">96 24 24 24</frame>
				<frame time="100">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">120 24 24 24</frame>
				<frame time="100">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared-attack" />
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">144 24 24 24</frame>
				<frame time="100">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared-attack" />			
			<effect delay="400" src="actors/mt/shade_attack_slash.effect" />
			<sprite origin="12 20" looping="false" texture="actors/mt/shade.png" material="system/default.mats:actor">
				<frame time="400">168 24 24 24</frame>
				<frame time="100">168 48 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>