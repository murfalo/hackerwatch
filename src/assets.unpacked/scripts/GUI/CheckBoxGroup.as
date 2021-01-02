interface ICheckableWidget
{
	string GetValue();
	bool IsChecked();
	void SetCheckable();
	void SetChecked(bool b);
	void SetGroupWidget(CheckBoxGroupWidget@ group);
	bool IsEnabled();
}

class CheckBoxGroupWidget : ScrollableWidget
{
	array<ICheckableWidget@> m_checkboxes;

	string m_func;
	string m_funcDouble;
	string m_cvar;
	bool m_cvarInit;

	cvar_type m_cvarType;
	string m_cvarOrigString;
	bool m_cvarOrigBool;
	int m_cvarOrigInt;
	float m_cvarOrigFloat;

	bool m_dynamicSize;

	CheckBoxGroupWidget()
	{
		super();
	}

	Widget@ Clone() override
	{
		CheckBoxGroupWidget@ w = CheckBoxGroupWidget();
		CloneInto(w);
		return w;
	}

	void Reset()
	{
		if (m_cvarType == cvar_type::String)
		{
			string def = GetVarStringDefault(m_cvar);
			SetVar(m_cvar, def);
			SetChecked(def);
		}
		else if (m_cvarType == cvar_type::Bool)
		{
			bool def = GetVarBoolDefault(m_cvar);
			SetVar(m_cvar, def);
			if (def)
				SetChecked("true");
			else
				SetChecked("false");
		}
		else if (m_cvarType == cvar_type::Int)
		{
			int def = GetVarIntDefault(m_cvar);
			SetVar(m_cvar, def);
			SetChecked("" + def);
		}
		else if (m_cvarType == cvar_type::Float)
		{
			float def = GetVarFloatDefault(m_cvar);
			SetVar(m_cvar, def);
			SetChecked("" + def);
		}
	}

	void Cancel()
	{
		if (m_cvarType == cvar_type::String)
		{
			SetVar(m_cvar, m_cvarOrigString);
			SetChecked(m_cvarOrigString);
		}
		else if (m_cvarType == cvar_type::Bool)
		{
			SetVar(m_cvar, m_cvarOrigBool);
			if (m_cvarOrigBool)
				SetChecked("true");
			else
				SetChecked("false");
		}
		else if (m_cvarType == cvar_type::Int)
		{
			SetVar(m_cvar, m_cvarOrigInt);
			SetChecked("" + m_cvarOrigInt);
		}
		else if (m_cvarType == cvar_type::Float)
		{
			SetVar(m_cvar, m_cvarOrigFloat);
			SetChecked("" + m_cvarOrigFloat);
		}
	}

	void Save()
	{
		if (m_cvarType == cvar_type::String)
			m_cvarOrigString = GetVarString(m_cvar);
		else if (m_cvarType == cvar_type::Bool)
			m_cvarOrigBool = GetVarBool(m_cvar);
		else if (m_cvarType == cvar_type::Int)
			m_cvarOrigInt = GetVarInt(m_cvar);
		else if (m_cvarType == cvar_type::Float)
			m_cvarOrigFloat = GetVarFloat(m_cvar);
		Config::SaveVar(m_cvar);
	}

	bool IsChanged()
	{
		if (m_cvarType == cvar_type::String)
			return GetVarString(m_cvar) != m_cvarOrigString;
		else if (m_cvarType == cvar_type::Bool)
			return GetVarBool(m_cvar) != m_cvarOrigBool;
		else if (m_cvarType == cvar_type::Int)
			return GetVarInt(m_cvar) != m_cvarOrigInt;
		else if (m_cvarType == cvar_type::Float)
			return GetVarFloat(m_cvar) != m_cvarOrigFloat;
		return false;
	}

	array<ICheckableWidget@> FindCheckables(Widget@ w)
	{
		array<ICheckableWidget@> ret;

		ICheckableWidget@ cb = cast<ICheckableWidget>(w);
		if (cb !is null)
			ret.insertLast(cb);

		for (uint i = 0; i < w.m_children.length(); i++)
		{
			array<ICheckableWidget@> arr = FindCheckables(w.m_children[i]);
			if (arr.length() > 0)
			{
				for (uint j = 0; j < arr.length(); j++)
					ret.insertLast(arr[j]);
			}
		}

		return ret;
	}

