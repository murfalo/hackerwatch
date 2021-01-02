<!-- Character buttons -->
<spritebutton id="player-button-left" candoubleclick="false" func="char-prev" spriteset="arrow-left" offset="0 0" />
<portrait id="portrait" offset="12 0" />
<spritebutton id="player-button-right" candoubleclick="false" func="char-next" spriteset="arrow-right" offset="40 0" />

<!-- Header -->
<rect offset="52 0" width="276" height="28">
	<sprite src="character-info-frame" />

	<rect id="playerheader" offset="3 0" width="273" height="28" color="#202a26FF" shadow="#000000af" shadowsize="2">
		<clip width="273" height="28">
			<group inner="true" anchor="0.5 0" flow="hbox" spacing="3">
				<text id="playername" font="gui/fonts/arial11_bold.fnt" text="XXX" color="#0067FFFF" />

				<!-- DLC's -->
				<sprite id="dlc-pop" visible="false" src="icon-dlc-pop" anchor="0 0.5" offset="0 1" />
				<sprite id="dlc-wh" visible="false" src="icon-dlc-wh" anchor="0 0.5" offset="0 1" />
				<sprite id="dlc-mt" visible="false" src="icon-dlc-mt" anchor="0 0.5" offset="0 1" />
			</group>
			<text id="playertitle" font="gui/fonts/arial11.fnt" text="XXX" anchor="0.5 1" />
		</clip>
	</rect>
</rect>

<!-- Separator line between header and lower contents -->
<sprite src="frame-line-horizontal" offset="0 28" />
