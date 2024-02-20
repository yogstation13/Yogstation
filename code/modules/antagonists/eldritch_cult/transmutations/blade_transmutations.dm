/datum/eldritch_transmutation/dark_knife
	name = "Darkness Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/stack/sheet/mineral/silver)
	result_atoms = list(/obj/item/melee/sickly_blade/dark)
	required_shit_list = "A bar of pure silver and a knife."

/datum/eldritch_transmutation/eldritch_whetstone
	name = "Master's Whetstone"
	required_atoms = list(/obj/item/organ/heart, /obj/item/stack/sheet/mineral/diamond, /obj/item/stack/sheet/plasteel)
	result_atoms = list(/obj/item/sharpener/eldritch)
	required_shit_list = "A human heart, a diamond, a sheet of plasteel"

/datum/eldritch_transmutation/bone_knife
	name = "Bone Blade"
	required_atoms = list(/obj/item/kitchen/knife,/obj/item/stack/sheet/mineral/gold)
	result_atoms = list(/obj/item/melee/sickly_blade/bone)
	required_shit_list = "A bar of gold and a knife."

/datum/eldritch_transmutation/final/blade_final
	name = "Maelstrom of Silver"
	required_atoms = list(/mob/living/carbon/human)
	var/list/trait_list = list(TRAIT_HARDLY_WOUNDED, TRAIT_STUNIMMUNE)
	required_shit_list = "Three dead bodies."

/datum/eldritch_transmutation/final/blade_final/on_finished_recipe(mob/living/user, list/atoms, loc)
	priority_announce("Master of blades, the Torn Champion's disciple, [user.real_name] has ascended! Their steel is that which will cut reality in a maelstom of silver!", ANNOUNCER_SPANOMALIES)
	
	var/mob/living/carbon/human/H = user
	user.apply_status_effect(/datum/status_effect/protective_blades/recharging, null, 8, 30, 0.25 SECONDS, 1 MINUTES)
	H.physiology.brute_mod *= 0.5
	H.physiology.burn_mod *= 0.5
	H.physiology.stamina_mod = 0
	H.physiology.stun_mod = 0
	var/datum/antagonist/heretic/ascension = H.mind.has_antag_datum(/datum/antagonist/heretic)
	ascension.ascended = TRUE
	var/datum/action/cooldown/spell/pointed/projectile/furious_steel/steel_spell = locate() in user.actions
	steel_spell?.cooldown_time /= 2
	for(var/X in trait_list)
		ADD_TRAIT(user,X,MAGIC_TRAIT)
	return ..()
