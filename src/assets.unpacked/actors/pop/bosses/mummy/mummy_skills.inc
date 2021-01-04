			<dict>
				<string name="class">SpewSkill</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>puke</string>
				</array>
				<string name="anim">spit 8</string>
				
				<string name="start-snd">event:/enemy/boss_mummy/flies-start</string>
				<string name="snd">event:/enemy/boss_mummy/flies</string>

				<string name="offset">attack-pos</string>
				<bool name="must-see">false</bool>
				<bool name="hold-dir">false</bool>
				<int name="cooldown-start">30000</int>
				<int name="cooldown">25000</int>
				<int name="castpoint">2200</int>
				<int name="duration">4000</int>
				<int name="range">999</int>
				<int name="spread">20</int>
				<int name="rate">20</int>
				<string name="projectile">actors/pop/bosses/mummy/fly_projectile.unit</string>
			</dict>
			
			%// Stomp
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>stomp_regular</string>
				</array>
				<string name="anim">stomp 8</string>
				<int name="cooldown">500</int>
				<int name="castpoint">600</int>
				<int name="range">60</int>
				<string name="offset">attack-pos</string>
				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">effects/animations/impact_smash.effect</string>
						<int name="min-radius">16</int>
						<int name="radius">16</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.35</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_mummy/stomp</string>
					</dict>
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">stomp_regular</string>
					</dict>
				</array>
			</dict>
			
			%// Stomp +range
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>stomp_ranged</string>
				</array>
				<string name="anim">stomp 8</string>
				<int name="cooldown">12500</int>
				<int name="castpoint">600</int>
				<int name="range">999</int>
				<int name="min-range">100</int>
				<string name="offset">attack-pos</string>
				<array name="actions">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">effects/animations/impact_smash.effect</string>
						<int name="min-radius">16</int>
						<int name="radius">16</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.35</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_mummy/stomp</string>
					</dict>
					<dict>
						<string name="class">RaiseGlobalEvent</string>
						<string name="name">stomp_ranged</string>
					</dict>
				</array>
			</dict>			

			%// Short Charge
			<dict>
				<string name="class">ChargeStrike</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>charge_short</string>
				</array>
				<string name="anim">charge 8</string>
				<string name="anim-stop">charge_finish 8</string>
				
				<string name="start-snd">event:/enemy/boss_mummy/charge</string>
				
				<bool name="must-see">false</bool>
				<int name="cooldown-start">2000</int>
				<int name="cooldown">1000</int>
				<int name="range">120</int>
				<int name="min-range">60</int>
				<float name="speed">10</float>
				<int name="air-time">390</int>
				<int name="hold-frame">500</int>
				<int name="jump-height">0</int>
				<string name="offset">attack-pos</string>
				
				<int name="ray-num">6</int>
				<int name="ray-width">18</int>
				<float name="ray-length">5</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">100</int>
					</dict>
				</array>

				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">effects/animations/impact_smash.effect</string>
						<int name="min-radius">20</int>
						<int name="radius">20</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.35</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_mummy/stomp</string>
					</dict>
					<dict name="effect">
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/pop/bosses/mummy/dust_large.effect</string>
					</dict>
				</array>
			</dict>
			
			%// Long Charge
			<dict>
				<string name="class">ChargeStrike</string>
				<array name="conditional">
					<string>flag</string><string>is</string><string>charge_long</string>
				</array>
				<string name="anim">charge 8</string>
				<string name="anim-stop">charge_finish 8</string>
				

				<string name="start-snd">event:/enemy/boss_mummy/charge-long</string>
				
				<bool name="must-see">false</bool>
				<int name="cooldown-start">2000</int>
				<int name="cooldown">2000</int>
				<int name="range">999</int>
				<int name="min-range">120</int>
				<float name="speed">10</float>
				<int name="air-time">780</int>
				<int name="hold-frame">500</int>
				<int name="jump-height">0</int>
				<string name="offset">attack-pos</string>
				
				<int name="ray-num">6</int>
				<int name="ray-width">18</int>
				<float name="ray-length">5</float>

				<array name="effects">
					<dict>
						<string name="class">Damage</string>
						<int name="physical">100</int>
					</dict>
				</array>

				<array name="finish-effects">
					<dict>
						<string name="class">Explode</string>
						<string name="fx">effects/animations/impact_smash.effect</string>
						<int name="min-radius">20</int>
						<int name="radius">20</int>
						<float name="dist-scaling">1000</float>
						<float name="team-dmg">0</float>
						<array name="effects">
							<dict>
								<string name="class">Damage</string>
								<int name="physical">100</int>
								<float name="armor-mul">0.35</float>
								<bool name="melee">true</bool>
							</dict>
						</array>
					</dict>
					<dict>
						<string name="class">PlaySound</string>
						<string name="sound">event:/enemy/boss_mummy/stomp</string>
					</dict>
					<dict name="effect">
						<string name="class">SpawnEffect</string>
						<string name="effect">actors/pop/bosses/mummy/dust_large.effect</string>
					</dict>					
				</array>
			</dict>


			
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.75</float>
					
					<string>flag</string><string>is</string><string>curse</string>
				</array>
				<string name="start-snd">event:/enemy/boss_mummy/curse</string>
				<int name="charges">1</int>
				<string name="anim">curse</string>
				<int name="cooldown">0</int>
				<int name="castpoint">1750</int>
				<int name="range">999</int>
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_stable.unit</string>
						<vec2 name="offset">12 -10</vec2>
					</dict>
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_twitch.unit</string>
						<vec2 name="offset">-12 -10</vec2>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.5</float>
					
					<string>flag</string><string>is</string><string>curse</string>
				</array>
				<string name="start-snd">event:/enemy/boss_mummy/curse</string>
				<int name="charges">1</int>
				<string name="anim">curse</string>
				<int name="cooldown">0</int>
				<int name="castpoint">1750</int>
				<int name="range">999</int>
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_stable.unit</string>
						<vec2 name="offset">12 -10</vec2>
					</dict>
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_twitch.unit</string>
						<vec2 name="offset">-12 -10</vec2>
					</dict>
				</array>
			</dict>	
			
			<dict>
				<string name="class">CompositeActorSkill</string>
				<array name="conditional">
					<string>hp</string><string>lt</string><float>0.25</float>
					
					<string>flag</string><string>is</string><string>curse</string>
				</array>
				<string name="start-snd">event:/enemy/boss_mummy/curse</string>
				<int name="charges">1</int>
				<string name="anim">curse</string>
				<int name="cooldown">0</int>
				<int name="castpoint">1750</int>
				<int name="range">999</int>
				<array name="actions">
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_stable.unit</string>
						<vec2 name="offset">12 -10</vec2>
					</dict>
					<dict>
						<string name="class">ShootProjectile</string>
						<string name="projectile">actors/pop/bosses/mummy/curseball_twitch.unit</string>
						<vec2 name="offset">-12 -10</vec2>
					</dict>
				</array>
			</dict>
			
			<dict>
				<string name="class">CompositeActorTriggeredSkill</string>
				<string name="trigger">OnDeath</string>
				<array name="actions">
					<dict>
						<string name="class">SpawnUnit</string>
						<string name="unit">actors/pop/bosses/mummy/mummy_corpse.unit</string>
					</dict>
				</array>
			</dict>
