/* First aid storage
 * Contains:
 *		First Aid Kits
 * 		Pill Bottles
 *		Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/firstaid
	name = "first-aid kit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "firstaid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	var/empty = FALSE

/obj/item/storage/firstaid/regular
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/regular/empty
	empty = TRUE

/obj/item/storage/firstaid/regular/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/firstaid/regular/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/autoinjector/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/emergency
	icon_state = "medbriefcase"
	name = "emergency first-aid kit"
	desc = "A very simple first aid kit meant to secure and stabilize serious wounds for later treatment."

/obj/item/storage/firstaid/emergency/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/healthanalyzer/wound = 1,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/suture/emergency = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/reagent_containers/autoinjector/medipen/ekit = 2,)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/medical
	name = "medical aid kit"
	icon_state = "firstaid_surgery"
	item_state = "firstaid"
	desc = "A high capacity aid kit for doctors, full of medical supplies and basic surgical equipment"

/obj/item/storage/firstaid/medical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12
	STR.max_combined_w_class = 24
	STR.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/lighter,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/autoinjector,
		/obj/item/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves/,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/storage/bag/chemistry,
		/obj/item/storage/bag/bio,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/holosign_creator/firstaid,
		/obj/item/book/manual/wiki/medicine
		))

/obj/item/storage/firstaid/medical/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze/twelve = 1,
		/obj/item/stack/medical/suture = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/autoinjector/medipen/ekit = 1,
		/obj/item/healthanalyzer = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/book/manual/wiki/medicine = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/ancient
	icon_state = "firstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/firstaid/ancient/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/medical/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment= 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/fire
	name = "burn treatment kit"
	desc = "A specialized medical kit for when the toxins lab <i>-spontaneously-</i> burns down."
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/storage/firstaid/fire/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins rubbing \the [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to start a fire!"))
	return FIRELOSS

/obj/item/storage/firstaid/fire/Initialize(mapload)
	. = ..()
	icon_state = pick("ointment","firefirstaid")

/obj/item/storage/firstaid/fire/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/silver_sulf = 3,
		/obj/item/reagent_containers/pill/oxandrolone = 2,
		/obj/item/reagent_containers/autoinjector/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/toxin
	name = "toxin treatment kit"
	desc = "Used to treat toxic blood content and radiation poisoning."
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/storage/firstaid/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS

/obj/item/storage/firstaid/toxin/Initialize(mapload)
	. = ..()
	icon_state = pick("antitoxin","antitoxfirstaid","antitoxfirstaid2","antitoxfirstaid3")

/obj/item/storage/firstaid/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/charcoal = 4,
		/obj/item/storage/pill_bottle/charcoal = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/o2
	name = "oxygen deprivation treatment kit"
	desc = "A box full of oxygen goodies."
	icon_state = "o2"
	item_state = "firstaid-o2"

/obj/item/storage/firstaid/o2/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/firstaid/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/syringe/perfluorodecalin = 5,
		/obj/item/reagent_containers/autoinjector/medipen = 1,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/brute
	name = "brute trauma treatment kit"
	desc = "A first aid kit for when you get toolboxed."
	icon_state = "brute"
	item_state = "firstaid-brute"

/obj/item/storage/firstaid/brute/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins beating [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/firstaid/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/styptic = 4,
		/obj/item/stack/medical/gauze = 2,
		/obj/item/healthanalyzer = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/advanced
	name = "advanced first aid kit"
	desc = "An advanced kit to help deal with advanced wounds."
	icon_state = "radfirstaid"
	item_state = "firstaid-rad"
	custom_premium_price = 600

/obj/item/storage/firstaid/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 3,
		/obj/item/reagent_containers/autoinjector/medipen/atropine = 2,
		/obj/item/stack/medical/gauze = 1,
		/obj/item/storage/pill_bottle/penacid = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/tactical
	name = "combat medical kit"
	desc = "I hope you've got insurance."
	icon_state = "bezerk"
	item_state = "firstaid-bezerk"

/obj/item/storage/firstaid/tactical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/firstaid/tactical/PopulateContents()
	if(empty)
		return
	new /obj/item/stack/medical/gauze(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/hypospray/combat(src)
	new /obj/item/reagent_containers/pill/patch/styptic(src)
	new /obj/item/reagent_containers/pill/patch/styptic(src)
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	new /obj/item/clothing/glasses/hud/health/night(src)

//medibot assembly
/obj/item/storage/firstaid/attackby(obj/item/bodypart/S, mob/user, params)
	if((!istype(S, /obj/item/bodypart/l_arm/robot)) && (!istype(S, /obj/item/bodypart/r_arm/robot)))
		return ..()

	//Making a medibot!
	if(contents.len >= 1)
		to_chat(user, span_warning("You need to empty [src] out first!"))
		return

	var/obj/item/bot_assembly/medbot/A = new
	if(istype(src, /obj/item/storage/firstaid/fire))
		A.skin = "ointment"
	else if(istype(src, /obj/item/storage/firstaid/toxin))
		A.skin = "tox"
	else if(istype(src, /obj/item/storage/firstaid/o2))
		A.skin = "o2"
	else if(istype(src, /obj/item/storage/firstaid/brute))
		A.skin = "brute"
	user.put_in_hands(A)
	to_chat(user, span_notice("You add [S] to [src]."))
	A.robot_arm = S.type
	A.firstaid = type
	qdel(S)
	qdel(src)

/*
 * Hypospray Kits
 */
