
/obj/effect/decal/cleanable/food
	icon = 'icons/effects/tomatodecal.dmi'
	gender = NEUTER

/obj/effect/decal/cleanable/food/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/food/plant_smudge
	name = "plant smudge"
	desc = "Chlorophyll? More like borophyll!"
	icon_state = "smashed_plant"

/obj/effect/decal/cleanable/food/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	icon_state = "smashed_egg1"
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/food/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	icon_state = "smashed_pie"

/obj/effect/decal/cleanable/food/salt
	name = "salt pile"
	desc = "A sizable pile of table salt. Someone must be upset."
	icon_state = "salt_pile"

/obj/effect/decal/cleanable/food/flour
	name = "flour"
	desc = "What a mess."
	icon_state = "flour"

/obj/effect/decal/cleanable/food/flour/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food/drinks))
		if(src.reagents && W.reagents)
			. = 1 //so the containers don't splash their content on the src while scooping.
			if(!src.reagents.total_volume)
				to_chat(user, "<span class='notice'>[src] isn't thick enough to scoop up!</span>")
				return
			if(W.reagents.total_volume >= W.reagents.maximum_volume)
				to_chat(user, "<span class='notice'>[W] is full!</span>")
				return
			user.visible_message("<span class='notice'>[user] shamefully begins gathering up all [src]...</span>", "<span class='notice'>You shamefully begin gathering up all [src] into [W]...</span>")
			var/scoop_time
			scoop_time = min((W.reagents.maximum_volume - W.reagents.total_volume), src.reagents.total_volume) * 2 //don't spill your flour
			if(do_mob(user, user, scoop_time))
				if(src)
					to_chat(user, "<span class='notice'>You scoop up [src] into [W].</span>")
					reagents.trans_to(W, reagents.total_volume, transfered_by = user)
					if(!reagents.total_volume) //scooped up all of it
						qdel(src)
						return
