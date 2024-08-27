/datum/smite/choke_on_this
	name = "Choke on this!"
	var/to_paper = null
	var/choke_object = null

/datum/smite/choke_on_this/configure(client/user)
	var/thingy = "Choke on thing?"
	var/words = "Choke on words!"
	var/selection = tgui_alert(user, "What shall they choke upon m'lord?", "Choke on this!", list(words, thingy, "nevermind"), 0, TRUE)
	if(selection == words)
		to_paper = tgui_input_text(user, "What words do you want them to choke on?", "Admins stink!", max_length = 250, multiline = TRUE)
	else if(selection == thingy)
		choke_object = tgui_input_text(user, "What Object shall they choke on? must be a descendant /datum/atom/moveable, if you can't imagine it moving it shouldn't be used. An example is provided. /obj/item/clothing/shoes/sneakers/white", "What Object shall they choke on?", max_length = 250, multiline = TRUE )
	else
		return

/datum/smite/choke_on_this/effect(client/user, mob/living/target)
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	//var/mob/living/carbon/carbon_target = target
	var/chokerino = text2path(choke_object)
	if(to_paper != null)
		var/obj/item/paper/choke_paper = new
		choke_paper.add_raw_text(to_paper)
		target.AddComponent(/datum/status_effect/choke, choke_paper, flaming = FALSE, vomit_delay = -1)
	else if(chokerino != null)
		var/choke_obj = new chokerino
		target.AddComponent(/datum/status_effect/choke, choke_obj, flaming = FALSE, vomit_delay = -1)
	else
		to_chat(user, span_warning("Nothing Selected"), confidential = TRUE)
		return
