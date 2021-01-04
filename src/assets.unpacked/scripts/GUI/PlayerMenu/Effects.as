enum PlayerMenuEffectCategory
{
	None,

	Blessings,
	Drinks,
	Fountain,
	Statues,
	Misc
}

enum PlayerMenuEffectMisc
{
	None,

	Cursed,
	Buff,
	BloodAltar,
	Djinn,
	MtBlocks
}

class PlayerMenuEffectInfo
{
	PlayerMenuEffectCategory m_category;

	OwnedUpgrade@ m_ownedUpgrade;
	TavernDrink@ m_drink;
	Fountain::Effect@ m_fountainEffect;
	TownStatue@ m_statue;
	int m_level;

	PlayerMenuEffectMisc m_misc;

	int m_curseAmount;
	ActorBuffDef@ m_buffDef;
	BloodAltar::Reward@ m_bloodAltarReward;

	Widget@ CreateWidget(PlayerMenuEffectsTab@ tab)
	{
		switch (m_category)
		{
			case PlayerMenuEffectCategory::Blessings: return CreateWidgetBlessing(tab);
			case PlayerMenuEffectCategory::Drinks: return CreateWidgetDrink(tab);
			case PlayerMenuEffectCategory::Fountain: return CreateWidgetFountain(tab);
			case PlayerMenuEffectCategory::Statues: return CreateWidgetStatue(tab);

			case PlayerMenuEffectCategory::Misc:
				switch (m_misc)
				{
					case PlayerMenuEffectMisc::Cursed: return CreateWidgetCursed(tab);
					case PlayerMenuEffectMisc::Buff: return CreateWidgetBuff(tab);
					case PlayerMenuEffectMisc::BloodAltar: return CreateWidgetBloodAltar(tab);
					case PlayerMenuEffectMisc::Djinn: return CreateWidgetDjinn(tab);
					case PlayerMenuEffectMisc::MtBlocks: return CreateWidgetMtBlocks(tab);
				}
				break;
		}

		return null;
	}

	Widget@ CreateWidgetBlessing(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto upgradeStep = m_ownedUpgrade.m_step;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(upgradeStep.GetSprite());

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(upgradeStep.m_name));

		wRet.m_tooltipText = Resources::GetString(upgradeStep.m_description);

