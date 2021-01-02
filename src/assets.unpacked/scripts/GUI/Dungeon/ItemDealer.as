class ItemDealer : ScriptWidgetHost
{
	Widget@ m_wItemList;
	Widget@ m_wItemTemplate;

	Widget@ m_wQualityList;
	Widget@ m_wQualityTemplate;

	ScalableSpriteButtonWidget@ m_wGamble;
	RectWidget@ m_wFinalItem;

	ItemDealer(SValue& params)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wItemList = m_widget.GetWidgetById("list-items");
		@m_wItemTemplate = m_widget.GetWidgetById("template-item");

		@m_wQualityList = m_widget.GetWidgetById("list-qualities");
		@m_wQualityTemplate = m_widget.GetWidgetById("template-quality");

		@m_wGamble = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("gamble"));
		@m_wFinalItem = cast<RectWidget>(m_widget.GetWidgetById("final-item"));

		auto gm = cast<Campaign>(g_gameMode);
		auto record = GetLocalPlayerRecord();

		if (record.itemDealerSaved == gm.m_levelCount + 1)
		{
			auto finalItem = g_items.GetItem(record.itemDealerReward);
			if (finalItem !is null)
			{
				ReloadItemList(false);
				ShowFinalItem(finalItem);
			}
			else
			{
				//???
				ReloadItemList();
			}
		}
		else
			ReloadItemList();

		UpdateButton();

		PauseGame(true, true);
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void UpdateButton()
	{
		int numSelected = 0;
		for (uint i = 0; i < m_wItemList.m_children.length(); i++)
		{
			auto wItem = cast<CheckBoxWidget>(m_wItemList.m_children[i]);
			if (wItem !is null && wItem.IsChecked())
				numSelected++;
		}

		m_wGamble.m_enabled = (numSelected > 0);
		m_wGamble.m_tooltipTitle = Resources::GetString(".itemdealer.tooltip.title");
		if (numSelected == 1)
			m_wGamble.m_tooltipText = Resources::GetString(".itemdealer.tooltip.single");
		else
			m_wGamble.m_tooltipText = Resources::GetString(".itemdealer.tooltip.plural", { { "num", numSelected } });

		int points = GetCurrentPoints();
		auto svReward = GetReward(points);

		array<ActorItemQuality> qualities;

		if (svReward !is null)
		{
			auto arrQualities = GetParamArray(UnitPtr(), svReward, "qualities");
			for (uint i = 0; i < arrQualities.length(); i++)
				qualities.insertLast(ParseActorItemQuality(arrQualities[i].GetString()));
		}

		m_wQualityList.ClearChildren();

		for (int i = 1; i < 6; i++)
		{
			auto quality = ActorItemQuality(i);
			string qualityName = GetItemQualityName(quality);
			vec4 qualityColor = GetItemQualityColor(quality);

			int num = 0;
			float ratio = 0.0f;

			for (uint j = 0; j < qualities.length(); j++)
			{
				if (qualities[j] == quality)
					num++;
			}

			if (qualities.length() > 0)
				ratio = num / float(qualities.length());

			auto wNewQuality = m_wQualityTemplate.Clone();
			wNewQuality.SetID("");
			wNewQuality.m_visible = true;

			wNewQuality.m_tooltipTitle = "\\c" + GetItemQualityColorString(quality) + Resources::GetString(".quality." + qualityName);

			auto wQuality = cast<SpriteWidget>(wNewQuality.GetWidgetById("quality"));
			if (wQuality !is null)
				wQuality.SetSprite("quality-" + qualityName);

			auto wPercentage = cast<TextWidget>(wNewQuality.GetWidgetById("percentage"));
			if (wPercentage !is null)
			{
				wPercentage.m_color = qualityColor;
				wPercentage.SetText(ceil(ratio * 100.0f) + "%");
			}

			m_wQualityList.AddChild(wNewQuality);
		}
	}

	void ShowFinalItem(ActorItem@ item)
	{
		auto record = GetLocalPlayerRecord();

		SetActorItemOnGui(record, m_wFinalItem, item);

		m_wFinalItem.m_color = GetItemQualityBackgroundColor(item.quality);

		m_wGamble.m_enabled = false;
		m_wGamble.m_tooltipTitle = "";
		m_wGamble.m_tooltipText = "";
	}

	void ReloadItemList(bool enabled = true)
	{
		m_wItemList.ClearChildren();

		auto record = GetLocalPlayerRecord();
		for (uint i = 0; i < record.items.length(); i++)
		{
			auto item = g_items.GetItem(record.items[i]);
			if (item is null)
			{
				PrintError("Couldn't find item at index " + i);
				continue;
			}

			auto wNewItem = cast<CheckBoxWidget>(AddActorItemToGuiList(record, m_wItemList, m_wItemTemplate, item));
			if (wNewItem !is null)
				wNewItem.m_enabled = enabled;
		}

		m_wGamble.m_enabled = false;
	}

	int GetCurrentPoints()
	{
		auto player = GetLocalPlayer();

		int points = 0;
		for (uint i = 0; i < m_wItemList.m_children.length(); i++)
		{
			auto wItem = cast<CheckBoxWidget>(m_wItemList.m_children[i]);
			if (wItem is null || !wItem.IsChecked())
				continue;

			auto item = g_items.GetItem(wItem.m_value);
			if (item is null)
				continue;

			switch (item.quality)
			{
				case ActorItemQuality::Common: points += 1; break;
				case ActorItemQuality::Uncommon: points += 3; break;
				case ActorItemQuality::Rare: points += 7; break;
				case ActorItemQuality::Epic: points += 12; break;
				case ActorItemQuality::Legendary: points += 24; break;
			}
		}
		return points;
	}

	SValue@ GetReward(int points)
	{
		auto svalRewards = Resources::GetSValue("tweak/itemdealer.sval");
		auto arrRewards = svalRewards.GetArray();
		for (uint i = 0; i < arrRewards.length(); i++)
		{
			auto sv = arrRewards[i];

			int minPoints = GetParamInt(UnitPtr(), sv, "min-points", false);
			if (points > minPoints)
				return sv;
		}
		return null;
	}

	void CommitGamble()
	{
		auto gm = cast<Campaign>(g_gameMode);

		auto player = GetLocalPlayer();
		if (player is null)
		{
			PrintError("Player is dead!");
			return;
		}

		int points = GetCurrentPoints();

		int numItemsLost = 0;
		for (uint i = 0; i < m_wItemList.m_children.length(); i++)
		{
			auto wItem = cast<CheckBoxWidget>(m_wItemList.m_children[i]);
			if (wItem is null || !wItem.IsChecked())
				continue;

			auto item = g_items.GetItem(wItem.m_value);
			if (item is null)
				continue;

			player.TakeItem(item);
			player.m_record.itemsRecycled.insertLast(item.id);
			numItemsLost++;
		}

		Platform::Service.UnlockAchievement("item_dealer_used");

		Stats::Add("item-dealer", 1, player.m_record);
		Stats::Add("item-dealer-lost", numItemsLost, player.m_record);

		auto svReward = GetReward(points);
		if (svReward !is null)
		{
			array<ActorItemQuality> randomQualities;

			auto arrQualities = GetParamArray(UnitPtr(), svReward, "qualities");
			for (uint j = 0; j < arrQualities.length(); j++)
				randomQualities.insertLast(ParseActorItemQuality(arrQualities[j].GetString()));

			int randomIndex = randi(randomQualities.length());
			ActorItemQuality randomQuality = randomQualities[randomIndex];

			auto newItem = g_items.TakeRandomItem(randomQuality);
			if (newItem is null)
			{
				PrintError("Couldn't find a new random item for quality " + randomQuality);
				return;
			}

			if (randomQuality == ActorItemQuality::Legendary)
				Platform::Service.UnlockAchievement("item_dealer_legendary");

			player.AddItem(newItem);

			player.m_record.itemDealerSaved = gm.m_levelCount + 1;
			player.m_record.itemDealerReward = newItem.id;

			ShowFinalItem(newItem);
		}

		ReloadItemList(false);
	}

	void Stop() override
	{
		ScriptWidgetHost::Stop();

		PauseGame(false, true);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Stop();
		else if (name == "gamble")
			CommitGamble();
		else if (name == "item-checked")
			UpdateButton();
	}
}
