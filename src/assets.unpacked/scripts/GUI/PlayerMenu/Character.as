funcdef float PlayerMenuCharacterTabTooltipListFunction(PlayerBase@ player, Modifiers::ModifierList@ list);
funcdef float PlayerMenuCharacterTabTooltipFunction(PlayerBase@ player, Modifiers::Modifier@ mod);

class PlayerMenuCharacterTab : MultiplePlayersTab
{
	Widget@ m_wPlayerDead;
	Widget@ m_wPlayerInfo;

	InventoryWidget@ m_inventory;
	TextWidget@ m_wItemsText;

	TextWidget@ m_wDungeonTime;
	TextWidget@ m_wDungeonTimePrev;

	Sprite@ m_spriteMana;

	PlayerMenuCharacterTab()
	{
		m_id = "character";
	}

	void OnCreated() override
	{
		MultiplePlayersTab::OnCreated();

		@m_wPlayerDead = m_widget.GetWidgetById("player-dead");
		@m_wPlayerInfo = m_widget.GetWidgetById("player-info");

		@m_inventory = cast<InventoryWidget>(m_widget.GetWidgetById("inventory"));
		@m_inventory.m_itemTemplate = cast<InventoryItemWidget>(m_widget.GetWidgetById("inventory-template"));
		@m_wItemsText = cast<TextWidget>(m_widget.GetWidgetById("items-text"));

		@m_wDungeonTime = cast<TextWidget>(m_widget.GetWidgetById("dungeon-time"));
		if (m_wDungeonTime !is null)
			m_wDungeonTime.m_visible = (cast<Town>(g_gameMode) is null);
		@m_wDungeonTimePrev = cast<TextWidget>(m_widget.GetWidgetById("dungeon-time-prev"));

		@m_spriteMana = m_def.GetSprite("icon-mana");
	}

	void OnShow() override
	{
		MultiplePlayersTab::OnShow();

		auto gm = cast<Campaign>(g_gameMode);
		if (m_wDungeonTimePrev !is null)
			m_wDungeonTimePrev.SetText("prev: " + formatTime(gm.m_timePlayedDungeonPrev, false, true));
	}

	void Update(int dt) override
	{
		auto gm = cast<Campaign>(g_gameMode);
		if (gm !is null && m_wDungeonTime !is null)
		{
			m_wDungeonTime.SetText(formatTime(gm.m_timePlayedDungeon, false, true));
		}
	}

	void SetTextWidget(string id, string text, bool setColor = false)
	{
		auto w = cast<TextWidget>(m_widget.GetWidgetById(id));
		if (w is null)
			return;
		w.SetText(text, setColor);
	}

	void SetTooltipWidget(string id, string title, string text)
	{
		auto w = cast<TextWidget>(m_widget.GetWidgetById(id));
		if (w is null)
			return;

		w.m_parent.m_tooltipTitle = title;
		w.m_parent.m_tooltipText = text;
	}

	void AddTextWidget(string id, string text, bool setColor = false)
	{
		auto w = cast<TextWidget>(m_widget.GetWidgetById(id));
		if (w is null)
			return;
		w.SetText(w.m_str + text, setColor);
	}

