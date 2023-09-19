/datum/action/cooldown/spell
	var/list/enchants = list()

/*
/datum/action/cooldown/spell/on_gain(mob/living/user)
	. = ..()
	if (enchants.len != 0)
		to_chat(user, "<span class='warning'>Enchantments detected while gaining the spell</span>")
		clothes_req = FALSE
		cult_req = FALSE
		to_chat(user, "<span class='warning'>Extra spell requirements removed</span>")
		for (var/datum/spell_enchant/E in enchants)
			to_chat(user, "<span class='warning'>Preparing to activate enchantment gain</span>")
			E.ongain(src)
			to_chat(user, "<span class='warning'>Activated enchantment gain</span>")
*/

// moved to spell.dm in spells module,line 348 // moved back here
/*
/datum/action/cooldown/spell/perform()//(mob/user = usr)
	. = ..()
	if (enchants.len != 0)
		to_chat(usr, "<span class='warning'>Enchantments detected while casting the spell</span>")
		for (var/datum/spell_enchant/E in enchants)
			to_chat(usr, "<span class='warning'>Preparing to activate enchantment cast</span>")
			E.on_cast(usr)
			to_chat(usr, "<span class='warning'>Activated enchantment cast</span>")
*/

/*
for context if you decide to port this onto a server
that has any rules regarding code to prevent it from turning into spaghetti,
i still barely understand what a datum is at the moment of coding this
*/

//=======enchants
/datum/spell_enchant
	var/name = "Enchant"
	var/desc = "Enchant Description"

/datum/spell_enchant/proc/on_cast(var/mob/user)
	return
// ongain procs are called only if you learn the spell from a book, don't forger about it in case of adding new ways of learning spells with enchants
/datum/spell_enchant/proc/ongain(var/datum/action/cooldown/spell/spell)
	return

/datum/spell_enchant/selfharm
	name = "SelfHarm"
	desc = "Damages the user each time it is cast."

datum/spell_enchant/selfharm/on_cast(mob/user = usr)
	if (user == /mob/living/carbon/human)
		var/mob/living/carbon/human/h = user
		h.adjustBruteLoss(10)
	else if (user == /mob/living/simple_animal)
		var/mob/living/simple_animal/s = user
		s.adjustHealth(10)

/datum/spell_enchant/extra_cd
	name = "Extra cooldown"
	desc = "Gives additional 5 seconds of cooldown to a spell."

/datum/spell_enchant/extra_cd/ongain(datum/action/cooldown/spell/spell)
	if (spell != null)
		spell.cooldown_time += 5 SECONDS


// the first pperfectly balanced enchantment with no exploits
/datum/spell_enchant/deadcast
	name = "Dead Cast"
	desc = "Allows the spell to be cast by a corpse.Doesn't work properly with some spells."

/datum/spell_enchant/deadcast/ongain(datum/action/cooldown/spell/spell)
	if (spell != null)
		spell.dead_cast = TRUE
		spell.spell_requirements += SPELL_CASTABLE_AS_BRAIN
		datum_flags -= AB_CHECK_CONSCIOUS

/datum/spell_enchant/nonabstract_req
	name = "Non-Physical Cast"
	desc = "Allows the spell to be cast without a body.Doesn't work properly with some spells."

/datum/spell_enchant/nonabstract_req/ongain(datum/action/cooldown/spell/spell)
	if (spell != null)
		spell.spell_requirements += SPELL_CASTABLE_WHILE_PHASED

//Ported more enchants fromm the files i recovered from the old pc
datum/spell_enchant/more_range
	name = "More Range"
	desc = "Increases range of the spells that have it. Lets you apply effects of spells that only affect the user onto people near you, while also letting you use ranged spells on yourself."

/datum/spell_enchant/more_range/ongain(datum/action/cooldown/spell/spell, mob/user)
	if (spell == null)
		return
// seems like after the new tg spell rework they don't have a uniform range var at all. what a fucking idiot was even trusted with this rework?
	if (spell == /datum/action/cooldown/spell/list_target) // added include user to some spells
		var/datum/action/cooldown/spell/list_target/T = spell
		T.target_radius += 1
		T.include_user = TRUE

	if (spell == /datum/action/cooldown/spell/aoe)
		var/datum/action/cooldown/spell/aoe/T = spell
		T.aoe_radius += 1

	if (spell == /datum/action/cooldown/spell/pointed)
		var/datum/action/cooldown/spell/pointed/T = spell
		T.include_user = 1
		T.cast_range += 1

/obj/item/book/enchanter/more_range
	enchant = /datum/spell_enchant/more_range
	cost = 2


// leg disable
/datum/spell_enchant/paraplegic
	name = "Paraplegic"
	desc = "Learning a spell with this enchant will make your legs stop functioning forever.Unfortunately, doesn't give you a free wheelchair."

/datum/spell_enchant/paraplegic/ongain(datum/action/cooldown/spell/spell, mob/user)
	if (user == /mob/living/carbon/human)
		var/datum/brain_trauma/severe/paralysis/paraplegic/T = new()
		var/mob/living/carbon/human/H = user
		to_chat(user, "The enchant paralyzed your legs in exchange for more power.")
		H.gain_trauma(T, TRAUMA_RESILIENCE_ABSOLUTE)
	else
		to_chat(user, "After learning the spell the enchant fails to make you paraplegic. I wonder why.")

