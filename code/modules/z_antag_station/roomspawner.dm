//house spawner, works like room spawner but is connected to the

/obj/effect/spawner/house
	name = "random room spawner"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/room_width = 0
	var/room_height = 0

/obj/effect/spawner/house/New(loc, ...)
	. = ..()
	if(!isnull(SSmapping.random_room_spawners))
		SSmapping.random_room_spawners += src

/obj/effect/spawner/house/Initialize(mapload)
	..()
	if(!length(SSmapping.random_room_templates))
		message_admins("House room spawner created with no templates available. This shouldn't happen.")
		return INITIALIZE_HINT_QDEL
	var/list/possibletemplates = list()
	var/datum/map_template/random_room/candidate
	shuffle_inplace(SSmapping.random_room_templates)
	for(var/ID in SSmapping.random_room_templates)
		candidate = SSmapping.random_room_templates[ID]
		if(candidate.spawned || room_height != candidate.template_height || room_width != candidate.template_width)
			candidate = null
			continue
		possibletemplates[candidate] = candidate.weight
	if(possibletemplates.len)
		var/datum/map_template/random_room/template = pickweight(possibletemplates)
		template.stock --
		template.weight = (template.weight / 2)
		if(template.stock <= 0)
			template.spawned = TRUE
		template.load(get_turf(src), centered = template.centerspawner)
	return INITIALIZE_HINT_QDEL

/obj/effect/spawner/house/fivexfour
	name = "5x4 room spawner"
	room_width = 5
	room_height = 4

/obj/effect/spawner/house/fivexthree
	name = "5x3 room spawner"
	room_width = 5
	room_height = 3

/obj/effect/spawner/house/threexfive
	name = "3x5 room spawner"
	room_width = 3
	room_height = 5

/obj/effect/spawner/house/tenxten
	name = "10x10 room spawner"
	room_width = 10
	room_height = 10

/obj/effect/spawner/house/tenxfive
	name = "10x5 room spawner"
	room_width = 10
	room_height = 5

/obj/effect/spawner/house/threexthree
	name = "3x3 room spawner"
	room_width = 3
	room_height = 3

/obj/effect/spawner/house_dist
	name = "House number distributor (one per map!)"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "random_room"
	dir = NORTH
	var/max_houses = 15
	var/max_syndi_houses = 2
	var/max_occult_houses = 1

/obj/effect/spawner/house_dist/Initialize(mapload)
	..()// stops after 40 times so it doesn't infinitely search for a number when there are not enough of them
	for (var/i=0, i<=40, i++)
		var/house = rand(1, max_houses)
		if (GLOB.syndi_houses.Find(house) != 0)
			continue
		else if (GLOB.occult_houses.Find(house) != 0)
			continue
		else
			if (GLOB.syndi_houses.len < max_syndi_houses)
				GLOB.syndi_houses.Add(house)
			else if (GLOB.occult_houses.len < max_occult_houses)
				GLOB.occult_houses.Add(house)
			else
				break

	return INITIALIZE_HINT_QDEL

GLOBAL_LIST_INIT(syndi_houses, list ())
GLOBAL_LIST_INIT(occult_houses, list ())


