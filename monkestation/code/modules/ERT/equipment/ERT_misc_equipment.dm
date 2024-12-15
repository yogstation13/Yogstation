/obj/item/implant/dust
	name = "self immolation implant"
	desc = "Dust to dust."
	icon = 'icons/obj/nuke_tools.dmi'
	icon_state = "supermatter_sliver_pulse"
	actions_types = list(/datum/action/item_action/dust_implant)
	var/popup = FALSE // is the window open?
	var/active = FALSE

/obj/item/implant/dust/proc/on_death(datum/source)
	SIGNAL_HANDLER

	// There may be other signals that want to handle mob's death
	// and the process of activating destroys the body, so let the other
	// signal handlers at least finish.
	INVOKE_ASYNC(src, PROC_REF(activate), "death")

/obj/item/implant/dust/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Robust Corp RX-81 Employee Management Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				<b>Important Notes:</b> Highly unstable.<BR>
				<HR>
				<b>Implant Details:</b><BR>
				<b>Function:</b> Contains a compact supermatter fragment surrounded in a protective bluespace capsule that releases upon receiving a specially encoded signal or upon host death.<BR>
				<b>Special Features:</b> Self Immolation<BR>
				"}
	return dat

/obj/item/implant/dust/activate(cause)
	. = ..()
	if(!cause || !imp_in || active)
		return FALSE
	if(cause == "action_button")
		if(popup)
			return FALSE
		popup = TRUE
		var/response = tgui_alert(imp_in, "Are you sure you want to activate your [name]? This will cause you to disintergrate!", "[name] Confirmation", list("Yes", "No"))
		popup = FALSE
		if(response != "Yes")
			return FALSE
	if(cause == "death" && HAS_TRAIT(imp_in, TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION))
		return FALSE
	to_chat(imp_in, span_notice("You activate your [name]."))
	active = TRUE
	to_chat(imp_in, "<span class='notice'>Your dusting implant activates!</span>")
	var/turf/immolationturf = get_turf(imp_in)
	message_admins("[ADMIN_LOOKUPFLW(imp_in)] has activated their [name] at [ADMIN_VERBOSEJMP(immolationturf)], with cause of [cause].")

	if(imp_in)
		imp_in.visible_message(span_warning("[imp_in]'s body flashes and burns up from inside in blazing light!"))
		imp_in.investigate_log("has been dusted by a self immolation implant.", INVESTIGATE_DEATHS)
		imp_in.dust()
		playsound(src, 'sound/effects/supermatter.ogg', 50, TRUE)
		qdel(src)
		return

/obj/item/implant/dust/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	. = ..()
	if(.)
		RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/obj/item/implant/dust/removed(mob/target, silent = FALSE, special = FALSE)
	. = ..()
	if(.)
		UnregisterSignal(target, COMSIG_LIVING_DEATH)

/obj/item/implanter/dust
	name = "implanter (self immolation)"
	imp_type = /obj/item/implant/dust

/obj/item/implantcase/dust
	name = "implant case - 'Self Immolation'"
	desc = "A glass case containing a self immolation implant."
	imp_type = /obj/item/implant/dust

/datum/action/item_action/dust_implant
	check_flags = NONE
	name = "Activate Self Immolation Implant"

/obj/item/mod/module/energy_shield/nanotrasen
	name = "MOD energy shield module"
	desc = "A personal, protective forcefield typically seen in military applications. \
		This advanced deflector shield is essentially a scaled down version of those seen on starships, \
		and the power cost can be an easy indicator of this. However, it is capable of blocking nearly any incoming attack, \
		though with its' low amount of separate charges, the user remains mortal."
	shield_icon = "shield-old" //red syndicate blue nanotrasen :P

/obj/item/storage/belt/security/full/bola/PopulateContents()
	new /obj/item/reagent_containers/spray/pepper(src)
	new /obj/item/restraints/legcuffs/bola/energy(src)
	new /obj/item/grenade/flashbang(src)
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/melee/baton/security/loaded(src)
	update_appearance()

/obj/item/clothing/mask/gas/sechailer/swat/ert
	name = "\improper emergency response team mask"
	desc = "A close-fitting tactical mask with a toned down Compli-o-nator 3000. This one is designed for Nanotrasen emergency response teams and has an inbuilt air-freshener. Fancy!"
	icon = 'monkestation/icons/obj/clothing/masks.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/mask.dmi'
	worn_icon_snouted = 'monkestation/icons/mob/clothing/species/mask_muzzled.dmi'
	icon_state = "ert"
	aggressiveness = 1

