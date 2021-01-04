class DrinksMenuContent : ShopMenuContent
{
	TextWidget@ m_wHeaderText;

	ScrollableWidget@ m_wList;

	Widget@ m_wTemplateItem;
	Widget@ m_wTemplateSprite;

	DrinksMenuContent(ShopMenu@ shopMenu)
	{
		super(shopMenu);
	}

	void OnShow() override
	{
		@m_wHeaderText = cast<TextWidget>(m_widget.GetWidgetById("headertext"));

		@m_wList = cast<ScrollableWidget>(m_widget.GetWidgetById("list"));

		@m_wTemplateItem = m_widget.GetWidgetById("template-item");
		@m_wTemplateSprite = m_widget.GetWidgetById("template-sprite");

		ReloadList();
	}

	void ReloadList() override
	{
		int level = m_shopMenu.m_currentShopLevel;

		auto record = GetLocalPlayerRecord();

%if HARDCORE
		int titleIndex = record.GetTitleIndex();
		auto titleList = record.GetTitleList();
%endif

		int numDrinks = level + 2;
		bool hadEnough = (int(record.tavernDrinks.length()) >= numDrinks);

		if (hadEnough)
			m_wHeaderText.SetText(Resources::GetString(".shop.drinks.message.enough"));
		else
			m_wHeaderText.SetText(record.tavernDrinks.length() + " / " + numDrinks);

		m_wList.PauseScrolling();
		m_wList.ClearChildren();

		for (uint i = 0; i < g_tavernDrinks.length(); i++)
		{
			auto drink = g_tavernDrinks[i];
			if (drink.localCount == -1 && !drink.unlocked)
				continue;

%if HARDCORE
			bool canAfford = Currency::CanAfford(record, drink.cost) && titleIndex >= int(drink.quality) - 1;
%else
			bool canAfford = (drink.localCount > 0 || Currency::CanAfford(record, drink.cost) || drink.unlocked);
%endif

			bool hasConsumed = false;
			for (uint j = 0; j < record.tavernDrinks.length(); j++)
			{
				if (drink.idHash == HashString(record.tavernDrinks[j]))
				{
					hasConsumed = true;
					break;
				}
			}

			Widget@ wNewItem = null;

			if (canAfford && !hasConsumed && !hadEnough)
			{
				auto wNewButton = cast<ScalableSpriteButtonWidget>(m_wTemplateItem.Clone());
				wNewButton.m_func = "buy-drink " + drink.idHash;

				@wNewItem = wNewButton;
			}
			else
			{
				@wNewItem = m_wTemplateSprite.Clone();

				if (hasConsumed)
				{
					auto wCheck = wNewItem.GetWidgetById("icon-check");
					if (wCheck !is null)
						wCheck.m_visible = true;
				}
				else if (hadEnough)
				{
					auto wLock = wNewItem.GetWidgetById("icon-lock");
					if (wLock !is null)
						wLock.m_visible = true;
				}
			}

			if (drink.quality != ActorItemQuality::Common)
			{
				auto wQuality = cast<RectWidget>(wNewItem.GetWidgetById("quality"));
				if (wQuality !is null)
				{
					wQuality.m_parent.m_visible = true;
					wQuality.m_color = GetItemQualityColor(drink.quality);
				}
			}

			auto wIcon = cast<SpriteWidget>(wNewItem.GetWidgetById("icon"));
			if (wIcon !is null)
			{
				wIcon.SetSprite(drink.icon);
				if (!canAfford && !hasConsumed)
					wIcon.m_colorize = true;
			}

			auto wCount = cast<TextWidget>(wNewItem.GetWidgetById("count"));
			if (wCount !is null)
			{
%if HARDCORE
				wCount.m_visible = false;
%else
				wCount.SetText("" + drink.localCount);
%endif
			}

			if (wNewItem !is null)
			{
				wNewItem.SetID("");
				wNewItem.m_visible = true;

				wNewItem.m_tooltipTitle = "\\c" + GetItemQualityColorString(drink.quality) + utf8string(Resources::GetString(drink.name)).toUpper().plain();
				wNewItem.m_tooltipText = Resources::GetString(drink.desc);

%if HARDCORE
				if (titleIndex < int(drink.quality) - 1)
				{
					auto titleRequired = titleList.GetTitle(int(drink.quality) - 1);
					wNewItem.m_tooltipText += "\n\\cff0000" + Resources::GetString(".shop.menu.restriction.player-title", {
						{ "title", Resources::GetString(titleRequired.m_name) }
					});
				}
%endif

%if !HARDCORE
				if (drink.localCount == 0)
%endif
					wNewItem.AddTooltipSub(m_def.GetSprite("icon-gold"), formatThousands(drink.cost));

				m_wList.AddChild(wNewItem);
			}
		}

		m_wList.ResumeScrolling();

		m_shopMenu.DoLayout();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "buy-drink")
		{
			uint id = parseUInt(parse[1]);

			auto drink = GetTavernDrink(id);
			if (drink is null)
			{
				PrintError("Couldn't find drink for ID " + id + "!");
				return;
			}

			auto player = GetLocalPlayer();

%if !HARDCORE
			if (drink.localCount <= 0)
			{
%endif
				if (!Currency::CanAfford(player.m_record, drink.cost))
				{
					PrintError("Not enough gold for that drink. How did you even trigger this error");
					return;
				}

				Currency::Spend(player.m_record, drink.cost);
%if !HARDCORE
				drink.localCount = 0;
			}
			else
				drink.localCount--;
%endif

			player.AddDrink(drink);
			player.m_record.tavernDrinksBought.insertLast(drink.id);
			player.RefreshModifiers();

			PlaySound2D(Resources::GetSoundEvent("event:/ui/swallow_drink"));

			ReloadList();
		}
		else
			ShopMenuContent::OnFunc(sender, name);
	}

	string GetTitle() override
	{
		return Resources::GetString(".shop.drinks");
	}

	string GetGuiFilename() override
	{
		return "gui/shop/drinks.gui";
	}
}
