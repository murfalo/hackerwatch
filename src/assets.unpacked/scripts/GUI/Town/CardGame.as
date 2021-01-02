class CardGameSound
{
	SoundEvent@ m_snd;
	int m_delay;

	CardGameSound(SoundEvent@ snd, int delay)
	{
		@m_snd = snd;
		m_delay = delay;
	}
}

class CardGameLimitPrize
{
	string m_type;
	ActorItemQuality m_quality;
}

class CardGameLimit
{
	int m_amount;

	bool m_onlyIfAvailable;

	string m_tooltip;
	bool m_animateSuspense;

	float m_prizeChance;
	array<CardGameLimitPrize> m_prizes;

	CardGameLimit(SValue@ sv)
	{
		m_amount = GetParamInt(UnitPtr(), sv, "amount");

		m_onlyIfAvailable = GetParamBool(UnitPtr(), sv, "only-if-available", false);

		m_tooltip = GetParamString(UnitPtr(), sv, "tooltip", false);
		m_animateSuspense = GetParamBool(UnitPtr(), sv, "animate-suspense", false);

		m_prizeChance = GetParamFloat(UnitPtr(), sv, "prize-chance", false);

		auto arrPrizes = GetParamArray(UnitPtr(), sv, "prizes", false);
		if (arrPrizes !is null)
		{
			for (uint i = 0; i < arrPrizes.length(); i += 2)
			{
				CardGameLimitPrize prize;
				prize.m_type = arrPrizes[i + 0].GetString();
				prize.m_quality = ParseActorItemQuality(arrPrizes[i + 1].GetString());
				m_prizes.insertLast(prize);
			}
		}
	}
}

class CardGame : ScriptWidgetHost
{
	TextWidget@ m_wStatus;

	TextWidget@ m_wStatusBattle;
	Widget@ m_wSubStatus;
	TextWidget@ m_wGoldFrom;
	TextWidget@ m_wGoldTo;

	Widget@ m_wPrizeText;
	Widget@ m_wPrizeFrame;
	RectWidget@ m_wPrizeBackground;
	Widget@ m_wPrizeBlueprint;
	SpriteWidget@ m_wPrizeIcon;
	DyeSpriteWidget@ m_wPrizeIconDye;

	ScalableSpriteButtonWidget@ m_wFlipButton;

	CheckBoxGroupWidget@ m_wLimits;
	Widget@ m_wLimitsTemplate;

	Widget@ m_wDarkness;
	Widget@ m_wDarknessMove;
	SpriteWidget@ m_wDarknessMoveSprite;

	Sprite@ m_spriteDarknessSquare;
	Sprite@ m_spriteDarkness;

	TextWidget@ m_wDiff;

	SoundEvent@ m_sndLose;
	SoundEvent@ m_sndWin;
	SoundEvent@ m_sndFlip;
	SoundEvent@ m_sndSuspense;

	CardGameLimit@ m_limit;
	array<CardGameLimit@> m_limits;

	ivec2 m_cardPlayer;
	ivec2 m_cardHouse;

	bool m_waitWin;
	int m_waitTime;

	bool m_cardsPlaced;
	int m_animateOutWaitTime;

	array<CardGameSound@> m_sounds;

	CardGame(SValue& sval)
	{
		super();
	}

