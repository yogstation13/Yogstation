/obj/effect/proc_holder/spell/targeted/touch/mime
	name = "Invisible Touch"
	desc = "It disappeared!"
	hand_path = "/obj/item/weapon/melee/touch_attack/nothing/roundstart" // there is a non roundstart version. can be found in godhand.dmi
	panel = "Mime"

	invocation_type = "emote"
	invocation_emote_self = "<span class='notice'>You blow on your finger.</span>"
	school = "mime"
	charge_max = 1000
	clothes_req = 0
	cooldown_min = 500

	action_icon_state = "nothing"


/obj/effect/proc_holder/spell/targeted/touch/mime/Click()
	if(usr && usr.mind)
		if(!usr.mind.miming)
			to_chat(usr, "<span class='notice'>You don't remember how to perform this... It probably takes dedication.</span>")
			return
	..()

/obj/effect/proc_holder/spell/targeted/touch/mime/strong
	hand_path = "/obj/item/weapon/melee/touch_attack/nothing"
	charge_max = 1500
	cooldown_min = 1000