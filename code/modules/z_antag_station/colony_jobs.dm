
/datum/job/assistant/citizen
	title = "Colony Citizen"
	total_positions = 800 // i hope at least this doesn't run out from dying and respawning

//spawn landmark
/*
/obj/effect/landmark/start/citizen
	name = "Citizen"
	icon_state = "Assistant"
*/ //i still did not find what part of the code connect these with their respective jobs at the moment

/datum/job/assistant/citizen/shadow
	title = "Shadow"

/datum/job/assistant/citizen/shadow/after_spawn(mob/living/H, mob/M)
	. = ..()
	H.mind.add_antag_datum(/datum/antagonist/nightmare)

/datum/job/assistant/citizen/nightmare
	title = "Nightmare"

/datum/job/assistant/citizen/nightmare/after_spawn(mob/living/H, mob/M)
	. = ..()
	H.set_species(/datum/species/shadow/nightmare)
	H.mind.add_antag_datum(/datum/antagonist/nightmare)


/datum/job/assistant/citizen/heretic
	title = "Heretic"

/datum/job/assistant/citizen/heretic/after_spawn(mob/living/H, mob/M)
	. = ..()
	H.mind.add_antag_datum(/datum/antagonist/heretic)


/datum/job/assistant/citizen/bloodcult
	title = "Blood cultist"

/datum/job/assistant/citizen/bloodcult/after_spawn(mob/living/H, mob/M)
	. = ..()
	H.mind.add_antag_datum(/datum/antagonist/cult)

/datum/job/assistant/citizen/clockcult
	title = "Clock cultist"

/datum/job/assistant/citizen/clockcult/after_spawn(mob/living/H, mob/M)
	. = ..()
	H.mind.add_antag_datum(/datum/antagonist/clockcult)


GLOBAL_LIST_INIT(original_occult_union_positions, list(
	"Shadow",
	"Nightmare",
	"Heretic",
	"Blood cultist",
	"Clock cultist"))

GLOBAL_LIST_INIT(occult_union_positions, original_occult_union_positions | original_occult_union_positions)
