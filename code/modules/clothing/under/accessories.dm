/obj/item/clothing/accessory //Ties moved to neck slot items, but as there are still things like medals and armbands, this accessory system is being kept as-is
	name = "Accessory"
	desc = "Something has gone wrong!"
	icon = 'icons/obj/clothing/accessories.dmi'
	icon_state = "plasma"
	item_state = ""	//no inhands
	worn_icon = 'icons/mob/clothing/accessories.dmi'
	slot_flags = 0
	w_class = WEIGHT_CLASS_SMALL
	var/above_suit = FALSE
	var/above_suit_adjustable = FALSE
	var/minimize_when_attached = TRUE // TRUE if shown as a small icon in corner, FALSE if overlayed
	var/datum/component/storage/detached_pockets
	var/attachment_slot = CHEST

/obj/item/clothing/accessory/proc/can_attach_accessory(obj/item/clothing/U, mob/user)
	if(!attachment_slot || (U && U.body_parts_covered & attachment_slot))
		return TRUE
	if(user)
		to_chat(user, span_warning("There doesn't seem to be anywhere to put [src]..."))

/obj/item/clothing/accessory/proc/attach(obj/item/clothing/under/U, user)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		if(SEND_SIGNAL(U, COMSIG_CONTAINS_STORAGE))
			return FALSE
		U.TakeComponent(storage)
		detached_pockets = storage
	U.attached_accessory = src
	forceMove(U)
	layer = FLOAT_LAYER
	plane = FLOAT_PLANE
	if(minimize_when_attached)
		transform *= 0.5	//halve the size so it doesn't overpower the under
		pixel_x += 8
		pixel_y -= 8
	U.add_overlay(src)

	if (islist(U.armor) || isnull(U.armor)) 										// This proc can run before /obj/Initialize has run for U and src,
		U.armor = getArmor(arglist(U.armor))	// we have to check that the armor list has been transformed into a datum before we try to call a proc on it
																					// This is safe to do as /obj/Initialize only handles setting up the datum if actually needed.
	if (islist(armor) || isnull(armor))
		armor = getArmor(arglist(armor))

	U.armor = U.armor.attachArmor(armor)

	if(isliving(user))
		on_clothing_equip(U, user)

	return TRUE

/obj/item/clothing/accessory/proc/detach(obj/item/clothing/under/U, user)
	if(detached_pockets && detached_pockets.parent == U)
		TakeComponent(detached_pockets)

	U.armor = U.armor.detachArmor(armor)

	if(isliving(user))
		on_clothing_dropped(U, user)

	if(minimize_when_attached)
		transform *= 2
		pixel_x -= 8
		pixel_y += 8
	layer = initial(layer)
	SET_PLANE_IMPLICIT(src, initial(plane))
	U.cut_overlays()
	U.attached_accessory = null
	U.accessory_overlay = null

/obj/item/clothing/accessory/proc/on_clothing_equip(obj/item/clothing/U, user)
	return

/obj/item/clothing/accessory/proc/on_clothing_dropped(obj/item/clothing/U, user)
	return

/obj/item/clothing/accessory/AltClick(mob/user)
	if(istype(user) && user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		if(above_suit_adjustable)
			above_suit = !above_suit
			to_chat(user, "[src] will be worn [above_suit ? "above" : "below"] your suit.")

/obj/item/clothing/accessory/examine(mob/user)
	. = ..()
	. += span_notice("\The [src] can be attached to a uniform. Alt-click to remove it once attached.")
	if(initial(above_suit))
		. += span_notice("\The [src] can be worn above or below your suit. Alt-click to toggle.")

/obj/item/clothing/accessory/waistcoat
	name = "waistcoat"
	desc = "For some classy, murderous fun."
	icon_state = "waistcoat"
	item_state = "waistcoat"
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/maidapron
	name = "maid apron"
	desc = "The best part of a maid costume."
	icon_state = "maidapron"
	item_state = "maidapron"
	lefthand_file = 'icons/mob/inhands/clothing/suits_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/clothing/suits_righthand.dmi'
	minimize_when_attached = FALSE
	attachment_slot = null

/obj/item/clothing/accessory/sharkhoodie
	name = "shark hoodie"
	desc = "Standard apparel of shark enthusiasts everywhere."
	icon_state = "shark_hoodie"
	item_state = "shark_hoodie"
	minimize_when_attached = FALSE
	attachment_slot = null


//////////
//Medals//
//////////

/obj/item/clothing/accessory/medal
	name = "bronze medal"
	desc = "A bronze medal."
	icon_state = "bronze"
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT)
	resistance_flags = FIRE_PROOF
	/// Sprite used for medalbox
	var/medaltype = "medal"
	/// Has this been use for a commendation?
	var/commendation_message
	/// Who was first given this medal
	var/awarded_to
	/// Who gave out this medal
	var/awarder

