class DecalSet
{
	float dmgLimit;
	array<Decal@> decals;
	int totDecalChance;
	
	DecalSet(float dmgLimit)
	{
		this.dmgLimit = dmgLimit;
	}
	
	void Finalize()
	{
		totDecalChance = 0;
		for (uint i = 0; i < decals.length(); i++)
			totDecalChance += decals[i].chance;
	}
	
	int opCmp(const DecalSet &in decalSet) const
	{
		if(dmgLimit < decalSet.dmgLimit) 
			return -1;
		else if(dmgLimit > decalSet.dmgLimit) 
			return 1;
		return 0;
	}
}

class Decal
{
	int chance;
	uint8 importance;
	UnitProducer@ unit;
	AnimString@ anim;
	
	Decal(int chance)
	{
		this.chance = chance;
	}
	
	int opCmp(const Decal &in decal) const
	{
		if(chance < decal.chance) 
			return -1;
		else if(chance > decal.chance) 
			return 1;
		return 0;
	}
}

class EffectSet
{
	float dmgLimit;
	array<Effect@> effects;
	int totEffectChance;
	
	EffectSet(float dmgLimit)
	{
		this.dmgLimit = dmgLimit;
	}
	
	void Finalize()
	{
		totEffectChance = 0;
		for (uint i = 0; i < effects.length(); i++)
			totEffectChance += effects[i].chance;
	}
	
	int opCmp(const EffectSet &in effectSet) const
	{
		if(dmgLimit < effectSet.dmgLimit) 
			return -1;
		else if(dmgLimit > effectSet.dmgLimit) 
			return 1;
		return 0;
	}
}

class Effect
{
	int chance;
	UnitScene@ effect;
	
	Effect(int chance)
	{
		this.chance = chance;
	}
	
	int opCmp(const Effect &in effect) const
	{
		if(chance < effect.chance) 
			return -1;
		else if(chance > effect.chance) 
			return 1;
		return 0;
	}
}




class GibSet
{
	float dmgLimit;
	array<GibDef@> gibDefs;
	
	GibSet(float dmgLimit)
	{
		this.dmgLimit = dmgLimit;
	}
	
	int opCmp(const GibSet &in gibSet) const
	{
		if(dmgLimit < gibSet.dmgLimit) 
			return -1;
		else if(dmgLimit > gibSet.dmgLimit) 
			return 1;
		return 0;
	}
}

class GibDef
{
	int min;
	int max;
	float force;
	float restitution;
	UnitProducer@ unit;
	AnimString@ anim;
	DecalSet@ decal;
	uint8 importance;
}

class Gib
{
	UnitPtr unit;
	vec3 dir;
	DecalSet@ decal;
	float restitution;
	uint8 importance;
	bool checkTilesets;
	
	Gib()
	{
		checkTilesets = true;
	}
	
	
	bool Update(int ms)
	{
		vec3 pos = unit.GetPosition();
		vec3 d = dir;

		pos += d * ms * 0.2;
		d.z -= ms * 0.0015;
		if (pos.z <= 0)
		{
			d *= restitution;
			d.z *= -1;
			pos.z = 0;
			
			if (checkTilesets)
			{
				array<Tileset@>@ tilesets = g_scene.FetchTilesets(xy(pos));
				for (int i = tilesets.length() - 1; i >= 0; i--)
				{
					SValue@ tsd = tilesets[i].GetData();
					if (tsd is null)
						continue;

					SValue@ svGibsDisappear = tsd.GetDictionaryEntry("gibs-disappear");
					if (svGibsDisappear is null or svGibsDisappear.GetType() != SValueType::Boolean)
						continue;

					if (svGibsDisappear.GetBoolean())
					{
						unit.Destroy();
						unit.SetUnitTimeScale(0);
						return true;
					}
					else
						break;
				}
				
				if ((d.x * d.x + d.y * d.y) < 0.0005)
					checkTilesets = false;
			}

			if (d.z < ms * 0.0015)
			{
				d.z = 0;
				//if (lengthsq(d) < 0.025)
				{
					if (importance > 0)
					{					
						unit.SetUnitTimeScale(0);
						unit.TagAsDebris(importance);
					}
					else
						unit.Destroy();
					
					return true;
				}
			}
			
			if (decal !is null)
			{
				int r = randi(decal.totDecalChance);
				array<Decal@>@ ds = decal.decals;
				for (uint j = 0; j < ds.length(); j++)
				{
					r -= ds[j].chance;
					if (r < 0)
					{
						if (ds[j].unit is null)
							break;
							
						pos.y += randf() - 0.5f;
						
						UnitPtr u = ds[j].unit.Produce(g_scene, pos);
						u.SetUnitScene(ds[j].anim.GetSceneName(atan(d.y, d.x)), false);
						u.TagAsDebris(ds[j].importance);
						break;
					}
				}
			}
		}
		
		dir = d;
		unit.SetPosition(pos);
		return false;
	}
}


