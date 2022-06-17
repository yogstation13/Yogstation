/obj/item/organ/heart/gland/spiderman
	abductor_hint = "araneae cloister accelerator. It makes that the abductee occasionally exhales spider pheromones and will spawn spiderlings."
	cooldown_low = 45 SECONDS
	cooldown_high = 90 SECONDS
	icon_state = "spider"
	mind_control_uses = 2
	mind_control_duration = 4 MINUTES

/obj/item/organ/heart/gland/spiderman/activate()
	to_chat(owner, span_warning("You feel something crawling in your skin."))
	owner.faction |= "spiders"
	var/obj/structure/spider/spiderling/S = new(owner.drop_location())
	S.directive = "Protect your nest inside [owner.real_name]."
