<unit netsync="position" slot="actor">
	<behavior class="BossLich">
%if SCYTHE
		<string name="beastiary-override">actors/bosses/wraith/wraith_scythe.unit</string>
%elif STAFF
		<string name="beastiary-override">actors/bosses/wraith/wraith_staff.unit</string>
%elif MAGE
		<string name="beastiary-override">actors/bosses/wraith/wraith_mage.unit</string>
%endif
		
		<string name="type">undead</string>
		<int name="hp">7500</int>
		<int name="armor">30</int>
		<int name="resistance">60</int>
		<float name="mp-scale-fact">1.25</float>
		
		<string name="death-snd">event:/enemy/boss_wraith/death</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">400</int>
		<int name="unit-height">40</int>
		<float name="debuff-scale">0.5</float>
		<float name="wind-scale">0</float>
		
		<array name="buffs-immune-tags">
			<string>bleeding</string>
			<string>confusion</string>
			<string>debuff</string>
			<string>root</string>
			<string>disarm</string>
			<string>stun</string>
			<string>slow</string>
		</array>
		
		<dict name="effect">
			<string name="class">ApplyBuff</string>
			<string name="buff">actors/buffs.sval:mana-leak</string>
		</dict>

		<dict name="movement">
			<string name="class">BossLichMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">5.25</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<dict name="action">
					<string name="class">SpawnEffect</string>
					<string name="effect">actors/bosses/wraith/wraith_death.effect</string>
				</dict>
			</dict>	
		
%if SCYTHE
			<dict>
				<string name="class">BossLichRandomSkill</string>
				
				<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
				
				<string name="anim">scythe</string>
				<int name="castpoint">2200</int>

				<bool name="must-have-target">true</bool>
				<bool name="good-aim">true</bool>

				<int name="melee-range">35</int>
				<int float="melee-chance">0.9</int>
				<int name="melee-cooldown">1000</int>

				<string name="trigger">OnTime</string>
				<int name="max-range">125</int>
				<int name="period">1000</int>
				<int name="period-rand">250</int>

				<array name="actions">
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wraith/attack-scythe</string>
					</dict>			
					
					<dict>
						<string name="class">Explode</string>
						
						<int name="min-radius">45</int>
						<int name="radius">45</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.75</float>
							</dict>
						</array>
					</dict>
					
					<dict>
						<string name="class">Nova</string>
						
						<int name="projectiles">5</int>
						<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker_both.unit</string>
						<int name="dist">20</int>
					</dict>
				</array>
			</dict>

%elif STAFF
			<dict>
				<string name="class">BossLichRandomSkill</string>
				
				<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
				
				<string name="anim">staff</string>
				<int name="castpoint">2580</int>

				<bool name="must-have-target">true</bool>

				<int name="melee-range">35</int>
				<int float="melee-chance">0.7</int>
				<int name="melee-cooldown">1000</int>

				<string name="trigger">OnTime</string>
				<int name="max-range">200</int>
				<int name="period">1000</int>
				<int name="period-rand">250</int>

				<array name="actions">
					
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wraith/attack-staff</string>
					</dict>		
					
					<dict>
						<string name="class">RaiseUnitEvent</string>
						<string name="name">staff_area</string>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
						<bool name="safe-spawn">false</bool>
						<int name="spawn-dist">0</int>
					</dict>
				</array>
			</dict>

%elif MAGE
			<dict>
				<string name="class">BossLichRandomSkill</string>
				
				<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
				
				<string name="anim">mage</string>
				<int name="castpoint">4500</int>

				<bool name="must-have-target">true</bool>

				<int name="melee-range">35</int>
				<int float="melee-chance">0.8</int>
				<int name="melee-cooldown">1000</int>

				<string name="trigger">OnTime</string>
				<int name="max-range">150</int>
				<int name="period">1000</int>
				<int name="period-rand">250</int>

				<array name="actions">
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_wraith/attack-mage</string>
					</dict>		
					
					<dict>
						<string name="class">Nova</string>
						<int name="projectiles">19</int>
						<string name="projectile">actors/bosses/wraith/wraith_mage_nova_both.unit</string>
					</dict>
				</array>
			</dict>

