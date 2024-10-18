/*
 *	Everything derived from the common cardboard box.
 *	Basically everything except the original is a kit (starts full).
 *
 *	Contains:
 *		Empty box, starter boxes (survival/engineer),
 *		Latex glove and sterile mask boxes,
 *		Syringe, beaker, dna injector boxes,
 *		Blanks, flashbangs, and EMP grenade boxes,
 *		Tracking and chemical implant boxes,
 *		Prescription glasses and drinking glass boxes,
 *		Condiment bottle and silly cup boxes,
 *		Donkpocket and monkeycube boxes,
 *		ID and security PDA cart boxes,
 *		Handcuff, mousetrap, and pillbottle boxes,
 *		Snap-pops and matchboxes,
 *		Replacement light boxes.
 *		Action Figure Boxes
 *		Various paper bags.
 *
 *		For syndicate call-ins see uplink_kits.dm
 */

/obj/item/storage/box
	name = "box"
	desc = "It's just an ordinary box."
	icon_state = "box"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	resistance_flags = FLAMMABLE
	drop_sound = 'sound/items/handling/cardboardbox_drop.ogg'
	pickup_sound =  'sound/items/handling/cardboardbox_pickup.ogg'
	var/foldable = /obj/item/stack/sheet/cardboard
	var/illustration = "writing"

/obj/item/storage/box/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_ICON)

/obj/item/storage/box/suicide_act(mob/living/carbon/user)
	var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
	if(myhead)
		user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src], and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
		myhead.dismember()
		myhead.forceMove(src)//force your enemies to kill themselves with your head collection box!
		playsound(user,pick('sound/misc/desceration-01.ogg','sound/misc/desceration-02.ogg','sound/misc/desceration-01.ogg') ,50, 1, -1)
		return BRUTELOSS
	user.visible_message(span_suicide("[user] attempts to put [user.p_their()] head into \the [src], but realizes [user.p_their()] has no head!"))
	return SHAME

/obj/item/storage/box/update_overlays()
	. = ..()
	if(illustration)
		. += illustration

/obj/item/storage/box/attack_self(mob/user, modifiers)
	..()
	if(modifiers?[RIGHT_CLICK]) // right click opens the storage
		return
	if(!foldable)
		return
	if(contents.len)
		to_chat(user, span_warning("You can't fold this box with items still inside!"))
		return
	if(!ispath(foldable))
		return

	to_chat(user, span_notice("You fold [src] flat."))
	var/obj/item/I = new foldable
	qdel(src)
	user.put_in_hands(I)

/obj/item/storage/box/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stack/packageWrap))
		return 0
	return ..()

//Mime spell boxes

/obj/item/storage/box/mime
	name = "invisible box"
	desc = "Unfortunately not large enough to trap the mime."
	foldable = null
	icon_state = "box"
	item_state = null
	alpha = 0

/obj/item/storage/box/mime/attack_hand(mob/user)
	..()
	if(user.mind.miming)
		alpha = 255

/obj/item/storage/box/mime/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	if (iscarbon(old_loc))
		alpha = 0
	..()

//Disk boxes

/obj/item/storage/box/disks
	name = "diskette box"
	illustration = "disk_kit"

/obj/item/storage/box/disks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/data(src)


/obj/item/storage/box/disks_plantgene
	name = "plant data disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_plantgene/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/plantgene(src)

/obj/item/storage/box/disks_nanite
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/nanite_program(src)

// Ordinary survival box
/obj/item/storage/box/survival
	var/mask_type = /obj/item/clothing/mask/breath
	var/internal_type = /obj/item/tank/internals/emergency_oxygen
	var/medipen_type = /obj/item/reagent_containers/autoinjector/medipen

/obj/item/storage/box/survival/PopulateContents()
	if(!isnull(mask_type))
		new mask_type(src)
	if(!isnull(internal_type))
		new internal_type(src)
	if(!isnull(medipen_type))
		new medipen_type(src)

	if(HAS_TRAIT(SSstation, STATION_TRAIT_PREMIUM_INTERNALS))
		new /obj/item/flashlight/flare(src)
		new /obj/item/radio/off(src)

/obj/item/storage/box/survival/radio/PopulateContents()
	..() // we want the survival stuff too.
	new /obj/item/radio/off(src)

/obj/item/storage/box/survival/proc/wardrobe_removal()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/box_owner = loc
	if(!length(box_owner.dna?.species?.survival_box_replacements))
		return
	var/list/survival_box_replacements_delete = box_owner.dna.species.survival_box_replacements["items_to_delete"]
	var/list/survival_box_replacements_add = box_owner.dna.species.survival_box_replacements["new_items"]
	var/list/items_to_delete = survival_box_replacements_delete?.Copy() || list()
	var/list/new_items = survival_box_replacements_add?.Copy() || list()
	box_owner.dna.species.survival_box_replacement(box_owner, src, items_to_delete, new_items)

/obj/item/storage/box/survival/mining
	mask_type = /obj/item/clothing/mask/gas/explorer

/obj/item/storage/box/survival/mining/PopulateContents()
	..()
	new /obj/item/crowbar/red(src)
	new /obj/item/gps/mining(src)

// Engineer survival box
/obj/item/storage/box/survival/engineer
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/engineer/radio/PopulateContents()
	..() // we want the regular items too.
	new /obj/item/radio/off(src)

// Syndie survival box
/obj/item/storage/box/survival/syndie
	mask_type = /obj/item/clothing/mask/gas/syndicate
	internal_type = /obj/item/tank/internals/emergency_oxygen/engi

/obj/item/storage/box/survival/syndie/PopulateContents()
	..()
	new /obj/item/extinguisher/mini(src)

// Security survival box
/obj/item/storage/box/survival/security
	mask_type = /obj/item/clothing/mask/gas/sechailer

/obj/item/storage/box/survival/security/radio/PopulateContents()
	..() // we want the regular stuff too
	new /obj/item/radio/off(src)

//Clown survival box
/obj/item/storage/box/survival/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	mask_type = null
	foldable = null

/obj/item/storage/box/survival/hug/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all.."))
	return (BRUTELOSS)

/obj/item/storage/box/survival/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, vary = TRUE, extrarange = -5)
	user.visible_message(span_notice("[user] hugs [src]."), span_notice("You hug [src]."))
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug)

