/obj/item/robot_module
	name = "Default"
	icon = 'icons/obj/module.dmi'
	icon_state = "std_mod"
	w_class = WEIGHT_CLASS_GIGANTIC
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	flags_1 = CONDUCT_1

	/// Sets the cyborg's armor values to these upon selecting their module.
	var/list/module_armor = list()
	/// Determines if the module will give '/datum/component/armor_plate' and how many times it can be done.
	var/use_armorplates = 0

	var/list/basic_modules = list() ///a list of paths, converted to a list of instances on New()
	var/list/emag_modules = list() ///ditto
	var/list/ratvar_modules = list() ///ditto ditto
	var/list/modules = list() ///holds all the usable modules
	var/list/added_modules = list() ///modules not inherient to the robot module, are kept when the module changes
	var/list/storages = list()

	var/list/radio_channels = list()

	var/cyborg_base_icon = "robot" ///produces the icon for the borg and, if no special_light_key is set, the lights
	var/special_light_key ///if we want specific lights, use this instead of copying lights in the dmi

	var/moduleselect_icon = "nomod"

	var/can_be_pushed = TRUE
	var/magpulsing = FALSE

	var/did_feedback = FALSE

	var/hat_offset = -3

	var/list/ride_offset_x = list("north" = 0, "south" = 0, "east" = -6, "west" = 6)
	var/list/ride_offset_y = list("north" = 4, "south" = 4, "east" = 3, "west" = 3)
	var/ride_allow_incapacitated = TRUE
	var/allow_riding = TRUE
	var/canDispose = FALSE /// Whether the borg can stuff itself into disposal

	var/syndicate_module = FALSE /// If the borg should blow emag size regardless of emag state

	var/obj/item/hat // Keeps track of the hat while transforming, to attempt to place back on the borg's head

/obj/item/robot_module/Initialize(mapload)
	. = ..()
	for(var/i in basic_modules)
		var/obj/item/I = new i(src)
		basic_modules += I
		basic_modules -= i
	for(var/i in emag_modules)
		var/obj/item/I = new i(src)
		emag_modules += I
		emag_modules -= i
	for(var/i in ratvar_modules)
		var/obj/item/I = new i(src)
		ratvar_modules += I
		ratvar_modules -= i
	

/obj/item/robot_module/Destroy()
	basic_modules.Cut()
	emag_modules.Cut()
	ratvar_modules.Cut()
	modules.Cut()
	added_modules.Cut()
	storages.Cut()

	return ..()

/obj/item/robot_module/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_CONTENTS)
		return
	for(var/obj/O in modules)
		O.emp_act(severity)
	..()

/obj/item/robot_module/proc/get_usable_modules()
	. = modules.Copy()

/obj/item/robot_module/proc/get_inactive_modules()
	. = list()
	var/mob/living/silicon/robot/R = loc
	for(var/m in get_usable_modules())
		if(!(m in R.held_items))
			. += m

/obj/item/robot_module/proc/get_or_create_estorage(storage_type)
	for(var/datum/robot_energy_storage/S in storages)
		if(istype(S, storage_type))
			return S

	return new storage_type(src)

/obj/item/robot_module/proc/add_module(obj/item/I, nonstandard, requires_rebuild)
	if(istype(I, /obj/item/stack))
		var/obj/item/stack/S = I

		if(is_type_in_list(S, list(/obj/item/stack/sheet/metal, /obj/item/stack/rods, /obj/item/stack/tile/plasteel)))
			if(S.materials[/datum/material/iron])
				S.cost = S.materials[/datum/material/iron] * 0.25
			S.source = get_or_create_estorage(/datum/robot_energy_storage/metal)

		else if(istype(S, /obj/item/stack/sheet/glass))
			S.cost = 500
			S.source = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/sheet/rglass/cyborg))
			var/obj/item/stack/sheet/rglass/cyborg/G = S
			G.source = get_or_create_estorage(/datum/robot_energy_storage/metal)
			G.glasource = get_or_create_estorage(/datum/robot_energy_storage/glass)

		else if(istype(S, /obj/item/stack/medical))
			S.cost = 250
			S.source = get_or_create_estorage(/datum/robot_energy_storage/medical)

		else if(istype(S, /obj/item/stack/cable_coil))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/wire)

		else if(istype(S, /obj/item/stack/ethernet_coil))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/ethernet)

		else if(istype(S, /obj/item/stack/marker_beacon))
			S.cost = 1
			S.source = get_or_create_estorage(/datum/robot_energy_storage/beacon)

		if(S && S.source)
			S.materials = list()
			S.is_cyborg = 1

	if(I.loc != src)
		I.forceMove(src)
	modules += I
	ADD_TRAIT(I, TRAIT_NODROP, CYBORG_ITEM_TRAIT)
	I.mouse_opacity = MOUSE_OPACITY_OPAQUE
	if(nonstandard)
		added_modules += I
	if(requires_rebuild)
		rebuild_modules()
	return I

