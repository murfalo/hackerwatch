<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.spawner_vampire_2</string>
%else
		<string name="beastiary-override">actors/mt/spawners/spawner_vampire_2.unit</string>
%endif
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">-1 2</vec2>
		<string name="quality">uncommon</string>
		<string name="dlc">mt</string>
	
		<string name="type">construct</string>
		<int name="hp">450</int>
		<int name="armor">60</int>
		<int name="resistance">40</int>
		<int name="experience-reward">250</int>
		<float name="mp-scale-fact">1</float>
		
		<string name="gore">effects/gibs/gib_vampire_coffin.sval</string>
		<string name="death-snd">event:/enemy/vampire/spawner_break</string>
		<string name="loot">LOOT</string>
		
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
				<string name="anim">spawn</string>
				<string name="offset">spawn-pos</string>
				
				<int name="charges">SPAWNCHARGES</int>

				<int name="cooldown">SPAWNCD</int>
				<int name="castpoint">500</int>
				<int name="range">200</int>
				<bool name="must-see">true</bool>
				
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<array name="units">
							<int>800</int><string>actors/mt/vampire_2.unit</string>
							<int>200</int><string>actors/mt/vampire_2_ranged.unit</string>
						</array>
						<bool name="aggro">true</bool>
						<bool name="safe-spawn">true</bool>
						<int name="spawn-dist">0</int>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">CORPSE</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes>
%if NORTH
		<scene name="default">
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="10 17" looping="false" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 0 16 29</frame>
			</sprite>			
		</scene>

		<scene name="spawn" trigger-snd="event:/enemy/vampire/spawn">
			<locator name="spawn-pos" pos="0 8"/>
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="10 17" looping="true" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 0 16 29</frame>
				<frame time="100">16 0 16 29</frame>
				<frame time="100">32 0 16 29</frame>
				<frame time="100">48 0 16 29</frame>
				<frame time="300">64 0 16 29</frame>
				<frame time="100">48 0 16 29</frame>
				<frame time="100">32 0 16 29</frame>
				<frame time="100">16 0 16 29</frame>
				<frame time="100">0 0 16 29</frame>
			</sprite>
		</scene>
%elif EAST
		<scene name="default">
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="16 20" looping="false" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 53 17 24</frame>
			</sprite>			
		</scene>
		<scene name="spawn" trigger-snd="event:/enemy/vampire/spawn">
			<locator name="spawn-pos" pos="-12 0"/>
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="16 20" looping="true" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 53 17 24</frame>
				<frame time="100">17 53 17 24</frame>
				<frame time="100">34 53 17 24</frame>
				<frame time="100">51 53 17 24</frame>
				<frame time="300">68 53 17 24</frame>
				<frame time="100">51 53 17 24</frame>
				<frame time="100">34 53 17 24</frame>
				<frame time="100">17 53 17 24</frame>
				<frame time="100">0 53 17 24</frame>
			</sprite>			
		</scene>
%elif WEST
		<scene name="default">
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="1 20" looping="true" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 29 17 24</frame>
			</sprite>		
		</scene>
		<scene name="spawn" trigger-snd="event:/enemy/vampire/spawn">
			<locator name="spawn-pos" pos="12 -1"/>
			<minimap_sprite layer="1" origin="3 3" texture="gui/minimap.png" frame="123 5 5 5"/>
			<collision static="true">
				<circle offset="0 0" radius="5" />
			</collision>
			<sprite origin="1 20" looping="true" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 29 17 24</frame>
				<frame time="100">17 29 17 24</frame>
				<frame time="100">34 29 17 24</frame>
				<frame time="100">51 29 17 24</frame>
				<frame time="300">68 29 17 24</frame>
				<frame time="100">51 29 17 24</frame>
				<frame time="100">34 29 17 24</frame>
				<frame time="100">17 29 17 24</frame>
				<frame time="100">0 29 17 24</frame>
			</sprite>			
		</scene>
%endif
		<scene name="portrait">
			<sprite origin="9 16" looping="false" texture="actors/mt/spawners/spawner_vampire_2.png" material="system/default.mats:actor">
				<frame time="100">0 0 15 29</frame>
			</sprite>
		</scene>
	</scenes>
</unit>