//Mime survival box
/obj/item/storage/box/survival/hug/black
	icon_state = "hugbox_black"
	illustration = "heart_black"

/obj/item/storage/box/gloves
	name = "box of latex gloves"
	desc = "Contains sterile latex gloves."
	illustration = "latex"

/obj/item/storage/box/gloves/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/gloves/color/latex(src)

/obj/item/storage/box/masks
	name = "box of sterile masks"
	desc = "This box contains sterile medical masks."
	illustration = "sterile"

/obj/item/storage/box/masks/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/mask/surgical(src)

/obj/item/storage/box/syringes
	name = "box of syringes"
	desc = "A box full of syringes."
	illustration = "syringe"

/obj/item/storage/box/syringes/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe(src)

/obj/item/storage/box/syringes/variety
	name = "syringe variety box"

/obj/item/storage/box/syringes/variety/PopulateContents()
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/syringe/lethal(src)
	new /obj/item/reagent_containers/syringe/piercing(src)
	new /obj/item/reagent_containers/syringe/bluespace(src)

/obj/item/storage/box/medipens
	name = "box of medipens"
	desc = "A box full of epinephrine MediPens."
	illustration = "syringe"

/obj/item/storage/box/medipens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/autoinjector/medipen(src)

/obj/item/storage/box/medipens/utility
	name = "stimpack value kit"
	desc = "A box with several stimpack medipens for the economical miner."
	illustration = "syringe"

/obj/item/storage/box/medipens/utility/PopulateContents()
	..() // includes regular medipens.
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/autoinjector/medipen/stimpack(src)

/obj/item/storage/box/beakers
	name = "box of beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker( src )

/obj/item/storage/box/beakers/bluespace
	name = "box of bluespace beakers"
	illustration = "beaker"

/obj/item/storage/box/beakers/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/beakers/variety
	name = "beaker variety box"

/obj/item/storage/box/beakers/variety/PopulateContents()
	new /obj/item/reagent_containers/glass/beaker(src)
	new /obj/item/reagent_containers/glass/beaker/large(src)
	new /obj/item/reagent_containers/glass/beaker/plastic(src)
	new /obj/item/reagent_containers/glass/beaker/meta(src)
	new /obj/item/reagent_containers/glass/beaker/noreact(src)
	new /obj/item/reagent_containers/glass/beaker/bluespace(src)

/obj/item/storage/box/vials
	name = "box of vials"
	illustration = "vial"

/obj/item/storage/box/vials/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/vial(src)

/obj/item/storage/box/vials/bluespace
	name = "box of bluespace vials"

/obj/item/storage/box/vials/bluespace/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/glass/bottle/vial/bluespace(src)

/obj/item/storage/box/medsprays
	name = "box of medical sprayers"
	desc = "A box full of medical sprayers, with unscrewable caps and precision spray heads."

/obj/item/storage/box/medsprays/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/medspray( src )

/obj/item/storage/box/injectors
	name = "box of DNA injectors"
	desc = "This box contains injectors, it seems."

/obj/item/storage/box/injectors/PopulateContents()
	var/static/items_inside = list(
		/obj/item/dnainjector/h2m = 3,
		/obj/item/dnainjector/m2h = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/flashbangs
	name = "box of flashbangs (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness or deafness in repeated use.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/flashbangs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/flashbang(src)

/obj/item/storage/box/flashes
	name = "box of flashbulbs"
	desc = "<B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	icon_state = "secbox"
	illustration = "flashbang"

/obj/item/storage/box/flashes/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/assembly/flash/handheld(src)

/obj/item/storage/box/wall_flash
	name = "wall-mounted flash kit"
	desc = "This box contains everything necessary to build a wall-mounted flash. <B>WARNING: Flashes can cause serious eye damage, protective eyewear is required.</B>"
	illustration = "flashbang"

/obj/item/storage/box/wall_flash/PopulateContents()
	var/id = rand(1000, 9999)
	// FIXME what if this conflicts with an existing one?

	new /obj/item/wallframe/button(src)
	new /obj/item/electronics/airlock(src)
	var/obj/item/assembly/control/flasher/remote = new(src)
	remote.id = id
	var/obj/item/wallframe/flasher/frame = new(src)
	frame.id = id
	new /obj/item/assembly/flash/handheld(src)
	new /obj/item/screwdriver(src)


/obj/item/storage/box/teargas
	name = "box of tear gas grenades (WARNING)"
	desc = "<B>WARNING: These devices are extremely dangerous and can cause blindness and skin irritation.</B>"
	illustration = "flashbang"

/obj/item/storage/box/teargas/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/teargas(src)

/obj/item/storage/box/emps
	name = "box of emp grenades"
	desc = "A box with 5 emp grenades."
	illustration = "flashbang"

/obj/item/storage/box/emps/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/empgrenade(src)

/obj/item/storage/box/trackimp
	name = "boxed tracking implant kit"
	desc = "Box full of scum-bag tracking utensils."
	illustration = "implant"

/obj/item/storage/box/trackimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1,
		/obj/item/locator = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/minertracker
	name = "boxed tracking implant kit"
	desc = "For finding those who have died on the accursed lavaworld."
	illustration = "implant"

/obj/item/storage/box/minertracker/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/tracking = 4,
		/obj/item/implanter = 1,
		/obj/item/computer_hardware/hard_drive/portable/implant_tracker = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/chemimp
	name = "boxed chemical implant kit"
	desc = "Box of stuff used to implant chemicals."
	illustration = "implant"

/obj/item/storage/box/chemimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/chem = 5,
		/obj/item/implanter = 1,
		/obj/item/implantpad = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/exileimp
	name = "boxed exile implant kit"
	desc = "Box of exile implants. It has a picture of a clown being booted through the Gateway."
	illustration = "implant"

/obj/item/storage/box/exileimp/PopulateContents()
	var/static/items_inside = list(
		/obj/item/implantcase/exile = 5,
		/obj/item/implanter = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/bodybags
	name = "body bags"
	desc = "The label indicates that it contains body bags."
	illustration = "bodybags"

/obj/item/storage/box/bodybags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag(src)

/obj/item/storage/box/envirobags
	name = "environment protection bags"
	desc = "The label indicates that it contains environment protection bags."
	illustration = "bodybags"

/obj/item/storage/box/envirobags/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/bodybag/environmental(src)

/obj/item/storage/box/rxglasses
	name = "box of prescription glasses"
	desc = "This box contains nerd glasses."
	illustration = "glasses"

/obj/item/storage/box/rxglasses/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/glasses/regular(src)

/obj/item/storage/box/drinkingglasses
	name = "box of drinking glasses"
	desc = "It has a picture of drinking glasses on it."

/obj/item/storage/box/drinkingglasses/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/drinks/drinkingglass(src)

/obj/item/storage/box/condimentbottles
	name = "box of condiment bottles"
	desc = "It has a large ketchup smear on it."

/obj/item/storage/box/condimentbottles/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/food/condiment(src)

/obj/item/storage/box/cups
	name = "box of paper cups"
	desc = "It has pictures of paper cups on the front."

/obj/item/storage/box/cups/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/food/drinks/sillycup( src )

/obj/item/storage/box/donkpockets
	name = "box of donk-pockets"
	desc = "<B>Instructions:</B> <I>Heat in microwave.</I>"
	icon_state = "donkpocketbox"
	illustration=null
	var/donktype = /obj/item/reagent_containers/food/snacks/donkpocket

/obj/item/storage/box/donkpockets/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/donkpocket))

