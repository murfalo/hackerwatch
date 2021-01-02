<unit slot="actor" netsync="position">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bosses.golem</string>
		<string name="beastiary-scene">portrait</string>
		<vec2 name="beastiary-offset">0 -3</vec2>
		<string name="quality">epic</string>
%else
		<string name="beastiary-override">actors/bosses/golem/golem_rock.unit</string>
%endif
	
		<string name="type">construct</string>
		<int name="hp">800</int>
		<int name="armor">50</int>
		<int name="resistance">50</int>
		<int name="experience-reward">1000</int>
		<float name="mp-scale-fact">1.25</float>
		<float name="ngp-scale">1.5</float>
		
		<string name="death-snd">event:/enemy/boss_golem/death</string>
		<string name="gore">effects/gibs/gib_boss_golem.sval</string>
		<string name="loot">actors/loot.sval:boss_golem</string>
		
		<bool name="impenetrable">true</bool>
		<bool name="must-see-target">false</bool>
		<int name="aggro-range">1000</int>
		<int name="unit-height">45</int>
		<float name="debuff-scale">0.5</float>
		
		<array name="buffs-immune-tags">
%include "actors/extra/buffs_immune_boss.inc"
		</array>
		
		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<int name="dist">150</int>
			<int name="stagger-threshold">0</int>
		</dict>
		
		<array name="skills">
%include "actors/bosses/golem/golem_rock_skills.inc"
		</array>
		
		<dict name="effect-params"></dict>
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="5 5" texture="gui/minimap.png" frame="117 13 11 11"/>
			<collision static="false">
				<circle offset="0 0" radius="15" density="100"/>
				<circle offset="0 -14" sensor="true" shoot-through="false" radius="15" />
			</collision>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<locator name="shoot-pos" pos="20 -17" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">0 192 64 64</frame>
				<frame time="400">0 256 64 64</frame>
				<frame time="200">0 320 64 64</frame>
				<frame time="100">0 384 64 64</frame>
				<frame time="100">0 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-1">
			<scene src="shared" />
			<locator name="shoot-pos" pos="19 5" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">448 192 64 64</frame>
				<frame time="400">448 256 64 64</frame>
				<frame time="200">448 320 64 64</frame>
				<frame time="100">448 384 64 64</frame>
				<frame time="100">448 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-2">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 18" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">384 192 64 64</frame>
				<frame time="400">384 256 64 64</frame>
				<frame time="200">384 320 64 64</frame>
				<frame time="100">384 384 64 64</frame>
				<frame time="100">384 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-3">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-19 5" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">320 192 64 64</frame>
				<frame time="400">320 256 64 64</frame>
				<frame time="200">320 320 64 64</frame>
				<frame time="100">320 384 64 64</frame>
				<frame time="100">320 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-4">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-25 -17" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">256 192 64 64</frame>
				<frame time="400">256 256 64 64</frame>
				<frame time="200">256 320 64 64</frame>
				<frame time="100">256 384 64 64</frame>
				<frame time="100">256 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-5">
			<scene src="shared" />
			<locator name="shoot-pos" pos="-25 -27" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">192 192 64 64</frame>
				<frame time="400">192 256 64 64</frame>
				<frame time="200">192 320 64 64</frame>
				<frame time="100">192 384 64 64</frame>
				<frame time="100">192 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-6">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 -34" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">128 192 64 64</frame>
				<frame time="400">128 256 64 64</frame>
				<frame time="200">128 320 64 64</frame>
				<frame time="100">128 384 64 64</frame>
				<frame time="100">128 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="attack-7">
			<scene src="shared" />
			<locator name="shoot-pos" pos="25 -27" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="200">64 192 64 64</frame>
				<frame time="400">64 256 64 64</frame>
				<frame time="200">64 320 64 64</frame>
				<frame time="100">64 384 64 64</frame>
				<frame time="100">64 128 64 64</frame>
			</sprite>
		</scene>
		
		
		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">0 0 64 64</frame>
				<frame time="150">0 64 64 64</frame>
				<frame time="150">0 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">448 0 64 64</frame>
				<frame time="150">448 64 64 64</frame>
				<frame time="150">448 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">384 0 64 64</frame>
				<frame time="150">384 64 64 64</frame>
				<frame time="150">384 128 64 64</frame>					
			</sprite>
		</scene>
		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">320 0 64 64</frame>
				<frame time="150">320 64 64 64</frame>
				<frame time="150">320 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">256 0 64 64</frame>
				<frame time="150">256 64 64 64</frame>
				<frame time="150">256 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">192 0 64 64</frame>
				<frame time="150">192 64 64 64</frame>
				<frame time="150">192 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">128 0 64 64</frame>
				<frame time="150">128 64 64 64</frame>
				<frame time="150">128 128 64 64</frame>
			</sprite>
		</scene>
		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="150">64 0 64 64</frame>
				<frame time="150">64 64 64 64</frame>
				<frame time="150">64 128 64 64</frame>			
			</sprite>
		</scene>	
		

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">0 0 64 64</frame>
				<frame time="300">0 64 64 64</frame> 
				<frame time="300">0 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">448 0 64 64</frame>
				<frame time="300">448 64 64 64</frame> 
				<frame time="300">448 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">384 0 64 64</frame>
				<frame time="300">384 64 64 64</frame> 
				<frame time="300">384 128 64 64</frame>				
			</sprite>
			
		</scene>
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">320 0 64 64</frame>
				<frame time="300">320 64 64 64</frame>
				<frame time="300">320 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">256 0 64 64</frame>
				<frame time="300">256 64 64 64</frame>
				<frame time="300">256 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">192 0 64 64</frame>
				<frame time="300">192 64 64 64</frame> 
				<frame time="300">192 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">128 0 64 64</frame>
				<frame time="300">128 64 64 64</frame> 
				<frame time="300">128 128 64 64</frame>
			</sprite>
			
		</scene>
		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">64 0 64 64</frame>
				<frame time="300">64 64 64 64</frame>
				<frame time="300">64 128 64 64</frame>			
			</sprite>
		</scene>
		
		<scene name="special">
			<scene src="shared" />
			<locator name="shoot-pos" pos="0 18" />
			<sprite looping="false" origin="32 42" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="500">0 448 64 64</frame>
				<frame time="900">64 448 64 64</frame>
				<frame time="50">128 448 64 64</frame>
				<frame time="500">192 448 64 64</frame>
				<frame time="50">384 384 64 64</frame>
			</sprite>
			<effect ulayer="-1" delay="1500" pos="0 0" src="actors/bosses/golem/smoke_impact_golem.effect" />
			<effect ulayer="-1" delay="1500" pos="-32 0" src="actors/bosses/golem/hit_impact_ground.effect" />
			<effect ulayer="-1" delay="1500" pos="32 0" src="actors/bosses/golem/hit_impact_ground.effect" />
		</scene>
		
		<scene name="portrait">
			<sprite origin="14 14" texture="./golem_rock.png" material="system/default.mats:actor">
				<frame time="300">329 12 28 28</frame>
			</sprite>
		</scene>
	</scenes>
</unit>