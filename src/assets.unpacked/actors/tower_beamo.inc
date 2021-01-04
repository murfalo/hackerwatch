<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_beamo</string>
%else
		<string name="beastiary-override">actors/tower_ballista_javelin.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 5</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">construct</string>
		<int name="hp">600</int>
		<int name="armor">55</int>
		<int name="resistance">55</int>
		<int name="experience-reward">225</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="gore">effects/gibs/gib_tower_beamo.sval</string>
		<string name="death-snd">event:/enemy/tower/death</string>
		<string name="loot">actors/loot.sval:tower_beamo.unit</string>

		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">true</bool>
		<int name="aggro-range">150</int>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">idle 16</string>
		</dict>

		<array name="skills">
			%// Beam
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 16</string>
				<string name="start-snd">event:/enemy/tower_rail/shoot-rail</string>
				<string name="snd">event:/enemy/high_priest/beam</string>
				
				<int name="cooldown">BEAMCD</int>
				<int name="castpoint">500</int>
				<int name="range">200</int>
				<bool name="good-aim">false</bool>	
				<bool name="must-see">true</bool>

				<dict name="action">
					<string name="class">Hitscan</string>
					<int name="rays">BEAMRAYS</int>
					<int name="spread">BEAMSPREAD</int>
					<bool name="miss-fx">true</bool>
					
					<string name="hit-fx">actors/projectiles/rail_hit.effect</string>
					<string name="shoot-fx">actors/projectiles/beamo_beam.effect</string>
					
					<array name="effects">
						<dict>
							<string name="class">Damage</string>
							<int name="magical">50</int>
						</dict>
					
						<dict>
							<string name="class">ApplyBuff</string>
							<string name="buff">actors/buffs.sval:confusion</string>
						</dict>
					</array>

					<dict name="range">
						<int name="min">200</int>
						<int name="max">200</int>
					</dict>
				</dict>
			</dict>
			
			%// WhirlNova
			<dict>
				<string name="class">WhirlNovaSkill</string>
				<string name="anim">nova</string>
				<string name="fire-snd">event:/enemy/tower_rail/shoot</string>
				
				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">800</int>
				<int name="duration">WHIRLDUR</int>
				<int name="min-range">0</int>
				<int name="range">200</int>
				<bool name="must-see">true</bool>

				<string name="projectile">WHIRLPROJ</string>
				<float name="proj-dist">6</float>
				<int name="proj-delay">WHIRLPROJDELAY</int>
				<int name="per-revolution">WHIRLPROJPERREV</int>
			</dict>
		</array>
		
		<bool name="hold-angle-on-cast">true</bool>
		
		<dict name="effect-params">
			<float name="length">200</float>
			<float name="height">10</float>
		</dict>
	</behavior>

	<scenes>
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<rect aim-through="false" shoot-through="false">-6 -7 12 14</rect>
			</collision>
			<sprite origin="5 20" looping="false" ulayer="15" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>54 0 10 15</frame>
			</sprite>
			<sprite origin="7 7" texture="actors/tower_beamo.png" ulayer="-20" material="system/default.mats:actor">
				<frame>40 0 14 14</frame>
			</sprite>
			<shadow>
				<sprite origin="-5 8" texture="actors/tower_beamo.png" layer="-21" material="system/default.mats:shadow">>
					<frame>40 14 3 13</frame>
				</sprite>
			</shadow>
		</scene>
		
	<scene name="shared-idle">
			%if GAME
			<!-- <effect src="actors/tower_beamo_trail_aim_idle.effect" /> -->
			%endif
		</scene>
		
		<scene name="shared-attack">
			%if GAME
			<effect src="actors/tower_beamo_trail_aim_attack.effect" />
			%endif
		</scene>

		<scene name="nova">
			<scene src="shared" /> 
			
			<!-- Eye -->
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="100">0 10 10 10</frame>
			</sprite>
			
			<!-- Cylinder -->
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>

				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>

				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>

				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
				<frame time="50">0 40 10 19</frame>
				<frame time="50">10 40 10 19</frame>
				<frame time="50">20 40 10 19</frame>
				<frame time="50">30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-0">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-1">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-2">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-3">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-4">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-5">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-6">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-7">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-8">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-9">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-10">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-11">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-12">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-13">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-14">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="idle-15">
			<scene src="shared" />
			<scene src="shared-idle" />
			<sprite origin="5 21" looping="true" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="true" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-0">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-1">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-2">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-3">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 0 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-4">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-5">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-6">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-7">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 10 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-8">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-9">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10  40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-10">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-11">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 20 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-12">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">0 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-13">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">10 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-14">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">20 40 10 19</frame>
			</sprite>
		</scene>
		
		<scene name="attack-15">
			<scene src="shared" />
			<scene src="shared-attack" />
			<sprite origin="5 21" looping="false" ulayer="20" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 30 10 10</frame>
			</sprite>
			<sprite origin="5 17" looping="false" ulayer="10" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame time="700">30 40 10 19</frame>
			</sprite>
		</scene>
		<scene name="portrait">
			<sprite origin="8 14" looping="false" ulayer="2" texture="actors/tower_beamo.png" material="system/default.mats:actor">
				<frame>48 32 16 28</frame>
			</sprite>
			
		</scene>
	</scenes>
</unit>