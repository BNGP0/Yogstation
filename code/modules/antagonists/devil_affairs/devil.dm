///How much a Devil will slowly heal themselves when they die.
#define DEVIL_LIFE_HEALING_AMOUNT 0.5
///How much damage+burn you need at most to be able to revive
#define DEVIL_REVIVE_AMOUNT_REQUIRED 180

/datum/antagonist/devil
	name = "Devil"
	roundend_category = "infernal affairs agents"
	antagpanel_category = "Devil Affairs"
	job_rank = ROLE_INFERNAL_AFFAIRS_DEVIL
	greentext_achieve = /datum/achievement/greentext/devil

	///The amount of souls the devil has so far.
	var/souls = 0
	///List of Powers we currently have unlocked.
	var/list/datum/action/devil_powers = list()

/datum/antagonist/devil/on_gain()
	. = ..()
	SSinfernal_affairs.devils += src
	obtain_power(/datum/action/cooldown/spell/conjure_item/summon_contract)
	obtain_power(/datum/action/cooldown/spell/pointed/collect_soul)

/datum/antagonist/devil/on_removal()
	clear_power(/datum/action/cooldown/spell/conjure_item/summon_contract)
	clear_power(/datum/action/cooldown/spell/pointed/collect_soul)
	if(src in SSinfernal_affairs.devils)
		SSinfernal_affairs.devils -= src
	return ..()

/datum/antagonist/devil/apply_innate_effects(mob/living/mob_override)
	. = ..()
	RegisterSignal(mob_override, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(mob_override, COMSIG_LIVING_REVIVE, PROC_REF(on_revival))
	RegisterSignal(mob_override, COMSIG_LIVING_GIBBED, PROC_REF(on_gibbed))
	
/datum/antagonist/devil/remove_innate_effects(mob/living/mob_override)
	UnregisterSignal(mob_override, list(COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_LIVING_GIBBED))
	return ..()

///Ensure their healing will follow through to their new body.
/datum/antagonist/devil/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	if(old_body.stat == DEAD)
		UnregisterSignal(old_body, COMSIG_LIVING_LIFE)
	if(new_body.stat == DEAD)
		RegisterSignal(new_body, COMSIG_LIVING_LIFE)

///Begins your healing process when you die.
/datum/antagonist/devil/proc/on_death(atom/source, gibbed)
	SIGNAL_HANDLER
	RegisterSignal(source, COMSIG_LIVING_LIFE, PROC_REF(on_dead_life))

///Ends your healing process when you are revived
/datum/antagonist/devil/proc/on_revival(atom/source, full_heal, admin_revive)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_LIVING_LIFE)

///Removes you from the list of devils and makes you unrevivable if you are gibbed.
///You are completely killed and the round will continue without you.
/datum/antagonist/devil/proc/on_gibbed(atom/source, no_brain, no_organs, no_bodyparts)
	SIGNAL_HANDLER
	playsound(source, 'sound/effects/tendril_destroyed.ogg', 40, TRUE)
	ADD_TRAIT(owner, TRAIT_HELLBOUND, DEVIL_TRAIT)
	SSinfernal_affairs.devils -= src

///Called on Life, but only while you are dead. Handles slowly healing and coming back to life when eligible.
/datum/antagonist/devil/proc/on_dead_life(atom/source, delta_time, times_fired)
	SIGNAL_HANDLER
	owner.current.heal_overall_damage(DEVIL_LIFE_HEALING_AMOUNT, DEVIL_LIFE_HEALING_AMOUNT)
	if(owner.current.blood_volume < BLOOD_VOLUME_NORMAL(owner.current))
		owner.current.blood_volume += (DEVIL_LIFE_HEALING_AMOUNT * 2)

	if((owner.current.getBruteLoss() + owner.current.getFireLoss()) > DEVIL_REVIVE_AMOUNT_REQUIRED)
		return
	owner.current.revive(FALSE, FALSE)
	owner.current.grab_ghost()

/**
 * ##update_souls_owned
 * 
 * Used to edit the amount of souls a Devil has. This can be a negative number to take away.
 * Will give Powers when getting to the proper level, or attempts to take them away if they go under
 * That way this works for both adding and removing.
 */
/datum/antagonist/devil/proc/update_souls_owned(souls_adding)
	souls += souls_adding

	switch(souls)
		if(1)
			clear_power(/datum/action/cooldown/spell/conjure_item/violin)
		if(2)
			obtain_power(/datum/action/cooldown/spell/conjure_item/violin)
			clear_power(/datum/action/cooldown/spell/conjure_item/summon_pitchfork)
		if(3)
			obtain_power(/datum/action/cooldown/spell/conjure_item/summon_pitchfork)
			clear_power(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/infernal_jaunt)
		if(4)
			obtain_power(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/infernal_jaunt)
		if(7)
			clear_power(/datum/action/cooldown/spell/summon_dancefloor)
			clear_power(/datum/action/cooldown/spell/pointed/projectile/fireball/hellish)
			clear_power(/datum/action/cooldown/spell/shapeshift/devil)
		if(8)
			obtain_power(/datum/action/cooldown/spell/summon_dancefloor)
			obtain_power(/datum/action/cooldown/spell/pointed/projectile/fireball/hellish)
			obtain_power(/datum/action/cooldown/spell/shapeshift/devil)

/datum/antagonist/devil/proc/obtain_power(datum/action/new_power)
	new_power = new new_power
	devil_powers[new_power.type] = new_power
	new_power.Grant(owner.current)
	return TRUE

///Called when a Bloodsucker loses a power: (power)
/datum/antagonist/devil/proc/clear_power(datum/action/removed_power)
	if(devil_powers[removed_power])
		QDEL_NULL(devil_powers[removed_power])

#undef DEVIL_LIFE_HEALING_AMOUNT
#undef DEVIL_REVIVE_AMOUNT_REQUIRED
