<unit slot="doodad">
	<behavior class="Breakable">
		<bool name="shoot-through">true</bool>
		<bool name="walk-through">true</bool>
		<string name="break-sound">event:/item/break_sack</string>
		<string name="gore">effects/gibs/doodads/gib_container_crate_a.sval</string>
		
%if ITEM0
		<string name="loot">prefabs/coliseum/tweak/crowd_loot.sval:item_0</string>
%elif ITEM1
		<string name="loot">prefabs/coliseum/tweak/crowd_loot.sval:item_1</string>
%elif ITEM2
		<string name="loot">prefabs/coliseum/tweak/crowd_loot.sval:item_2</string>
%elif ITEM3
		<string name="loot">prefabs/coliseum/tweak/crowd_loot.sval:item_3</string>
%elif ITEM4
		<string name="loot">prefabs/coliseum/tweak/crowd_loot.sval:item_4</string>
%endif
	</behavior>

	<scenes default="1 2 3 4">
		<scene name="shared">
			<minimap_sprite layer="10" origin="6 6" texture="gui/minimap.png" frame="175 9 12 12" />
			
			<collision static="true">
				<circle sensor="true" shoot-through="false" aim-through="true" offset="0 0" radius="4"/>
			</collision>
		</scene>
		
		<scene name="1">
			<scene src="shared" />
			<effect src="effects/animations/dust_big.effect" />
			<sprite origin="8 12" looping="true" texture="doodads/generic/crowd_items.png" material="items/items.mats:food">	
				<frame time="100">80 0 16 16</frame>				
			</sprite>

		</scene>
		<scene name="2">
			<scene src="shared" />
			<effect src="effects/animations/dust_big.effect" />
			<sprite origin="8 12" looping="true" texture="doodads/generic/crowd_items.png" material="items/items.mats:food">	
				<frame time="100">80 16 16 16</frame>				
			</sprite>

		</scene>
		<scene name="3">
			<scene src="shared" />
			<effect src="effects/animations/dust_big.effect" />
			<sprite origin="8 12" looping="true" texture="doodads/generic/crowd_items.png" material="items/items.mats:food">	
				<frame time="100">80 32 16 16</frame>				
			</sprite>

		</scene>
		<scene name="4">
			<scene src="shared" />
			<effect src="effects/animations/dust_big.effect" />
			<sprite origin="8 12" looping="true" texture="doodads/generic/crowd_items.png" material="items/items.mats:food">	
				<frame time="100">80 48 16 16</frame>				
			</sprite>
		</scene>
		
	</scenes>
</unit>