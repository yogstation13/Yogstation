//Judicial visor: Grants the ability to smite an area and knocking down the unfaithful nearby every thirty seconds.
/obj/item/clothing/glasses/judicial_visor
	name = "judicial visor"
	desc = "A strange purple-lensed visor. Looking at it inspires an odd sense of guilt."
	icon = 'icons/obj/clothing/clockwork_garb.dmi'
	icon_state = "judicial_visor_0"
	item_state = "sunglasses"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flash_protect = 1
	var/active = FALSE //If the visor is online
	var/recharging = FALSE //If the visor is currently recharging
	var/datum/action/cooldown/judicial_visor/blaster
	var/recharge_cooldown = 30 SECONDS //divided by 10 if ratvar is alive
	actions_types = list(/datum/action/cooldown/judicial_visor)

/obj/item/clothing/glasses/judicial_visor/Initialize(mapload)
	. = ..()
	GLOB.all_clockwork_objects += src
	blaster = new(src)

/obj/item/clothing/glasses/judicial_visor/Destroy()
	GLOB.all_clockwork_objects -= src
	if(blaster.owner)
		blaster.unset_click_ability(blaster.owner)
	blaster.visor = null
	qdel(blaster)
	return ..()

/obj/item/clothing/glasses/judicial_visor/item_action_slot_check(slot, mob/user)
	if(slot != ITEM_SLOT_EYES)
		return 0
	return ..()

/obj/item/clothing/glasses/judicial_visor/equipped(mob/living/user, slot)
	..()
	if(slot != ITEM_SLOT_EYES)
		update_status(FALSE)
		if(blaster.owner)
			blaster.unset_click_ability(blaster.owner)
		return 0
	if(is_servant_of_ratvar(user))
		update_status(TRUE)
	else
		update_status(FALSE)
	if(iscultist(user)) //Cultists spontaneously combust
		to_chat(user, "[span_heavy_brass("\"Consider yourself judged, whelp.\"")]")
		to_chat(user, span_userdanger("You suddenly catch fire!"))
		user.adjust_fire_stacks(5)
		user.ignite_mob()
	return 1

/obj/item/clothing/glasses/judicial_visor/dropped(mob/user)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(check_on_mob), user), 1) //dropped is called before the item is out of the slot, so we need to check slightly later

/obj/item/clothing/glasses/judicial_visor/proc/check_on_mob(mob/user)
	if(user && src != user.get_item_by_slot(ITEM_SLOT_EYES)) //if we happen to check and we AREN'T in the slot, we need to remove our shit from whoever we got dropped from
		update_status(FALSE)
		if(blaster.owner)
			blaster.unset_click_ability(user)

/obj/item/clothing/glasses/judicial_visor/attack_self(mob/user)
	if(is_servant_of_ratvar(user) && src == user.get_item_by_slot(ITEM_SLOT_EYES))
		blaster.Trigger()

/obj/item/clothing/glasses/judicial_visor/proc/update_status(change_to)
	if(recharging || !isliving(loc))
		icon_state = "judicial_visor_0"
		return 0
	if(active == change_to)
		return 0
	var/mob/living/L = loc
	active = change_to
	icon_state = "judicial_visor_[active]"
	L.update_mob_action_buttons()
	L.update_inv_glasses()
	if(!is_servant_of_ratvar(L) || L.stat)
		return 0
	switch(active)
		if(TRUE)
			to_chat(L, "[span_notice("As you put on [src], its lens begins to glow, information flashing before your eyes.")]\n\
			[span_heavy_brass("Judicial visor active. Use the action button to gain the ability to smite the unworthy.")]")
		if(FALSE)
			to_chat(L, span_notice("As you take off [src], its lens darkens once more."))
	return 1

/obj/item/clothing/glasses/judicial_visor/proc/recharge_visor(mob/living/user)
	if(!src)
		return 0
	recharging = FALSE
	if(user && src == user.get_item_by_slot(ITEM_SLOT_EYES))
		to_chat(user, span_brass("Your [name] hums. It is ready."))
	else
		active = FALSE
	icon_state = "judicial_visor_[active]"
	if(user)
		user.update_mob_action_buttons()
		user.update_inv_glasses()

/datum/action/cooldown/judicial_visor
	name = "Create Judicial Marker"
	desc = "Allows you to create a stunning Judicial Marker at any location in view. Click again to disable."
	ranged_mousepointer = 'icons/effects/mouse_pointers/visor_reticule.dmi'
	button_icon = 'icons/obj/clothing/clockwork_garb.dmi'
	button_icon_state = "judicial_visor_1"
	background_icon_state = "bg_clock"
	click_to_activate = TRUE
	var/judgment_range = 7
	var/obj/item/clothing/glasses/judicial_visor/visor

/datum/action/cooldown/judicial_visor/link_to(Target)
	. = ..()
	visor = Target

/datum/action/cooldown/judicial_visor/IsAvailable(feedback = FALSE)
	if(!is_servant_of_ratvar(owner))
		return FALSE
	if(visor.recharging)
		return FALSE
	if(owner.incapacitated() || !visor || visor != owner.get_item_by_slot(ITEM_SLOT_EYES))
		return FALSE
	if(!isturf(owner.loc))
		return FALSE
	return TRUE

