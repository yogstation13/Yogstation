/*
SPLEEN (natural)

Modifies natural blood regeneration by a %

SPLEENLESS ANATOMY = 100% regen

If you are a spleenoid you get 110% blood regen for having a spleen (basically unobservable)
If your spleens fucking DEAD you have 30% blood regen rate

If your blood goes below 336 blood spleen will release 24 units of stored blood (which takes like 10 minutes to regenerate)

If you have > 135 toxin damage and dont have spleenless/liverless metabolism your spleen will try to heal some toxin damage at the cost of itself
	-if your liver is below 70 damage the spleen will take 2 damage on life tick and heal 0.2 toxin
	-If you have 70 and above liverdamage the spleen will take 3 damage on life tick and heal 0.2 toxin
	-if you have no liver the spleen will take 4 damage and heal 0.2 damage on life tick
*/
/obj/item/organ/internal/spleen
	name = "spleen"
	icon_state = "spleen"
	visual = FALSE
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_SPLEEN
	desc = "Handles part of blood generation, hypervolemia, and critically dangerous toxin levels at cost to itself."

	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY // smack in the middle of decay times

	food_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/iron = 2, /datum/reagent/blood = 10)
	grind_results = list(/datum/reagent/consumable/nutriment/peptides = 4)

	var/blood_regen_mult = 0.10 //how much the spleen will multiply your blood regen
	var/operated = FALSE //whether the spleens been repaired with surgery and can be fixed again or not
	var/internal_blood_buffer_max = 24 //a buffer that hold blood unside the spleen, when you get low on blood it releases this and takes a while to regenerate it fully
	var/stored_blood = 24 //current blood in your spleen buffer
	var/toxResistance = -0.2 //how much the spleen will heal when you are messed up from toxins (damages iteself in process)
	var/toxLimit = 135 //how high tox can get before spleen starts sacrificing itself to heal it

/obj/item/organ/internal/spleen/Initialize(mapload)
	. = ..()

/// Registers HANDLE_SPLEEN_MULT_BLOODGEN to owner
/obj/item/organ/internal/spleen/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_SPLEEN_MULT_BLOODGEN, PROC_REF(blood_generation))
	RegisterSignal(organ_owner, COMSIG_SPLEEN_EMERGENCY, PROC_REF(emergency_release))

/// Unregisters HANDLE_SPLEEN_MULT_BLOODGEN from owner
/obj/item/organ/internal/spleen/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_SPLEEN_MULT_BLOODGEN)
	UnregisterSignal(organ_owner, COMSIG_SPLEEN_EMERGENCY, PROC_REF(emergency_release))
/**
 * Used for multiplying or acting on blood generation amounts in blood.dm
 * overide in new spleen organs for different effects
 **/
/obj/item/organ/internal/spleen/proc/blood_generation(datum/source, mob/living/carbon/organ_owner, blood_volume, nutrition_ratio, seconds_per_tick)
	SIGNAL_HANDLER
	var/efficiency = ((maxHealth - damage)/maxHealth) + blood_regen_mult //regular spleen gives you 10% boost to blood gen yay
	organ_owner.blood_volume = min(blood_volume + (BLOOD_REGEN_FACTOR * nutrition_ratio * seconds_per_tick * efficiency), BLOOD_VOLUME_NORMAL)

/obj/item/organ/internal/spleen/proc/emergency_release(mob/living/carbon/organ_owner)
	SIGNAL_HANDLER
	if(stored_blood < (internal_blood_buffer_max - 2))
		return
	var/released_blood = stored_blood
	stored_blood = 0
	organ_owner.blood_volume += released_blood

/obj/item/organ/internal/spleen/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(stored_blood < internal_blood_buffer_max)
		stored_blood += 0.02

/obj/item/organ/internal/liver/before_organ_replacement(obj/item/organ/replacement)
	. = ..()
	if(!istype(replacement, type))
		return

	var/datum/job/owner_job = owner.mind?.assigned_role
	if(!owner_job || !LAZYLEN(owner_job.liver_traits))
		return

	// Transfer over liver traits from jobs, if we should have them
	for(var/readded_trait in owner_job.liver_traits)
		if(!HAS_TRAIT_FROM(src, readded_trait, JOB_TRAIT))
			continue
		ADD_TRAIT(replacement, readded_trait, JOB_TRAIT)

/obj/item/organ/internal/spleen/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(damage > 99)

		return
	var/mob/living/carbon/organ_owner = src.owner
	if(!HAS_TRAIT(src, TRAIT_SPLEENLESS_METABOLISM && !HAS_TRAIT(src, TRAIT_LIVERLESS_METABOLISM)))
		if(organ_owner.getToxLoss() >= toxLimit)
			if(!isnull(organ_owner.dna.species.mutantliver) && !organ_owner.get_organ_slot(ORGAN_SLOT_LIVER))
				var/obj/item/organ/organ = organ_owner.get_organ_slot(ORGAN_SLOT_LIVER)
				if(organ.damage < 70)
					damage += 2
					organ_owner.adjustToxLoss(toxResistance)
				else
					damage += 1
					organ_owner.adjustToxLoss(toxResistance)
			else
				damage += 3
				organ_owner.adjustToxLoss(toxResistance)

/obj/item/organ/internal/spleen/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantliver

/obj/item/organ/internal/spleen/cybernetic
	name = "basic cybernetic spleen"
	icon_state = "spleen-c"
	desc = "A very basic device designed to mimic the functions of a human liver. Handles toxins slightly worse than an organic liver."
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.5
	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

	blood_regen_mult = 0.05 //how much the spleen will multiply your blood regen
	operated = FALSE //whether the spleens been repaired with surgery and can be fixed again or not
	internal_blood_buffer_max = 10 //a buffer that hold blood unside the spleen, when you get low on blood it releases this and takes a while to regenerate it fully
	stored_blood = 10 //current blood in your spleen buffer
	toxResistance = -0.1 //how much the spleen will heal when you are messed up from toxins (damages iteself in process)
	toxLimit = 150 //

/obj/item/organ/internal/spleen/cybernetic/tier2
	name = "cybernetic spleen"
	icon_state = "spleen-c-u"
	desc = "An electronic device designed to mimic the functions of a human spleen. Handles blood and emergency toxins slightly better than an organic spleen."
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD
	emp_vulnerability = 40 //Chance of permanent effects if emp-ed.

	blood_regen_mult = 0.15 //how much the spleen will multiply your blood regen
	operated = FALSE //whether the spleens been repaired with surgery and can be fixed again or not
	internal_blood_buffer_max = 30 //a buffer that hold blood unside the spleen, when you get low on blood it releases this and takes a while to regenerate it fully
	stored_blood = 30 //current blood in your spleen buffer
	toxResistance = -0.4 //how much the spleen will heal when you are messed up from toxins (damages iteself in process)
	toxLimit = 130

/obj/item/organ/internal/spleen/cybernetic/tier3
	name = "upgraded cybernetic spleen"
	icon_state = "spleen-c-u2"
	desc = "An upgraded version of the cybernetic spleen designed to mimic hematopoiesis of bone marrow while being able to in emergencies sacrifice its durability to cleans toxins. Stores 50 units of blood for emergency release in case of hypervolemic shock. "
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD*1.5
	emp_vulnerability = 20 //Chance of permanent effects if emp-ed.

	blood_regen_mult = 0.35
	operated = FALSE
	internal_blood_buffer_max = 50
	stored_blood = 50
	toxResistance = -0.7
	toxLimit = 99

/obj/item/organ/internal/spleen/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.adjustToxLoss(10)
		COOLDOWN_START(src, severe_cooldown, 10 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.

