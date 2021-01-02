class SpawnUnitBase
{
	[Editable]
	UnitProducer@ UnitType;

	[Editable]
	string SceneName;

	[Editable]
	int Layer;
	
	[Editable]
	float JitterX;
	[Editable]
	float JitterY;
	
	[Editable]
	int Delay;
	
	
	[Editable default=false]
	bool AggroEnemy;
	[Editable default=false]
	bool NoLootEnemy;
	[Editable default=false]
	bool NoExperienceEnemy;

	[Editable]
	uint WeaponInfo;

	

	void Initialize(UnitPtr unit, SValue@ params)
	{
		if (params !is null)
		{
			@UnitType = Resources::GetUnitProducer(GetParamString(unit, params, "unit", false));
			SceneName = GetParamString(unit, params, "scene", false, "");
			Layer = GetParamInt(unit, params, "layer", false, 0);
			Delay = GetParamInt(unit, params, "delay", false, 0);
			AggroEnemy = GetParamBool(unit, params, "aggro", false, false);
			NoLootEnemy = GetParamBool(unit, params, "no-loot", false, false);
			NoExperienceEnemy = GetParamBool(unit, params, "no-experience", false, false);
			vec2 jitter = GetParamVec2(unit, params, "jitter", false);
			JitterX = jitter.x;
			JitterY = jitter.y;
		}
	}
	
	vec2 CalcJitter()
	{
		return vec2((randf() * 2.0 - 1.0) * JitterX, (randf() * 2.0 - 1.0) * JitterY);
	}
	
	UnitPtr SpawnUnit(vec2 pos, Actor@ owner, float intensity = 1.0)
	{
		auto prod = UnitMap::Replace(UnitType);

		if (prod is null)
			return UnitPtr();

		int8 cfgEnemy = SpawnUnitBaseHandler::PackEnemyCfg(AggroEnemy, NoLootEnemy, NoExperienceEnemy);
		if (!Network::IsServer() && IsNetsyncedExistance(prod.GetNetSyncMode()))
		{
			(Network::Message("DoSpawnUnitBase") << Delay << prod.GetResourceHash() << pos << SceneName << Layer << cfgEnemy << (owner is null ? 0 : owner.m_unit.GetId()) << intensity << WeaponInfo).SendToHost();
			return UnitPtr();
		}
		
		if (Delay > 0)
		{
			QueuedTasks::Queue(Delay, SpawnUnitBaseTask(prod, pos, SceneName, Layer, cfgEnemy, owner is null ? UnitPtr() : owner.m_unit, intensity, WeaponInfo));
			return UnitPtr();
		}
		
		return SpawnUnitBaseImpl(prod, pos, SceneName, Layer, cfgEnemy, owner is null ? UnitPtr() : owner.m_unit, intensity, WeaponInfo);
	}
}

UnitPtr SpawnUnitBaseImpl(UnitProducer@ UnitType, vec2 pos, string scene, int layer, int cfgEnemy, UnitPtr owner, float intensity, uint weaponInfo)
{
	auto prod = UnitMap::Replace(UnitType);

	UnitPtr u;
	if (prod is null)
		return u;
	
	u = prod.Produce(g_scene, xyz(pos));
	
	auto enemyBehavior = cast<CompositeActorBehavior>(u.GetScriptBehavior());
	if (enemyBehavior !is null)
		SpawnUnitBaseHandler::ConfigureEnemy(enemyBehavior, cfgEnemy);
	else
		cfgEnemy = 0;
		
	if (scene != "")
		u.SetUnitScene(scene, true);
	if (layer != 0)
		u.SetLayer(layer);

	auto ownedUnit = cast<IOwnedUnit>(u.GetScriptBehavior());
	if (owner.IsValid() && ownedUnit !is null)
	{
		ownedUnit.Initialize(cast<Actor>(owner.GetScriptBehavior()), intensity, false, weaponInfo);
		if (cfgEnemy != 0)
			(Network::Message("SpawnedOwnedUnitEnemy") << prod.GetResourceHash() << u.GetId() << pos << scene << layer << cfgEnemy << owner << intensity << weaponInfo).SendToAll();
		else
			(Network::Message("SpawnedOwnedUnit") << prod.GetResourceHash() << u.GetId() << pos << scene << layer << owner << intensity << weaponInfo).SendToAll();
			
		return u;
	}
	
	if (cfgEnemy != 0)
		(Network::Message("SpawnedUnitEnemy") << prod.GetResourceHash() << u.GetId() << pos << scene << layer << cfgEnemy).SendToAll();
	else if (scene != "" || layer != 0)
		(Network::Message("SpawnedUnit") << prod.GetResourceHash() << u.GetId() << pos << scene << layer).SendToAll();
	else
		(Network::Message("SpawnedUnitSimple") << prod.GetResourceHash() << u.GetId() << pos).SendToAll();
	
	return u;
}