/obj/item/storage/box/survival/ert
	name = "emergency response survival box"
	desc = "A box with the bare essentials of ensuring the survival of your team. This one is labelled to contain a double tank."
	icon_state = "ntbox"
	illustration = "ntlogo"
	internal_type = /obj/item/tank/internals/emergency_oxygen/double

/obj/item/storage/box/survival/ert/PopulateContents()
	. = ..()
	new /obj/item/reagent_containers/pill/patch/advanced(src)
	new /obj/item/crowbar/red(src)
	new /obj/item/spess_knife(src) // i love this thing and i want it to be out there more
	new /obj/item/flashlight/flare(src)

/obj/item/reagent_containers/pill/patch/advanced
	name = "advanced health patch"
	desc = "Helps with brute and burn injuries while stabilizing the patient. Contains anti-toxin along with formaldehyde."
	list_reagents = list(/datum/reagent/medicine/oxandrolone = 5, /datum/reagent/medicine/sal_acid = 5, /datum/reagent/medicine/granibitaluri = 10, /datum/reagent/medicine/c2/seiver = 5, /datum/reagent/toxin/formaldehyde = 3, /datum/reagent/medicine/coagulant = 2, /datum/reagent/medicine/epinephrine = 10)
	icon_state = "bandaid_msic" //they misspelt it

/obj/item/storage/box/rcd_upgrades
	name = "RCD upgrade diskette box"
	desc = "A box of essential RCD upgrade disks."
	illustration = "disk_kit"

/obj/item/storage/box/rcd_upgrades/PopulateContents()
	. = ..()
	new /obj/item/rcd_upgrade/simple_circuits(src)
	new /obj/item/rcd_upgrade/anti_interrupt(src)
	new /obj/item/rcd_upgrade/cooling(src)
	new /obj/item/rcd_upgrade/silo_link(src)
	new /obj/item/rcd_upgrade/frames(src)
	new /obj/item/rcd_upgrade/furnishing(src)

/obj/item/reagent_containers/spray/drying
	name = "drying agent spray"
	list_reagents = list(/datum/reagent/drying_agent = 250)

/obj/vehicle/sealed/mecha/honker/dark/loaded/not_evil
	operation_req_access = list()
	internals_req_access = list()

/obj/vehicle/sealed/mecha/honker/dark/loaded/not_evil
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/honker,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/launcher/banana_mortar,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(),
	)

/obj/item/storage/belt/janitor/full/ert/PopulateContents()
	new /obj/item/lightreplacer/blue(src)
	new /obj/item/reagent_containers/spray/cleaner(src)
	new /obj/item/soap/omega(src)
	new /obj/item/holosign_creator(src)
	new /obj/item/melee/flyswatter(src)
	new /obj/item/wirebrush(src)

/obj/item/scythe/compact
	name = "compact scythe"
	desc = "A sharp and curved blade on a long fibremetal handle, this tool makes it easy to reap what you sow. This one has been compacted with bluespace fields, don't question it."
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/mod/control/pre_equipped/responsory/generic
	applied_cell = /obj/item/stock_parts/cell/bluespace
	applied_modules = list(
		/obj/item/mod/module/storage/large_capacity,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/rad_protection,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack,
		/obj/item/mod/module/magboot/advanced,
	)

/obj/item/mod/control/pre_equipped/responsory/generic/commander
	insignia_type = /obj/item/mod/module/insignia/commander
	additional_module = /obj/item/mod/module/power_kick

/obj/item/mod/control/pre_equipped/responsory/generic/security
	insignia_type = /obj/item/mod/module/insignia/security
	additional_module = /obj/item/mod/module/criminalcapture

/obj/item/mod/control/pre_equipped/responsory/generic/engineer
	insignia_type = /obj/item/mod/module/insignia/engineer
	additional_module = /obj/item/mod/module/mister/atmos

/obj/item/mod/control/pre_equipped/responsory/generic/medic
	insignia_type = /obj/item/mod/module/insignia/medic
	additional_module = /obj/item/mod/module/quick_carry/advanced

/obj/item/mod/control/pre_equipped/responsory/generic/janitor
	insignia_type = /obj/item/mod/module/insignia/janitor
	additional_module = /obj/item/mod/module/mister/cleaner

/obj/item/mod/control/pre_equipped/responsory/generic/clown
	insignia_type = /obj/item/mod/module/insignia/clown
	additional_module = list(/obj/item/mod/module/bikehorn, /obj/item/mod/module/waddle)

/obj/item/mod/control/pre_equipped/responsory/generic/chaplain
	applied_skin = "inquisitory"
	insignia_type = /obj/item/mod/module/insignia/chaplain
	additional_module =  list(/obj/item/mod/module/injector, /obj/item/mod/module/anti_magic)

