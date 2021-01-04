<unit netsync="none">
	<behavior class="ComboNovaProjectile">
		<string name="anim">idle 8</string>
		<float name="speed">5</float>
		<int name="ttl">1000</int>
		<array name="effects">
			<dict>
				<string name="class">Damage</string>
				<int name="magical">16</int>
			</dict>
		</array>
		<dict name="effect-params">
			<float name="height">3</float>
		</dict>
	</behavior>

	<scenes start="combo">
		<scene name="combo">
			<collision static="false">
				<circle offset="0 0" radius="3" projectile="true" />
			</collision>
			
			%if STANDARD
				<effect src="players/combo/nova/combo_nova_standard_1.effect" />
			%elif FIELD              
				<effect src="players/combo/nova/combo_nova_field_1.effect" />
			%elif LIGHTNING          
				<effect src="players/combo/nova/combo_nova_lightning_1.effect" />
			%elif PULSE              
				<effect src="players/combo/nova/combo_nova_pulse_1.effect" />
			%elif SPIN               
				<effect src="players/combo/nova/combo_nova_spin_1.effect" />
			%endif	

			
			
		</scene>
	</scenes>
</unit>