		return wRet;
	}

	Widget@ CreateWidgetDrink(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(m_drink.icon);

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(m_drink.name));

		wRet.m_tooltipText = Resources::GetString(m_drink.desc);

		return wRet;
	}

	Widget@ CreateWidgetFountain(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite("icon-fountain");

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(".fountain.effect." + m_fountainEffect.m_id + ".name"));

		auto wTextIcon = cast<SpriteWidget>(wRet.GetWidgetById("text-icon"));
		if (wTextIcon !is null)
		{
			wTextIcon.m_visible = true;
			wTextIcon.m_offset.y = 1;

			if (m_fountainEffect.m_favor > 0)
				wTextIcon.SetSprite("icon-fountain-positive");
			else if (m_fountainEffect.m_favor < 0)
				wTextIcon.SetSprite("icon-fountain-negative");
		}

		wRet.m_tooltipText = Resources::GetString(".fountain.effect." + m_fountainEffect.m_id + ".description");

		return wRet;
	}

	Widget@ CreateWidgetStatue(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto statueDef = m_statue.GetDef();

		auto wUnit = cast<UnitWidget>(wRet.GetWidgetById("unit"));
		if (wUnit !is null)
		{
			wUnit.m_visible = true;
			wUnit.AddUnit(statueDef.m_sceneSmall);
		}

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(statueDef.m_name));

		wRet.ClearTooltipSubs();
		wRet.AddTooltipSub(null, Resources::GetString(".shop.statues.level", {
			{ "level", m_statue.m_level }
		}));
		wRet.m_tooltipText = Resources::GetString(statueDef.m_desc);

		return wRet;
	}

	Widget@ CreateWidgetDjinn(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite("icon-djinn");

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(".playermenu.effects.djinn"));

		wRet.ClearTooltipSubs();
		wRet.m_tooltipText = Resources::GetString(Resources::GetString(".playermenu.effects.djinn.desc"));

		return wRet;
	}

	Widget@ CreateWidgetMtBlocks(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite("icon-mtblocks");

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(".playermenu.effects.mtblocks"));

		wRet.ClearTooltipSubs();
		wRet.m_tooltipText = Resources::GetString(Resources::GetString(".playermenu.effects.mtblocks.desc"));

		return wRet;
	}

	Widget@ CreateWidgetCursed(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite("icon-cursed");

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
		{
			wText.SetText(Resources::GetString(".playermenu.effects.cursed", {
				{ "amount", m_curseAmount }
			}));
		}

		wRet.m_tooltipText = Resources::GetString(".sarcophagus.cursehelp", {
			{ "chance", round((1.0f - pow(0.99f, m_curseAmount)) * 100.0f, 1) },
			{ "damage", round((2.0f + 0.01f * m_curseAmount) * 100.0f, 1) }
		});

		return wRet;
	}

	Widget@ CreateWidgetBuff(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(m_buffDef.m_effectIcon);

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(m_buffDef.m_name));

		wRet.m_tooltipText = Resources::GetString(m_buffDef.m_description);

		return wRet;
	}

	Widget@ CreateWidgetBloodAltar(PlayerMenuEffectsTab@ tab)
	{
		auto wRet = tab.m_wTemplateInfo.Clone();
		wRet.SetID("");
		wRet.m_visible = true;

		auto wIcon = cast<SpriteWidget>(wRet.GetWidgetById("icon"));
		if (wIcon !is null)
			wIcon.SetSprite(m_bloodAltarReward.icon);

		auto wText = cast<TextWidget>(wRet.GetWidgetById("text"));
		if (wText !is null)
			wText.SetText(Resources::GetString(m_bloodAltarReward.name));

		wRet.m_tooltipText = Resources::GetString(m_bloodAltarReward.description);

		return wRet;
	}

	int opCmp(const PlayerMenuEffectInfo &in other) const
	{
		if (int(m_category) > int(other.m_category)) return 1;
		else if (int(m_category) < int(other.m_category)) return -1;
		return 0;
	}
}

class PlayerMenuEffectsTab : PlayerMenuTab
{
	Widget@ m_wList;
	Widget@ m_wTemplateHeader;
	Widget@ m_wTemplateInfo;

	PlayerMenuEffectsTab()
	{
		m_id = "effects";
	}

	void OnCreated() override
	{
		PlayerMenuTab::OnCreated();

		@m_wList = m_widget.GetWidgetById("list");
		@m_wTemplateHeader = m_widget.GetWidgetById("template-header");
		@m_wTemplateInfo = m_widget.GetWidgetById("template-info");
	}

	string GetCategoryName(PlayerMenuEffectCategory cat)
	{
		switch (cat)
		{
			case PlayerMenuEffectCategory::None: return "??";
			case PlayerMenuEffectCategory::Blessings: return Resources::GetString(".playermenu.effects.blessings");
			case PlayerMenuEffectCategory::Drinks: return Resources::GetString(".playermenu.effects.drinks");
			case PlayerMenuEffectCategory::Fountain: return Resources::GetString(".playermenu.effects.fountain");
			case PlayerMenuEffectCategory::Statues: return Resources::GetString(".playermenu.effects.statues");
			case PlayerMenuEffectCategory::Misc: return Resources::GetString(".playermenu.effects.misc");
		}
		return "";
	}

