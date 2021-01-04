namespace WorldScript
{
	[WorldScript color="232 170 238" icon="system/icons.png;256;0;32;32"]
	class RefreshSpawnPickup
	{
		vec3 Position;
	
		[Editable]
		UnitProducer@ UnitType;

		[Editable]
		UnitScene@ SpawnEffect;

		[Editable]
		int SpawnLayer;

		[Editable]
		int EffectLayer;

		[Editable]
		SoundEvent@ SpawnSound;

		
		bool m_needNetSync;
		Pickup@ m_currPickup;


		void Initialize()
		{
			m_needNetSync = !IsNetsyncedExistance(UnitType.GetNetSyncMode());
		}
		
		UnitPtr ProduceUnit(int id)
		{
			UnitPtr u = UnitType.Produce(g_scene, Position, id);
			if (SpawnLayer != 0)
				u.SetLayer(SpawnLayer);
				
			@m_currPickup = cast<Pickup>(u.GetScriptBehavior());
			return u;
		}
		
		void SpawnEffects()
		{
			if (SpawnEffect !is null)
			{
				UnitPtr effectUnit = PlayEffect(SpawnEffect, xy(Position));
				if (effectUnit.IsValid())
				{
					if (EffectLayer != 0)
						effectUnit.SetLayer(EffectLayer);
				}
			}
			if (SpawnSound !is null)
				PlaySound3D(SpawnSound, Position);
		}
		
		bool AlreadyExists()
		{
			if (m_currPickup is null)
				return false;

			if (!m_currPickup.m_visible || m_currPickup.m_unit.IsDestroyed() || m_currPickup.m_unit.IsHidden())
			{
				@m_currPickup = null;
				return false;
			}
				
			return true;
		}

		SValue@ ServerExecute()
		{
			if (AlreadyExists())
				return null;
		
			SValueBuilder sval;
			auto u = ProduceUnit(0);
			sval.PushInteger(u.GetId());
			SpawnEffects();
			return sval.Build();
		}
		
		void ClientExecute(SValue@ val)
		{
			if (m_needNetSync)
			{
				if (AlreadyExists())
					return;
			
				ProduceUnit(0);
				SpawnEffects();
			}
			else
			{
				if (val is null)
					return;

				SpawnEffects();
			}
		}
	}
}