/obj/item/clothing/accessory/medal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pinnable_accessory, on_pre_pin = CALLBACK(src, PROC_REF(provide_reason)))

/obj/item/clothing/accessory/medal/update_desc(updates)
	. = ..()
	if(commendation_message && awarded_to && awarder)
		desc += span_info("<br>The inscription reads: [commendation_message] - Awarded to [awarded_to] by [awarder]")

/// Input a reason for the medal for the round end screen
/obj/item/clothing/accessory/medal/proc/provide_reason(mob/living/carbon/human/distinguished, mob/user)
	if(!commendation_message)
		commendation_message = tgui_input_text(user, "Reason for this commendation? It will be recorded by Nanotrasen.", "Commendation", max_length = 140)
	return !!commendation_message

/obj/item/clothing/accessory/medal/attach(obj/item/clothing/under/attach_to, mob/living/attacher)
	var/mob/living/distinguished = attach_to.loc
	if(isnull(attacher) || !istype(distinguished) || distinguished == attacher || awarded_to)
		// You can't be awarded by nothing, you can't award yourself, and you can't be awarded someone else's medal
		return ..()

	awarder = attacher.real_name
	awarded_to = distinguished.real_name

	update_appearance(UPDATE_DESC)
	distinguished.log_message("was given the following commendation by <b>[key_name(attacher)]</b>: [commendation_message]", LOG_GAME, color = "green")
	message_admins("<b>[key_name_admin(distinguished)]</b> was given the following commendation by <b>[key_name_admin(attacher)]</b>: [commendation_message]")
	GLOB.commendations += "[awarder] awarded <b>[awarded_to]</b> the <span class='medaltext'>[name]</span>! \n- [commendation_message]"
	SSblackbox.record_feedback("associative", "commendation", 1, list("commender" = "[awarder]", "commendee" = "[awarded_to]", "medal" = "[src]", "reason" = commendation_message))

	return ..()

/obj/item/clothing/accessory/medal/conduct
	name = "distinguished conduct medal"
	desc = "A bronze medal awarded for distinguished conduct. Whilst a great honor, this is the most basic award given by Nanotrasen. It is often awarded by a captain to a member of his crew."

/obj/item/clothing/accessory/medal/bronze_heart
	name = "bronze heart medal"
	desc = "A bronze heart-shaped medal awarded for sacrifice. It is often awarded posthumously or for severe injury in the line of duty."
	icon_state = "bronze_heart"

/obj/item/clothing/accessory/medal/ribbon
	name = "ribbon"
	desc = "A ribbon"
	icon_state = "cargo"

/obj/item/clothing/accessory/medal/ribbon/cargo
	name = "\"cargo tech of the shift\" award"
	desc = "An award bestowed only upon those cargotechs who have exhibited devotion to their duty in keeping with the highest traditions of Cargonia."

/obj/item/clothing/accessory/medal/silver
	name = "silver medal"
	desc = "A silver medal."
	icon_state = "silver"
	medaltype = "medal-silver"
	materials = list(/datum/material/silver=1000)

/obj/item/clothing/accessory/medal/silver/valor
	name = "medal of valor"
	desc = "A silver medal awarded for acts of exceptional valor."