/obj/item/storage/firstaid/hypospray
	name = "hypospray kit"
	desc = "A basic kit containing a hypospray for applying reagents to patients."
	icon_state = "hypobasic"
	item_state = "firstaid"
	custom_premium_price = 100
	var/stored_hypo

/obj/item/storage/firstaid/hypospray/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/glass/beaker,
		/obj/item/reagent_containers/glass/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/autoinjector,
		/obj/item/hypospray,
		/obj/item/gun/syringe/syndicate,
		/obj/item/storage/lockbox/vialbox
		))

/obj/item/storage/firstaid/hypospray/PopulateContents()
	if(empty || !ispath(stored_hypo))
		return 
	new stored_hypo(src)

/obj/item/storage/firstaid/hypospray/hypo
	stored_hypo = /obj/item/hypospray

/obj/item/storage/firstaid/hypospray/vial
	name = "hypospray kit"
	desc = "A kit containing a hypospray and empty vials for applying reagents to patients."
	stored_hypo = /obj/item/hypospray
	custom_premium_price = 200

/obj/item/storage/firstaid/hypospray/vial/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial = 6
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/basic
	name = "basic hypospray vial kit"
	desc = "A hypospray vial kit containing vials for most common situations."
	custom_premium_price = 100

/obj/item/storage/firstaid/hypospray/basic/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/libital = 1,
		/obj/item/reagent_containers/glass/bottle/vial/aiuri = 1,
		/obj/item/reagent_containers/glass/bottle/vial/charcoal = 1,
		/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin = 1,
		/obj/item/reagent_containers/glass/bottle/vial/epi = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/basic/hypo
	name = "basic hypospray kit"
	desc = "A hypospray kit containing a hypospray and vials for most common situations."
	stored_hypo = /obj/item/hypospray
	custom_premium_price = 300

/obj/item/storage/firstaid/hypospray/brute
	name = "brute hypospray vial kit"
	desc = "A hypospray kit containing hypospray vials to treat most blunt trauma."
	icon_state = "hypobrute"
	item_state = "firstaid-brute"

/obj/item/storage/firstaid/hypospray/brute/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/libital = 2,
		/obj/item/reagent_containers/glass/bottle/vial/styptic = 2,
		/obj/item/reagent_containers/glass/bottle/vial/sal_acid = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/burn
	name = "burn hypospray vial kit"
	desc = "A hypospray kit containing hypospray vials to treat most burns."
	icon_state = "hypoburn"
	item_state = "firstaid-ointment"

