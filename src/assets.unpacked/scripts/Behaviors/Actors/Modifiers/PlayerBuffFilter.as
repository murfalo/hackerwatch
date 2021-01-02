namespace Modifiers
{
	class PlayerBuffFilter : FilterModifier
	{
		uint64 m_tags;

		PlayerBuffFilter(UnitPtr unit, SValue& params)
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
			return player.m_buffs.HasTags(m_tags);
		}
	}
}
