/datum/eldritch_knowledge/base_mind
	name = "Precipice Of Enlightenment"
	desc = "Pledge yourself to knowledge everlasting. Allows you to transmute a knife and a book into a blade of pure thought. Additionally, Your mansus grasp now functions at a range, knocking them down and blurring their vision."
	gain_text = "The corpse of an ancient God defiled, your fellow scholars enlightened by false knowledge, but you seek true insight. You seek the unknown, the invisible, the truth behind the veil."
	unlocked_transmutations = list(/datum/eldritch_transmutation/mind_knife)
	cost = 1
	route = PATH_MIND
	tier = TIER_PATH
	
/datum/eldritch_knowledge/base_mind/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/melee/sickly_blade/mind
	user.put_in_hands(realknife)
	var/datum/action/cooldown/spell/touch/mansus_touch = locate(/datum/action/cooldown/spell/touch/mansus_grasp) in user.actions
	if(mansus_touch)
		mansus_touch.hand_path = /obj/item/melee/touch_attack/mansus_fist/mind //longer range version
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/mind/mind_jaunt = new(user)
	mind_jaunt.Grant(user)

/datum/eldritch_knowledge/base_mind/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_mind/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/human/human_target = target
	human_target.adjust_eye_blur(1 SECONDS)
	human_target.Knockdown(2 SECONDS)

/datum/eldritch_knowledge/spell/eldritchbolt
	name = "T1 - Eldritch Bolt"
	gain_text = "Remain wary of the frailty of men. Their wills are weak, minds young. Were it not for fear, death would go unlamented. Seek the old blood. Let us pray, let us wish... to partake in communion."
	desc = "A strong single target spell, shoot a target with raw energy from another dimension."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/lightningbolt/eldritchbolt
	route = PATH_MIND
	tier = TIER_1

/datum/eldritch_knowledge/eldritch_eye
	name = "T1 - Eldritch Eye"
	gain_text = "One of the many eyes of the defilied god ripped from it's bloated corpse, as you stood on that moonlit beach, you could almost swear you heard a baby crying."
	desc = "Allows you to craft an eldritch eye by transmuting a flashlight and a pair of eyes. Grants the user a hud type of their choosing, additionally also grants night vision but it cannot be removed."
	unlocked_transmutations = list(/datum/eldritch_transmutation/eldritch_eye)
	cost = 1
	route = PATH_MIND
	tier = TIER_1

/datum/eldritch_knowledge/mind_mark
	name = "Grasp Mark - Occipital Oblivion"
	gain_text = "They say the eyes are the gateway to the soul, a way to tell one's true intentions. Show them a single sliver of the truth of this world and their eyes will reject all."
	desc = "Upgrade your mansus grasp, granting it the ability to blind a target on hit, as well as increasing the range"
	cost = 2
	route = PATH_MIND
	tier = TIER_MARK

/datum/eldritch_knowledge/mind_mark/on_gain(mob/user)
	. = ..()
	var/datum/action/cooldown/spell/touch/mansus_touch = locate(/datum/action/cooldown/spell/touch/mansus_grasp) in user.actions
	if(mansus_touch)
		mansus_touch.hand_path = /obj/item/melee/touch_attack/mansus_fist/mind/upgraded //even longer range version
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/mind_mark/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/mind_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!ishuman(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/human/human_target = target
	human_target.adjust_eye_blur(2 SECONDS)
	human_target.blind_eyes(1 SECONDS)

/datum/eldritch_knowledge/spell/assault
	name = "T2 - Amygdala Assault"
	gain_text = "Deep into the dream, you work tirelessly, endlessly. A blighted curse consumes the land, but the scholars of Kos will light the way through the nightmare."
	desc = "Shoot a single bolt of condensed mental power infront of you, dealing large amounts of brute damage to any targets hit."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/assault
	route = PATH_MIND
	tier = TIER_2

/datum/eldritch_knowledge/spell/famished_roar
	name = "T3 - Famished Roar"
	gain_text = "Beasts all over the shop. You'll be one of them... Sooner or later... What's that smell? The sweet blood, oh, it sings to me. It's enough to make a man sick..."
	desc = "An AOE roar spell that freezes all nearby people with sheer terror."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/aoe/immobilize/famished_roar
	route = PATH_MIND
	tier = TIER_3

/datum/eldritch_knowledge/mind_blade_upgrade
	name = "Blade Upgrade - Spine of The Infinite Beast"
	gain_text = "Curse here, Curse there. Curse for he and she, why care? A bottomless curse, a bottomless sea, source of all greatness, all things that be."
	desc = "Your mind blade will now inject targets hit with mutetoxin, silencing them."
	cost = 2
	route = PATH_MIND
	tier = TIER_BLADE

/datum/eldritch_knowledge/mind_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/toxin/mutetoxin, 2)

/datum/eldritch_knowledge/cerebral_control
	name = "T3 - Full Cerebral Control"
	gain_text = "Itching on the inside of your skull, like spiders under your skin, runes marked all over your body, etched into your soul. Eyes on the inside to see the truth, to ascend."
	desc = "Rewire your own brain to partially ignore damage slowdown."
	cost = 1
	route = PATH_MIND
	tier = TIER_3

/datum/eldritch_knowledge/cerebral_control/on_gain(mob/user)
	. = ..()
	ADD_TRAIT(user, TRAIT_REDUCED_DAMAGE_SLOWDOWN, type)

/datum/eldritch_knowledge/mind_final
	name = "Ascension Rite - Beyond All Knowledge Lies Despair"
	gain_text = "A beast, a walking corpse, a murderer, a hunter. You are all these and more, and you like it. A hunter is a hunter, even in a dream, and you've made it to the end. It's time to wake from this endless nightmare, the keys to the lock built on a mountain of corpses. "
	desc = "Transmute three corpses to ascend as a Monarch of Knowledge, your advanced prowess in mental proficiency allows you to deflect all projectiles. Instantly gain 9 points of knowledge to use, you also gain additional immunity to pressure and no longer need to breath."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/mind_final)
	route = PATH_MIND
	tier = TIER_ASCEND