/obj/item/storage/box/donkpockets/PopulateContents()
	for(var/i in 1 to 6)
		new donktype(src)

/obj/item/storage/box/donkpockets/donkpocketspicy
	name = "box of spicy-flavoured donk-pockets"
	icon_state = "donkpocketboxspicy"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/spicy

/obj/item/storage/box/donkpockets/donkpocketteriyaki
	name = "box of teriyaki-flavoured donk-pockets"
	icon_state = "donkpocketboxteriyaki"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/teriyaki

/obj/item/storage/box/donkpockets/donkpocketpizza
	name = "box of pizza-flavoured donk-pockets"
	icon_state = "donkpocketboxpizza"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/pizza

/obj/item/storage/box/donkpockets/donkpocketgondola
	name = "box of gondola-flavoured donk-pockets"
	icon_state = "donkpocketboxgondola"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/gondola

/obj/item/storage/box/donkpockets/donkpocketberry
	name = "box of berry-flavoured donk-pockets"
	icon_state = "donkpocketboxberry"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/berry

/obj/item/storage/box/donkpockets/donkpockethonk
	name = "box of banana-flavoured donk-pockets"
	icon_state = "donkpocketboxbanana"
	donktype = /obj/item/reagent_containers/food/snacks/donkpocket/honk

/obj/item/storage/box/monkeycubes
	name = "monkey cube box"
	desc = "Drymate brand monkey cubes. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null
	var/cube_type = /obj/item/reagent_containers/food/snacks/monkeycube

/obj/item/storage/box/monkeycubes/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/monkeycubes/PopulateContents()
	for(var/i in 1 to 5)
		new cube_type(src)

/obj/item/storage/box/monkeycubes/syndicate
	desc = "Waffle Co. brand monkey cubes. Just add water and a dash of subterfuge!"
	cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/syndicate

/obj/item/storage/box/monkeycubes/syndicate/mice
	name = "mouse cube box"
	desc = "Waffle Co. brand mouse cubes. Just add water and a dash of subterfuge!"
	cube_type = /obj/item/reagent_containers/food/snacks/monkeycube/mouse/syndicate

/obj/item/storage/box/monkeycubes/syndicate/mice/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 24
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/monkeycubes/syndicate/mice/PopulateContents()
	for(var/i in 1 to 24)
		new /obj/item/reagent_containers/food/snacks/monkeycube/mouse/syndicate(src)

/obj/item/storage/box/gorillacubes
	name = "gorilla cube box"
	desc = "Waffle Co. brand gorilla cubes. Do not taunt."
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/gorillacubes/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 3
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/gorillacubes/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/monkeycube/gorilla(src)

/obj/item/storage/box/mixedcubes
	name = "mixed farm animal cube box"
	desc = "Farm Town's new cubes to make your farming dreams come true. Just add water!"
	icon_state = "monkeycubebox"
	illustration = null

/obj/item/storage/box/mixedcubes/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 6
	STR.can_hold = typecacheof(list(/obj/item/reagent_containers/food/snacks/monkeycube))

/obj/item/storage/box/mixedcubes/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/monkeycube/goat(src)
		new /obj/item/reagent_containers/food/snacks/monkeycube/sheep(src)
		new /obj/item/reagent_containers/food/snacks/monkeycube/chicken(src)
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/food/snacks/monkeycube/cow(src)

/obj/item/storage/box/ids
	name = "box of spare IDs"
	desc = "Has so many empty IDs."
	illustration = "id"

/obj/item/storage/box/ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id(src)

//Some spare PDAs in a box
/obj/item/storage/box/PDAs
	name = "spare PDAs"
	desc = "A box of spare PDA microcomputers."
	illustration = "pda"

/obj/item/storage/box/PDAs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/modular_computer/tablet/pda/preset(src)
/obj/item/storage/box/silver_ids
	name = "box of spare silver IDs"
	desc = "Shiny IDs for important people."
	illustration = "id"

/obj/item/storage/box/silver_ids/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/card/id/silver(src)

/obj/item/storage/box/prisoner
	name = "box of prisoner IDs"
	desc = "Take away their last shred of dignity, their name."
	illustration = "id"

/obj/item/storage/box/prisoner/PopulateContents()
	..()
	new /obj/item/card/id/prisoner/one(src)
	new /obj/item/card/id/prisoner/two(src)
	new /obj/item/card/id/prisoner/three(src)
	new /obj/item/card/id/prisoner/four(src)
	new /obj/item/card/id/prisoner/five(src)
	new /obj/item/card/id/prisoner/six(src)
	new /obj/item/card/id/prisoner/seven(src)

/obj/item/storage/box/firingpins
	name = "box of standard firing pins"
	desc = "A box full of standard firing pins, to allow newly-developed firearms to operate."
	illustration = "id"

/obj/item/storage/box/firingpins/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin(src)

/obj/item/storage/box/firingpins/syndicate
	name = "box of syndicate firing pins"
	desc = "A box full of Syndicate-issue secure firing pins, to allow newly-developed firearms to operate."
	illustration = "id"

/obj/item/storage/box/firingpins/syndicate/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin/implant/pindicate(src) //why did you fucks name it pindicate just name it syndicate its not funny at all

