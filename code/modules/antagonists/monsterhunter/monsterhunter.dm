#define HUNTER_SCAN_MIN_DISTANCE 8
#define HUNTER_SCAN_MAX_DISTANCE 15
/// 5s update time
#define HUNTER_SCAN_PING_TIME 20

/datum/antagonist/monsterhunter
	name = "\improper Monster Hunter"
	roundend_category = "Monster Hunters"
	antagpanel_category = "Monster Hunter"
	job_rank = ROLE_MONSTERHUNTER
	antag_hud_name = "monsterhunter"
	preview_outfit = /datum/outfit/monsterhunter
	var/list/datum/action/powers = list()
	var/datum/martial_art/hunterfu/my_kungfu = new
	var/give_objectives = TRUE


/datum/outfit/monsterhunter
	name = "Monster Hunter"

	head = /obj/item/clothing/head/helmet/chaplain/witchunter_hat
	uniform = /obj/item/clothing/under/rank/civilian/chaplain
	suit = /obj/item/clothing/suit/armor/riot/chaplain/witchhunter
	l_hand = /obj/item/stake
	r_hand = /obj/item/stake/hardened/silver
