<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
%if BESTIARY
		<string name="beastiary-name">.bestiary.name.bannerman_protection</string>
%else
		<string name="beastiary-override">actors/bannerman_protection.unit</string>
%endif
		<vec2 name="beastiary-offset">1 2</vec2>
		<string name="quality">common</string>
	
		<string name="type">undead</string>
		<int name="hp">45</int>
		<int name="armor">15</int>
		<int name="resistance">5</int>
		<int name="experience-reward">45</int>
		<float name="mp-scale-fact">0.2</float>
		
		<string name="death-snd">event:/enemy/skeleton/death</string>
		<string name="gore">effects/gibs/gib_bannerman_bloodlust.sval</string>
		<string name="loot">actors/loot.sval:skeleton_1_elite</string>
		
%include "actors/extra/debuff_scaling_normal.inc"

		<array name="buffs-immune-tags">
			<string>buff</string>
			<string>respawn_ghost_ranger</string>
			<string>respawn_ghost_sorcerer</string>
		</array>

		
		<int name="aggro-range">130</int>

		<dict name="movement">
			<string name="class">RangedMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>

			<float name="speed">MOVESPEED</float>
			<int name="dist">80</int>
			<int name="min-dist">50</int>
		</dict>

		<array name="skills">
			<dict>
				<array name="conditional">
					<string>flag</string><string>isnt</string><string>mode_arena</string>
				</array>
			
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/banners/banner_protection.unit</string>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorAuraSkill</string>
				<string name="buff">actors/buffs.sval:protection</string>
				<int name="freq">250</int>
				<int name="range">BUFFRANGE</int>
			</dict>
		</array>
		
		<dict name="effect-params">
			<float name="color_r">.75</float>
			<float name="color_g">.75</float>
			<float name="color_b">.75</float>
			<float name="size">BUFFRANGE</float>
		</dict>		
		
	</behavior>

	<scenes start="idle-0 idle-1 idle-2 idle-3 idle-4 idle-5 idle-6 idle-7">
		<scene name="shared">
			<minimap_sprite layer="1" origin="1 1" texture="gui/minimap.png" frame="120 0 3 3"/>
			
			<effect src="actors/banners/banner_marker_protection.effect" />
			
			<collision static="false">
				<circle offset="0 0" aim-through="true" radius="3.5" charge-through="true" />
				<circle offset="0 -5.25" sensor="true" shoot-through="false" aim-through="true" radius="3.5" />
			</collision>
		</scene>

		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">0 24 24 24</frame>
				<frame time="225">0 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">24 24 24 24</frame>
				<frame time="225">24 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">48 24 24 24</frame>
				<frame time="225">48 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">72 24 24 24</frame>
				<frame time="225">72 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">96 24 24 24</frame>
				<frame time="225">96 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">120 24 24 24</frame>
				<frame time="225">120 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">144 24 24 24</frame>
				<frame time="225">144 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="225">168 24 24 24</frame>
				<frame time="225">168 48 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">0 72 24 24</frame>
				<frame time="250">0 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">24 72 24 24</frame>
				<frame time="250">24 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">48 72 24 24</frame>
				<frame time="250">48 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">72 72 24 24</frame>
				<frame time="250">72 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">96 72 24 24</frame>
				<frame time="250">96 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">120 72 24 24</frame>
				<frame time="250">120 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">144 72 24 24</frame>
				<frame time="250">144 96 24 24</frame>
			</sprite>
		</scene>

		<scene name="attack-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="false" texture="actors/bannerman_protection.png" material="system/default.mats:actor">
				<frame time="350">168 72 24 24</frame>
				<frame time="250">168 96 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>