/obj/item/robot_module/proc/remove_module(obj/item/I, delete_after)
	var/mob/living/silicon/robot/R = loc
	if(!istype(R))
		return
	
	// Keeping these to reset their module slots to what they were previously.
	var/list/held_modules = R.held_items.Copy()
	var/active_module_num = R.get_selected_module()
	R.uneq_all() // Must be done before module removed; otherwise, will CRASH().

	basic_modules -= I
	modules -= I
	emag_modules -= I
	ratvar_modules -= I
	added_modules -= I
	rebuild_modules(held_modules, active_module_num)
	if(delete_after)
		qdel(I)

/obj/item/robot_module/proc/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	for(var/datum/robot_energy_storage/st in storages)
		st.energy = min(st.max_energy, st.energy + coeff * st.recharge_rate)

	for(var/obj/item/I in get_usable_modules())
		if(istype(I, /obj/item/assembly/flash))
			var/obj/item/assembly/flash/F = I
			F.times_used = 0
			F.burnt_out = FALSE
			F.update_appearance(UPDATE_ICON)
		else if(istype(I, /obj/item/melee/baton))
			var/obj/item/melee/baton/B = I
			if(B.cell)
				B.cell.charge = B.cell.maxcharge
		else if(istype(I, /obj/item/gun/energy))
			var/obj/item/gun/energy/EG = I
			if(!EG.chambered)
				EG.recharge_newshot() //try to reload a new shot.

	R.toner = R.tonermax

/obj/item/robot_module/proc/rebuild_modules(list/last_held_modules = null, last_active_module_num = null) ///builds the usable module list from the modules we have
	var/mob/living/silicon/robot/R = loc
	if(!istype(R))
		return

	var/list/held_modules = R.held_items.Copy()
	if(last_held_modules) 
		held_modules = last_held_modules
	var/active_module_num = R.get_selected_module()
	if(last_active_module_num)
		active_module_num = last_active_module_num

	R.uneq_all()
	modules = list()
	for(var/obj/item/I in basic_modules)
		add_module(I, FALSE, FALSE)
	if(R.emagged)
		for(var/obj/item/I in emag_modules)
			add_module(I, FALSE, FALSE)
	if(is_servant_of_ratvar(R))
		for(var/obj/item/I in ratvar_modules)
			add_module(I, FALSE, FALSE)
	for(var/obj/item/I in added_modules)
		add_module(I, FALSE, FALSE)
	for(var/i in held_modules)
		if(i && (i in modules))
			var/slot = held_modules.Find(i)
			R.equip_module_to_slot(i, slot)
			if(slot == active_module_num)
				R.select_module(slot)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()

/obj/item/robot_module/proc/transform_to(new_module_type)
	var/mob/living/silicon/robot/R = loc
	R.uneq_all()
	var/obj/item/robot_module/RM = new new_module_type(R)
	if(!RM.be_transformed_to(src))
		qdel(RM)
		return
	R.special_skin = FALSE
	R.module = RM
	R.update_module_innate()
	RM.rebuild_modules()
	R.radio.recalculateChannels()
	var/datum/component/armor_plate/C = R.GetComponent(/datum/component/armor_plate)
	if(C) // Remove armor plating.
		C.dropplates()
		C.Destroy() // It is possible to switch over to a module that has a different 'use_armorplates' value, thus we remove in all cases.
	if(RM.use_armorplates > 0) // Add armor plating.
		R.AddComponent(/datum/component/armor_plate, RM.use_armorplates)
	R.armor = getArmor(arglist(RM.module_armor))

	INVOKE_ASYNC(RM, PROC_REF(do_transform_animation))
	qdel(src)
	return RM

/obj/item/robot_module/proc/be_transformed_to(obj/item/robot_module/old_module)
	for(var/i in old_module.added_modules)
		added_modules += i
		old_module.added_modules -= i
	did_feedback = old_module.did_feedback
	return TRUE

