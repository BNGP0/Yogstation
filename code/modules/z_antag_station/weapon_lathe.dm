/obj/machinery/modular_fabricator/autolathe/weapon
	name = "weaopn lathe"
	desc = "It manufactures weapons from iron, copper, and glass."
	icon_state = "autolathe"
	circuit = /obj/item/circuitboard/machine/autolathe

	//Security modes
	security_interface_locked = FALSE

	categories = list(
		"Tools",
		"Weapons",
		"Construction",
		"Non-Lethal",
		"Imported"
		)

	accepts_disks = TRUE

	stored_research_type = /datum/techweb/specialized/autounlocking/autolathe




///obj/machinery/modular_fabricator/autolathe/AfterMaterialInsert(type_inserted, id_inserted, amount_inserted)
//	. = ..()
//	switch(id_inserted)
//		if (/datum/material/iron)
//			flick("autolathe_o",src)//plays metal insertion animation
//		if(/datum/material/copper)
//			flick("autolathe_c",src)//plays metal insertion animation
//		else
//			flick("autolathe_r",src)//plays glass insertion animation by default otherwise

///obj/machinery/modular_fabricator/autolathe/set_default_sprite()
//	icon_state = "autolathe"

///obj/machinery/modular_fabricator/autolathe/set_working_sprite()
//	icon_state = "autolathe_n"

/datum/techweb/specialized/autounlocking/weaponlathe
	design_autounlock_buildtypes = WEAPONLATHE
	allowed_buildtypes = WEAPONLATHE

/datum/design/stechkin
	name = "Stechkin Pistol"
	id = "stechkin"
	build_type = WEAPONLATHE
	materials = list(/datum/material/iron = 30000, /datum/material/glass = 100)
	build_path = /obj/item/gun/ballistic/automatic/pistol
	category = list("Weapons")

/datum/design/stechkin
	name = "pistol magazine (10mm)"
	id = "pistolmag10mm"
	build_type = WEAPONLATHE
	materials = list(/datum/material/iron = 10000)
	build_path = /obj/item/ammo_box/magazine/m10mm
	category = list("Weapons")

/datum/design/c10mm/wl
	build_type = WEAPONLATHE
	id = "c10mm_wl"

/datum/design/c10mm/wl/ap
	name = "Ammo Box (10mm armor-piercing)"
	id = "c10mm_ap"
	build_path = /obj/item/ammo_box/c10mm/ap

/datum/design/c10mm/wl/hp
	name = "Ammo Box (10mm hollow-point)"
	id = "c10mm_hp"
	build_path = /obj/item/ammo_box/c10mm/hp