/obj/item/storage/box/secfiringpins
	name = "box of mindshield firing pins"
	desc = "A box full of mindshield firing pins, to allow newly-developed firearms to operate."
	illustration = "id"

/obj/item/storage/box/secfiringpins/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/firing_pin/implant/mindshield(src)

/obj/item/storage/box/lasertagpins
	name = "box of laser tag firing pins"
	desc = "A box full of laser tag firing pins, to allow newly-developed firearms to require wearing brightly coloured plastic armor before being able to be used."
	illustration = "id"

/obj/item/storage/box/lasertagpins/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/firing_pin/tag/red(src)
		new /obj/item/firing_pin/tag/blue(src)

/obj/item/storage/box/handcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/handcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs(src)

/obj/item/storage/box/zipties
	name = "box of spare zipties"
	desc = "A box full of zipties."
	icon_state = "secbox"
	illustration = "handcuff"

/obj/item/storage/box/zipties/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/restraints/handcuffs/cable/zipties(src)

/obj/item/storage/box/alienhandcuffs
	name = "box of spare handcuffs"
	desc = "A box full of handcuffs."
	icon_state = "alienbox"
	illustration = "handcuff"

/obj/item/storage/box/alienhandcuffs/PopulateContents()
	for(var/i in 1 to 7)
		new	/obj/item/restraints/handcuffs/alien(src)

/obj/item/storage/box/fakesyndiesuit
	name = "boxed space suit and helmet"
	desc = "A sleek, sturdy box used to hold replica spacesuits."
	icon_state = "syndiebox"

/obj/item/storage/box/fakesyndiesuit/PopulateContents()
	new /obj/item/clothing/head/syndicatefake(src)
	new /obj/item/clothing/suit/syndicatefake(src)

/obj/item/storage/box/mousetraps
	name = "box of Pest-B-Gon mousetraps"
	desc = span_alert("Keep out of reach of children.")
	illustration = "mousetrap"

/obj/item/storage/box/mousetraps/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/assembly/mousetrap(src)

/obj/item/storage/box/pillbottles
	name = "box of pill bottles"
	desc = "It has pictures of pill bottles on its front."
	illustration = "pillbox"

/obj/item/storage/box/pillbottles/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/storage/pill_bottle(src)

/obj/item/storage/box/snappops
	name = "snap pop box"
	desc = "Eight wrappers of fun! Ages 8 and up. Not suitable for children."
	icon = 'icons/obj/toy.dmi'
	icon_state = "spbox"

/obj/item/storage/box/snappops/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.set_holdable(list(/obj/item/toy/snappop))
	STR.max_items = 8

/obj/item/storage/box/snappops/PopulateContents()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_FILL_TYPE, /obj/item/toy/snappop)

/obj/item/storage/box/matches
	name = "matchbox"
	desc = "A small box of Almost But Not Quite Plasma Premium Matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	item_state = "zippo"
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT
	drop_sound = 'sound/items/handling/matchbox_drop.ogg'
	pickup_sound =  'sound/items/handling/matchbox_pickup.ogg'

/obj/item/storage/box/matches/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.set_holdable(list(/obj/item/match))

/obj/item/storage/box/matches/PopulateContents()
	SEND_SIGNAL(src, COMSIG_TRY_STORAGE_FILL_TYPE, /obj/item/match)

/obj/item/storage/box/matches/attackby(obj/item/match/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/match))
		W.matchignite()

/obj/item/storage/box/lights
	name = "box of replacement bulbs"
	icon = 'icons/obj/storage.dmi'
	illustration = "light"
	desc = "This box is shaped on the inside so that only light tubes and bulbs fit."
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	foldable = /obj/item/stack/sheet/cardboard //BubbleWrap

/obj/item/storage/box/lights/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 21
	STR.set_holdable(list(/obj/item/light/tube, /obj/item/light/bulb))
	STR.max_combined_w_class = 21
	STR.click_gather = FALSE //temp workaround to re-enable filling the light replacer with the box

/obj/item/storage/box/lights/bulbs/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/bulb(src)

/obj/item/storage/box/lights/tubes
	name = "box of replacement tubes"
	illustration = "lighttube"

/obj/item/storage/box/lights/tubes/PopulateContents()
	for(var/i in 1 to 21)
		new /obj/item/light/tube(src)

/obj/item/storage/box/lights/mixed
	name = "box of replacement lights"
	illustration = "lightmixed"

/obj/item/storage/box/lights/mixed/PopulateContents()
	for(var/i in 1 to 14)
		new /obj/item/light/tube(src)
	for(var/i in 1 to 7)
		new /obj/item/light/bulb(src)


/obj/item/storage/box/deputy
	name = "box of deputy armbands"
	desc = "A box of old Nanotrasen deputy armbands, they stopped serving a purpose ever since the deputization of crew was outlawed."

/obj/item/storage/box/deputy/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/clothing/accessory/armband/deputy(src)

/obj/item/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches."
	illustration = "flashbang"

/obj/item/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/smart_metal_foam
	name = "box of smart metal foam grenades"
	desc = "Used to rapidly seal hull breaches. This variety conforms to the walls of its area."
	illustration = "flashbang"

/obj/item/storage/box/smart_metal_foam/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/smart_metal_foam(src)

/obj/item/storage/box/hug
	name = "box of hugs"
	desc = "A special box for sensitive people."
	icon_state = "hugbox"
	illustration = "heart"
	foldable = null

/obj/item/storage/box/hug/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] clamps the box of hugs on [user.p_their()] jugular! Guess it wasn't such a hugbox after all.."))
	return (BRUTELOSS)

/obj/item/storage/box/hug/attack_self(mob/user)
	..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(loc, "rustle", 50, 1, -5)
	user.visible_message(span_notice("[user] hugs \the [src]."),span_notice("You hug \the [src]."))
	SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "hug", /datum/mood_event/hug)

/obj/item/storage/box/hug/black
	icon_state = "hugbox_black"
	illustration = "heart_black"

/////clown box & honkbot assembly
/obj/item/storage/box/clown
	name = "clown box"
	desc = "A colorful cardboard box for the clown"
	illustration = "clown"