/obj/item/robot_module/proc/do_transform_animation()
	var/mob/living/silicon/robot/R = loc
	if(R.hat)
		hat = R.hat
		R.hat = null
		hat.moveToNullspace()

	R.cut_overlays()
	R.setDir(SOUTH)
	do_transform_delay()

/obj/item/robot_module/proc/do_transform_delay()
	var/mob/living/silicon/robot/R = loc
	var/prev_lockcharge = R.lockcharge
	sleep(0.1 SECONDS)
	flick("[cyborg_base_icon]_transform", R)
	R.notransform = TRUE
	R.SetLockdown(1)
	R.anchored = TRUE
	R.logevent("Chassis configuration has been set to [name].")
	sleep(0.1 SECONDS)
	for(var/i in 1 to 4)
		playsound(R, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		sleep(0.7 SECONDS)
	if(!prev_lockcharge)
		R.SetLockdown(0)
	R.setDir(SOUTH)
	R.anchored = FALSE
	R.notransform = FALSE
	R.updatehealth()
	R.update_icons()
	R.notify_ai(NEW_MODULE)
	if(R.hud_used)
		R.hud_used.update_robot_modules_display()
	SSblackbox.record_feedback("tally", "cyborg_modules", 1, R.module)

   /*
   check_menu: Checks if we are allowed to interact with a radial menu

   Arguments:
   user The mob interacting with a menu
  */
/obj/item/robot_module/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/robot_module/standard
	name = "Standard"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/reagent_containers/borghypo/epi,
		/obj/item/healthanalyzer,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/extinguisher,
		/obj/item/pickaxe,
		/obj/item/t_scanner/adv_mining_scanner,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/soap/infinite, //yogs - changed soap type
		/obj/item/borg/cyborghug)
	emag_modules = list(/obj/item/melee/transforming/energy/sword/cyborg)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/obj/item/clockwork/replica_fabricator/cyborg)
	moduleselect_icon = "standard"
	hat_offset = -3

/obj/item/robot_module/medical
	name = "Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/healthanalyzer,
		/obj/item/reagent_containers/borghypo/medical,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/extinguisher/mini,
		/obj/item/roller/robo,
		/obj/item/borg/cyborghug/medical,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/stack/medical/bone_gel/cyborg,
		/obj/item/organ_storage,
		/obj/item/borg_snack_dispenser/medical)
	radio_channels = list(RADIO_CHANNEL_MEDICAL)
	emag_modules = list(/obj/item/reagent_containers/borghypo/medical/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "medical"
	moduleselect_icon = "medical"
	can_be_pushed = FALSE
	hat_offset = 3

/obj/item/robot_module/engineering
	name = "Engineering"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/construction/rcd/borg,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/t_scanner,
		/obj/item/analyzer,
		/obj/item/borg/gripper/engineering,
		/obj/item/geiger_counter/cyborg,
		/obj/item/assembly/signaler/cyborg,
		/obj/item/areaeditor/blueprints/cyborg,
		/obj/item/electroadaptive_pseudocircuit,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/ethernet_coil/cyborg,
		/obj/item/barrier_taperoll/engineering)
	radio_channels = list(RADIO_CHANNEL_ENGINEERING)
	emag_modules = list(/obj/item/gun/energy/printer/flamethrower)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/engineer,
		/obj/item/clockwork/replica_fabricator/cyborg)
	cyborg_base_icon = "engineer"
	moduleselect_icon = "engineer"
	magpulsing = TRUE
	hat_offset = -4

/obj/item/robot_module/security
	name = "Security"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/melee/baton/loaded,
		/obj/item/gun/energy/disabler/cyborg,
		/obj/item/clothing/mask/gas/sechailer/cyborg,
		/obj/item/wantedposterposter,
		/obj/item/donutsynth,
		/obj/item/barrier_taperoll/police)
	radio_channels = list(RADIO_CHANNEL_SECURITY)
	emag_modules = list(/obj/item/gun/energy/laser/cyborg)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "sec"
	moduleselect_icon = "security"
	can_be_pushed = FALSE
	hat_offset = 3

/obj/item/robot_module/security/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>While you have picked the security module, you still have to follow your laws, NOT Space Law. \
	For Asimov, this means you must follow criminals' orders unless there is a law 1 reason not to.</span>")

