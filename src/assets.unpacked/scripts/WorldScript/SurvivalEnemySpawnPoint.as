[WorldScript color="0 196 150" icon="system/icons.png;416;128;32;32"]
class SurvivalEnemySpawnPoint
{
	bool Enabled;
	vec3 Position;

	[Editable]
	string Filter;

	[Editable]
	UnitScene@ IntroEffect;

	[Editable]
	UnitScene@ SpawnEffect;

	[Editable]
	SoundEvent@ SpawnSound;

	[Editable]
	int Delay;

	[Editable default=true]
	bool AggroEnemy;
	[Editable default=false]
	bool NoLootEnemy;
	[Editable default=false]
	bool NoExperienceEnemy;

	void Initialize()
	{
		auto survivalMode = cast<Survival>(g_gameMode);
		if (survivalMode !is null)
			survivalMode.m_enemySpawns.insertLast(this);
	}

	void SpawnEffects()
	{
		if (SpawnEffect !is null)
			PlayEffect(SpawnEffect, xy(Position));
		if (SpawnSound !is null)
			PlaySound3D(SpawnSound, Position);
	}
}
