//DO NOT ADD MECHA PARTS TO THE GAME WITH THE DEFAULT "SPRITE ME" SPRITE!
//I'm annoyed I even have to tell you this! SPRITE FIRST, then commit.

/obj/item/mecha_parts/mecha_equipment
	name = "mecha equipment"
	icon = 'icons/mecha/mecha_equipment.dmi'
	icon_state = "mecha_equip"
	force = 5
	max_integrity = 300
	/// Prevents hitting stuff when trying to use certain equipment as tools
	item_flags = NOBLUDGEON
	/// Cooldown after use
	var/equip_cooldown = 0
	/// is the module ready for use
	var/equip_ready = TRUE
	/// How much energy it drains when used or while in use
	var/energy_drain = 0
	/// How much this heats the mech when used
	var/heat_cost = 0
	/// Whether this equipment should process along with its chassis
	var/active = FALSE
	/// Linked Mech/Chassis
	var/obj/mecha/chassis = null
	/// Bitflag: MECHA_MELEE|MECHA_RANGED what ranges it operates at
	var/range = MECHA_MELEE
	/// Can the module be salvaged
	var/salvageable = TRUE
	/// Is it a passive module(FALSE) or a selectable module(TRUE)
	var/selectable = TRUE
	/// Used for pacifism checks
	var/harmful = FALSE
	/// Sound when this module is destroyed
	var/destroy_sound = 'sound/mecha/critdestr.ogg'
	/// Bitflag. Used by exosuit fabricator to assign sub-categories based on which exosuits can equip this.
	var/mech_flags = NONE
	/// Special melee override for melee weapons
	var/melee_override = FALSE
	/// Actions granted by this equipment
	var/list/equip_actions = list()

/obj/item/mecha_parts/mecha_equipment/Initialize(mapload)
	. = ..()
	var/list/action_type_list = equip_actions.Copy()
	equip_actions = list()
	for(var/path in action_type_list)
		var/datum/action/new_action = new path
		if(istype(new_action, /datum/action/innate/mecha/equipment))
			var/datum/action/innate/mecha/equipment/equip_action = new_action
			equip_action.equipment = src
		equip_actions.Add(new_action)
	qdel(action_type_list)

/obj/item/mecha_parts/mecha_equipment/proc/update_chassis_page()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
		send_byjax(chassis.occupant,"exosuit.browser","equipment_menu",chassis.get_equipment_menu(),"dropdowns")
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/proc/update_equip_info()
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",get_equip_info())
		return 1
	return

/obj/item/mecha_parts/mecha_equipment/Destroy()
	if(chassis)
		if(chassis.selected == src)	//If it's the active equipment, we lose any passive effects
			on_deselect()
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		src.update_chassis_page()
		log_message("[src] is destroyed.", LOG_MECHA)
		if(chassis.occupant)
			chassis.occupant_message(span_danger("[src] is destroyed!"))
			chassis.occupant.playsound_local(chassis, destroy_sound, 50)
		chassis = null
	for(var/datum/action/innate/mecha/equipment/E in equip_actions)
		E.Destroy()
	return ..()

/obj/item/mecha_parts/mecha_equipment/try_attach_part(mob/user, obj/mecha/M)
	if(can_attach(M))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return FALSE
		attach(M)
		user.visible_message("[user] attaches [src] to [M].", span_notice("You attach [src] to [M]."))
		return TRUE
	to_chat(user, span_warning("You are unable to attach [src] to [M]!"))
	return FALSE

/obj/item/mecha_parts/mecha_equipment/proc/get_equip_info()
	if(!chassis)
		return
	var/txt = "<span style=\"color:[equip_ready?"#0f0":"#f00"];\">*</span>&nbsp;"
	if(chassis.selected == src)
		txt += "<b>[src.name]</b>"
	else if(selectable)
		txt += "<a href='byond://?src=[REF(chassis)];select_equip=[REF(src)]'>[src.name]</a>"
	else
		txt += "[src.name]"

	return txt

