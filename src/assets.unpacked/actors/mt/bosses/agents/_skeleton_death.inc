<unit>
	<behavior class="BombBehavior">
		<int name="delay-random">0</int>
		<int name="delay">400</int>
		<bool name="targetable">false</bool>
		<bool name="targeting">false</bool>
		%if AGENT_BLAZE		
			<string name="gore">effects/gibs/gib_agent_skeleton_blaze.sval</string>
		%endif
		%if AGENT_DECAY
			<string name="gore">effects/gibs/gib_agent_skeleton_decay.sval</string>
		%endif
		%if AGENT_RIME
			<string name="gore">effects/gibs/gib_agent_skeleton_rime.sval</string>
		%endif
		%if AGENT_STAR
			<string name="gore">effects/gibs/gib_agent_skeleton_star.sval</string>
		%endif
		<array name="actions">
			%if AGENT_BLAZE
			<dict>
				<string name="class">Explode</string>
				<string name="fx">AGENTPATH/skeleton_explosion.effect</string>
				<int name="min-radius">8</int>
				<int name="radius">8</int>
				<float name="dist-scaling">1000</float>
				<float name="team-dmg">0</float>
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">75</int>
						<bool name="melee">true</bool>
					</dict>
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/mt/bosses/agents/buffs.sval:firesword</string>
					</dict>
				</array>
			</dict>
			%endif
			%if AGENT_DECAY
			<dict>
				<string name="class">SpawnEffect</string>
				<string name="effect">AGENTPATH/skeleton_explosion.effect</string>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/rottenpart_puddle.unit</string>
				<bool name="safe-spawn">false</bool>
				<int name="spawn-dist">0</int>
			</dict>
			%endif
			%if AGENT_RIME
			<dict>
				<string name="class">SpawnEffect</string>
				<string name="effect">AGENTPATH/skeleton_explosion.effect</string>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/skeleton_area.unit</string>
				<bool name="safe-spawn">false</bool>
				<int name="spawn-dist">0</int>
			</dict>
			%endif
			%if AGENT_STAR
			<dict>
				<string name="class">Explode</string>
				<string name="fx">AGENTPATH/starprojectile_impact.effect</string>
				<int name="radius">12</int>
				<float name="team-dmg">0</float>
				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="magical">20</int>
						<float name="resistance-mul">0.5</float>
					</dict>
					<dict>
						<string name="class">ApplyBuff</string>
						<string name="buff">actors/mt/bosses/agents/buffs.sval:starburst</string>
					</dict>
				</array>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/starprojectile_bomb.unit</string>
				<bool name="safe-spawn">false</bool>
				<vec2 name="jitter">4 4</vec2>
				<int name="delay">100</int>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/starprojectile_bomb.unit</string>
				<bool name="safe-spawn">false</bool>
				<vec2 name="jitter">4 4</vec2>
				<int name="delay">200</int>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/starprojectile_bomb.unit</string>
				<bool name="safe-spawn">false</bool>
				<vec2 name="jitter">4 4</vec2>
				<int name="delay">300</int>
			</dict>
			<dict>
				<string name="class">SpawnUnit</string>
				<string name="unit">AGENTPATH/starprojectile_bomb.unit</string>
				<bool name="safe-spawn">false</bool>
				<vec2 name="jitter">4 4</vec2>
				<int name="delay">400</int>
			</dict>
			%endif
		</array>
	</behavior>
	<scenes>
		<scene>
			<sprite origin="12 14" looping="true" texture="./skeleton.png" material="system/default.mats:glow-both-bright">
				<frame time="50">0 96 24 24</frame>
				<frame time="50">24 96 24 24</frame>
				<frame time="50">48 96 24 24</frame>
				<frame time="50">72 96 24 24</frame>
				<frame time="50">96 96 24 24</frame>
				<frame time="50">120 96 24 24</frame>
				<frame time="50">144 96 24 24</frame>
				<frame time="50">168 96 24 24</frame>
			</sprite>
			<light pos="0 -3">
				<sprite texture="actors/mt/bosses/agents/agent_star/star.png">
					<frame>0 0 256 256</frame>
				</sprite>
				<length value="100" />
				%if !AGENT_STAR
				<overbright value="20"/>
				%endif	
				%if AGENT_STAR
				<overbright value="30"/>
				%endif
				<overlay value="false"/>
				<looping value="true" />
				<cast-shadows value="false" />
				<shadow-cast-pos value="0 0" />
				<shadow-cast-pos-jitter value="0 0 0 0" />
				<sizes>
					<size value="0" />
					<size value="100" />
				</sizes>
				<colors>
					%if AGENT_BLAZE
					<color value="255 100 0 0" />
					%endif
					%if AGENT_STAR
					<color value="100 75 150 0" />
					%endif
					%if AGENT_RIME
					<color value="0 150 255 0" />
					%endif
					%if AGENT_DECAY
					<color value="50 255 0 0" />
					%endif				
				</colors>
			</light>
		</scene>
	</scenes>
</unit>