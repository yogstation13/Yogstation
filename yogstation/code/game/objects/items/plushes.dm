/obj/item/toy/plush/narplush
	var/is_invoker = TRUE // Part of preserving the plush's capacity to invoke. <3

/obj/item/toy/plush/narplush/hugbox
	desc = "A small stuffed doll of the elder goddess Nar'Sie. Who thought this was a good children's toy? <b>It looks sad.</b>"
	is_invoker = FALSE

/obj/item/toy/plush/goatplushie
	name = "strange goat plushie"
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
	if (world.time > cooldown && target)
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

/obj/item/toy/plush/goatplushie
	squeak_override = list('yogstation/sound/items/goatsound.ogg'=1)

/obj/item/toy/plush/goatplushie/angry/realgoat
	name = "goat plushie"
	icon_state = "realgoat"

/obj/item/toy/plush/realgoat
	name = "goat plushie"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same, or atleast it would if it wasnt a normal plushie."
	icon_state = "realgoat"
	squeak_override = list('yogstation/sound/items/goatsound.ogg'=1)

/obj/item/toy/plush/goatplushie/angry/kinggoat
	name = "King Goat Plushie"
	desc = "A plushie depicting the king of all goats."
	icon_state = "kinggoat"
	cooldown_modifier = 3
	throwforce = 25
	force = 25
	attack_verb = list("chomped")

/obj/item/toy/plush/goatplushie/angry/ascendedkinggoat
	name = "Ascended King Goat Plushie"
	desc = "A plushie depicting the god of all goats."
	icon_state = "ascendedkinggoat"
	cooldown_modifier = 1
	throwforce = 30
	force = 30
	attack_verb = list("chomped")

/obj/item/toy/plush/goatplushie/angry/ascendedkinggoat/attackby(obj/item/I,mob/living/user,params)
	if(I.is_sharp())
		user.visible_message("<span class='notice'>[user] attempts to stab [src]!</span>", "<span class='suicide'>[I] bounces off of [src]'s back before breaking into millions of pieces... [src] glares at [user]!</span>") // You fucked up now son
		I.play_tool_sound(src)
		qdel(I)
		addtimer(CALLBACK(user, /mob/living/.proc/gib), 3 SECONDS)

/obj/item/toy/plush/goatplushie/angry/kinggoat/attackby(obj/item/I,mob/living/user,params)
	if(I.is_sharp())
		user.visible_message("<span class='notice'>[user] stabs [src] to shreds!</span>", "<span class='notice'>[src]'s death has attracted the attention of the king goat plushie guards!</span>")
		I.play_tool_sound(src)
		qdel(src)
		var/turf/location = get_turf(user)
		new/obj/item/toy/plush/goatplushie/angry/masterguardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/masterguardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/masterguardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/masterguardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)
		new/obj/item/toy/plush/goatplushie/angry/guardgoat(location)

/obj/item/toy/plush/goatplushie/angry/kinggoat/attackby(/obj/item/reagent_containers/food/snacks/grown/cabbage/C,mob/living/user,params)
		var/C = /obj/item/reagent_containers/food/snacks/grown/cabbage
		user.visible_message("<span class='notice'>[user] watches as [src] takes a bite out of the cabbage!</span>", "<span class='notice'>[src]'s fur now starts glowing it seems it has ascended!</span>")
		playsound(src, 'sound/items/eatfood.ogg', 50, 1)
		qdel(C)
		qdel(src)
		var/turf/location = get_turf(user)
		new/obj/item/toy/plush/goatplushie/angry/ascendedkinggoat(location)


/obj/item/toy/plush/goatplushie/angry/guardgoat
	name = "guard goat plushie"
	desc = "A plushie depicting one of the king goats guards, tasked to protecting the king at all costs."
	icon_state = "guardgoat"
	cooldown_modifier = 5
	throwforce = 10

/obj/item/toy/plush/goatplushie/angry/masterguardgoat
	name = "royal guard goat plushie"
	desc = "A plushie depicting one of the royal king goats guards, tasked to protecting the king at all costs and training new goat guards."
	icon_state = "royalguardgoat"
	cooldown_modifier = 4
	throwforce = 15
