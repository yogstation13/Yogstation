
//Syndie Uno reverse card
/obj/item/syndicateReverseCard
	name = "Red Reverse"
	icon = 'icons/obj/toy.dmi'
	icon_state = "sc_Red Reverse_uno"
	desc = "a card."
	w_class = WEIGHT_CLASS_TINY
	var/used = FALSE //has this been used before? If not, give no hints about it's nature

/obj/item/syndicateReverseCard/Initialize()
	..()
	var/cardColor = pick ("Red", "Green", "Yellow", "Blue") //this randomizes which color reverse you get!
	name = "[cardColor] Reverse"
	icon_state = "sc_[cardColor] Reverse_uno"

/obj/item/syndicateReverseCard/update_icon()
	..()
	if (used)
		cut_overlays()
		add_overlay(image('icons/obj/items_and_weapons.dmi', icon_state = "Reverse_Overlay"))

/obj/item/syndicateReverseCard/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!(attack_type == PROJECTILE_ATTACK))
		return FALSE //this means the attack goes through
	if(istype(hitby, /obj/item/projectile))
		var/obj/item/projectile/P = hitby
		if(P?.firer && P.fired_from && (P.firer != P.fired_from)) //if the projectile comes from YOU, like your spit or some shit, you can't steal that bro. Also protects mechs
			if(ismachinery(P.firer) || isanimal(P.firer) || issilicon(P.firer)) //You can't switcharoo with turrets or simplemobs, or borgs
				return FALSE
			switcharoo(P.firer, owner, P.fired_from)
			return TRUE //this means the attack is blocked
	return FALSE

/obj/item/syndicateReverseCard/proc/switcharoo(mob/firer, mob/user, obj/item/gun/gun) //this proc teleports the gun out of the firer's hands and into the user's. The firer gets the card.
	//first, the sparks!
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(12, 1, firer)
	s.start()
	//next, we move the gun to the user and the card to the firer
	to_chat(user, "The [src] vanishes from your hands, and [gun] appears in them!")
	to_chat(firer, "<span class='warning'>[gun] vanishes from your hands, and a [src] appears in them!</span>")
	user.put_in_hands(gun)
	firer.put_in_hands(src)
	used = TRUE
	update_icon()

/obj/item/syndicateReverseCard/examine(mob/user)
	. = ..()
	if(is_special_character(user))
		. += "<span class='info'>Hold this in your hand when you are getting shot at to steal your opponent's gun. You'll lose this, so be careful!</span>"
		return
	if(used)
		. += "<span class='warning'>Something sinister is strapped to this card. It looks like it was once masked with some sort of cloaking field, which is now nonfunctional.</span>"
		return
