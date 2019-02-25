/obj/item/storage/backpack/holding
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "holdingpack"
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_HEAD // yes thats right you can wear it on your head! It's not useful for extra storage because it makes you blind or look out the other bag.
	flags_inv = HIDEHAIR
	var/cut = FALSE
	var/appears_split = FALSE

/obj/item/storage/backpack/holding/build_worn_icon(var/state = "", var/default_layer = 0, var/default_icon_file = null, var/isinhands = FALSE, var/femaleuniform = NO_FEMALE_UNIFORM)
	state = item_state
	if(default_icon_file == 'icons/mob/head.dmi')
		default_icon_file = 'yogstation/icons/mob/head.dmi' // thats a fun dilemma.... how to keep the tg sprites when doing back but do yogs sprites when worn on head.
	return ..()

/obj/item/storage/backpack/holding/attackby(obj/item/W, mob/living/user)
	if(istype(W, /obj/item/disabled_boh) && appears_split) // allows you to make a split bag appear whole, so that you can fool security or whatever with it. it's a bit pricey though since you need to bork an entire bag to do so.
		to_chat(user, "<span class='notice'>You graft the outer shell of the disabled bag onto this one.</span>")
		qdel(W)
		cut = FALSE
		appears_split = FALSE
		name = initial(name)
		icon_state = initial(icon_state)
		return TRUE
	if(istype(W, /obj/item/scalpel) && istype(loc, /turf) && !appears_split) // you gotta do this on the ground.
		if(!cut)
			user.visible_message("[user] begins to make an incision on the outer shell of [src].", "<span class='notice'>You begin to make an incision on the outer shell of [src]...</span>")
			if(W.use_tool(src, user, 40))
				if(!appears_split && !cut)
					user.visible_message("[user] succeeds!", "<span class='notice'>You succeed.</span>")
					cut = TRUE
					name = "cut [initial(name)]"
					icon_state = "holdingpack-cut"
			else
				user.visible_message("<span class='warning'>[user] screws up!</span>", "<span class='warning'>You screw up!</span>")
			return TRUE
		else
			user.visible_message("[user] begins to carefully cut [src]'s bluespace interface in half.", "<span class='notice'>You begin to carefully cut [src]'s bluespace interface in half...</span>")
			if(W.use_tool(src, user, 40))
				if(!appears_split && cut)
					user.visible_message("[user] succeeds!", "<span class='notice'>You succeed.</span>")
					cut = FALSE
					appears_split = TRUE
					name = "split [initial(name)]"
					icon_state = "holdingpack-split-right"

					var/obj/item/storage/backpack/holding/twin = new(loc)
					GET_COMPONENT_FROM(old_other_storage, /datum/component/storage, twin)
					old_other_storage.RemoveComponent()
					GET_COMPONENT(this_storage, /datum/component/storage)
					var/datum/component/storage/twin_storage = twin.AddComponent(/datum/component/storage/bluespace/bag_of_holding, this_storage.master()) // add a slave storage component
					twin_storage.allow_big_nesting = TRUE
					twin_storage.max_w_class = WEIGHT_CLASS_GIGANTIC
					twin_storage.max_combined_w_class = 35
					twin_storage.max_items = 21
					twin.cut = FALSE
					twin.appears_split = TRUE
					twin.name = "split [initial(twin.name)]"
					twin.icon_state = "holdingpack-split-left"
			else // HAHAHAHA YOU FUCKED UP BIG TIME MATE
				user.visible_message("<span class='danger'>[user] screws up, causing the bluespace interface to collapse catastrophically!</span>", "<span class='userdanger'>You screw up, causing the bluespace interface to collapse catastrophically! Try not moving next time?</span>")
				fuck_up(user)
			return TRUE
	else if(istype(W, /obj/item/hemostat) && istype(loc, /turf) && !appears_split && cut) // how to bork a bag of holding
		user.visible_message("[user] begins to carefully disrupt [src]'s bluespace interface.", "<span class='notice'>You begin to carefully disrupt [src]'s bluespace interface...</span>")
		if(W.use_tool(src, user, 40))
			if(!appears_split && cut)
				user.visible_message("[user] succeeds!", "<span class='notice'>You succeed.</span>")
				disable_bag(TRUE)
				var/obj/item/disabled_boh/replacement = new(loc)
				replacement.icon_state = replacetext(icon_state, "holdingpack", "brokenpack")
				replacement.name = name
				qdel(src)
		else // HAHAHAHA YOU FUCKED UP BIG TIME MATE
			user.visible_message("<span class='danger'>[user] screws up, causing the bluespace interface to collapse catastrophically!</span>", "<span class='userdanger'>You screw up, causing the bluespace interface to collapse catastrophically! Try not moving next time?</span>")
			fuck_up(user)
		return TRUE
	return ..()

