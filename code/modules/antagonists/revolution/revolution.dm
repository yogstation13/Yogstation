//How often to check for promotion possibility
#define HEAD_UPDATE_PERIOD 300
#define REVOLUTION_VICTORY 1
#define STATION_VICTORY 2

/datum/antagonist/rev
	name = "Revolutionary"
	roundend_category = "revolutionaries" // if by some miracle revolutionaries without revolution happen
	antagpanel_category = "Revolution"
	job_rank = ROLE_REV
	antag_moodlet = /datum/mood_event/revolution
	antag_hud_name = "rev"
	count_towards_antag_cap = TRUE
	var/datum/team/revolution/rev_team

/datum/antagonist/rev/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		if(new_owner.assigned_role in GLOB.command_positions)
			return FALSE
		if(new_owner.unconvertable)
			return FALSE
		if(new_owner.current && HAS_TRAIT(new_owner.current, TRAIT_MINDSHIELD))
			return FALSE
		var/list/no_team_antag = list(
			/datum/antagonist/clockcult,
			/datum/antagonist/darkspawn,
			/datum/antagonist/cult,
			/datum/antagonist/zombie
			)
		for(var/datum/antagonist/NTA in new_owner.antag_datums)
			if(NTA.type in no_team_antag)
				return FALSE

/datum/antagonist/rev/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/M = mob_override || owner.current
	M.grant_language(/datum/language/french, TRUE, TRUE, LANGUAGE_REVOLUTIONARY)
	M.throw_alert("revolution", /atom/movable/screen/alert/revolution)
	add_team_hud(M, /datum/antagonist/rev)

/datum/antagonist/rev/remove_innate_effects(mob/living/mob_override)
	var/mob/living/M = mob_override || owner.current
	M.remove_language(/datum/language/french, TRUE, TRUE, LANGUAGE_REVOLUTIONARY)
	M.clear_alert("revolution")
	return ..()

/datum/antagonist/rev/proc/equip_rev()
	return

/datum/antagonist/rev/on_gain()
	. = ..()
	equip_rev()
	owner.current.log_message("has been converted to the revolution!", LOG_ATTACK, color="red")

/datum/antagonist/rev/greet()
	to_chat(owner, span_userdanger("You are now a revolutionary! Help your cause. Do not harm your fellow freedom fighters. You can identify your comrades by the red \"R\" icons, and your leaders by the blue \"R\" icons. Help them kill the heads to win the revolution!"))
	owner.announce_objectives()

/datum/antagonist/rev/create_team(datum/team/revolution/new_team)
	if(!new_team)
		//For now only one revolution at a time
		for(var/datum/antagonist/rev/head/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.rev_team)
				rev_team = H.rev_team
				return
		rev_team = new /datum/team/revolution
		rev_team.update_objectives()
		rev_team.update_heads()
		return
	if(!istype(new_team))
		stack_trace("Wrong team type passed to [type] initialization.")
	rev_team = new_team

/datum/antagonist/rev/get_team()
	return rev_team

//Bump up to head_rev
/datum/antagonist/rev/proc/promote()
	var/old_team = rev_team
	var/datum/mind/old_owner = owner
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/rev)
	var/datum/antagonist/rev/head/new_revhead = new()
	new_revhead.silent = TRUE
	old_owner.add_antag_datum(new_revhead,old_team)
	new_revhead.silent = FALSE
	to_chat(old_owner, span_userdanger("You have proved your devotion to revolution! You are a head revolutionary now!"))


/datum/antagonist/rev/get_admin_commands()
	. = ..()
	.["Promote"] = CALLBACK(src, PROC_REF(admin_promote))

/datum/antagonist/rev/proc/admin_promote(mob/admin)
	var/datum/mind/O = owner
	promote()
	message_admins("[key_name_admin(admin)] has head-rev'ed [O].")
	log_admin("[key_name(admin)] has head-rev'ed [O].")

/datum/antagonist/rev/head/admin_add(datum/mind/new_owner,mob/admin)
	give_flash = TRUE
	give_hud = TRUE
	remove_clumsy = TRUE
	new_owner.add_antag_datum(src)
	message_admins("[key_name_admin(admin)] has head-rev'ed [key_name_admin(new_owner)].")
	log_admin("[key_name(admin)] has head-rev'ed [key_name(new_owner)].")
	to_chat(new_owner.current, span_userdanger("You are a member of the revolutionaries' leadership now!"))

