interface IPlayerActorDamager
{
	DamageInfo DamageActor(Actor@ actor, DamageInfo di);
	void DamagedActor(Actor@ actor, DamageInfo di);
}
