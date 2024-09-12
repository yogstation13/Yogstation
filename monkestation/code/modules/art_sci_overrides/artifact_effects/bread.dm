/datum/artifact_effect/bread
	examine_discovered = "Summons bread?"
	weight = ARTIFACT_UNCOMMON
	discovered_credits = CARGO_CRATE_VALUE * 2 //Mmm bread
	activation_message = "begins baking some fresh eldritch brand bread!"
	deactivation_message = "runs out of bread!"
	research_value = 500
	type_name = "Bread Teleportation Effect"

	COOLDOWN_DECLARE(bread_cd)

	var/bread_counter = 0

	///We sell BREAD. We sell LOAF. TOASTED, ROASTED...
	var/static/list/obj/item/food/validbread = list(
		/obj/item/food/bread/plain = 20,
		/obj/item/food/bread/meat = 15,
		/obj/item/food/bread/banana = 15,
		/obj/item/food/bread/tofu = 10,
		/obj/item/food/croissant = 10,
		/obj/item/food/baguette = 10,
		/obj/item/food/garlicbread = 10,
		/obj/item/food/bread/creamcheese = 10,
		/obj/item/food/frenchtoast = 8,
		/obj/item/food/breadstick = 8,
		/obj/item/food/butterbiscuit = 5,
		/obj/item/food/bread/mimana = 5,
		/obj/item/food/bread/sausage = 5,
		/obj/item/food/bread/xenomeat = 1,
		/obj/item/food/bread/spidermeat = 1
	)

/datum/artifact_effect/bread/effect_process()
	if(!COOLDOWN_FINISHED(src,bread_cd))
		return
	var/center_turf = get_turf(our_artifact.parent)
	var/list/turf/valid_turfs = list()
	if(!center_turf)
		CRASH("[src] had attempted to trigger, but failed to find the center turf!")
	for(var/turf/boi in range(3,center_turf))
		if(boi.density)
			continue
		valid_turfs += boi
	var/obj/item/food/pickedbread = pick_weight(validbread)
	new pickedbread(pick(valid_turfs))
	bread_counter++
	if(bread_counter > round(potency/10))
		bread_counter = 0
		toggle_active(FALSE)
		return
	COOLDOWN_START(src,bread_cd,(7.5 SECONDS))

