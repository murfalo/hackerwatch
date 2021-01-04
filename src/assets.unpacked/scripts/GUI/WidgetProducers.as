namespace WidgetProducers
{
	void LoadBase(GUIBuilder@ builder)
	{
		//builder.AddWidgetProducer("gui", PrintWidget);
		builder.AddWidgetProducer("group", LoadGroupWidget);
		builder.AddWidgetProducer("grouprect", LoadGroupRectWidget);
		builder.AddWidgetProducer("text", LoadTextWidget);
		builder.AddWidgetProducer("systext", LoadSysTextWidget);
		builder.AddWidgetProducer("sprite", LoadSpriteWidget);
		builder.AddWidgetProducer("dyesprite", LoadDyeSpriteWidget);
		builder.AddWidgetProducer("portrait", LoadPortraitWidget);
		builder.AddWidgetProducer("radialsprite", LoadRadialSpriteWidget);
		builder.AddWidgetProducer("rect", LoadRectWidget);
		builder.AddWidgetProducer("clip", LoadClipWidget);
		builder.AddWidgetProducer("scrollrect", LoadScrollableRectWidget);
		builder.AddWidgetProducer("flag", LoadFlagWidget);
		builder.AddWidgetProducer("transform", LoadTransformWidget);
		builder.AddWidgetProducer("button", LoadButtonWidget);
		builder.AddWidgetProducer("spritebutton", LoadSpriteButtonWidget);
		builder.AddWidgetProducer("colorbutton", LoadColorButtonWidget);
		builder.AddWidgetProducer("dyeshades", LoadDyeShadesWidget);
		builder.AddWidgetProducer("scalebutton", LoadScalableSpriteButtonWidget);
		builder.AddWidgetProducer("scaleiconbutton", LoadScalableSpriteIconButtonWidget);
		builder.AddWidgetProducer("slider", LoadSliderWidget);
		builder.AddWidgetProducer("unit", LoadUnitWidget);
		builder.AddWidgetProducer("textinput", LoadTextInputWidget);
		builder.AddWidgetProducer("bar", LoadBarWidget);
		builder.AddWidgetProducer("scrollbar", LoadScrollbarWidget);
		builder.AddWidgetProducer("checkbox", LoadCheckboxWidget);
		builder.AddWidgetProducer("colorcheckbox", LoadColorCheckboxWidget);
		builder.AddWidgetProducer("checkboxgroup", LoadCheckBoxGroupWidget);
		builder.AddWidgetProducer("blink", LoadBlinkWidget);
		builder.AddWidgetProducer("filteredlist", LoadFilteredListWidget);
		builder.AddWidgetProducer("dotbar", LoadDotbarWidget);
		builder.AddWidgetProducer("spritebar", LoadSpriteBarWidget);
		builder.AddWidgetProducer("details", LoadDetailsWidget);
		builder.AddWidgetProducer("buff", LoadBuffWidget);
		builder.AddWidgetProducer("topnumber", LoadTopNumberIconWidget);
		builder.AddWidgetProducer("knobslider", LoadKnobSliderWidget);
	}

	void LoadIngame(GUIBuilder@ builder)
	{
		builder.AddWidgetProducer("inventory", LoadInventoryWidget);
		builder.AddWidgetProducer("inventoryitem", LoadInventoryItemWidget);
		builder.AddWidgetProducer("shopitem", LoadShopButtonWidget);
		builder.AddWidgetProducer("upgradeshopitem", LoadUpgradeShopButtonWidget);
		builder.AddWidgetProducer("favorbutton", LoadFavorButtonWidget);
		builder.AddWidgetProducer("upgradeicon", LoadUpgradeIconWidget);
		builder.AddWidgetProducer("skill", LoadSkillWidget);
		builder.AddWidgetProducer("bossbar", LoadBossBarWidget);
		builder.AddWidgetProducer("waypoints", LoadWaypointMarkersWidget);
		builder.AddWidgetProducer("coop-player", LoadCoopPlayerWidget);

		Hooks::Call("LoadWidgetProducers", @builder);
	}

	void LoadMainMenu(GUIBuilder@ builder)
	{
		builder.AddWidgetProducer("menu_control_input", LoadMenuControlInput);
		builder.AddWidgetProducer("game_chat", LoadGameChatWidget);
		builder.AddWidgetProducer("menu_lobby_player", LoadMenuLobbyPlayer);
		builder.AddWidgetProducer("menu_serverlist_item", LoadMenuServerListItemWidget);
		builder.AddWidgetProducer("menu_birds", LoadMenuBirdsWidget);
	}
}
