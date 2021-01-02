class MercenaryDungeonSettingsMenu : ScriptWidgetHost
{
	ScalableSpriteButtonWidget@ m_wInsurance;

	Sprite@ m_spriteGold;

	SoundEvent@ m_sndBuyGold;

	DungeonProperties@ m_dungeon;

	MercenaryDungeonSettingsMenu(SValue& sval)
	{
		super();

		string campaignId = sval.GetString();
		if (campaignId != "")
		{
			@m_dungeon = DungeonProperties::Get(campaignId);
			if (m_dungeon is null)
				PrintError("Dungeon with ID '" + campaignId + "' is not found!");
		}
		else
			PrintError("Campaign is not set for MercenaryDungeonSettingsMenu! Make sure you pass the campaign ID in the Param value.");
	}

	int GetNgp()
	{
		auto record = GetLocalPlayerRecord();
		return record.ngps.GetHighest();//[m_dungeon.m_id];
	}

	int GetInsuranceCost()
	{
		return m_dungeon.m_mercenaryInsuranceCost + m_dungeon.m_mercenaryInsuranceCostPerNG * GetNgp();
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Initialize(bool loaded) override
	{
		@m_wInsurance = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("insurance"));

		@m_spriteGold = m_def.GetSprite("icon-gold");

		@m_sndBuyGold = Resources::GetSoundEvent("event:/ui/buy_gold");

		auto wDescription = cast<TextWidget>(m_widget.GetWidgetById("description"));
		if (wDescription !is null)
		{
			wDescription.SetText(Resources::GetString(".town.dungeonsettings.mercenary.description", {
				{ "dungeon", Resources::GetString(m_dungeon.m_name) }
			}));
		}

		UpdateInfo();

		g_ngp = float(GetNgp());
	}

	void UpdateInfo()
	{
		auto wNgp = cast<TextWidget>(m_widget.GetWidgetById("ngp"));
		if (wNgp !is null)
			wNgp.SetText("+" + GetNgp());

		if (m_wInsurance !is null)
		{
			int cost = GetInsuranceCost();
			auto record = GetLocalPlayerRecord();

			m_wInsurance.m_enabled = (!record.HasInsurance(m_dungeon.m_id) && Currency::CanAfford(record, cost));

			m_wInsurance.m_tooltipTitle = Resources::GetString(".town.dungeonsettings.mercenary.insurance.tooltip.title", {
				{ "dungeon", Resources::GetString(m_dungeon.m_name) }
			});

			m_wInsurance.ClearTooltipSubs();
			m_wInsurance.AddTooltipSub(m_spriteGold, formatThousands(cost));
		}
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "insurance")
		{
			int cost = GetInsuranceCost();
			if (!Currency::CanAfford(cost))
			{
				PrintError("Can't afford mercenary insurance!");
				return;
			}

			auto record = GetLocalPlayerRecord();
			if (record.HasInsurance(m_dungeon.m_id))
			{
				PrintError("Mercenary insurance already owned!");
				return;
			}

			record.GiveInsurance(m_dungeon.m_id);

			Currency::Spend(record, cost);

			PlaySound2D(m_sndBuyGold);
			UpdateInfo();
		}
		else if (name == "close")
			Stop();
	}
}