	void Initialize(bool loaded) override
	{
		@m_wStatus = cast<TextWidget>(m_widget.GetWidgetById("status"));

		@m_wStatusBattle = cast<TextWidget>(m_widget.GetWidgetById("status-battle"));
		@m_wSubStatus = m_widget.GetWidgetById("substatus");
		@m_wGoldFrom = cast<TextWidget>(m_widget.GetWidgetById("your-x"));
		@m_wGoldTo = cast<TextWidget>(m_widget.GetWidgetById("became-y"));

		@m_wPrizeText = m_widget.GetWidgetById("prize-text");
		@m_wPrizeFrame = m_widget.GetWidgetById("prize-frame");
		@m_wPrizeBackground = cast<RectWidget>(m_widget.GetWidgetById("prize-background"));
		@m_wPrizeBlueprint = m_widget.GetWidgetById("prize-blueprint");
		@m_wPrizeIcon = cast<SpriteWidget>(m_widget.GetWidgetById("prize-icon"));
		@m_wPrizeIconDye = cast<DyeSpriteWidget>(m_widget.GetWidgetById("prize-icon-dye"));

		@m_wFlipButton = cast<ScalableSpriteButtonWidget>(m_widget.GetWidgetById("flip"));

		@m_wLimits = cast<CheckBoxGroupWidget>(m_widget.GetWidgetById("limits-list"));
		@m_wLimitsTemplate = m_widget.GetWidgetById("limits-template");

		@m_wDarkness = m_widget.GetWidgetById("darkness");
		@m_wDarknessMove = m_widget.GetWidgetById("darkness-move");
		@m_wDarknessMoveSprite = cast<SpriteWidget>(m_wDarknessMove.m_children[0]);

		@m_spriteDarknessSquare = m_def.GetSprite("darkness-square");
		@m_spriteDarkness = m_def.GetSprite("darkness");

		@m_wDiff = cast<TextWidget>(m_widget.GetWidgetById("diff"));

		@m_sndLose = Resources::GetSoundEvent("event:/ui/game-lose");
		@m_sndWin = Resources::GetSoundEvent("event:/ui/game-win");
		@m_sndFlip = Resources::GetSoundEvent("event:/ui/game-cardflip");
		@m_sndSuspense = Resources::GetSoundEvent("event:/ui/game-suspense");

		auto wPortrait = cast<DyeSpriteWidget>(m_widget.GetWidgetById("portrait"));
		if (wPortrait !is null)
		{
			auto record = GetLocalPlayerRecord();
			auto faceInfo = ClassFaceInfo(record.charClass);
			wPortrait.SetSprite(faceInfo.GetSprite(record.face));
			wPortrait.SetDyes(record.colors);
		}

		SetLimitButtons();
	}

	string GetCardName(ivec2 card)
	{
		if (card.y == 10)
			return Resources::GetString(".gambling.card.wildcard");
		else
			return Resources::GetString(".gambling.card." + (card.x + 1) + "." + (card.y + 1));
	}

	void DisableLimitButtons()
	{
		for (uint i = 0; i < m_wLimits.m_children.length(); i++)
		{
			auto w = cast<ScalableSpriteButtonWidget>(m_wLimits.m_children[i]);
			w.m_enabled = false;
		}
	}

	CardGameLimit@ GetLimit(int amount)
	{
		for (uint i = 0; i < m_limits.length(); i++)
		{
			auto limit = m_limits[i];
			if (limit.m_amount == amount)
				return limit;
		}
		PrintError("Unable to find limit for amount " + amount);
		return null;
	}

	void SetLimitButtons()
	{
		auto gm = cast<Campaign>(g_gameMode);

		int leastValue = 0;
		int mostValue = 0;
		int currentValue = 0;

		if (m_limit !is null)
			currentValue = m_limit.m_amount;

		@m_limit = null;
		m_limits.removeRange(0, m_limits.length());

		auto sval = Resources::GetSValue("tweak/gambling.sval");
		auto arrLimits = sval.GetArray();

		m_wLimits.ClearChildren();
		for (uint i = 0; i < arrLimits.length(); i++)
		{
			auto svLimit = arrLimits[i];

			auto newLimit = CardGameLimit(svLimit);
			m_limits.insertLast(newLimit);

			bool canAfford = Currency::CanAfford(newLimit.m_amount);

			if (newLimit.m_onlyIfAvailable && !canAfford)
				continue;

			if (canAfford)
			{
				if (leastValue == 0 || newLimit.m_amount < leastValue)
					leastValue = newLimit.m_amount;
				if (newLimit.m_amount > mostValue)
					mostValue = newLimit.m_amount;
			}

			auto wNewLimit = cast<ScalableSpriteButtonWidget>(m_wLimitsTemplate.Clone());
			wNewLimit.SetID("");
			wNewLimit.m_visible = true;

			wNewLimit.m_enabled = canAfford;
			wNewLimit.m_value = "" + newLimit.m_amount;
			wNewLimit.SetText(formatThousands(newLimit.m_amount));

			if (newLimit.m_tooltip != "")
				wNewLimit.m_tooltipText = Resources::GetString(newLimit.m_tooltip);

			m_wLimits.AddChild(wNewLimit);
			if (m_wLimits.m_children.length() > 6)
			{
				m_limits.removeAt(0);
				m_wLimits.m_children[0].RemoveFromParent();
			}
		}

		if (leastValue == 0)
			g_gameMode.ShowDialog("close", Resources::GetString(".town.cardgame.outofmoney." + (randi(5) + 1)), Resources::GetString(".menu.ok"), this);
		else
		{
			@m_limit = GetLimit(clamp(currentValue, leastValue, mostValue));
			m_wLimits.SetChecked("" + m_limit.m_amount);
		}
	}

