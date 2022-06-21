#define IVYMEN_SPAWN_THRESHOLD 2
//The ivymen nest is basically a rethemed ashwalker nest, takes corpses and makes eggs
/obj/structure/yog_jungle/ivymen
	name = "mother tree nest"
	desc = "A small tree covered in vines, thorns, and foul smelling spores. It's surrounded by a nest of rapidly growing eggs..."
	icon = 'yogstation/icons/mob/nest.dmi'
	icon_state = "ivymen_nest"

	move_resist=INFINITY
	anchored = TRUE
	density = TRUE

	resistance_flags = FIRE_PROOF | LAVA_PROOF
	max_integrity = 200


	var/faction = list("ivymen")
	var/meat_counter = 6
	var/datum/team/ivymen/ivy

/obj/structure/yog_jungle/ivymen/Initialize()
	.=..()
	ivy = new /datum/team/ivymen()
	var/datum/objective/protect_object/objective = new
	objective.set_target(src)
	ivy.objectives += objective
	START_PROCESSING(SSprocessing, src)

/obj/structure/yog_jungle/ivymen/deconstruct(disassembled)
	new /obj/item/assembly/signaler/anomaly (get_step(loc, pick(GLOB.alldirs)))
	return ..()

/obj/structure/yog_jungle/ivymen/process()
	consume()
	spawn_mob()

/obj/structure/yog_jungle/ivymen/proc/consume()
	for(var/mob/living/H in view(src, 1)) //Only for corpse right next to/on same tile
		if(H.stat)
			visible_message(span_warning("Thorny vines eagerly pull [H] to [src], tearing the body apart as its blood seeps over the eggs."))
			playsound(get_turf(src),'sound/magic/demon_consume.ogg', 100, 1)
			for(var/obj/item/W in H)
				if(!H.dropItemToGround(W))
					qdel(W)
			if(ismegafauna(H))
				meat_counter += 20
			else
				meat_counter++
			H.gib()
			obj_integrity = min(obj_integrity + max_integrity*0.05,max_integrity)//restores 5% hp of tree
			for(var/mob/living/L in view(src, 5))
				if(L.mind?.has_antag_datum(/datum/antagonist/ivymen))
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_good)
				else
					SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "oogabooga", /datum/mood_event/sacrifice_bad)

/obj/structure/yog_jungle/ivymen/proc/spawn_mob()
	if(meat_counter >= IVYMEN_SPAWN_THRESHOLD)
		new /obj/effect/mob_spawn/human/ivymen(get_step(loc, pick(GLOB.alldirs)), ivy)
		visible_message(span_danger("One of the eggs swells to an unnatural size and tumbles free. It's ready to hatch!"))
		meat_counter -= IVYMEN_SPAWN_THRESHOLD
