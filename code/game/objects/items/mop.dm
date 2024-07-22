/obj/item/mop
	desc = "The world of Janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'yogstation/icons/obj/janitor.dmi'
	icon_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")
	resistance_flags = FLAMMABLE
	var/mopping = 0
	var/mopcount = 0
	var/mopcap = 45
	var/mopspeed = 15
	force_string = "robust... against germs"
	var/insertable = TRUE

/obj/item/mop/Initialize(mapload)
	. = ..()
	create_reagents(mopcap, REFILLABLE)
	AddComponent(/datum/component/liquids_interaction, TYPE_PROC_REF(/obj/item/mop, attack_on_liquids_turf))


/obj/item/mop/proc/clean(turf/A)
	if(reagents.has_reagent(/datum/reagent/water, 1) || reagents.has_reagent(/datum/reagent/water/holywater, 1) || reagents.has_reagent(/datum/reagent/consumable/ethanol/vodka, 1) || reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		A.wash(CLEAN_SCRUB)
	reagents.reaction(A, TOUCH, 10)	//Needed for proper floor wetting.
	reagents.remove_any(1)			//reaction() doesn't use up the reagents


/obj/item/mop/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	var/turf/T = get_turf(A)

	if(istype(A, /obj/item/reagent_containers/glass/bucket) || istype(A, /obj/structure/janitorialcart) || istype(A, /obj/structure/mopbucket))
		return

	if(reagents.total_volume < 1)
		to_chat(user, span_warning("Your mop is dry!"))
		return

	if(T)
		// Disable normal cleaning if there are liquids.
		if(T.liquids)
			to_chat(user, span_warning("It would be quite difficult to clean this with a pool of liquids on top!"))
			return

		user.visible_message("[user] begins to clean \the [T] with [src].", span_notice("You begin to clean \the [T] with [src]..."))

		var/realspeed = mopspeed
		if(IS_JOB(user, "Janitor"))
			realspeed *= 0.8

		if(do_after(user, realspeed, T))
			to_chat(user, span_notice("You finish mopping."))
			clean(T)


/obj/effect/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mop) || istype(I, /obj/item/soap))
		return
	else
		return ..()


/obj/item/mop/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J)
	if(insertable)
		J.put_in_cart(src, user)
		J.mymop=src
		J.update_appearance(UPDATE_ICON)
	else
		to_chat(user, span_warning("You are unable to fit your [name] into the [J.name]."))
		return

/obj/item/mop/proc/attack_on_liquids_turf(obj/item/mop/the_mop, turf/target, mob/user, obj/effect/abstract/liquid_turf/liquids)
	if(!user.Adjacent(target))
		return FALSE
	var/free_space = mopcap - reagents.total_volume
	var/speed_mult = 1
	var/datum/liquid_group/targeted_group = target?.liquids?.liquid_group
	while(!QDELETED(targeted_group))
		if(speed_mult >= 0.2)
			speed_mult -= 0.05
		if(free_space <= 0)
			to_chat(user, span_warning("You cant absorb any more liquid with \the [src]!"))
			return TRUE
		if(!do_after(user, src.mopspeed * speed_mult, target = target))
			break
		if(the_mop.reagents.total_volume == the_mop.mopcap)
			to_chat(user, span_warning("You cant absorb any more liquid with \the [src]!"))
			break
		if(targeted_group?.reagents_per_turf)
			targeted_group?.trans_to_seperate_group(the_mop.reagents, min(targeted_group?.reagents_per_turf, 5))
			to_chat(user, span_notice("You soak up some liquids with \the [src]."))
		else if(!QDELETED(target?.liquids?.liquid_group))
			targeted_group = target.liquids.liquid_group
		else
			break
	user.changeNext_move(CLICK_CD_MELEE)
	return TRUE

/obj/item/mop/cyborg
	insertable = FALSE

/obj/item/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal, complete with a condenser for self-wetting! Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	mopcap = 10
	icon_state = "advmop"
	item_state = "mop"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 12
	throwforce = 14
	throw_range = 4
	mopspeed = 8
	var/refill_enabled = TRUE //Self-refill toggle for when a janitor decides to mop with something other than water.
	var/refill_rate = 0.5 //Rate per process() tick mop refills itself
	var/refill_reagent = /datum/reagent/water //Determins what reagent to use for refilling, just in case someone wanted to make a HOLY MOP OF PURGING

/obj/item/mop/advanced/New()
	..()
	START_PROCESSING(SSobj, src)

/obj/item/mop/advanced/attack_self(mob/user)
	refill_enabled = !refill_enabled
	if(refill_enabled)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj,src)
	to_chat(user, span_notice("You set the condenser switch to the '[refill_enabled ? "ON" : "OFF"]' position."))
	playsound(user, 'sound/machines/click.ogg', 30, 1)

/obj/item/mop/advanced/process(delta_time)
	var/amadd = min(mopcap - reagents.total_volume, refill_rate * delta_time)
	if(amadd > 0)
		reagents.add_reagent(refill_reagent, amadd)

/obj/item/mop/advanced/examine(mob/user)
	. = ..()
	. += span_notice("The condenser switch is set to <b>[refill_enabled ? "ON" : "OFF"]</b>.")

/obj/item/mop/advanced/Destroy()
	if(refill_enabled)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mop/advanced/cyborg
	insertable = FALSE
