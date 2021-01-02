%// Frostball SP
<dict>
	<string name="class">CompositeActorSkill</string>
	
<!-- 	<array name="conditional">
		<string>players</string><string>eq</string><int>1</int>
	</array> -->
	
	<string name="anim">shard 9 0 180</string>
	<string name="start-snd">event:/enemy/boss_dragon/frostball-start</string>
	<string name="snd">event:/enemy/boss_dragon/frostball</string>

	<int name="cooldown">12500</int>
	<int name="castpoint">450</int>
	<int name="range">1400</int>
	<bool name="must-see">false</bool>
	
	<string name="offset">shoot-pos</string>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectile</string>
			<string name="projectile">actors/bosses/dragon/frostball_v4.unit</string>
		</dict>
	</array>
</dict>

%// Frostball MP
<!-- <dict>
	<string name="class">BossScatterBurstSkill</string>
	
	<array name="conditional">
		<string>players</string><string>gt</string><int>1</int>
	</array>
	
	<string name="anim">shard 9 0 180</string>
	<string name="start-snd">event:/enemy/boss_dragon/frostball-start</string>
	<string name="snd">event:/enemy/boss_dragon/frostball</string>

	<int name="burst">3</int>
	<int name="cooldown">10000</int>
	<int name="castpoint">450</int>
	<int name="range">1400</int>
	<bool name="must-see">false</bool>
	
	<string name="offset">shoot-pos</string>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectile</string>
			<string name="projectile">actors/bosses/dragon/frostball_v4.unit</string>
		</dict>
	</array>
</dict>	 -->

%// Shard
<dict>
	<string name="class">BossScatterBurstSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>unlock_shards</string>
		<string>ngp</string><string>lt</string><int>2</int>
	</array>
	
	<string name="anim">shard 9 0 180</string>
	<string name="start-snd">event:/enemy/boss_dragon/shard-start</string>
	<string name="snd">event:/enemy/boss_dragon/shard</string>

	<int name="burst">7</int>
	<int name="cooldown">2000</int>
	<int name="castpoint">450</int>
	<int name="range">999</int>
	<int name="min-range">50</int>
	<bool name="must-see">false</bool>
	<bool name="good-aim">false</bool>
	
	<string name="offset">shoot-pos</string>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="projectiles">3</int>
			<int name="spread">20</int>
			<string name="projectile">actors/bosses/dragon/shard.unit</string>
		</dict>
	</array>
</dict>

%// Shard NG+2
<dict>
	<string name="class">BossScatterBurstSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>unlock_shards</string>
		<string>ngp</string><string>gt</string><int>1</int>
	</array>

	<string name="anim">shard 9 0 180</string>
	<string name="start-snd">event:/enemy/boss_dragon/shard-start</string>
	<string name="snd">event:/enemy/boss_dragon/shard</string>

	<int name="burst">7</int>
	<int name="cooldown">2000</int>
	<int name="castpoint">450</int>
	<int name="range">999</int>
	<int name="min-range">50</int>
	<bool name="must-see">false</bool>
	<bool name="good-aim">false</bool>
	
	<string name="offset">shoot-pos</string>
	
	<array name="actions">
		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="projectiles">5</int>
			<int name="spread">40</int>
			<string name="projectile">actors/bosses/dragon/shard.unit</string>
		</dict>
	</array>
</dict>

%// Breath
<dict>
	<string name="class">SpewSkill</string>
	
	<array name="conditional">
		<string>hp</string><string>lt</string><float>0.75</float>
	</array>
	
	<string name="anim">wave 9 0 180</string>
	<string name="start-snd">event:/enemy/boss_dragon/wave-start</string>
	<string name="snd">event:/enemy/boss_dragon/wave</string>
	
	<int name="cooldown">12000</int>
	<int name="castpoint">700</int>
	<int name="duration">3000</int>	
	<int name="range">600</int>
	<int name="min-range">64</int>
	<int name="spread">15</int>
	<int name="rate">7</int>
	
	<bool name="must-see">false</bool>
	<bool name="hold-dir">true</bool>
	
	<string name="offset">shoot-pos</string>
	<string name="projectile">actors/bosses/dragon/breath_v3.unit</string>
</dict>		