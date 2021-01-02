class FavorButtonWidget : ScalableSpriteButtonWidget
{
	Fountain::Effect@ m_effect;

	BitmapString@ m_textPrice;

	bool m_lockedIn;
	array<Sprite@> m_spriteLockedIn;

	Sprite@ m_spriteFavorGood;
	Sprite@ m_spriteFavorBad;

	FavorButtonWidget()
	{
		super();
	}

	int opCmp(const Widget@ w) override
	{
		auto other = cast<FavorButtonWidget>(w);

		if (m_effect.m_favor > other.m_effect.m_favor)
			return 1;
		else if (m_effect.m_favor < other.m_effect.m_favor)
			return -1;

		return 0;
	}

	Widget@ Clone() override
	{
		FavorButtonWidget@ w = FavorButtonWidget();
		CloneInto(w);
		return w;
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		m_textOffset = vec2(36, -1);

		ScalableSpriteButtonWidget::Load(ctx);

		GUIDef@ def = ctx.GetGUIDef();
		string spriteSet = ctx.GetString("spriteset");

		m_spriteLockedIn.insertLast(def.GetSprite(spriteSet + "-lockedin-left"));
		m_spriteLockedIn.insertLast(def.GetSprite(spriteSet + "-lockedin-mid"));
		m_spriteLockedIn.insertLast(def.GetSprite(spriteSet + "-lockedin-right"));

		@m_spriteFavorGood = def.GetSprite("icon-favor-good");
		@m_spriteFavorBad = def.GetSprite("icon-favor-bad");

		m_checkable = true;

		@m_font = Resources::GetBitmapFont("gui/fonts/arial11.fnt");
	}

	void Set(Fountain::Effect@ effect, int shopLevel)
	{
		@m_effect = effect;

		m_value = effect.m_id;

		if (effect.m_favor > 0)
		{
			@m_textPrice = m_font.BuildText("+" + effect.m_favor);
			m_textPrice.SetColor(vec4(0, 1, 0, 1));
		}
		else
		{
			@m_textPrice = m_font.BuildText("" + effect.m_favor);
			m_textPrice.SetColor(vec4(1, 0, 0, 1));
		}

		m_enabled = (Network::IsServer() && Fountain::CurrentEffects.length() == 0 && shopLevel >= effect.m_level);

		m_lockedIn = Fountain::HasEffect(effect.m_idHash);

		string name = Resources::GetString(".fountain.effect." + effect.m_id + ".name");
		string desc = Resources::GetString(".fountain.effect." + effect.m_id + ".description");

		m_tooltipTitle = name;
		m_tooltipText = desc;

		if (shopLevel < effect.m_level)
			m_tooltipText += "\n\n" + Resources::GetString(".fountain.requiredlevel", { { "level", effect.m_level } });

		if (effect.m_favor > 0)
			AddTooltipSub(m_spriteFavorGood, "+" + effect.m_favor);
		else
			AddTooltipSub(m_spriteFavorBad, "" + effect.m_favor);

		SetText(name);
	}

	vec4 GetTextColor() override
	{
		if (m_lockedIn)
			return vec4(1, 1, 1, 1);

		return ScalableSpriteButtonWidget::GetTextColor();
	}

	array<Sprite@> GetSprites() override
	{
		if (m_lockedIn)
			return m_spriteLockedIn;

		return ScalableSpriteButtonWidget::GetSprites();
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		ScalableSpriteButtonWidget::DoDraw(sb, pos);

		vec2 pricePos = vec2(
			pos.x + m_width - m_textPrice.GetWidth() - m_textOffset.x,
			pos.y + m_height / 2 - m_textPrice.GetHeight() / 2 + m_textOffset.y - 1
		);
		sb.DrawString(pricePos, m_textPrice);
	}
}

ref@ LoadFavorButtonWidget(WidgetLoadingContext &ctx)
{
	FavorButtonWidget@ w = FavorButtonWidget();
	w.Load(ctx);
	return w;
}