/obj/item/clothing/accessory/medal/silver/security
	name = "robust security award"
	desc = "An award for distinguished combat and sacrifice in defence of Nanotrasen's commercial interests. Often awarded to security staff."

/obj/item/clothing/accessory/medal/silver/excellence
	name = "head of personnel award for outstanding achievement in the field of excellence"
	desc = "Nanotrasen's dictionary defines excellence as \"the quality or condition of being excellent\". This is awarded to those rare crewmembers who fit that definition."

/obj/item/clothing/accessory/medal/silver/medical
	name = "award for medical excellence"
	desc = "An award for an exceptional application of medical service. Can be awarded to any crewmember who provides an outstanding benefit to the station through their medical knowledge."

/obj/item/clothing/accessory/medal/silver/engineering
	name = "medal of engineering integrity"
	desc = "A medal made of silver portraying the bearer as a crewmember who demonstrates notable engineering prowess. The merits of those who earn this award can range from atmospheric wizardry to simply rebuilding half the station after a toxins explosion."

/obj/item/clothing/accessory/medal/gold
	name = "gold medal"
	desc = "A prestigious golden medal."
	icon_state = "gold"
	medaltype = "medal-gold"
	materials = list(/datum/material/gold=1000)

/obj/item/clothing/accessory/medal/gold/captain
	name = "medal of captaincy"
	desc = "A golden medal awarded exclusively to those promoted to the rank of captain. It signifies the codified responsibilities of a captain to Nanotrasen, and their undisputable authority over their crew."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	cryo_preserve = TRUE

/obj/item/clothing/accessory/medal/gold/heroism
	name = "medal of exceptional heroism"
	desc = "An extremely rare golden medal awarded only by CentCom. To receive such a medal is the highest honor and as such, very few exist. This medal is almost never awarded to anybody but commanders."

/obj/item/clothing/accessory/medal/plasma
	name = "plasma medal"
	desc = "An eccentric medal made of plasma."
	icon_state = "plasma"
	medaltype = "medal-plasma"
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = -10, ACID = 0) //It's made of plasma. Of course it's flammable.
	materials = list(/datum/material/plasma=1000)

/obj/item/clothing/accessory/medal/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		atmos_spawn_air("plasma=20;TEMP=[exposed_temperature]")
		visible_message(span_danger(" \The [src] bursts into flame!"),span_userdanger("Your [src] bursts into flame!"))
		qdel(src)

/obj/item/clothing/accessory/medal/plasma/nobel_science
	name = "nobel sciences award"
	desc = "A plasma medal which represents significant contributions to the field of science or robotics."


////////////
//Armbands//
////////////

/obj/item/clothing/accessory/armband
	name = "red armband"
	desc = "An fancy red armband!"
	icon_state = "redband"
	attachment_slot = null
	above_suit = TRUE
	above_suit_adjustable = TRUE

/obj/item/clothing/accessory/armband/deputy
	name = "security deputy armband"
	desc = "A worn out armband, once worn by personnel authorized to act as a deputy of station security. No longer serves a purpose since Nanotrasen outlawed deputization."

/obj/item/clothing/accessory/armband/cargo
	name = "cargo bay guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is brown."
	icon_state = "cargoband"

/obj/item/clothing/accessory/armband/engine
	name = "engineering guard armband"
	desc = "An armband, worn by security members to display which department they're assigned to. This one is orange with a reflective strip!"
	icon_state = "engieband"

/obj/item/clothing/accessory/armband/science
	name = "science guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is purple."
	icon_state = "rndband"

/obj/item/clothing/accessory/armband/service
	name = "service guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is green."
	icon_state = "serviceband"

/obj/item/clothing/accessory/armband/hydro
	name = "hydroponics guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is green and blue."
	icon_state = "hydroband"

/obj/item/clothing/accessory/armband/med
	name = "medical guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is white."
	icon_state = "medband"

/obj/item/clothing/accessory/armband/medblue
	name = "medical guard armband"
	desc = "An armband, worn by engineers and security members to display which department they're assigned to. This one is white and blue."
	icon_state = "medblueband"