	string GetTooltipText(PlayerRecord@ record, PlayerBase@ player, PlayerMenuCharacterTabTooltipListFunction@ callback, float base = -1.0f, float buffs = 1.0f, float buffs0 = 1.0f, bool baseCanBeCapped = false, bool percentage = false)
	{
		string ret = "";

		if (base >= 0.0f)
		{
			int effectiveLevel = record.EffectiveLevel();
			if (baseCanBeCapped && record.level > effectiveLevel)
			{
				ret += Resources::GetString(".playermenu.character.base.capped", {
					{ "value", formatFloat(base, "", 0, 2) },
					{ "level", effectiveLevel }
				}) + "\n";
			}
			else
			{
				ret += Resources::GetString(".playermenu.character.base", {
					{ "value", formatFloat(base, "", 0, 2) }
				}) + "\n";
			}
		}

		auto mods = record.modifiers.GetAllModifiers();
		for (uint i = 0; i < mods.length(); i++)
		{
			auto list = cast<Modifiers::ModifierList>(mods[i]);
			if (list !is null)
			{
				float value = callback(player, list);
				if (!percentage && value != 0)
				{
					ret += "\u2005\u2005";
					if (value > 0)
						ret += "+";
					ret += formatFloat(value, "", 0, 1) + " " + list.m_name + "\n";
				}
				else if (percentage && value != 0)
				{
					value = (value - 1.0f) * 100.0f;
					if (value != 0)
					{
						ret += "\u2005\u2005";
						if (value > 0)
							ret += "+";
						ret += formatFloat(value, "", 0, 1) + "% " + list.m_name + "\n";
					}
				}
			}
		}

		if (buffs < buffs0 - 0.01f || buffs > buffs0 + 0.01f)
			ret += "\u2005\u2005+ " + formatFloat(buffs * 100.0f, "", 0, 1) + "% " + Resources::GetString(".modifier.list.player.buffs") + "\n";

		return strTrim(ret);
	}

	string GetSingularTooltip(Modifiers::ModifierList@ list, PlayerBase@ player, PlayerMenuCharacterTabTooltipFunction@ callback)
	{
		string ret = "";

		auto mods = list.GetAllModifiers();
		for (uint i = 0; i < mods.length(); i++)
		{
			auto mod = mods[i];

			auto subList = cast<Modifiers::ModifierList>(mod);
			if (subList !is null)
			{
				ret += GetSingularTooltip(subList, player, callback);
				continue;
			}

			float value = callback(player, mod);
			if (value > 0)
				ret += "\u2005\u2005+" + formatFloat(value, "", 0, 1) + " " + list.m_name + "\n";
		}

		return ret;
	}

	string GetSingularTooltip(PlayerRecord@ record, PlayerBase@ player, PlayerMenuCharacterTabTooltipFunction@ callback, float base = -1.0f)
	{
		string ret = "";

		if (base >= 0.0f)
			ret += Resources::GetString(".playermenu.character.base", { { "value", formatFloat(base, "", 0, 2) } }) + "\n";

		return strTrim(ret + GetSingularTooltip(record.GetModifiers(), player, callback));
	}

	void UpdateNow(PlayerRecord@ record) override
	{
		MultiplePlayersTab::UpdateNow(record);

		auto player = cast<PlayerBase>(record.actor);
		if (player !is null)
			UpdateFromRecord(record, player);
		else
		/*
		{
			PlayerBase fake;
			@fake.m_record = record;
			fake.RefreshModifiers();
			UpdateFromRecord(record, fake);
		}
		*/
		
		{
			m_wPlayerDead.m_visible = true;
			m_wPlayerInfo.m_visible = false;

			auto wText = cast<TextWidget>(m_wPlayerDead.GetWidgetById("player-dead-text"));
			if (wText !is null)
				wText.SetText(Resources::GetString(".playermenu.dead", { { "player", record.GetName() } }));
		}
		
		m_inventory.UpdateFromRecord(record);

		m_wItemsText.m_tooltipText = Resources::GetString(".playermenu.character.items.tooltip", { { "count", record.items.length() } });

		int numCommon = 0, numUncommon = 0, numRare = 0, numEpic = 0, numLegendary = 0;
		for (uint i = 0; i < record.items.length(); i++)
		{
			auto item = g_items.GetItem(record.items[i]);
			if (item is null)
				continue;

			switch (item.quality)
			{
				case ActorItemQuality::Common: numCommon++; break;
				case ActorItemQuality::Uncommon: numUncommon++; break;
				case ActorItemQuality::Rare: numRare++; break;
				case ActorItemQuality::Epic: numEpic++; break;
				case ActorItemQuality::Legendary: numLegendary++; break;
			}
		}

		string strItemCount = "";
		if (numCommon > 0) strItemCount += "\\c" + GetItemQualityColorString(ActorItemQuality::Common) + numCommon + "\\d / ";
		if (numUncommon > 0) strItemCount += "\\c" + GetItemQualityColorString(ActorItemQuality::Uncommon) + numUncommon + "\\d / ";
		if (numRare > 0) strItemCount += "\\c" + GetItemQualityColorString(ActorItemQuality::Rare) + numRare + "\\d / ";
		if (numEpic > 0) strItemCount += "\\c" + GetItemQualityColorString(ActorItemQuality::Epic) + numEpic + "\\d / ";
		if (numLegendary > 0) strItemCount += "\\c" + GetItemQualityColorString(ActorItemQuality::Legendary) + numLegendary + "\\d / ";
		if (strItemCount != "")
			m_wItemsText.m_tooltipText += "\n" + strTrim(strItemCount, "/ ");

		Invalidate();
	}

