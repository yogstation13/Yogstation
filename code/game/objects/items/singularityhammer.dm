/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon_state = "singhammer0"
	base_icon_state = "singhammer"
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 0, BOMB = 50, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	var/charged = 5

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/two_handed, \
		force_wielded = 15, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/singularityhammer/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/singularityhammer/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/singularityhammer/process()
	if(charged < 5)
		charged++
	return

/obj/item/singularityhammer/update_icon_state()  //Currently only here to fuck with the on-mob icons.
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/X in orange(5,pull))
		if(ismovable(X))
			var/atom/movable/A = X
			if(A == wielder)
				continue
			if(A && !A.anchored && !ishuman(X))
				step_towards(A,pull)
				step_towards(A,pull)
				step_towards(A,pull)
			else if(ishuman(X))
				var/mob/living/carbon/human/H = X
				if(istype(H.shoes, /obj/item/clothing/shoes/magboots))
					var/obj/item/clothing/shoes/magboots/M = H.shoes
					if(M.magpulse)
						continue
				H.apply_effect(20, EFFECT_PARALYZE, 0)
				step_towards(H,pull)
				step_towards(H,pull)
				step_towards(H,pull)
	return

/obj/item/singularityhammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		if(charged == 5)
			charged = 0
			if(istype(A, /mob/living))
				var/mob/living/Z = A
				Z.take_bodypart_damage(20,0)
			playsound(user, 'sound/weapons/marauder.ogg', 50, 1)
			var/turf/target = get_turf(A)
			vortex(target,user)

/obj/item/mjolnir
	name = "Mjolnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	icon = 'icons/obj/wizard.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF | ACID_PROOF
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE

/obj/item/mjolnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_wielded = 20, \
		icon_wielded = "[base_icon_state]1", \
	)
	AddComponent(/datum/component/cleave_attack, arc_size=180, requires_wielded=TRUE)

/obj/item/mjolnir/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]0"

/obj/item/mjolnir/proc/shock(mob/living/target)
	target.Stun(60)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message(span_danger("[target.name] was shocked by [src]!"), \
		span_userdanger("You feel a powerful shock course through your body sending you flying!"), \
		span_italics("You hear a heavy electrical crack!"))
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)
	return

/obj/item/mjolnir/attack(mob/living/M, mob/user)
	..()
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		playsound(loc, "sparks", 50, 1)
		shock(M)

/obj/item/mjolnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(isliving(hit_atom))
		var/mob/M = hit_atom
		var/atom/A = M.can_block_magic()
		if(A)
			if(isitem(A))
				M.visible_message(span_warning("[M]'s [A] glows brightly as it disrupts the Mjolnir's power!"))
			visible_message(span_boldwarning("<span class='big bold'>With a mighty thud, Mjolnir slams into the [src.loc], and its glow fades!</span><br>"))
			playsound(src, 'sound/effects/meteorimpact.ogg', 100, 1, extrarange = 30)
			new /obj/structure/mjollnir(loc)
			qdel(src)
		else
			shock(hit_atom)