/datum/antagonist/rev/head/get_admin_commands()
	. = ..()
	. -= "Promote"
	.["Take flash"] = CALLBACK(src, PROC_REF(admin_take_flash))
	.["Give flash"] = CALLBACK(src, PROC_REF(admin_give_flash))
	.["Repair flash"] = CALLBACK(src, PROC_REF(admin_repair_flash))
	.["Demote"] = CALLBACK(src, PROC_REF(admin_demote))

/datum/antagonist/rev/head/proc/admin_take_flash(mob/admin)
	var/obj/item/organ/cyberimp/arm/flash/rev/flash = owner.current.getorgan(/obj/item/organ/cyberimp/arm/flash/rev)
	if (!flash)
		to_chat(admin, span_danger("Deleting flash failed!"))
		return
	qdel(flash)

/datum/antagonist/rev/head/proc/admin_give_flash(mob/admin)
	//This is probably overkill but making these impact state annoys me
	var/old_give_flash = give_flash
	var/old_give_hud = give_hud
	var/old_remove_clumsy = remove_clumsy
	give_flash = TRUE
	give_hud = FALSE
	remove_clumsy = FALSE
	equip_rev()
	give_flash = old_give_flash
	give_hud = old_give_hud
	remove_clumsy = old_remove_clumsy

/datum/antagonist/rev/head/proc/admin_repair_flash(mob/admin)
	var/list/L = owner.current.get_contents()
	var/obj/item/assembly/flash/flash = locate() in L
	if (!flash)
		to_chat(admin, span_danger("Repairing flash failed!"))
	else
		flash.burnt_out = FALSE
		flash.update_appearance(UPDATE_ICON)

/datum/antagonist/rev/head/proc/admin_demote(datum/mind/target,mob/user)
	message_admins("[key_name_admin(user)] has demoted [key_name_admin(owner)] from head revolutionary.")
	log_admin("[key_name(user)] has demoted [key_name(owner)] from head revolutionary.")
	demote()

/datum/antagonist/rev/head
	name = "Head Revolutionary"
	antag_hud_name = "rev_head"
	var/remove_clumsy = FALSE
	var/give_flash = TRUE
	var/give_hud = TRUE
	preview_outfit = /datum/outfit/revolutionary

/datum/antagonist/rev/head/antag_listing_name()
	return ..() + "(Leader)"

/datum/antagonist/rev/head/on_gain(mob/living/carbon/human)
	if(owner.current)
		equip_head()
	return ..()

/datum/antagonist/rev/head/get_preview_icon()
	var/icon/final_icon = render_preview_outfit(preview_outfit)

	final_icon.Blend(make_assistant_icon("Business Hair"), ICON_UNDERLAY, -8, 0)
	final_icon.Blend(make_assistant_icon("CIA"), ICON_UNDERLAY, 8, 0)

	// Apply the rev head HUD, but scale up the preview icon a bit beforehand.
	// Otherwise, the R gets cut off.
	final_icon.Scale(64, 64)

	var/icon/rev_head_icon = icon('yogstation/icons/mob/antag_hud.dmi', "rev_head")
	rev_head_icon.Scale(48, 48)
	rev_head_icon.Crop(1, 1, 64, 64)
	rev_head_icon.Shift(EAST, 10)
	rev_head_icon.Shift(NORTH, 16)
	final_icon.Blend(rev_head_icon, ICON_OVERLAY)

	return finish_preview_icon(final_icon)

/datum/antagonist/rev/head/proc/make_assistant_icon(hairstyle)
	var/mob/living/carbon/human/dummy/consistent/assistant = new
	assistant.hair_style = hairstyle
	assistant.update_hair()

	var/icon/assistant_icon = render_preview_outfit(/datum/outfit/job/assistant/consistent, assistant)
	assistant_icon.ChangeOpacity(0.5)

	qdel(assistant)

	return assistant_icon