/obj/item/mecha_parts/mecha_equipment/proc/action_checks(atom/target)
	if(!target)
		return FALSE
	if(!chassis)
		return FALSE
	if(!(range & MECHA_MELEE) && chassis.default_melee_attack(target))
		return FALSE
	if(!(range & MECHA_RANGED) && !chassis.Adjacent(target))
		return FALSE
	if(!equip_ready)
		return FALSE
	if(energy_drain && !chassis.has_charge(energy_drain))
		return FALSE
	if(HAS_TRAIT(src, TRAIT_MECH_DISABLED))
		return FALSE
	if(chassis.is_currently_ejecting)
		return FALSE
	if(chassis.equipment_disabled)
		to_chat(chassis.occupant, "<span=warn>Error -- Equipment control unit is unresponsive.</span>")
		return FALSE
	if(isliving(target) && harmful && (HAS_TRAIT(chassis.occupant, TRAIT_PACIFISM) || !synth_check(chassis.occupant, SYNTH_RESTRICTED_WEAPON)))
		to_chat(chassis.occupant, span_warning("You don't want to harm other living beings!"))
		return FALSE
	if(isliving(target) && harmful && HAS_TRAIT(chassis.occupant, TRAIT_NO_STUN_WEAPONS))
		to_chat(chassis.occupant, span_warning("You cannot use non-lethal weapons!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/on_process(delta_time)
	return PROCESS_KILL

/obj/item/mecha_parts/mecha_equipment/proc/action(atom/target, mob/living/user, params)
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/start_cooldown()
	if(equip_ready)
		chassis.use_power(energy_drain)
		chassis.adjust_overheat(heat_cost)
	set_ready_state(0)
	addtimer(CALLBACK(src, PROC_REF(set_ready_state), 1), equip_cooldown * check_eva(), TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/mecha_parts/mecha_equipment/proc/do_after_cooldown(atom/target)
	if(!chassis)
		return FALSE
	set_ready_state(FALSE)
	. = do_after(chassis.occupant, equip_cooldown * check_eva(), target, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), target))
	set_ready_state(TRUE)
	if(!.)
		return
	chassis.use_power(energy_drain)
	chassis.adjust_overheat(heat_cost)

/obj/item/mecha_parts/mecha_equipment/proc/do_after_mecha(atom/target, delay)
	if(!chassis)
		return
	return do_after(chassis.occupant, delay * check_eva(), target, extra_checks = CALLBACK(src, PROC_REF(do_after_checks), target))

/obj/item/mecha_parts/mecha_equipment/proc/do_after_checks(atom/target)
	if(!chassis)
		return FALSE
	if(src != chassis.selected)
		return FALSE
	if(target && !(chassis.omnidirectional_attacks || (get_dir(chassis, target) & chassis.dir)))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/proc/can_attach(obj/mecha/M)
	if(M.equipment.len<M.max_equip)
		return 1

/obj/item/mecha_parts/mecha_equipment/proc/attach(obj/mecha/M)
	M.equipment += src
	chassis = M
	forceMove(M)
	log_message("[src] initialized.", LOG_MECHA)
	update_chassis_page()
	ADD_TRAIT(src, TRAIT_NODROP, REF(M))
	item_flags |= NO_MAT_REDEMPTION // terrible
	for(var/datum/action/innate/mecha/equipment/action as anything in equip_actions)
		action.chassis = M
	if(chassis.occupant)
		grant_actions(chassis.occupant)
	return

/obj/item/mecha_parts/mecha_equipment/proc/detach(atom/moveto=null)
	if(chassis.occupant)
		remove_actions(chassis.occupant)
	for(var/datum/action/innate/mecha/equipment/action as anything in equip_actions)
		action.chassis = null
	item_flags &= ~NO_MAT_REDEMPTION
	REMOVE_TRAIT(src, TRAIT_NODROP, REF(chassis))
	if(chassis.selected == src)
		src.on_deselect()
	moveto = moveto || get_turf(chassis)
	if(src.Move(moveto))
		chassis.equipment -= src
		if(chassis.selected == src)
			chassis.selected = null
		update_chassis_page()
		log_message("[src] removed from equipment.", LOG_MECHA)
		chassis = null
		set_ready_state(1)
	return


/obj/item/mecha_parts/mecha_equipment/Topic(href,href_list)
	if(href_list["detach"])
		detach()

/obj/item/mecha_parts/mecha_equipment/proc/set_ready_state(state)
	equip_ready = state
	if(chassis)
		send_byjax(chassis.occupant,"exosuit.browser","[REF(src)]",src.get_equip_info())
	return

/obj/item/mecha_parts/mecha_equipment/proc/occupant_message(message)
	if(chassis)
		chassis.occupant_message("[icon2html(src, chassis.occupant)] [message]")
	return

/obj/item/mecha_parts/mecha_equipment/log_message(message, message_type=LOG_GAME, color=null, log_globally)
	if(chassis)
		chassis.log_message("ATTACHMENT: [src] [message]", message_type, color)
	else
		..()


//Used for reloading weapons/tools etc. that use some form of resource
/obj/item/mecha_parts/mecha_equipment/proc/rearm()
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/needs_rearm()
	return 0


//used for equipment, such as melee weapons, that have passive effects
/obj/item/mecha_parts/mecha_equipment/proc/on_select()
	return 0

/obj/item/mecha_parts/mecha_equipment/proc/on_deselect()
	return 0

// Is the occupant wearing a pilot suit?
/obj/item/mecha_parts/mecha_equipment/proc/check_eva(mob/pilot)
	return chassis?.check_eva(pilot)

// Some equipment can be used as tools
/obj/item/mecha_parts/mecha_equipment/tool_use_check(mob/living/user, amount)
	return (chassis ? (chassis.cell.charge >= energy_drain) : FALSE) // but not if they aren't attached to a mech

// Grant any actions to the pilot
/obj/item/mecha_parts/mecha_equipment/proc/grant_actions(mob/pilot)
	for(var/datum/action/action as anything in equip_actions)
		action.Grant(pilot, chassis, src)

// Remove the actions!!!!
/obj/item/mecha_parts/mecha_equipment/proc/remove_actions(mob/pilot)
	for(var/datum/action/action as anything in equip_actions)
		action.Remove(pilot)
