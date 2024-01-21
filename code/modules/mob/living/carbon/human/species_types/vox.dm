/datum/species/vox
	name = "Vox"
	id = SPECIES_VOX
	say_mod = "shrieks"
	is_dimorphic = FALSE
	species_traits = list(NO_UNDERWEAR, NOTRANSSTING, EYECOLOR, HAS_TAIL, HAIRCOLOR, FACEHAIRCOLOR, MUTCOLORS, MUTCOLORS_SECONDARY) // Robust, but cannot be cloned easily.
	inherent_traits = list(TRAIT_RESISTLOWPRESSURE, TRAIT_NOCLONE)
	mutant_bodyparts = list("vox_quills", "vox_body_markings",  "vox_facial_quills", "vox_tail", "vox_body", "vox_tail_markings")
	default_features = list("vox_quills" = "None", "vox_facial_quills" = "None", "vox_body_markings" = "None", "vox_tail" = "grnvox", "vox_tail_markings" = "None", "vox_body" = "Green")
	attack_verb = "slash"
	attack_sound = 'sound/weapons/slash.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'
	//screamsound = 'sound/voice/shriek1.ogg'
	//male_cough_sound = 'sound/voice/shriekcough.ogg'
	//female_cough_sound = 'sound/voice/shriekcough.ogg'
	//male_sneeze_sound = 'sound/voice/shrieksneeze.ogg'
	//female_sneeze_sound = 'sound/voice/shrieksneeze.ogg'
	//mutantbrain = /obj/item/organ/brain/cybernetic/vox // Brain damage on EMP
	mutantheart = /obj/item/organ/heart/vox
	mutantliver = /obj/item/organ/liver/vox // Liver damage on EMP
	mutantstomach = /obj/item/organ/stomach/vox // Disgust on EMP
	mutanttongue = /obj/item/organ/tongue/vox
	mutantlungs = /obj/item/organ/lungs/vox // Causes them to.. gasp.
	mutantears = /obj/item/organ/ears/vox // Very brief deafness
	mutanteyes = /obj/item/organ/eyes/vox // Quick hallucination
	mutanttail = /obj/item/organ/tail/vox
	//meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/vox
	//skinned_type = /obj/item/stack/sheet/animalhide/vox
	toxmod = 2 // Weak immune systems.
	burnmod = 0.8 // Tough hides.
	stunmod = 1.1 // Take a bit longer to get up than other species.
	//breathid = "n2"
	//husk_id = "voxhusk"
	has_icon_variants = TRUE
	damage_overlay_type = "vox"
	exotic_bloodtype = "V"

/datum/species/vox/get_species_description()
	return "Though commonly referred to as \"shitbirds\" by the crew, they are, in fact, not avian. \
	Exiled by their own species, the corporation is the only one that will hire the outcasts. \
	Most of them struggle with galactic common - as it is not their native tongue - and have difficulty grasping the nuances of the language."
	
/datum/species/vox/get_species_lore()
	return list("bruh kek")

/datum/species/vox/random_name(unique)
	var/sounds = rand(2,8)
	var/i = 0
	var/newname = ""

	while(i<=sounds)
		i++
		newname += pick("ti","hi","ki","ya","ta","ha","ka","yi","chi","cha","kah")
	return capitalize(newname)

/datum/species/vox/on_species_gain(mob/living/carbon/C) // The body color choice feature
	. = ..()
	var/vox_body = C.dna.features["vox_body"]
	var/datum/sprite_accessory/vox_bodies/vox_body_of_choice = GLOB.vox_bodies_list[vox_body]
	C.dna.species.limbs_id = vox_body_of_choice.limbs_id
	C.dna.features["vox_tail"] = vox_body_of_choice.limbs_id // The tail has to match the bodytype

/datum/species/vox/after_equip_job(datum/job/J, mob/living/carbon/human/H) // Don't forget your voxygen tank
	H.grant_language(/datum/language/voxpidgin)
	H.equip_to_slot_or_del(new /obj/item/clothing/mask/breath(H), ITEM_SLOT_MASK)
	//H.put_in_r_hand(new /obj/item/tank/internals/emergency_oxygen/vox(H))
	to_chat(H, "<span class='notice'>You are now running on nitrogen internals from the emergency tank in your hand. Your species finds oxygen EXTREMELY TOXIC, so you must breathe nitrogen only.</span>")
	H.open_internals(H.get_item_for_held_index(2))
	H.grant_language(/datum/language/voxpidgin)

/*/datum/species/vox/on_husk(mob/living/carbon/C) // Husks the tail
		C.dna.features["vox_tail"] = "voxhusk"

/datum/species/vox/on_husk_cure(mob/living/carbon/C) // De-husks the to a normal tail based on the body.
	var/vox_body = C.dna.features["vox_body"]
	var/datum/sprite_accessory/vox_bodies/vox_body_of_choice = GLOB.vox_bodies_list[vox_body]
	C.dna.features["vox_tail"] = vox_body_of_choice.limbs_id*/