/datum/antagonist/rev/head/proc/equip_head()
	var/obj/item/book/granter/crafting_recipe/weapons/W = new
	W.on_reading_finished(owner.current)
	qdel(W)

/datum/antagonist/rev/proc/can_be_converted(mob/living/candidate)
	if(!candidate.mind)
		return FALSE
	if(!can_be_owned(candidate.mind))
		return FALSE
	if(is_synth(candidate))
		return FALSE
	var/mob/living/carbon/C = candidate //Check to see if the potential rev is implanted
	if(!istype(C)) //Can't convert simple animals
		return FALSE
	return TRUE

/datum/antagonist/rev/proc/add_revolutionary(datum/mind/rev_mind,stun = TRUE)
	if(!can_be_converted(rev_mind.current))
		return FALSE
	if(stun)
		if(iscarbon(rev_mind.current))
			var/mob/living/carbon/carbon_mob = rev_mind.current
			carbon_mob.silent = max(carbon_mob.silent, 5)
			carbon_mob.flash_act(1, 1)
		rev_mind.current.Stun(100)
	rev_mind.add_antag_datum(/datum/antagonist/rev,rev_team)
	rev_mind.special_role = ROLE_REV
	return TRUE

/datum/antagonist/rev/head/proc/demote()
	var/datum/mind/old_owner = owner
	var/old_team = rev_team
	silent = TRUE
	owner.remove_antag_datum(/datum/antagonist/rev/head)
	var/datum/antagonist/rev/new_rev = new /datum/antagonist/rev()
	new_rev.silent = TRUE
	old_owner.add_antag_datum(new_rev,old_team)
	new_rev.silent = FALSE
	to_chat(old_owner, span_userdanger("Revolution has been disappointed of your leader traits! You are a regular revolutionary now!"))