/obj/item/storage/box/clown/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/bodypart/l_arm/robot)) || (istype(I, /obj/item/bodypart/r_arm/robot)))
		if(contents.len) //prevent accidently deleting contents
			to_chat(user, span_warning("You need to empty [src] out first!"))
			return
		if(!user.temporarilyRemoveItemFromInventory(I))
			return
		qdel(I)
		to_chat(user, span_notice("You add some wheels to the [src]! You've got a honkbot assembly now! Honk!"))
		var/obj/item/bot_assembly/honkbot/A = new
		qdel(src)
		user.put_in_hands(A)
	else
		return ..()

//////
/obj/item/storage/box/hug/medical/PopulateContents()
	new /obj/item/stack/medical/bruise_pack(src)
	new /obj/item/stack/medical/ointment(src)
	new /obj/item/reagent_containers/autoinjector/medipen(src)

/obj/item/storage/box/rubbershot
	name = "box of rubber shots"
	desc = "A box full of rubber shots designed for shotguns. The box itself is designed for holding any kind of shotgun shell."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/rubbershot/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/ammo_casing/shotgun))

/obj/item/storage/box/rubbershot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/rubbershot(src)

/obj/item/storage/box/lethalshot
	name = "box of lethal shotgun shots"
	desc = "A box full of lethal shots designed for shotguns. The box itself is designed for holding any kind of shotgun shell."
	icon_state = "lethalshot_box"
	illustration = null

/obj/item/storage/box/lethalshot/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/ammo_casing/shotgun))

/obj/item/storage/box/lethalshot/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/buckshot(src)

/obj/item/storage/box/breacherslug
	name = "box of breaching shotgun shells"
	desc = "A box full of breaching slugs designed for rapid entry. The box itself is designed for holding any kind of shotgun shell."
	icon_state = "breachershot_box"
	illustration = null

/obj/item/storage/box/breacherslug/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/ammo_casing/shotgun))

/obj/item/storage/box/breacherslug/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/breacher(src)

/obj/item/storage/box/beanbag
	name = "box of beanbags"
	desc = "A box full of beanbag shells designed for shotguns. The box itself is designed for holding any kind of shotgun shell."
	icon_state = "rubbershot_box"
	illustration = null

/obj/item/storage/box/beanbag/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	STR.set_holdable(list(/obj/item/ammo_casing/shotgun))

/obj/item/storage/box/beanbag/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/beanbag(src)

/obj/item/storage/box/actionfigure
	name = "box of action figures"
	desc = "The latest set of collectable action figures."
	icon_state = "box"

/obj/item/storage/box/actionfigure/PopulateContents()
	for(var/i in 1 to 4)
		var/randomFigure = pick(subtypesof(/obj/item/toy/figure))
		new randomFigure(src)

#define NODESIGN "None"
#define NANOTRASEN "NanotrasenStandard"
#define SYNDI "SyndiSnacks"
#define HEART "Heart"
#define SMILEY "SmileyFace"

/obj/item/storage/box/papersack
	name = "paper sack"
	desc = "A sack neatly crafted out of paper."
	icon_state = "paperbag_None"
	item_state = "paperbag_None"
	resistance_flags = FLAMMABLE
	foldable = null
	var/design = NODESIGN

/obj/item/storage/box/papersack/update_icon_state()
	. = ..()
	if(contents.len == 0)
		icon_state = "[item_state]"
	else
		icon_state = "[item_state]_closed"

/obj/item/storage/box/papersack/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/pen))
		//if a pen is used on the sack, dialogue to change its design appears
		if(contents.len)
			to_chat(user, span_warning("You can't modify [src] with items still inside!"))
			return
		var/list/designs = list(NODESIGN, NANOTRASEN, SYNDI, HEART, SMILEY, "Cancel")
		var/switchDesign = input("Select a Design:", "Paper Sack Design", designs[1]) in designs
		if(get_dist(usr, src) > 1)
			to_chat(usr, span_warning("You have moved too far away!"))
			return
		var/choice = designs.Find(switchDesign)
		if(design == designs[choice] || designs[choice] == "Cancel")
			return 0
		to_chat(usr, span_notice("You make some modifications to [src] using your pen."))
		design = designs[choice]
		icon_state = "paperbag_[design]"
		item_state = "paperbag_[design]"
		switch(designs[choice])
			if(NODESIGN)
				desc = "A sack neatly crafted out of paper."
			if(NANOTRASEN)
				desc = "A standard Nanotrasen paper lunch sack for loyal employees on the go."
			if(SYNDI)
				desc = "The design on this paper sack is a remnant of the notorious 'SyndieSnacks' program."
			if(HEART)
				desc = "A paper sack with a heart etched onto the side."
			if(SMILEY)
				desc = "A paper sack with a crude smile etched onto the side."
		return 0
	else if(W.is_sharp())
		if(!contents.len)
			if(item_state == "paperbag_None")
				user.show_message(span_notice("You cut eyeholes into [src]."), MSG_VISUAL)
				new /obj/item/clothing/head/papersack(user.loc)
				qdel(src)
				return 0
			else if(item_state == "paperbag_SmileyFace")
				user.show_message(span_notice("You cut eyeholes into [src] and modify the design."), MSG_VISUAL)
				new /obj/item/clothing/head/papersack/smiley(user.loc)
				qdel(src)
				return 0
	return ..()

#undef NODESIGN
#undef NANOTRASEN
#undef SYNDI
#undef HEART
#undef SMILEY

/obj/item/storage/box/ingredients //This box is for the randomly chosen version the chef spawns with, it shouldn't actually exist.
	name = "ingredients box"
	illustration = "fruit"
	var/theme_name

/obj/item/storage/box/ingredients/Initialize(mapload)
	. = ..()
	if(theme_name)
		name = "[name] ([theme_name])"
		desc = "A box containing supplementary ingredients for the aspiring chef. The box's theme is '[theme_name]'."
		item_state = "syringe_kit"

/obj/item/storage/box/ingredients/wildcard
	theme_name = "wildcard"

/obj/item/storage/box/ingredients/wildcard/PopulateContents()
	for(var/i in 1 to 7)
		var/randomFood = pick(/obj/item/reagent_containers/food/snacks/grown/chili,
							  /obj/item/reagent_containers/food/snacks/grown/tomato,
							  /obj/item/reagent_containers/food/snacks/grown/carrot,
							  /obj/item/reagent_containers/food/snacks/grown/potato,
							  /obj/item/reagent_containers/food/snacks/grown/potato/sweet,
							  /obj/item/reagent_containers/food/snacks/grown/apple,
							  /obj/item/reagent_containers/food/snacks/chocolatebar,
							  /obj/item/reagent_containers/food/snacks/grown/cherries,
							  /obj/item/reagent_containers/food/snacks/grown/banana,
							  /obj/item/reagent_containers/food/snacks/grown/cabbage,
							  /obj/item/reagent_containers/food/snacks/grown/soybeans,
							  /obj/item/reagent_containers/food/snacks/grown/corn,
							  /obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet,
							  /obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
							  /obj/item/reagent_containers/food/snacks/grown/cucumber)
		new randomFood(src)