	void AnimateCardsOut()
	{
		HideStatus();

		m_wDiff.m_visible = false;

		UnsetCard("card-house");
		UnsetCard("card-player");

		m_cardsPlaced = false;
		m_animateOutWaitTime = 750;
	}

	void HideStatus()
	{
		m_wStatus.m_visible = false;
		m_wStatusBattle.m_visible = false;
		m_wSubStatus.m_visible = false;
		m_wPrizeText.m_visible = false;
		m_wPrizeFrame.m_visible = false;
		m_wPrizeBackground.m_visible = false;
		m_wPrizeBlueprint.m_visible = false;
		m_wPrizeIcon.m_visible = false;
		m_wPrizeIcon.m_offset = vec2();
		m_wPrizeIconDye.m_visible = false;
	}

	void SetStatus(bool win)
	{
		if (win)
		{
			m_wStatus.SetText(Resources::GetString(".town.cardgame.header.win"));
			m_wStatus.SetColor(tocolor(vec4(0, 1, 0, 1)));
		}
		else
		{
			m_wStatus.SetText(Resources::GetString(".town.cardgame.header.lose"));
			m_wStatus.SetColor(tocolor(vec4(1, 0, 0, 1)));
		}
		m_wStatus.m_visible = true;
	}

	void SetBattleStatus(ivec2 cardPlayer, ivec2 cardHouse)
	{
		string namePlayer = GetCardName(cardPlayer);
		string nameHouse = GetCardName(cardHouse);

		m_wStatusBattle.SetText(Resources::GetString(".town.cardgame.battlestatus", { { "player", namePlayer }, { "house", nameHouse } }));
		m_wStatusBattle.m_visible = true;
	}

	void SetGoldStatus(int fromGold, int toGold)
	{
		m_wGoldFrom.SetText(Resources::GetString(".town.cardgame.goldfrom", { { "num", formatThousands(fromGold) } }));
		m_wGoldTo.SetText(Resources::GetString(".town.cardgame.goldto", { { "num", formatThousands(toGold) } }));

		m_wSubStatus.m_visible = true;
	}

	vec4 GetCardFrame(ivec2 card)
	{
		vec4 ret;

		ret.z = 45;
		ret.w = 68;
		ret.x = card.y * ret.z;
		ret.y = card.x * ret.w;

		return ret;
	}

	RandomContext GetRandomContext()
	{
		int index = m_limits.findByRef(m_limit);
		switch (index) {
			case 0: return RandomContext::CardGame0;
			case 1: return RandomContext::CardGame1;
			case 2: return RandomContext::CardGame2;
			case 3: return RandomContext::CardGame3;
			case 4: return RandomContext::CardGame4;
			case 5: return RandomContext::CardGame5;
			case 6: return RandomContext::CardGame6;
			case 7: return RandomContext::CardGame7;
			case 8: return RandomContext::CardGame8;
			case 9: return RandomContext::CardGame9;
		}
		return RandomContext::CardGame0;
	}

	ivec2 PullRandomCard()
	{
		auto randomContext = GetRandomContext();
		int cardRow = RandomBank::Int(randomContext, 4);
		int cardNum = RandomBank::Int(randomContext, 11);
		return ivec2(cardRow, cardNum);
	}

	bool IsValidCardCombination(ivec2 house, ivec2 player)
	{
		// Don't pull the same card
		if (house.x == player.x && house.y == player.y)
			return false;

		// Only pull 1 joker card
		if (house.y == 10 && player.y == 10)
			return false;

		return true;
	}

	void UnsetCard(string id)
	{
		auto wPlacedCard = m_widget.GetWidgetById(id);
		wPlacedCard.m_visible = false;

		auto wDeck = m_widget.GetWidgetById(id + "-deck");

		auto wCardAnimator = m_widget.GetWidgetById(id + "-animator-behind");
		wCardAnimator.m_visible = true;

		vec2 startPos = wPlacedCard.m_offset;
		vec2 endPos = wDeck.m_offset;
		endPos.y = startPos.y;

		wCardAnimator.m_offset = startPos;
		wCardAnimator.Animate(WidgetVec2Animation("offset", startPos, endPos, 500));

		wCardAnimator.Animate(WidgetBoolAnimation("visible", false, 500));
	}