/datum/antagonist/rev/farewell()
	if(ishuman(owner.current) || ismonkey(owner.current))
		owner.current.visible_message("[span_deconversion_message("[owner.current] looks like [owner.current.p_theyve()] just remembered [owner.current.p_their()] real allegiance!")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("You are no longer a brainwashed revolutionary! Your memory is hazy from the time you were a rebel...the only thing you remember is the name of the one who brainwashed you..."))
	else if(issilicon(owner.current))
		owner.current.visible_message("[span_deconversion_message("The frame beeps contentedly, purging the hostile memory engram from the MMI before initalizing it.")]", null, null, null, owner.current)
		to_chat(owner, span_userdanger("The frame's firmware detects and deletes your neural reprogramming! You remember nothing but the name of the one who flashed you."))

//blunt trauma deconversions call this through species.dm spec_attacked_by()
/datum/antagonist/rev/proc/remove_revolutionary(borged, deconverter)
	log_attack("[key_name(owner.current)] has been deconverted from the revolution by [ismob(deconverter) ? key_name(deconverter) : deconverter]!")
	if(borged)
		message_admins("[ADMIN_LOOKUPFLW(owner.current)] has been borged while being a [name]")
	owner.special_role = null
	if(iscarbon(owner.current))
		var/mob/living/carbon/C = owner.current
		C.Unconscious(100)
	owner.remove_antag_datum(type)

/datum/antagonist/rev/head/remove_revolutionary(borged,deconverter)
	if(borged || deconverter == "gamemode")
		. = ..()

/datum/antagonist/rev/head/equip_rev()
	var/mob/living/carbon/H = owner.current
	if(!ishuman(H) && !ismonkey(H))
		return

	handle_clown_mutation(owner.current, "Your training has allowed you to overcome your clownish nature, allowing you to wield weapons without harming yourself.")

	if(give_flash)
		var/obj/item/organ/cyberimp/arm/flash/rev/T = new
		T.Insert(H, special = TRUE, drop_if_replaced = FALSE)
		to_chat(H, span_boldnotice("The flash implant in your arm will allow you to persuade the crew to join your cause. It is one of a kind, so do not lose it."))

	if(give_hud)
		var/obj/item/organ/cyberimp/eyes/hud/security/syndicate/S = new(H)
		S.Insert(H, special = FALSE, drop_if_replaced = FALSE)
		to_chat(H, "Your eyes have been implanted with a cybernetic security HUD which will help you keep track of who is mindshield-implanted, and therefore unable to be recruited.")

/datum/antagonist/rev/head/on_gain()
	. = ..()
	company = /datum/corporation/bolsynpowell
	owner.add_employee(company)
	to_chat(owner.current, "<span class='notice'>Your employer [initial(company.name)] will be paying you an extra [initial(company.paymodifier)]x your nanotrasen paycheck.")

/datum/antagonist/rev/head/on_removal()
	.=..()
	owner.remove_employee(company)

/datum/team/revolution
	name = "Revolution"
	var/max_headrevs = 3
	var/list/ex_headrevs = list() // Dynamic removes revs on loss, used to keep a list for the roundend report.
	var/list/ex_revs = list()

/datum/team/revolution/proc/update_objectives(initial = FALSE)
	var/untracked_heads = SSjob.get_all_heads()
	for(var/datum/objective/mutiny/O in objectives)
		untracked_heads -= O.target
	for(var/datum/mind/M in untracked_heads)
		var/datum/objective/mutiny/new_target = new()
		new_target.team = src
		new_target.target = M
		new_target.update_explanation_text()
		objectives += new_target
	for(var/datum/mind/M in members)
		var/datum/antagonist/rev/R = M.has_antag_datum(/datum/antagonist/rev)
		R.objectives |= objectives

	addtimer(CALLBACK(src, PROC_REF(update_objectives)),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/datum/team/revolution/proc/head_revolutionaries()
	. = list()
	for(var/datum/mind/M in members)
		if(M.has_antag_datum(/datum/antagonist/rev/head))
			. += M

/datum/team/revolution/proc/update_heads()
	if(SSticker.HasRoundStarted())
		var/list/datum/mind/head_revolutionaries = head_revolutionaries()
		var/list/datum/mind/heads = SSjob.get_all_heads()
		var/list/sec = SSjob.get_all_sec()

		if(head_revolutionaries.len < max_headrevs && head_revolutionaries.len < round(heads.len - ((8 - sec.len) / 3)))
			var/list/datum/mind/non_heads = members - head_revolutionaries
			var/list/datum/mind/promotable = list()
			var/list/datum/mind/nonhuman_promotable = list()
			for(var/datum/mind/khrushchev in non_heads)
				if(khrushchev.current && !khrushchev.current.incapacitated() && !khrushchev.current.restrained() && khrushchev.current.client && khrushchev.current.stat != DEAD)
					if(ROLE_REV in khrushchev.current.client.prefs.be_special)
						if(ishuman(khrushchev.current))
							promotable += khrushchev
						else
							nonhuman_promotable += khrushchev
			if(!promotable.len && nonhuman_promotable.len) //if only nonhuman revolutionaries remain, promote one of them to the leadership.
				promotable = nonhuman_promotable
			if(promotable.len)
				var/datum/mind/new_leader = pick(promotable)
				var/datum/antagonist/rev/rev = new_leader.has_antag_datum(/datum/antagonist/rev)
				rev.promote()

	addtimer(CALLBACK(src, PROC_REF(update_heads)),HEAD_UPDATE_PERIOD,TIMER_UNIQUE)

/datum/team/revolution/proc/save_members()
	ex_headrevs = get_antag_minds(/datum/antagonist/rev/head, TRUE)
	ex_revs = get_antag_minds(/datum/antagonist/rev, TRUE)

/datum/team/revolution/proc/check_victory()
	for(var/datum/objective/O in objectives)
		if(!O.check_completion())
			return FALSE
	return TRUE

/datum/team/revolution/proc/round_result(finished)
	if (finished == REVOLUTION_VICTORY)
		SSticker.mode_result = "win - heads killed"
		SSticker.news_report = REVS_WIN
	else if (finished == STATION_VICTORY)
		SSticker.mode_result = "loss - rev heads killed"
		SSticker.news_report = REVS_LOSE
		
/datum/team/revolution/roundend_report()
	if(!members.len && !ex_headrevs.len)
		return

	var/list/result = list()

	result += "<div class='panel redborder'>"

	var/num_revs = 0
	var/num_survivors = 0
	for(var/mob/living/carbon/survivor in GLOB.alive_mob_list)
		if(survivor.ckey)
			num_survivors++
			if(survivor.mind)
				if(IS_REVOLUTIONARY(survivor))
					num_revs++
	if(num_survivors)
		result += "Command's Approval Rating: <B>[100 - round((num_revs/num_survivors)*100, 0.1)]%</B><br>"


	var/list/targets = list()
	var/list/datum/mind/headrevs
	var/list/datum/mind/revs
	if(ex_headrevs.len)
		headrevs = ex_headrevs
	else
		headrevs = get_antag_minds(/datum/antagonist/rev/head, TRUE)

	if(ex_revs.len)
		revs = ex_revs
	else
		revs = get_antag_minds(/datum/antagonist/rev, TRUE)

	if(check_victory())
		for(var/H in revs)
			var/datum/mind/M = H
			SSachievements.unlock_achievement(/datum/achievement/greentext/revolution,M.current.client)
			if(M.has_antag_datum(/datum/antagonist/rev/head))
				SSachievements.unlock_achievement(/datum/achievement/greentext/revolution/head,M.current.client)

	if(headrevs.len)
		var/list/headrev_part = list()
		headrev_part += span_header("The head revolutionaries were:")
		headrev_part += printplayerlist(headrevs,TRUE)
		result += headrev_part.Join("<br>")

	if(revs.len)
		var/list/rev_part = list()
		rev_part += span_header("The revolutionaries were:")
		rev_part += printplayerlist(revs,TRUE)
		result += rev_part.Join("<br>")

	var/list/heads = SSjob.get_all_heads()
	if(heads.len)
		var/head_text = span_header("The heads of staff were:")
		head_text += "<ul class='playerlist'>"
		for(var/datum/mind/head in heads)
			var/target = (head in targets)
			head_text += "<li>"
			if(target)
				head_text += span_redtext("Target")
			head_text += "[printplayer(head, 1)]</li>"
		head_text += "</ul><br>"
		result += head_text

	result += "</div>"

	return result.Join()

/datum/team/revolution/antag_listing_entry()
	var/common_part = ""
	var/list/parts = list()
	parts += "<b>[antag_listing_name()]</b><br>"
	parts += "<table cellspacing=5>"

	var/list/heads = get_team_antags(/datum/antagonist/rev/head,TRUE)

	for(var/datum/antagonist/A in heads | get_team_antags())
		parts += A.antag_listing_entry()

	parts += "</table>"
	parts += antag_listing_footer()
	common_part = parts.Join()

	var/heads_report = "<b>Heads of Staff</b><br>"
	heads_report += "<table cellspacing=5>"
	for(var/datum/mind/N in SSjob.get_living_heads())
		var/mob/M = N.current
		if(M)
			heads_report += "<tr><td><a href='byond://?_src_=holder;[HrefToken()];adminplayeropts=[REF(M)]'>[M.real_name]</a>[M.client ? "" : " <i>(No Client)</i>"][M.stat == DEAD ? " <b><font color=red>(DEAD)</font></b>" : ""]</td>"
			heads_report += "<td><A href='byond://?priv_msg=[M.ckey]'>PM</A></td>"
			heads_report += "<td><A href='byond://?_src_=holder;[HrefToken()];adminplayerobservefollow=[REF(M)]'>FLW</a></td>"
			var/turf/mob_loc = get_turf(M)
			heads_report += "<td>[mob_loc.loc]</td></tr>"
		else
			heads_report += "<tr><td><a href='byond://?_src_=vars;[HrefToken()];Vars=[REF(N)]'>[N.name]([N.key])</a><i>Head body destroyed!</i></td>"
			heads_report += "<td><A href='byond://?priv_msg=[N.key]'>PM</A></td></tr>"
	heads_report += "</table>"
	return common_part + heads_report

/datum/team/revolution/is_gamemode_hero()
	return SSgamemode.name == "revolution"

/datum/outfit/revolutionary
	name = "Revolutionary (Preview only)"

	uniform = /obj/item/clothing/under/yogs/soviet_dress_uniform
	head = /obj/item/clothing/head/ushanka
	gloves = /obj/item/clothing/gloves/color/black
	l_hand = /obj/item/melee/spear
	r_hand = /obj/item/assembly/flash
