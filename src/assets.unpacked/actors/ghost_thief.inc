<unit layer="20" netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.ghost_thief</string>
%else
		<string name="beastiary-override">actors/ghost_thief.unit</string>
%endif
		<string name="quality">common</string>
	
		<string name="type">undead</string>
		<int name="hp">50</int>
		<int name="armor">20</int>
		<float name="evade-physical">EVASION</float>
		<int name="resistance">20</int>
		<int name="experience-reward">65</int>
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
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<bool name="flying">true</bool>
			<float name="speed">MOVESPEED</float>
			<int name="min-dist">60</int>
			<int name="dist">90</int>
			<int name="stagger-threshold">0</int>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/ghost/knives</string>

				<int name="cooldown">KNIVESCD</int>
				<int name="castpoint">400</int>
				<int name="min-range">40</int>
				<int name="range">125</int>
				<bool name="good-aim">GOODAIM</bool>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">PROJECTILENUM</int>
						<int name="spread">PROJECTILESPREAD</int>
						<string name="projectile">actors/projectiles/ghost_dagger.unit</string>
					</dict>
				</array>
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
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">0 24 24 24</frame>
				<frame time="300">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">24 24 24 24</frame>
				<frame time="300">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">48 24 24 24</frame>
				<frame time="300">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">72 24 24 24</frame>
				<frame time="300">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">96 24 24 24</frame>
				<frame time="300">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">120 24 24 24</frame>
				<frame time="300">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">144 24 24 24</frame>
				<frame time="300">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="300">168 24 24 24</frame>
				<frame time="300">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">0 72 24 24</frame>
				<frame time="200">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">24 72 24 24</frame>
				<frame time="200">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">48 72 24 24</frame>
				<frame time="200">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">72 72 24 24</frame>
				<frame time="200">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">96 72 24 24</frame>
				<frame time="200">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">120 72 24 24</frame>
				<frame time="200">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">144 72 24 24</frame>
				<frame time="200">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/ghost_thief.png" material="system/default.mats:glow-both-bright">
				<frame time="400">168 72 24 24</frame>
				<frame time="200">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