/obj/item/storage/backpack/holding/proc/disable_bag(dump = FALSE)
	// find a new master but only if this bag is a master
	GET_COMPONENT(STR, /datum/component/storage/concrete)
	if(istype(STR))
		var/list/new_slaves = STR.slaves.Copy()
		var/datum/component/storage/new_master = pick_n_take(new_slaves)
		if(new_master)
			var/obj/item/storage/backpack/holding/m_obj = new_master.parent
			GET_COMPONENT_FROM(m_storage, /datum/component/storage, m_obj)
			if(m_storage)
				m_storage.RemoveComponent()
			m_storage = m_obj.AddComponent(m_obj.component_type)
			m_storage.allow_big_nesting = TRUE
			m_storage.max_w_class = WEIGHT_CLASS_GIGANTIC
			m_storage.max_combined_w_class = 35
			m_storage.max_items = 21
			for(var/datum/component/storage/slave in new_slaves)
				slave.change_master(m_storage)
			for(var/obj/item/I in src)
				I.forceMove(m_obj)
	STR.RemoveComponent()
	if(dump && get_turf(src))
		for(var/obj/item/I in src)
			I.forceMove(get_turf(src))

/obj/item/storage/backpack/holding/Destroy()
	disable_bag()
	. = ..()

/obj/item/storage/backpack/holding/proc/fuck_up(mob/living/user)
	var/turf/loccheck = get_turf(src)
	if(is_reebe(loccheck.z) || istype(loccheck.loc, /area/fabric_of_reality))
		qdel(src)
		return
	playsound(loccheck,'sound/effects/supermatter.ogg', 200, 1)

	message_admins("[ADMIN_LOOKUPFLW(user)] screwed up a bag of holding split at [ADMIN_VERBOSEJMP(loccheck)].")
	log_game("[key_name(user)] screwed up a bag of holding split at [loc_name(loccheck)].")

	user.gib(TRUE, TRUE, TRUE)
	for(var/turf/T in range(1,loccheck)) // much less large than a normal bag of holding explosion
		if(istype(T, /turf/open/space/transit))
			continue
		for(var/mob/living/M in T)
			if(M.movement_type & FLYING)
				M.visible_message("<span class='danger'>The bluespace collapse crushes the air towards it, pulling [M] towards the ground...</span>")
				M.Paralyze(5, TRUE, TRUE)		//Overrides stun absorbs.
		T.TerraformTurf(/turf/open/chasm/magic, /turf/open/chasm/magic)
	for(var/fabricarea in get_areas(/area/fabric_of_reality))
		var/area/fabric_of_reality/R = fabricarea
		R.origin = loccheck
	for (var/obj/structure/ladder/unbreakable/binary/ladder in GLOB.ladders)
		ladder.ActivateAlmonds()
	qdel(src)

/obj/item/storage/backpack/holding/equipped(mob/living/carbon/user, slot)
	. = ..()
	if(slot == SLOT_HEAD)
		// time to wonkize this shit
		GET_COMPONENT(STR, /datum/component/storage)
		var/datum/component/storage/concrete/master = STR.master()
		var/list/eye_list = master.slaves + master - STR
		if(eye_list.len)
			var/datum/component/storage/chosen = pick(eye_list)
			var/obj/chosen_item = chosen.parent

			user.reset_perspective(chosen_item)
		else
			user.update_tint()

/mob/living/carbon/get_total_tint()
	. = ..()
	if(istype(head, /obj/item/storage/backpack/holding))
		if(client && !istype(client.eye, /obj/item/storage/backpack/holding)) // check if we're actually looking out another bag
			. += 3

/mob/living/carbon/reset_perspective()
	. = ..()
	update_tint()

/mob/living/carbon/head_update(obj/item/I, forced) // not oop but meh at least its *modularized*. if you want to see OOP stuff look at spacepod code
	if(istype(I, /obj/item/storage/backpack/holding))
		if(head != I) // wait so why isn't there a proc that's called when something's unequipped? HUH? TG?
			reset_perspective()
	. = ..()


/obj/item/disabled_boh
	name = "bag of holding"
	desc = "A backpack that opens into a localized pocket of bluespace. The bluespace interface on this one is collapsed, rendering it useless"
	icon = 'yogstation/icons/obj/storage.dmi'
	icon_state = "brokenpack"
	item_state = "holdingpack"
	resistance_flags = FIRE_PROOF
	item_flags = NO_MAT_REDEMPTION
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 50)

/obj/item/disabled_boh/build_worn_icon(var/state = "", var/default_layer = 0, var/default_icon_file = null, var/isinhands = FALSE, var/femaleuniform = NO_FEMALE_UNIFORM)
	state = "brokenpack"
	return ..()

//Nick's snail shit

/obj/item/storage/backpack/snail
	name = "snail shell"
	desc = "You wonder who this came from."
	icon = 'yogstation/icons/obj/storage.dmi'
	alternate_worn_icon = 'yogstation/icons/mob/back.dmi'
	item_state = "snail_green"
	icon_state = "snail_green"
	slowdown = 1


/obj/item/storage/backpack/snail/green
	name = "green shell backpack"
	desc = "An emerald-green snail shell converted into a backpack. Still smells of salt"
	item_state = "snail_green"
	icon_state = "snail_green"