/datum/action/cooldown/judicial_visor/Activate(atom/target_atom)
	var/mob/living/living_owner = owner
	if(owner && get_dist(get_turf(owner), get_turf(target_atom)) > judgment_range)
		target_atom.balloon_alert(owner, "too far away!")
		return
	visor.recharging = TRUE
	visor.update_status()
	for(var/obj/item/clothing/glasses/judicial_visor/V in living_owner.get_all_contents())
		if(V == visor)
			continue
		V.recharging = TRUE //To prevent exploiting multiple visors to bypass the cooldown
		V.update_status()
		addtimer(CALLBACK(V, TYPE_PROC_REF(/obj/item/clothing/glasses/judicial_visor, recharge_visor), owner), (GLOB.ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown) * 2)
	clockwork_say(owner, text2ratvar("Kneel, heathens!"))
	owner.visible_message(span_warning("[owner]'s judicial visor fires a stream of energy at [target_atom], creating a strange mark!"), "[span_heavy_brass("You direct [visor]'s power to [target_atom]. You must wait for some time before doing this again.")]")
	var/turf/target_turf = get_turf(target_atom)
	new /obj/effect/clockwork/judicial_marker(target_turf, owner)
	log_combat(owner, target_turf, "created a judicial marker")
	owner.update_mob_action_buttons()
	owner.update_inv_glasses()
	addtimer(CALLBACK(visor, TYPE_PROC_REF(/obj/item/clothing/glasses/judicial_visor, recharge_visor), owner), GLOB.ratvar_awakens ? visor.recharge_cooldown*0.1 : visor.recharge_cooldown)//Cooldown is reduced by 10x if Ratvar is up
	unset_click_ability(owner)

//Judicial marker: Created by the judicial visor. Immediately applies Belligerent and briefly knocks down, then after 3 seconds does large damage and briefly knocks down again
/obj/effect/clockwork/judicial_marker
	name = "judicial marker"
	desc = "You get the feeling that you shouldn't be standing here."
	clockwork_desc = "A sigil that will soon erupt and smite any unenlightened nearby."
	icon = 'icons/effects/96x96.dmi'
	icon_state = ""
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_MOB_LAYER
	var/mob/user

/obj/effect/clockwork/judicial_marker/Initialize(mapload, caster)
	. = ..()
	set_light(1.4, 2, "#FE9C11")
	user = caster
	INVOKE_ASYNC(src, PROC_REF(judicialblast))

/obj/effect/clockwork/judicial_marker/singularity_act()
	return

/obj/effect/clockwork/judicial_marker/singularity_pull()
	return

/obj/effect/clockwork/judicial_marker/proc/judicialblast()
	playsound(src, 'sound/magic/magic_missile.ogg', 50, 1, 1, 1)
	flick("judicial_marker", src)
	for(var/mob/living/carbon/C in range(1, src))
		var/datum/status_effect/belligerent/B = C.apply_status_effect(STATUS_EFFECT_BELLIGERENT)
		if(!QDELETED(B))
			B.duration = world.time + 3 SECONDS
			C.Paralyze(0.5 SECONDS) //knocks down for half a second if affected
	sleep(!GLOB.ratvar_approaches ? 1.6 SECONDS : 1 SECONDS)
	name = "judicial blast"
	layer = ABOVE_ALL_MOB_LAYER
	flick("judicial_explosion", src)
	set_light(1.4, 2, "#B451A1")
	sleep(1.3 SECONDS)
	name = "judicial explosion"
	var/targetsjudged = 0
	playsound(src, 'sound/effects/explosion_distant.ogg', 100, 1, 1, 1)
	set_light(0)
	for(var/mob/living/L in range(1, src))
		if(is_servant_of_ratvar(L))
			continue
		var/atom/I = L.can_block_magic()
		if(I)
			if(isitem(I))
				L.visible_message(span_warning("Strange energy flows into [L]'s [I.name]!"), \
				span_userdanger("Your [I.name] shields you from [src]!"))
			continue
		L.Paralyze(15) //knocks down briefly when exploding
		if(!iscultist(L))
			L.visible_message(span_warning("[L] is struck by a judicial explosion!"), \
			span_userdanger("[!issilicon(L) ? "An unseen force slams you into the ground!" : "ERROR: Motor servos disabled by external source!"]"))
		else
			L.visible_message(span_warning("[L] is struck by a judicial explosion!"), \
			"[span_heavy_brass("\"Keep an eye out, filth.\"")]\n[span_userdanger("A burst of heat crushes you against the ground!")]")
			L.adjust_fire_stacks(2) //sets cultist targets on fire
			L.ignite_mob()
			L.adjustFireLoss(5)
		targetsjudged++
		if(!QDELETED(L))
			L.adjustBruteLoss(20) //does a decent amount of damage
		log_combat(user, L, "struck with a judicial blast")
	to_chat(user, span_brass("<b>[targetsjudged ? "Successfully judged [span_neovgre("[targetsjudged]")]":"Judged no"] heretic[targetsjudged == 1 ? "":"s"].</b>"))
	sleep(3) //so the animation completes properly
	qdel(src)

/obj/effect/clockwork/judicial_marker/ex_act(severity)
	return
