<unit netsync="position" slot="actor" layer="20">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.gargoyle_1</string>
%else
		<string name="beastiary-override">actors/gargoyle_1.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 13</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">beast</string>
		<int name="hp">1100</int>
		<int name="armor">70</int>
		<int name="resistance">70</int>
		<int name="experience-reward">125</int>
		<float name="mp-scale-fact">0.65</float>
		
		<int name="unit-height">28</int>
		
		<string name="death-snd">event:/enemy/gargoyle/death</string>
		<string name="gore">effects/gibs/gib_gargoyle.sval</string>
		
		<int name="aggro-range">150</int>
		<float name="wind-scale">0.5</float>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying.inc"
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">idle 8</string>

			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
		</dict>

		<array name="skills">
			%// Melee
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">50</int>
				<int name="castpoint">400</int>
				<int name="range">20</int>
				<int name="dmg-range">24</int>
				<int name="arc">160</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">75</int>
						<float name="armor-mul">0.8</float>
						<bool name="melee">true</bool>
					</dict>
				</array>
			</dict>
			
			%// Ranged
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">ranged 8</string>
				<string name="snd">event:/enemy/sentinel/shoot</string>

				<int name="cooldown">1000</int>
				<int name="castpoint">400</int>
				<int name="min-range">60</int>
				<int name="range">175</int>
				<bool name="good-aim">false</bool>
				<float name="aim-interception">12</float>
				<string name="offset">shoot-pos</string>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<string name="projectile">actors/projectiles/trident.unit</string>
						<int name="projectiles">PROJECTILENUM</int>
						<int name="spread">PROJECTILESPREAD</int>
					</dict>
				</array>
			</dict>

			%// Charge
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">ChargeStrike</string>
				<string name="anim">charge 8</string>
				
				<int name="cooldown-start">250</int>
				<int name="cooldown">CHARGECD</int>
				<int name="hold-frame">400</int>
				
				<int name="min-range">30</int>
				<int name="range">40</int>
				
				<float name="speed">5</float>
				<int name="air-time">400</int>
				<int name="jump-height">0</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">4</int>
				<int name="ray-width">14</int>
				<float name="ray-length">5</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">75</int>
						<float name="armor-mul">0.8</float>
					</dict>
				</array>
			</dict>
		</array>
		
		<bool name="hold-angle-on-cast">true</bool>
		<dict name="effect-params" />
		
	</behavior>

	<scenes start="idle-0 idle-7 idle-6 idle-5 idle-4 idle-3 idle-2 idle-1">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6"/>
				<circle offset="0 -10" sensor="true" shoot-through="false" aim-through="true" radius="6" />
			</collision>
		</scene>

		<scene name="shared-charge">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="6"/>
				<circle offset="0 -10" sensor="true" shoot-through="false" aim-through="true" charging="true" radius="6" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">0 0 48 48</frame>
				<frame time="100">0 48 48 48</frame>
				<frame time="100">0 96 48 48</frame>
				<frame time="100">0 144 48 48</frame>
				<frame time="100">0 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">48 0 48 48</frame>
				<frame time="100">48 48 48 48</frame>
				<frame time="100">48 96 48 48</frame>
				<frame time="100">48 144 48 48</frame>
				<frame time="100">48 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">96 0 48 48</frame>
				<frame time="100">96 48 48 48</frame>
				<frame time="100">96 96 48 48</frame>
				<frame time="100">96 144 48 48</frame>
				<frame time="100">96 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">144 0 48 48</frame>
				<frame time="100">144 48 48 48</frame>
				<frame time="100">144 96 48 48</frame>
				<frame time="100">144 144 48 48</frame>
				<frame time="100">144 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">192 0 48 48</frame>
				<frame time="100">192 48 48 48</frame>
				<frame time="100">192 96 48 48</frame>
				<frame time="100">192 144 48 48</frame>
				<frame time="100">192 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">240 0 48 48</frame>
				<frame time="100">240 48 48 48</frame>
				<frame time="100">240 96 48 48</frame>
				<frame time="100">240 144 48 48</frame>
				<frame time="100">240 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">288 0 48 48</frame>
				<frame time="100">288 48 48 48</frame>
				<frame time="100">288 96 48 48</frame>
				<frame time="100">288 144 48 48</frame>
				<frame time="100">288 192 48 48</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">336 0 48 48</frame>
				<frame time="100">336 48 48 48</frame>
				<frame time="100">336 96 48 48</frame>
				<frame time="100">336 144 48 48</frame>
				<frame time="100">336 192 48 48</frame>
			</sprite>
		</scene>	
		
		<scene name="attack-0">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">0 240 48 48</frame>
				<frame time="100">0 288 48 48</frame>
				<frame time="100">0 336 48 48</frame>
				<frame time="100">0 384 48 48</frame>
				<frame time="100">0 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">48 240 48 48</frame>
				<frame time="100">48 288 48 48</frame>
				<frame time="100">48 336 48 48</frame>
				<frame time="100">48 384 48 48</frame>
				<frame time="100">48 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">96 240 48 48</frame>
				<frame time="100">96 288 48 48</frame>
				<frame time="100">96 336 48 48</frame>
				<frame time="100">96 384 48 48</frame>
				<frame time="100">96 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">144 240 48 48</frame>
				<frame time="100">144 288 48 48</frame>
				<frame time="100">144 336 48 48</frame>
				<frame time="100">144 384 48 48</frame>
				<frame time="100">144 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">192 240 48 48</frame>
				<frame time="100">192 288 48 48</frame>
				<frame time="100">192 336 48 48</frame>
				<frame time="100">192 384 48 48</frame>
				<frame time="100">192 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">240 240 48 48</frame>
				<frame time="100">240 288 48 48</frame>
				<frame time="100">240 336 48 48</frame>
				<frame time="100">240 384 48 48</frame>
				<frame time="100">240 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">288 240 48 48</frame>
				<frame time="100">288 288 48 48</frame>
				<frame time="100">288 336 48 48</frame>
				<frame time="100">288 384 48 48</frame>
				<frame time="100">288 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />			
			<effect delay="400" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">336 240 48 48</frame>
				<frame time="100">336 288 48 48</frame>
				<frame time="100">336 336 48 48</frame>
				<frame time="100">336 384 48 48</frame>
				<frame time="100">336 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-0">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">0 240 48 48</frame>
				<frame time="100">0 288 48 48</frame>
				<frame time="100">0 336 48 48</frame>
				<frame time="100">0 384 48 48</frame>
				<frame time="200">0 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-7">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">48 240 48 48</frame>
				<frame time="100">48 288 48 48</frame>
				<frame time="100">48 336 48 48</frame>
				<frame time="100">48 384 48 48</frame>
				<frame time="200">48 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-6">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">96 240 48 48</frame>
				<frame time="100">96 288 48 48</frame>
				<frame time="100">96 336 48 48</frame>
				<frame time="100">96 384 48 48</frame>
				<frame time="200">96 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-5">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">144 240 48 48</frame>
				<frame time="100">144 288 48 48</frame>
				<frame time="100">144 336 48 48</frame>
				<frame time="100">144 384 48 48</frame>
				<frame time="200">144 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-4">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">192 240 48 48</frame>
				<frame time="100">192 288 48 48</frame>
				<frame time="100">192 336 48 48</frame>
				<frame time="100">192 384 48 48</frame>
				<frame time="200">192 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-3">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">240 240 48 48</frame>
				<frame time="100">240 288 48 48</frame>
				<frame time="100">240 336 48 48</frame>
				<frame time="100">240 384 48 48</frame>
				<frame time="200">240 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-2">
			<scene src="shared-charge" />
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">288 240 48 48</frame>
				<frame time="100">288 288 48 48</frame>
				<frame time="100">288 336 48 48</frame>
				<frame time="100">288 384 48 48</frame>
				<frame time="200">288 432 48 48</frame>
			</sprite>
		</scene>

		<scene name="charge-1">
			<scene src="shared-charge" />			
			<effect delay="500" src="effects/gargoyle_attack_slash.effect" />
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">336 240 48 48</frame>
				<frame time="100">336 288 48 48</frame>
				<frame time="100">336 336 48 48</frame>
				<frame time="100">336 384 48 48</frame>
				<frame time="200">336 432 48 48</frame>
			</sprite>
		</scene>
		
		<scene name="ranged-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="10 0"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">0 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">0 240 48 48</frame>
				<frame time="100">0 288 48 48</frame>
				<frame time="100">0 336 48 48</frame>
				<frame time="100">0 384 48 48</frame>
				<frame time="100">0 432 48 48</frame>
			</sprite>
			<effect pos="10 0" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-7">
			<scene src="shared" />
			<locator name="shoot-pos" pos="13 -13"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">48 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">48 240 48 48</frame>
				<frame time="100">48 288 48 48</frame>
				<frame time="100">48 336 48 48</frame>
				<frame time="100">48 384 48 48</frame>
				<frame time="100">48 432 48 48</frame>
			</sprite>
			<effect pos="13 -13" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-6">
			<scene src="shared" />
			<locator name="shoot-pos" pos="8 -25"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">96 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">96 240 48 48</frame>
				<frame time="100">96 288 48 48</frame>
				<frame time="100">96 336 48 48</frame>
				<frame time="100">96 384 48 48</frame>
				<frame time="100">96 432 48 48</frame>
			</sprite>
			<effect pos="8 -25" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-5">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-4 -25"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">144 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">144 240 48 48</frame>
				<frame time="100">144 288 48 48</frame>
				<frame time="100">144 336 48 48</frame>
				<frame time="100">144 384 48 48</frame>
				<frame time="100">144 432 48 48</frame>
			</sprite>
			<effect pos="-4 -25" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-4">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-18 -18"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">192 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">192 240 48 48</frame>
				<frame time="100">192 288 48 48</frame>
				<frame time="100">192 336 48 48</frame>
				<frame time="100">192 384 48 48</frame>
				<frame time="100">192 432 48 48</frame>
			</sprite>
			<effect pos="-18 -18" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-3">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-17 -5"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">240 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">240 240 48 48</frame>
				<frame time="100">240 288 48 48</frame>
				<frame time="100">240 336 48 48</frame>
				<frame time="100">240 384 48 48</frame>
				<frame time="100">240 432 48 48</frame>
			</sprite>
			<effect pos="-17 -5" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-2">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-8 17"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">288 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">288 240 48 48</frame>
				<frame time="100">288 288 48 48</frame>
				<frame time="100">288 336 48 48</frame>
				<frame time="100">288 384 48 48</frame>
				<frame time="100">288 432 48 48</frame>
			</sprite>
			<effect pos="-8 17" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="ranged-1">
			<scene src="shared" />	
			<locator name="shoot-pos" pos="11 11"/>
			<sprite ulayer="1" origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">336 480 48 32</frame>
				<frame time="50">0 0 0 0</frame>
			</sprite>		
			<sprite origin="24 36" looping="false" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="400">336 240 48 48</frame>
				<frame time="100">336 288 48 48</frame>
				<frame time="100">336 336 48 48</frame>
				<frame time="100">336 384 48 48</frame>
				<frame time="100">336 432 48 48</frame>
			</sprite>
			<effect pos="11 11" src="actors/projectiles/trident_light.effect" />
		</scene>

		<scene name="portrait">
			<scene src="shared" />
			<sprite origin="24 36" looping="true" texture="actors/gargoyle_1.png" material="system/default.mats:actor">
				<frame time="100">240 0 48 48</frame>
			</sprite>
		</scene>
	</scenes>
</unit>