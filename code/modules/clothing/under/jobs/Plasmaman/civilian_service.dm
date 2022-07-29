/obj/item/clothing/under/plasmaman/cargo
	name = "cargo envirosuit"
	desc = "A joint envirosuit used by plasmamen cargo techs, due to the logistical problems of differenciating the two with the length of their pant legs."
	icon_state = "cargo_envirosuit"
	item_state = "cargo_envirosuit"

/obj/item/clothing/under/plasmaman/qm
	name = "quartermaster's envirosuit"
	desc = "A joint envirosuit used by plasmamen quartermasters due to the logistical problems of differenciating the two with the length of their pant legs."
	icon_state = "qm_envirosuit"
	item_state = "qm_envirosuit"

/obj/item/clothing/under/plasmaman/mining
	name = "mining envirosuit"
	desc = "An air-tight grey suit designed for operations on lavaland by plasmamen."
	icon_state = "explorer_envirosuit"
	item_state = "explorer_envirosuit"


/obj/item/clothing/under/plasmaman/chef
	name = "chef's envirosuit"
	desc = "A white plasmaman envirosuit designed for cullinary practices. One might question why a member of a species that doesn't need to eat would become a chef."
	icon_state = "chef_envirosuit"
	item_state = "chef_envirosuit"

/obj/item/clothing/under/plasmaman/enviroslacks
	name = "enviroslacks"
	desc = "The pet project of a particularly posh plasmaman, this custom suit was quickly appropriated by Nano-Trasen for it's detectives, lawyers, and bar-tenders alike."
	icon_state = "enviroslacks"
	item_state = "enviroslacks"

/obj/item/clothing/under/plasmaman/chaplain
	name = "chaplain's envirosuit"
	desc = "An envirosuit specially designed for only the most pious of plasmamen."
	icon_state = "chap_envirosuit"
	item_state = "chap_envirosuit"

/obj/item/clothing/under/plasmaman/curator
	name = "prototype envirosuit"
	desc = "The far lighter, second-generation variant of the plasmaman uniforms designed by Nanotrasen. Unlike the first-generation variants, this uniform is made of fire-resistant fabrics, rather than clunky hardsuit plating. The latest extinguishers have also been installed."
	icon_state = "plasmaman_OLD"
	item_state = "plasmaman_OLD"

/obj/item/clothing/under/plasmaman/janitor
	name = "janitorial envirosuit"
	desc = "A purple envirosuit designated for plasmamen janitors."
	icon_state = "janitor_envirosuit"
	item_state = "janitor_envirosuit"

/obj/item/clothing/under/plasmaman/botany
	name = "botanical envirosuit"
	desc = "A green-blue envirosuit designed to protect plasmamen from minor plant-related injuries."
	icon_state = "botany_envirosuit"
	item_state = "botany_envirosuit"


/obj/item/clothing/under/plasmaman/mime
	name = "mime's envirosuit"
	desc = "It's not very colourful."
	icon_state = "mime_envirosuit"
	item_state = "mime_envirosuit"

/obj/item/clothing/under/plasmaman/clown
	name = "clown's envirosuit"
	desc = "<i>'HONK!'</i>"
	icon_state = "clown_envirosuit"
	item_state = "clown_envirosuit"

/obj/item/clothing/under/plasmaman/clown/Extinguish(mob/living/carbon/human/H)
	if(!istype(H))
		return

	if(H.on_fire)
		if(extinguishes_left)
			if(next_extinguish > world.time)
				return
			next_extinguish = world.time + extinguish_cooldown
			extinguishes_left--
			H.visible_message(span_warning("[H]'s suit spews out a tonne of space lube!"),span_warning("Your suit spews out a tonne of space lube!"))
			H.ExtinguishMob()
			new /obj/effect/particle_effect/foam(loc) //Truely terrifying.
	return 0
