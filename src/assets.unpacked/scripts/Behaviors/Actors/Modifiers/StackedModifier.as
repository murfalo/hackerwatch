namespace Modifiers
{
	class StackedModifier : Modifier
	{
		int m_stackCount = 1;

		Modifier@ Instance() override
		{
			auto ret = StackedModifier();
			ret = this;
			ret.m_cloned++;
			return ret;
		}
	}
}
