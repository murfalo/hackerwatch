%if BESTIARY
		<string name="beastiary-name">AGENTNAME</string>
%else
		<string name="beastiary-override">BESTIARYOVERRIDE</string>
%endif
		<vec2 name="beastiary-offset">0 10</vec2>
		<string name="quality">epic</string>
		<string name="dlc">mt</string>
		<string name="type">undead</string>
		<int name="hp">10000</int>
		<int name="armor">100</int>
		<int name="resistance">100</int>
		<int name="experience-reward">2500</int>
		<string name="death-snd">event:/enemy/boss_agents/death</string>
		<string name="loot">actors/mt/bosses/agents/loot.sval:equipment</string>
		<float name="mp-scale-fact">1.4</float>
		<float name="ngp-scale">1.25</float>
		<float name="wind-scale">0</float>
		<int name="aggro-range">3000</int>
		<int name="unit-height">21</int>
		<bool name="must-see-target">true</bool>
		<array name="buffs-immune-tags">
			%include "actors/extra/buffs_immune_boss.inc"
			<string>notagent</string>
			<string>player</string>
			%if AGENT_BLAZE
			<string>burning</string>
			%endif
			%if AGENT_RIME
			<string>freezing</string>
			%endif
			%if AGENT_DECAY
			<string>poison</string>
			%endif
		</array>
		<dict name="movement">
%if AGENT_BLAZE
			<string name="class">MeleeMovement</string>
			<int name="dist">0</int>

%elif AGENT_DECAY
			<string name="class">CirclingMovement</string>
			<int name="dist">0</int>
%else
			<string name="class">RangedMovement</string>
			<int name="dist">MOVEDIST</int>
%endif

			<string name="anim-idle">idle 8</string>
			<string name="anim-walk">walk 8</string>
			<float name="speed">MOVESPEED</float>
		</dict>		