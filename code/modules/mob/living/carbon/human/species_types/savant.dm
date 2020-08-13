/**
  * # Savant
  *
  * A race of small blue people who wear big suits to fit in with general society. Pronounced Sa'vän(t)
  *
  * Basically, the Savants wear these suits so they can do standard ss13 jobs. The suited savants are /datum/species/savant/suit.
  * Meanwhile, the 'naked' ones are /datum/species/savant. They are slower, weaker, and have tiny arms and legs.
  * Roundstart Savants are the suited variety. See [/datum/species/savant/suit]
  * Author: Jcat
  *
  */
/// How much damage the Savant can take before the suit fails and they become a /datum/species/savant
#define SUITFAILHEALTH 50
/datum/species/savant //sa'vän(t). This is the suitless one. Not for roundstart use.
	id = "savant"
	name = "Savant"
	default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race
	limbs_id = "savant"
	sexes = FALSE
	damage_overlay_type = ""
	offset_features = list(OFFSET_GLOVES = list(0,-6),OFFSET_GLASSES = list(0,-8), OFFSET_EARS = list(0,-8), OFFSET_FACEMASK = list(0,-8), OFFSET_HEAD = list(0,-8), OFFSET_FACE = list(0,-8), OFFSET_BACK = list(0,-8))
	hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.

	use_skintones = FALSE	// does it use skintones or not? (spoiler alert this is only used by humans)
	exotic_bloodtype = "S" //If your race uses a non standard bloodtype (A+, O-, AB-, etc)
	meat = /obj/item/reagent_containers/food/snacks/meat/slab //What the species drops on gibbing
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | RAW | MEAT
	toxic_food = TOXIC
	no_equip = list(SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE, SLOT_BELT, SLOT_NECK)	// slots the race can't equip stuff to
	nojumpsuit = TRUE
	say_mod = "trills"	// affects the speech message

	speedmod = 1	//Small legs!
	armor = -20	// overall defense for the race... or less defense, if it's negative.
	punchdamagelow = 1       //lowest possible punch damage. if this is set to 0, punches will always miss
	punchdamagehigh = 5      //highest possible punch damage
	species_traits = list(AGENDER, NO_UNDERWEAR, NOEYESPRITES)
	// generic traits tied to having the species
	inherent_traits = list(TRAIT_SMALL_HANDS, TRAIT_SHORT)
	attack_verb = "punch"	// punch-specific attack verb
	sound/attack_sound = 'sound/weapons/punch1.ogg'
	sound/miss_sound = 'sound/weapons/punchmiss.ogg'
	mutanttongue = /obj/item/organ/tongue/savant

	override_float = FALSE
	///This is the 'spell' that savants get so they can craft a new suit.
	var/datum/action/innate/savantSuitUp/SuitUpPower

	changesource_flags = MIRROR_BADMIN

/datum/action/innate/savantSuitUp
	name = "Construct Suit"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "jaunt"
	icon_icon = 'icons/mob/actions/actions_spells.dmi'

/**
  * This is the Activate() proc for the suitUp.
  *
  * If you are already a savant/suit, you unsuit, taking a lot of damage in the process.
  * Otherwise, if you find 30 metal in one sheet stack nearby, you can make yourself a suit!
  * Both processes take a bit of time.
  *
  */
