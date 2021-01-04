namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;384;128;32;32"]
	class AreaRayTrigger
	{
		vec3 Position;

		[Editable]
		array<CollisionArea@>@ Areas;

		[Editable type=flags default=2]
		AreaFilter Filter;

		[Editable type=enum default=2]
		RaycastType RayType;

		UnitSource AllInside;
		UnitSource LastEntered;

		array<UnitPtr> m_enterQueue;

		void Initialize()
		{
			if (Network::IsServer())
			{
				for (uint i = 0; i < Areas.length(); i++)
				{
					Areas[i].AddOnEnter(this, "OnEnter");
					Areas[i].AddOnExit(this, "OnExit");
				}
			}
		}

		void Update(int dt)
		{
			for (int i = int(m_enterQueue.length() - 1); i >= 0; i--)
			{
				UnitPtr u = m_enterQueue[i];
				auto res = g_scene.Raycast(xy(Position), xy(u.GetPosition()), ~0, RayType);
				for (uint j = 0; j < res.length(); j++)
				{
					auto rayUnit = res[j].FetchUnit(g_scene);
					if (rayUnit == u)
					{
						m_enterQueue.removeAt(i);
						WorldScript::GetWorldScript(g_scene, this).Execute();
						break;
					}
					else if (rayUnit.GetScriptBehavior() is null)
						break;
				}
			}
		}

		void OnEnabledChanged(bool enabled)
		{
			AllInside.Clear();
			m_enterQueue.removeRange(0, m_enterQueue.length());

			if (!enabled)
				return;

			for (uint i = 0; i < Areas.length(); i++)
			{
				auto units = Areas[i].FetchAllInside(g_scene);
				for (uint j = 0; j < units.length(); j++)
				{
					if (!ApplyAreaFilter(units[j], Filter))
						continue;

					m_enterQueue.insertLast(units[j]);
				}
			}
		}

		void OnEnter(UnitPtr unit, vec2 pos, vec2 normal)
		{
			if (!ApplyAreaFilter(unit, Filter))
				return;

			m_enterQueue.insertLast(unit);
		}

		void OnExit(UnitPtr unit)
		{
			if (!ApplyAreaFilter(unit, Filter))
				return;

			int index = m_enterQueue.find(unit);
			if (index != -1)
				m_enterQueue.removeAt(index);
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
