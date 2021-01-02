namespace Skills
{
	enum TargetingMode
	{
		Passive,
		Direction,
		TargetAOE,
		Cone,
		Channeling,
		Toggle
	}

	abstract class Skill : IPreRenderable
	{
		Actor@ m_owner;
		ScriptSprite@ m_icon;

		string m_name;
%if HARDCORE
		string m_description;
%endif
		uint m_skillId;

		bool m_isActive;

		Skill(UnitPtr unit)
		{
			@m_owner = cast<Actor>(unit.GetScriptBehavior());
		}
		
		void Initialize(Actor@ owner, ScriptSprite@ icon, uint id) 
		{
			@m_owner = owner;
			@m_icon = icon;
			m_skillId = id;
		}
		
		TargetingMode GetTargetingMode(int &out size) { return TargetingMode::Passive; }
		bool Activate(vec2 target) { return false; }
		void NetActivate(vec2 target) {}
		void Deactivate() {}
		void NetDeactivate() {}
		void Hold(int dt, vec2 target) {}
		void NetHold(int dt, vec2 target) {}
		void Release(vec2 target) {}
		void NetRelease(vec2 target) {}
		
		float GetMoveSpeedMul() { return 1.0f; }
		bool IsActive() { return m_isActive; }
		bool IsBlocking() { return false; }
		bool IgnoreForBlock() { return false; }
		vec2 GetMoveDir() { return vec2(); }
		void OnCollide(UnitPtr unit, vec2 pos, vec2 normal, Fixture@ fxOther) {}
		array<Modifiers::Modifier@>@ GetModifiers() { return null; }
		void RefreshScene(CustomUnitScene@ scene) {}
		void OnDestroy() {}

		void Update(int dt, bool walking)
		{
		}

		string GetFullName(int level)
		{
%if HARDCORE
			return Resources::GetString(m_name);
%else
			string skillName = Resources::GetString(m_name);
			dictionary params = { { "name", skillName }, { "level", level } };
			return Resources::GetString(".skills.fullname", params);
%endif
		}

		string GetFullDescription(int level)
		{
%if HARDCORE
			return Resources::GetString(m_description);
%else
			if (m_name.length() == 0 || m_name.substr(0, 1) != ".")
				return m_name + " " + level;
			return Resources::GetString(m_name + "." + level);
%endif
		}

		bool PreRender(int idt) { return false; }
	}
	
	class NullSkill : Skill
	{
		NullSkill(UnitPtr unit)
		{
			super(unit);
		}
	}
}