/obj/item/robot_module/security/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/gun/energy/disabler/cyborg/T = locate(/obj/item/gun/energy/disabler/cyborg) in basic_modules
	if(T)
		if(T.cell.charge < T.cell.maxcharge)
			var/obj/item/ammo_casing/energy/S = T.ammo_type[T.select]
			T.cell.give(S.e_cost * coeff)
			T.update_appearance(UPDATE_ICON)
		else
			T.charge_timer = 0

/obj/item/robot_module/peacekeeper
	name = "Peacekeeper"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/borg_snack_dispenser/peacekeeper,
		/obj/item/harmalarm,
		/obj/item/reagent_containers/borghypo/peace,
		/obj/item/holosign_creator/cyborg,
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/extinguisher,
		/obj/item/borg/projectile_dampen)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(/obj/item/reagent_containers/borghypo/peace/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/peacekeeper,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "peace"
	moduleselect_icon = "standard"
	can_be_pushed = FALSE
	hat_offset = -2

/obj/item/robot_module/peacekeeper/do_transform_animation()
	..()
	to_chat(loc, "<span class='userdanger'>Under ASIMOV, you are an enforcer of the PEACE and preventer of HUMAN HARM. \
	You are not a security module and you are expected to follow orders and prevent harm above all else. Space law means nothing to you.</span>")

/obj/item/robot_module/janitor
	name = "Janitor"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/screwdriver/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/soap/infinite, //yogs - changed soap type
		/obj/item/storage/bag/trash/cyborg,
		/obj/item/melee/flyswatter,
		/obj/item/extinguisher/mini,
		/obj/item/mop/cyborg,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/paint/paint_remover,
		/obj/item/lightreplacer/cyborg,
		/obj/item/holosign_creator/janibarrier,
		/obj/item/reagent_containers/spray/cyborg_drying)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(/obj/item/reagent_containers/spray/cyborg_lube)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/janitor,
		/obj/item/clockwork/replica_fabricator/cyborg)
	cyborg_base_icon = "janitor"
	moduleselect_icon = "janitor"
	hat_offset = -5
	/// Weakref to the wash toggle action we own
	var/datum/weakref/wash_toggle_ref

/obj/item/robot_module/janitor/be_transformed_to(obj/item/robot_module/old_module, forced = FALSE)
	. = ..()
	if(!.)
		return
	var/datum/action/wash_toggle = new /datum/action/toggle_buffer(loc)
	wash_toggle.Grant(loc)
	wash_toggle_ref = WEAKREF(wash_toggle)

/obj/item/robot_module/janitor/Destroy()
	QDEL_NULL(wash_toggle_ref)
	return ..()

/datum/action/toggle_buffer
	name = "Activate Auto-Wash"
	desc = "Trade speed and water for a clean floor."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"
	var/block_buffer_change	= FALSE
	var/buffer_on = FALSE
	///The bucket we draw water from
	var/datum/weakref/bucket_ref
	///Our looping sound
	var/datum/looping_sound/wash/wash_audio
	///Toggle cooldown to prevent sound spam
	COOLDOWN_DECLARE(toggle_cooldown)

/datum/action/toggle_buffer/Destroy()
	if(buffer_on)
		turn_off_wash()
	QDEL_NULL(wash_audio)
	return ..()

/datum/action/toggle_buffer/Grant(mob/M)
	. = ..()
	wash_audio = new(list(owner), FALSE)

/datum/action/toggle_buffer/IsAvailable(feedback = FALSE)
	if(!issilicon(owner))
		return FALSE
	return ..()