/obj/item/storage/box/ingredients/fiesta
	theme_name = "fiesta"

/obj/item/storage/box/ingredients/fiesta/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/tortilla(src)
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/corn(src)
		new /obj/item/reagent_containers/food/snacks/grown/soybeans(src)
		new /obj/item/reagent_containers/food/snacks/grown/chili(src)

/obj/item/storage/box/ingredients/italian
	theme_name = "italian"

/obj/item/storage/box/ingredients/italian/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/grown/tomato(src)
		new /obj/item/reagent_containers/food/snacks/raw_meatball(src) //YOGS - bigotry rule
	new /obj/item/reagent_containers/food/drinks/bottle/wine(src)

/obj/item/storage/box/ingredients/vegetarian
	theme_name = "vegetarian"

/obj/item/storage/box/ingredients/vegetarian/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/carrot(src)
	new /obj/item/reagent_containers/food/snacks/grown/eggplant(src)
	new /obj/item/reagent_containers/food/snacks/grown/potato(src)
	new /obj/item/reagent_containers/food/snacks/grown/apple(src)
	new /obj/item/reagent_containers/food/snacks/grown/corn(src)
	new /obj/item/reagent_containers/food/snacks/grown/tomato(src)

/obj/item/storage/box/ingredients/american
	theme_name = "american"

/obj/item/storage/box/ingredients/american/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/potato(src)
		new /obj/item/reagent_containers/food/snacks/grown/tomato(src)
		new /obj/item/reagent_containers/food/snacks/grown/corn(src)
	new /obj/item/reagent_containers/food/snacks/raw_meatball(src) //YOGS - bigotry rule

/obj/item/storage/box/ingredients/fruity
	theme_name = "fruity"

/obj/item/storage/box/ingredients/fruity/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/apple(src)
		new /obj/item/reagent_containers/food/snacks/grown/citrus/orange(src)
	new /obj/item/reagent_containers/food/snacks/grown/citrus/lemon(src)
	new /obj/item/reagent_containers/food/snacks/grown/citrus/lime(src)
	new /obj/item/reagent_containers/food/snacks/grown/watermelon(src)

/obj/item/storage/box/ingredients/sweets
	theme_name = "sweets"

/obj/item/storage/box/ingredients/sweets/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/cherries(src)
		new /obj/item/reagent_containers/food/snacks/grown/banana(src)
	new /obj/item/reagent_containers/food/snacks/chocolatebar(src)
	new /obj/item/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/reagent_containers/food/snacks/grown/apple(src)

/obj/item/storage/box/ingredients/delights
	theme_name = "delights"

/obj/item/storage/box/ingredients/delights/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/grown/potato/sweet(src)
		new /obj/item/reagent_containers/food/snacks/grown/bluecherries(src)
	new /obj/item/reagent_containers/food/snacks/grown/vanillapod(src)
	new /obj/item/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/reagent_containers/food/snacks/grown/berries(src)

/obj/item/storage/box/ingredients/grains
	theme_name = "grains"

/obj/item/storage/box/ingredients/grains/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/grown/oat(src)
	new /obj/item/reagent_containers/food/snacks/grown/wheat(src)
	new /obj/item/reagent_containers/food/snacks/grown/cocoapod(src)
	new /obj/item/reagent_containers/honeycomb(src)
	new /obj/item/seeds/poppy(src)

/obj/item/storage/box/ingredients/carnivore
	theme_name = "carnivore"

/obj/item/storage/box/ingredients/carnivore/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/meat/slab/bear(src)
	new /obj/item/reagent_containers/food/snacks/meat/slab/spider(src)
	new /obj/item/reagent_containers/food/snacks/spidereggs(src)
	new /obj/item/reagent_containers/food/snacks/carpmeat(src)
	new /obj/item/reagent_containers/food/snacks/meat/slab/xeno(src)
	new /obj/item/reagent_containers/food/snacks/meat/slab/corgi(src)
	new /obj/item/reagent_containers/food/snacks/raw_meatball(src) //YOGS - bigotry rule

/obj/item/storage/box/ingredients/exotic
	theme_name = "exotic"

/obj/item/storage/box/ingredients/exotic/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/reagent_containers/food/snacks/carpmeat(src)
		new /obj/item/reagent_containers/food/snacks/grown/soybeans(src)
		new /obj/item/reagent_containers/food/snacks/grown/cabbage(src)
	new /obj/item/reagent_containers/food/snacks/grown/chili(src)

/obj/item/storage/box/ingredients/seafood
	theme_name = "seafood"

/obj/item/storage/box/ingredients/seafood/PopulateContents()
	new /obj/item/reagent_containers/food/snacks/grown/citrus/lemon(src)
	for(var/i in 1 to 6)
		var/randomFood = pick(/obj/item/reagent_containers/food/snacks/carpmeat,
							  /obj/item/reagent_containers/food/snacks/dolphinmeat,
							  /obj/item/reagent_containers/food/snacks/fish/tuna,
							  /obj/item/reagent_containers/food/snacks/fish/shrimp)
		new randomFood(src)

/obj/item/storage/box/cheese
	name = "box of advanced cheese bacteria"

/obj/item/storage/box/cheese/PopulateContents()
	new /obj/item/reagent_containers/food/condiment/mesophilic(src)
	new /obj/item/reagent_containers/food/condiment/thermophilic(src)
	new /obj/item/reagent_containers/food/condiment/pcandidum(src)
	new /obj/item/reagent_containers/food/condiment/proqueforti(src)

/obj/item/storage/box/emptysandbags
	name = "box of empty sandbags"

/obj/item/storage/box/emptysandbags/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/emptysandbag(src)

/obj/item/storage/box/rndboards
	name = "\proper the liberator's legacy"
	desc = "A box containing a gift for worthy golems."

/obj/item/storage/box/rndboards/PopulateContents()
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole(src)

