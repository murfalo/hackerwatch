class SarcophagusUI : ScriptWidgetHost
{
	WorldScript::Sarcophagus@ m_sarcophagusScript;

	ScalableSpriteButtonWidget@ m_wButtonAccept;

	Widget@ m_wTemplateItem;
	Widget@ m_wTemplateSeparator;
	Widget@ m_wList;

	array<ActorItem@> m_items;

	SarcophagusUI()
	{
	}

	SarcophagusUI(SValue& params)
	{
		super();
	}
	

	int GetCurseCost(ActorItemQuality quality)
	{
		switch (quality)
		{
			case ActorItemQuality::Common: return 1;
			case ActorItemQuality::Uncommon: return 2;
			case ActorItemQuality::Rare: return 5;
			case ActorItemQuality::Epic: return 10;
		}
		PrintError("Unexpected item quality " + int(quality) + "!");
		return 0;
	}

	int GetCurseCost()
	{
		int value = 0;
		auto selectedItems = GetSelectedItems();
		for (uint i = 0; i < selectedItems.length(); i++)
			value += GetCurseCost(selectedItems[i].quality);
		return int(ceil(pow(value, 1.7)));
	}

	array<ActorItem@> GetSelectedItems()
	{
		array<ActorItem@> ret;

		int itemIndex = 0;
		for (uint i = 0; i < m_wList.m_children.length(); i++)
		{
			auto wChild = cast<CheckBoxWidget>(m_wList.m_children[i]);
			if (wChild is null)
				continue;

			auto item = m_items[itemIndex++];

			if (wChild.IsChecked())
				ret.insertLast(item);
		}

		return ret;
	}

	void Initialize(bool loaded) override
	{
		auto record = GetLocalPlayerRecord();

		auto gm = cast<Campaign>(g_gameMode);

		@m_wTemplateItem = m_widget.GetWidgetById("template-item");
		@m_wTemplateSeparator = m_widget.GetWidgetById("template-separator");
		@m_wList = m_widget.GetWidgetById("item-list");

		@m_wButtonAccept = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("button-accept"));

		if (record.sarcophagusItemsSaved == gm.m_levelCount + 1)
		{
			// Load old items
			for (uint i = 0; i < record.sarcophagusItems.length(); i++)
			{
				uint id = record.sarcophagusItems[i];

				auto item = g_items.GetItem(id);
				if (item is null)
				{
					PrintError("Unable to find item with ID " + id);
					continue;
				}

				AddItemToList(item);
			}
		}
		else
		{
			// Take some new items
			auto svSarcophagus = Resources::GetSValue("tweak/sarcophagus.sval");
			auto arrActs = svSarcophagus.GetArray();

			record.sarcophagusItems.removeRange(0, record.sarcophagusItems.length());
			record.sarcophagusItemsSaved = gm.m_levelCount + 1;

			ivec3 lvl = CalcLevel(gm.m_levelCount);
			auto svAct = arrActs[lvl.x];

			array<SValue@> arrQualities = GetParamArray(UnitPtr(), svAct, "items");
			int numQualities = 5;

			array<ActorItem@> chosenItems;

			for (int i = 0; i < numQualities; i++)
			{
				int index = randi(arrQualities.length());
				auto quality = ParseActorItemQuality(arrQualities[index].GetString());
				arrQualities.removeAt(index);

				auto item = g_items.TakeRandomItem(quality);
				if (item !is null)
					chosenItems.insertLast(item);
			}

			chosenItems.sortAsc();

			for (uint i = 0; i < chosenItems.length(); i++)
			{
				auto item = chosenItems[i];
				AddItemToList(item);
				record.sarcophagusItems.insertLast(item.idHash);
			}
		}

		UpdateCurseValue();
	}

	void AddItemToList(ActorItem@ item)
	{
		auto record = GetLocalPlayerRecord();

		AddActorItemToGuiList(record, m_wList, m_wTemplateItem, item);

		auto wNewSeparator = m_wTemplateSeparator.Clone();
		wNewSeparator.SetID("");
		wNewSeparator.m_visible = true;
		m_wList.AddChild(wNewSeparator);

		m_items.insertLast(item);
	}

	void UpdateCurseValue()
	{
		int value = GetCurseCost();

		m_wButtonAccept.m_enabled = (value > 0);

		auto wCurseContainer = m_widget.GetWidgetById("curse-container");
		if (wCurseContainer !is null)
		{
			wCurseContainer.m_tooltipText = Resources::GetString(".sarcophagus.cursehelp", {
				{ "chance", round((1.0f - pow(0.99f, value)) * 100.0f, 1) },
				{ "damage", round((2.0f + 0.05f * value) * 100.0f, 1) }
			});
		}

		auto wCurseValue = cast<TextWidget>(m_widget.GetWidgetById("curse-value"));
		if (wCurseValue !is null)
			wCurseValue.SetText("+" + value);
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void OnFunc(Widget@ sender, string name) override
	{
		auto parse = name.split(" ");
		if (parse[0] == "stop")
			Stop();
		else if (parse[0] == "selection-changed")
			UpdateCurseValue();
		else if (parse[0] == "accept")
		{
			auto record = GetLocalPlayerRecord();

			int value = GetCurseCost();
			auto selectedItems = GetSelectedItems();

			auto player = cast<Player>(record.actor);
			if (player is null)
			{
				PrintError("Can't apply sarcophagus because player is dead!");
				return;
			}

			for (uint i = 0; i < selectedItems.length(); i++)
				player.AddItem(selectedItems[i]);

			player.m_record.GiveCurse(value);
			player.m_record.sarcophagusItemsSaved = -1;

			m_sarcophagusScript.OnUsed();

			PlaySound2D(Resources::GetSoundEvent("event:/ui/sarcophagus-close"));

			//TODO: Temporary?
			Stop();
		}
	}

	void Stop() override
	{
		m_sarcophagusScript.Stop();
	}
}