//////////////
//OBJECTION!//
//////////////

/obj/item/clothing/accessory/lawyers_badge
	name = "attorney's badge"
	desc = "Fills you with the conviction of JUSTICE. Lawyers tend to want to show it to everyone they meet."
	icon_state = "lawyerbadge"

/obj/item/clothing/accessory/lawyers_badge/attack_self(mob/user)
	if(prob(1))
		user.say("The testimony contradicts the evidence!", forced = "attorney's badge")
	user.visible_message("[user] shows [user.p_their()] attorney's badge.", span_notice("You show your attorney's badge."))

/obj/item/clothing/accessory/lawyers_badge/on_clothing_equip(obj/item/clothing/U, user)
	var/mob/living/L = user
	if(L)
		L.AddElement(/datum/element/speech_bubble_override, BUBBLE_LAWYER)

/obj/item/clothing/accessory/lawyers_badge/on_clothing_dropped(obj/item/clothing/U, user)
	var/mob/living/L = user
	if(L)
		L.RemoveElement(/datum/element/speech_bubble_override, BUBBLE_LAWYER)

////////////////
//HA HA! NERD!//
////////////////

/obj/item/clothing/accessory/pocketprotector
	name = "pocket protector"
	desc = "Can protect your clothing from ink stains, but you'll look like a nerd if you're using one."
	icon_state = "pocketprotector"
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/pocketprotector

/obj/item/clothing/accessory/pocketprotector/full/Initialize(mapload)
	. = ..()
	new /obj/item/pen/red(src)
	new /obj/item/pen(src)
	new /obj/item/pen/blue(src)

/obj/item/clothing/accessory/pocketprotector/cosmetology/Initialize(mapload)
	. = ..()
	for(var/i in 1 to 3)
		new /obj/item/lipstick/random(src)


////////////////
//OONGA BOONGA//
////////////////

/obj/item/clothing/accessory/talisman
	name = "bone talisman"
	desc = "A hunter's talisman, some say the old gods smile on those who wear it."
	icon_state = "talisman"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, RAD = 5, FIRE = 0, ACID = 25)
	attachment_slot = null
	above_suit = TRUE
	above_suit_adjustable = TRUE

/obj/item/clothing/accessory/skullcodpiece
	name = "skull codpiece"
	desc = "A skull shaped ornament, intended to protect the important things in life."
	icon_state = "skull"
	above_suit = TRUE
	above_suit_adjustable = TRUE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, RAD = 5, FIRE = 0, ACID = 25)
	attachment_slot = GROIN

/obj/item/clothing/accessory/skilt
	name = "Sinew Skirt"
	desc = "For the last time. IT'S A KILT not a skirt."
	icon_state = "skilt"
	above_suit_adjustable = TRUE
	minimize_when_attached = FALSE
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, RAD = 5, FIRE = 0, ACID = 25)
	attachment_slot = GROIN

/obj/item/clothing/accessory/resinband
	name = "resin armband"
	desc = "A smooth amber colored armband made of solid resin, generally worn by tribal aristocracy."
	icon_state = "resinband"
	armor = list(MELEE = 5, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 20, BIO = 20, RAD = 5, FIRE = 0, ACID = 25)
	attachment_slot = null
	above_suit = TRUE
	above_suit_adjustable = TRUE



/////////////
//Poppy Pin//
/////////////

/obj/item/clothing/accessory/poppypin
	name = "Poppy pins"
	desc = "A poppy pin that is meant to commemorate the fallen soldiers in wars. It symbolizes the gunshot that killed the soldiers."
	icon_state = "poppy"


//////////////
//Ooh shiny!//
//////////////

/obj/item/clothing/accessory/sing_necklace
	name = "singularity shard necklace"
	desc = "The gem mounted inside seems to glow with an unearthly, pulsing light. It is bitter cold to the touch."
	icon_state = "sing_necklace"
	above_suit = TRUE
	above_suit_adjustable = TRUE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = -5, FIRE = 0, ACID = 0) //It IS radioactive after all. Watch me get yelled at for powergaming because I'm making this my """donator""" item - Mqiib
	attachment_slot = null
	light_power = 2
	light_range = 1.4 //Same as cosmic bedsheet
	light_color = "#9E1F1F" //dim red
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // Good luck destroying a singularity

