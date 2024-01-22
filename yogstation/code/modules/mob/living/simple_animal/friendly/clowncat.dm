/mob/living/simple_animal/pet/cat/clown
	gold_core_spawnable = FRIENDLY_SPAWN
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/clothing/mask/gas/clown_hat = 1, /mob/living/simple_animal/hostile/retaliate/clown = 3)
	name = "Honkers"
	desc = "A goofy little clown cat."
	var/emagged = FALSE
	icon = 'yogstation/icons/mob/clownpets.dmi'
	icon_state = "clown_cat"
	icon_living = "clown_cat"
	icon_dead = "clown_cat_dead"
	var/static/meows = list("yogstation/sound/creatures/clownCatHonk.ogg", "yogstation/sound/creatures/clownCatHonk2.ogg","yogstation/sound/creatures/clownCatHonk3.ogg")
	speak = list("Meow!", "Honk!", "Haaaa....", "Hink!")
	speak_chance = 15
	emote_see = list("shakes its head.", "shivers.", "does a gag.", "clowns around.")

/mob/living/simple_animal/pet/cat/clown/handle_automated_speech(override)
	..()
	if(override || prob(speak_chance))
		visible_message("[name] lets out a honk!")
		playsound(src, pick(meows), 100)

/mob/living/simple_animal/pet/cat/clown/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(emagged)
		return FALSE
	emagged = TRUE
	do_sparks(8, FALSE, loc)

/mob/living/simple_animal/pet/cat/clown/Move(atom/newloc, direct)
	..()
	if(emagged)
		if(prob(5) && stat != DEAD)
			visible_message("[name] pukes up a banana hairball!")
			playsound(get_turf(src), 'sound/effects/splat.ogg', 100, 1)
			new /obj/item/grown/bananapeel(get_turf(src))
			new /obj/effect/decal/cleanable/vomit(get_turf(src))
