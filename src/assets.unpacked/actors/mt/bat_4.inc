<unit netsync="position" slot="actor" layer="1000">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bat_4</string>
%else
		<string name="beastiary-override">actors/mt/bat_4.unit</string>
%endif
		<vec2 name="beastiary-offset">-1 -3</vec2>
		<string name="quality">common</string>
		<string name="dlc">mt</string>

		<string name="type">beast</string>
		<int name="hp">40</int>
		<int name="armor">5</int>
		<int name="resistance">5</int>
		<int name="experience-reward">20</int>
		
		<string name="death-snd">event:/enemy/bat/death</string>
		<string name="gore">effects/gibs/gib_bat_1.sval</string>
		
		<int name="aggro-range">150</int>
		<bool name="must-see-target">false</bool>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying.inc"
			<string>respawn_ghost</string>
			<string>respawn_thrall</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<bool name="flying">true</bool>
			<float name="speed">MSPEED</float>
			<float name="roaming">0.1</float>
			<int name="dist">10</int>
		</dict>

		<array name="skills">
<!-- %if !NORMAL -->
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">charge</string>
				
				<int name="cooldown">CHARGECD</int>
				<int name="hold-frame">210</int>
				
				<int name="range">60</int>
				<int name="min-range">30</int>

				<bool name="must-see">true</bool>
				
				<float name="speed">5</float>
				<int name="air-time">400</int>
				<int name="jump-height">0</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">3</int>
				<int name="ray-width">8</int>
				<float name="ray-length">4</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">20</int>
						<bool name="melee">true</bool>
					</dict>
				</array>
			</dict>
<!-- %endif -->

			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">0</int>
				<int name="castpoint">300</int>
				<int name="range">15</int>
				<int name="arc">90</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">20</int>
						<bool name="melee">true</bool>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:freezing</string>
					</dict>
%endif
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 1 1"/>
			<collision static="false">
				<circle offset="0 0" sensor="false" shoot-through="false" aim-through="true" radius="5" />
			</collision>
		</scene>

		<scene name="idle-0">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="250">39 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
				<frame time="250">65 0 13 16</frame>
				<frame time="250">52 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
		<scene src="shared" />
			<sprite origin="6 5" looping="true" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="150">0 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
				<frame time="150">26 0 13 16</frame>
				<frame time="150">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		<scene src="shared" />
			<sprite origin="6 5" looping="false" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">0 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">26 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
				<frame time="50">13 0 13 16</frame>
			</sprite>
		</scene>
		
		<scene name="charge">
			<scene src="shared" />
			<sprite origin="6 5" loopback="300" texture="actors/mt/bat_4.png" material="system/default.mats:actor">
				<frame time="30">0 0 13 16</frame>
				<frame time="30">13 0 13 16</frame>
				<frame time="30">26 0 13 16</frame>
				<frame time="30">13 0 13 16</frame>
				<frame time="30">0 0 13 16</frame>
				<frame time="30">13 0 13 16</frame>
				<frame time="30">26 0 13 16</frame>
				
				<frame time="100">26 0 13 16</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
