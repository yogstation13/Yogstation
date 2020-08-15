/// How much damage the Savant can take before the suit fails and they become a /datum/species/savant
#define SUITFAILHEALTH 50
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
/datum/species/savant //sa'vän(t). This is the suitless one. Not for roundstart use.
	id = "savant"
	name = "Savant"
	default_color = "#FFF"
	limbs_id = "savant"
	sexes = FALSE
	damage_overlay_type = ""
	offset_features = list(OFFSET_GLASSES = list(0,-8), OFFSET_EARS = list(0,-8), OFFSET_FACEMASK = list(0,-8), OFFSET_HEAD = list(0,-8), OFFSET_FACE = list(0,-8), OFFSET_BACK = list(0,-8))
	hair_alpha = 255

	use_skintones = FALSE
	exotic_bloodtype = "S"
	meat = /obj/item/reagent_containers/food/snacks/meat/slab
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | RAW | MEAT
	toxic_food = TOXIC
	no_equip = list(SLOT_WEAR_SUIT, SLOT_GLOVES, SLOT_SHOES, SLOT_W_UNIFORM, SLOT_S_STORE, SLOT_BELT, SLOT_NECK)
	nojumpsuit = TRUE
	say_mod = "trills"

	speedmod = 1	//Small legs!
	armor = -20
	punchdamagelow = 1
	punchdamagehigh = 5
	species_traits = list(AGENDER, NO_UNDERWEAR, NOEYESPRITES)

	inherent_traits = list(TRAIT_SMALL_HANDS, TRAIT_SHORT)
	attack_verb = "punch"
	sound/attack_sound = 'sound/weapons/punch1.ogg'
	sound/miss_sound = 'sound/weapons/punchmiss.ogg'
	mutanttongue = /obj/item/organ/tongue/savant

	override_float = FALSE
	///This is the 'spell' that savants get so they can craft a new suit.
	var/datum/action/innate/savantSuitUp/SuitUpPower

	changesource_flags = MIRROR_BADMIN

	///This var decides if the savant is suited or naked :flushed:
	var/isSuited = FALSE

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
	///This is how much metal is needed, in sheets
	var/metalNeeded = 30
	if(isSuitedSavant(H))
		to_chat(H, "<span class='warning'>You begin to take off your suit...this might hurt! Are you sure you want to?</span>")
		playsound(H, pick('sound/items/drill_use.ogg', 'sound/items/jaws_cut.ogg', 'sound/items/jaws_pry.ogg', 'sound/items/welder.ogg', 'sound/items/ratchet.ogg'), 80, 1, -1)
		if(do_after(owner, 40, TRUE, owner))
			var/datum/species/savant/S = H.dna.species
			S.loseSuit(H)
			H.update_body_parts()
			explosion(H, 0, 0, 0, adminlog = FALSE)
			var/sfh = SUITFAILHEALTH
			H.adjustBruteLoss(sfh*0.5, 0)
			H.adjustFireLoss(sfh*0.5, 0)
			var/obj/item/stack/sheet/metal/M = new(H.loc)
			M.amount = round(metalNeeded * 0.5)
		return

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
  * Causes a mob/living/carbon/human to become a savant with a suit Also heals them above the suit breakage threshold.
  *
  * This proc can take any mob/living/carbon/human. It is intended to only be used on savants, but hey, go nuts.
  * The proc will also heal the subject until it is above the suitFailHealth threshold.
  * The proc heals brute first, with leftover healing going to burn.
  * Since toxin and o2 damage do not cause the suit to break, they are not healed at all.
  * * C - the savant (or other human type) that will be turned into a savant/suit
  */
/datum/action/innate/savantSuitUp/proc/suitUp(mob/living/carbon/human/C)
	//first, the values get changed
	C.dna.species.limbs_id = "savant"
	C.dna.species.no_equip = list(SLOT_W_UNIFORM)
	C.dna.species.speedmod = 0
	C.dna.species.armor = -10
	C.dna.species.punchdamagelow = 1
	C.dna.species.punchdamagehigh = 10
	C.dna.species.offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))
	C.dna.species.inherent_traits = list(TRAIT_NODISMEMBER ,TRAIT_NOLIMBDISABLE)
	C.dna.species.species_traits = list(AGENDER, NO_UNDERWEAR, NOTRANSSTING, NOEYESPRITES)
	var/datum/species/savant/S = C.dna.species
	S.isSuited = TRUE

	//next, they heal (if needed)
	var/sfh = SUITFAILHEALTH
	if((C.getFireLoss() + C.getBruteLoss()) > sfh)//This part heals suitFailHealth points total, starting in brute, and any leftovers go to burn.
		if(C.getBruteLoss() > sfh)
			C.adjustBruteLoss(-sfh, 0)
		else
			var/BruteHeal = C.getBruteLoss()
			C.adjustBruteLoss(-BruteHeal, 0)
			var/BurnHeal = -(sfh - BruteHeal)
			C.adjustFireLoss(BurnHeal)
	//C.set_species(/datum/species/savant/suit)
	//Lastly, the robot limbs are handled
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		if(!(istype(O, /obj/item/bodypart/head) || istype(O, /obj/item/bodypart/chest)))//Head and chest are organic. Only the limbs are augmented
			O.change_bodypart_status(BODYPART_ROBOTIC, FALSE, FALSE)
			O.icon = 'icons/mob/augmentation/savant.dmi'
			O.icon_state = "savant_suited_[O.body_zone]"

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
  * Causes a savant to lose the suit.
  *
  * Basically, this does SuitUp in reverse
  */
/datum/species/savant/proc/loseSuit(mob/living/carbon/C)
	if(!isSuited)
		return
	explosion(C, 0, 0, 0, adminlog = FALSE)

	for(var/X in C.bodyparts)
		var/obj/item/bodypart/O = X
		O.change_bodypart_status(BODYPART_ORGANIC,FALSE,FALSE)
	C.update_body_parts()
	limbs_id = initial(limbs_id)
	no_equip = initial(no_equip)
	speedmod = initial(speedmod)
	armor = initial(armor)
	punchdamagelow = initial(punchdamagelow)
	punchdamagehigh = initial(punchdamagehigh)
	offset_features = initial(offset_features)
	inherent_traits = initial(inherent_traits)
	species_traits = initial(species_traits)
	isSuited = FALSE

/datum/species/savant/apply_damage(damage, damagetype = BRUTE, def_zone = null, blocked, mob/living/carbon/human/H)
	. = ..()
	if (!isSuited)
		return
	if((H.getFireLoss() + H.getBruteLoss()) > SUITFAILHEALTH)
		loseSuit(H)


/**
  * # Suited Savants
  *
  * Savants, but with a suit. (See [/datum/species/savant/]). These should be the "default" ones spawned/used for roundstart stuff.
  *
  * Savants live comfortably in thier suit until they are damaged enough.
  * Once they take suitFailHealth in brute or burn, they explode(just a little bit) and the suit comes off.
  * Savant/suit allows for the savant to be spawned with a suit on. The species type instantly goes back to savant, so this species will never actually exist.
  * Author: Jcat
  *
  */
/datum/species/savant/suit
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT
	///This var is repeated here for the character selection screen to render properly
	limbs_id = "savant_suited"

/datum/species/savant/suit/on_species_gain(mob/living/carbon/C)
	. = ..()
	if(ishuman(C))
		C.set_species(/datum/species/savant)
		SuitUpPower = new //This is redundant but is here for safety
		SuitUpPower.Grant(C)
		SuitUpPower.suitUp(C)
