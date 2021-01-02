<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.lich_frost</string>
%else
		<string name="beastiary-override">actors/lich_frost.unit</string>
%endif
		<vec2 name="beastiary-offset">0 2</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">undead</string>
		<int name="hp">250</int>
		<int name="armor">30</int>
		<int name="resistance">80</int>
		<int name="experience-reward">105</int>
		<float name="mp-scale-fact">0.65</float>

		<float name="evade-magical">EVASION</float>
		<string name="evade-fx">effects/mana_shield.effect</string>
		
		<string name="death-snd">event:/enemy/lich/death</string>
		<string name="gore">effects/gibs/gib_lich_1.sval</string>
		<string name="loot">actors/loot.sval:lich_frost</string>

		<int name="aggro-range">130</int>

%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_paladin</string>
			<string>freezing</string>
		</array>
		
		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">1.6</float>
			<int name="min-dist">40</int>
			<int name="dist">100</int>
		</dict>

		<array name="skills">
			%// Frost Fan
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/lich_frost/shoot</string>

				<int name="cooldown-start">500</int>
				<int name="cooldown">1750</int>
				<int name="castpoint">500</int>
				<int name="range">140</int>
				<int name="min-range">50</int>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<int name="projectiles">FANNUM</int>
						<int name="spread">FANSPREAD</int>
						<string name="projectile">actors/projectiles/lich_frost_shard.unit</string>
					</dict>
				</array>
			</dict>
			
			%// Breath
			<dict>
				<string name="class">SpewSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">shoot-pos</string>
				<string name="first-fire-snd">event:/enemy/lich_frost/breath</string>
				
				<bool name="must-see">true</bool>
				<bool name="hold-dir">false</bool>
				<int name="cooldown">2000</int>
				<int name="castpoint">500</int>
				<int name="duration">1500</int>
				
				<int name="range">SPEWRANGE</int>
				<int name="spread">SPEWSPREAD</int>
				<int name="rate">SPEWRATE</int>

				<string name="projectile">SPEWPROJECTILE</string>
			</dict>
			
			%// NG+2 Area
			<dict>
				<array name="conditional">
					<string>ngp</string><string>ge</string><int>2</int>
				</array>
			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				
				<bool name="must-see">false</bool>		
				<int name="cooldown">3000</int>	
				<int name="castpoint">500</int>
				<int name="min-range">40</int>
				<int name="range">120</int>
				<bool name="good-aim">true</bool>	
				
				<dict name="action">
					<string name="class">DummyHitscan</string>
					
					<array name="effects">
						<dict>
							<string name="class">SpawnUnit</string>
							<string name="unit">actors/projectiles/lich_frost_area.unit</string>
							<bool name="safe-spawn">false</bool>
							<int name="spawn-dist">0</int>
						</dict>
					</array>
				</dict>
			</dict>
			
			%// Blink
			<dict>
				<string name="class">BlinkSkill</string>
				<string name="anim">attack 8</string>
				<string name="snd">event:/enemy/lich/blink</string>
				<string name="fx">effects/blink.effect</string>
				
				<int name="cooldown-start">3500</int>
				<int name="cooldown">BLINKCD</int>
				<int name="castpoint">500</int>

				<int name="spread">30</int>
				<float name="off-distance">5</float>
				<int name="range">40</int>
				<float name="distance">-80</float>

				<array name="blink-effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:blink-stop-ranged</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" charge-through="true" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">0 24 24 24</frame>
				<frame time="125">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">24 24 24 24</frame>
				<frame time="125">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">48 24 24 24</frame>
				<frame time="125">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">72 24 24 24</frame>
				<frame time="125">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">96 24 24 24</frame>
				<frame time="125">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">120 24 24 24</frame>
				<frame time="125">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">144 24 24 24</frame>
				<frame time="125">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="125">168 24 24 24</frame>
				<frame time="125">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">0 72 24 24</frame>
				<frame time="500">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">24 72 24 24</frame>
				<frame time="500">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">48 72 24 24</frame>
				<frame time="500">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">72 72 24 24</frame>
				<frame time="500">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">96 72 24 24</frame>
				<frame time="500">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">120 72 24 24</frame>
				<frame time="500">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">144 72 24 24</frame>
				<frame time="500">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/lich_frost.png" material="system/default.mats:actor">
				<frame time="500">168 72 24 24</frame>
				<frame time="500">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>