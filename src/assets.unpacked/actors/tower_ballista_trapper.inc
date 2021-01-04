<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.tower_ballista_trapper</string>
%else
		<string name="beastiary-override">actors/tower_ballista_trapper.unit</string>
%endif
		<vec2 name="beastiary-offset">10 5</vec2>
		<string name="quality">uncommon</string>
	
		<string name="type">construct</string>
		<int name="hp">1000</int>
		<int name="armor">80</int>
		<int name="resistance">80</int>
		<int name="experience-reward">200</int>
		<float name="mp-scale-fact">0.75</float>
		
		<string name="death-snd">event:/enemy/tower_ballista/death</string>
		<string name="gore">effects/gibs/gib_tower_ballista.sval</string>
		<string name="loot">actors/loot.sval:tower_ballista</string>
		
		<int name="aggro-range">150</int>
		<bool name="impenetrable">true</bool>

%include "actors/extra/debuff_scaling_big.inc"
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_static.inc"
		</array>

		<dict name="movement">
			<string name="class">PassiveMovement</string>
			<string name="anim-idle">idle 8</string>
		</dict>

		<array name="skills">
			<dict>			
				<string name="class">CompositeActorSkill</string>
				<string name="anim">attack 8</string>
				<string name="offset">attack-pos</string>

				<int name="cooldown-start">500</int>
				<int name="cooldown">SHOOTCD</int>
				<int name="castpoint">0</int>
				<int name="range">170</int>
				<bool name="good-aim">false</bool>
				
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">SHOOTPROJ</string>
					</dict>
				</array>
			</dict>
		</array>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="2 2" texture="gui/minimap.png" frame="123 0 5 5"/>
			<collision static="true">
				<rect shoot-through="false" aim-through="true">-16 -16 32 32</rect>
			</collision>	
		  <sprite origin="16 18" ulayer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>384 48 32 32</frame>
		  </sprite>
		</scene>

		<scene name="idle-0">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>0 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" layer="-1" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>0 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-7">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>48 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>48 336 48 48</frame>
		  </sprite>
		</scene>
		<scene name="idle-6">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>96 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>96 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-5">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>144 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>144 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-4">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>192 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>192 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-3">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>240 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>240 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-2">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>288 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>288 336 48 48</frame>
		  </sprite>
		</scene>

		<scene name="idle-1">
		  <scene src="shared" />
		  <sprite origin="24 33" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
			<frame>336 336 48 48</frame>
		  </sprite>
		  <sprite origin="12 35" layer="-1" looping="true" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
			<frame>336 336 48 48</frame>
		  </sprite>
		</scene>

		
		<scene name="attack-0">
		  <scene src="shared" />
			<locator name="attack-pos" pos="19 -13"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">0 48 48 48</frame>
				<frame time="60">0 96 48 48</frame>
				<frame time="60">0 144 48 48</frame>
				<frame time="60">0 192 48 48</frame>
				<frame time="60">0 240 48 48</frame>
				<frame time="150">0 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">0 48 48 48</frame>
				<frame time="60">0 96 48 48</frame>
				<frame time="60">0 144 48 48</frame>
				<frame time="60">0 192 48 48</frame>
				<frame time="60">0 240 48 48</frame>
				<frame time="150">0 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
		  <scene src="shared" />
			<locator name="attack-pos" pos="12 -24"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">48 48 48 48</frame>
				<frame time="60">48 96 48 48</frame>
				<frame time="60">48 144 48 48</frame>
				<frame time="60">48 192 48 48</frame>
				<frame time="60">48 240 48 48</frame>
				<frame time="150">48 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">48 48 48 48</frame>
				<frame time="60">48 96 48 48</frame>
				<frame time="60">48 144 48 48</frame>
				<frame time="60">48 192 48 48</frame>
				<frame time="60">48 240 48 48</frame>
				<frame time="150">48 48 48 48</frame>
			</sprite>
		</scene>
		<scene name="attack-6">
		  <scene src="shared" />
			<locator name="attack-pos" pos="1 -31"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">96 48 48 48</frame>
				<frame time="60">96 96 48 48</frame>
				<frame time="60">96 144 48 48</frame>
				<frame time="60">96 192 48 48</frame>
				<frame time="60">96 240 48 48</frame>
				<frame time="150">96 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">96 48 48 48</frame>
				<frame time="60">96 96 48 48</frame>
				<frame time="60">96 144 48 48</frame>
				<frame time="60">96 192 48 48</frame>
				<frame time="60">96 240 48 48</frame>
				<frame time="150">96 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
		  <scene src="shared" />
			<locator name="attack-pos" pos="-10 -25"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">144 48 48 48</frame>
				<frame time="60">144 96 48 48</frame>
				<frame time="60">144 144 48 48</frame>
				<frame time="60">144 192 48 48</frame>
				<frame time="60">144 240 48 48</frame>
				<frame time="150">144 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">144 48 48 48</frame>
				<frame time="60">144 96 48 48</frame>
				<frame time="60">144 144 48 48</frame>
				<frame time="60">144 192 48 48</frame>
				<frame time="60">144 240 48 48</frame>
				<frame time="150">144 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
		  <scene src="shared" />
			<locator name="attack-pos" pos="-18 -15"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">192 48 48 48</frame>
				<frame time="60">192 96 48 48</frame>
				<frame time="60">192 144 48 48</frame>
				<frame time="60">192 192 48 48</frame>
				<frame time="60">192 240 48 48</frame>
				<frame time="150">192 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">192 48 48 48</frame>
				<frame time="60">192 96 48 48</frame>
				<frame time="60">192 144 48 48</frame>
				<frame time="60">192 192 48 48</frame>
				<frame time="60">192 240 48 48</frame>
				<frame time="150">192 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
		  <scene src="shared" />
			<locator name="attack-pos" pos="-15 -5"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">240 48 48 48</frame>
				<frame time="60">240 96 48 48</frame>
				<frame time="60">240 144 48 48</frame>
				<frame time="60">240 192 48 48</frame>
				<frame time="60">240 240 48 48</frame>
				<frame time="150">240 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">240 48 48 48</frame>
				<frame time="60">240 96 48 48</frame>
				<frame time="60">240 144 48 48</frame>
				<frame time="60">240 192 48 48</frame>
				<frame time="60">240 240 48 48</frame>
				<frame time="150">240 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
		  <scene src="shared" />
			<locator name="attack-pos" pos="0 4"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">288 48 48 48</frame>
				<frame time="60">288 96 48 48</frame>
				<frame time="60">288 144 48 48</frame>
				<frame time="60">288 192 48 48</frame>
				<frame time="60">288 240 48 48</frame>
				<frame time="150">288 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">288 48 48 48</frame>
				<frame time="60">288 96 48 48</frame>
				<frame time="60">288 144 48 48</frame>
				<frame time="60">288 192 48 48</frame>
				<frame time="60">288 240 48 48</frame>
				<frame time="150">288 48 48 48</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
		  <scene src="shared" />
			<locator name="attack-pos" pos="15 -6"/>
			<sprite origin="24 33" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:actor">
				<frame time="60">336 48 48 48</frame>
				<frame time="60">336 96 48 48</frame>
				<frame time="60">336 144 48 48</frame>
				<frame time="60">336 192 48 48</frame>
				<frame time="60">336 240 48 48</frame>
				<frame time="150">336 48 48 48</frame>
			</sprite>
			<sprite origin="12 35" layer="-1" looping="false" texture="actors/tower_ballista_javelin.png" material="system/default.mats:shadow">
				<frame time="60">336 48 48 48</frame>
				<frame time="60">336 96 48 48</frame>
				<frame time="60">336 144 48 48</frame>
				<frame time="60">336 192 48 48</frame>
				<frame time="60">336 240 48 48</frame>
				<frame time="150">336 48 48 48</frame>
			</sprite>
		</scene>


	</scenes>
</unit>