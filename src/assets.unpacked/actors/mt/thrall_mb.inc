<unit netsync="position" slot="actor">
	<behavior class="Miniboss">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.thrall_mb</string>
%else
		<string name="beastiary-override">actors/mt/thrall_mb.unit</string>
%endif
		<vec2 name="beastiary-offset">0 10</vec2>
		<string name="quality">rare</string>
		<string name="dlc">mt</string>
	
		<string name="type">undead</string>
		<int name="hp">750</int>
		<int name="armor">50</int>
		<int name="resistance">30</int>
		<int name="experience-reward">250</int>
		<float name="mp-scale-fact">0.85</float>

		<int name="overhead-bossbar-width">16</int>
		<int name="unit-height">22</int>
		
		<string name="death-snd">event:/enemy/thrall_mb/death</string>
		<string name="gore">effects/gibs/gib_thrall_mb.sval</string>

		<float name="wind-scale">0.5</float>
		<bool name="ignore-hit-effects">true</bool>
		<bool name="impenetrable">true</bool>
		<int name="aggro-range">150</int>

%include "actors/extra/debuff_scaling_mb.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_no_respawn.inc"
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
				<string name="start-snd">event:/enemy/thrall_mb/groan</string>

				<int name="cooldown">250</int>
				<int name="castpoint">550</int>
				<int name="range">16</int>
				<int name="dmg-range">24</int>
				<int name="arc">160</int>
				
				<array name="effects">
					<dict name="effect">
						<string name="class">Damage</string>
						<int name="physical">60</int>
						<bool name="melee">true</bool>
					</dict>

					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/thrall/slash</string>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">Explode</string>
						<int name="radius">24</int>
						<int name="min-radius">24</int>
						<float name="self-dmg">1</float>
						<float name="team-dmg">1</float>
						<float name="enemy-dmg">0</float>

						<array name="effects">
							<dict name="effect">
								<string name="class">Decimate</string>
								<float name="amount-max">-0.1</float>
							</dict>
							<dict>
								<string name="class">SpawnEffect</string>
								<string name="effect">effects/players/lifesteal.effect</string>
							</dict>
						</array>
					</dict>
%endif
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">ranged 8</string>
				<string name="snd">event:/enemy/thrall_mb/attack</string>
				<string name="start-snd">event:/enemy/thrall_mb/groan</string>
				
				<int name="cooldown">SWIPECD</int>
				<int name="castpoint">550</int>
				<int name="range">45</int>
				<bool name="must-see">true</bool>
				<bool name="good-aim">false</bool>

				<dict name="action">
					<string name="class">HitscanSpreadFan</string>
					<bool name="penetrating">true</bool>
					<bool name="only-hit-targets-once">true</bool>
					<float name="team-dmg">0</float>
					<int name="rays">SWIPERAYS</int>
					<int name="spread">SWIPESPREAD</int>
					<float name="jitter">1</float>
					<bool name="miss-fx">true</bool>
					<string name="shoot-fx">actors/mt/projectiles/thrall_mb_cut.effect</string>
					
					<array name="effects">
						<dict>
							<string name="class">Damage</string>
							<int name="physical">50</int>
						</dict>
%if !NORMAL
						<dict>
							<string name="class">ApplyBuff</string>
							<string name="buff">actors/buffs.sval:vampire-bleeding</string>
						</dict>
