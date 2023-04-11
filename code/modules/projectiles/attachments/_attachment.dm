// Attachment space bitflags.
// Attachments that are not exclusive i.e. attaches to the barrel should have an attachment_type of 0.
#define TYPE_SIGHT (1<<0) // Scopes, sights
#define TYPE_BARREL (1<<1) // Shorter, longer, or otherwise modified barrel
#define TYPE_TRIGGER (1<<2) // Modified trigger
#define TYPE_FOREGRIP (1<<3) // Foregrip

/// Base attachment.
/// "_a" icons should be 5x5 pixels.
/// See icons/obj/guns/attachment.dmi.
/obj/item/attachment
	name = "attachment"
	desc = "It's an attachment."
	icon = 'icons/obj/guns/attachment.dmi'

	/// Attached sprite adds "_a" e.g. "iconname_a"
	icon_state = "_error"

	var/obj/item/gun/attached_gun

	/// If the attachment can be "turned on", it will use "_on" e.g. "iconname_on_a" and "iconname_on".
	/// It is important to note that not all attachments can be turned on, so you don't have to worry about this most of the time.
	var/is_on = FALSE 

	/// Attachments that are not exclusive i.e. attaches to the side of the barrel should have an attachment_type of 0.
	/// Otherwise, use one or many bitflags to represent the exclusive space this attachment should occuy.
	var/attachment_type = 0

	/// "You slide the attachment into place on gun."
	var/attach_verb = "slide"

	var/mob/current_user = null

	/// List of actions to add to the gun when attached.
	/// See code/modules/projectiles/attachments/laser_sight.dm for example.
	var/list/actions_list = list()

/obj/item/attachment/update_icon()
	icon_state = "[initial(icon_state)][is_on ? "_on" : ""]"
	. = ..()
	attached_gun?.update_attachments()

/obj/item/attachment/Destroy()
	if(attached_gun)
		on_detach(attached_gun)
	. = ..()

/// Called when the attacment is attached to a weapon
/obj/item/attachment/proc/on_attach(obj/item/gun/G, mob/user = null)
	attached_gun = G

	for(var/act in actions_list)
		var/datum/action/attachment_action = new act(G)
		G.attachment_actions += attachment_action
		if(user && G.loc == user)
			attachment_action.Grant(user)
	
	if(G.loc == user)
		set_user(user)
		if(user.is_holding(G))
			pickup_user(user)
	G.attachment_flags |= attachment_type
	G.current_attachments += src
	G.update_attachments()
	forceMove(G)

	if(user)
		current_user = user

/// Called when the attachment is detached from a weapon
/obj/item/attachment/proc/on_detach(obj/item/gun/G, mob/living/user = null)
	for(var/act_type in actions_list)
		for(var/stored_attachment in G.attachment_actions)
			if(istype(stored_attachment, act_type))
				var/datum/action/typed_attachment = stored_attachment
				typed_attachment.Remove(user)
				G.attachment_actions -= stored_attachment
				QDEL_NULL(stored_attachment)
				break
	
	attached_gun = null
	set_user()
	if(user)
		drop_user(user)
	G.attachment_flags ^= attachment_type
	G.current_attachments -= src
	G.update_attachments()
	if(user)
		user.put_in_hands(src)
	else
		forceMove(get_turf(G))

/obj/item/attachment/proc/on_gun_fire(obj/item/gun/G)

/obj/item/attachment/proc/set_user(mob/user = null)
	if(user == current_user)
		return
	if(istype(current_user))
		current_user = null
	if(istype(user))
		current_user = user

// Called when the gun is picked up
/obj/item/attachment/proc/pickup_user(mob/user = null)

// Called when the gun is stowed
/obj/item/attachment/proc/equip_user(mob/user = null)

// Called when the gun is dropped
/obj/item/attachment/proc/drop_user(mob/user = null)

/obj/item/attachment/proc/check_user()
	if(!istype(current_user))
		if(ismob(loc))
			set_user(loc)
		else if(ismob(loc.loc))
			set_user(loc.loc)
	if(!istype(current_user) || !isturf(current_user.loc) || !( (src in current_user.held_items)||(loc in current_user.held_items) ) || current_user.incapacitated())	//Doesn't work if you're not holding it!
		return FALSE
	return TRUE
