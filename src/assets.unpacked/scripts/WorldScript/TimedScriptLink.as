namespace WorldScript
{
	class TimedScriptLinkItem
	{
		WorldScript@ m_script;
		int m_timeC;

		TimedScriptLinkItem(WorldScript@ ws, int time)
		{
			@m_script = ws;
			m_timeC = time;
		}
	}

	[WorldScript color="#5D7A9EFF" icon="system/icons.png;416;128;32;32"]
	class TimedScriptLink
	{
		[Editable validation=IsExecutable]
		UnitFeed LinkScripts;

		[Editable]
		int TimeMin;

		[Editable]
		int TimeMax;

		array<TimedScriptLinkItem@> m_items;

		bool IsExecutable(UnitPtr unit)
		{
			WorldScript@ script = WorldScript::GetWorldScript(unit);
			if (script is null)
				return false;

			return script.IsExecutable();
		}

		SValue@ ServerExecute()
		{
			auto arrScripts = LinkScripts.FetchAll();
			for (uint j = 0; j < arrScripts.length(); j++)
			{
				auto ws = WorldScript::GetWorldScript(g_scene, arrScripts[j].GetScriptBehavior());
				int time = TimeMin + randi(TimeMax - TimeMin);
				m_items.insertLast(TimedScriptLinkItem(ws, time));
			}
			return null;
		}

		void Update(int dt)
		{
			for (int i = int(m_items.length()) - 1; i >= 0; i--)
			{
				auto item = m_items[i];
				item.m_timeC -= dt;
				if (item.m_timeC <= 0)
				{
					m_items.removeAt(i);
					item.m_script.Execute();
				}
			}
		}

		SValue@ Save()
		{
			SValueBuilder builder;

			builder.PushArray();
			for (uint i = 0; i < m_items.length(); i++)
			{
				auto item = m_items[i];
				builder.PushArray();
				builder.PushInteger(item.m_script.GetUnit().GetId());
				builder.PushInteger(item.m_timeC);
				builder.PopArray();
			}
			builder.PopArray();

			return builder.Build();
		}

		void Load(SValue@ save)
		{
			auto arr = save.GetArray();
			for (uint i = 0; i < arr.length(); i++)
			{
				auto arrItem = arr[i].GetArray();

				UnitPtr unit = g_scene.GetUnit(arrItem[0].GetInteger());
				auto ws = WorldScript::GetWorldScript(g_scene, unit.GetScriptBehavior());

				int timeC = arrItem[1].GetInteger();

				m_items.insertLast(TimedScriptLinkItem(ws, timeC));
			}
		}
	}
}
