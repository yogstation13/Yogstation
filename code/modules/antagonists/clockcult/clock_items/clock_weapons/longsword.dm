/obj/item/clockwork/weapon/brass_sword
	name = "brass longsword"
	desc = "A large sword made of brass."
	icon_state = "ratvarian_sword"
	force = 16
	throwforce = 20
	armour_penetration = 8
	attack_verb = list("attacked", "slashed", "cut", "torn", "gored")
	clockwork_desc = "A powerful sword of Ratvarian making. Enemies hit with it will be struck with a powerful electromagnetic pulse."
	var/emp_cooldown = 0

/obj/item/clockwork/weapon/brass_sword/attack(mob/living/target, mob/living/carbon/human/user)
	. = ..()
	if(world.time > emp_cooldown && !is_servant_of_ratvar(target))
		target.emp_act(EMP_LIGHT)
		emp_cooldown = world.time + 300
		addtimer(CALLBACK(src, .proc/send_message, user), 300)
		to_chat(user, "<span class='brass'>You strike [target] with an electromagnetic pulse!</span>")
		playsound(user, 'sound/magic/lightningshock.ogg', 40)

/obj/item/clockwork/weapon/brass_sword/proc/send_message(mob/living/target)
	to_chat(target, "<span class='brass'>[src] glows, indicating the next attack will disrupt electronics of the target.</span>")
