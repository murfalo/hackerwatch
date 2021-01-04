class Actor : IDamageTaker
{
	uint Team;
	UnitPtr m_unit;

	bool m_countsAsKill;

	bool m_crosshairColors;
	bool m_floatingHurt = true;

	array<UnitPtr> m_attachedUnits;

	Actor(UnitPtr unit)
	{
		m_unit = unit;
	}

	float GetWindScale() { return 1.0f; }

	void AddFloatingHurt(int num, int crit = 0, FloatingTextType type = FloatingTextType::EnemyHurt)
	{
		if (!m_floatingHurt)
			return;

		if (crit <= 0)
			AddFloatingNumber(type, num, m_unit.GetPosition());
		else
		{
			string dmgText = Resources::GetString(".misc.dmg.crit" + clamp(crit, 0, 5), { { "dmg", num } });
			AddFloatingText(FloatingTextType::EnemyImmortal, dmgText, m_unit.GetPosition());
		}
	}

	void AddFloatingImmortal(int num, FloatingTextType type = FloatingTextType::EnemyImmortal)
	{
		AddFloatingText(type, Resources::GetString(".misc.dmg.immortal"), m_unit.GetPosition());
		//AddFloatingNumber(type, num, m_unit.GetPosition());
	}

	void AddFloatingGive(int num, FloatingTextType type = FloatingTextType::EnemyHealed)
	{
		AddFloatingNumber(type, num, m_unit.GetPosition());
	}

	void SetTeam(string str, bool countsAsKill = true)
	{
		SetTeam(HashString(str), countsAsKill);
	}

	void SetTeam(uint tm, bool countsAsKill = true)
	{
		Team = tm;
		m_countsAsKill = countsAsKill;
		
		ActorCollection@ coll = GetActorList(Team);
		if (coll is null)
		{
			@coll = ActorCollection();
			coll.m_team = Team;
			g_actors.insertLast(coll);
		}
		coll.m_arr.insertLast(this);
		
		if (m_countsAsKill)
			g_totalEnemies++;
	}

	float GetHealth() { return 1; }
	
	void Kill(Actor@ killer, uint weapon) {}
	int Damage(DamageInfo dmg, vec2 pos, vec2 dir) override { return 0; }
	int Decimate(DecimateInfo dec, vec2 pos, vec2 dir) override { return 0; }
	void NetDecimate(int hp, int mana) override {}
	int Heal(int amount) { return 0; }
	bool IsDead() override { return false; }
	bool Impenetrable() override { return false; }
	bool ApplyBuff(ActorBuff@ buff) { return false; }
	bool HasBuff(uint buff) { return false; }
	void KilledActor(Actor@ killed, DamageInfo di) {}
	
	void NetDamage(DamageInfo dmg, vec2 pos, vec2 dir) override {}
	void NetKill(Actor@ attacker, uint16 dmg, vec2 dir, uint weapon) {}
	void NetHeal(int amt) {}
	void NetSetTarget(Actor@ target) {}
	void NetUseSkill(int skillId, int stage, vec2 pos, SValue@ param) {}
	
	void SpreadTarget(Actor@ target, int spreadTargetCount) {}
	bool IsTargetable() { return true; }
	void SetImmortal(bool immortal) {}
	bool IsImmortal(bool ignoreBuffs = false) { return false; }
	bool IsHusk() { return !Network::IsServer(); }
	bool Ricochets() override { return false; }
	bool ShootThrough(Actor@ attacker, vec2 pos, vec2 dir) override { return false; }
	bool BlockProjectile(IProjectile@ proj) { return false; }

	void WarnCooldown(Skills::Skill@ skill, int ms) {}
	bool SpendCost(int mana, int stamina, int health) { return true; }
	int SetUnitScene(AnimString@ anim, bool resetScene) { return 0; }
	int IconHeight() { return -20; }
}

class ActorCollection
{
	uint m_team;
	array<Actor@> m_arr;
}

ActorCollection@ GetActorList(uint team)
{
	for (uint i = 0; i < g_actors.length(); i++)
	{
		auto coll = g_actors[i];
		if (coll.m_team == team)
			return coll;
	}
	return null;
}

uint GetActorListId(uint team)
{
	return team;
	/*
	for (uint i = 0; i < g_actors.length(); i++)
	{
		auto coll = g_actors[i];
		if (coll.m_team == team)
			return i + 1;
	}
	return 0;
	*/
}

vec2 FetchOffsetPos(UnitPtr unit, string offset)
{
	vec2 pos = xy(unit.GetPosition());
	if (offset != "")
		pos += unit.FetchLocator(offset);
		
	return pos;
}

array<ActorCollection@> g_actors;
int g_totalEnemies;
int g_totalEnemiesTotal;
int g_killedEnemies;
int g_killedEnemiesTotal;

uint g_team_none = HashString("");
uint g_team_player = HashString("player");
uint g_team_civilian = HashString("civilian");