namespace SpawnUnitBaseHandler
{
	int PackEnemyCfg(bool AggroEnemy, bool NoLootEnemy, bool NoExperienceEnemy)
	{
		return (AggroEnemy ? 1 : 0) | (NoLootEnemy ? 2 : 0) | (NoExperienceEnemy ? 4 : 0);
	}

	void ConfigureEnemy(CompositeActorBehavior@ enemy, int cfgEnemy)
	{
		enemy.Configure((cfgEnemy & 1) != 0, (cfgEnemy & 2) != 0, (cfgEnemy & 4) != 0);
	}

	void NetSpawnUnitBaseImpl(uint prodHash, int unitId, vec2 pos, string scene, int layer, int cfgEnemy, UnitPtr owner, float intensity, uint weaponInfo)
	{
		UnitProducer@ UnitType = UnitMap::Replace(prodHash);
		if (UnitType is null)
			return;

		UnitPtr u;
		if (IsNetsyncedExistance(UnitType.GetNetSyncMode()))
			u = g_scene.GetUnit(unitId);
		else
			u = UnitType.Produce(g_scene, xyz(pos));
		
		auto enemyBehavior = cast<CompositeActorBehavior>(u.GetScriptBehavior());
		if (enemyBehavior !is null)
			ConfigureEnemy(enemyBehavior, cfgEnemy);
			
		if (scene != "")
			u.SetUnitScene(scene, true);
		if (layer != 0)
			u.SetLayer(layer);

		auto ownedUnit = cast<IOwnedUnit>(u.GetScriptBehavior());
		if (owner.IsValid() && ownedUnit !is null)
			ownedUnit.Initialize(cast<Actor>(owner.GetScriptBehavior()), intensity, true, weaponInfo);
	}
	
	void DoSpawnUnitBase(int delay, uint prodHash, vec2 pos, string scene, int layer, int cfgEnemy, int ownerId, float intensity, int weaponInfo)
	{
		UnitProducer@ prod = UnitMap::Replace(prodHash);
		if (prod is null)
			return;
		
		if (delay > 0)
			QueuedTasks::Queue(delay, SpawnUnitBaseTask(prod, pos, scene, layer, cfgEnemy, g_scene.GetUnit(ownerId), intensity, weaponInfo));
		else
			SpawnUnitBaseImpl(prod, pos, scene, layer, cfgEnemy, g_scene.GetUnit(ownerId), intensity, weaponInfo);
	}

	void SpawnedOwnedUnitEnemy(uint prodHash, int unitId, vec2 pos, string scene, int layer, int cfgEnemy, UnitPtr owner, float intensity, int weaponInfo)
	{
		NetSpawnUnitBaseImpl(prodHash, unitId, pos, scene, layer, cfgEnemy, owner, intensity, weaponInfo);
	}
	
	void SpawnedOwnedUnit(uint prodHash, int unitId, vec2 pos, string scene, int layer, UnitPtr owner, float intensity, int weaponInfo)
	{
		NetSpawnUnitBaseImpl(prodHash, unitId, pos, scene, layer, 0, owner, intensity, weaponInfo);
	}
	
	void SpawnedUnitEnemy(uint prodHash, int unitId, vec2 pos, string scene, int layer, int cfgEnemy)
	{
		NetSpawnUnitBaseImpl(prodHash, unitId, pos, scene, layer, cfgEnemy, UnitPtr(), 1.0f, 0);
	}
	
	void SpawnedUnit(uint prodHash, int unitId, vec2 pos, string scene, int layer)
	{
		NetSpawnUnitBaseImpl(prodHash, unitId, pos, scene, layer, 0, UnitPtr(), 1.0f, 0);
	}
	
	void SpawnedUnitSimple(uint prodHash, int unitId, vec2 pos)
	{
		NetSpawnUnitBaseImpl(prodHash, unitId, pos, "", 0, 0, UnitPtr(), 1.0f, 0);
	}
}

class SpawnUnitBaseTask : QueuedTasks::QueuedTask
{
	SpawnUnitBaseTask(UnitProducer@ UnitType, vec2 pos, string scene, int layer, int cfgEnemy, UnitPtr owner, float intensity, uint weaponInfo)
	{
		@m_UnitType = UnitType;
		m_pos = pos;
		m_scene = scene;
		m_layer = layer;
		m_cfgEnemy = cfgEnemy;
		m_owner = owner;
		m_intensity = intensity;
		m_weaponInfo = weaponInfo;
	}

	void Execute() override
	{
		SpawnUnitBaseImpl(m_UnitType, m_pos, m_scene, m_layer, m_cfgEnemy, m_owner, m_intensity, m_weaponInfo);
	}
	
	UnitProducer@ m_UnitType;
	vec2 m_pos;
	string m_scene;
	int m_layer;
	int m_cfgEnemy;
	UnitPtr m_owner;
	float m_intensity;
	uint m_weaponInfo;
}