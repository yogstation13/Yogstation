/obj/item/toy/plush/goatplushie
	name = "goat plushie"
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "goat"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same. Goats never change."

/obj/item/toy/plush/goatplushie/angry
	var/mob/living/carbon/target
	throwforce = 6
	var/cooldown = 0
	var/cooldown_modifier = 20

/obj/item/toy/plush/goatplushie/angry/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/item/toy/plush/goatplushie/angry/process()
	if (prob(25) && !target)
		var/list/targets_to_pick_from = list()
		for(var/mob/living/carbon/C in view(7, src))
			if(considered_alive(C.mind))
				targets_to_pick_from += C
		if (!targets_to_pick_from.len)
			return
		target = pick(targets_to_pick_from)
		visible_message("<span class='notice'>[src] stares at [target].</span>")
	if (world.time > cooldown)
		ram()

/obj/item/toy/plush/goatplushie/angry/proc/ram()
	if(prob((obj_flags & EMAGGED) ? 98:90) && isturf(loc) && considered_alive(target.mind))
		throw_at(target, 10, 10)
		visible_message("<span class='danger'>[src] rams [target]!</span>")
		cooldown = world.time + cooldown_modifier
	target = null
	visible_message("<span class='notice'>[src] looks disinterested.</span>")

/obj/item/toy/plush/goatplushie/angry/emag_act(mob/user)
	if (obj_flags&EMAGGED)
		visible_message("<span class='notice'>[src] already looks angry enough, you shouldn't anger it more.</span>")
		return
	cooldown_modifier = 5
	throwforce = 20
	obj_flags |= EMAGGED
	visible_message("<span class='danger'>[src] stares at [user] angrily before going docile.</span>")

/obj/item/toy/plush/goatplushie/angry/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/toy/plush/teddybear
	name = "teddy bear"
	desc = "A soft brown bear you can cuddle with anywhere."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "teddybear"

/obj/item/toy/plush/stuffedmonkey
	name = "stuffed monkey"
	desc = "Looks just like the live ones on station. Except this one is made from plush."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "stuffedmonkey"

/obj/item/toy/plush/inorixplushie
	name = "inorix plushie"
	desc = "An adorable stuffed toy that resembles a giant robotic squid. It squirms around in your hand with realistic, buggy motion."
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "plushie_inorix"
	attack_verb = list("harkened", "glared", "erased")

/obj/item/toy/plush/flowerbunch
	name = "flower bunch"
	desc = "Oh, a bunch of flowers to show you care!"
	icon = 'yogstation/icons/obj/toy.dmi'
	icon_state = "flowerbunch"