<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
		<string name="beastiary-override">actors/bosses/vampire/thrall_leaper.unit</string>
	
		<string name="type">undead</string>
		<int name="hp">110</int>
		<int name="armor">5</int>
		<int name="resistance">20</int>
		<int name="experience-reward">60</int>
		<float name="mp-scale-fact">0.2</float>
		
		<string name="death-snd">event:/enemy/thrall/death</string>
		<string name="gore">effects/gibs/gib_thrall_pale.sval</string>
		
		<int name="aggro-range">130</int>
		
%include "actors/extra/debuff_scaling_normal.inc"
		
		<array name="buffs-immune-tags">
			<string>respawn_ghost</string>
			<string>respawn_thrall_normal</string>
		</array>

		<dict name="movement">
			<string name="class">MeleeMovement</string>
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
			
			<dict>
				<string name="class">ChargeStrike</string>
				<string name="anim">jump 8</string>
				
				<bool name="must-see">true</bool>
				<int name="cooldown">CHARGECD</int>
				<int name="range">38</int>
				<int name="min-range">26</int>
				
				<int name="hold-frame">150</int>
				<float name="speed">6</float>
				<int name="air-time">250</int>
				<int name="jump-height">0</int>
				<bool name="glide">false</bool>
				
				<int name="ray-num">3</int>
				<int name="ray-width">6</int>
				<float name="ray-length">2</float>

				<array name="effects">
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">35</int>
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
				<int name="cooldown">RAGECD</int>
				
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
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="250">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">0 32 32 32</frame>
				<frame time="150">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">32 32 32 32</frame>
				<frame time="150">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">64 32 32 32</frame>
				<frame time="150">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">96 32 32 32</frame>
				<frame time="150">96 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">128 32 32 32</frame>
				<frame time="150">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">160 32 32 32</frame>
				<frame time="150">160 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">192 32 32 32</frame>
				<frame time="150">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 24" looping="true" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">224 32 32 32</frame>
				<frame time="150">224 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">0 96 32 32</frame>
				<frame time="200">0 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">32 96 32 32</frame>
				<frame time="200">32 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">64 96 32 32</frame>
				<frame time="200">64 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">96 96 32 32</frame>
				<frame time="200">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">128 96 32 32</frame>
				<frame time="200">128 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">160 96 32 32</frame>
				<frame time="200">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">192 96 32 32</frame>
				<frame time="200">192 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="350">224 96 32 32</frame>
				<frame time="200">224 128 32 32</frame>
			</sprite>
		</scene>
		
		<scene name="jump-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">0 96 32 32</frame>
				<frame time="250">0 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">32 96 32 32</frame>
				<frame time="250">32 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">64 96 32 32</frame>
				<frame time="250">64 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 -6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">96 96 32 32</frame>
				<frame time="250">96 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-8 0"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">128 96 32 32</frame>
				<frame time="250">128 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">160 96 32 32</frame>
				<frame time="250">160 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 8"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">192 96 32 32</frame>
				<frame time="250">192 128 32 32</frame>
			</sprite>
		</scene>

		<scene name="jump-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="6 6"/>
			<sprite origin="16 24" looping="false" texture="actors/mt/thrall_pale.png" material="system/default.mats:actor">
				<frame time="150">224 96 32 32</frame>
				<frame time="250">224 128 32 32</frame>
			</sprite>
		</scene>
  </scenes>
</unit>