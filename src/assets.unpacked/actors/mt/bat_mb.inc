<unit slot="actor" netsync="position">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bat_mb</string>
%else
		<string name="beastiary-override">actors/mt/bat_mb.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 8</vec2>
		<string name="quality">rare</string>
		<string name="dlc">mt</string>

		<string name="type">beast</string>
		<int name="hp">1400</int>
		<int name="armor">25</int>
		<int name="resistance">50</int>
		<int name="experience-reward">400</int>
		<float name="mp-scale-fact">0.85</float>
		
		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/bat_mb/death</string>
		<string name="gore">effects/gibs/gib_bat_mb.sval</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">150</int>
		<int name="unit-height">28</int>
		
%include "actors/extra/debuff_scaling_mb.inc"

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying.inc"
		</array>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">idle 8</string>

			<bool name="strafing">false</bool>
			<float name="speed">3.2</float>
			<int name="min-dist">50</int>
			<int name="dist">100</int>
		</dict>
		
		<array name="skills">
			<dict>
				<string name="class">SpewSkill</string>
				<string name="anim">idle 8</string>
				<string name="snd">event:/enemy/bat_mb/attack</string>
				<string name="offset">shoot-pos</string>
				
				<int name="cooldown-start">750</int>
				<int name="cooldown">SPEWCD</int>
				<int name="castpoint">850</int>
				<int name="duration">SPEWDUR</int>
				
				<int name="range">180</int>
				<int name="min-range">0</int>
				<int name="spread">SPEWSPREAD</int>
				<int name="rate">SPEWRATE</int>
				<bool name="good-aim">false</bool>
				<bool name="must-see">true</bool>
				<bool name="hold-dir">false</bool>
%if NORMAL
				<string name="projectile">actors/mt/projectiles/bat_mb_sonic_wave.unit</string>
%else
				<string name="projectile">actors/mt/projectiles/bat_mb_sonic_wave_ng.unit</string>