%endif
						<dict>
							<string name="class">SpawnEffect</string>
							<string name="effect">actors/bosses/vampire/thrall_slash.effect</string>
						</dict>
					</array>
					
					<dict name="range">
						<int name="min">SWIPERANGEMIN</int>
						<int name="max">SWIPERANGEMAX</int>
					</dict>
				</dict>
			</dict>
			
			 <dict>
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:respawn_thrall_normal</string>
				<bool name="friendly">true</bool>
				<int name="freq">250</int>
				<int name="range">BUFFRANGE</int>
			</dict>
			
			 <dict>
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:respawn_thrall_pale</string>
				<bool name="friendly">true</bool>
				<int name="freq">250</int>
				<int name="range">BUFFRANGE</int>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/thrall_mb_corpse.unit</string>
					</dict>
				</array>
			</dict>
		</array>

		<bool name="hold-angle-on-cast">true</bool>

		<dict name="effect-params">
			<float name="height">3</float>
			<float name="arc">SWIPEARC</float>
			<!-- <float name="arc">1.047</float> -->
			<!-- <float name="arc">1.57</float> -->
		</dict>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="119 3 4 5"/>
		 	<sprite origin="4 4" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame>7 10 9 9</frame>
			</sprite>	
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="5" charge-through="true" density="20"/>
				<!-- <circle offset="0 -8" sensor="true" shoot-through="false" aim-through="true" radius="4" /> -->
			</collision>
		</scene>

		<scene name="shared-attack">
			%if GAME
			<effect src="effects/aim_arc.effect" />
			%endif
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="16 25" looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">0 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">32 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">64 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">96 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">128 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">160 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">192 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">224 0 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">0 32 32 32</frame>
				<frame time="250">0 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">32 32 32 32</frame>
				<frame time="250">32 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">64 32 32 32</frame>
				<frame time="250">64 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">96 32 32 32</frame>
				<frame time="250">96 64 32 32</frame>	
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">128 32 32 32</frame>
				<frame time="250">128 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">160 32 32 32</frame>
				<frame time="250">160 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">192 32 32 32</frame>
				<frame time="250">192 64 32 32</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="16 25"  looping="true" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="250">224 32 32 32</frame>
				<frame time="250">224 64 32 32</frame>	
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="attack-pos" pos="5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">0 96 32 32</frame>
				<frame time="100">0 128 32 32</frame>
				<frame time="200">0 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<locator name="attack-pos" pos="4 -7"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">32 96 32 32</frame>
				<frame time="100">32 128 32 32</frame>
				<frame time="200">32 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<locator name="attack-pos" pos="1 -6"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">64 96 32 32</frame>
				<frame time="100">64 128 32 32</frame>
				<frame time="200">64 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<locator name="attack-pos" pos="-4 -7"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">96 96 32 32</frame>
				<frame time="100">96 128 32 32</frame>
				<frame time="200">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<locator name="attack-pos" pos="-5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">128 96 32 32</frame>
				<frame time="100">128 128 32 32</frame>
				<frame time="200">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<locator name="attack-pos" pos="-5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">160 96 32 32</frame>
				<frame time="100">160 128 32 32</frame>
				<frame time="200">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<locator name="attack-pos" pos="0 -16"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">192 96 32 32</frame>
				<frame time="100">192 128 32 32</frame>
				<frame time="200">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<locator name="attack-pos" pos="5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="500">224 96 32 32</frame>
				<frame time="100">224 128 32 32</frame>
				<frame time="200">224 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-0">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">0 96 32 32</frame>
				<frame time="80">0 128 32 32</frame>
				<frame time="80">0 160 32 32</frame>
				<frame time="80">0 128 32 32</frame>
				<frame time="80">0 160 32 32</frame>
				<frame time="80">0 128 32 32</frame>
				<frame time="80">0 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-1">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="4 -7"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">32 96 32 32</frame>
				<frame time="80">32 128 32 32</frame>
				<frame time="80">32 160 32 32</frame>
				<frame time="80">32 128 32 32</frame>
				<frame time="80">32 160 32 32</frame>
				<frame time="80">32 128 32 32</frame>
				<frame time="80">32 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-2">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="1 -6"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">64 96 32 32</frame>
				<frame time="80">64 128 32 32</frame>
				<frame time="80">64 160 32 32</frame>
				<frame time="80">64 128 32 32</frame>
				<frame time="80">64 160 32 32</frame>
				<frame time="80">64 128 32 32</frame>
				<frame time="80">64 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-3">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="-4 -7"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">96 96 32 32</frame>
				<frame time="80">96 128 32 32</frame>
				<frame time="80">96 160 32 32</frame>
				<frame time="80">96 128 32 32</frame>
				<frame time="80">96 160 32 32</frame>
				<frame time="80">96 128 32 32</frame>
				<frame time="80">96 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-4">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="-5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">128 96 32 32</frame>
				<frame time="80">128 128 32 32</frame>
				<frame time="80">128 160 32 32</frame>
				<frame time="80">128 128 32 32</frame>
				<frame time="80">128 160 32 32</frame>
				<frame time="80">128 128 32 32</frame>
				<frame time="80">128 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-5">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="-5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">160 96 32 32</frame>
				<frame time="80">160 128 32 32</frame>
				<frame time="80">160 160 32 32</frame>
				<frame time="80">160 128 32 32</frame>
				<frame time="80">160 160 32 32</frame>
				<frame time="80">160 128 32 32</frame>
				<frame time="80">160 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-6">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="0 -16"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">192 96 32 32</frame>
				<frame time="80">192 128 32 32</frame>
				<frame time="80">192 160 32 32</frame>
				<frame time="80">192 128 32 32</frame>
				<frame time="80">192 160 32 32</frame>
				<frame time="80">192 128 32 32</frame>
				<frame time="80">192 160 32 32</frame>
			</sprite>
		</scene>

		<scene name="ranged-7">
			<scene src="shared" />
			<scene src="shared-attack" />
			<locator name="attack-pos" pos="5 -8"/>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="450">224 96 32 32</frame>
				<frame time="80">224 128 32 32</frame>
				<frame time="80">224 160 32 32</frame>
				<frame time="80">224 128 32 32</frame>
				<frame time="80">224 160 32 32</frame>
				<frame time="80">224 128 32 32</frame>
				<frame time="80">224 160 32 32</frame>
			</sprite>
		</scene>
	
		<scene name="death">
		 	<sprite origin="4 4" layer="-1" texture="doodads/special/shadows.png" material="system/default.mats:shadow">
				<frame>7 10 9 9</frame>
			</sprite>
			<sprite origin="16 25"  looping="false" texture="actors/mt/thrall_mb.png" material="system/default.mats:actor">
				<frame time="100">0 192 32 32</frame>
				<frame time="100">32 192 32 32</frame>
				<frame time="100">64 192 32 32</frame>
				<frame time="200">96 192 32 32</frame>
				<frame time="100">128 192 32 32</frame>
				<frame time="100">160 192 32 32</frame>
				<frame time="100">192 192 32 32</frame>
			</sprite>
		</scene>
	</scenes>
</unit>