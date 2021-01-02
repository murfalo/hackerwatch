<!-- Separator template -->
<rect id="template-separator" visible="false" width="366" height="3" spriteset="gui/variable/3pxbar_hor.sval" />

<!-- Character template -->
<details id="template-character" visible="false" func="details-toggled" spriteset="gui/variable/details_borders.sval" arrow-down="arrow-down" arrow-up="arrow-up">
	<rect id="header" width="358" height="28" flow="hbox">
		<!-- Unit preview -->
		<sprite src="box">
			<sprite src="char-shadow" offset="8 12" />
			<unit id="unit" width="18" height="18" anchor="0.6 0.8" />

			<!-- Merc frame -->
			<group id="merc-frame-unit" visible="false">
				<sprite src="merc-small-left" offset="2 2" />
				<sprite src="merc-small-right" anchor="1 0" offset="-2 2" />
			</group>
		</sprite>

		<!-- Portrait -->
		<portrait id="portrait" />

		<!-- Level -->
		<sprite src="box-wide">
			<text id="level" font="gui/fonts/arial11_bold.fnt" anchor="0.5 0.5" offset="1 0" />

			<!-- Merc frame -->
			<group id="merc-frame-level" visible="false">
				<sprite src="merc-left" offset="2 2" />
				<sprite src="merc-right" anchor="1 0" offset="-2 2" />
			</group>
		</sprite>

		<rect width="3" height="28" spriteset="gui/variable/3pxbar_vert.sval" />

		<!-- Name -->
		<rect
%if LEDGER_BUTTON
				width="227"
%else
				width="255"
%endif
				height="28" spriteset="gui/variable/block_borders.sval">
			<text id="name" font="gui/fonts/arial11.fnt" text="Bob the Ranger" anchor="0.5 0.5" />

			<!-- Merc frame -->
			<group id="merc-frame-name" visible="false">
				<sprite src="merc-left" offset="2 2" />
				<sprite src="merc-right" anchor="1 0" offset="-2 2" />
			</group>
		</rect>

%if LEDGER_BUTTON
		<!-- Delete button -->
		<sprite src="char-button24-frame">
			<spritebutton id="button-delete" spriteset="char-button24" offset="2 2">
				<sprite src="icon-char-delete" anchor="0.5 0.5" />
			</spritebutton>
		</sprite>
%endif
	</rect>
	<grouprect id="details" inner="true" width="358" flow="vbox" spriteset="gui/variable/bigwindow_borders.sval" color="#202a26FF" shadow="#0c120fFF" shadowsize="2" />
</details>

<!-- Empty stats template -->
<rect id="template-stats-empty" visible="false" width="354" height="36" offset="2 0">
	<text text=".guildhall.stats.empty" font="gui/fonts/arial11.fnt" anchor="0.5 0.5" />
</rect>

<!-- Stats header template -->
<rect id="template-stats-header" visible="false" width="354" height="18" flow="hbox" offset="2 0">
	<rect width="269" height="18" spriteset="gui/variable/headline_hor.sval">
		<text id="category" font="gui/fonts/arial11_bold.fnt" anchor="0.5 0.5" />
	</rect>
	<rect width="85" height="18" spriteset="gui/variable/headline_hor.sval">
		<text font="gui/fonts/arial11_bold.fnt" anchor="0.5 0.5" text=".guildhall.stats.lifetime" />
	</rect>
</rect>

<!-- Stats separator template -->
<rect id="template-stats-separator" visible="false" offset="2 2" width="354" height="3" spriteset="gui/variable/3pxbar_hor.sval" />

<!-- Stats template -->
<rect id="template-stats" visible="false" offset="2 0" width="354" height="18">
	<text id="name" font="gui/fonts/arial11.fnt" offset="4 0" />
	<rect width="85" height="15" offset="269 0">
		<text id="value" font="gui/fonts/arial11.fnt" anchor="0.5 0" />
	</rect>
</rect>
