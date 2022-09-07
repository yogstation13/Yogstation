/obj/item/seeds/nettle
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/reagent_containers/food/snacks/grown/nettle
	lifespan = 30
	endurance = 40 // tuff like a toiger
	yield = 4
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/nettle/)
	reagents_add = list(/datum/reagent/toxin/acid = 0.5)

/obj/item/seeds/nettle/
	name = "pack of -nettle seeds"
	desc = "These seeds grow into -nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = " Nettles"
	product = /obj/item/reagent_containers/food/snacks/grown/nettle/
	endurance = 25
	maturation = 8
	yield = 2
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging)
	mutatelist = list()
	reagents_add = list(/datum/reagent/toxin/acid/fluacid = 0.5, /datum/reagent/toxin/acid = 0.5)
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/nettle // "snack"
	seed = /obj/item/seeds/nettle
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "nettle"
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = BURN
	force = 15
	wound_bonus = CANT_WOUND
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("stung")

/obj/item/reagent_containers/food/snacks/grown/nettle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is eating some of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|TOXLOSS)

/obj/item/reagent_containers/food/snacks/grown/nettle/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.gloves)
		return FALSE
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return FALSE
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, force))
			C.update_damage_overlays()
	to_chat(C, span_userdanger("The nettle burns your bare hand!"))
	return TRUE

/obj/item/reagent_containers/food/snacks/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > 0)
		if(istype(src, /obj/item/reagent_containers/food/snacks/grown/nettle/)) // istype instead of new proc because . = ..() is scary
			force -= rand(1, (force / 10) + 1) // rand of 1 to (10% + 1) as opposed to (33% + 1)
		else
			force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/nettle/basic
	seed = /obj/item/seeds/nettle

/obj/item/reagent_containers/food/snacks/grown/nettle/basic/add_juice()
	..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/reagent_containers/food/snacks/grown/nettle/
	seed = /obj/item/seeds/nettle/
	name = "nettle"
	desc = "The <span class='danger'>glowing</span> nettle incites <span class='boldannounce'>rage</span> in you just from looking at it!"
	icon_state = "nettle"
	force = 30
	throwforce = 15

/obj/item/reagent_containers/food/snacks/grown/nettle//add_juice()
	..()
	force = round((5 + seed.potency / 4), 1) // Max 30 dmg, esword level, with max potency and buffed force reduction, should down unarmored in 3-4 hits

/obj/item/reagent_containers/food/snacks/grown/nettle//pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyze(100)
			to_chat(user, span_userdanger("You are stunned by the nettle as you try picking it up!"))

/obj/item/reagent_containers/food/snacks/grown/nettle//attack(mob/living/carbon/M, mob/user)
	if(..())
		return
	if(user.a_intent != INTENT_HARM)
		return
	if(isliving(M))
		to_chat(M, span_danger("You are blinded by the powerful acid of [src]!"))
		log_combat(user, M, "attacked", src)

		M.adjust_blurriness(force/7)