	void SetCard(string id, ivec2 card)
	{
		auto wCard = cast<SpriteWidget>(m_widget.GetWidgetById(id));
		if (wCard is null)
		{
			PrintError("Invalid widget ID: " + id);
			return;
		}

		if (card.y == 10)
			wCard.SetSprite("card-joker");
		else
		{
			auto texture = Resources::GetTexture2D("gui/cards.png");
			auto frame = GetCardFrame(card);
			wCard.SetSprite(ScriptSprite(texture, frame));
		}

		int animTime = 650;
		int animDelay = 0;
		if (id != "card-player")
			animDelay = 100;

		bool moveSpotlight = false;

		if (m_limit.m_animateSuspense)
		{
			moveSpotlight = true;

			if (id == "card-player")
				animDelay = 4000;
			else
				animDelay = 2000;

			AddSound(m_sndFlip, animDelay);
		}

		wCard.Animate(WidgetBoolAnimation("visible", true, animTime + animDelay));

		auto wDeck = m_widget.GetWidgetById(id + "-deck");

		auto wCardAnimator = m_widget.GetWidgetById(id + "-animator");
		auto wCardAnimatorShadow = m_widget.GetWidgetById(id + "-animator-shadow");

		wCardAnimator.Animate(WidgetBoolAnimation("visible", true, animDelay + 50));
		wCardAnimatorShadow.Animate(WidgetBoolAnimation("visible", true, animDelay + 50));

		vec2 startPos = wDeck.m_offset;
		vec2 endPos = wCard.m_offset;
		vec2 bezierPos = lerp(startPos, endPos, 0.5f) + vec2(0, -50);

		wCardAnimator.Animate(WidgetVec2BezierAnimation("offset", startPos, bezierPos, endPos, animTime, animDelay));
		wCardAnimator.Animate(WidgetBoolAnimation("visible", false, animTime + animDelay));

		vec2 shadowBezierPos = lerp(startPos, endPos, 0.5f) + vec2(20, -55);

		wCardAnimatorShadow.Animate(WidgetVec2BezierAnimation("offset", startPos, shadowBezierPos, endPos, animTime, animDelay));
		wCardAnimatorShadow.Animate(WidgetBoolAnimation("visible", false, animTime + animDelay));

		if (moveSpotlight)
		{
			vec2 spotlightOffset = vec2(-64 + 22, -64 + 33);
			m_wDarknessMove.Animate(WidgetVec2BezierAnimation("offset", startPos + spotlightOffset, bezierPos + spotlightOffset, endPos + spotlightOffset, animTime, animDelay));
			m_wDarknessMoveSprite.Animate(WidgetSpriteAnimation("sprite", m_spriteDarkness, animDelay));
			m_wDarknessMoveSprite.Animate(WidgetSpriteAnimation("sprite", m_spriteDarknessSquare, animDelay + animTime + 500));
		}
	}

	void LoseCash()
	{
		Currency::Spend(m_limit.m_amount);

		Stats::Add("gambling-gold-lost", m_limit.m_amount, GetLocalPlayerRecord());
	}

	Materials::Dye@ RandomPrizeDye(ActorItemQuality quality)
	{
		auto gm = cast<Campaign>(g_gameMode);

		array<Materials::Dye@> possibleDyes;
		for (uint i = 0; i < Materials::g_dyes.length(); i++)
		{
			auto dye = Materials::g_dyes[i];

			if (dye.m_default)
				continue;

			if (dye.m_legacyPoints > 0)
				continue;

			if (dye.m_quality != quality)
				continue;

			if (gm.m_townLocal.OwnsDye(dye))
				continue;

			if (!HasDLC(dye.m_dlc))
				continue;

			possibleDyes.insertLast(dye);
		}

		if (possibleDyes.length() == 0)
			return null;

		int randomItemIndex = RandomBank::Int(GetRandomContext(), possibleDyes.length());
		return possibleDyes[randomItemIndex];
	}