class GoreSpawner
{
	string m_path;

	vec3 m_offset;
	vec3 m_spread;
	
	array<DecalSet@>@ m_hitDecals;
	array<DecalSet@>@ m_deathDecals;

	array<EffectSet@>@ m_hitEffects;
	array<EffectSet@>@ m_deathEffects;
	
	array<GibSet@>@ m_hitGibs;
	array<GibSet@>@ m_deathGibs;

	float m_forceMulXY = 1.0;
	float m_forceMulZ = 1.0;
	bool m_isGore;
	
	GoreSpawner(string path, SValue& params)
	{
		m_path = path;
		
		
		m_offset = GetParamVec3(UnitPtr(), params, "offset", false);
		m_spread = GetParamVec3(UnitPtr(), params, "spread", false);
		m_isGore = GetParamBool(UnitPtr(), params, "gore", false, false);
	
		@m_hitDecals = LoadDecalSets(GetParamArray(UnitPtr(), params, "hit-decal", false), 150);
		@m_deathDecals = LoadDecalSets(GetParamArray(UnitPtr(), params, "death-decal", false), 200);
		
		@m_hitEffects = LoadEffectSets(GetParamArray(UnitPtr(), params, "hit-effect", false));
		@m_deathEffects = LoadEffectSets(GetParamArray(UnitPtr(), params, "death-effect", false));
		
		@m_hitGibs = LoadGibSets(params, GetParamArray(UnitPtr(), params, "hit-gib", false), 50);
		@m_deathGibs = LoadGibSets(params, GetParamArray(UnitPtr(), params, "death-gib", false), 100);
	}
	
	int AdjustGibAmount(int num)
	{
%if GFX_VFX_MEDIUM
		if (num > 1) num = max(1, int(num * 0.66));
%elif GFX_VFX_LOW
		if (num > 1) num = max(1, int(num * 0.33));
%endif
		return num;
	}
	
	array<GibSet@>@ LoadGibSets(SValue& params, array<SValue@>@ param, uint8 defImportance)
	{
		if (param is null)
			return null;
		
		if (param.length() <= 0)
			return null;
			
		array<GibSet@>@ sets = array<GibSet@>();
		GibSet@ currSet;
			
		for (uint i = 0; i < param.length(); i++)
		{
			if (param[i].GetType() == SValueType::Float)
			{
				if (currSet !is null)
					sets.insertLast(currSet);
			
				@currSet = GibSet(param[i].GetFloat());
			}
			else if (param[i].GetType() == SValueType::Dictionary && currSet !is null)
			{
				GibDef@ gib = GibDef();
				
				gib.min = AdjustGibAmount(GetParamInt(UnitPtr(), param[i], "min", false, 1));
				gib.max = AdjustGibAmount(GetParamInt(UnitPtr(), param[i], "max", false, 1));
				gib.force = GetParamFloat(UnitPtr(), param[i], "force", false, 1);
				gib.restitution = GetParamFloat(UnitPtr(), param[i], "restitution", false, 0.33);
				@gib.unit = Resources::GetUnitProducer(GetParamString(UnitPtr(), param[i], "unit"));
				@gib.anim = AnimString(GetParamString(UnitPtr(), param[i], "anim"));
				
				if (GetParamBool(UnitPtr(), param[i], "stay", false, true))
					gib.importance = GetParamInt(UnitPtr(), param[i], "importance", false, defImportance);
				else
					gib.importance = 0;
				
				string decalName = GetParamString(UnitPtr(), param[i], "decal", false);
				if (decalName != "")
				{
					array<SValue@>@ decalParam = GetParamArray(UnitPtr(), params, decalName);
					DecalSet@ dSet = DecalSet(0);
				
					for (uint j = 0; j < decalParam.length(); j++)
						dSet.decals.insertLast(LoadDecal(decalParam[j], defImportance + 100));
					
					dSet.Finalize();
					@gib.decal = dSet;
				}
				else
					@gib.decal = null;
				
				currSet.gibDefs.insertLast(gib);
			}
		}
		
		if (currSet !is null)
			sets.insertLast(currSet);
		
		sets.sortDesc();
		return sets;
	}
	
