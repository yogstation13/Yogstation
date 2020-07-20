/datum/species/savant
	id = "savant"
	//limbs_id		//this is used if you want to use a different species limb sprites. Mainly used for angels as they look like humans.
	name = "Savant"
	default_color = "#FFF"	// if alien colors are disabled, this is the color that will be used by that race

	sexes = FALSE

	//list/offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,0), OFFSET_EARS = list(0,0), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,0), OFFSET_HEAD = list(0,0), OFFSET_FACE = list(0,0), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

	//hair_color	// this allows races to have specific hair colors... if null, it uses the H's hair/facial hair colors. if "mutcolor", it uses the H's mutant_color
	hair_alpha = 255	// the alpha used by the hair. 255 is completely solid, 0 is transparent.

	use_skintones = FALSE	// does it use skintones or not? (spoiler alert this is only used by humans)
	//exotic_blood = ""	// If your race wants to bleed something other than bog standard blood, change this to reagent id.
	//exotic_bloodtype = "" //If your race uses a non standard bloodtype (A+, O-, AB-, etc)
	//meat = /obj/item/reagent_containers/food/snacks/meat/slab/human //What the species drops on gibbing
	//skinned_type
	liked_food = VEGETABLES | FRUIT
	disliked_food = GROSS | RAW | MEAT
	toxic_food = TOXIC
	//list/no_equip = list()	// slots the race can't equip stuff to
	//nojumpsuit = 0	// this is sorta... weird. it basically lets you equip stuff that usually needs jumpsuits without one, like belts and pockets and ids
	say_mod = "trills"	// affects the speech message
	//species_language_holder = /datum/language_holder
	//list/default_features = list() // Default mutant bodyparts for this species. Don't forget to set one for every mutant bodypart you allow this species to have.
	//list/mutant_bodyparts = list() 	// Visible CURRENT bodyparts that are unique to a species. DO NOT USE THIS AS A LIST OF ALL POSSIBLE BODYPARTS AS IT WILL FUCK SHIT UP! Changes to this list for non-species specific bodyparts (ie cat ears and tails) should be assigned at organ level if possible. Layer hiding is handled by handle_mutant_bodyparts() below.	list/mutant_organs = list()		//Internal organs that are unique to this race.
	speedmod = 0	// this affects the race's speed. positive numbers make it move slower, negative numbers make it move faster
	armor = 0		// overall defense for the race... or less defense, if it's negative.
	brutemod = 0.75	// multiplier for brute damage
	burnmod = 0.75		// multiplier for burn damage
	coldmod = 0.75		// multiplier for cold damage
	heatmod = 0.75		// multiplier for heat damage
	acidmod = 0.75    // multiplier for acid damage // yogs - Old Plant People
	stunmod = 0.75		// multiplier for stun duration
	attack_type = BRUTE //Type of damage attack does
	punchdamagelow = 1       //lowest possible punch damage. if this is set to 0, punches will always miss
	punchdamagehigh = 8      //highest possible punch damage
	//punchstunthreshold = 10//damage at which punches from this race will stun //yes it should be to the attacked race but it's not useful that way even if it's logical
	//siemens_coeff = 1.5 //base electrocution coefficient
	//damage_overlay_type = "human" //what kind of damage overlays (if any) appear on our species when wounded?
	//fixed_mut_color = "" //to use MUTCOLOR with a fixed color that's independent of dna.feature["mcolor"]
	//inert_mutation 	= DWARFISM //special mutation that can be found in the genepool. Dont leave empty or changing species will be a headache
	//deathsound //used to set the mobs deathsound on species change
	//list/special_step_sounds //Sounds to override barefeet walkng
	//grab_sound //Special sound for grabbing
	//screamsound //yogs - audio of a species' scream
	flying_species = FALSE //is a flying species, just a check for some things
	//datum/action/innate/flight/fly //the actual flying ability given to flying species
	//wings_icon = "Angel" //the icon used for the wings

	// species-only traits. Can be found in DNA.dm
	//list/species_traits = list()
	// generic traits tied to having the species
	//list/inherent_traits = list()
	//list/inherent_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)

	attack_verb = "punch"	// punch-specific attack verb
	sound/attack_sound = 'sound/weapons/punch1.ogg'
	sound/miss_sound = 'sound/weapons/punchmiss.ogg'

	list/mob/living/ignored_by = list()	// list of mobs that will ignore this species
	//Breathing!
	//obj/item/organ/lungs/mutantlungs = null
	breathid = "o2"

	obj/item/organ/brain/mutant_brain = /obj/item/organ/brain
	obj/item/organ/heart/mutant_heart = /obj/item/organ/heart
	obj/item/organ/eyes/mutanteyes = /obj/item/organ/eyes
	obj/item/organ/ears/mutantears = /obj/item/organ/ears
	obj/item/mutanthands = null
	obj/item/organ/tongue/mutanttongue = /obj/item/organ/tongue
	obj/item/organ/tail/mutanttail = null

	//obj/item/organ/liver/mutantliver
	//obj/item/organ/stomach/mutantstomach
	override_float = FALSE

	//Bitflag that controls what in game ways can select this species as a spawnable source
	//Think magic mirror and pride mirror, slime extract, ERT etc, see defines
	//in __DEFINES/mobs.dm, defaults to NONE, so people actually have to think about it
	changesource_flags = NONE