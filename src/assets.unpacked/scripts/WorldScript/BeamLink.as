namespace WorldScript
{
	class BeamLinkActorConnection
	{
		Actor@ m_actor;
		int m_timeC;
		int m_touchC;

		BeamLinkActorConnection(Actor@ actor)
		{
			@m_actor = actor;
		}
	}

	class BeamLinkConnection
	{
		BeamLink@ m_link;

		UnitPtr m_source;
		UnitPtr m_target;

		EffectBehavior@ m_fx;

		bool m_shouldDelete = false;

		float m_hitLengthPrev;
		float m_hitLength;

		array<BeamLinkActorConnection@> m_touchingUnits;

		BeamLinkConnection(BeamLink@ link)
		{
			@m_link = link;
		}

		/// Returns true if this actor has just started touching the beam
		bool UnitTouched(Actor@ actor)
		{
			for (uint i = 0; i < m_touchingUnits.length(); i++)
			{
				auto touch = m_touchingUnits[i];
				if (touch.m_actor is actor)
				{
					touch.m_touchC = 0;
					return false;
				}
			}
			auto newTouch = BeamLinkActorConnection(actor);
			newTouch.m_timeC = m_link.Frequency;
			m_touchingUnits.insertLast(newTouch);
			return true;
		}

		void Save(SValueBuilder@ builder)
		{
			builder.PushDictionary();
			builder.PushInteger("source", m_source.GetId());
			builder.PushInteger("target", m_target.GetId());
			builder.PushBoolean("visible", IsVisible());
			builder.PopDictionary();
		}

		void Load(SValue@ data)
		{
			auto source = g_scene.GetUnit(GetParamInt(UnitPtr(), data, "source", false, m_source.GetId()));
			auto target = g_scene.GetUnit(GetParamInt(UnitPtr(), data, "target", false, m_target.GetId()));
			bool visible = GetParamBool(UnitPtr(), data, "visible", false, IsVisible());

			Connect(source, target);
			SetVisible(visible);
		}

		bool IsVisible() { return m_fx !is null; }

		void SetVisible(bool visible)
		{
			if (m_shouldDelete)
				return;

			if (visible && m_fx is null)
			{
				UnitPtr source = m_source;
				UnitPtr fx = PlayEffect(m_link.Effect, source, {});

				@m_fx = cast<EffectBehavior>(fx.GetScriptBehavior());
				if (m_fx !is null)
					m_fx.m_looping = true;
			}
			else if (!visible && m_fx !is null)
			{
				m_fx.m_unit.Destroy();
				@m_fx = null;
			}
		}

		void Connect(UnitPtr source, UnitPtr target)
		{
			m_source = source;
			m_target = target;

			m_hitLengthPrev = m_hitLength = dist(target.GetPosition(), source.GetPosition());
		}

		void DoDamage(BeamLinkActorConnection@ touch, const vec2 &in dir)
		{
			if (!IsVisible())
				return;

			DamageInfo di;
			di.PhysicalDamage = m_link.PhysicalDamage;
			di.MagicalDamage = m_link.MagicalDamage;
			di.CanKill = m_link.CanKill;
			touch.m_actor.Damage(di, vec2(), dir);

			if (m_link.m_buff !is null)
				touch.m_actor.ApplyBuff(ActorBuff(null, m_link.m_buff, 1.0f, false));
		}

		void DoDamage(Actor@ actor, const vec2 &in dir)
		{
			if (!IsVisible())
				return;

			for (uint i = 0; i < m_touchingUnits.length(); i++)
			{
				auto touch = m_touchingUnits[i];
				if (touch.m_actor is actor)
				{
					DoDamage(touch, dir);
					return;
				}
			}
		}

		void Update(int dt)
		{
			if (m_source.IsDestroyed() || m_target.IsDestroyed())
			{
				SetVisible(false);
				m_shouldDelete = true;
				return;
			}

			UnitPtr source = m_source;

			vec2 targetPos = xy(m_target.GetPosition());
			vec2 sourcePos = xy(source.GetPosition());

			float d = dist(sourcePos, targetPos);
			vec2 dir = normalize(targetPos - sourcePos);

			if (d > m_link.Range)
			{
				SetVisible(false);
				return;
			}

			m_hitLengthPrev = m_hitLength;
			m_hitLength = dist(targetPos, sourcePos);

			for (int i = int(m_touchingUnits.length()) - 1; i >= 0; i--)
			{
				auto touch = m_touchingUnits[i];
				if (touch.m_touchC >= 2)
				{
					m_touchingUnits.removeAt(i);
					continue;
				}
				touch.m_touchC++;

				touch.m_timeC -= dt;
				if (touch.m_timeC <= 0)
				{
					DoDamage(touch, dir);
					touch.m_timeC = m_link.Frequency;
				}
			}

			bool shouldBeVisible = true;

			auto arrRes = g_scene.RaycastWide(m_link.RaycastCount, m_link.RaycastWidth, sourcePos, targetPos, ~0, RaycastType::Shot);
			for (uint i = 0; i < arrRes.length(); i++)
			{
				auto res = arrRes[i];
				UnitPtr unit = res.FetchUnit(g_scene);
				if (unit == m_target)
					continue;

				if (unit.GetScriptBehavior() is null)
				{
					if (m_link.BreakOnSolid)
						shouldBeVisible = false;
					else
						m_hitLength = dist(res.point, sourcePos);
					break;
				}

				auto actor = cast<Actor>(unit.GetScriptBehavior());
				if (actor is null || actor.Team == m_link.m_teamHash)
					continue;

				if (UnitTouched(actor))
					DoDamage(actor, dir);

				if (actor.Impenetrable())
					break;
			}

			SetVisible(shouldBeVisible);
		}

		void PreRender(int idt)
		{
			if (m_fx is null)
				return;

			float mul = idt / 33.0f;

			vec2 targetPos = xy(m_target.GetInterpolatedPosition(idt));
			vec2 sourcePos = xy(m_source.GetInterpolatedPosition(idt));

			float d = lerp(m_hitLengthPrev, m_hitLength, mul);
			vec2 dir = normalize(targetPos - sourcePos);

			m_fx.SetParam("angle", atan(dir.y, dir.x));
			m_fx.SetParam("length", m_hitLength);
		}
	}

	[WorldScript color="#00A9FFFF" icon="system/icons.png;0;96;32;32"]
	class BeamLink : IPreRenderable
	{
		[Editable]
		UnitFeed Source;

		[Editable]
		UnitFeed Connected;

		[Editable]
		UnitScene@ Effect;

		[Editable default=100]
		float Range;

		[Editable default="enemy"]
		string Team;

		[Editable default=100]
		int Frequency;

		[Editable default=10 min=0 max=1000000]
		int PhysicalDamage;

		[Editable default=0 min=0 max=1000000]
		int MagicalDamage;

		[Editable default=true]
		bool CanKill;

		[Editable]
		string Buff;

		[Editable default=2]
		int RaycastCount;

		[Editable default=4]
		int RaycastWidth;

		[Editable default=true]
		bool BreakOnSolid;

		uint m_teamHash;

		ActorBuffDef@ m_buff;

		array<BeamLinkConnection@> m_connections;

		BeamLinkConnection@ GetConnection(UnitPtr source, UnitPtr target)
		{
			for (uint i = 0; i < m_connections.length(); i++)
			{
				auto conn = m_connections[i];
				if (conn.m_source == source && conn.m_target == target)
					return conn;
			}
			return null;
		}

		void ClearConnections()
		{
			for (uint i = 0; i < m_connections.length(); i++)
			{
				auto conn = m_connections[i];
				conn.SetVisible(false);
				conn.m_shouldDelete = true;
			}
			m_connections.removeRange(0, m_connections.length());
		}

		void Initialize()
		{
			m_teamHash = HashString(Team);

			@m_buff = LoadActorBuff(Buff);

			m_preRenderables.insertLast(this);
		}

		SValue@ Save()
		{
			SValueBuilder builder;
			builder.PushArray();
			for (uint i = 0; i < m_connections.length(); i++)
				m_connections[i].Save(builder);
			builder.PopArray();
			return builder.Build();
		}

		void Load(SValue@ data)
		{
			auto arrConnections = data.GetArray();
			for (uint i = 0; i < arrConnections.length(); i++)
			{
				auto newConnection = BeamLinkConnection(this);
				newConnection.Load(arrConnections[i]);
				m_connections.insertLast(newConnection);
			}
		}

		void Update(int dt)
		{
			for (int i = int(m_connections.length()) - 1; i >= 0; i--)
			{
				if (i >= int(m_connections.length()))
				{
					PrintError("Unexpected loss of connection at index " + i + " with " + m_connections.length() + " current connections");
					continue;
				}

				auto conn = m_connections[i];
				conn.Update(dt);

				if (conn.m_shouldDelete)
					m_connections.removeAt(i);
			}
		}

		bool PreRender(int idt)
		{
			for (uint i = 0; i < m_connections.length(); i++)
				m_connections[i].PreRender(idt);

			return false;
		}

		SValue@ ServerExecute()
		{
			auto arrSources = Source.FetchAll();
			auto arrTargets = Connected.FetchAll();

			for (uint j = 0; j < arrSources.length(); j++)
			{
				UnitPtr source = arrSources[j];

				for (uint i = 0; i < arrTargets.length(); i++)
				{
					UnitPtr target = arrTargets[i];

					auto conn = GetConnection(source, target);
					if (conn !is null)
						continue;

					auto newConnection = BeamLinkConnection(this);
					newConnection.Connect(source, target);
					m_connections.insertLast(newConnection);
				}
			}
			return null;
		}

		void ClientExecute(SValue@ sval)
		{
			ServerExecute();
		}
	}
}