/datum/action/toggle_buffer/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	block_buffer_change = DOING_INTERACTION(owner, "auto_wash_toggle")
	if(block_buffer_change)
		return FALSE

	var/mob/living/silicon/robot/robot_owner = owner
	var/obj/item/reagent_containers/glass/bucket/our_bucket = locate(/obj/item/reagent_containers/glass/bucket) in robot_owner.module.modules
	bucket_ref = WEAKREF(our_bucket)
	
	// Spam preventation.
	if(!COOLDOWN_FINISHED(src, toggle_cooldown))
		if(!buffer_on)
			robot_owner.balloon_alert(robot_owner, "auto-wash refreshing, please hold...")
		else
			robot_owner.balloon_alert(robot_owner, "auto-wash deactivating, please hold...")
		return FALSE

	// Turning off.
	if(buffer_on)
		robot_owner.balloon_alert(robot_owner, "de-activating auto-wash...")
		deactivate_wash() // Handles its own cooldown for spam prevention.
		return TRUE

	// Turning on - checks.
	if(!allow_buffer_activate())
		return FALSE

	// Turning on.
	COOLDOWN_START(src, toggle_cooldown, 4 SECONDS)
	robot_owner.balloon_alert(robot_owner, "activating auto-wash...")
	// Start the sound. it'll just last the 4 seconds it takes for us to rev up.
	wash_audio.start()
	// We're just gonna shake the borg a bit. Not a ton, but just enough that it feels like the audio makes sense.
	var/base_x = robot_owner.base_pixel_x
	var/base_y = robot_owner.base_pixel_y
	animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 17) // Startup rumble.
		var/x_offset = base_x + rand(-1, 1)
		var/y_offset = base_y + rand(-1, 1)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
	if(!do_after(robot_owner, 4 SECONDS, extra_checks = CALLBACK(src, PROC_REF(allow_buffer_activate))))
		wash_audio.stop() // Coward.
		animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1)
		return FALSE
	activate_wash()

/// Activate the buffer, comes with a nice animation that loops while it's on
/datum/action/toggle_buffer/proc/activate_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	buffer_on = TRUE
	// Slow em down a bunch.
	robot_owner.add_movespeed_modifier("janiborg buffer", multiplicative_slowdown = 3)
	RegisterSignal(robot_owner, COMSIG_MOVABLE_MOVED, PROC_REF(clean))
	// This is basically just about adding a shake to the borg, effect should look ilke an engine's running.
	var/base_x = robot_owner.base_pixel_x
	var/base_y = robot_owner.base_pixel_y
	robot_owner.pixel_x = base_x + rand(-7, 7)
	robot_owner.pixel_y = base_y + rand(-7, 7)
	// Larger shake with more changes to start out, feels like "Revving".
	animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1, loop = -1)
	for(var/i in 1 to 100)
		var/x_offset = base_x + rand(-2, 2)
		var/y_offset = base_y + rand(-2, 2)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
	if(!wash_audio.is_active())
		wash_audio.start()
	clean()
	name = "De-Activate Auto-Wash"
	button_icon_state = "deactivate_wash"
	build_all_button_icons()

/// Start the process of disabling the buffer. Plays some effects, waits a bit, then finishes.
/datum/action/toggle_buffer/proc/deactivate_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	var/time_left = timeleft(wash_audio.timerid) // We delay by the timer of our wash cause well, we want to hear the ramp down.
	var/finished_by = time_left + 2.6 SECONDS
	// Need to ensure that people don't spawn the deactivate button.
	COOLDOWN_START(src, toggle_cooldown, finished_by)
	// Diable the cleaning, we're revving down
	UnregisterSignal(robot_owner, COMSIG_MOVABLE_MOVED)
	// Do the rumble animation till we're all finished.
	var/base_x = robot_owner.base_pixel_x
	var/base_y = robot_owner.base_pixel_y
	animate(robot_owner, pixel_x = base_x, pixel_y = base_y, time = 1)
	for(var/i in 1 to finished_by - 0.1 SECONDS) //We rumble until we're finished making noise
		var/x_offset = base_x + rand(-1, 1)
		var/y_offset = base_y + rand(-1, 1)
		animate(pixel_x = x_offset, pixel_y = y_offset, time = 1)
	// Reset our animations.
	animate(pixel_x = base_x, pixel_y = base_y, time = 2)
	addtimer(CALLBACK(wash_audio, /datum/looping_sound/proc/stop), time_left)
	addtimer(CALLBACK(src, PROC_REF(turn_off_wash)), finished_by)

/// Called by [deactivate_wash] on a timer to allow noises and animation to play out.
/// Finally disables the buffer. Doesn't do everything mind, just the stuff that we wanted to delay.
/datum/action/toggle_buffer/proc/turn_off_wash()
	var/mob/living/silicon/robot/robot_owner = owner
	buffer_on = FALSE
	robot_owner.remove_movespeed_modifier("janiborg buffer")
	name = "Activate Auto-Wash"
	button_icon_state = "activate_wash"
	build_all_button_icons()

