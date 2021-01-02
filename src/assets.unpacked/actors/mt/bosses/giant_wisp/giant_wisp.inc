<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bosses.giant_wisp</string>
%else
		<string name="beastiary-override">actors/mt/bosses/giant_wisp/giant_wisp.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">2 5</vec2>
		<string name="quality">epic</string>
		<string name="dlc">mt</string>
	
		<string name="type">aberration</string>
		<int name="hp">4500</int>
		<int name="armor">40</int>
		<int name="resistance">50</int>
		<int name="experience-reward">2500</int>
		<float name="mp-scale-fact">1.25</float>
		<float name="ngp-scale">1.5</float>
		
		<string name="gore">effects/gibs/gib_iceblock.sval</string>
		<string name="death-snd">event:/misc/iceblock_break</string>
		<string name="loot">actors/loot.sval:boss_giant_wisp</string>

		<int name="aggro-range">1000</int>
		<float name="debuff-scale">0.5</float>
		<float name="wind-scale">0</float>
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">999</int>

		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_boss.inc"
		</array>

		<dict name="movement">
			<string name="class">MeleeMovement</string>
			<string name="anim-idle">idle</string>
			<string name="anim-walk">walk</string>
			
			<float name="speed">1.5</float>
			<int name="dist">80</int>
		</dict>

		<array name="skills">
			<!-- LINKS NOT BROKEN -->
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>links_broken</string>
				</array>

				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack</string>

				<int name="cooldown-start">1000</int>
				<int name="cooldown">BOMBCD</int>
				<int name="castpoint">900</int>
				<int name="min-range">0</int>
				<int name="range">50</int>
				<bool name="must-see">false</bool>
				
				<array name="start-actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/giant_wisp/giant_wisp_bomb.unit</string>
						<bool name="safe-spawn">false</bool>
					</dict>
				</array>
			</dict>
		
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>links_broken</string>
				</array>

				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack</string>
				<string name="start-snd">event:/enemy/boss_wisp/wisp_spawn</string>

				<int name="cooldown-start">1000</int>
				<int name="cooldown">WISPSPAWNCD</int>
				<int name="castpoint">1000</int>
				<int name="min-range">0</int>
				<int name="range">1000</int>
				<bool name="must-see">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectileFan</string>
						<string name="projectile">actors/mt/bosses/giant_wisp/wisp_spawn_projectile.unit</string>
						<int name="projectiles">WISPSPAWNNUM</int>
						<int name="dist">24</int>
						<int name="spread">60</int>
						<float name="jitter">5</float>
					</dict>
				</array>
			</dict>
			
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>links_broken</string>
					<string>hp</string><string>lt</string><float>0.8</float>
				</array>
			
				<string name="class">WhirlNovaSkill</string>
				<string name="anim">summon</string>
				<string name="start-snd">event:/enemy/boss_wisp/whirlwind</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">10000</int>
				<int name="castpoint">500</int>
				<int name="duration">2550</int>
				<int name="min-range">0</int>
				<int name="range">300</int>
				<bool name="must-see">false</bool>

				<string name="projectile">actors/mt/bosses/giant_wisp/giant_wisp_ice_projectile.unit</string>
				<float name="proj-dist">0</float>
				<int name="proj-delay">WHIRLPROJDELAY</int>
				<int name="per-revolution">17</int>
			</dict>
			
			<!-- LINKS BROKEN -->
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>links_broken</string>
				</array>

				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack-walk</string>

				<int name="cooldown">BOMBCDFREE</int>
				<int name="castpoint">900</int>
				<int name="min-range">0</int>
				<int name="range">50</int>
				<bool name="must-see">false</bool>
				
				<array name="start-actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/giant_wisp/giant_wisp_bomb.unit</string>
						<bool name="safe-spawn">false</bool>
					</dict>
				</array>
			</dict>
			
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>links_broken</string>
				</array>
			
				<string name="class">WhirlNovaSkill</string>
				<string name="anim">summon-walk</string>
				<string name="start-snd">event:/enemy/boss_wisp/whirlwind</string>
				
				<int name="cooldown-start">500</int>
				<int name="cooldown">4000</int>
				<int name="castpoint">500</int>
				<int name="duration">2550</int>
				<int name="min-range">0</int>
				<int name="range">300</int>
				<bool name="must-see">false</bool>

				<string name="projectile">actors/mt/bosses/giant_wisp/giant_wisp_ice_projectile.unit</string>
				<float name="proj-dist">0</float>
				<int name="proj-delay">WHIRLPROJDELAY</int>
				<int name="per-revolution">17</int>
			</dict>
			
			<dict>
				<array name="conditional">
					<string>flag</string><string>is</string><string>links_broken</string>
				</array>
			
				<string name="class">NovaSkill</string>
				<string name="anim">attack-walk</string>
				<string name="start-snd">event:/enemy/boss_wisp/wisp_spawn</string>
				
				<int name="cooldown-start">2500</int>
				<int name="cooldown">WISPSPAWNCDFREE</int>
				<int name="castpoint">1000</int>
				<int name="min-range">0</int>
				<int name="range">1000</int>
				<bool name="must-see">false</bool>
				
				<int name="proj-count">12</int>
				<float name="proj-dist">24</float>
				<string name="projectile">actors/mt/bosses/giant_wisp/wisp_spawn_projectile.unit</string>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bosses/giant_wisp/giant_wisp_corpse_bomb.unit</string>
					</dict>
				</array>
			</dict>
		</array>
		
	</behavior>

	<scenes start="idle">
		<scene name="shared">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
		</scene>

		<scene name="static-collision">
			<collision static="true">
				<circle sensor="false" shoot-through="false" aim-through="false" radius="22" density="10000"/>
			</collision>
		</scene>

		<scene name="walk-collision">
			<collision static="false">
				<circle sensor="false" shoot-through="false" aim-through="false" radius="22" density="10000"/>
			</collision>
		</scene>

		<scene name="idle">
			<scene src="shared" />
			<scene src="static-collision" />

			<effect src="./giant_wisp.effect" />
			<effect src="./giant_wisp_ice.effect" />
		</scene>
		
		<scene name="walk">
			<scene src="shared" />
			<scene src="walk-collision" />
			
			<collision static="false">
				<circle sensor="false" aim-through="false" radius="22" density="10000"/>
			</collision>
			
			<effect src="./giant_wisp_walk.effect" />
			<effect src="./giant_wisp_ice.effect" />
		</scene>
		
		<scene name="attack">
			<scene src="shared" />
			<scene src="static-collision" />
			
			<effect src="./giant_wisp_attack.effect" />
			<effect src="./giant_wisp_ice_attack.effect" />
		</scene>

		<scene name="summon">
			<scene src="shared" />
			<scene src="static-collision" />
			
			<effect src="./giant_wisp_summon.effect" />
			<effect src="./giant_wisp_ice_summon.effect" />
		</scene>

		<scene name="attack-walk">
			<scene src="shared" />
			<scene src="walk-collision" />
			
			<effect src="./giant_wisp_attack.effect" />
			<effect src="./giant_wisp_ice_attack.effect" />
		</scene>

		<scene name="summon-walk">
			<scene src="shared" />
			<scene src="walk-collision" />
			
			<effect src="./giant_wisp_summon.effect" />
			<effect src="./giant_wisp_ice_summon.effect" />
		</scene>

		<scene name="portrait">
			<sprite origin="24 24" looping="true" texture="./giant_wisp.png" material="system/default.mats:actor">
				<frame time="75">0 0 48 48</frame>
			</sprite>
		</scene>
	</scenes>
</unit>