/obj/item/toy/prizeball
	name = "prize ball"
	desc = "A toy is a toy, but a prize ball could be anything! It could even be a toy!"
	icon = 'icons/obj/arcade.dmi'
	icon_state = "prizeball_1"
	var/opening = 0

/obj/item/toy/prizeball/New()
	..()
	icon_state = pick("prizeball_1","prizeball_2","prizeball_3")

/obj/item/toy/prizeball/attack_self(mob/user as mob)
	if(opening)
		return
	opening = 1
	playsound(src.loc, 'sound/items/bubblewrap.ogg', 30, 1, extrarange = -4, falloff = 10)
	icon_state = "prizeconfetti"
	var/prize_inside = pick(/obj/item/toy/foamblade, /obj/item/twohanded/dualsaber/toy, /obj/item/toy/redbutton, /obj/item/toy/cards/deck, /obj/item/toy/clockwork_watch, /obj/item/toy/figure/assistant, /obj/item/toy/plush/narplush, /obj/item/toy/plush/teddybear, /obj/item/toy/plush/goatplushie/angry/kinggoat, /obj/item/toy/plush/realgoat, /obj/item/toy/plush/plushvar, /obj/item/toy/plush/nukeplushie, /obj/item/toy/plush/snakeplushie, /obj/item/toy/plush/slimeplushie, /obj/item/toy/plush/bubbleplush, /obj/item/toy/plush/carpplushie
)	//will add ticket bundles later
	spawn(10)
		user.unEquip(src)
		new prize_inside(user.loc)
		qdel(src) 
