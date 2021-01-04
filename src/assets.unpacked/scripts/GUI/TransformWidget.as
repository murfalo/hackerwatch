class TransformWidget : Widget
{
	bool m_dynamicSz;
	mat4 m_transform;

	bool m_nativeScale;
	float m_scale = 1.0f;

	TransformWidget()
	{
		super();
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		mat3 tform;

		vec2 shear = ctx.GetVector2("shear", false);
		if (shear.x != 0)
			tform = mat::shearY(tform, shear.x);
		if (shear.y != 0)
			tform = mat::shearX(tform, shear.y);

		float rot = ctx.GetFloat("rotate", false);
		if (rot != 0)
			tform = mat::rotate(tform, rot * PI / 180.0);

		m_transform = mat4(tform);

		int w = ctx.GetInteger("width", false, -1);
		int h = ctx.GetInteger("height", false, -1);

		if (w != -1 && h != -1)
		{
			m_width = w;
			m_height = h;
			m_dynamicSz = false;
		}
		else
			m_dynamicSz = true;

		string strScale = ctx.GetString("scale", false);
		if (strScale != "")
		{
			m_nativeScale = true;
			m_scale = parseFloat(strScale);
		}

		Widget::Load(ctx);
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (m_dynamicSz)
		{
			int w = int(parentSz.x);
			int h = int(parentSz.y);

			if (m_nativeScale)
			{
				w = int(w * g_gameMode.m_wndScale / m_scale);
				h = int(h * g_gameMode.m_wndScale / m_scale);
			}

			m_width = w;
			m_height = h;
		}

		Widget::DoLayout(origin, parentSz);
	}

	void Draw(SpriteBatch& sb, bool debugDraw) override
	{
		float px = m_origin.x;
		float py = m_origin.y;

		mat4 tform;
		tform = mat::translate(tform, vec3(px, py, 0));

		tform *= m_transform;
		if (m_nativeScale)
		{
			tform *= g_gameMode.m_wndInvScaleTransform;
			tform *= mat::scale(mat4(), m_scale);
		}

		tform = mat::translate(tform, vec3(-px, -py, 0));

		sb.PushTransformation(tform);

		Widget::Draw(sb, debugDraw);

		sb.PopTransformation();
	}
}

ref@ LoadTransformWidget(WidgetLoadingContext &ctx)
{
	TransformWidget@ w = TransformWidget();
	w.Load(ctx);
	return w;
}
