/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable(feedback = FALSE)
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/
/// The Buster Arm (Left)
/// Same as the right one, but replaces your left arm!
/// Use it in-hand to swap its left or right mode
/// Attacking any human mob (typically yourself) will cause their arm to instantly be replaced with it
/obj/item/bodypart/l_arm/robot/buster
	name = "left buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "left_buster_arm"
	max_damage = 50
	aux_layer = 12
	var/datum/action/cooldown/buster/megabuster/l/megabuster_action = new/datum/action/cooldown/buster/megabuster/l()
	var/datum/martial_art/buster_style/buster_style = new

/// Set up our actions, disable gloves
/obj/item/bodypart/l_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	megabuster_action.Grant(N)
	if(N.mind.martial_art.type != buster_style) //you've already got buster style.
		buster_style.teach(N)
	to_chat(owner, "[span_boldannounce("You've gained the ability to use Buster Style!")]")

/// Remove our actions, re-enable gloves
/obj/item/bodypart/l_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/obj/item/bodypart/r_arm = N.get_bodypart(BODY_ZONE_R_ARM)
	megabuster_action.Remove(N)
	if(!istype(r_arm, /obj/item/bodypart/r_arm/robot/buster)) //got another arm, don't remove it then.
		buster_style.remove(N)
		N.click_intercept = null
		to_chat(owner, "[span_boldannounce("You've lost the ability to use Buster Style...")]")
	..()

/// Attacking a human mob with the arm causes it to instantly replace their arm
/obj/item/bodypart/l_arm/robot/buster/attack(mob/living/L, proximity)
	if(get_turf(L) != get_turf(src)) //putting the arm on someone else makes the moveset just not work for some reason so please dont
		return
	if(!ishuman(L))
		return
	if((L.mind.martial_art != L.mind.default_martial_art) && !(istype(L.mind.martial_art, /datum/martial_art/cqc/under_siege))) //prevents people from learning several martial arts or swapping between them
		to_chat(L, span_warning("You are already dedicated to using [L.mind.martial_art.name]!"))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your left arm!"))
	replace_limb(L)

/// Using the arm in-hand switches the arm it replaces
/obj/item/bodypart/l_arm/robot/buster/attack_self(mob/user)
	. = ..()
	var/obj/item/bodypart/r_arm/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the right arm."))
	qdel(src)
	
/// Same code as above, but set up for the right arm instead
/obj/item/bodypart/r_arm/robot/buster
	name = "right buster arm"
	desc = "A robotic arm designed explicitly for combat and providing the user with extreme power. <b>It can be configured by hand to fit on the opposite arm.</b>"
	icon = 'icons/mob/augmentation/augments_buster.dmi'
	icon_state = "right_buster_arm"
	max_damage = 50
	aux_layer = 12
	var/datum/action/cooldown/buster/megabuster/r/megabuster_action = new/datum/action/cooldown/buster/megabuster/r()
	var/datum/martial_art/buster_style/buster_style = new

/// Set up our actions, disable gloves
/obj/item/bodypart/r_arm/robot/buster/attach_limb(mob/living/carbon/N, special)
	. = ..()
	megabuster_action.Grant(N)
	buster_style.teach(N)
	to_chat(owner, span_boldannounce("You've gained the ability to use Buster Style!"))

/// Remove our actions, re-enable gloves
/obj/item/bodypart/r_arm/robot/buster/drop_limb(special)
	var/mob/living/carbon/N = owner
	var/obj/item/bodypart/l_arm = N.get_bodypart(BODY_ZONE_L_ARM)
	megabuster_action.Remove(N)
	if(!istype(l_arm, /obj/item/bodypart/l_arm/robot/buster))
		buster_style.remove(N)
		N.click_intercept = null
		to_chat(owner, "[span_boldannounce("You've lost the ability to use Buster Style...")]")
	..()

/// Attacking a human mob with the arm causes it to instantly replace their arm
/obj/item/bodypart/r_arm/robot/buster/attack(mob/living/L, proximity)
	if(get_turf(L) != get_turf(src))
		return
	if(!ishuman(L))
		return
	if((L.mind.martial_art != L.mind.default_martial_art) && !(istype(L.mind.martial_art, /datum/martial_art/cqc/under_siege))) //prevents people from learning several martial arts or swapping between them
		to_chat(L, span_warning("You are already dedicated to using [L.mind.martial_art.name]!"))
		return
	playsound(L,'sound/effects/phasein.ogg', 20, 1)
	to_chat(L, span_notice("You bump the prosthetic near your shoulder. In a flurry faster than your eyes can follow, it takes the place of your right arm!"))
	replace_limb(L)

/// Using the arm in-hand switches the arm it replaces
/obj/item/bodypart/r_arm/robot/buster/attack_self(mob/user)
	. = ..()
	var/obj/item/bodypart/l_arm/robot/buster/opphand = new(get_turf(src))
	opphand.brute_dam = src.brute_dam
	opphand.burn_dam = src.burn_dam 
	to_chat(user, span_notice("You modify [src] to be installed on the left arm."))
	qdel(src)
