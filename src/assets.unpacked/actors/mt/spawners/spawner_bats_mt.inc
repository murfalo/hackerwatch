<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.spawner_bats_mt</string>
%else
		<string name="beastiary-override">actors/mt/spawners/spawner_bats_mt.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">-1 3</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>

		<string name="type">construct</string>
		<int name="hp">200</int>
		<int name="armor">40</int>
		<int name="resistance">15</int>
		<int name="experience-reward">55</int>
		<float name="mp-scale-fact">1</float>
		
		<string name="gore">effects/gibs/gib_bat_spawner.sval</string>
		<string name="death-snd">event:/enemy/bat/death_spawner</string>
		<string name="loot">actors/loot.sval:spawner_bats_mt</string>

		<bool name="impenetrable">true</bool>
		<int name="aggro-range">130</int>
		<float name="debuff-scale">0.5</float>
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>
		
		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">default</string>
		</dict>

		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">default</string>
				
				<int name="charges">SPAWNCHARGES</int>
				<int name="cooldown">SPAWNCD</int>
				<int name="range">210</int>
				<bool name="must-see">true</bool>

				<dict name="action">
					<string name="class">SpawnUnit</string>
					<array name="units">
						<int>1000</int><string>actors/mt/bat_4.unit</string>
					</array>
					<bool name="aggro">true</bool>
					<bool name="safe-spawn">false</bool>
					<int name="spawn-dist">12</int>
				</dict>
			</dict>
			
%if !NORMAL
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDamaged</string>

				<int name="cooldown">SPAWNCD</int>
				<int name="charges">SPAWNCHARGES</int>
				
				<dict name="action">
					<string name="class">SpawnUnit</string>
					<array name="units">
						<int>1000</int><string>actors/mt/bat_4.unit</string>
					</array>
					<bool name="aggro">true</bool>
					<bool name="safe-spawn">false</bool>
					<int name="spawn-dist">16</int>
				</dict>
			</dict>
%endif

			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/spawners/spawner_bats_mt_razed.unit</string>
					</dict>
%if !NORMAL
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/bat/swarm</string>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<vec2 name="jitter">8 8</vec2>
						<bool name="aggro">true</bool>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<vec2 name="jitter">8 8</vec2>
						<bool name="aggro">true</bool>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<vec2 name="jitter">8 8</vec2>
						<bool name="aggro">true</bool>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<vec2 name="jitter">8 8</vec2>
						<bool name="aggro">true</bool>
					</dict>

					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/mt/bat_4.unit</string>
						<vec2 name="jitter">8 8</vec2>
						<bool name="aggro">true</bool>
					</dict>
%endif
				</array>
			</dict>
		</array>
	</behavior>

	<scenes>
		<scene>
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="8" />
			</collision>
			<sprite origin="9 12" looping="true" texture="actors/mt/spawners/spawner_bats_mt.png" material="system/default.mats:actor">
				<frame>0 0 21 18</frame>
			</sprite>
		</scene>
		<scene name="portrait">
			<sprite origin="9 12" looping="true" texture="actors/mt/spawners/spawner_bats_mt.png" material="system/default.mats:actor">
				<frame>0 0 21 18</frame>
			</sprite>		
		</scene>
	</scenes>
</unit>