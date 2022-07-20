/mob/living/carbon
	gender = MALE
	pressure_resistance = 15
	possible_a_intents = list(INTENT_HELP, INTENT_HARM)
	hud_possible = list(HEALTH_HUD,STATUS_HUD,ANTAG_HUD,GLAND_HUD,NANITE_HUD,DIAG_NANITE_FULL_HUD)
	has_limbs = 1
	held_items = list(null, null)
	/// List of /obj/item/organ in the mob. 
	/// They don't go in the contents for some reason I don't want to know.
	var/list/internal_organs		= list()	
	/// List of /obj/item/organ in the mob by slot ID for easy access. 
	/// They don't go in the contents for some reason I don't want to know.
	var/list/internal_organs_slot= list()

	/// Can't talk. Value goes down every life proc.
	/// NOTE TO FUTURE CODERS: DO NOT INITIALIZE NUMERICAL VARS AS NULL OR I WILL MURDER YOU.
	var/silent = FALSE 		
	/// How many dream images we have left to send
	var/dreaming = 0 

	/// A reference to the current handcuff on this carbon if one is equipped.
	var/obj/item/restraints/handcuffed = null 
	/// A reference to the current legcuff on this carbon if one is equipped. Bear traps use this.
	var/obj/item/restraints/legcuffed = null

	var/disgust = 0

	/// Timer id of any transformation
	var/transformation_timer

//inventory slots
	var/obj/item/back = null
	var/obj/item/clothing/mask/wear_mask = null
	var/obj/item/clothing/neck/wear_neck = null
	var/obj/item/tank/internal = null
	var/obj/item/clothing/head = null

	var/obj/item/clothing/gloves = null //only used by humans
	var/obj/item/clothing/shoes = null //only used by humans.
	var/obj/item/clothing/glasses/glasses = null //only used by humans.
	var/obj/item/clothing/ears = null //only used by humans.

	var/datum/dna/dna = null//Carbon
	var/datum/mind/last_mind = null //last mind to control this mob, for blood-based cloning

	var/failed_last_breath = 0 //This is used to determine if the mob failed a breath. If they did fail a brath, they will attempt to breathe each tick, otherwise just once per 4 ticks.

	var/co2overloadtime = null
	var/temperature_resistance = T0C+75
	var/obj/item/reagent_containers/food/snacks/meat/slab/type_of_meat = /obj/item/reagent_containers/food/snacks/meat/slab

	var/gib_type = /obj/effect/decal/cleanable/blood/gibs

	var/rotate_on_lying = 1

	var/tinttotal = 0	// Total level of visualy impairing items

	var/list/bodyparts = list(/obj/item/bodypart/chest, /obj/item/bodypart/head, /obj/item/bodypart/l_arm,
					 /obj/item/bodypart/r_arm, /obj/item/bodypart/r_leg, /obj/item/bodypart/l_leg)
	//Gets filled up in create_bodyparts()

	var/list/hand_bodyparts = list() //a collection of arms (or actually whatever the fug /bodyparts you monsters use to wreck my systems)

	var/icon_render_key = ""
	var/static/list/limb_icon_cache = list()

	//halucination vars
	var/image/halimage
	var/image/halbody
	var/obj/halitem
	var/hal_screwyhud = SCREWYHUD_NONE
	var/next_hallucination = 0
	var/cpr_time = 1 //CPR cooldown.
	var/damageoverlaytemp = 0

	var/drunkenness = 0 //Overall drunkenness - check handle_alcohol() in life.dm for effects
	var/stam_regen_start_time = 0 //used to halt stamina regen temporarily
	var/stam_paralyzed = FALSE //knocks you down

	/// All of the wounds a carbon has afflicted throughout their limbs
	var/list/all_wounds
	/// All of the scars a carbon has afflicted throughout their limbs
	var/list/all_scars
	var/visible_tumors = FALSE //if you are seem with some tumors, for examine

	COOLDOWN_DECLARE(bleeding_message_cd)