/obj/item/storage/box/rndboards/miner
	name = "\proper Morokha Heavy Industries Research and Development Kit"
	desc = "A box containing the essential circuit boards for research and development. Materials, stock parts, and intelligence not included."

/obj/item/storage/box/rndboards/miner/PopulateContents()
	new /obj/item/circuitboard/machine/autolathe(src)
	new /obj/item/circuitboard/machine/protolathe(src)
	new /obj/item/circuitboard/machine/destructive_analyzer(src)
	new /obj/item/circuitboard/machine/circuit_imprinter(src)
	new /obj/item/circuitboard/computer/rdconsole/ruin(src)

/obj/item/storage/box/silver_sulf
	name = "box of silver sulfadiazine patches"
	desc = "Contains patches used to treat burns."

/obj/item/storage/box/silver_sulf/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/patch/silver_sulf(src)

/obj/item/storage/box/fountainpens
	name = "box of fountain pens"

/obj/item/storage/box/fountainpens/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/pen/fountain(src)

/obj/item/storage/box/holy_grenades
	name = "box of holy hand grenades"
	desc = "Contains several grenades used to rapidly purge heresy."
	illustration = "flashbang"

/obj/item/storage/box/holy_grenades/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/holy(src)

/obj/item/storage/box/stockparts/basic //for ruins where it's a bad idea to give access to an autolathe/protolathe, but still want to make stock parts accessible
	name = "box of stock parts"
	desc = "Contains a variety of basic stock parts."

/obj/item/storage/box/stockparts/basic/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor = 3,
		/obj/item/stock_parts/scanning_module = 3,
		/obj/item/stock_parts/manipulator = 3,
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/stock_parts/matter_bin = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/stockparts/deluxe
	name = "box of deluxe stock parts"
	desc = "Contains a variety of deluxe stock parts."
	icon_state = "syndiebox"

/obj/item/storage/box/stockparts/deluxe/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stock_parts/capacitor/quadratic = 3,
		/obj/item/stock_parts/scanning_module/triphasic = 3,
		/obj/item/stock_parts/manipulator/femto = 3,
		/obj/item/stock_parts/micro_laser/quadultra = 3,
		/obj/item/stock_parts/matter_bin/bluespace = 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/dishdrive
	name = "DIY Dish Drive Kit"
	desc = "Contains everything you need to build your own Dish Drive!"
	custom_premium_price = 200

/obj/item/storage/box/dishdrive/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/metal/five = 1,
		/obj/item/stack/cable_coil/random/five = 1,
		/obj/item/circuitboard/machine/dish_drive = 1,
		/obj/item/stack/sheet/glass = 1,
		/obj/item/stock_parts/manipulator = 1,
		/obj/item/stock_parts/matter_bin = 2,
		/obj/item/screwdriver = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/materials
	name = "Materials Box"
	desc = "Contains most of what you would need"

/obj/item/storage/box/materials/PopulateContents()
	var/static/items_inside = list(
		/obj/item/stack/sheet/metal/fifty = 2,
		/obj/item/stack/sheet/glass/fifty = 2,
		/obj/item/stack/rods/fifty = 2,
		/obj/item/stack/sheet/plasteel/fifty = 2,
		/obj/item/stack/sheet/plastic/fifty = 2,
		/obj/item/stack/sheet/plastitaniumglass/fifty = 2,
		/obj/item/stack/sheet/titaniumglass/fifty = 2,
		/obj/item/stack/sheet/plasmaglass/fifty = 2,
		/obj/item/stack/sheet/rglass/fifty = 2,
		/obj/item/stack/sheet/mineral/plastitanium/fifty = 1,
		/obj/item/stack/sheet/mineral/wood/fifty = 1,
		/obj/item/stack/sheet/mineral/titanium/fifty = 1,
		/obj/item/stack/sheet/mineral/uranium/fifty = 1,
		/obj/item/stack/sheet/mineral/diamond/fifty = 1,
		/obj/item/stack/sheet/mineral/plasma/fifty = 1,
		/obj/item/stack/sheet/mineral/gold/fifty = 1,
		/obj/item/stack/sheet/mineral/silver/fifty = 1,
		/obj/item/stack/sheet/mineral/bananium/fifty = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/materials/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_combined_w_class = 200
	STR.max_items = 30
	STR.max_w_class = WEIGHT_CLASS_GIGANTIC

/obj/item/storage/box/coffeepack
	icon_state = "arabica_beans"
	name = "arabica beans"
	desc = "A bag containing fresh, dry coffee arabica beans. Ethically sourced and packaged by Waffle Corp."
	illustration = null
	icon = 'icons/obj/food/containers.dmi'
	var/beantype = /obj/item/reagent_containers/food/snacks/grown/coffee

/obj/item/storage/box/coffeepack/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 5
	STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/grown/coffee))

/obj/item/storage/box/coffeepack/PopulateContents()
	var/static/items_inside = list(
		beantype = 5
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/box/coffeepack/robusta
	icon_state = "robusta_beans"
	name = "robusta beans"
	desc = "A bag containing fresh, dry coffee robusta beans. Ethically sourced and packaged by Waffle Corp."
	beantype = /obj/item/reagent_containers/food/snacks/grown/coffee/robusta

/obj/item/storage/box/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	foldable = null

/obj/item/storage/box/rollingpapers/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 10
	STR.set_holdable(list(/obj/item/rollingpaper))

/obj/item/storage/box/rollingpapers/PopulateContents()
	for(var/i in 1 to 10)
		new /obj/item/rollingpaper(src)

/obj/item/storage/box/rollingpapers/update_overlays()
	. = ..()
	if(!contents.len)
		. += "[icon_state]_empty"

#define CARTON_PLAIN "plain ice cream"
#define CARTON_VANILLA "vanilla ice cream"
#define CARTON_CHOCOLATE "chocolate ice cream"
#define CARTON_STRAWBERRY "strawberry ice cream"
#define CARTON_BLUE "blue ice cream"
#define CARTON_LEMON_SORBET "lemon sorbet"
#define CARTON_CARAMEL "caramel ice cream"
#define CARTON_BANANA "banana ice cream"
#define CARTON_ORANGE_CREAMSICLE "orange creamsicle"
#define CARTON_PEACH "peach ice cream"
#define CARTON_CHERRY_CHOCOLATE "cherry chocolate ice cream"
#define CARTON_MEAT "meat lover's ice cream"
#define BOX_CAKE "cake cone"
#define BOX_CHOCOLATE "chocolate cone"

/obj/item/storage/box/ice_cream_carton
	icon_state = "ice_cream"
	icon = 'icons/obj/food/containers.dmi'
	name = "Big Top plain ice cream carton"
	desc = "A classic ice cream brand; this carton contains plain ice cream."

	//What flavor will be inside the carton
	var/item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop
	//String for extra examine
	var/container_type = "carton"
	//String for ice cream vat
	var/contents_type = "ice cream"


/obj/item/storage/box/ice_cream_carton/Initialize(mapload)
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 7
	//Check if it is a scoop carton or cone box
	if(!istype(src, /obj/item/storage/box/ice_cream_carton/cone))
		STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/ice_cream_scoop))
	else
		STR.set_holdable(list(/obj/item/reagent_containers/food/snacks/ice_cream_cone))