	ActorItem@ RandomPrizeBlueprintItem(ActorItemQuality quality)
	{
		auto gm = cast<Campaign>(g_gameMode);

		array<ActorItem@> possibleBlueprintItems;
		for (uint i = 0; i < g_items.m_allItemsList.length(); i++)
		{
			auto item = g_items.m_allItemsList[i];

			if (!item.hasBlueprints || item.quality != quality)
				continue;

			if (gm.m_townLocal.m_forgeBlueprints.find(item.idHash) != -1)
				continue;

			if (!HasDLC(item.dlc))
				continue;

			possibleBlueprintItems.insertLast(item);
		}

		if (possibleBlueprintItems.length() == 0)
			return null;

		int randomItemIndex = RandomBank::Int(GetRandomContext(), possibleBlueprintItems.length());
		return possibleBlueprintItems[randomItemIndex];
	}

	void WinPrize(const CardGameLimitPrize &in prize)
	{
		print("Prize: " + prize.m_type + " with quality " + prize.m_quality);

		string prizeType = prize.m_type;

		if (prizeType == "dye")
		{
			ActorItemQuality quality = prize.m_quality;
			Materials::Dye@ randomDye = null;

			while (randomDye is null && int(quality) > 0)
			{
				@randomDye = RandomPrizeDye(quality);
				quality = ActorItemQuality(int(quality) - 1);
			}

			if (randomDye !is null)
			{
				GiveDyeImpl(randomDye, GetLocalPlayer(), true);

				m_wPrizeFrame.m_tooltipTitle = Materials::GetCategoryName(randomDye.m_category);
				m_wPrizeFrame.m_tooltipText = Resources::GetString(randomDye.m_name);

				m_wPrizeBackground.m_visible = true;
				m_wPrizeBackground.m_color = GetItemQualityBackgroundColor(randomDye.m_quality);

				m_wPrizeIconDye.m_visible = true;

				string spriteName = "dye-bucket-c";
				switch (randomDye.m_quality)
				{
					case ActorItemQuality::Common: spriteName = "dye-bucket-c"; break;
					case ActorItemQuality::Uncommon: spriteName = "dye-bucket-u"; break;
					case ActorItemQuality::Rare: spriteName = "dye-bucket-r"; break;
				}

				Sprite@ sprite = m_def.GetSprite(spriteName + (1 + randi(2)));
				m_wPrizeIconDye.SetSprite(sprite);

				m_wPrizeIconDye.m_dyeStates = { randomDye.MakeDyeState() };
			}
			else
				prizeType = "drink";
		}
		else if (prizeType == "blueprint")
		{
			ActorItemQuality quality = prize.m_quality;
			ActorItem@ item = null;

			while (item is null && int(quality) > 0)
			{
				@item = RandomPrizeBlueprintItem(quality);
				quality = ActorItemQuality(int(quality) - 1);
			}

			if (item !is null)
			{
				GiveForgeBlueprintImpl(item, GetLocalPlayer(), true);

				m_wPrizeFrame.m_tooltipTitle = "";
				m_wPrizeFrame.m_tooltipText = "\\c" + GetItemQualityColorString(item.quality) + utf8string(Resources::GetString(item.name)).toUpper().plain();

				m_wPrizeBlueprint.m_visible = true;

				m_wPrizeIcon.m_visible = true;
				m_wPrizeIcon.SetSprite(item.icon);
				m_wPrizeIcon.m_offset = vec2(-1, 2);
			}
			else
				prizeType = "drink";
		}

		if (prizeType == "drink")
		{
			auto randomDrink = GetTavernDrink(prize.m_quality);
			if (randomDrink is null)
				return;

			GiveTavernBarrelImpl(randomDrink, GetLocalPlayer(), true);

			m_wPrizeFrame.m_tooltipTitle = "";
			m_wPrizeFrame.m_tooltipText = "\\c" + GetItemQualityColorString(randomDrink.quality) + Resources::GetString(randomDrink.name);

			m_wPrizeIcon.m_visible = true;
			m_wPrizeIcon.SetSprite(randomDrink.icon);
		}

		m_wPrizeText.m_visible = true;
		m_wPrizeFrame.m_visible = true;
	}

	void WinCash()
	{
		Currency::Give(m_limit.m_amount);

		Stats::Add("gambling-gold-won", m_limit.m_amount, GetLocalPlayerRecord());

		if (m_limit.m_prizeChance > 0.0f && m_limit.m_prizes.length() > 0 && RandomBank::Float(GetRandomContext()) <= m_limit.m_prizeChance)
		{
			int randomPrizeIndex = RandomBank::Int(GetRandomContext(), m_limit.m_prizes.length());
			auto prize = m_limit.m_prizes[randomPrizeIndex];

			WinPrize(prize);
		}
	}