%endif
				
				<array name="actions">
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/mt/projectiles/bat_mb_sonic_muzzle.effect</string>
						<bool name="clone-owner-params">true</bool>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">charge 8</string>
				<string name="snd">event:/enemy/bat_mb/melee</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">CHARGECD</int>
				<int name="hold-frame">360</int>
				
				<int name="range">80</int>
				<bool name="must-see">true</bool>
				
				<float name="speed">CHARGESPEED</float>
				<int name="air-time">CHARGETIME</int>
				<int name="jump-height">0</int>
				<bool name="glide">false</bool>
				<int name="ray-num">4</int>
				<int name="ray-width">12</int>
				<float name="ray-length">3</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">80</int>
					</dict>
				</array>
			</dict>
		</array>	
		
		<dict name="effect-params"></dict>
	</behavior>

	<scenes>
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
			<collision static="false">
				<circle offset="0 -2" radius="8" sensor="false" shoot-through="false" aim-through="true" density="100"/>
			</collision>
			<sprite origin="9 10" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
                <frame>85 32 19 19</frame>
            </sprite>
		</scene>
		
		<scene name="shared-charge">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
			<collision static="false">
				<circle offset="0 -2" radius="8" sensor="false" shoot-through="false" aim-through="true" charging="true" density="100"/>
			</collision>
			<sprite origin="9 10" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
                <frame>85 32 19 19</frame>
            </sprite>
		</scene>
		
		<scene name="idle-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="9 -4" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">0 0 44 44</frame>
				<frame time="90">0 44 44 44</frame>
				<frame time="90">0 88 44 44</frame>
				<frame time="90">0 132 44 44</frame>
				<frame time="90">0 176 44 44</frame>
				<frame time="90">0 220 44 44</frame>
				<frame time="90">0 264 44 44</frame>
				<frame time="90">0 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-7">
			<scene src="shared" />
			<locator name="shoot-pos" pos="8 -14" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">44 0 44 44</frame>
				<frame time="90">44 44 44 44</frame>
				<frame time="90">44 88 44 44</frame>
				<frame time="90">44 132 44 44</frame>
				<frame time="90">44 176 44 44</frame>
				<frame time="90">44 220 44 44</frame>
				<frame time="90">44 264 44 44</frame>
				<frame time="90">44 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-6">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 -16" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">88 0 44 44</frame>
				<frame time="90">88 44 44 44</frame>
				<frame time="90">88 88 44 44</frame>
				<frame time="90">88 132 44 44</frame>
				<frame time="90">88 176 44 44</frame>
				<frame time="90">88 220 44 44</frame>
				<frame time="90">88 264 44 44</frame>
				<frame time="90">88 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-5">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-8 -14" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">132 0 44 44</frame>
				<frame time="90">132 44 44 44</frame>
				<frame time="90">132 88 44 44</frame>
				<frame time="90">132 132 44 44</frame>
				<frame time="90">132 176 44 44</frame>
				<frame time="90">132 220 44 44</frame>
				<frame time="90">132 264 44 44</frame>
				<frame time="90">132 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-4">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-9 -4" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">176 0 44 44</frame>
				<frame time="90">176 44 44 44</frame>
				<frame time="90">176 88 44 44</frame>
				<frame time="90">176 132 44 44</frame>
				<frame time="90">176 176 44 44</frame>
				<frame time="90">176 220 44 44</frame>
				<frame time="90">176 264 44 44</frame>
				<frame time="90">176 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-3">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-6 -1" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">220 0 44 44</frame>
				<frame time="90">220 44 44 44</frame>
				<frame time="90">220 88 44 44</frame>
				<frame time="90">220 132 44 44</frame>
				<frame time="90">220 176 44 44</frame>
				<frame time="90">220 220 44 44</frame>
				<frame time="90">220 264 44 44</frame>
				<frame time="90">220 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-2">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 -2" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">264 0 44 44</frame>
				<frame time="90">264 44 44 44</frame>
				<frame time="90">264 88 44 44</frame>
				<frame time="90">264 132 44 44</frame>
				<frame time="90">264 176 44 44</frame>
				<frame time="90">264 220 44 44</frame>
				<frame time="90">264 264 44 44</frame>
				<frame time="90">264 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="idle-1">
			<scene src="shared" />
			<locator name="shoot-pos" pos="6 -1" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">308 0 44 44</frame>
				<frame time="90">308 44 44 44</frame>
				<frame time="90">308 88 44 44</frame>
				<frame time="90">308 132 44 44</frame>
				<frame time="90">308 176 44 44</frame>
				<frame time="90">308 220 44 44</frame>
				<frame time="90">308 264 44 44</frame>
				<frame time="90">308 308 44 44</frame>
			</sprite>
		</scene>
		
		<scene name="charge-0">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="9 -4" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">0 0 44 44</frame>
				<frame time="30">0 44 44 44</frame>
				<frame time="30">0 88 44 44</frame>
				<frame time="30">0 132 44 44</frame>
				<frame time="30">0 176 44 44</frame>
				<frame time="30">0 220 44 44</frame>
				<frame time="30">0 264 44 44</frame>
				<frame time="30">0 308 44 44</frame>
				
				<frame time="30">0 0 44 44</frame>
				<frame time="30">0 44 44 44</frame>
				<frame time="30">0 88 44 44</frame>
				<frame time="30">0 132 44 44</frame>
				<frame time="150">0 176 44 44</frame>
				<frame time="150">0 220 44 44</frame>
				<frame time="150">0 264 44 44</frame>
				<frame time="150">0 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-7">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="8 -14" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">44 0 44 44</frame>
				<frame time="30">44 44 44 44</frame>
				<frame time="30">44 88 44 44</frame>
				<frame time="30">44 132 44 44</frame>
				<frame time="30">44 176 44 44</frame>
				<frame time="30">44 220 44 44</frame>
				<frame time="30">44 264 44 44</frame>
				<frame time="30">44 308 44 44</frame>
				
				<frame time="30">44 0 44 44</frame>
				<frame time="30">44 44 44 44</frame>
				<frame time="30">44 88 44 44</frame>
				<frame time="30">44 132 44 44</frame>
				<frame time="150">44 176 44 44</frame>
				<frame time="150">44 220 44 44</frame>
				<frame time="150">44 264 44 44</frame>
				<frame time="150">44 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-6">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="0 -16" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">88 0 44 44</frame>
				<frame time="30">88 44 44 44</frame>
				<frame time="30">88 88 44 44</frame>
				<frame time="30">88 132 44 44</frame>
				<frame time="30">88 176 44 44</frame>
				<frame time="30">88 220 44 44</frame>
				<frame time="30">88 264 44 44</frame>
				<frame time="30">88 308 44 44</frame>
				
				<frame time="30">88 0 44 44</frame>
				<frame time="30">88 44 44 44</frame>
				<frame time="30">88 88 44 44</frame>
				<frame time="30">88 132 44 44</frame>
				<frame time="150">88 176 44 44</frame>
				<frame time="150">88 220 44 44</frame>
				<frame time="150">88 264 44 44</frame>
				<frame time="150">88 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-5">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="-8 -14" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">132 0 44 44</frame>
				<frame time="30">132 44 44 44</frame>
				<frame time="30">132 88 44 44</frame>
				<frame time="30">132 132 44 44</frame>
				<frame time="30">132 176 44 44</frame>
				<frame time="30">132 220 44 44</frame>
				<frame time="30">132 264 44 44</frame>
				<frame time="30">132 308 44 44</frame>
				
				<frame time="30">132 0 44 44</frame>
				<frame time="30">132 44 44 44</frame>
				<frame time="30">132 88 44 44</frame>
				<frame time="30">132 132 44 44</frame>
				<frame time="150">132 176 44 44</frame>
				<frame time="150">132 220 44 44</frame>
				<frame time="150">132 264 44 44</frame>
				<frame time="150">132 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-4">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="-9 -4" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">176 0 44 44</frame>
				<frame time="30">176 44 44 44</frame>
				<frame time="30">176 88 44 44</frame>
				<frame time="30">176 132 44 44</frame>
				<frame time="30">176 176 44 44</frame>
				<frame time="30">176 220 44 44</frame>
				<frame time="30">176 264 44 44</frame>
				<frame time="30">176 308 44 44</frame>
				
				<frame time="30">176 0 44 44</frame>
				<frame time="30">176 44 44 44</frame>
				<frame time="30">176 88 44 44</frame>
				<frame time="30">176 132 44 44</frame>
				<frame time="150">176 176 44 44</frame>
				<frame time="150">176 220 44 44</frame>
				<frame time="150">176 264 44 44</frame>
				<frame time="150">176 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-3">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="-6 -1" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">220 0 44 44</frame>
				<frame time="30">220 44 44 44</frame>
				<frame time="30">220 88 44 44</frame>
				<frame time="30">220 132 44 44</frame>
				<frame time="30">220 176 44 44</frame>
				<frame time="30">220 220 44 44</frame>
				<frame time="30">220 264 44 44</frame>
				<frame time="30">220 308 44 44</frame>
				
				<frame time="30">220 0 44 44</frame>
				<frame time="30">220 44 44 44</frame>
				<frame time="30">220 88 44 44</frame>
				<frame time="30">220 132 44 44</frame>
				<frame time="150">220 176 44 44</frame>
				<frame time="150">220 220 44 44</frame>
				<frame time="150">220 264 44 44</frame>
				<frame time="150">220 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-2">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="0 -2" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">264 0 44 44</frame>
				<frame time="30">264 44 44 44</frame>
				<frame time="30">264 88 44 44</frame>
				<frame time="30">264 132 44 44</frame>
				<frame time="30">264 176 44 44</frame>
				<frame time="30">264 220 44 44</frame>
				<frame time="30">264 264 44 44</frame>
				<frame time="30">264 308 44 44</frame>
				
				<frame time="30">264 0 44 44</frame>
				<frame time="30">264 44 44 44</frame>
				<frame time="30">264 88 44 44</frame>
				<frame time="30">264 132 44 44</frame>
				<frame time="150">264 176 44 44</frame>
				<frame time="150">264 220 44 44</frame>
				<frame time="150">264 264 44 44</frame>
				<frame time="150">264 308 44 44</frame>
			</sprite>
		</scene>
		<scene name="charge-1">
			<scene src="shared-charge" />
			<locator name="shoot-pos" pos="6 -1" />
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="30">308 0 44 44</frame>
				<frame time="30">308 44 44 44</frame>
				<frame time="30">308 88 44 44</frame>
				<frame time="30">308 132 44 44</frame>
				<frame time="30">308 176 44 44</frame>
				<frame time="30">308 220 44 44</frame>
				<frame time="30">308 264 44 44</frame>
				<frame time="30">308 308 44 44</frame>
				
				<frame time="30">308 0 44 44</frame>
				<frame time="30">308 44 44 44</frame>
				<frame time="30">308 88 44 44</frame>
				<frame time="30">308 132 44 44</frame>
				<frame time="150">308 176 44 44</frame>
				<frame time="150">308 220 44 44</frame>
				<frame time="150">308 264 44 44</frame>
				<frame time="150">308 308 44 44</frame>
			</sprite>
		</scene>

		<scene name="portrait">
			<sprite origin="22 37" texture="actors/mt/bat_mb.png" material="system/default.mats:actor">
				<frame time="90">220 220 44 44</frame>
			</sprite>
		</scene>
	</scenes>
</unit>