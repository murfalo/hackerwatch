<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
		<string name="beastiary-override">actors/bosses/vampire/thrall.unit</string>
		<string name="type">undead</string>
		<int name="hp">130</int>
		<int name="armor">5</int>
		<int name="resistance">20</int>
		<int name="experience-reward">45</int>
		<float name="mp-scale-fact">0.1</float>
		
		<string name="death-snd">event:/enemy/thrall/death</string>
		<string name="gore">effects/gibs/gib_thrall.sval</string>
		
		<int name="aggro-range">130</int>
		
%include "actors/extra/debuff_scaling_normal.inc"

		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
			<string>respawn_thrall_pale</string>
		</array>

		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">EnemyMeleeStrike</string>
				<string name="anim">attack 8</string>

				<int name="cooldown">50</int>
				<int name="castpoint">400</int>
				<int name="range">16</int>
				<int name="dmg-range">20</int>
				<int name="arc">160</int>
				
				<array name="effects">
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">50</int>
						<float name="armor-mul">0.95</float>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/bosses/vampire/thrall_slash.effect</string>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/thrall/slash</string>
					</dict>
				</array>
			</dict>
			
%if !NORMAL
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">CHARGECD</int>
				
				<array name="effects">
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/buffs.sval:vampire-rage</string>
						<bool name="target-self">true</bool>
					</dict>
				</array>
			</dict>
%endif
		</array>
	</behavior>
	
	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="118 0 2 2"/>
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="250">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">0 32 32 32</frame>
				<frame time="150">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">32 32 32 32</frame>
				<frame time="150">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">64 32 32 32</frame>
				<frame time="150">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">96 32 32 32</frame>
				<frame time="150">96 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">128 32 32 32</frame>
				<frame time="150">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">160 32 32 32</frame>
				<frame time="150">160 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">192 32 32 32</frame>
				<frame time="150">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="150">224 32 32 32</frame>
				<frame time="150">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">0 96 32 32</frame>
				<frame time="200">0 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">32 96 32 32</frame>
				<frame time="200">32 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">64 96 32 32</frame>
				<frame time="200">64 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">96 96 32 32</frame>
				<frame time="200">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">128 96 32 32</frame>
				<frame time="200">128 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">160 96 32 32</frame>
				<frame time="200">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">192 96 32 32</frame>
				<frame time="200">192 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall.png" material="system/default.mats:actor">
				<frame time="400">224 96 32 32</frame>
				<frame time="200">224 128 32 32</frame>
			</sprite>
		</scene>
  </scenes>
</unit>