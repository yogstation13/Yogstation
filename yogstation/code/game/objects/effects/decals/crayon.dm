/obj/effect/decal/cleanable/crayon/Initialize(mapload, main, type, e_name, graf_rot, alt_icon = null)
	if(type == "poseur tag")
		var/datum/team/gang/gang = pick(subtypesof(/datum/team/gang))
		var/gangname = initial(gang.name)
		icon = 'yogstation/icons/effects/crayondecal.dmi'
		icon_state = "[gangname]"
		type = null
	.=..()

/obj/effect/decal/cleanable/crayon/gang
	icon = 'yogstation/icons/effects/crayondecal.dmi'
	layer = ABOVE_NORMAL_TURF_LAYER //Harder to hide
	plane = ADJUSTING_PLANE(GAME_PLANE)
	do_icon_rotate = FALSE //These are designed to always face south, so no rotation please.
	var/datum/team/gang/gang

/obj/effect/decal/cleanable/crayon/gang/Initialize(mapload, datum/team/gang/G, e_name = "gang tag", rotation = 0,  mob/user)
	if(!G)
		return INITIALIZE_HINT_QDEL
	gang = G
	var/newcolor = G.color
	var/area/territory = get_area(src)
	icon_state = G.name
	G.new_territories |= list(territory.type = territory.name)
	//If this isn't tagged by a specific gangster there's no bonus income.
	.=..(mapload, newcolor, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	if(gang)
		var/area/territory = get_area(src)
		gang.territories -= territory.type
		gang.new_territories -= territory.type
		gang.lost_territories |= list(territory.type = territory.name)
		gang = null
	return ..()
