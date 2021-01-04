class SkillWidget : Widget
{
	GUIDef@ m_def;

	Skills::ActiveSkill@ m_skill;
	BitmapFont@ m_font;
	BitmapString@ m_manaCost;
	int m_manaCostCache;
	

	SkillWidget()
	{
		super();

		m_width = 0;
		m_height = 0;
		m_manaCostCache = -1;
		
		@m_font = Resources::GetBitmapFont("gui/fonts/font_hw8.fnt");
	}

	Widget@ Clone() override
	{
		auto w = SkillWidget();
		w.SetSkill(m_skill);
		return w;
	}
	
	void RefreshManaCost(int manaCost)
	{
		if (m_manaCostCache == manaCost)
			return;
	
		m_manaCostCache = manaCost;
		@m_manaCost = m_font.BuildText("" + manaCost, -1, TextAlignment::Right);
	}

	void SetSkill(Skills::Skill@ skill)
	{
		@m_skill = cast<Skills::ActiveSkill>(skill);
		if (m_skill !is null)
			RefreshManaCost(m_skill.m_costMana);
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		@m_def = ctx.GetGUIDef();
		Widget::Load(ctx);
	}

	void DoDraw(SpriteBatch& sb, vec2 pos) override
	{
		if (m_skill is null || m_skill.m_icon is null)
			return;

		int idt = 0;

		auto frame = m_skill.m_icon.GetFrame(0);
		vec4 p = vec4(pos.x, pos.y, frame.z, frame.w);

		auto texture_cd = Resources::GetTexture2D("gui/icons_skills_cd.png");
		if (texture_cd is null)
		{
			sb.EnableColorize(vec4(0.1,0.1,0.1, 1), vec4(2,2,2, 1), vec4(4,4,4, 1));
			sb.DrawSprite(m_skill.m_icon.m_texture, p, frame, vec4(4,4,4,1));
			sb.DisableColorize();
		}
		else
			sb.DrawSprite(texture_cd, p, frame);

		sb.DrawSpriteRadial(m_skill.m_icon.m_texture, p, frame, 1.0 - m_skill.GetCooldownProgess(idt), vec4(1,1,1,1));
		
		auto player = GetLocalPlayer();
		if (player !is null && m_skill.m_costMana > 0)
		{
			int manaCost = int(m_skill.m_costMana * g_allModifiers.SpellCostMul(player));
			RefreshManaCost(manaCost);
			if (manaCost > player.m_record.mana * (player.m_record.MaxMana() + g_allModifiers.StatsAdd(player).y))
				m_manaCost.SetColor(vec4(1, 0, 0, 1));
			else if (m_skill.m_cooldownC > 0)
				m_manaCost.SetColor(vec4(0.1, 0.1, 0.1, 1));
			else
				m_manaCost.SetColor(vec4(0.6, 0.6, 1, 1));
			
			sb.DrawString(pos + vec2(frame.z - m_manaCost.GetWidth(), frame.w - m_manaCost.GetHeight()), m_manaCost);
		}
	}
}

ref@ LoadSkillWidget(WidgetLoadingContext &ctx)
{
	SkillWidget@ w = SkillWidget();
	w.Load(ctx);
	return w;
}
