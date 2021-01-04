%if MAGE
<!-- mage start at 1020 -->
<dict>
	<string name="class">CompositeActorSkill</string>
	<string name="anim">mage_intro</string>
	<string name="snd">event:/enemy/boss_wraith/attack-mage</string>

	<int name="charges">1</int>
	<bool name="must-see">false</bool>
	<int name="cooldown">0</int>
	<int name="castpoint">1800</int>
	<int name="range">400</int>
	
	<array name="actions">
		<dict>
			<string name="class">Nova</string>
			
			<int name="projectiles">NOVANUM</int>
			<string name="projectile">actors/bosses/wraith/wraith_mage_nova.unit</string>
		</dict>
	</array>
</dict>

<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraiths_activate</string>
		<string>flag</string><string>isnt</string><string>wraith_scythe_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">mage</string>
	<int name="castpoint">4500</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.7</float>
	<int name="melee-cooldown">1500</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">150</int>
	<int name="period">1500</int>
	<int name="period-rand">750</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-mage</string>
		</dict>
		
		<dict>
			<string name="class">Nova</string>
			<int name="projectiles">NOVANUM</int>
			<string name="projectile">actors/bosses/wraith/wraith_mage_nova.unit</string>
		</dict>
	</array>
</dict>

<!-- MAGE - SCYTHE DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_scythe_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">mage</string>
	<int name="castpoint">4500</int>

	<bool name="must-have-target">true</bool>
	
	<int name="melee-range">35</int>
	<float name="melee-chance">0.8</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">150</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-mage</string>
		</dict>		
		
		<dict>
			<string name="class">Nova</string>
			<int name="projectiles">NOVANUMONEDEAD</int>
			<string name="projectile">actors/bosses/wraith/wraith_mage_nova_scythe.unit</string>
		</dict>
	</array>
</dict>

<!-- MAGE - STAFF DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>isnt</string><string>wraith_scythe_dead</string>
		<string>flag</string><string>is</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">mage</string>
	<int name="castpoint">4500</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.8</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">150</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-mage</string>
		</dict>		
		
		<dict>
			<string name="class">Nova</string>
			<int name="projectiles">NOVANUMONEDEAD</int>
			<string name="projectile">actors/bosses/wraith/wraith_mage_nova_staff.unit</string>
		</dict>
	</array>
</dict>

<!-- MAGE - BOTH DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_scythe_dead</string>
		<string>flag</string><string>is</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">mage</string>
	<int name="castpoint">4500</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.8</float>
	<int name="melee-cooldown">1000</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">150</int>
	<int name="period">1000</int>
	<int name="period-rand">250</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-mage</string>
		</dict>		
		
		<dict>
			<string name="class">Nova</string>
			<int name="projectiles">NOVANUMBOTHDEAD</int>
			<string name="projectile">actors/bosses/wraith/wraith_mage_nova_both.unit</string>
		</dict>
	</array>
</dict>

<!-- MAGE DEAD -->
<dict>
	<string name="class">CompositeActorTriggeredSkill</string>
	<string name="trigger">OnDeath</string>
	<array name="actions">
		<dict>
			<string name="class">SetFlag</string>
			<bool name="value">true</bool>
			<string name="flag">wraith_mage_dead</string>
		</dict>
		<dict>
			<string name="class">SpawnEffect</string>
			<string name="effect">actors/bosses/wraith/wraith_death.effect</string>
		</dict>
	</array>	
</dict>	


%elif SCYTHE
<!-- scythe start at  1380-->
<dict>
	<string name="class">CompositeActorSkill</string>
	<string name="anim">scythe_intro</string>
	<string name="snd">event:/enemy/boss_wraith/attack-scythe</string>

	<int name="charges">1</int>
	<bool name="must-see">false</bool>
	<int name="cooldown">0</int>
	<int name="castpoint">950</int>
	<int name="range">400</int>
	
	<array name="actions">
		<dict>
			<string name="class">Explode</string>
			
			<int name="min-radius">45</int>
			<int name="radius">45</int>
			<float name="dist-scaling">1000</float>
			<float name="team-dmg">0</float>
			
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<float name="armor-mul">0.75</float>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="dist">10</int>
			<int name="spread">SCYTHESPREAD</int>
			<int name="projectiles">SCYTHENUM</int>
			<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker.unit</string>
		</dict>
	</array>