/obj/item/book/enchanter/paraplegic
	enchant = /datum/spell_enchant/paraplegic
	cost = -7
	significant = TRUE
	can_stack = FALSE

//=======end of enchants

// book
/obj/item/book/granter/action/spell/modular
//	spellname = "spell"
	icon = 'code/modules/z_antag_station/icons_32x32.dmi'
	icon_state ="bookSpellmaker"
	desc = "This book lets you learn a custom spell. Or maybe it doesn't"
	remarks = list(
		"...",
		"Learning...",
		"Interesting...",
	)
	var/list/book_enchants = list()
	var/e_balance = -3
	var/datum/action/cooldown/spell/spell

/obj/item/book/granter/action/spell/modular/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/book/enchanter))
		var/obj/item/book/enchanter/E = W
		book_enchants.Add(E.enchant)
		e_balance -= E.cost
		balloon_alert(user, "Enchantment added")
		qdel(E)
//		if(!user.transferItemToLoc(W, src))
//			return

/obj/item/book/granter/action/spell/modular/attack_self(mob/user)
	if (e_balance < 0)
		to_chat(user, "<span class='warning'>The enchantments are out of balance, the spell can't be cast!</span>")
		return FALSE
//		..() // didn't work. for some reason
	if(reading)
		to_chat(user, span_warning("You're already reading this!"))
		return FALSE
	if(is_blind(user))
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return FALSE
//	if(!isliving(user) || !user.can_read(src) || !can_learn(user))
//		to_chat(user, span_warning("You are unable to read / learn this!"))
//		return FALSE

	if(uses <= 0)
		recoil(user)
		return FALSE

	on_reading_start(user)
	reading = TRUE
	for(var/i in 1 to pages_to_mastery)
		if(!turn_page(user))
			to_chat(user, span_warning("You stop reading the book"))
			on_reading_stopped()
			reading = FALSE
			return
	if(do_after(user, 5 SECONDS, src))
		uses--
		on_reading_finished(user)
	reading = FALSE
	return TRUE // not sure why calling parrent proc didn't work but whatever



/obj/item/book/granter/action/spell/modular/on_reading_finished(mob/user)
	to_chat(user, "<span class='notice'>You feel like you've experienced enough to cast [spell]!</span>")
	var/datum/action/cooldown/spell/S = new spell
	S.enchants = book_enchants
// ongain procs
	if (S.enchants.len != 0)
		to_chat(user, "<span class='warning'>Enchantments detected while gaining the spell</span>")
		S.spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
		to_chat(user, "<span class='warning'>Extra spell requirements removed</span>")
		for (var/datum/spell_enchant/E in S.enchants)
			to_chat(user, "<span class='warning'>Preparing to activate enchantment gain</span>")
			E.ongain(src)
			to_chat(user, "<span class='warning'>Activated enchantment gain</span>")
// ongain procs end
	to_chat(user, "<span class='warning'>Enchantment gain looop ended</span>")
//	user.mind.AddSpell(S)
	S.Grant(user)
	to_chat(user, "<span class='warning'>Spell added to the mind</span>")
	user.log_message("learned the spell ([S])", LOG_ATTACK, color="orange")
//	onlearned(user)


/obj/item/book/granter/action/spell/modular/examine(mob/living/M)
	. = ..()
	. += "<span class='notice'>It has : [book_enchants.len] enchantments.</span>"
	. += "<span class='notice'>Its enchantment balance is [e_balance].</span>"
	. += "<span class='notice'>The spell of the book is [spell].</span>"


//enchantment scroll
/obj/item/book/enchanter
	name = "Enchantment Scroll"
	desc = "A piece of paper with a part of a spell on it."
	icon = 'code/modules/z_antag_station/icons_32x32.dmi'
	icon_state ="enchant_scroll"
	var/datum/spell_enchant/enchant = /datum/spell_enchant
	var/cost = -1
	var/significant = FALSE
	var/can_stack = TRUE

/obj/item/book/enchanter/examine(mob/living/M)
	. = ..()
	. += "<span class='notice'>The cost of the enchant is: [cost].</span>"
	. += "<span class='notice'>[enchant]</span>"
	. += "<span class='notice'>[enchant.name]</span>"
	. += "<span class='notice'>[enchant.desc]</span>"


/obj/item/book/enchanter/attackby(obj/item/W, mob/user, params)
	return
/obj/item/book/enchanter/attack_self(mob/user)
	return

//enchanters
/obj/item/book/enchanter/selfharm
	enchant = /datum/spell_enchant/selfharm
	cost = -3

/obj/item/book/enchanter/extra_cd
	enchant = /datum/spell_enchant/extra_cd
	cost = -3

/obj/item/book/enchanter/deadcast
	enchant = /datum/spell_enchant/deadcast
	cost = 4

// books
/obj/item/book/granter/action/spell/modular/summonitem
	spell = /datum/action/cooldown/spell/summonitem
	e_balance = -5

/obj/item/book/granter/action/spell/modular/telepathy
	spell = /datum/action/cooldown/spell/list_target/telepathy
	e_balance = -2

/obj/item/book/granter/action/spell/modular/forcewall
	spell = /datum/action/cooldown/spell/forcewall
	e_balance = -4

/obj/item/book/granter/action/spell/modular/shadowwalk
	spell = /datum/action/cooldown/spell/jaunt/shadow_walk
	e_balance = -6

