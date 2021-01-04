<unit layer="20" netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.ghost_paladin</string>
%else
		<string name="beastiary-override">actors/ghost_paladin.unit</string>
%endif
		<string name="quality">common</string>
	
		<string name="type">undead</string>
		<int name="hp">50</int>
		<int name="armor">20</int>
		<float name="evade-physical">EVASION</float>
		<int name="resistance">20</int>
		<int name="experience-reward">60</int>
		<float name="mp-scale-fact">0.2</float>

		<string name="death-snd">event:/enemy/ghost/death</string>
		<string name="gore">effects/gibs/gib_ghost.sval</string>
		<string name="evade-fx">actors/ghost_miss.effect</string>

		<int name="aggro-range">130</int>
		<bool name="must-see-target">false</bool>		

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_flying_ghost.inc"
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			
			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
			<int name="dist">12</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">100</int>
				<int name="castpoint">450</int>
				<int name="range">16</int>
				<int name="dmg-range">18</int>
				<int name="arc">90</int>
				
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="magical">50</int>
						<bool name="melee">true</bool>
					</dict>
					<dict name="effect">
						<string name="class">Decimate</string>
						<float name="mana-max">0.1</float>
					</dict>
				</array>
			</dict>
			
			%// NG+ Whirlwind
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">WhirlwindSkill</string>
				<string name="anim">whirlwind</string>

				<int name="cooldown">WHIRLCD</int>
				<int name="castpoint">480</int>
				
				<int name="range">75</int>
				
				<float name="acceleration">WHIRLACC</float>
				<float name="speed">WHIRLSPEED</float>
				<int name="duration">WHIRLDUR</int>
				<int name="freq">240</int>
				
				<dict name="effect">
					<string name="class">Explode</string>
					
					<int name="radius">14</int>
					<float name="dist-scaling">1000</float>
					
					<array name="effects">
						<dict>
							<string name="class">Damage</string>
							<int name="magical">15</int>
							<bool name="melee">true</bool>
						</dict>
						<dict name="effect">
							<string name="class">Decimate</string>
							<float name="mana-max">0.02</float>
						</dict>
					</array>
				</dict>
			</dict>

		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		
			<light pos="0 0">
				<sprite texture="system/light_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="250" />
				<overbright value="4" />
				<looping value="true" />
				<overlay value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="40" />
				</sizes>
				<colors>
					<color value="50 255 200 0" />
				</colors>
			</light>				
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">0 24 24 24</frame>
				<frame time="300">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">24 24 24 24</frame>
				<frame time="300">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">48 24 24 24</frame>
				<frame time="300">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">72 24 24 24</frame>
				<frame time="300">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">96 24 24 24</frame>
				<frame time="300">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">120 24 24 24</frame>
				<frame time="300">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">144 24 24 24</frame>
				<frame time="300">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="300">168 24 24 24</frame>
				<frame time="300">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">72 72 24 24</frame>
				<frame time="200">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="400">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
		
		<scene name="whirlwind">
			<scene src="shared" />
			<sprite origin="12 14" loopback="480" texture="actors/ghost_paladin.png" material="system/default.mats:glow-both-bright">
				<frame time="60">144 96 24 24</frame>
				<frame time="60">120 96 24 24</frame>
				<frame time="60">96 96 24 24</frame>
				<frame time="60">72 96 24 24</frame>
				<frame time="60">48 96 24 24</frame>
				<frame time="60">24 96 24 24</frame>
				<frame time="60">0 96 24 24</frame>
				<frame time="60">168 96 24 24</frame>
				
				<frame time="30">144 96 24 24</frame>
				<frame time="30">120 96 24 24</frame>
				<frame time="30">96 96 24 24</frame>
				<frame time="30">72 96 24 24</frame>
				<frame time="30">48 96 24 24</frame>
				<frame time="30">24 96 24 24</frame>
				<frame time="30">0 96 24 24</frame>
				<frame time="30">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>