namespace Modifiers
{
	enum EffectTrigger
	{
		None,
		Hit,
		SpellHit,
		Hurt,
		HurtSelf,
		HurtNonSelf,
		Kill,
		Attack,
		CastSpell,
		DrinkPotion,
		CriticalHit,
		SpellCriticalHit,
		Evade,
		Collide,
		PotionCharge,
		
		Pickup,
		PickupMana,
		PickupHealth,
		PickupOre,
		PickupMoney,
		PickupKey
	}

	enum SyncVerb
	{
		None,
		Item,
		Set,
		Drink,
		Passive,
		Wish,
		Buff,
		Statue,
		Upgrade
	}

	array<Modifier@>@ LoadModifiers(UnitPtr owner, SValue& params, string prefix = "", Modifiers::SyncVerb verb = Modifiers::SyncVerb::None, uint verbId = 0, uint orIndex = 0)
	{
		array<Modifier@> modifiers;
		
		array<SValue@>@ datArr = GetParamArray(owner, params, prefix + "modifiers", false);
		if (datArr !is null)
		{
			for (uint i = 0; i < datArr.length(); i++)
			{
				string c = GetParamString(owner, datArr[i], "class");
				auto mod = cast<Modifier>(InstantiateClass(c, owner, datArr[i]));
				if (mod !is null)
				{
					mod.Initialize(verb, verbId, modifiers.length() | orIndex);
					modifiers.insertLast(mod);
				}
			}
		}
		else
		{
			SValue@ dat = GetParamDictionary(owner, params, prefix + "modifier", false);
			if (dat !is null)
			{
				string c = GetParamString(owner, dat, "class");
				auto mod = cast<Modifier>(InstantiateClass(c, owner, dat));
				if (mod !is null)
				{
					mod.Initialize(verb, verbId, 0 | orIndex);
					modifiers.insertLast(mod);
				}
			}
		}

		if (modifiers.length() > 0xFF)
			PrintError("Loading " + modifiers.length() + " modifiers! If there are any TriggerEffect modifiers, they will fail to netsync.");

		return modifiers;
	}

	ModifierList@ LoadModifiersList(UnitPtr owner, SValue& params, string prefix = "")
	{
		return ModifierList(LoadModifiers(owner, params, prefix));
	}
	
	EffectTrigger ParseEffectTrigger(string trigger)
	{
		if (trigger == "hit")
			return EffectTrigger::Hit;
		else if (trigger == "spellhit")
			return EffectTrigger::SpellHit;
		else if (trigger == "hurt")
			return EffectTrigger::Hurt;
		else if (trigger == "hurt-self")
			return EffectTrigger::HurtSelf;
		else if (trigger == "hurt-non-self")
			return EffectTrigger::HurtNonSelf;
		else if (trigger == "kill")
			return EffectTrigger::Kill;
		else if (trigger == "attack")
			return EffectTrigger::Attack;
		else if (trigger == "castspell")
			return EffectTrigger::CastSpell;
		else if (trigger == "drinkpotion" || trigger == "potion")
			return EffectTrigger::DrinkPotion;
		else if (trigger == "criticalhit" || trigger == "crit")
			return EffectTrigger::CriticalHit;
		else if (trigger == "spellcriticalhit" || trigger == "spellcrit")
			return EffectTrigger::SpellCriticalHit;
		else if (trigger == "evade" || trigger == "dodge")
			return EffectTrigger::Evade;
		else if (trigger == "collide")
			return EffectTrigger::Collide;
		else if (trigger == "potion-charge")
			return EffectTrigger::PotionCharge;
		
		else if (trigger == "pickup")
			return EffectTrigger::Pickup;
		else if (trigger == "pickup-mana")
			return EffectTrigger::PickupMana;
		else if (trigger == "pickup-health")
			return EffectTrigger::PickupHealth;
		else if (trigger == "pickup-ore")
			return EffectTrigger::PickupOre;
		else if (trigger == "pickup-money")
			return EffectTrigger::PickupMoney;
		else if (trigger == "pickup-key")
			return EffectTrigger::PickupKey;
			
		return EffectTrigger::None;
	}
}

//TODO: Is this ok for multiplayer?
Modifiers::ModifierList g_allModifiers;