	void Play()
	{
		m_wFlipButton.m_enabled = false;
		HideStatus();
		DisableLimitButtons();

		if (m_cardsPlaced)
		{
			AnimateCardsOut();
			return;
		}

		m_cardsPlaced = true;

		do
		{
			m_cardHouse = PullRandomCard();
			m_cardPlayer = PullRandomCard();
		} while (!IsValidCardCombination(m_cardHouse, m_cardPlayer));

		m_waitWin = (m_cardPlayer.y > m_cardHouse.y);

		if (m_limit.m_amount >= 1000000)
			m_waitTime = 5000;
		else
			m_waitTime = 750;

		SetCard("card-house", m_cardHouse);
		SetCard("card-player", m_cardPlayer);

		if (m_limit.m_amount >= 1000000)
		{
			m_wDarkness.Animate(WidgetBoolAnimation("visible", true, 500));
			m_wDarkness.Animate(WidgetBoolAnimation("visible", false, m_waitTime));
			m_wDarknessMoveSprite.SetSprite(m_spriteDarknessSquare);

			PlaySound2D(m_sndSuspense);
		}
		else
			PlaySound2D(m_sndFlip);

		if (m_cardHouse.y == 10 || m_cardPlayer.y == 10)
			m_wDiff.SetText("*");
		else
		{
			int diff = m_cardPlayer.y - m_cardHouse.y;
			if (diff == 0)
				m_wDiff.SetText("-");
			else if (diff > 0)
				m_wDiff.SetText("+" + diff);
			else
				m_wDiff.SetText("" + diff);
		}

		if (m_waitWin)
			m_wDiff.SetColor(tocolor(vec4(0, 1, 0, 1)));
		else
			m_wDiff.SetColor(tocolor(vec4(1, 0, 0, 1)));

		m_wDiff.m_visible = false;
		m_wDiff.Animate(WidgetBoolAnimation("visible", true, m_waitTime));
	}

	void AddSound(SoundEvent@ snd, int delay)
	{
		m_sounds.insertLast(CardGameSound(snd, delay));
	}

	bool ShouldFreezeControls() override { return true; }
	bool ShouldDisplayCursor() override { return true; }
	bool ShouldSaveExistance() override { return false; }

	void Update(int dt) override
	{
		for (int i = int(m_sounds.length()) - 1; i >= 0; i--)
		{
			auto snd = m_sounds[i];
			snd.m_delay -= dt;
			if (snd.m_delay <= 0)
			{
				PlaySound2D(snd.m_snd);
				m_sounds.removeAt(i);
			}
		}

		if (m_waitTime > 0)
		{
			m_waitTime -= dt;
			if (m_waitTime <= 0)
			{
				SetStatus(m_waitWin);
				SetBattleStatus(m_cardPlayer, m_cardHouse);

				if (m_waitWin)
				{
					PlaySound2D(m_sndWin);
					SetGoldStatus(m_limit.m_amount, m_limit.m_amount * 2);
					WinCash();
				}
				else
				{
					PlaySound2D(m_sndLose);
					SetGoldStatus(m_limit.m_amount, 0);
					LoseCash();
				}

				m_wFlipButton.m_enabled = true;

				SetLimitButtons();

				m_waitWin = false;
			}
		}

		if (m_animateOutWaitTime > 0)
		{
			m_animateOutWaitTime -= dt;
			if (m_animateOutWaitTime <= 0)
				Play();
		}

		ScriptWidgetHost::Update(dt);
	}

	void Stop() override
	{
		if (m_waitTime > 0)
			return;

		ScriptWidgetHost::Stop();
	}

	void OnFunc(Widget@ sender, string name) override
	{
		if (name == "close")
			Stop();
		else if (name == "set-limit")
		{
			auto group = cast<CheckBoxGroupWidget>(sender);
			int limitAmount = parseInt(group.GetChecked().GetValue());
			auto limit = GetLimit(limitAmount);

			if (!Currency::CanAfford(limit.m_amount))
			{
				PrintError("Not enough gold!");
				return;
			}

			@m_limit = limit;
		}
		else if (name == "play")
			Play();
	}
}
