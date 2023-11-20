/datum/eldritch_knowledge/base_jungle
	name = "Xibalba's oath"
	desc = "Pledges yourself to the path of Jungle. Allows you to summon an Eldritch Bola for a portion of your health. Additionally, empowers your Mansus grasp to immobilize your victims, as well as healing you. You will also become more resistant to brute."
	gain_text = "The deep and dense jungle swallows all who enter, never to return."
	cost = 1
	route = PATH_JUNGLE
	tier = TIER_PATH

/datum/eldritch_knowledge/base_jungle/on_gain(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.physiology.brute_mod *= 0.9

	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/jungle/jungle_jaunt = new(user)
	jungle_jaunt.Grant(user)

	var/datum/action/cooldown/spell/conjure_item/eldritch_bola/bola_summon = new(user)
	bola_summon.Grant(user)

	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_jungle/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

datum/eldritch_knowledge/base_jungle/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/C = target
	var/atom/throw_target = get_edge_target_turf(C, source.dir)
	if(!C.anchored)
		C.throw_at(throw_target, rand(4,8), 14, source)