/obj/item/storage/firstaid/hypospray/burn/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/aiuri = 2,
		/obj/item/reagent_containers/glass/bottle/vial/silver_sulfadiazine = 2,
		/obj/item/reagent_containers/glass/bottle/vial/oxandrolone = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/toxin
	name = "toxin hypospray vial kit"
	desc = "A hypospray kit containing hypospray vials to cure toxic damage."
	icon_state = "hypotoxin"
	item_state = "firstaid-toxin"

/obj/item/storage/firstaid/hypospray/toxin/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/charcoal = 4,
		/obj/item/reagent_containers/glass/bottle/vial/calomel = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/oxygen
	name = "oxygen hypospray vial kit"
	desc = "A hypospray vial kit containing a vials to treat suffication."
	icon_state = "hypooxygen"
	item_state = "firstaid-o2"

/obj/item/storage/firstaid/hypospray/oxygen/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/perfluorodecalin = 2,
		/obj/item/reagent_containers/glass/bottle/vial/epi = 2,
		/obj/item/reagent_containers/glass/bottle/vial/salbutamol = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)


/obj/item/storage/firstaid/hypospray/advanced
	name = "advanced hypospray vial kit"
	desc = "A hypospray kit containing vials for most situations."
	icon_state = "hyporad"
	item_state = "firstaid-rad"
	custom_premium_price = 300

/obj/item/storage/firstaid/hypospray/advanced/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/sal_acid = 1,
		/obj/item/reagent_containers/glass/bottle/vial/oxandrolone = 1,
		/obj/item/reagent_containers/glass/bottle/vial/calomel = 1,
		/obj/item/reagent_containers/glass/bottle/vial/salbutamol = 1,
		/obj/item/reagent_containers/glass/bottle/vial/epi = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/advanced/hypo
	name = "advanced hypospray kit"
	desc = "An advanced kit containing a hypospray and vials for most situations."
	stored_hypo = /obj/item/hypospray
	custom_premium_price = 500

/obj/item/storage/firstaid/hypospray/deluxe
	name = "deluxe hypospray kit"
	desc = "An advanced kit containing a deluxe hypospray and large vials for most ailments."
	icon_state = "hypodeluxe"
	stored_hypo = /obj/item/hypospray/deluxe

/obj/item/storage/firstaid/hypospray/deluxe/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/storage/lockbox/vialbox/hypo_deluxe = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/firstaid/hypospray/deluxe/cmo
	name = "\improper CMO's deluxe hypospray kit"
	desc = "An advanced kit containing a deluxe hypospray and large vials for most ailments. This one contains the CMO's hypospray."
	icon_state = "hypodeluxe"
	stored_hypo = /obj/item/hypospray/deluxe/cmo

/obj/item/storage/firstaid/hypospray/qmc
	name = "\improper QMC hypospray kit"
	desc = "An advanced kit containing a QMC hypospray and medical supplies for most situations found on lavaland."
	icon_state = "hypoqmc"
	stored_hypo = /obj/item/hypospray/qmc

/obj/item/storage/firstaid/hypospray/qmc/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/libital = 1,
		/obj/item/reagent_containers/glass/bottle/vial/aiuri = 1,
		/obj/item/reagent_containers/glass/bottle/vial/lavaland = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)


/obj/item/storage/firstaid/hypospray/paramedic
	name = "first aid autosyringe kit"
	desc = "A simple first aid kit containing an autosyringe and vials with chemicals used to secure and stabilize serious wounds for later treatment."
	stored_hypo = /obj/item/hypospray/syringe

/obj/item/storage/firstaid/hypospray/paramedic/PopulateContents()
	if(empty)
		return
	..()
	var/static/items_inside = list(
		/obj/item/reagent_containers/glass/bottle/vial/epi = 2,
		/obj/item/reagent_containers/glass/bottle/vial/coagulant = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/mesh = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)


