<unit netsync="position" slot="actor">
	<behavior class="CompositeActorBehavior">
		<string name="type">undead</string>
		<bool name="counts-as-kill">false</bool>
		<int name="hp">100</int>
		<int name="armor">0</int>
		<int name="resistance">20</int>
		<bool name="must-see-target">false</bool>
		<string name="death-snd">event:/enemy/skeleton/death</string>
		<int name="aggro-range">3000</int>
		<array name="buffs-immune-tags">
			<string>player</string>
			<string>agents</string>
			%if AGENT_BLAZE
			<string>burning</string>
			%endif
			%if AGENT_RIME
			<string>freezing</string>
			<string>frozen</string>
			<string>slippery</string>
			%endif
			%if AGENT_DECAY
			<string>poison</string>
			%endif		
		</array>
		<dict name="movement">
			<string name="class">CirclingMovement</string>
			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			<float name="speed">3</float>
			<float name="roaming">0.75</float>
			<int name="dist">0</int>
		</dict>
		<array name="skills">
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">hide</string>
				<int name="cooldown">5000</int>
				<int name="castpoint">0</int>
				<int name="range">3000</int>
				<bool name="must-see">false</bool>
				<array name="actions">
					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
			<dict>
				<string name="class">CompositeActorSkill</string>
				<string name="anim">hide</string>
				<int name="cooldown-start">0</int>
				<int name="cooldown">0</int>
				<int name="castpoint">0</int>
				<int name="range">14</int>
				<bool name="must-see">false</bool>
				<array name="actions">
					<dict>
						<string name="class">Suicide</string>
					</dict>
				</array>
			</dict>
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">AGENTPATH/skeleton_death.unit</string>
						<bool name="safe-spawn">false</bool>
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
			<light pos="0 -3">
				<sprite texture="system/light2_L.png">
					<frame>0 0 128 128</frame>
				</sprite>
				<length value="1000" />
				%if !AGENT_STAR
				<overbright value="5"/>
				%endif
				%if AGENT_STAR
				<overbright value="8"/>
				%endif				
				<overlay value="false"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					%if !AGENT_RIME
					<size value="50" />
					%endif
					%if AGENT_RIME
					<size value="70" />
					%endif
				</sizes>
				<colors>
					%if AGENT_BLAZE
					<color value="255 75 0 0" />
					%endif
					%if AGENT_DECAY
					<color value="0 100 0 0" />
					%endif
					%if AGENT_RIME
					<color value="150 150 255 0" />
					%endif
					%if AGENT_STAR
					<color value="100 100 150 0" />
					%endif
				</colors>
			</light>
		</scene>
		<scene name="idle-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>0 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">0 0 24 24</frame>
				<frame time="100">0 24 24 24</frame>
				<frame time="100">0 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">0 0 24 24</frame>
			</sprite>
			%endif
		</scene>
		<scene name="idle-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>24 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">24 0 24 24</frame>
				<frame time="100">24 24 24 24</frame>
				<frame time="100">24 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">24 0 24 24</frame>
			</sprite>
			%endif
		</scene>
		<scene name="idle-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>48 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">48 0 24 24</frame>
				<frame time="100">48 24 24 24</frame>
				<frame time="100">48 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">48 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="idle-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>72 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">72 0 24 24</frame>
				<frame time="100">72 24 24 24</frame>
				<frame time="100">72 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">72 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="idle-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>96 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">96 0 24 24</frame>
				<frame time="100">96 24 24 24</frame>
				<frame time="100">96 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">96 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="idle-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>120 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">120 0 24 24</frame>
				<frame time="100">120 24 24 24</frame>
				<frame time="100">120 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">120 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="idle-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>144 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">144 0 24 24</frame>
				<frame time="100">144 24 24 24</frame>
				<frame time="100">144 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">144 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="idle-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame>168 0 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">
				<frame time="100">168 0 24 24</frame>
				<frame time="100">168 24 24 24</frame>
				<frame time="100">168 48 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">
				<frame time="100">168 0 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-0">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">0 24 24 24</frame>
				<frame time="100">0 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">0 0 24 24</frame>
				<frame time="100">0 23 24 24</frame>
				<frame time="100">0 48 24 24</frame>
				<frame time="100">0 -1 24 24</frame>
				<frame time="100">0 24 24 24</frame>
				<frame time="100">0 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR || NIGHTPOWER
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">0 24 24 24</frame>
				<frame time="100">0 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-7">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">24 24 24 24</frame>
				<frame time="100">24 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">24 0 24 24</frame>
				<frame time="100">24 23 24 24</frame>
				<frame time="100">24 48 24 24</frame>
				<frame time="100">24 -1 24 24</frame>
				<frame time="100">24 24 24 24</frame>
				<frame time="100">24 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">24 24 24 24</frame>
				<frame time="100">24 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-6">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">48 24 24 24</frame>
				<frame time="100">48 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">48 0 24 24</frame>
				<frame time="100">48 23 24 24</frame>
				<frame time="100">48 48 24 24</frame>
				<frame time="100">48 -1 24 24</frame>
				<frame time="100">48 24 24 24</frame>
				<frame time="100">48 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">48 24 24 24</frame>
				<frame time="100">48 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-5">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">72 24 24 24</frame>
				<frame time="100">72 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">72 0 24 24</frame>
				<frame time="100">72 23 24 24</frame>
				<frame time="100">72 48 24 24</frame>
				<frame time="100">72 -1 24 24</frame>
				<frame time="100">72 24 24 24</frame>
				<frame time="100">72 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">72 24 24 24</frame>
				<frame time="100">72 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-4">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">96 24 24 24</frame>
				<frame time="100">96 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">96 0 24 24</frame>
				<frame time="100">96 23 24 24</frame>
				<frame time="100">96 48 24 24</frame>
				<frame time="100">96 -1 24 24</frame>
				<frame time="100">96 24 24 24</frame>
				<frame time="100">96 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">96 24 24 24</frame>
				<frame time="100">96 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-3">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">120 24 24 24</frame>
				<frame time="100">120 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">120 0 24 24</frame>
				<frame time="100">120 23 24 24</frame>
				<frame time="100">120 48 24 24</frame>
				<frame time="100">120 -1 24 24</frame>
				<frame time="100">120 24 24 24</frame>
				<frame time="100">120 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">120 24 24 24</frame>
				<frame time="100">120 48 24 24</frame>
			</sprite>
			%endif				
		</scene>
		<scene name="walk-2">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">144 24 24 24</frame>
				<frame time="100">144 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">144 0 24 24</frame>
				<frame time="100">144 23 24 24</frame>
				<frame time="100">144 48 24 24</frame>
				<frame time="100">144 -1 24 24</frame>
				<frame time="100">144 24 24 24</frame>
				<frame time="100">144 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">144 24 24 24</frame>
				<frame time="100">144 48 24 24</frame>
			</sprite>
			%endif
		</scene>
		<scene name="walk-1">
			<scene src="shared" />
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:actor">
				<frame time="100">168 24 24 24</frame>
				<frame time="100">168 48 24 24</frame>
			</sprite>
			%if AGENT_BLAZE
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:bright-noxray">				
				<frame time="100">168 0 24 24</frame>
				<frame time="100">168 23 24 24</frame>
				<frame time="100">168 48 24 24</frame>
				<frame time="100">168 -1 24 24</frame>
				<frame time="100">168 24 24 24</frame>
				<frame time="100">168 47 24 24</frame>
			</sprite>
			%endif
			%if AGENT_STAR
			<sprite origin="12 14" ulayer="1" looping="true" texture="./skeleton_outline.png" material="system/default.mats:glow-both-bright">				
				<frame time="100">168 24 24 24</frame>
				<frame time="100">168 48 24 24</frame>
			</sprite>
			%endif
		</scene>
		<scene name="hide">
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:invisible">
				<frame time="100">168 24 24 24</frame>
			</sprite>
		</scene>
	</scenes>
</unit>