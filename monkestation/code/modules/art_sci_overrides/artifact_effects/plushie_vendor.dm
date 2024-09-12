/datum/artifact_effect/plushie
	examine_hint = "Has some sort of claw mechanism."

	examine_discovered = "Its a claw machine of some kind"

	weight = ARTIFACT_UNCOMMON

	activation_message = "summons a toy of some kind!"

	type_name = "Toy Vender Effect"
	research_value = 250

	var/static/list/obj/item/toy/plush/plushies = list()

	COOLDOWN_DECLARE(plushiefact)

/datum/artifact_effect/plushie/effect_activate(silent)
	if(!length(plushies))
		plushies = typecacheof(/obj/item/toy/plush,ignore_root_path = TRUE) //I am not responsible for if this is a bad idea.
	if(!COOLDOWN_FINISHED(src,plushiefact))
		return
	var/obj/item/toy/plush/boi_path = pick(plushies)
	var/obj/item/toy/plush/boi = new boi_path
	boi.forceMove(our_artifact.holder.loc)
	if(prob(clamp(potency-50,0,100)))
		boi.AddComponent(/datum/component/ghost_object_control,boi,TRUE)
		var/datum/component/ghost_object_control/spiritholder = boi.GetComponent(/datum/component/ghost_object_control)
		if(!(spiritholder.bound_spirit))
			spiritholder.request_control(0.6)
	COOLDOWN_START(src,plushiefact,3 MINUTE)
