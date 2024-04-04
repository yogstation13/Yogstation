GLOBAL_LIST_INIT(rarity_to_quality, list(
	TIER_NORMAL = 0,
	TIER_UNCOMMON = 2,
	TIER_RARE = 5,
	TIER_LEGENDARY = 10,
	TIER_MYTHICAL = 25
))

GLOBAL_LIST_INIT(rarity_to_color, list(
	TIER_NORMAL = "#FFFFFF",
	TIER_UNCOMMON = "#00ff62",
	TIER_RARE = "#2600ff",
	TIER_LEGENDARY = "#ff00ff",
	TIER_MYTHICAL = "#ffd900"
))

GLOBAL_LIST_INIT(rarity_weights, list(
		TIER_NORMAL = 55,
		TIER_UNCOMMON = 30,
		TIER_RARE = 10,
		TIER_LEGENDARY = 4,
		TIER_MYTHICAL = 1
	))

/datum/component/fantasy
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

	var/quality

	var/canFail
	var/announce

	var/originalName
	var/list/affixes
	var/list/appliedComponents

	var/static/list/affixListing

	var/rarity = TIER_NORMAL

/datum/component/fantasy/Initialize(quality, list/affixes = list(), canFail=FALSE, announce=FALSE)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	//src.quality = quality || randomQuality()
	src.canFail = canFail
	src.announce = announce
	src.rarity = randomRarity()
	src.quality = GLOB.rarity_to_quality[src.rarity]

	src.affixes = affixes
	appliedComponents = list()
	randomAffixes()

/datum/component/fantasy/Destroy()
	unmodify()
	affixes = null
	return ..()

/datum/component/fantasy/RegisterWithParent()
	var/obj/item/master = parent
	originalName = master.name
	modify()

/datum/component/fantasy/UnregisterFromParent()
	unmodify()

/datum/component/fantasy/InheritComponent(datum/component/fantasy/newComp, original, quality, list/affixes, canFail, announce)
	unmodify()
	src.rarity = randomRarity()
	src.quality = GLOB.rarity_to_quality[src.rarity]
	modify()

/datum/component/fantasy/proc/randomRarity()
	return pickweight(GLOB.rarity_weights)

/datum/component/fantasy/proc/randomAffixes(force)
	if(!affixListing)
		affixListing = list()
		for(var/T in subtypesof(/datum/fantasy_affix))
			var/datum/fantasy_affix/affix = new T
			affixListing[affix] = affix.weight

	if(length(affixes))
		if(!force)
			return
		affixes = list()

	var/alignment
	if(quality >= 0)
		alignment |= AFFIX_GOOD
	if(quality <= 0)
		alignment |= AFFIX_EVIL

	var/usedSlots = NONE
	for(var/i in 1 to max(1, abs(quality))) // We want at least 1 affix applied
		var/datum/fantasy_affix/affix = pickweight(affixListing)
		if(affix.placement & usedSlots)
			continue
		if(!(affix.alignment & alignment))
			continue
		if(!affix.validate(src))
			continue
		affixes += affix
		usedSlots |= affix.placement

/datum/component/fantasy/proc/modify()
	var/obj/item/master = parent

	master.force = max(0, master.force + quality)
	master.throwforce = max(0, master.throwforce + quality)
	master.armor = master.armor.modifyAllRatings(quality)
	master.wound_bonus += quality
	master.bare_wound_bonus += quality

	var/newName = originalName
	
	for(var/i in affixes)
		var/datum/fantasy_affix/affix = i
		newName = affix.apply(src, newName)

	if(quality != 0)
		newName = "[newName][quality > 0 ? "+" : ""][quality]"

	var/rarity_string = rarity == TIER_NORMAL ? "" : "[rarity] "
	newName = "[rarity_string][newName]"

	master.color = GLOB.rarity_to_color[rarity]

	if(canFail && prob((quality - 9)*10))
		var/turf/place = get_turf(parent)
		place.visible_message(span_danger("[parent] [span_inathneq_large("violently glows blue")] for a while, then evaporates."))
		master.burn()
		return
	else if(announce)
		announce()

	master.name = newName

/datum/component/fantasy/proc/unmodify()
	var/obj/item/master = parent

	for(var/i in affixes)
		var/datum/fantasy_affix/affix = i
		affix.remove(src)
	for(var/i in appliedComponents)
		qdel(i)

	master.force = max(0, master.force - quality)
	master.throwforce = max(0, master.throwforce - quality)
	master.armor = master.armor.modifyAllRatings(-quality)
	master.wound_bonus -= quality
	master.bare_wound_bonus -= quality

	master.name = originalName
	master.color = null

/datum/component/fantasy/proc/announce()
	var/turf/location = get_turf(parent)
	var/span
	var/effect_description
	if(quality >= 0)
		span = "<span class='notice'>"
		effect_description = "[span_heavy_brass("shimmering golden glow")]"
	else
		span = "<span class='danger'>"
		effect_description = "[span_umbra_emphasis("mottled black glow")]"

	location.visible_message("[span][originalName] is covered by a [effect_description] and then transforms into [parent]!</span>")
