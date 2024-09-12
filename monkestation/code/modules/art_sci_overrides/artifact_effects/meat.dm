/datum/artifact_effect/meat
	examine_discovered = "Summons meat?"
	weight = ARTIFACT_UNCOMMON
	discovered_credits = CARGO_CRATE_VALUE * 2 //ME A T
	activation_message = "begins stealing meat!"
	deactivation_message = "gets caught stealing meat!"
	research_value = 500
	type_name = "Meat Teleportation Effect"

	COOLDOWN_DECLARE(meat_cd)

	var/meat_counter = 0

	///MY MEAT BYCICLE IS BIGGER THAN YOURS - Kreig borderlands
	var/static/list/obj/item/food/validmeat = list(
		/obj/item/food/meat/slab = 20,
		/obj/item/food/meat/slab/meatwheat = 20,
		/obj/item/food/meat/slab/monkey = 15,
		/obj/item/food/meat/slab/bugmeat = 15,
		/obj/item/food/meat/slab/mothroach = 15,
		/obj/item/food/meat/slab/mouse = 15,
		/obj/item/food/meat/slab/pug = 10,
		/obj/item/food/meat/slab/goliath = 10,
		/obj/item/food/meat/slab/corgi = 10,
		/obj/item/food/meat/slab/gorilla = 5,
		/obj/item/food/meat/slab/bear = 5,
		/obj/item/food/meat/slab/xeno = 5,
		/obj/item/food/meat/slab/spider = 5,
		/obj/item/food/meat/slab/human/mutant/slime = 1,
		/obj/item/food/meat/slab/human/mutant/lizard = 1,
		/obj/item/food/meat/slab/human = 1,
		/obj/item/food/meat/slab/human/mutant/skeleton = 1,
	)

/datum/artifact_effect/meat/effect_process()
	if(!COOLDOWN_FINISHED(src,meat_cd))
		return
	var/center_turf = get_turf(our_artifact.parent)
	var/list/turf/valid_turfs = list()
	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	for(var/turf/boi in range(3,center_turf))
		if(boi.density)
			continue
		valid_turfs += boi
	var/obj/item/food/pickedmeat = pick_weight(validmeat)
	new pickedmeat(pick(valid_turfs))
	meat_counter++
	if(meat_counter > round(potency/10))
		meat_counter = 0
		toggle_active(FALSE)
		return
	COOLDOWN_START(src,meat_cd,(10 SECONDS))

