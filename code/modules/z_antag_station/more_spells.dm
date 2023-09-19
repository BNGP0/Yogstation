/obj/effect/proc_holder/spell/wakeup
	name = "Wake up"
	desc = "Allows you to interact with items and surrounding even if you are incapacitated. Or, if you cast it while dead, allows you to do the same, while, well, dead"
	range = -1
	clothes_req = FALSE

/obj/effect/proc_holder/spell/wakeup/cast(list/targets, mob/living/carbon/human/user)
	REMOVE_TRAIT(user,TRAIT_INCAPACITATED,null)
	REMOVE_TRAIT(user,TRAIT_IMMOBILIZED,null)
	REMOVE_TRAIT(user,TRAIT_KNOCKEDOUT,null)
	REMOVE_TRAIT(user,TRAIT_HANDS_BLOCKED,null)
	REMOVE_TRAIT(user,TRAIT_UI_BLOCKED,null)
	REMOVE_TRAIT(user,TRAIT_PULL_BLOCKED,null)
	if (user.stat == 4)
		ADD_TRAIT(user, TRAIT_HUSK, "Necromancy")
		ADD_TRAIT(user, TRAIT_DISFIGURED, "Necromancy")
