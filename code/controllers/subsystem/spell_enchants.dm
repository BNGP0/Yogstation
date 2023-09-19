/*! How enchant datums work
I have no idea, let's hope they do

based on materials subsystem
*/

SUBSYSTEM_DEF(spell_enchants)
	name = "Spell enchants"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DEFAULT
	///Dictionary of material.type || material ref
	var/list/enchants = list()
	///Dictionary of category || list of material refs
//	var/list/enchants_by_category = list()

/datum/controller/subsystem/spell_enchants/Initialize(timeofday)
	InitializeEnchants()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/spell_enchants/proc/InitializeEnchants(timeofday)
	for(var/type in subtypesof(/datum/spell_enchant))
		var/datum/spell_enchant/ref = new type
		enchants[type] = ref
//		for(var/c in ref.categories)
//			enchants_by_category[c] += list(ref)
