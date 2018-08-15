/datum/martial_art/sec/
 	name = "Security Art"
 	constant_block = 5
 	var/desc = ""

/datum/martial_art/sec/teach(mob/living/carbon/human/H,make_temporary=0,mob/M)
	. = ..()
	to_chat(M, "<span class='bold info'><font size='2'>[desc]</font></span>")


/datum/martial_art/sec/flipper
	name = "Cool Flips Bro"
	desc = "You've become adept to flipping, you are likely to kick people right in the face during unarmed combat."

/datum/martial_art/sec/flipper/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(75))
		A.emote("flip")
		A.visible_message("<span class = 'danger'><B>[A] does a flip, kicking [D] back!</B></span>")
		playsound(A.loc, "swing_hit", 50, 1)
		D.apply_damage(15, BRUTE)
		var/throwtarget = get_edge_target_turf(A, get_dir(A, get_step_away(D, A)))
		D.throw_at(throwtarget, 4, 2, A)
		D.Knockdown(35) //3.5 milisecond stun, because why not
		return TRUE
	..()

/datum/martial_art/sec/blocker
	name = "Block Affinity"
	constant_block = 25
	desc = "Show those pesky greytiders who's boss! You commonly block melee attacks with JUST your arms."



/datum/martial_art/sec/puncher
	name = "Heavy Hitter"
	desc = "Getting your ass handed to you in training pushed you to do something better with your life, you know how to sucker punch people, delivering a good, stunning, blow."

/datum/martial_art/sec/puncher/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(50))
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='danger'>[A] sucker punches [D]!</span>", \
				  "<span class='userdanger'>[A] sucker punches you!</span>")     // hoping for more punch names or whatever, but no idea for now
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 40, 1, -1)
		D.apply_damage(rand(10,15), BRUTE)
		if(prob(20))
			D.Stun(20) //minimal stun
		return TRUE
	..()

/datum/martial_art/sec/headbutter
	name = "Hard Headed"
	desc = "Getting dropped as a child has given you some pretty hard times in life, now it shines. You can headbutt people, just make sure you AIM FOR THEIR HEAD and they have no helmets on."

/datum/martial_art/sec/headbutter/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	if(prob(50) && !istype(D.head, /obj/item/clothing/head/helmet) && A.zone_selected == BODY_ZONE_HEAD)
		A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
		D.visible_message("<span class='danger'>[A] headbutts [D]!</span>", \
				  "<span class='userdanger'>[A] headbutts you!</span>")
		playsound(get_turf(D), 'sound/weapons/punch1.ogg', 40, 1, -1)
		D.apply_damage(12, BRUTE, BODY_ZONE_HEAD)
		D.Knockdown(rand(5,30))
		return TRUE
	..()

/datum/martial_art/sec/grabber
	name = "Fierce Grabber"
	desc = "Apart from being an avid kleptomaniac in your youth, your grip has been strengthened. You can aggressively grab people faster than others."

/datum/martial_art/sec/grabber/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.grab_state >= GRAB_AGGRESSIVE)  // this isnt stolen from sleeping carp code, i dont know what you're talking about
		D.grabbedby(A, 1)
	else
		A.start_pulling(D, 1)
		if(A.pulling)
			D.drop_all_held_items()
			D.stop_pulling()
			if(A.a_intent == INTENT_GRAB)
				D.visible_message("<span class='warning'>[A] violently grabs [D]!</span>", \
				  "<span class='userdanger'>[A] violently grabs you!</span>")
				A.grab_state = GRAB_AGGRESSIVE
			else
				A.grab_state = GRAB_PASSIVE
	return TRUE

/datum/martial_art/sec/disarmer
	name = "Tactical Disarmer"
	desc = "Slapping weapons out of peoples hands? Pushing?! Those are weak tactics. You yank things out of peoples hands when disarming, but pushing them down is too dishonorable for you."

/datum/martial_art/sec/disarmer/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(prob(50))
		var/obj/item/I = D.get_active_held_item()
		if(I)
			if(D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
		D.visible_message("<span class='danger'>[A] has disarmed [D]!</span>", \
						"<span class='userdanger'>[A] has disarmed [D]!</span>")
		playsound(D, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
	else
		D.visible_message("<span class='danger'>[A] attempted to disarm [D]!</span>", \
							"<span class='userdanger'>[A] attempted to disarm [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
	return TRUE