/obj/item/mod/control/pre_equipped/apocryphal/elite
	applied_modules = list(
		/obj/item/mod/module/storage/bluespace,
		/obj/item/mod/module/welding,
		/obj/item/mod/module/emp_shield/advanced,
		/obj/item/mod/module/magnetic_harness,
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/noslip,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/rad_protection,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/thermal_regulator,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/holster,
		/obj/item/mod/module/visor/night,
		/obj/item/mod/module/status_readout,
		/obj/item/mod/module/joint_torsion = 1,
	)
	default_pins = list(
		/obj/item/mod/module/jetpack/advanced,
		/obj/item/mod/module/power_kick,
		/obj/item/mod/module/magboot/advanced,
		/obj/item/mod/module/thermal_regulator,
		/obj/item/mod/module/dna_lock,
		/obj/item/mod/module/holster,
		/obj/item/mod/module/visor/night,
	)

/obj/item/storage/box/syndie_kit/imp_deathrattle/nanotrasen
	icon_state = "ntbox"
	illustration = "implant"

/obj/item/storage/belt/military/snack/pie
	name = "tactical pie rig"
	desc = "A set of snack-tical webbing worn by athletes of the Honk Co. VR sports division."

/obj/item/storage/belt/military/snack/pie/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 7
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21 // 7 * 3 = 21?
	atom_storage.set_holdable(list(
		/obj/item/food/pie/cream,
	))

/obj/item/storage/belt/military/snack/pie/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/food/pie/cream(src)

/obj/item/storage/box/medipens/advanced
	name = "box of advanced medipens"
	desc = "A box full of advanced MediPens."
	icon_state = "ntbox"
	illustration = "epipen"

/obj/item/storage/box/medipens/advanced/PopulateContents()
	new /obj/item/reagent_containers/hypospray/medipen/stimpack(src)
	new /obj/item/reagent_containers/hypospray/medipen/atropine(src)
	new /obj/item/reagent_containers/hypospray/medipen/blood_loss(src)
	new /obj/item/reagent_containers/hypospray/medipen/oxandrolone(src)
	new /obj/item/reagent_containers/hypospray/medipen/salacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/penacid(src)
	new /obj/item/reagent_containers/hypospray/medipen/salbutamol(src)

/obj/item/storage/box/x4
	name = "box of x-4 charges (WARNING)"
	desc = "A box full of x-4 charges."
	icon_state = "secbox"
	illustration = "firecracker"

/obj/item/storage/box/x4/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/c4/x4(src)

/obj/item/storage/box/c4
	name = "box of c-4 charges (WARNING)"
	desc = "A box full of c-4 charges."
	icon_state = "secbox"
	illustration = "firecracker"

/obj/item/storage/box/c4/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/c4(src)

/obj/vehicle/sealed/mecha/working/ripley/deathripley/real/elite
	desc = "OH SHIT IT'S THE DEATHSQUAD WE'RE ALL GONNA DIE. FOR REAL"
	operation_req_access = list(ACCESS_CENT_SPECOPS)
	internals_req_access = list(ACCESS_CENT_SPECOPS)
	fast_pressure_step_in = 1 //step_in while in low pressure conditions
	slow_pressure_step_in = 1.5 //step_in while in normal pressure conditions
	movedelay = 1.5
	max_integrity = 500
	encumbrance_gap = 5
	max_equip_by_category = list(
		MECHA_UTILITY = 3,
		MECHA_POWER = 2,
		MECHA_ARMOR = 3,
	)
	equip_by_category = list(
		MECHA_L_ARM = /obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/elite,
		MECHA_R_ARM = /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/admantium,
		MECHA_UTILITY = list(/obj/item/mecha_parts/mecha_equipment/ejector, /obj/item/mecha_parts/mecha_equipment/thrusters/ion),
		MECHA_POWER = list(),
		MECHA_ARMOR = list(/obj/item/mecha_parts/mecha_equipment/armor/antiproj_armor_booster, /obj/item/mecha_parts/mecha_equipment/armor/anticcw_armor_booster),
	)

/obj/vehicle/sealed/mecha/working/ripley/deathripley/real/elite/generate_actions()
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_eject)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_internals)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_lights)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_toggle_safeties)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/mech_view_stats)
	initialize_passenger_action_type(/datum/action/vehicle/sealed/mecha/strafe)

/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp/kill/elite
	name = "\improper KILL CLAMP"
	desc = "They won't know what clamped them! This time for real!"
	clamp_damage = 150
	killer_clamp = TRUE
	movedelay = 0

/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill/admantium
	name = "adamantine-tipped exosuit drill"
	desc = "Equipment for combat exosuits. This is an upgraded version of the drill that'll pierce the universe itself!"
	icon_state = "mecha_diamond_drill"
	drill_delay = 2
	force = 60