%endif
		</array>
	</behavior>

	<scenes start="idle">
		<scene name="shared">
			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="true" density="100"/>
			</collision>
			
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			
			<shadow>
				<sprite origin="14 12" texture="doodads/special/shadows.png">
					<frame>66 0 24 24</frame>
				</sprite>
			</shadow>	
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<sprite origin="32 50" ulayer="1" looping="true" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="150">0 256 64 64</frame>
				<frame time="150">0 320 64 64</frame>
				<frame time="150">0 384 64 64</frame>
				<frame time="150">0 448 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="walk-0">
			<scene src="shared" />
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif							
				<frame time="150">0 0 64 64</frame>
				<frame time="150">0 64 64 64</frame>
				<frame time="150">0 128 64 64</frame>
				<frame time="150">0 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">64 0 64 64</frame>
				<frame time="150">64 64 64 64</frame>
				<frame time="150">64 128 64 64</frame>
				<frame time="150">64 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />	
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">128 0 64 64</frame>
				<frame time="150">128 64 64 64</frame>
				<frame time="150">128 128 64 64</frame>
				<frame time="150">128 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">192 0 64 64</frame>
				<frame time="150">192 64 64 64</frame>
				<frame time="150">192 128 64 64</frame>
				<frame time="150">192 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />	
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">256 0 64 64</frame>
				<frame time="150">256 64 64 64</frame>
				<frame time="150">256 128 64 64</frame>
				<frame time="150">256 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />	
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">320 0 64 64</frame>
				<frame time="150">320 64 64 64</frame>
				<frame time="150">320 128 64 64</frame>
				<frame time="150">320 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />	
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">384 0 64 64</frame>
				<frame time="150">384 64 64 64</frame>
				<frame time="150">384 128 64 64</frame>
				<frame time="150">384 192 64 64</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />	
			%if MAGE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_mage.png" material="system/default.mats:actor">
			%endif
			%if SCYTHE
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith_scythe.png" material="system/default.mats:actor">
			%endif
			%if STAFF
			<sprite origin="32 50" ulayer="1" layer="20" looping="true" texture="./wraith.png" material="system/default.mats:actor">
			%endif	
				<frame time="150">448 0 64 64</frame>
				<frame time="150">448 64 64 64</frame>
				<frame time="150">448 128 64 64</frame>
				<frame time="150">448 192 64 64</frame>
			</sprite>
		</scene>
		
		<scene name="mage">
			<scene src="shared" />

			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>			
			
			<!-- Body fade in fade out-->
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="150">0 256 64 64</frame>
				<frame time="150">0 320 64 64</frame>
				<frame time="150">0 384 64 64</frame>
				<frame time="150">0 448 64 64</frame>
				<frame time="150">0 512 64 64</frame>
				<frame time="150">0 576 64 64</frame>
				<frame time="150">0 640 64 64</frame>	
				<frame time="4350">0 0 0 0</frame>	
				<frame time="100">0 640 64 64</frame>
				<frame time="100">0 576 64 64</frame>
				<frame time="100">0 512 64 64</frame>	<!-- 5700 -->
			</sprite>
			
			<!-- Face fade in -->
			<sprite origin="21 23" ulayer="3" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="600">0 0 0 0</frame>	
				<frame time="150">92 512 28 19</frame>
				<frame time="150">92 531 28 19</frame>
				<frame time="150">92 550 28 19</frame>
				<frame time="2550">0 0 0 0</frame>	<!-- 3600 -->
			</sprite>
				
			<!-- Attack -->
			<sprite origin="35 46" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="1050">0 0 0 0</frame>
				<frame time="150">64 576 67 51</frame>
				<frame time="150">131 576 67 51</frame>
				<frame time="150">198 576 67 51</frame>
				<frame time="150">265 576 67 51</frame>
				<frame time="150">332 576 67 51</frame>
				<frame time="150">399 576 67 51</frame>
				<frame time="150">466 576 67 51</frame>
				<frame time="150">533 576 67 51</frame>
				<frame time="150">600 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">801 576 67 51</frame>
				<frame time="150">868 576 67 51</frame>		<!-- 4200 -->
				<frame time="75">64 627 67 51</frame>
				<frame time="75">131 627 67 51</frame>
				<frame time="75">198 627 67 51</frame>
				<frame time="75">265 627 67 51</frame>		<!-- castpoint 4500 -->
				<frame time="75">332 627 67 51</frame>
				<frame time="75">399 627 67 51</frame>
				<frame time="75">466 627 67 51</frame>
				<frame time="75">533 627 67 51</frame>
				<frame time="75">600 627 67 51</frame>
				<frame time="75">667 627 67 51</frame>
				<frame time="500">734 627 67 51</frame>
				<frame time="150">0 0 0 0</frame>		<!-- 5600 -->
			</sprite>
			
			<!-- Attack effect -->
			<sprite origin="35 46" ulayer="5" looping="false" texture="./wraith.png" material="system/default.mats:bright-noxray">
				<frame time="1050">0 0 0 0</frame>
				<frame time="150">164 474 67 51</frame>
				<frame time="150">231 474 67 51</frame>
				<frame time="150">298 474 67 51</frame>
				<frame time="150">365 474 67 51</frame>
				<frame time="150">432 474 67 51</frame>
				<frame time="150">499 474 67 51</frame>
				<frame time="150">566 474 67 51</frame>
				<frame time="150">633 474 67 51</frame>
				<frame time="150">700 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">901 474 67 51</frame>
				<frame time="150">968 474 67 51</frame>
				<frame time="75">164 525 67 51</frame>
				<frame time="75">231 525 67 51</frame>
				<frame time="75">298 525 67 51</frame>
				<frame time="75">365 525 67 51</frame>
				<frame time="75">432 525 67 51</frame>
				<frame time="75">499 525 67 51</frame>
				<frame time="75">566 525 67 51</frame>
				<frame time="75">633 525 67 51</frame>
				<frame time="75">700 525 67 51</frame>
				<frame time="75">767 525 67 51</frame>
				<frame time="500">834 525 67 51</frame>
				<frame time="150">0 0 0 0</frame>
			</sprite>
			
			<light pos="0 0" delay="4500">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="100" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="150" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="255 150 150 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>
		</scene>
		
		<scene name="mage_intro">	
			<scene src="shared" />
			
			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>
			
			<!-- Body fade out -->
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="2750">0 0 0 0</frame>	
				<frame time="100">0 640 64 64</frame>
				<frame time="100">0 576 64 64</frame>
				<frame time="100">0 512 64 64</frame>	
			</sprite>

			<!-- Attack -->
			<sprite origin="35 46" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="150">265 576 67 51</frame>
				<frame time="150">332 576 67 51</frame>
				<frame time="150">399 576 67 51</frame>
				<frame time="150">466 576 67 51</frame>
				<frame time="150">533 576 67 51</frame>
				<frame time="150">600 576 67 51</frame>
				<frame time="150">667 576 67 51</frame>
				<frame time="150">734 576 67 51</frame>
				<frame time="150">801 576 67 51</frame>
				<frame time="150">868 576 67 51</frame>
				<frame time="75">64 627 67 51</frame>
				<frame time="75">131 627 67 51</frame>
				<frame time="75">198 627 67 51</frame>
				<frame time="75">265 627 67 51</frame>
				<frame time="75">332 627 67 51</frame>
				<frame time="75">399 627 67 51</frame>
				<frame time="75">466 627 67 51</frame>
				<frame time="75">533 627 67 51</frame>
				<frame time="75">600 627 67 51</frame>
				<frame time="75">667 627 67 51</frame>
				<frame time="500">734 627 67 51</frame>
				<frame time="150">0 0 0 0</frame>
			</sprite>
			
			<!-- Attack effect -->
			<sprite origin="35 46" ulayer="5" looping="false" texture="./wraith.png" material="system/default.mats:bright-noxray">
				<frame time="150">365 474 67 51</frame>
				<frame time="150">432 474 67 51</frame>
				<frame time="150">499 474 67 51</frame>
				<frame time="150">566 474 67 51</frame>
				<frame time="150">633 474 67 51</frame>
				<frame time="150">700 474 67 51</frame>
				<frame time="150">767 474 67 51</frame>
				<frame time="150">834 474 67 51</frame>
				<frame time="150">901 474 67 51</frame>
				<frame time="150">968 474 67 51</frame>
				<frame time="75">164 525 67 51</frame>
				<frame time="75">231 525 67 51</frame>
				<frame time="75">298 525 67 51</frame>
				<frame time="75">365 525 67 51</frame>
				<frame time="75">432 525 67 51</frame>
				<frame time="75">499 525 67 51</frame>
				<frame time="75">566 525 67 51</frame>
				<frame time="75">633 525 67 51</frame>
				<frame time="75">700 525 67 51</frame>
				<frame time="75">767 525 67 51</frame>
				<frame time="500">834 525 67 51</frame>
				<frame time="150">0 0 0 0</frame>
			</sprite> 
			
			<light pos="0 0" delay="1800">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="100" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="150" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="255 150 150 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>
		</scene>
		
		<scene name="scythe">
			<scene src="shared" />

			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>
			
			<!-- body fade in fade out -->
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="150">0 256 64 64</frame>
				<frame time="150">0 320 64 64</frame>
				<frame time="150">0 384 64 64</frame>
				<frame time="150">0 448 64 64</frame>
				<frame time="150">0 512 64 64</frame>
				<frame time="150">0 576 64 64</frame>
				<frame time="150">0 640 64 64</frame>	
				<frame time="2650">0 0 0 0</frame>	
				<frame time="150">0 640 64 64</frame>
				<frame time="150">0 576 64 64</frame>
				<frame time="150">0 512 64 64</frame>
			</sprite>
			
			<!-- face fade in -->
			<sprite origin="17 23" ulayer="3" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="600">0 0 0 0</frame>	
				<frame time="150">64 512 28 19</frame>
				<frame time="150">64 531 28 19</frame>
				<frame time="150">64 550 28 19</frame>
				<frame time="3250">0 0 0 0</frame>	
			</sprite>
				
			<!-- attack -->
			<sprite origin="52 70" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="1050">0 0 0 0</frame>
				<frame time="200">64 256 113 103</frame>
				<frame time="200">177 256 113 103</frame>
				<frame time="600">290 256 113 103</frame>
				<frame time="150">403 256 113 103</frame> <!-- castpoint 2200 -->
				<frame time="150">516 256 113 103</frame>
				<frame time="150">629 256 113 103</frame>
				<frame time="150">742 256 113 103</frame>
				<frame time="150">855 256 113 103</frame>
				<frame time="300">64 359 113 103</frame>
				<frame time="300">64 256 113 103</frame>
				<frame time="150">177 359 113 103</frame>
				<frame time="150">290 359 113 103</frame>
				<frame time="150">403 359 113 103</frame>
				<frame time="150">516 359 113 103</frame>
				<frame time="150">0 0 0 0</frame>
			</sprite>
			
			<light pos="0 -25" delay="2150">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="150" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="255 255 255 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>
			
		</scene>
		
		<scene name="scythe_intro">	
			<scene src="shared" />
			
			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>
			
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="2250">0 0 0 0</frame>	
				<frame time="150">0 640 64 64</frame>
				<frame time="150">0 576 64 64</frame>
				<frame time="150">0 512 64 64</frame>
			</sprite>
			
				
			<sprite origin="52 70" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="200">64 256 113 103</frame>
				<frame time="200">177 256 113 103</frame>
				<frame time="600">290 256 113 103</frame>
				<frame time="150">403 256 113 103</frame>
				<frame time="150">516 256 113 103</frame>
				<frame time="150">629 256 113 103</frame>
				<frame time="150">742 256 113 103</frame>
				<frame time="150">855 256 113 103</frame>
				<frame time="300">64 359 113 103</frame>
				<frame time="300">64 256 113 103</frame>
				<frame time="150">177 359 113 103</frame>
				<frame time="150">290 359 113 103</frame>
				<frame time="150">403 359 113 103</frame>
				<frame time="150">516 359 113 103</frame>
				<frame time="150">0 0 0 0</frame>
			</sprite>
			
			<light pos="0 -25" delay="850">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="200" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="150" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="255 255 255 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>
			
		</scene>
		
		<scene name="staff">
			<scene src="shared" />

			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>			
			
			<!-- Body fade in fade out-->
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="150">0 256 64 64</frame>
				<frame time="150">0 320 64 64</frame>
				<frame time="150">0 384 64 64</frame>
				<frame time="150">0 448 64 64</frame>
				<frame time="150">0 512 64 64</frame>
				<frame time="75">0 704 64 64</frame>
				<frame time="75">0 768 64 64</frame>
				<frame time="75">0 832 64 64</frame>
				<frame time="75">0 896 64 64</frame>	
				<frame time="2160">0 0 0 0</frame>
				<frame time="100">0 896 64 64</frame>
				<frame time="100">0 832 64 64</frame>
				<frame time="100">0 768 64 64</frame>
				<frame time="100">0 512 64 64</frame>
			</sprite>
			
			<!-- attack -->
			<sprite origin="31 63" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="1050">0 0 0 0</frame>
				<frame time="90">64 678 53 88</frame>
				<frame time="90">117 678 53 88</frame>
				<frame time="90">170 678 53 88</frame>
				<frame time="90">223 678 53 88</frame>
				<frame time="90">276 678 53 88</frame>
				<frame time="90">329 678 53 88</frame>
				<frame time="90">382 678 53 88</frame>
				<frame time="90">435 678 53 88</frame>
				<frame time="90">488 678 53 88</frame>
				<frame time="90">541 678 53 88</frame>
				<frame time="90">594 678 53 88</frame>
				<frame time="90">647 678 53 88</frame>
				<frame time="90">700 678 53 88</frame>
				<frame time="90">753 678 53 88</frame>
				<frame time="90">806 678 53 88</frame>
				<frame time="90">859 678 53 88</frame>
				<frame time="90">912 678 53 88</frame>		<!-- castpoint 3600 2580-->
				<frame time="90">64 766 53 88</frame>
				<frame time="90">117 766 53 88</frame>
				<frame time="90">170 766 53 88</frame>
				<frame time="90">223 766 53 88</frame>
				<frame time="90">276 766 53 88</frame>
				<frame time="90">329 766 53 88</frame>
				<frame time="90">382 766 53 88</frame>
			</sprite>
			
			<!-- attack effect -->
			<sprite origin="31 63" ulayer="5" looping="false" texture="./wraith.png" material="system/default.mats:bright-noxray">
				<frame time="1050">0 0 0 0</frame>
				<frame time="90">64 854 53 88</frame>
				<frame time="90">117 854 53 88</frame>
				<frame time="90">170 854 53 88</frame>
				<frame time="90">223 854 53 88</frame>
				<frame time="90">276 854 53 88</frame>
				<frame time="90">329 854 53 88</frame>
				<frame time="90">382 854 53 88</frame>
				<frame time="90">435 766 53 88</frame>
				<frame time="90">488 766 53 88</frame>
				<frame time="90">541 766 53 88</frame>
				<frame time="90">594 766 53 88</frame>
				<frame time="90">647 766 53 88</frame>
				<frame time="90">700 766 53 88</frame>
				<frame time="90">753 766 53 88</frame>
				<frame time="90">806 766 53 88</frame>
				<frame time="90">859 766 53 88</frame>
				<frame time="90">912 766 53 88</frame>
				<frame time="90">435 854 53 88</frame>
				<frame time="90">488 854 53 88</frame>
				<frame time="90">541 854 53 88</frame>
				<frame time="90">594 854 53 88</frame>
				<frame time="90">647 854 53 88</frame>
				<frame time="90">700 854 53 88</frame>
				<frame time="90">753 854 53 88</frame>
			</sprite>  

			<light pos="0 0" delay="2580">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="75" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="100 255 100 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>			
		</scene>
		
		<scene name="staff_intro">
			<scene src="shared" />
			
			<collision static="false">
				<circle offset="-2 0" radius="18" sensor="false" />
			</collision>
			
			<sprite origin="32 50" ulayer="1" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="1440">0 0 0 0</frame>	
				<frame time="100">0 896 64 64</frame>	
				<frame time="100">0 832 64 64</frame>	
				<frame time="100">0 768 64 64</frame>	
				<frame time="100">0 512 64 64</frame>	
			</sprite>
				
			<sprite origin="31 63" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">
				<frame time="90">488 678 53 88</frame>
				<frame time="90">541 678 53 88</frame>
				<frame time="90">594 678 53 88</frame>
				<frame time="90">647 678 53 88</frame>
				<frame time="90">700 678 53 88</frame>
				<frame time="90">753 678 53 88</frame>
				<frame time="90">806 678 53 88</frame>
				<frame time="90">859 678 53 88</frame>
				<frame time="90">912 678 53 88</frame>	<!-- castpoint 810 -->
				<frame time="90">64 766 53 88</frame>
				<frame time="90">117 766 53 88</frame>
				<frame time="90">170 766 53 88</frame>
				<frame time="90">223 766 53 88</frame>
				<frame time="90">276 766 53 88</frame>
				<frame time="90">329 766 53 88</frame>
				<frame time="90">382 766 53 88</frame>
			</sprite>
			
			
			<sprite origin="31 63" ulayer="5" looping="false" texture="./wraith.png" material="system/default.mats:bright-noxray">
				<frame time="90">488 766 53 88</frame>
				<frame time="90">541 766 53 88</frame>
				<frame time="90">594 766 53 88</frame>
				<frame time="90">647 766 53 88</frame>
				<frame time="90">700 766 53 88</frame>
				<frame time="90">753 766 53 88</frame>
				<frame time="90">806 766 53 88</frame>
				<frame time="90">859 766 53 88</frame>
				<frame time="90">912 766 53 88</frame>
				<frame time="90">435 854 53 88</frame>
				<frame time="90">488 854 53 88</frame>
				<frame time="90">541 854 53 88</frame>
				<frame time="90">594 854 53 88</frame>
				<frame time="90">647 854 53 88</frame>
				<frame time="90">700 854 53 88</frame>
				<frame time="90">753 854 53 88</frame>
			</sprite>  

			<light pos="0 0" delay="1500">
				<sprite texture="system/light_concentrated_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="50" />
				<overbright value="10" />
				<looping value="false" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="75" />
					<size value="0" />
				</sizes>
 				<colors>
					<color value="0 0 0 0" />
					<color value="100 255 100 0" />
					<color value="0 0 0 0" />
				</colors> 
			</light>			
		</scene>                

		<scene name="mage-portrait">	
			<sprite origin="10 10" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">					
				<frame time="75">757 641 20 20</frame>
			</sprite>			
		</scene>		

		<scene name="staff-portrait">	
			<sprite origin="10 10" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">					
				<frame time="75">189 713 20 20</frame>
			</sprite>			
		</scene>	
		
		<scene name="scythe-portrait">	
			<sprite origin="10 10" ulayer="0" looping="false" texture="./wraith.png" material="system/default.mats:actor">					
				<frame time="75">103 297 20 20</frame>
			</sprite>			
		</scene>		
	</scenes>                     
</unit>