</dict>

<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraiths_activate</string>
		<string>flag</string><string>isnt</string><string>wraith_mage_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">scythe</string>
	<int name="castpoint">2200</int>

	<bool name="must-have-target">true</bool>
	<bool name="good-aim">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.9</float>
	<int name="melee-cooldown">1500</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">100</int>
	<int name="period">1500</int>
	<int name="period-rand">750</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-scythe</string>
		</dict>		
		
		<dict>
			<string name="class">Explode</string>
			
			<int name="min-radius">45</int>
			<int name="radius">45</int>
			<float name="dist-scaling">1000</float>
			<float name="team-dmg">0</float>
			
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<float name="armor-mul">0.75</float>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="dist">10</int>
			<int name="spread">SCYTHESPREAD</int>
			<int name="projectiles">SCYTHENUM</int>		
			<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker.unit</string>
		</dict>
	</array>
</dict>

<!-- SCYTHE - MAGE DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_mage_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">scythe</string>
	<int name="castpoint">2200</int>

	<bool name="must-have-target">true</bool>
	<bool name="good-aim">true</bool>
	
	<int name="melee-range">35</int>
	<float name="melee-chance">0.7</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">100</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-scythe</string>
		</dict>			
		
		<dict>
			<string name="class">Explode</string>
			
			<int name="min-radius">45</int>
			<int name="radius">45</int>
			<float name="dist-scaling">1000</float>
			<float name="team-dmg">0</float>
			
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<float name="armor-mul">0.75</float>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="class">Nova</string>
			
			<int name="projectiles">SCYTHEMAGENOVA</int>
			<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker_mage.unit</string>
			<int name="dist">20</int>
		</dict>
	</array>
</dict>

<!-- SCYTHE - STAFF DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>isnt</string><string>wraith_mage_dead</string>
		<string>flag</string><string>is</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">scythe</string>
	<int name="castpoint">2200</int>

	<bool name="must-have-target">true</bool>
	<bool name="good-aim">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.9</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">100</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-scythe</string>
		</dict>			
		
		<dict>
			<string name="class">Explode</string>
			
			<int name="min-radius">45</int>
			<int name="radius">45</int>
			<float name="dist-scaling">1000</float>
			<float name="team-dmg">0</float>
			
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<float name="armor-mul">0.75</float>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="class">ShootProjectileFan</string>
			<int name="dist">10</int>
			<int name="spread">SCYTHESPREAD</int>
			<int name="projectiles">SCYTHENUM</int>
			<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker_staff.unit</string>
		</dict>
	</array>
</dict>

<!-- SCYTHE - BOTH DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_mage_dead</string>
		<string>flag</string><string>is</string><string>wraith_staff_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">scythe</string>
	<int name="castpoint">2200</int>

	<bool name="must-have-target">true</bool>
	<bool name="good-aim">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.9</float>
	<int name="melee-cooldown">1000</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">125</int>
	<int name="period">1000</int>
	<int name="period-rand">250</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-scythe</string>
		</dict>			
		
		<dict>
			<string name="class">Explode</string>
			
			<int name="min-radius">45</int>
			<int name="radius">45</int>
			<float name="dist-scaling">1000</float>
			<float name="team-dmg">0</float>
			
			<array name="effects">
				<dict>
					<string name="class">Damage</string>
					<int name="physical">100</int>
					<float name="armor-mul">0.75</float>
				</dict>
			</array>
		</dict>
		
		<dict>
			<string name="class">Nova</string>
			
			<int name="projectiles">SCYTHEMAGENOVA</int>
			<string name="projectile">actors/bosses/wraith/wraith_scythe_lurker_both.unit</string>
			<int name="dist">20</int>
		</dict>
	</array>
</dict>


<!-- SCYTHE DEAD -->
<dict>
	<string name="class">CompositeActorTriggeredSkill</string>
	<string name="trigger">OnDeath</string>
	<array name="actions">
		<dict>
			<string name="class">SetFlag</string>
			<bool name="value">true</bool>
			<string name="flag">wraith_scythe_dead</string>
		</dict>
		<dict>
			<string name="class">SpawnEffect</string>
			<string name="effect">actors/bosses/wraith/wraith_death.effect</string>
		</dict>
	</array>	
</dict>	