/// Should we keep trying to activate our buffer, or did you fuck it up somehow.
/datum/action/toggle_buffer/proc/allow_buffer_activate()
	var/mob/living/silicon/robot/robot_owner = owner
	if(block_buffer_change)
		robot_owner.balloon_alert(robot_owner, "activation cancelled!")
		return FALSE

	var/obj/item/reagent_containers/glass/bucket/our_bucket = bucket_ref?.resolve()
	if(!buffer_on && our_bucket?.reagents?.total_volume < 0.1)
		robot_owner.balloon_alert(robot_owner, "bucket is empty!")
		return FALSE
	return TRUE

/// Call this to attempt to actually clean the turf underneath us.
/datum/action/toggle_buffer/proc/clean()
	SIGNAL_HANDLER
	var/mob/living/silicon/robot/robot_owner = owner

	var/obj/item/reagent_containers/glass/bucket/our_bucket = bucket_ref?.resolve()
	var/datum/reagents/reagents = our_bucket?.reagents

	if(!reagents || reagents.total_volume < 0.1)
		robot_owner.balloon_alert(robot_owner, "bucket is empty, de-activating...")
		deactivate_wash()
		return

	var/turf/our_turf = get_turf(robot_owner)
	
	// We're realistically only going to have water, but here is the full list of chems that can clean anyways.
	if(reagents.has_reagent(/datum/reagent/water, 1) || reagents.has_reagent(/datum/reagent/water/holywater, 1) || reagents.has_reagent(/datum/reagent/consumable/ethanol/vodka, 1) || reagents.has_reagent(/datum/reagent/space_cleaner, 1))
		our_turf.wash(CLEAN_SCRUB)
	
	// Deals with any sleeps().
	INVOKE_ASYNC(reagents, TYPE_PROC_REF(/datum/reagents, reaction), our_turf, TOUCH, 10)

	// We use more water doing this then mopping.
	reagents.remove_any(2) //reaction() doesn't use up the reagents.

/obj/item/reagent_containers/spray/cyborg_drying
	name = "drying agent spray"
	color = "#A000A0"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/item/reagent_containers/spray/cyborg_lube
	name = "lube spray"
	list_reagents = list(/datum/reagent/lube = 250)

/obj/item/robot_module/janitor/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/lightreplacer/LR = locate(/obj/item/lightreplacer) in basic_modules
	if(LR)
		for(var/i in 1 to coeff)
			LR.Charge(R)

	var/obj/item/reagent_containers/spray/cyborg_drying/CD = locate(/obj/item/reagent_containers/spray/cyborg_drying) in basic_modules
	if(CD)
		CD.reagents.add_reagent(/datum/reagent/drying_agent, 5 * coeff)

	var/obj/item/reagent_containers/spray/cyborg_lube/CL = locate(/obj/item/reagent_containers/spray/cyborg_lube) in emag_modules
	if(CL)
		CL.reagents.add_reagent(/datum/reagent/lube, 2 * coeff)

/obj/item/robot_module/clown
	name = "Clown"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/toy/crayon/rainbow,
		/obj/item/instrument/bikehorn,
		/obj/item/stamp/clown,
		/obj/item/bikehorn,
		/obj/item/bikehorn/airhorn,
		/obj/item/paint/anycolor,
		/obj/item/soap/infinite, //yogs - changed soap type
		/obj/item/pneumatic_cannon/pie/selfcharge/cyborg,
		/obj/item/razor,					//killbait material
		/obj/item/lipstick/purple,
		/obj/item/holosign_creator/clown/cyborg, //Evil
		/obj/item/borg/cyborghug/peacekeeper,
		/obj/item/borg_snack_dispenser/medical,
		/obj/item/picket_sign/cyborg,
		/obj/item/reagent_containers/borghypo/clown,
		/obj/item/extinguisher/mini)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(
		/obj/item/reagent_containers/borghypo/clown/hacked,
		/obj/item/reagent_containers/spray/waterflower/cyborg/hacked)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/obj/item/clockwork/replica_fabricator/cyborg)
	moduleselect_icon = "service"
	cyborg_base_icon = "clown"
	hat_offset = -2

