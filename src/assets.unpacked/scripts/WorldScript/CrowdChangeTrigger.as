enum CrowdChangeState
{
	Less,
	More,
	Equal
}

array<WorldScript::CrowdChangeTrigger@> g_crowdChangeTriggers;

namespace WorldScript
{
	[WorldScript color="210 105 30" icon="system/icons.png;96;96;32;32"]
	class CrowdChangeTrigger
	{
		[Editable type=enum default=1]
		CrowdChangeState ChangeState;

		void Initialize()
		{
			g_crowdChangeTriggers.insertLast(this);
		}

		void OnChange(float delta)
		{
			bool trigger = false;
			if (ChangeState == CrowdChangeState::Less && delta < 0.0f)
				trigger = true;
			else if (ChangeState == CrowdChangeState::More && delta > 0.0f)
				trigger = true;
			else if (ChangeState == CrowdChangeState::Equal)
				trigger = true;

			if (!trigger)
				return;

			WorldScript::GetWorldScript(g_scene, this).Execute();
		}

		SValue@ ServerExecute()
		{
			return null;
		}
	}
}
