%// Feeding
<dict>
	<array name="conditional">
		<string>flag</string><string>is</string><string>vampire_middle</string>
	</array>
	
	<string name="class">CompositeActorSkill</string>
	<string name="anim">feeding</string>
	
	<bool name="must-see">false</bool>
	<int name="cooldown">5000</int>
	<int name="castpoint">3200</int>
	<int name="range">1000</int>
	
	<string name="start-snd">event:/enemy/boss_vampire/feeding</string>
	
	<array name="start-actions">
		<dict>
			<string name="class">SetFlag</string>
			<bool name="value">true</bool>
			<string name="flag">vampire_feed</string>
		</dict>
		
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">feed_start</string>
		</dict>
		
		<dict>
			<string name="class">ApplyBuff</string>
			<string name="buff">actors/buffs.sval:vampire-middle</string>
			<bool name="target-self">true</bool>
		</dict>
	</array>
	
	<array name="actions">
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">feed_end</string>
		</dict>
		
		<dict>
			<string name="class">SetFlag</string>
			<bool name="value">false</bool>
			<string name="flag">vampire_feed</string>
		</dict>
		
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_vampire/feeding_laugh</string>
		</dict>
	</array>
</dict>

%// NG+2 Bat Spray
<dict>
	<array name="conditional">
		<string>ngp</string><string>gt</string><int>1</int>
		<string>hp</string><string>lt</string><float>0.2</float>
		<string>flag</string><string>isnt</string><string>vampire_middle</string>
	</array>

	<string name="class">SpewSkill</string>
	<string name="anim">attack-hand 8</string>
	<string name="offset">shoot-pos</string>
	
	<int name="charges">BATCHARGES</int>
	
	<string name="first-fire-snd">event:/enemy/boss_vampire/bat_spray</string>
	
	<int name="cooldown-start">200</int>
	<int name="cooldown">20000</int>
	<int name="castpoint">850</int>
	<int name="duration">600</int>	
	<int name="range">120</int>
	<int name="min-range">0</int>
	<int name="spread">30</int>
	<int name="rate">50</int>
	
	<bool name="must-see">false</bool>
	<bool name="hold-dir">false</bool>

	<string name="projectile">actors/bosses/vampire/bat_projectile_spawn.unit</string>
</dict>

%// Blade Wall
<dict>
	<array name="conditional">
		<string>flag</string><string>isnt</string><string>vampire_middle</string>
	</array>
	
	<string name="class">CompositeActorSkill</string>
	<string name="anim">sword</string>
	
	<string name="start-snd">event:/enemy/boss_vampire/attack-blades</string>
	
	<bool name="must-see">false</bool>
	<int name="cooldown-start">500</int>
	<int name="cooldown">BLADESCD</int>
	<int name="castpoint">450</int>
	<int name="range">1000</int>
	
	<array name="actions">
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">blade_wall</string>
		</dict>
	</array>
</dict>

%// Rapiers
<dict>
	<array name="conditional">
		<string>flag</string><string>isnt</string><string>vampire_middle</string>
	</array>

	<string name="class">WhirlNovaSkill</string>
	<string name="anim">attack-sword 8</string>
	<!-- <string name="offset">shoot-pos</string> -->
	
	<string name="start-snd">event:/enemy/boss_vampire/attack-rapiers</string>
	<!-- <string name="fire-snd">event:/enemy/boss_vampire/rapier</string> -->
	
	<int name="cooldown">RAPIERCD</int>
	<int name="castpoint">1100</int>
	<int name="duration">540</int>
	<int name="min-range">0</int>
	<int name="range">1000</int>
	
	<bool name="hold-dir">true</bool>
	<bool name="must-see">false</bool>
	<bool name="targeted">true</bool>
	<int name="angle-offset">-60</int>
	
	<string name="projectile">actors/bosses/vampire/rapier_projectile.unit</string>
	<float name="proj-dist">12</float>
	<int name="proj-delay">60</int>
	<int name="per-revolution">27</int>			
</dict>

%// Death
<dict>
	<string name="class">CompositeActorTriggeredSkill</string>
	<string name="trigger">OnDeath</string>
	<array name="actions">
		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/vampire/vampire_corpse.unit</string>
		</dict>	
	</array>	
</dict>