/obj/item/robot_module/service
	name = "Service"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/storage/bag/money, // For charging a fee or getting onto the luxury shuttle.
		/obj/item/reagent_containers/food/drinks/drinkingglass,
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/pen,
		/obj/item/toy/crayon/spraycan/borg,
		/obj/item/extinguisher/mini,
		/obj/item/hand_labeler/borg,
		/obj/item/razor,
		/obj/item/rsf,
		/obj/item/borg/gripper/service,
		/obj/item/instrument/guitar,
		/obj/item/instrument/piano_synth,
		/obj/item/reagent_containers/dropper,
		/obj/item/lighter,
		/obj/item/storage/bag/tray,
		/obj/item/reagent_containers/borghypo/borgshaker,
		/obj/item/borg_snack_dispenser/medical,
		/obj/item/reagent_containers/glass/rag,
		/obj/item/soap/infinite)
	radio_channels = list(RADIO_CHANNEL_SERVICE)
	emag_modules = list(/obj/item/reagent_containers/borghypo/borgshaker/hacked)
	ratvar_modules = list(/obj/item/clockwork/slab/cyborg/service,
		/obj/item/borg/sight/xray/truesight_lens)
	moduleselect_icon = "service"
	special_light_key = "service"
	cyborg_base_icon = "tophat"
	hat_offset = 0

/obj/item/robot_module/service/respawn_consumable(mob/living/silicon/robot/R, coeff = 1)
	..()
	var/obj/item/reagent_containers/O = locate(/obj/item/reagent_containers/food/condiment/enzyme) in basic_modules
	if(O)
		O.reagents.add_reagent(/datum/reagent/consumable/enzyme, 2 * coeff)

// The reason why spawning a `silicon/robot/modules/service` or forcing a cyborg into ..
// .. Service doesn't work as it prompts the cyborg into selecting their initial skin first:
/obj/item/robot_module/service/be_transformed_to(obj/item/robot_module/old_module)
	var/mob/living/silicon/robot/R = loc
	var/list/service_icons = sortList(list(
		"Waitress" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_f"),
		"Butler" = image(icon = 'icons/mob/robots.dmi', icon_state = "service_m"),
		"Bro" = image(icon = 'icons/mob/robots.dmi', icon_state = "brobot"),
		"Kent" = image(icon = 'icons/mob/robots.dmi', icon_state = "kent"),
		"Tophat" = image(icon = 'icons/mob/robots.dmi', icon_state = "tophat")
		))
	var/service_robot_icon = show_radial_menu(R, R , service_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), R), radius = 42, require_near = TRUE)
	switch(service_robot_icon)
		if("Waitress")
			cyborg_base_icon = "service_f"
		if("Butler")
			cyborg_base_icon = "service_m"
		if("Bro")
			cyborg_base_icon = "brobot"
		if("Kent")
			cyborg_base_icon = "kent"
			special_light_key = "medical"
			hat_offset = 3
		if("Tophat")
			cyborg_base_icon = "tophat"
			special_light_key = null
			hat_offset = INFINITY //He is already wearing a hat
		else
			return FALSE
	return ..()

/obj/item/robot_module/miner
	name = "Miner"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg,
		/obj/item/borg/sight/meson,
		/obj/item/storage/bag/ore/cyborg,
		/obj/item/pickaxe/drill/cyborg,
		/obj/item/shovel, // This is here for: the ability to butcher & tool behavior of TOOL_SHOVEL. In all other cases, the cyborg drill is better.
		/obj/item/crowbar/cyborg,
		/obj/item/weldingtool/mini,
		/obj/item/extinguisher/mini,
		/obj/item/storage/bag/sheetsnatcher/borg,
		/obj/item/gun/energy/kinetic_accelerator/cyborg,
		/obj/item/gps/cyborg,
		/obj/item/stack/marker_beacon)
	radio_channels = list(RADIO_CHANNEL_SCIENCE, RADIO_CHANNEL_SUPPLY)
	emag_modules = list(/obj/item/gun/energy/plasmacutter/adv/malf)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/miner,
		/obj/item/clockwork/weapon/ratvarian_spear,
		/datum/action/innate/call_weapon/brass_bow,
		/obj/item/borg/sight/xray/truesight_lens)
	cyborg_base_icon = "miner"
	moduleselect_icon = "miner"
	hat_offset = 0
	module_armor = list(MELEE = 20)
	use_armorplates = 3
	var/obj/item/t_scanner/adv_mining_scanner/cyborg/mining_scanner //built in memes.

/obj/item/robot_module/miner/rebuild_modules()
	. = ..()
	if(!mining_scanner)
		mining_scanner = new(src)

/obj/item/robot_module/miner/Destroy()
	QDEL_NULL(mining_scanner)
	return ..()