	void UpdateFromRecord(PlayerRecord@ record, PlayerBase@ player)
	{
		m_wPlayerDead.m_visible = false;
		m_wPlayerInfo.m_visible = true;

		// Keys
		SetTextWidget("keys-0", "" + record.keys[0]);
		SetTextWidget("keys-1", "" + record.keys[1]);
		SetTextWidget("keys-2", "" + record.keys[2]);
		SetTextWidget("keys-3", "" + record.keys[3]);

		// Potion
		auto wPotion = cast<SpriteWidget>(m_widget.GetWidgetById("potion"));
		auto wPotionBar = cast<DotbarWidget>(m_widget.GetWidgetById("potion-bar"));

		if (wPotion !is null && wPotionBar !is null)
		{
			auto mods = record.GetModifiers();
			int charges = 1 + mods.PotionCharges();

			float potionSpriteStep = (4.0f / float(charges));
			int potionSprite = (4 - int(round(potionSpriteStep * record.potionChargesUsed)));

			if (potionSprite < 0 || record.potionChargesUsed == charges) potionSprite = 0;
			else if (potionSprite > 4) potionSprite = 4;

			int popNgp = record.ngps["pop"];
			if (popNgp > 0)
				wPotion.SetSprite("djinn-potion-" + potionSprite);
			else
				wPotion.SetSprite("potion-" + potionSprite);
			wPotionBar.m_value = (charges - record.potionChargesUsed);
			wPotionBar.m_max = charges;

			dictionary paramsTitle = { { "num", charges - record.potionChargesUsed }, { "total", charges } };
			wPotion.m_tooltipTitle = Resources::GetString(".playermenu.tooltip.potion.title", paramsTitle);

			float healAmnt = 50 * mods.PotionHealMul(player);
			float manaAmnt = 50 * mods.PotionManaMul(player);

			int djinnLevel = record.ngps["pop"];
			if (djinnLevel > 0)
			{
				healAmnt += djinnLevel * 25;
				manaAmnt += djinnLevel * 25;
			}

			dictionary paramsText = { { "hp", healAmnt }, { "mana", manaAmnt } };
			wPotion.m_tooltipText = Resources::GetString(".playermenu.tooltip.potion.text", paramsText);

			if (popNgp > 0)
			{
				wPotion.m_tooltipText += "\n\n" + Resources::GetString(".playermenu.tooltip.potion.djinn", {
					{ "ttl", 28 + (popNgp * 2.0f) },
					{ "dmg", int(50.0f * (1.0f + int(popNgp) * 0.2f)) }
				});
			}
		}

		// Skills
		for (uint i = 0; i < player.m_skills.length(); i++)
		{
			Widget@ wSkill = m_widget.GetWidgetById("skill-" + i);
			if (wSkill is null)
				continue;

			auto wSkillIcon = cast<SpriteWidget>(wSkill.GetWidgetById("icon"));
			if (wSkillIcon is null)
				continue;

%if HARDCORE
			int skillLevel = 0;
			if (i > 0 && record.hardcoreSkills[i - 1] is null)
			{
				wSkillIcon.m_visible = false;
				continue;
			}
%else
			int skillLevel = record.levelSkills[i];
			if (skillLevel == 0)
			{
				wSkillIcon.m_visible = false;
				continue;
			}
%endif

			wSkillIcon.m_visible = true;

			Skills::Skill@ skill = player.m_skills[i];
			Skills::ActiveSkill@ activeSkill = cast<Skills::ActiveSkill>(skill);

			wSkillIcon.SetSprite(skill.m_icon);
			wSkillIcon.m_tooltipTitle = skill.GetFullName(skillLevel);

			wSkillIcon.ClearTooltipSubs();

			if (i == 0) wSkillIcon.AddTooltipSub(null, Resources::GetString(".misc.primaryskill"));
			else if (i <= 3) wSkillIcon.AddTooltipSub(null, Resources::GetString(".misc.activeskill"));
			else wSkillIcon.AddTooltipSub(null, Resources::GetString(".misc.passiveskill"));

			if (activeSkill !is null && activeSkill.m_costMana > 0)
				wSkillIcon.AddTooltipSub(m_spriteMana, ("" + activeSkill.m_costMana));

			wSkillIcon.m_tooltipText = skill.GetFullDescription(skillLevel);
		}

		// Town info
		int townGold = Currency::GetHomeGold();
		int townOre = Currency::GetHomeOre();

		auto buffs = player.m_buffs;

		auto modifierList = record.GetModifiers();
		float slowScale = modifierList.SlowScale(player);

		// Character info
		vec2 statArmorAdd = modifierList.ArmorAdd(player, null); // armor, resistance
		vec2 statArmorMul = modifierList.ArmorMul(player, null); // armor, resistance
		//ivec2 statDamageBlock; // physical, magical

		ivec2 statDamagePower = modifierList.DamagePower(player, null); // attack power, spell power
		ivec2 statDamageAddAttack = modifierList.AttackDamageAdd(player, null, null); // attack physical add, attack magical add
		ivec2 statDamageAddSpell = modifierList.SpellDamageAdd(player, null, null); // spell physical add, spell magical add

		ivec2 statStatsAdd = modifierList.StatsAdd(player); // health, mana
		float maxHealthMul = modifierList.MaxHealthMul(player);
		float statMoveSpeed = min((Tweak::PlayerSpeed + modifierList.MoveSpeedAdd(player, slowScale)) * modifierList.MoveSpeedMul(player, slowScale), Tweak::PlayerSpeedMax);
		vec2 statRegenAdd = modifierList.RegenAdd(player); // health, mana
		vec2 statRegenMul = modifierList.RegenMul(player); // health, mana
		float allHealthGainScale = modifierList.AllHealthGainScale(player);
		float statExpMul = modifierList.ExpMul(player, null) + modifierList.ExpMulAdd(player, null);
		float luckAdd = modifierList.LuckAdd(player);

		int64 xpStart = record.LevelExperience(record.level - 1);
		int64 xpEnd = record.LevelExperience(record.level) - xpStart;
		int64 xpNow = record.experience - xpStart;

		int maxHp = record.MaxHealth() + statStatsAdd.x;

		SetTextWidget("info_health", "" + ceil(maxHp * maxHealthMul));
		SetTooltipWidget(
			"info_health",
			Resources::GetString(".playermenu.character.health"),
			GetTooltipText(record, player, function(player, list) {
				return list.StatsAdd(player).x;
			}, record.MaxHealth(), 1.0f, 1.0f, true) + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.MaxHealthMul(player);
			}, -1.0f, 1.0f, 1.0f, false, true)
		);
		SetTextWidget("info_health_regen", formatFloat((record.HealthRegen() + statRegenAdd.x) * statRegenMul.x * allHealthGainScale, "", 0, 2));
		SetTooltipWidget(
			"info_health_regen",
			Resources::GetString(".playermenu.character.healthregen"),
			strJoin({
				GetTooltipText(record, player, function(player, list) {
					return list.RegenAdd(player).x;
				}, record.HealthRegen(), 1.0f, 1.0f, true),
				GetTooltipText(record, player, function(player, list) {
					return list.RegenMul(player).x;
				}, -1.0f, 1.0f, 1.0f, false, true),
				GetTooltipText(record, player, function(player, list) {
					return list.AllHealthGainScale(player);
				}, -1.0f, 1.0f, 1.0f, false, true)
			}, "\n", true)
		);

		SetTextWidget("info_mana", "" + (record.MaxMana() + statStatsAdd.y));
		SetTooltipWidget(
			"info_mana",
			Resources::GetString(".playermenu.character.mana"),
			GetTooltipText(record, player, function(player, list) {
				return list.StatsAdd(player).y;
			}, record.MaxMana(), 1.0f, 1.0f, true)
		);

		SetTextWidget("info_mana_regen", formatFloat((record.ManaRegen() + statRegenAdd.y) * statRegenMul.y, "", 0, 2));
		SetTooltipWidget(
			"info_mana_regen",
			Resources::GetString(".playermenu.character.manaregen"),
			strTrim(
				GetTooltipText(record, player, function(player, list) {
					return list.RegenAdd(player).y;
				}, record.ManaRegen(), 1.0f, 1.0f, true) + "\n" +
				GetTooltipText(record, player, function(player, list) {
					return list.RegenMul(player).y;
				}, -1.0f, 1.0f, 1.0f, false, true)
			)
		);

		auto ngpNegativeArmor = Tweak::NewGamePlusNegArmor(g_ngp);

		string strNgpNegativeArmor = "";
		if (ngpNegativeArmor.x > 0)
			strNgpNegativeArmor = "\n\u2005\u2005-" + formatFloat(ngpNegativeArmor.x, "", 0, 1) + " " + Resources::GetString(".misc.ngp2", { { "ngp", int(g_ngp) } });

		string strNgpNegativeResistance = "";
		if (ngpNegativeArmor.y > 0)
			strNgpNegativeResistance = "\n\u2005\u2005-" + formatFloat(ngpNegativeArmor.y, "", 0, 1) + " " + Resources::GetString(".misc.ngp2", { { "ngp", int(g_ngp) } });

		auto armor = (record.Armor() + statArmorAdd.x) * (statArmorMul.x * buffs.ArmorMul().x) - ngpNegativeArmor.x;
		SetTextWidget("info_armor", "" + formatFloat(armor, "", 0, 1));
		SetTooltipWidget(
			"info_armor",
			Resources::GetString(".playermenu.character.armor"),
			Resources::GetString(".playermenu.character.armor.description", { { "value", round((1.0f - CalcArmor(armor)) * 100.0f) } }) + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.ArmorAdd(player, null).x;
			}, record.Armor(), 1.0f - buffs.DamageTakenMul(), 0.0f, true) + strNgpNegativeArmor + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.ArmorMul(player, null).x;
			}, -1.0f, 1.0f, 1.0f, false, true)
		);

		auto resistance = (record.Resistance() + statArmorAdd.y) * (statArmorMul.y * buffs.ArmorMul().y) - ngpNegativeArmor.y;
		SetTextWidget("info_resistance", "" + formatFloat(resistance, "", 0, 1));
		SetTooltipWidget(
			"info_resistance",
			Resources::GetString(".playermenu.character.resistance"),
			Resources::GetString(".playermenu.character.resistance.description", { { "value", round((1.0f - CalcArmor(resistance)) * 100.0f) } }) + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.ArmorAdd(player, null).y;
			}, record.Resistance(), 1.0f, 1.0f, true) + strNgpNegativeResistance + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.ArmorMul(player, null).x;
			}, -1.0f, 1.0f, 1.0f, false, true)
		);

		auto critChance = GetCritChance(modifierList);

		float critMulPhysical = modifierList.CritMul(player, null, false);
		critMulPhysical += modifierList.CritMulAdd(player, null, false);

		float critMulSpell = modifierList.CritMul(player, null, true);
		critMulSpell += modifierList.CritMulAdd(player, null, true);

		SetTextWidget("info_crit", formatFloat(max(critChance.x, critChance.y) * 100.0f, "", 0, 1) + "%");
		SetTooltipWidget(
			"info_crit",
			Resources::GetString(".playermenu.character.critchance"),
			// Crit multiplier: %mul%%\nCrit chance: %chance%%\n%chances%\nSkill crit chance: %spell-chance%%\nSkill crit multiplier: %spell-mul%%\n%spell-chances%
			Resources::GetString(".playermenu.character.critchance.description", {
				{ "mul", formatFloat((2.0f + critMulPhysical - 1.0f) * 100.0f, "", 0, 1) },
				{ "muls", GetTooltipText(record, player, function(player, mod) {
					return mod.CritMul(player, null, false) + mod.CritMulAdd(player, null, false);
				}, -1.0f, 1.0f, 1.0f, false, true) },
				{ "spell-mul", formatFloat((2.0f + critMulSpell - 1.0f) * 100.0f, "", 0, 1) },
				{ "spell-muls", GetTooltipText(record, player, function(player, mod) {
					return mod.CritMul(player, null, true) + mod.CritMulAdd(player, null, true);
				}, -1.0f, 1.0f, 1.0f, false, true) },
				{ "chance", formatFloat(critChance.x * 100.0f, "", 0, 1) },
				{ "spell-chance", formatFloat(critChance.y * 100.0f, "", 0, 1) },
				{ "chances", GetSingularTooltip(record, player, function(player, mod) {
					return mod.CritChance(false) * 100.0f;
				}) },
				{ "spell-chances", GetSingularTooltip(record, player, function(player, mod) {
					return mod.CritChance(true) * 100.0f;
				}) }
			})
		);

		auto evadeChance = GetEvadeChance(modifierList);
		SetTextWidget("info_evade", formatFloat(evadeChance * 100.0f, "", 0, 1) + "%");
		SetTooltipWidget(
			"info_evade",
			Resources::GetString(".playermenu.character.evadechance"),
			GetSingularTooltip(record, player, function(player, mod) {
				return mod.EvadeChance() * 100.0f;
			})
		);

		SetTextWidget("info_luck", formatFloat(luckAdd, "", 0, 1));
		SetTooltipWidget(
			"info_luck",
			Resources::GetString(".playermenu.character.luck"),
			GetTooltipText(record, player, function(player, mod) {
				return mod.LuckAdd(player);
			})
		);

		SetTextWidget("info_damage_power_attack", "" + statDamagePower.x);
		SetTooltipWidget(
			"info_damage_power_attack",
			Resources::GetString(".playermenu.character.attackpower"),
			Resources::GetString(".playermenu.character.attackpower.description", { { "value", round((((50.0f + statDamagePower.x) / 50.0f) - 1.0f) * 100.0f) } }) + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.DamagePower(player, null).x;
			}, -1.0f, buffs.DamageMul() - 1.0f, 0.0f) + "\n\n" +
			Resources::GetString(".playermenu.character.physicaladd", { { "amount", statDamageAddAttack.x } }) + "\n" +
			Resources::GetString(".playermenu.character.magicaladd", { { "amount", statDamageAddAttack.y } })
		);
		SetTextWidget("info_damage_power_spell", "" + statDamagePower.y);
		SetTooltipWidget(
			"info_damage_power_spell",
			Resources::GetString(".playermenu.character.spellpower"),
			Resources::GetString(".playermenu.character.spellpower.description", { { "value", round((((50.0f + statDamagePower.y) / 50.0f) - 1.0f) * 100.0f) } }) + "\n" +
			GetTooltipText(record, player, function(player, list) {
				return list.DamagePower(player, null).y;
			})
		);

		SetTextWidget("info_move_speed", formatFloat(statMoveSpeed, "", 0, 1));
		SetTooltipWidget(
			"info_move_speed",
			Resources::GetString(".playermenu.character.movespeed"),
			strTrim(
				GetTooltipText(record, player, function(player, list) {
					float slowScale = player.m_record.GetModifiers().SlowScale(player);
					return list.MoveSpeedAdd(player, slowScale);
				}, Tweak::PlayerSpeed, buffs.MoveSpeedMul(slowScale) - 1.0f, 0.0f) + "\n" +
				GetTooltipText(record, player, function(player, list) {
					float slowScale = player.m_record.GetModifiers().SlowScale(player);
					return list.MoveSpeedMul(player, slowScale);
				}, -1.0f, 1.0f, 1.0f, false, true)
			)
		);
		SetTextWidget("info_exp", floor(float(xpNow / double(xpEnd)) * 100) + "%");
		SetTooltipWidget("info_exp", Resources::GetString(".playermenu.tooltip.exp"),
			Resources::GetString(".playermenu.tooltip.exp.total") + " " + formatThousands(record.experience) + "\n" +
			Resources::GetString(".playermenu.tooltip.exp.left") + " " + formatThousands(xpEnd - xpNow) +
			" (" + ceil((1.0f - (xpNow / float(xpEnd))) * 100) + "%)\n" +
			Resources::GetString(".playermenu.tooltip.exp.rate") + " " + round(statExpMul * 100) + "%" +
//%if !HARDCORE
			"\n" + Resources::GetString(".playermenu.tooltip.exp.levelcap") + " " + record.GetLevelCap() +
//%endif
			(buffs.ExperienceMul() != 1.0f ? "\n" + Resources::GetString(".modifier.list.player.buffs") + ": +" + (formatFloat((buffs.ExperienceMul() - 1.0f) * 100.0f, "", 0, 1)) + "%" : "") +
			"\n" + GetTooltipText(record, player, function(player, list) {
				float mul = list.ExpMul(player, null);
				mul += list.ExpMulAdd(player, null);
				return (mul - 1.0f) * 100;
			})
		);

		string strNgpGoldGain = "";
		string strNgpOreGain = "";

		if (g_ngp > 0)
		{
			strNgpGoldGain = "\n\u2005\u2005+" + round((0.2f * g_ngp) * 100.0f) + " " + Resources::GetString(".misc.ngp2", { { "ngp", int(g_ngp) } });
			strNgpOreGain = "\n\u2005\u2005+" + round((0.2f * g_ngp) * 100.0f) + " " + Resources::GetString(".misc.ngp2", { { "ngp", int(g_ngp) } });
		}

		float goldGain = modifierList.GoldGainScale(player);
		goldGain += modifierList.GoldGainScaleAdd(player);

		SetTextWidget("info_gold", formatThousands(record.runGold));
		SetTooltipWidget(
			"info_gold",
			Resources::GetString(".playermenu.character.goldgain"),
			((goldGain + 0.2f * g_ngp) * 100) + "%\n" + 
			GetTooltipText(record, player, function(player, list) {
				float scale = list.GoldGainScale(player);
				scale += list.GoldGainScaleAdd(player);
				return (scale - 1.0f) * 100;
			}) + strNgpGoldGain
		);

		SetTextWidget("info_gold_town", formatThousands(townGold));
		int rg = max(250, record.runGold);
		SetTooltipWidget("info_gold_town", Resources::GetString(".playermenu.tooltip.tax"),
			round((1.0f - ApplyTaxRate(townGold, rg) / float(rg)) * 100, 2) + "%");

		SetTextWidget("info_ore", formatThousands(record.runOre));
		SetTooltipWidget(
			"info_ore",
			Resources::GetString(".playermenu.character.oregain"),
			((modifierList.OreGainScale(player) + 0.2f * g_ngp) * 100) + "%\n" + 
			GetTooltipText(record, player, function(player, list) {
				return (list.OreGainScale(player) - 1.0f) * 100;
			}) + strNgpOreGain
		);
		SetTextWidget("info_ore_town", formatThousands(townOre));
	}

	float GetEvadeChance(Modifiers::ModifierList@ modifiers)
	{
		float ret = 1.0f;

		auto mods = modifiers.GetAllModifiers();
		for (uint i = 0; i < mods.length(); i++)
		{
			auto mod = mods[i];

			auto modList = cast<Modifiers::ModifierList>(mod);
			if (modList !is null)
				ret *= 1.0f - GetEvadeChance(modList);

			ret *= 1.0f - mod.EvadeChance();
		}

		return 1.0f - ret;
	}

	vec2 GetCritChance(Modifiers::ModifierList@ modifiers)
	{
		vec2 ret(1, 1);

		auto mods = modifiers.GetAllModifiers();
		for (uint i = 0; i < mods.length(); i++)
		{
			auto mod = mods[i];

			auto modList = cast<Modifiers::ModifierList>(mod);
			if (modList !is null)
				ret *= vec2(1, 1) - GetCritChance(modList);

			ret.x *= 1.0f - mod.CritChance(false);
			ret.y *= 1.0f - mod.CritChance(true);
		}

		return vec2(1, 1) - ret;
	}
}