	array<PlayerMenuEffectInfo@> CollectEffectInfo()
	{
		array<PlayerMenuEffectInfo@> ret;

		auto record = GetLocalPlayerRecord();
		auto player = GetLocalPlayer();

		for (uint i = 0; i < record.upgrades.length(); i++)
		{
			auto ownedUpgrade = record.upgrades[i];

			//TODO: Add a better way to identify upgrades from certain shops, eg. automatically set a shop ID in upgrades?
			auto chapelUpgradeStep = cast<Upgrades::ChapelUpgradeStep>(ownedUpgrade.m_step);
			if (chapelUpgradeStep !is null)
			{
				auto newInfo = PlayerMenuEffectInfo();
				newInfo.m_category = PlayerMenuEffectCategory::Blessings;
				@newInfo.m_ownedUpgrade = ownedUpgrade;
				ret.insertLast(newInfo);
			}
		}

		for (uint i = 0; i < record.tavernDrinks.length(); i++)
		{
			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Drinks;
			@newInfo.m_drink = GetTavernDrink(HashString(record.tavernDrinks[i]));
			ret.insertLast(newInfo);
		}

		for (uint i = 0; i < Fountain::CurrentEffects.length(); i++)
		{
			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Fountain;
			@newInfo.m_fountainEffect = Fountain::GetEffect(Fountain::CurrentEffects[i]);
			ret.insertLast(newInfo);
		}

		auto gm = cast<Campaign>(g_gameMode);
		auto town = gm.m_town;
		if (Network::IsServer())
			@town = gm.m_townLocal;

%if !HARDCORE
		auto statues = town.GetPlacedStatues();
		for (uint i = 0; i < statues.length(); i++)
		{
			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Statues;
			@newInfo.m_statue = statues[i];
			ret.insertLast(newInfo);
		}
%endif

		int djinnLevel = record.ngps["pop"];
		if (djinnLevel > 0)
		{
			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Misc;
			newInfo.m_misc = PlayerMenuEffectMisc::Djinn;
			newInfo.m_level = djinnLevel;
			ret.insertLast(newInfo);
		}

		int mtBlocksLevel = record.ngps["mt"];
		if (mtBlocksLevel > 0)
		{
			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Misc;
			newInfo.m_misc = PlayerMenuEffectMisc::MtBlocks;
			newInfo.m_level = mtBlocksLevel;
			ret.insertLast(newInfo);
		}

		if (player !is null)
		{
			if (player.m_cachedCurses > 0)
			{
				auto newInfo = PlayerMenuEffectInfo();
				newInfo.m_category = PlayerMenuEffectCategory::Misc;
				newInfo.m_misc = PlayerMenuEffectMisc::Cursed;
				newInfo.m_curseAmount = player.m_cachedCurses;
				ret.insertLast(newInfo);
			}

			for (uint i = 0; i < player.m_buffs.m_buffs.length(); i++)
			{
				auto def = player.m_buffs.m_buffs[i].m_def;

				if (def.m_effectIcon is null || def.m_name == "" || def.m_description == "")
					continue;

				auto newInfo = PlayerMenuEffectInfo();
				newInfo.m_category = PlayerMenuEffectCategory::Misc;
				newInfo.m_misc = PlayerMenuEffectMisc::Buff;
				@newInfo.m_buffDef = def;
				ret.insertLast(newInfo);
			}
		}

		for (uint i = 0; i < record.bloodAltarRewards.length(); i++)
		{
			auto reward = BloodAltar::GetReward(record.bloodAltarRewards[i]);
			if (reward is null)
				continue;

			auto newInfo = PlayerMenuEffectInfo();
			newInfo.m_category = PlayerMenuEffectCategory::Misc;
			newInfo.m_misc = PlayerMenuEffectMisc::BloodAltar;
			@newInfo.m_bloodAltarReward = reward;
			ret.insertLast(newInfo);
		}

		ret.sortAsc();
		return ret;
	}

	void OnShow() override
	{
		PlayerMenuTab::OnShow();

		//TODO: Pause scrolling?
		m_wList.ClearChildren();

		auto lastCategory = PlayerMenuEffectCategory::None;

		auto infos = CollectEffectInfo();
		for (uint i = 0; i < infos.length(); i++)
		{
			auto info = infos[i];
			if (info.m_category != lastCategory)
			{
				lastCategory = info.m_category;

				auto wNewHeader = m_wTemplateHeader.Clone();
				wNewHeader.SetID("");
				wNewHeader.m_visible = true;

				auto wText = cast<TextWidget>(wNewHeader.GetWidgetById("text"));
				if (wText !is null)
					wText.SetText(GetCategoryName(info.m_category));

				m_wList.AddChild(wNewHeader);
			}

			auto wNewInfo = info.CreateWidget(this);
			if (wNewInfo is null)
			{
				PrintError("Couldn't create widget from effect info with ID \"" + info.m_ownedUpgrade.m_id + "\"");
				continue;
			}

			m_wList.AddChild(wNewInfo);
		}
	}
}