	Decal@ LoadDecal(SValue@ param, uint8 defImportance)
	{
		Decal@ decal = Decal(GetParamInt(UnitPtr(), param, "chance", false, 1));
		decal.importance = GetParamInt(UnitPtr(), param, "importance", false, defImportance);
	
		@decal.unit = Resources::GetUnitProducer(GetParamString(UnitPtr(), param, "unit", false));
		if (decal.unit !is null)
			@decal.anim = AnimString(GetParamString(UnitPtr(), param, "anim"));
			
		return decal;
	}
	
	array<DecalSet@>@ LoadDecalSets(array<SValue@>@ param, uint8 defImportance)
	{
		if (param is null)
			return null;
		
		if (param.length() <= 0)
			return null;
			
		array<DecalSet@>@ sets = array<DecalSet@>();
		DecalSet@ currSet;
			
		for (uint i = 0; i < param.length(); i++)
		{
			if (param[i].GetType() == SValueType::Float)
			{
				if (currSet !is null)
				{
					currSet.Finalize();
					sets.insertLast(currSet);
				}
			
				@currSet = DecalSet(param[i].GetFloat());
			}
			else if (param[i].GetType() == SValueType::Dictionary && currSet !is null)
				currSet.decals.insertLast(LoadDecal(param[i], defImportance));
		}
		
		if (currSet !is null)
		{
			currSet.Finalize();
			sets.insertLast(currSet);
		}
		
		sets.sortDesc();
		return sets;
	}
	
	array<EffectSet@>@ LoadEffectSets(array<SValue@>@ param)
	{
		if (param is null)
			return null;
		
		if (param.length() <= 0)
			return null;
			
		array<EffectSet@>@ sets = array<EffectSet@>();
		EffectSet@ currSet;
			
		for (uint i = 0; i < param.length(); i++)
		{
			if (param[i].GetType() == SValueType::Float)
			{
				if (currSet !is null)
				{
					currSet.Finalize();
					sets.insertLast(currSet);
				}
			
				@currSet = EffectSet(param[i].GetFloat());
			}
			else if (param[i].GetType() == SValueType::Dictionary && currSet !is null)
			{
				Effect@ effect = Effect(GetParamInt(UnitPtr(), param[i], "chance", false, 1));
				@effect.effect = Resources::GetEffect(GetParamString(UnitPtr(), param[i], "effect", false));
				currSet.effects.insertLast(effect);
			}
		}
		
		if (currSet !is null)
		{
			currSet.Finalize();
			sets.insertLast(currSet);
		}
		
		sets.sortDesc();
		return sets;
	}
	
	void ResolveDecal(array<DecalSet@>@ decals, float dmg, vec2 pos, float dir)
	{
		if (decals is null)
			return;
		
		pos.x += m_offset.x;
		pos.y += m_offset.y;

		for (uint i = 0; i < decals.length(); i++)
		{
			if (decals[i].dmgLimit <= dmg)
			{
				int r = randi(decals[i].totDecalChance);
				array<Decal@>@ ds = decals[i].decals;
				for (uint j = 0; j < ds.length(); j++)
				{
					r -= ds[j].chance;
					if (r < 0)
					{
						if (ds[j].unit is null)
							return;
							
						vec2 p = pos + randf() - 0.5f;
						vec3 s = MakeSpread();
						p.x += s.x;
						p.y += s.y;
						
						UnitPtr u = ds[j].unit.Produce(g_scene, xyz(p));
						u.SetUnitScene(ds[j].anim.GetSceneName(dir), false);
						u.TagAsDebris(ds[j].importance);
						return;
					}
				}
			
				return;
			}
		}
	}
	