	void ClearChildren() override
	{
		ScrollableWidget::ClearChildren();

		m_checkboxes.removeRange(0, m_checkboxes.length());
	}

	void AddChild(ref widget, int insertAt = -1) override
	{
		ScrollableWidget::AddChild(widget, insertAt);

		array<ICheckableWidget@> checkables = FindCheckables(cast<Widget>(widget));
		for (uint i = 0; i < checkables.length(); i++)
		{
			auto checkable = checkables[i];
			checkable.SetCheckable();
			checkable.SetGroupWidget(this);
			m_checkboxes.insertLast(checkable);
		}
	}

	void Toggled(ICheckableWidget@ check)
	{
		for (uint i = 0; i < m_checkboxes.length(); i++)
		{
			if (m_checkboxes[i] is check)
			{
				check.SetChecked(true);
				continue;
			}

			m_checkboxes[i].SetChecked(false);
		}

		if (m_func != "")
			m_host.OnFunc(this, m_func);
	}

	void SetCheckedRandom(int subtract = 0)
	{
		int numEnabled = 0;
		for (int i = 0; i < int(m_checkboxes.length()) - subtract; i++)
		{
			if (m_checkboxes[i].IsEnabled())
				numEnabled++;
		}

		int randomIndex = randi(numEnabled);
		int index = 0;

		for (uint i = 0; i < m_checkboxes.length(); i++)
		{
			if (!m_checkboxes[i].IsEnabled())
				continue;

			if (index == randomIndex)
			{
				SetChecked(i);
				break;
			}

			index++;
		}
	}

	void SetChecked(int index)
	{
		for (uint i = 0; i < m_checkboxes.length(); i++)
			m_checkboxes[i].SetChecked(int(i) == index);
	}

	void SetChecked(string value)
	{
		for (uint i = 0; i < m_checkboxes.length(); i++)
			m_checkboxes[i].SetChecked(m_checkboxes[i].GetValue() == value);
	}

	ICheckableWidget@ GetChecked()
	{
		for (uint i = 0; i < m_checkboxes.length(); i++)
		{
			if (m_checkboxes[i].IsChecked())
				return m_checkboxes[i];
		}
		return null;
	}

	void Update(int dt) override
	{
		ScrollableWidget::Update(dt);

		if (!m_cvarInit && m_cvar != "")
		{
			m_cvarInit = true;

			SetID(m_cvar);
			m_cvarType = GetVarType(m_cvar);

			if (m_cvarType == cvar_type::String)
			{
				m_cvarOrigString = GetVarString(m_cvar);
				SetChecked(m_cvarOrigString);
			}
			else if (m_cvarType == cvar_type::Bool)
			{
				m_cvarOrigBool = GetVarBool(m_cvar);
				if (m_cvarOrigBool)
					SetChecked("true");
				else
					SetChecked("false");
			}
			else if (m_cvarType == cvar_type::Int)
			{
				m_cvarOrigInt = GetVarInt(m_cvar);
				SetChecked("" + m_cvarOrigInt);
			}
			else if (m_cvarType == cvar_type::Float)
			{
				m_cvarOrigFloat = GetVarFloat(m_cvar);
				SetChecked("" + m_cvarOrigFloat);
			}
			else
				PrintError("Unhandled cvar type: " + int(m_cvarType));
		}
	}

	void Load(WidgetLoadingContext &ctx) override
	{
		m_func = ctx.GetString("func", false);
		m_funcDouble = ctx.GetString("func-double", false);

		m_cvar = ctx.GetString("cvar", false);

		m_autoScroll = false;
		m_clipping = false;

		ScrollableWidget::Load(ctx);

		m_dynamicSize = ctx.GetBoolean("dynamic-size", false, true);
		if (!m_dynamicSize)
			LoadWidthHeight(ctx, true);
	}

	void DoLayout(vec2 origin, vec2 parentSz) override
	{
		if (m_dynamicSize)
		{
			m_width = int(parentSz.x);
			m_height = int(parentSz.y);
		}

		ScrollableWidget::DoLayout(origin, parentSz);
	}

	bool OnDoubleClick(vec2 mousePos) override
	{
		if (m_funcDouble != "")
			m_host.OnFunc(this, m_funcDouble);

		return true;
	}
}

ref@ LoadCheckBoxGroupWidget(WidgetLoadingContext &ctx)
{
	CheckBoxGroupWidget@ w = CheckBoxGroupWidget();
	w.Load(ctx);
	return w;
}