%elif STAFF
<!-- staff start at  1410 -->
<dict>
	<string name="class">CompositeActorSkill</string>
	<string name="anim">staff_intro</string>
	<string name="snd">event:/enemy/boss_wraith/attack-staff</string>

	<int name="charges">1</int>
	<bool name="must-see">false</bool>
	<int name="cooldown">0</int>
	<int name="castpoint">810</int>
	<int name="range">400</int>
	
	<array name="actions">
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">staff_area</string>
		</dict>
		
		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
			<bool name="safe-spawn">false</bool>
			<int name="spawn-dist">0</int>
		</dict>
	</array>
</dict>

<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraiths_activate</string>
		<string>flag</string><string>isnt</string><string>wraith_mage_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_scythe_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">staff</string>
	<int name="castpoint">2580</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.5</float>
	<int name="melee-cooldown">1500</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">200</int>
	<int name="period">1500</int>
	<int name="period-rand">750</int>

	<array name="actions">
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-staff</string>
		</dict>		
		
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">staff_area</string>
		</dict>
		
		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
			<bool name="safe-spawn">false</bool>
			<int name="spawn-dist">0</int>
		</dict>
	</array>
</dict>

<!-- STAFF - MAGE DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_mage_dead</string>
		<string>flag</string><string>isnt</string><string>wraith_scythe_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">staff</string>
	<int name="castpoint">2580</int>

	<bool name="must-have-target">true</bool>
	
	<int name="melee-range">35</int>
	<float name="melee-chance">0.5</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">200</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-staff</string>
		</dict>		
		
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">staff_area_mage</string>
		</dict>

		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
			<bool name="safe-spawn">false</bool>
			<int name="spawn-dist">0</int>
		</dict>
	</array>
</dict>

<!-- STAFF - SCYTHE DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>isnt</string><string>wraith_mage_dead</string>
		<string>flag</string><string>is</string><string>wraith_scythe_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">staff</string>
	<int name="castpoint">2580</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.5</float>
	<int name="melee-cooldown">1250</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">200</int>
	<int name="period">1250</int>
	<int name="period-rand">500</int>

	<array name="actions">
		
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-staff</string>
		</dict>		
		
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">staff_area_scythe</string>
		</dict>

		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
			<bool name="safe-spawn">false</bool>
			<int name="spawn-dist">0</int>
		</dict>
	</array>
</dict>

<!-- STAFF - BOTH DEAD -->
<dict>
	<string name="class">BossLichRandomSkill</string>
	
	<array name="conditional">
		<string>flag</string><string>is</string><string>wraith_mage_dead</string>
		<string>flag</string><string>is</string><string>wraith_scythe_dead</string>
	</array>
	
	<string name="start-snd">event:/enemy/boss_wraith/spawn</string>
	
	<string name="anim">staff</string>
	<int name="castpoint">2580</int>

	<bool name="must-have-target">true</bool>

	<int name="melee-range">35</int>
	<float name="melee-chance">0.7</float>
	<int name="melee-cooldown">1000</int>

	<string name="trigger">OnTime</string>
	<int name="max-range">200</int>
	<int name="period">1000</int>
	<int name="period-rand">250</int>

	<array name="actions">
		
		<dict>
			<string name="class">PlaySound</string>
			<string name="sound">event:/enemy/boss_wraith/attack-staff</string>
		</dict>		
		
		<dict>
			<string name="class">RaiseUnitEvent</string>
			<string name="name">staff_area_both</string>
		</dict>

		<dict>
			<string name="class">SpawnUnit</string>
			<string name="unit">actors/bosses/wraith/wraith_staff_area_slow.unit</string>
			<bool name="safe-spawn">false</bool>
			<int name="spawn-dist">0</int>
		</dict>
	</array>
</dict>

<!-- STAFF DEAD -->
<dict>
	<string name="class">CompositeActorTriggeredSkill</string>
	<string name="trigger">OnDeath</string>
	<array name="actions">
		<dict>
			<string name="class">SetFlag</string>
			<bool name="value">true</bool>
			<string name="flag">wraith_staff_dead</string>
		</dict>
		<dict>
			<string name="class">SpawnEffect</string>
			<string name="effect">actors/bosses/wraith/wraith_death.effect</string>
		</dict>
	</array>	
</dict>
%endif