/datum/action/innate/savantSuitUp/Activate()
	var/mob/living/carbon/human/H = owner
	var/metalNeeded = 30
	if(isSuitedSavant(H))
		to_chat(H, "<span class='warning'>You begin to take off your suit...this might hurt! Are you sure you want to?</span>")
		playsound(H, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		if(do_after(owner, 40, TRUE, owner))
			H.set_species(/datum/species/savant)
			H.update_body_parts()
			explosion(H, 0, 0, 0, adminlog = FALSE)
			var/sfh = SUITFAILHEALTH
			H.adjustBruteLoss(sfh*0.5, 0)
			H.adjustFireLoss(sfh*0.5, 0)
			var/obj/item/stack/sheet/metal/M = new(H.loc)
			M.amount = round(metalNeeded * 0.5)
		return

	///This is how much metal is needed
	var/obj/item/stack/sheet/metal/M
	for(var/obj/item/stack/sheet/metal/S in range(1))
		if(S.get_amount() >= metalNeeded)
			M = S
			continue
	if(M)
		H.visible_message("<span class='notice'>[H] begins to construct a suit!</span>", "<span class='danger'>You begin to construct a suit...</span>")
		playsound(H, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		if(do_after(owner, 80, TRUE, owner))
			if(!(M.use(metalNeeded)))
				return
			suitUp(H)
			playsound(H, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
	else
		to_chat(H, "<span class='warning'>You need at least 30 metal sheets nearby to make a suit!</span>")
/**
  * Causes a mob/living/carbon/human to become a mob/living/carbon/savant/suit. Also heals them above the suit breakage threshold.
  *
  * This proc can take any mob/living/carbon/human. It is intended to only be used on savants, but hey, go nuts.
  * The proc will also heal the subject until it is above the suitFailHealth threshold, defined in /datum/species/savant/suit.
  * The proc heals brute first, with leftover healing going to burn.
  * Since toxin and o2 damage do not cause the suit to break, they are not healed at all.
  * * C - the savant (or other human type) that will be turned into a savant/suit
  */
/datum/action/innate/savantSuitUp/proc/suitUp(mob/living/carbon/human/C)
	var/sfh = SUITFAILHEALTH
	if((C.getFireLoss() + C.getBruteLoss()) > sfh)//This part heals suitFailHealth points total, starting in brute, and any leftovers go to burn.
		if(C.getBruteLoss() > sfh)
			C.adjustBruteLoss(-sfh, 0)
		else
			var/BruteHeal = C.getBruteLoss()
			C.adjustBruteLoss(-BruteHeal, 0)
			var/BurnHeal = -(sfh - BruteHeal)
			C.adjustFireLoss(BurnHeal)
	C.set_species(/datum/species/savant/suit)

/datum/species/savant/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		SuitUpPower = new
		SuitUpPower.Grant(C)

/datum/species/savant/on_species_loss(mob/living/carbon/C)
	if(SuitUpPower)
		SuitUpPower.Remove(C)
	..()

/datum/species/savant/spec_fully_heal(mob/living/carbon/human/H)
	H.set_species(/datum/species/savant/suit)
	. = ..()


/**
  * # Suited Savants
  *
  * Savants, but with a suit. (See [/datum/species/savant/]). These should be the "default" ones spawned/used for roundstart stuff.
  *
  * Savants live comfortably in thier suit until they are damaged enough.
  * Once they take suitFailHealth in brute or burn, they explode(just a little bit) and the suit comes off.
  * Bodypart stuff is handled in the on_species_gain and loss, since parts of the suit are mechanical and parts are just the savant's chest lol
  * Author: Jcat
  *
  */
/datum/species/savant/suit
	id = "savant_suited"
	limbs_id = "savant_suited"
	name = "Savant"
	no_equip = list(SLOT_W_UNIFORM)
	speedmod = 0
	armor = -10
	punchdamagelow = 1
	punchdamagehigh = 10
	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	inherent_traits = list(TRAIT_NODISMEMBER ,TRAIT_NOLIMBDISABLE, TRAIT_DNA_FROM_PARENT)
	species_traits = list(AGENDER, NO_UNDERWEAR, NOEYESPRITES)
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

/datum/species/savant/suit/on_species_gain(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		if(!(istype(O, /obj/item/bodypart/head) || istype(O, /obj/item/bodypart/chest)))//Head and chest are organic. Only the limbs are augmented
			O.change_bodypart_status(BODYPART_ROBOTIC, FALSE, FALSE)
			O.icon = 'icons/mob/augmentation/savant.dmi'
			O.icon_state = "savant_suited_[O.body_zone]"

/datum/species/savant/suit/on_species_loss(mob/living/carbon/C)
	. = ..()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC,FALSE,FALSE)

/datum/species/savant/suit/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	if((H.getFireLoss() + H.getBruteLoss()) > SUITFAILHEALTH)
		H.set_species(/datum/species/savant)
		H.update_body_parts()
		explosion(H, 0, 0, 0, adminlog = FALSE)

/datum/species/savant/suit/spec_death(gibbed, mob/living/carbon/human/H)
	. = ..()
	if(gibbed)
		return
	explosion(H, 0, 0, 0, adminlog = FALSE)
	H.set_species(/datum/species/savant)