	void ResolveEffect(array<EffectSet@>@ effects, float dmg, vec2 pos)
	{
		if (effects is null)
			return;
			
		/*
		pos.x += m_offset.x;
		pos.y += m_offset.y - m_offset.z;
		*/
		for (uint i = 0; i < effects.length(); i++)
		{
			if (effects[i].dmgLimit <= dmg)
			{
				int r = randi(effects[i].totEffectChance);
				array<Effect@>@ es = effects[i].effects;
				for (uint j = 0; j < es.length(); j++)
				{
					r -= es[j].chance;
					if (r < 0)
					{
						if (es[j].effect is null)
							return;
						
						/*
						vec2 p = pos;
						vec3 s = MakeSpread();
						p.x += s.x;
						p.y += s.y - s.z;
						*/
						
						PlayEffect(es[j].effect, pos);
						return;
					}
				}
			
				return;
			}
		}
	}
	
	void ResolveGibs(array<GibSet@>@ gibs, float dmg, vec2 pos, vec2 dir)
	{
		if (gibs is null)
			return;
		
%if GFX_VFX_LOW
		bool cullGibs = true;
%elif GFX_VFX_MEDIUM
		bool cullGibs = (m_gibsSpawned > 50) || m_gibs.length() > 150;
%else
		bool cullGibs = (m_gibsSpawned > 80) || m_gibs.length() > 300;
%endif
		
		if (!cullGibs)
		{
			BaseGameMode@ gm = cast<BaseGameMode>(g_gameMode);
			if (gm !is null)
				cullGibs = dist(pos, gm.m_camPos) > 600;
		}
			
		for (uint i = 0; i < gibs.length(); i++)
		{
			if (gibs[i].dmgLimit <= dmg)
			{
				array<GibDef@>@ gd = gibs[i].gibDefs;
				for (uint j = 0; j < gd.length(); j++)
				{
					if (cullGibs && gd[j].decal is null && gd[j].importance == 0)
						continue;
				
					int num = gd[j].min;
					num += randi(gd[j].max - num + 1);
				
					for (int k = 0; k < num; k++)
					{
						float force = gd[j].force;
						
						vec2 d = (randdir() + dir) / 2;
						d *= (force * m_forceMulXY) * (15 + randi(15)) / 100;

						Gib gib;
						gib.dir = vec3(d.x, d.y, 0.175 + randf() * force * m_forceMulZ);
						@gib.decal = gd[j].decal;
						gib.unit = gd[j].unit.Produce(g_scene, xyz(pos) + m_offset + MakeSpread());
						gib.unit.SetUnitScene(gd[j].anim.GetSceneName(atan(d.y, d.x)), true);
						gib.importance = gd[j].importance;
						gib.restitution = gd[j].restitution;
						
						AddGib(gib);
					}
				}
				
				return;
			}
		}
	}
	
	vec3 MakeSpread()
	{
		return vec3((randf() * 2 - 1) * m_spread.x,
					(randf() * 2 - 1) * m_spread.y,
					(randf() * 2 - 1) * m_spread.z);
	}
	
	void OnDeath(float dmg, vec2 pos, float ang = 0x7fc00000)
	{
		if (m_isGore && !GetVarBool("g_gore"))
		{
			if (m_safeGore !is null)
				m_safeGore.OnDeath(dmg, pos, ang);
			
			return;
		}
	
		vec2 dir;
		if (ang == 0x7fc00000)
		{
			ang = 0;
			dir = vec2(0, 0);
		}
		else
			dir = vec2(cos(ang), sin(ang));
	
		ResolveDecal(m_deathDecals, dmg, pos, ang);
		ResolveEffect(m_deathEffects, dmg, pos);
		ResolveGibs(m_deathGibs, dmg, pos, dir);
	}
	
	void OnHit(float dmg, vec2 pos, float ang = 0x7fc00000)
	{
		if (m_isGore && !GetVarBool("g_gore"))
		{
			if (m_safeGore !is null)
				m_safeGore.OnHit(dmg, pos, ang);
			
			return;
		}
	
		vec2 dir;
		if (ang == 0x7fc00000)
		{
			ang = 0;
			dir = vec2(0, 0);
		}
		else
			dir = vec2(cos(ang), sin(ang));
	
		ResolveDecal(m_hitDecals, dmg, pos, ang);
		ResolveEffect(m_hitEffects, dmg, pos);
		ResolveGibs(m_hitGibs, dmg, pos, dir);
	}
}