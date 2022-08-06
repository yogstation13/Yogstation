/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/ash/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ash, 30)
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/effect/decal/cleanable/ash/crematorium
//crematoriums need their own ash cause default ash deletes itself if created in an obj
	turf_loc_check = FALSE

/obj/effect/decal/cleanable/ash/large
	name = "large pile of ashes"
	icon_state = "big_ash"

/obj/effect/decal/cleanable/ash/large/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/ash, 30) //double the amount of ash.

/obj/effect/decal/cleanable/glass
	name = "tiny shards"
	desc = "Back to sand."
	icon = 'icons/obj/shards.dmi'
	icon_state = "tiny"

/obj/effect/decal/cleanable/glass/Initialize()
	. = ..()
	setDir(pick(GLOB.cardinals))

/obj/effect/decal/cleanable/glass/ex_act()
	qdel(src)

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	icon_state = "dirt"
	canSmoothWith = list(/obj/effect/decal/cleanable/dirt, /turf/closed/wall, /obj/structure/falsewall)
	smooth = SMOOTH_FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/dirt/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	if(T.tiled_dirt)
		smooth = SMOOTH_MORE
		icon = 'icons/effects/dirt.dmi'
		icon_state = ""
		queue_smooth(src)
	queue_smooth_neighbors(src)

/obj/effect/decal/cleanable/dirt/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/decal/cleanable/dirt/dust
	name = "dust"
	desc = "A thin layer of dust coating the floor."

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	icon_state = "greenglow"
	light_power = 1
	light_range = 2
	light_color = LIGHT_COLOR_GREEN
	rad_insulation = RAD_NO_INSULATION

/obj/effect/decal/cleanable/greenglow/ex_act()
	return

/obj/effect/decal/cleanable/greenglow/Initialize()
	. = ..()
	AddComponent(/datum/component/radioactive, 15, src, 0, FALSE)
	addtimer(CALLBACK(src, .proc/Decay), 24 SECONDS)

/obj/effect/decal/cleanable/greenglow/proc/Decay()
	var/datum/component/radioactive/R = GetComponent(/datum/component/radioactive)
	name = "dried goo"
	light_power = 0
	light_range = 0
	update_light()
	if(R)
		R.RemoveComponent()

/obj/effect/decal/cleanable/greenglow/filled/Initialize()
	. = ..()
	reagents.add_reagent(pick(/datum/reagent/uranium, /datum/reagent/uranium/radium), 5)

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	gender = NEUTER
	layer = WALL_OBJ_LAYER
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE

/obj/effect/decal/cleanable/cobweb/cobweb2
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"

//Vomit (sorry)
/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")

/obj/effect/decal/cleanable/vomit/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	GLOB.vomit_spots += src

/obj/effect/decal/cleanable/vomit/Destroy(force)
	GLOB.vomit_spots -= src
	. = ..()

/obj/effect/decal/cleanable/vomit/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(isflyperson(H))
			playsound(get_turf(src), 'sound/items/drink.ogg', 50, 1) //slurp
			H.visible_message(span_alert("[H] extends a small proboscis into the vomit pool, sucking it with a slurping sound."))
			if(reagents)
				for(var/datum/reagent/R in reagents.reagent_list)
					if (istype(R, /datum/reagent/consumable))
						var/datum/reagent/consumable/nutri_check = R
						if(nutri_check.nutriment_factor >0)
							H.adjust_nutrition(nutri_check.nutriment_factor * nutri_check.volume)
							reagents.remove_reagent(nutri_check.type,nutri_check.volume)
			reagents.trans_to(H, reagents.total_volume, transfered_by = user)
			qdel(src)

/obj/effect/decal/cleanable/vomit/old
	name = "crusty dried vomit"
	desc = "You try not to look at the chunks, and fail."

/obj/effect/decal/cleanable/vomit/old/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state += "-old"

/obj/effect/decal/cleanable/chem_pile
	name = "chemical pile"
	desc = "A pile of chemicals. You can't quite tell what's inside it."
	gender = NEUTER
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "The shredded remains of what appears to be clothing."
	icon_state = "shreds"
	gender = PLURAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity == 1) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)

/obj/effect/decal/cleanable/shreds/Initialize()
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	. = ..()

/obj/effect/decal/cleanable/glitter
	name = "generic glitter pile"
	desc = "The herpes of arts and crafts."
	icon = 'icons/effects/atmospherics.dmi'
	icon_state = "plasma_old"
	gender = NEUTER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/decal/cleanable/glitter/pink
	name = "pink glitter"
	icon_state = "plasma"

/obj/effect/decal/cleanable/glitter/white
	name = "white glitter"
	icon_state = "nitrous_oxide"

/obj/effect/decal/cleanable/glitter/blue
	name = "blue glitter"
	icon_state = "freon"

/obj/effect/decal/cleanable/plasma
	name = "stabilized plasma"
	desc = "A puddle of stabilized plasma."
	icon_state = "flour"
	icon = 'icons/effects/tomatodecal.dmi'
	color = "#C8A5DC"

/obj/effect/decal/cleanable/insectguts
	name = "insect guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")

/obj/effect/decal/cleanable/insectguts/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	GLOB.vomit_spots += src

/obj/effect/decal/cleanable/insectguts/Destroy(force)
	GLOB.vomit_spots -= src
	. = ..()

/obj/effect/decal/cleanable/flockdrone
	name = "flockdrone remains"
	desc = "A remains of a flockdrone."
	icon = 'goon/icons/mob/flock_mobs.dmi'
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5")
	blood_state = BLOOD_STATE_OIL
	bloodiness = BLOOD_AMOUNT_PER_DECAL

/obj/effect/decal/cleanable/fluid
	name = "strange fluid"
	desc = "A strange fluid."
	icon = 'goon/icons/mob/flock_mobs.dmi'
	icon_state = "fluid1"
	random_icon_states = list("fluid1", "fluid2", "fluid3")
	blood_state = BLOOD_STATE_OIL
	bloodiness = BLOOD_AMOUNT_PER_DECAL