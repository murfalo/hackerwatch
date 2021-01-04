class LootBoxItemAnimator
{
	LootBox@ m_owner;
	InventoryItemWidget@ m_wItem;
	InventoryItemWidget@ m_wItemNew;
	float m_bezierOffset;

	int m_waitTime;
	bool m_done = false;

	LootBoxItemAnimator(LootBox@ owner, InventoryItemWidget@ wItem, float bezierOffset)
	{
		@m_owner = owner;
		@m_wItem = wItem;
		m_bezierOffset = bezierOffset;
	}

	void AnimateUp()
	{
		m_waitTime = 1000;

		@m_wItemNew = cast<InventoryItemWidget>(m_wItem.Clone());
		m_wItemNew.m_offset = vec2();
		m_owner.m_wInventory.AddChild(m_wItemNew);
		m_owner.DoLayout();

		vec2 inventoryOffset = m_owner.m_wInventory.GetRelativeOffset();

		vec2 posStart = m_wItem.m_offset;
		vec2 posEnd = inventoryOffset + m_wItemNew.GetRelativeOffset();
		vec2 posBezier = posEnd + vec2(0, 32.0f);

		m_wItem.Animate(WidgetVec2BezierAnimation("offset", posStart, posBezier, posEnd, m_waitTime));//.WithEasing(EasingFunction::QuadIn));
	}

	void Update(int dt)
	{
		if (m_done)
			return;

		if (m_waitTime > 0)
		{
			m_waitTime -= dt;
			if (m_waitTime <= 0)
			{
				m_wItem.RemoveFromParent();
				m_wItemNew.m_visible = true;
				m_done = true;
			}
		}
	}
}

int g_LootBoxCost = 250;

class LootBox : ScriptWidgetHost
{
	InventoryWidget@ m_wInventory;

	Widget@ m_wBox;

	ScalableSpriteButtonWidget@ m_wPlayButton;

	int m_waitTime;
	int m_waitTimeUp;
	array<LootBoxItemAnimator@> m_itemWidgets;

	LootBox(SValue& sval)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wInventory = cast<InventoryWidget>(m_widget.GetWidgetById("inventory"));
		@m_wInventory.m_itemTemplate = cast<InventoryItemWidget>(m_widget.GetWidgetById("inventory-template"));

		@m_wBox = m_widget.GetWidgetById("box");

		@m_wPlayButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("play"));

		m_wInventory.UpdateFromRecord(GetLocalPlayerRecord());

		UpdateInterface();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void UpdateInterface()
	{
		auto gm = cast<Campaign>(g_gameMode);

		m_wPlayButton.SetText("play - " + g_LootBoxCost);
		m_wPlayButton.m_enabled = Currency::CanAfford(g_LootBoxCost);
	}

	void Play()
	{
		if (!Currency::CanAfford(g_LootBoxCost))
		{
			PrintError("Not enough gold!");
			return;
		}

		Currency::Spend(g_LootBoxCost);

		m_waitTime = 1000;

		m_wPlayButton.m_enabled = false;

		vec2 boxOffset = m_wBox.GetRelativeOffset();
		vec2 inventoryOffset = m_wInventory.GetRelativeOffset();

		for (int i = m_wInventory.m_children.length() - 1; i >= 0; i--)
		{
			auto wItem = cast<InventoryItemWidget>(m_wInventory.m_children[i]);
			wItem.MoveToParentInPlace(m_wInventory.m_parent, 3);

			vec2 posStart = wItem.m_offset;
			vec2 posEnd = boxOffset + vec2(m_wBox.m_width - wItem.m_width, m_wBox.m_height - wItem.m_height) * vec2(randf(), randf());
			vec2 posBezier = inventoryOffset + vec2(m_wInventory.m_width - wItem.m_width, m_wInventory.m_height - wItem.m_height) * vec2(randf(), randf());

			//TODO: Add animation delay
			wItem.Animate(WidgetVec2BezierAnimation("offset", posStart, posBezier, posEnd, m_waitTime).WithEasing(EasingFunction::QuadOut));
			m_itemWidgets.insertAt(0, LootBoxItemAnimator(this, wItem, posBezier.x - (m_wInventory.m_offset.x + m_wInventory.m_width / 2.0f)));
		}
	}

	void Update(int dt) override
	{
		for (int i = m_itemWidgets.length() - 1; i >= 0; i--)
		{
			m_itemWidgets[i].Update(dt);
			if (m_itemWidgets[i].m_done)
				m_itemWidgets.removeAt(i);
		}

		if (m_waitTimeUp > 0)
		{
			m_waitTimeUp -= dt;
			if (m_waitTimeUp <= 0)
			{
				m_wPlayButton.m_enabled = true;

				g_LootBoxCost *= 2;
				UpdateInterface();
			}
		}

		if (m_waitTime > 0)
		{
			m_waitTime -= dt;
			if (m_waitTime <= 0)
			{
				m_waitTimeUp = 1000;

				auto record = GetLocalPlayerRecord();
				for (uint i = 0; i < record.items.length(); i++)
				{
					string id = record.items[i];
					auto oldItem = g_items.GetItem(id);

					ActorItem@ newItem;
					int newItemAttempts = 0;
					do
					{
						@newItem = g_items.TakeRandomItem(oldItem.quality, false);
						newItemAttempts++;
					} while (newItemAttempts <= 3 && newItem.id == oldItem.id);

					print(oldItem.id + " -> " + newItem.id);

					record.items[i] = newItem.id;

					m_itemWidgets[i].m_wItem.Set(record, newItem);
					m_itemWidgets[i].AnimateUp();
				}

				for (uint i = 0; i < m_itemWidgets.length(); i++)
					m_itemWidgets[i].m_wItemNew.m_visible = false;

				auto player = cast<Player>(record.actor);
				player.RefreshModifiers();
			}
		}

		ScriptWidgetHost::Update(dt);
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "play")
			Play();
		else
			ScriptWidgetHost::OnFunc(sender, name);
	}
}
