//bepis boomerang
/obj/item/melee/baton/boomerang
	name = "\improper OZtek Boomerang"
	desc = "A device invented in 2486 for the great Space Emu War by the confederacy of Australicus, these high-tech boomerangs also work exceptionally well at stunning crewmembers. Just be careful to catch it when thrown!"
	throw_speed = 2
	icon = 'modular_dripstation/icons/obj/weapons/security.dmi'
	lefthand_file = 'modular_dripstation/icons/mob/inhands/security_lefthand.dmi'
	righthand_file = 'modular_dripstation/icons/mob/inhands/security_righthand.dmi'
	icon_state = "boomerang"
	item_state = "boomerang"
	force = 5
	throwforce = 5
	throw_range = 5
	hitcost = 2000
	throw_hit_chance = 99  //Have you prayed today?
	custom_materials = list(/datum/material/iron = 10000, /datum/material/glass = 4000, /datum/material/silver = 10000, /datum/material/gold = 1000)

/obj/item/melee/baton/boomerang/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!status)
		return ..()
	var/caught = hit_atom.hitby(src, skipcatch = FALSE, hitpush = FALSE, throwingdatum = throwingdatum)
	if(isliving(hit_atom) && !iscyborg(hit_atom) && !caught && prob(throw_hit_chance))//if they are a living creature and they didn't catch it
		baton_stun(hit_atom, thrownby)
	throw_at(thrownby, throw_range+3, throw_speed, null)
	..()

/obj/item/melee/baton/boomerang/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(iscarbon(thrower))
		var/mob/living/carbon/C = thrower
		C.throw_mode_on()
	..()

/obj/item/melee/baton/boomerang/loaded //Same as above, comes with a cell.
	preload_cell_type = /obj/item/stock_parts/cell/high