			<dict>
				<string name="class">NovaSkill</string>
				<string name="anim">attack</string>
				<bool name="must-see">false</bool>
				<int name="cooldown-start">500</int>
				<int name="cooldown">8000</int>
				<int name="castpoint">2000</int>
				<int name="min-range">0</int>
				<int name="range">1000</int>
				<string name="fire-snd">event:/enemy/hellcube/attack</string>
				<int name="proj-count">24</int>
				<float name="proj-dist">16</float>
				%if PRISON
				<string name="projectile">actors/special/hellcube/projectile_prison.unit</string>
				%elif ARMORY
				<string name="projectile">actors/special/hellcube/projectile_armory.unit</string>
				%elif ARCHIVES
				<string name="projectile">actors/special/hellcube/projectile_archives.unit</string>
				%endif
			</dict>