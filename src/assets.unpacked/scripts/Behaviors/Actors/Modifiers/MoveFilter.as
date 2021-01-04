namespace Modifiers
{
	class MoveFilter : FilterModifier
	{
		bool m_invert;
		
		MoveFilter(UnitPtr unit, SValue& params)
		{
			super(unit, params);
			m_invert = GetParamBool(unit, params, "invert", false, false);
		}	

		void Initialize(SyncVerb verb, uint id, uint modId) override
		{
			m_syncVerb = verb;
			m_syncId = id;

			FilterModifier::Initialize(verb, id, modId);
		}

		bool Filter(PlayerBase@ player, Actor@ enemy) override 
		{ 
			bool moving = player is null ? false : (lengthsq(player.m_unit.GetMoveDir()) > 0.01);
			return m_invert ? !moving : moving;
		}
	}
}