/obj/item/storage/box/ice_cream_carton/PopulateContents()
	for(var/i in 1 to 7)
		new item_flavor(src)

/obj/item/storage/box/ice_cream_carton/attackby(obj/item/A, mob/user, params)
	//Allow for name and desc to be changed with pen
	if(istype(A, /obj/item/pen))
		//Check if it is a scoop carton or cone box
		if(!istype(src, /obj/item/storage/box/ice_cream_carton/cone))
			var/choice = input(usr, "Choose which flavor to change to", "Changing Container Flavor") as null|anything in list(CARTON_PLAIN, CARTON_VANILLA, CARTON_CHOCOLATE, CARTON_STRAWBERRY, CARTON_BLUE, CARTON_LEMON_SORBET, CARTON_CARAMEL, CARTON_BANANA, CARTON_ORANGE_CREAMSICLE, CARTON_PEACH, CARTON_CHERRY_CHOCOLATE, CARTON_MEAT)
			if(choice != null)
				name = "Big Top [choice] carton"
				desc = "A classic ice cream brand; this carton contains [choice]."
		else
			var/choice = input(usr, "Choose which flavor to change to", "Changing Container Flavor") as null|anything in list(BOX_CAKE, BOX_CHOCOLATE)
			if(choice != null)
				name = "Big Top [choice] box"
				desc = "A classic ice cream brand; this box contains [choice]s."
		return
	..()

/obj/item/storage/box/ice_cream_carton/examine(mob/user)
	. = ..()
	. += span_notice("You can change the [container_type]'s flavor with a <b>Pen<b>.")
	if(length(contents) == 0)
		. += span_warning("This [container_type] is <b>EMPTY<b>!!") //PANIC!!

/obj/item/storage/box/ice_cream_carton/update_overlays()
	. = ..()
	//How much ice cream is in the carton
	var/inventory_count = length(contents)
	//What icon to use for the overlay
	var/carton_overlay = null

	if(inventory_count == 0)
		return .
	else
		carton_overlay = "_lid"

	var/mutable_appearance/ice_cream_overlay = mutable_appearance(icon, "[icon_state][carton_overlay]")
	. += ice_cream_overlay

/obj/item/storage/box/ice_cream_carton/vanilla
	name = "Big Top vanilla ice cream carton"
	desc = "A classic ice cream brand; this carton contains vanilla ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/vanilla

/obj/item/storage/box/ice_cream_carton/chocolate
	name = "Big Top chocolate ice cream carton"
	desc = "A classic ice cream brand; this carton contains chocolate ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/chocolate

/obj/item/storage/box/ice_cream_carton/strawberry
	name = "Big Top strawberry ice cream carton"
	desc = "A classic ice cream brand; this carton contains strawberry ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/strawberry

/obj/item/storage/box/ice_cream_carton/blue
	name = "Big Top blue ice cream carton"
	desc = "A classic ice cream brand; this carton contains blue ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/blue

/obj/item/storage/box/ice_cream_carton/lemon_sorbet
	name = "Big Top lemon sorbet carton"
	desc = "A classic ice cream brand; this carton contains lemon sorbet."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/lemon_sorbet

/obj/item/storage/box/ice_cream_carton/caramel
	name = "Big Top caramel ice cream carton"
	desc = "A classic ice cream brand; this carton contains caramel ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/caramel

/obj/item/storage/box/ice_cream_carton/banana
	name = "Big Top banana ice cream carton"
	desc = "A classic ice cream brand; this carton contains banana ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/banana

/obj/item/storage/box/ice_cream_carton/orange_creamsicle
	name = "Big Top orange creamsicle carton"
	desc = "A classic ice cream brand; this carton contains orange creamsicle."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/orange_creamsicle

/obj/item/storage/box/ice_cream_carton/peach
	name = "Big Top peach ice cream carton"
	desc = "A classic ice cream brand; this carton contains peach ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/peach

/obj/item/storage/box/ice_cream_carton/cherry_chocolate
	name = "Big Top cherry chocolate ice cream carton"
	desc = "A classic ice cream brand; this carton contains cherry chocolate ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/cherry_chocolate

/obj/item/storage/box/ice_cream_carton/meat
	name = "Big Top meat lover's ice cream carton"
	desc = "A classic ice cream brand; this carton contains meat lover's ice cream."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_scoop/meat

/obj/item/storage/box/ice_cream_carton/cone
	icon_state = "cone_box"
	name = "Big Top cake cone box"
	desc = "A classic ice cream brand; this box contains cake cones."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_cone/cake
	container_type = "box"
	contents_type = "cones"

/obj/item/storage/box/ice_cream_carton/cone/chocolate
	name = "Big Top chocolate cone box"
	desc = "A classic ice cream brand; this box contains chocolate cones."
	item_flavor = /obj/item/reagent_containers/food/snacks/ice_cream_cone/chocolate

#undef CARTON_PLAIN
#undef CARTON_VANILLA
#undef CARTON_CHOCOLATE
#undef CARTON_STRAWBERRY
#undef CARTON_BLUE
#undef CARTON_LEMON_SORBET
#undef CARTON_CARAMEL
#undef CARTON_BANANA
#undef CARTON_ORANGE_CREAMSICLE
#undef CARTON_PEACH
#undef CARTON_CHERRY_CHOCOLATE
#undef CARTON_MEAT
#undef BOX_CAKE
#undef BOX_CHOCOLATE
