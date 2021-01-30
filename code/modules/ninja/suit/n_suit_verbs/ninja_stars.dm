

//Creates a throwing star for 3 energy, 3% of the base power cell.
/obj/item/clothing/suit/space/space_ninja/proc/ninjastar()
	if(!ninjacost(30))
		var/mob/living/carbon/human/H = affecting
		var/obj/item/throwing_star/ninja/N = new(H)
		if(H.put_in_hands(N))
			to_chat(H, "<span class='notice'>A throwing star has been created in your hand!</span>")
		else
			qdel(N)
		H.throw_mode_on() //So they can quickly throw it.


/obj/item/throwing_star/ninja //while not the most important item in the codebase, it is still neat.
	name = "ninja throwing star"
	desc = "A small throwing star with incapacitating poison laced onto the edges."
	throwforce = 10
	embedding = list("embedded_pain_multiplier" = 1, "embed_chance" = 100, "embedded_fall_chance" = 20, "embedded_fall_pain_multiplier" = 1, "embedded_impact_pain_multiplier" = 1)

/obj/item/throwing_star/ninja/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		if(iscarbon(hit_atom))
			var/mob/living/carbon/L = hit_atom
			L.apply_damage(25, STAMINA)
			L.reagents.add_reagent(/datum/reagent/toxin/ninjatoxin, 5)
			return

	..()

