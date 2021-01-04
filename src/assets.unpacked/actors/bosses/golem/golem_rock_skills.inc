%// Groundspikes SP
<dict>
	<array name="conditional">
		<string>players</string><string>eq</string><int>1</int>
	</array>

	<string name="class">CompositeActorSkill</string>
	<string name="anim">attack 8</string>
	<string name="snd">event:/enemy/boss_golem/shoot_spikes</string>	
	
	<bool name="must-see">true</bool>
	<int name="cooldown-start">200</int>
	<int name="cooldown">GROUNDSPIKESCD</int>
	<int name="castpoint">650</int>
	<int name="range">200</int>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectile</string>
			<int name="dist">10</int>
			<int name="spread">0</int>
%if NORMAL
			<string name="projectile">actors/bosses/golem/golem_groundspikes_big.unit</string>
%else
			<string name="projectile">actors/bosses/golem/golem_groundspikes_big_ng.unit</string>
%endif
		</dict>
	</array>
</dict>

%// Groundspikes MP
<dict>
	<array name="conditional">
		<string>players</string><string>gt</string><int>1</int>
	</array>

	<string name="class">CompositeActorSkill</string>
	<string name="anim">attack 8</string>
	<string name="snd">event:/enemy/boss_golem/shoot_spikes</string>	
	
	<bool name="must-see">true</bool>
	<int name="cooldown-start">200</int>
	<int name="cooldown">GROUNDSPIKESCD</int>
	<int name="castpoint">650</int>
	<int name="range">200</int>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectile</string>
			<int name="dist">10</int>					
			<int name="spread">0</int>				
%if NORMAL
			<string name="projectile">actors/bosses/golem/golem_groundspikes_big.unit</string>
%else
			<string name="projectile">actors/bosses/golem/golem_groundspikes_big_ng.unit</string>
%endif
		</dict>

		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="dist">10</int>	
			<int name="projectiles">2</int>
			<int name="spread">90</int>
			<float name="jitter">0.2</float>
%if NORMAL
			<string name="projectile">actors/bosses/golem/golem_groundspikes.unit</string>
%else
			<string name="projectile">actors/bosses/golem/golem_groundspikes_ng.unit</string>
%endif
		</dict>
	</array>
</dict>

%// Slam
<dict>
	<string name="class">CompositeActorSkill</string>
	<string name="anim">special</string>
	<string name="start-snd">event:/enemy/boss_golem/ground_slam</string>	
	
	<bool name="must-see">false</bool>
	<int name="cooldown">SLAMCD</int>
	<int name="castpoint">1500</int>
	<int name="range">1000</int>
	
	<array name="actions">
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">stalactites</string>
		</dict>
		<dict>
			<string name="class">Explode</string>
			<int name="radius">40</int>
			<float name="team-dmg">0</float>
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">SLAMDMG</int>
					<float name="armor-mul">ARMORMUL</float>
				</dict>
			</array>
		</dict>
%if !NORMAL
		<dict>
			<string name="class">Nova</string>
			<int name="projectiles">SLAMNOVANUM</int>
			<int name="dist">10</int>
			<string name="projectile">actors/bosses/golem/golem_groundspikes_ng.unit</string>
		</dict>
%endif
	</array>
</dict>

%// Death
<dict>
	<string name="class">CompositeActorTriggeredSkill</string>
	<string name="trigger">OnDeath</string>
	<array name="actions">
		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/golem/golem_rock_corpse.unit</string>
		</dict>	
	</array>	
</dict>	