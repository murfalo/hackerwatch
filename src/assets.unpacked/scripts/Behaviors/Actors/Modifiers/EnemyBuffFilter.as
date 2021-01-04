namespace Modifiers
{
	class EnemyBuffFilter : FilterModifier
	{
		uint64 m_tags;

		EnemyBuffFilter(UnitPtr unit, SValue& params)
		{
			super(unit, params);

			m_tags = GetBuffTags(params);
		}

		void Initialize(SyncVerb verb, uint id, uint modId) override
		{
			m_syncVerb = verb;
			m_syncId = id;

			FilterModifier::Initialize(verb, id, modId);
		}

		bool Filter(PlayerBase@ player, Actor@ enemy) override
		{
			auto eb = cast<CompositeActorBehavior>(enemy);
			if (eb is null)
				return false;

			return eb.m_buffs.HasTags(m_tags);
		}
	}
}