/obj/item/robot_module/syndicate
	name = "Syndicate Assault"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/melee/transforming/energy/sword/cyborg,
		/obj/item/gun/energy/printer,
		/obj/item/gun/ballistic/revolver/grenadelauncher/cyborg,
		/obj/item/card/emag,
		/obj/item/crowbar/cyborg,
		/obj/item/pinpointer/syndicate_cyborg)

	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/security,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "synd_sec"
	moduleselect_icon = "malf"
	can_be_pushed = FALSE
	hat_offset = 3
	syndicate_module = TRUE

/obj/item/robot_module/syndicate/rebuild_modules()
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction  -= "silicon" //ai turrets

/obj/item/robot_module/syndicate/remove_module(obj/item/I, delete_after)
	..()
	var/mob/living/silicon/robot/Syndi = loc
	Syndi.faction += "silicon" //ai is your bff now!

/obj/item/robot_module/syndicate_medical
	name = "Syndicate Medical"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/reagent_containers/borghypo/syndicate,
		/obj/item/shockpaddles/syndicate,
		/obj/item/healthanalyzer,
		/obj/item/retractor,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/scalpel,
		/obj/item/bonesetter,
		/obj/item/melee/transforming/energy/sword/cyborg/saw,
		/obj/item/roller/robo,
		/obj/item/restraints/handcuffs/cable/zipties,
		/obj/item/extinguisher/mini,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/stack/medical/gauze/cyborg,
		/obj/item/gun/medbeam,
		/obj/item/organ_storage)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/medical,
		/obj/item/clockwork/weapon/ratvarian_spear)
	cyborg_base_icon = "synd_medical"
	moduleselect_icon = "malf"
	can_be_pushed = FALSE
	hat_offset = 3
	syndicate_module = TRUE

/obj/item/robot_module/saboteur
	name = "Syndicate Saboteur"
	basic_modules = list(
		/obj/item/assembly/flash/cyborg/combat,
		/obj/item/kitchen/knife/combat/cyborg,
		/obj/item/borg/sight/thermal,
		/obj/item/construction/rcd/borg/syndicate,
		/obj/item/pipe_dispenser,
		/obj/item/extinguisher,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/screwdriver/nuke,
		/obj/item/wrench/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
		/obj/item/borg/gripper/engineering,
		/obj/item/stack/sheet/metal/cyborg,
		/obj/item/stack/sheet/glass/cyborg,
		/obj/item/stack/sheet/rglass/cyborg,
		/obj/item/stack/rods/cyborg,
		/obj/item/stack/tile/plasteel/cyborg,
		/obj/item/destTagger/borg,
		/obj/item/stack/cable_coil/cyborg,
		/obj/item/stack/ethernet_coil/cyborg,
		/obj/item/pinpointer/syndicate_cyborg,
		/obj/item/borg_chameleon,
		)
	ratvar_modules = list(
		/obj/item/clockwork/slab/cyborg/engineer,
		/obj/item/clockwork/replica_fabricator/cyborg)
	cyborg_base_icon = "synd_engi"
	moduleselect_icon = "malf"
	can_be_pushed = FALSE
	magpulsing = TRUE
	hat_offset = -4
	canDispose = TRUE
	syndicate_module = TRUE

/datum/robot_energy_storage
	var/name = "Generic energy storage"
	var/max_energy = 30000
	var/recharge_rate = 1000
	var/energy

/datum/robot_energy_storage/New(obj/item/robot_module/R = null)
	energy = max_energy
	if(R)
		R.storages |= src
	return

/datum/robot_energy_storage/proc/use_charge(amount)
	if (energy >= amount)
		energy -= amount
		if (energy == 0)
			return 1
		return 2
	else
		return 0

/datum/robot_energy_storage/proc/add_charge(amount)
	energy = min(energy + amount, max_energy)

/datum/robot_energy_storage/metal
	name = "Metal Synthesizer"

/datum/robot_energy_storage/glass
	name = "Glass Synthesizer"

/datum/robot_energy_storage/wire
	max_energy = 50
	recharge_rate = 2
	name = "Wire Synthesizer"

/datum/robot_energy_storage/ethernet
	max_energy = 50
	recharge_rate = 2
	name = "Ethernet Cable Synthesizer"

/datum/robot_energy_storage/medical
	max_energy = 2500
	recharge_rate = 250
	name = "Medical Synthesizer"

/datum/robot_energy_storage/beacon
	max_energy = 30
	recharge_rate = 1
	name = "Marker Beacon Storage"