/obj/item/storage/firstaid/hypospray/syndicate
	name = "combat hypospray kit"
	desc = "An advanced kit containing a combat hypospray and a wide variety of vials containing \"perfectly legal chemicals\" to treat combatants."
	icon_state = "hypobezerk"
	item_state = "firstaid-bezerk"

/obj/item/storage/firstaid/hypospray/syndicate/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/hypospray/combat = 1,
		/obj/item/reagent_containers/glass/bottle/vial/large/combat = 2,
		/obj/item/reagent_containers/glass/bottle/vial/large/omnizine = 1,
		/obj/item/reagent_containers/glass/bottle/vial/large/morphine = 1,
		/obj/item/reagent_containers/glass/bottle/vial/large/epi = 1,
		/obj/item/healthanalyzer = 1
		)
	generate_items_inside(items_inside,src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/obj/item/storage/pill_bottle/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.allow_quick_gather = TRUE
	STR.click_gather = TRUE
	STR.set_holdable(list(/obj/item/reagent_containers/pill, /obj/item/dice))

/obj/item/storage/pill_bottle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/storage/pill_bottle/charcoal
	name = "bottle of charcoal pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/charcoal/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/charcoal(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/epinephrine(src)

/obj/item/storage/pill_bottle/mutadone
	name = "bottle of mutadone pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/mutadone/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mutadone/five(src)

/obj/item/storage/pill_bottle/mannitol
	name = "bottle of mannitol pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/mannitol/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mannitol(src)

/obj/item/storage/pill_bottle/mannitol/braintumor //For the brain tumor quirk
	desc = "Generously supplied by your Nanotrasen health insurance to treat that pesky tumor in your brain."

/obj/item/storage/pill_bottle/mannitol/braintumor/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/mannitol/braintumor(src)

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/stimulant(src)

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	new /obj/item/reagent_containers/pill/patch/silver_sulf(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/patch/styptic(src)

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aranesp(src)

/obj/item/storage/pill_bottle/psicodine
	name = "bottle of psicodine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/psicodine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psicodine(src)

/obj/item/storage/pill_bottle/happiness
	name = "happiness pill bottle"
	desc = "The label is long gone, in its place an 'H' written with a marker."

/obj/item/storage/pill_bottle/happiness/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happiness(src)

/obj/item/storage/pill_bottle/penacid
	name = "bottle of pentetic acid pills"
	desc = "Contains pills to expunge radiation and toxins."

/obj/item/storage/pill_bottle/penacid/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/penacid(src)


/obj/item/storage/pill_bottle/neurine
	name = "bottle of neurine pills"
	desc = "Contains pills to treat non-severe mental traumas."

/obj/item/storage/pill_bottle/neurine/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/neurine(src)

/obj/item/storage/pill_bottle/floorpill
	name = "bottle of floorpills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/floorpill/Initialize()
	. = ..()
	var/obj/item/reagent_containers/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/floorpill/PopulateContents()
	for(var/i in 1 to rand(1,7))
		new /obj/item/reagent_containers/pill/floorpill(src)

/obj/item/storage/pill_bottle/floorpill/full/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/floorpill(src)

/obj/item/storage/pill_bottle/bica
	name = "bottle of bicaridine pills"
	desc = "Contains pills to treat bruises."

/obj/item/storage/pill_bottle/bica/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/bica(src)

/obj/item/storage/pill_bottle/kelo
	name = "bottle of kelotane pills"
	desc = "Contains pills to treat burns."

/obj/item/storage/pill_bottle/kelo/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/kelo(src)

/obj/item/storage/pill_bottle/libi
	name = "bottle of libital pills"
	desc = "Contains pills to treat bruises."

/obj/item/storage/pill_bottle/libi/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/libi(src)

/obj/item/storage/pill_bottle/aiur
	name = "bottle of aiuri pills"
	desc = "Contains pills to treat burns."

/obj/item/storage/pill_bottle/aiur/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/aiur(src)
