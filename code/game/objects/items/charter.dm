#define STATION_RENAME_TIME_LIMIT (10 MINUTES)

/obj/item/station_charter
	name = "station charter"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	desc = "An official document entrusting the governance of the station \
		and surrounding space to the Captain."
	var/used = FALSE
	var/name_type = "station"

	var/unlimited_uses = FALSE
	var/ignores_timeout = FALSE
	var/response_timer_id = null
	var/approval_time = 600

	var/static/regex/standard_station_regex
	var/datum/callback/rename_callback // Yogs -- We actually keep track of this in order to be able to manually call this callback if an admin choses to do so.

/obj/item/station_charter/Initialize()
	. = ..()
	if(!standard_station_regex)
		var/prefixes = jointext(GLOB.station_prefixes, "|")
		var/names = jointext(GLOB.station_names, "|")
		var/suffixes = jointext(GLOB.station_suffixes, "|")
		var/numerals = jointext(GLOB.station_numerals, "|")
		var/regexstr = "^(([prefixes]) )?(([names]) ?)([suffixes]) ([numerals])$"
		standard_station_regex = new(regexstr)

/obj/item/station_charter/attack_self(mob/living/user)
	if(used)
		to_chat(user, "The [name_type] has already been named.")
		return
	if(!ignores_timeout && (world.time-SSticker.round_start_time > STATION_RENAME_TIME_LIMIT)) //10 minutes
		to_chat(user, "The crew has already settled into the shift. It probably wouldn't be good to rename the [name_type] right now.")
		return
	if(response_timer_id)
		to_chat(user, "You're still waiting for approval from your employers about your proposed name change, it'd be best to wait for now.")
		return

	//Yogs start -- Better Charter
	var/new_name = input(user, "What do you want to name \
		[station_name()]? Keep in mind particularly terrible names may be \
		rejected by your employers, while names using the standard format, \
		will automatically be accepted.", "Set Station Name") as text|null
	if(!new_name)
		return
	new_name = strip_html_simple(new_name,MAX_CHARTER_LEN)
	if(!length(new_name)) // <><><><><> is such a weird name for a station, don't you think?
		return

	if(isnotpretty(new_name)) // Yogs bigotry filter
		to_chat(user,"That's not a terribly good name for a space station.")
		message_admins("[ADMIN_LOOKUPFLW(user)] just attempted to name the station something bad: '[new_name]'")
		return

	if(response_timer_id)
		to_chat(user, "You're still waiting for approval from your employers about your proposed name change, it'd be best to wait for now.")
		return

	log_game("[key_name(user)] has proposed to name the station as \
		[new_name]")

	if(standard_station_regex.Find(new_name))
		to_chat(user, "Your name has been automatically approved.")
		rename_station(new_name, user.name, user.real_name, key_name(user))
		return

	to_chat(user, "Your name has been sent to your employers for approval.")
	// Autoapproves after a certain time
	rename_callback = CALLBACK(src, .proc/rename_station, new_name, user.name, user.real_name, key_name(user))
	response_timer_id = addtimer(rename_callback, approval_time, TIMER_STOPPABLE)
	to_chat(GLOB.permissions.admins,
		span_adminnotice("<b><font color=orange>CUSTOM STATION RENAME:</font></b>[ADMIN_LOOKUPFLW(user)] proposes to rename the [name_type] to [new_name] (will auto-approve in [DisplayTimeText(approval_time)]).\
		(<a HREF='?_src_=holder;[HrefToken(TRUE)];accept_custom_name=[REF(src)]'>ACCEPT</a> or <a HREF='?_src_=holder;[HrefToken(TRUE)];reject_custom_name=[REF(src)]'>REJECT</a>) [ADMIN_SMITE(user)] [ADMIN_CENTCOM_REPLY(user)]"))

/obj/item/station_charter/proc/accept_proposed(user)
	if(!user)
		return
	if(!response_timer_id)
		return
	deltimer(response_timer_id)
	response_timer_id = null

	var/m = "[key_name(user)] has manually accepted the proposed station name."
	message_admins(m)
	log_admin(m)

	rename_callback.Invoke()
	rename_callback = null

/obj/item/station_charter/proc/reject_proposed(user)
	if(!user)
		return
	if(!response_timer_id)
		return
	deltimer(response_timer_id) // Doing this first to make sure we're not having a race with all the rubbish below
	response_timer_id = null
	rename_callback = null

	var/turf/T = get_turf(src)
	T.visible_message("<span class='warning'>The proposed changes disappear \
		from [src]; it looks like they've been rejected.</span>")
	var/m = "[key_name(user)] has rejected the proposed station name."

	message_admins(m)
	log_admin(m)

/obj/item/station_charter/proc/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] has designated your station as [station_name()]", "Captain's Charter", 0)
	log_game("[ukey] has renamed the station as [station_name()].")

	name = "station charter for [station_name()]"
	desc = "An official document entrusting the governance of \
		[station_name()] and surrounding space to Captain [uname]."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

/obj/item/station_charter/admin
	unlimited_uses = TRUE
	ignores_timeout = TRUE


/obj/item/station_charter/flag
	name = "nanotrasen banner"
	icon = 'icons/obj/banners.dmi'
	name_type = "planet"
	icon_state = "banner"
	item_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A cunning device used to claim ownership of planets."
	w_class = 5
	force = 15

/obj/item/station_charter/flag/rename_station(designation, uname, ureal_name, ukey)
	set_station_name(designation)
	minor_announce("[ureal_name] has designated the planet as [station_name()]", "Captain's Banner", 0)
	log_game("[ukey] has renamed the planet as [station_name()].")
	name = "banner of [station_name()]"
	desc = "The banner bears the official coat of arms of Nanotrasen, signifying that [station_name()] has been claimed by Captain [uname] in the name of the company."
	SSblackbox.record_feedback("text", "station_renames", 1, "[station_name()]")
	if(!unlimited_uses)
		used = TRUE

#undef STATION_RENAME_TIME_LIMIT