//////////////
///Dog Tags///
//////////////

/obj/item/clothing/accessory/dogtags
	name = "Dogtags"
	desc = "Two small metal tags, connected with a thin piece of chain that hold important health infomration. And everything needed for a tombstone..."
	icon_state = "dogtags"
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF // its metal
	attachment_slot = null
	above_suit = TRUE
	above_suit_adjustable = TRUE
	

//////////////
//Pride Pins//
//////////////

/obj/item/clothing/accessory/pride
	name = "pride pin"
	desc = "A Nanotrasen Diversity & Inclusion Center-sponsored holographic pin to show off your sexuality, reminding the crew of their unwavering commitment to equity, diversity, and inclusion!"
	icon_state = "pride"
	above_suit_adjustable = TRUE
	var/static/list/pride_reskins = list(
		"Rainbow Pride" = list(
			"icon" = "pride_rainbow",
			"info" = "A colorful striped rainbow that represents diversity and Gay Pride, pride in same-gender love!"),
		"Bisexual Pride" = list(
			"icon" = "pride_bi",
			"info" = "Purple, dark pink and dark blue stripes that represent Bisexual Pride, pride in loving both binary genders!"),
		"Pansexual Pride" = list(
			"icon" = "pride_pan",
			"info" = "Yellow, pink and blue stripes that represent Pansexual Pride, pride in loving regardless of sex or gender!"),
		"Asexual Pride"	= list(
			"icon" = "pride_ace",
			"info" = "Black, grey, white and purple stripes that represent Asexual Pride, pride in nonsexual love!"),
		"Non-binary Pride" = list(
			"icon" = "pride_enby",
			"info" = "Yellow, white, purple and black stripes that represent Non-Binary pride, pride in identifying as a Non-Binary gender!"),
		"Transgender Pride"= list(
			"icon" = "pride_trans",
			"info" = "Blue, pink and white stripes that represent Transgender pride, pride in transitioning genders!"),
		"Intersex Pride" = list(
			"icon" = "pride_intersex",
			"info" = "A yellow background with a disctint purple circle that represents Intersex pride, pride in atypical sex characteristics!"),
		"Lesbian Pride" = list(
			"icon" = "pride_lesbian",
			"info" = "Orange and pink shaded stripes that represent Lesbian pride, pride in same-gender love among women!"),
		"Gay Pride" = list(
			"icon" = "pride_gay",
			"info" = "Navy and turquoise shaded stripes that represent Gay pride, pride in same-gender love among men!"),
		//meme pins under this
		"Ian Pride" = list( //we love ian
			"icon" = "pride_ian",
			"info" = "A orange corgi, pride in the HoP's beloved pet!"),
		"Void Pride" = list( //darkness antag
			"icon" = "pride",
			"info" = "Nothing, pride in NOTHING!!!"),
		"Suspicious Pride Pin" = list( //syndicate
			"icon" = "pride_suspicious",
			"info" = "A black S on a red banner, pride in chaos!"),
		"Grey Pride" = list( //assistants
			"icon" = "pride_grey",
			"info" = "A robust toolbox over a grey background, pride in what is stationwide!"),
		"Command Pride" = list(
			"icon" = "pride_command",
			"info" = "A blue background with an elaborate white trim, pride in your superiors!")
		)

/obj/item/clothing/accessory/pride/attack_self(mob/user)
	. = ..()
	var/list/radial_menu = list()
	for(var/pin_type in pride_reskins)
		var/datum/radial_menu_choice/choice = new()
		choice.image = icon(icon, pride_reskins[pin_type]["icon"])
		choice.info = pride_reskins[pin_type]["info"]
		radial_menu[pin_type] =  choice
	var/Pin = show_radial_menu(user, user, radial_menu, tooltips = TRUE)
	icon_state = Pin ? pride_reskins[Pin]["icon"] : initial(icon_state)
