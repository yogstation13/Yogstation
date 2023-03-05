#define CARP_CARP_CARP		1

/obj/item/storage/box/syndicate
	name = "suspicious box"
	var/real_name = "box"

/obj/item/storage/box/syndicate/examine(mob/user)
	if(is_syndicate(user))
		name = real_name
	else
		name = initial(name)
	. = ..()
	name = initial(name)

/obj/item/storage/box/syndie_kit
	name = "suspicious box"
	var/real_name = "box"

/obj/item/storage/box/syndie_kit/examine(mob/user)
	if(is_syndicate(user))
		name = real_name
	else
		name = initial(name)
	. = ..()
	name = initial(name)

/obj/item/storage/box/syndicate/bundle_A/PopulateContents()
	switch (pickweight(list("recon" = 2, "bloodyspai" = 3, "stealth" = 2, "guns" = 2, "murder" = 2, "implant" = 1, "hacker" = 3, "sabotage" = 3, "sniper" = 1, "metaops" = 1)))
		if("recon") //28ish TC
			new /obj/item/clothing/glasses/thermal/xray(src) //Would argue 6 TC. Thermals are 4 TC but work on organic targets in darkness
			new /obj/item/storage/briefcase/launchpad(src) //6 TC
			new	/obj/item/twohanded/binoculars(src) //1 TC, maybe. Very good but mining medic/detective get them for free
			new /obj/item/encryptionkey/syndicate(src) //2 TC
			new /obj/item/storage/box/syndie_kit/space(src) //4 TC
			new /obj/item/grenade/syndieminibomb/concussion/frag(src) //Minibomb with one less range on each part except for fire. 3-4 TC.
			new /obj/item/grenade/syndieminibomb/concussion/frag(src) //See above
			new /obj/item/flashlight/emp(src) //2 TC

		if("bloodyspai") //32 TCish
			new /obj/item/clothing/under/chameleon/syndicate(src) //1 TC, has only two parts of the massive kit
			new /obj/item/clothing/mask/chameleon/syndicate(src) //See above
			new /obj/item/card/id/syndicate(src) //2 TC
			new /obj/item/multitool/ai_detect(src) //1 TC
			new /obj/item/encryptionkey/syndicate(src) //2 TC
			new /obj/item/reagent_containers/syringe/mulligan(src) //4 TC
			new /obj/item/switchblade/backstab(src) //5 TC
			new /obj/item/storage/box/fancy/cigarettes/cigpack_syndicate (src) //2 TC (for now)
			new /obj/item/flashlight/emp(src) //2 TC
			new /obj/item/chameleon(src) //7 TC
			new /obj/item/card/emag(src) //6 TC

		if("stealth") //32 TC
			new /obj/item/gun/energy/kinetic_accelerator/crossbow(src) //10 TC
			new /obj/item/pen/sleepy(src) //4 TC
			new /obj/item/chameleon(src) //7 TC
			new /obj/item/clothing/glasses/thermal/syndi(src) //4 TC
			new /obj/item/flashlight/emp(src) //2 TC
			new /obj/item/jammer(src) //5 TC

		if("guns") //Total cost of 29 TC
			new /obj/item/gun/ballistic/revolver(src) //6 TC
			new /obj/item/gun/ballistic/revolver(src) //6 TC
			new /obj/item/gun/ballistic/automatic/pistol(src) //6 TC
			new /obj/item/gun/ballistic/automatic/pistol(src) //6 TC
			new /obj/item/ammo_box/a357(src) //1 TC for two
			new /obj/item/ammo_box/a357(src) //See above
			new /obj/item/ammo_box/a357(src) //1 TC for two
			new /obj/item/ammo_box/a357(src) //See above
			new /obj/item/ammo_box/magazine/m10mm(src) //1 TC for two
			new /obj/item/ammo_box/magazine/m10mm(src) //See above
			new /obj/item/ammo_box/magazine/m10mm(src) //1 TC for two
			new /obj/item/ammo_box/magazine/m10mm(src) //See above
			new /obj/item/storage/belt/holster/syndicate(src) //A holster for your four guns. It could be 1 TC I guess, since the tactical webbing can't hold normal items?
			new /obj/item/clothing/gloves/color/latex/nitrile(src) //Free?
			new /obj/item/clothing/mask/gas/clown_hat(src) //Free?
			new /obj/item/clothing/under/suit_jacket/really_black(src) //Free?

		if("murder") //Total cost of 28 TC
			new /obj/item/melee/transforming/energy/sword/saber(src) //8 TC
			new /obj/item/clothing/glasses/thermal/syndi(src) //4 TC
			new /obj/item/card/emag(src) //6 TC
			new /obj/item/clothing/shoes/chameleon/noslip/syndicate(src) //2 TC
			new /obj/item/encryptionkey/syndicate(src) //2 TC
			new /obj/item/grenade/syndieminibomb(src) //6 TC

		if("implant") //28 TC cost, then you get a spare 10 for a total of 38 TC (fair and balanced™)
			new /obj/item/implanter/freedom(src) //5 TC
			new /obj/item/implanter/uplink/precharged(src) //4 TC + 10 to use
			new /obj/item/implanter/emp(src) //1 TC, kit with 5 grenades costs 2
			new /obj/item/implanter/adrenalin(src) //8 TC
			new /obj/item/implanter/explosive(src) //2 TC, nukies only
			new /obj/item/implanter/storage(src) //8 TC

		if("hacker") //28 TC cost
			new /obj/item/aiModule/syndicate(src) //4 TC
			new /obj/item/card/emag(src) //6 TC
			new /obj/item/encryptionkey/binary(src) //2 TC
			new /obj/item/aiModule/toyAI(src) //Um, free...?
			new /obj/item/multitool/ai_detect(src) //1 TC
			new /obj/item/storage/toolbox/syndicate(src) //1 TC
			new /obj/item/camera_bug(src) //1 TC
			new /obj/item/card/id/syndicate(src) //2 TC
			new /obj/item/flashlight/emp(src) //2 TC
			new /obj/item/computer_hardware/hard_drive/portable/syndicate/bomberman(src) //6 TC
			new /obj/item/clothing/glasses/hud/diagnostic/sunglasses(src) //RD glasses. 1 TC, if that
			new /obj/item/pen/edagger(src) //2 TC

		if("sabotage") //Maybe 29 TC?
			new /obj/item/grenade/plastic/c4 (src) //1 TC
			new /obj/item/grenade/plastic/c4 (src) //1 TC
			new /obj/item/doorCharge(src) //2 TC
			new /obj/item/doorCharge(src) //2 TC
			new /obj/item/camera_bug(src) //1 TC
			new /obj/item/sbeacondrop/powersink(src) //8 TC
			new /obj/item/computer_hardware/hard_drive/portable/syndicate/bomberman(src) //6 TC
			new /obj/item/storage/toolbox/syndicate(src) //1 TC
			new /obj/item/pizzabox/bomb(src) //6 TC
			new /obj/item/storage/box/syndie_kit/emp(src) //2 TC

		if("sniper") //28 TC, you only get 11 shots total with the sniper and 14 with the revolver. A mini-ebow would probably be better than the sniper in a normal traitor game
			new /obj/item/gun/ballistic/automatic/sniper_rifle(src) //12 TC, nukies only
			new /obj/item/ammo_box/magazine/sniper_rounds/penetrator(src) //5 TC, nukies only
			new /obj/item/gun/ballistic/revolver(src) //6 TC
			new /obj/item/ammo_box/a357/heartpiercer(src) //1 TC
			new /obj/item/clothing/glasses/thermal/syndi(src) //4 TC
			new /obj/item/clothing/gloves/color/latex/nitrile(src) //Free?
			new /obj/item/clothing/mask/gas/clown_hat(src) //Free?
			new /obj/item/clothing/under/suit_jacket/really_black(src) //Free?

		if("metaops") //30 TC
			new /obj/item/clothing/suit/space/hardsuit/syndi(src) //8 TC
			new /obj/item/gun/ballistic/shotgun/bulldog/unrestricted(src) //8 TC, nukies only
			new /obj/item/implanter/explosive(src) //2 TC, nukies only
			new /obj/item/ammo_box/magazine/m12g(src) //2 TC, nukies only
			new /obj/item/ammo_box/magazine/m12g(src) //2 TC, nukies only
			new /obj/item/grenade/plastic/c4 (src) //1 TC
			new /obj/item/grenade/plastic/c4 (src) //1 TC
			new /obj/item/card/emag(src) //6 TC

/obj/item/storage/box/syndicate/bundle_B/PopulateContents()
	switch (pickweight(list("v" = 2, "oddjob" = 2, "neo" = 1, "ninja" = 1, "darklord" = 1, "white_whale_holy_grail" = CARP_CARP_CARP, "mad_scientist" = 2, "bee" = 2, "mr_freeze" = 2, "gang_boss" = 1)))
		if("v") //Big Boss. Total of ~26 TC.
			new /obj/item/clothing/under/syndicate/camo(src) //Reskinned tactical turtleneck, free
			new /obj/item/clothing/glasses/eyepatch/bigboss(src) //Gives flash protection and night vision, probably around 2-3 TC
			new /obj/item/clothing/shoes/combat(src) //Drip is essential. Free
			new /obj/item/clothing/gloves/fingerless/bigboss(src) //Like a much lighter version of the Gloves of the North Star, but also helps with carrying bodies. Worth maybe 2 TC
			new /obj/item/storage/belt/military(src) //Can't be concealed, basically just 7-slot belt, no normal items allowed. Free
			new /obj/item/book/granter/martial/cqc(src) //13 TC, ABSOLUTELY mandatory
			new /obj/item/gun/ballistic/automatic/toy/pistol/riot(src) //1 TC, not a tranq pistol but it's something
			new /obj/item/kitchen/knife/combat/survival(src) //Simple miner knife, in flavor. Maybe-maybe 1 TC, but basically free
			new /obj/item/implanter/stealth(src) //Just a box. 8 TC
			new /obj/item/storage/box/fancy/cigarettes/cigars(src) //It's no Phantom Cigar, but it'll still be badass
			new /obj/item/lighter(src) //Need to light the cigar

		if("oddjob") //Total TC value of 26ish TC
			new /obj/item/clothing/head/det_hat/evil(src) //6 TC. Absolutely necessary
			new /obj/item/clothing/under/syndicate/sniper(src) //Variant of tactical turtleneck that looks like a suit, provides 10 melee armor, has no sensors. Would say it's free
			new /obj/item/clothing/suit/det_suit/grey/evil(src) //Grey det trenchcoat with hos coat values, 2ish TC
			new /obj/item/clothing/shoes/laceup(src) //Fancy shoes. Free
			new /obj/item/gun/ballistic/automatic/pistol/deagle/gold(src) //Gold deagle (golden gun). Since you can print off .357 boxes now I'd honestly say it's like 5 TC, even that's an overestimation
			new /obj/item/ammo_box/magazine/m50(src) //Spare mag for your gun. 1 TC.
			new /obj/item/grenade/syndieminibomb(src) //Hand grenade. 6 TC
			new /obj/item/deployablemine(src) //I don't know if anyone remembers remote mines in Goldeneye because I certainly do. Hilariously less lethal than the 4 TC rubber ducky for clown ops, so I say 3
			new /obj/item/dnainjector/dwarf(src) //Gives you dwarfism (smaller hitbox, instantly climb tables), would argue 2-3 TC. The only other core item to this kit

		if("ninja")
			new /obj/item/katana(src) // Unique , hard to tell how much tc this is worth. 8 tc?
			new /obj/item/implanter/adrenalin(src) // 8 tc
			for(var/i in 1 to 6)
				new /obj/item/throwing_star(src) // ~5 tc for all 6
			new /obj/item/storage/belt/chameleon/syndicate(src) // Unique but worth at least 2 tc
			new /obj/item/card/id/syndicate(src) // 2 tc
			new /obj/item/chameleon(src) // 7 tc

		if("darklord") //This is now basically just a wizard instead of just desword: the kit. Hard to quantify the TC cost of spells, but taking SP * 4 would yield a theoretical TC of 27-ish
			new /obj/item/melee/transforming/energy/sword/saber/red(src) //8 TC. A red lightsaber. Enough said
			new /obj/item/clothing/mask/chameleon/syndicate(src) //Not even 1 TC, the real value of the chameleon kit is the jumpsuit. However this is absolutely necessary for your Sithsona
			new /obj/item/card/id/syndicate(src) //2 TC, so you can give yourself a proper name
			new /obj/item/clothing/head/yogs/sith_hood(src) //The DRIP
			new /obj/item/clothing/neck/yogs/sith_cloak(src) //See above
			new /obj/item/clothing/suit/yogs/armor/sith_suit(src) //See above
			new /obj/item/clothing/shoes/combat(src) //See above
			new /obj/item/clothing/gloves/combat(src) //Maybe 1 TC, so you don't shock yourself
			new /obj/item/book/granter/spell/lightningbolt(src) //Lightning bolt, LIGHTNING BOLT. A 2 SP cost spell that doesn't require robes and provides ranged potential
			new /obj/item/book/granter/spell/forcewall(src) //It has the word force in it? But more importantly, it doesn't require robes and it's 1 SP and it's VERY good defense
			new /obj/item/book/granter/spell/summonitem(src) //So you can throw your lightsaber and call it back. A 1 SP cost spell that doesn't require robes

		if("white_whale_holy_grail") //Unique items that don't appear anywhere else, more than 100 carps or your TC back
			new /obj/item/pneumatic_cannon/speargun(src)
			new /obj/item/storage/magspear_quiver(src)
			new /obj/item/clothing/suit/space/hardsuit/carp(src) //1 carp
			new /obj/item/clothing/mask/gas/carp(src) //1 carp?
			new /obj/item/twohanded/pitchfork/trident(src)
			new /obj/item/grenade/clusterbuster/syndie/spawner_spesscarp(src) //when you need A LOT of carps, you'll get at least (but most likely more) 30 carps with that
			new /obj/item/grenade/spawnergrenade/spesscarp(src) //for precise and quick delivery of carps, 5 carps per grenade for a total of 20 carps
			new /obj/item/grenade/spawnergrenade/spesscarp(src)
			new /obj/item/grenade/spawnergrenade/spesscarp(src)
			new /obj/item/grenade/spawnergrenade/spesscarp(src)
			new /obj/item/carpcaller(src) //to spawn carps in space, making the place safer for you and dangerous for everyone else, you should get at least 20 carps per use so 60  carps
			new /obj/item/toy/plush/carpplushie/dehy_carp //1 carp but guaranteed complete loyalty and cuddliness

		if("mad_scientist") // ~21 tc
			new /obj/item/clothing/suit/toggle/labcoat/mad(src) // 0 tc
			new /obj/item/clothing/shoes/jackboots(src) // 0 tc
			new /obj/item/megaphone(src) // 0 tc (because how else are they to know you're mad?)
			new /obj/item/grenade/clusterbuster/random/syndie(src) // RNG worth like 2-10TC
			new /obj/item/grenade/clusterbuster/random/syndie(src) // RNG worth like 2-10TC
			new /obj/item/grenade/chem_grenade/bioterrorfoam(src) // 5 tc
			new /obj/item/storage/box/syndie_kit/ez_clean // 6 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/assembly/signaler(src) // 0 tc
			new /obj/item/storage/toolbox/syndicate(src) // 1 tc
			new /obj/item/pen/edagger(src) // 2 tc
			new /obj/item/gun/energy/wormhole_projector/upgraded(src) // ~2 tc
			new /obj/item/gun/energy/decloner/unrestricted(src) // these shots do 9 damage. 1 tc

		if("bee") // bee sword too based so its priceless
			new /obj/item/paper/fluff/bee_objectives(src) // 0 tc (motivation)
			new /obj/item/clothing/suit/hooded/bee_costume(src) // 0 tc
			new /obj/item/clothing/mask/rat/bee(src) // 0 tc
			new /obj/item/storage/belt/fannypack/yellow(src) // 0 tc
			new /obj/item/storage/box/syndie_kit/bee_grenades(src) // 15 tc
			new /obj/item/reagent_containers/glass/bottle/beesease(src) // 10 tc?
			new /obj/item/melee/beesword(src) //priceless

		if("mr_freeze") // ~17 tc
			new /obj/item/clothing/glasses/cold(src) // 0 tc
			new /obj/item/clothing/gloves/color/black(src) // 0 tc
			new /obj/item/clothing/mask/chameleon/syndicate(src) // 0 tc on its own
			new /obj/item/clothing/suit/hooded/wintercoat(src) // 0 tc
			new /obj/item/clothing/shoes/winterboots(src) // 0 tc
			new /obj/item/grenade/gluon(src) // all four probably like 1 tc together kind of just a slip bomb
			new /obj/item/grenade/gluon(src) //
			new /obj/item/grenade/gluon(src) //
			new /obj/item/grenade/gluon(src) //
			new /obj/item/dnainjector/geladikinesis(src) // 0 tc
			new /obj/item/dnainjector/cryokinesis(src) // 1 or 2 tc, kind of useful
			new /obj/item/gun/energy/temperature/security(src) // the crutch of this kit, alongside esword, ~4 tc
			new /obj/item/melee/transforming/energy/sword/saber/blue(src) //see see it fits the theme bc its blue and ice is blue, 8 tc

		if("neo")
			new /obj/item/clothing/glasses/sunglasses(src)
			new /obj/item/gun/ballistic/automatic/pistol(src)
			new /obj/item/gun/ballistic/automatic/pistol(src)
			new /obj/item/ammo_box/magazine/m10mm/ap(src)
			new /obj/item/ammo_box/magazine/m10mm/ap(src)
			new /obj/item/ammo_box/magazine/m10mm/ap(src)
			new /obj/item/ammo_box/magazine/m10mm/ap(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/ammo_box/magazine/m10mm(src)
			new /obj/item/ammo_box/magazine/m10mm/sp(src)
			new /obj/item/ammo_box/magazine/m10mm/sp(src)
			new /obj/item/ammo_box/magazine/m10mm/fire(src)
			new /obj/item/ammo_box/magazine/m10mm/fire(src)
			new /obj/item/reagent_containers/syringe/plasma(src)
			new /obj/item/reagent_containers/autoinjector/medipen/stimpack/large/redpill(src)
			new /obj/item/slime_extract/sepia(src)
			new /obj/item/slime_extract/sepia(src)
			new /obj/item/slime_extract/sepia(src) // sepia to stop time because we dont really have a time slow event


		if("gang_boss")
			new /obj/item/clothing/under/jabroni(src) //fishnet suit
			new /obj/item/clothing/suit/yogs/pinksweater(src) //close enough
			new /obj/item/guardiancreator/tech(src) //15 TC
			new /obj/item/stand_arrow/boss(src) //priceless, but if it had to get a price it'd be ~45 for 3 holoparasite injectors and ~21 3 mindslave implants. although its difficult to conceal and the holoparasites are random.
			new /obj/item/storage/box/fancy/donut_box(src) //d o n u t s
			new /obj/item/reagent_containers/glass/bottle/drugs(src)
			new /obj/item/slimecross/stabilized/green(src) //secret identity

#undef CARP_CARP_CARP

/obj/item/stand_arrow/boss
	desc = "An arrow that can unleash <span class='holoparasite'>massive potential</span> from those stabbed by it. It has been laced with syndicate mindslave nanites that will be linked to whoever first uses it in their hand."
	kill_chance = 0
	arrowtype = "tech"
	var/datum/mind/owner
	can_requiem = FALSE

/obj/item/stand_arrow/boss/attack_self(mob/user)
	if(owner || !user.mind)
		return
	to_chat(user, span_notice("You prick your finger on the arrow, linking the mindslave nanites to you!"))
	owner = user.mind

/obj/item/stand_arrow/boss/attack(mob/living/M, mob/living/user)
	if(owner && owner.current == M && user == M) //you have a holoparasite injector for this exact purpose
		to_chat(M, span_warning("Implanting yourself with mindslave nanites is probably a bad idea..."))
		return
	. = ..()

/obj/item/stand_arrow/boss/generate_stand(mob/living/carbon/human/H)
	if(owner?.current && H != owner.current)//lol
		var/obj/item/implant/mindslave/M = new /obj/item/implant/mindslave() //if someone injects themself with a gangster arrow it's entirely their fault for using contraband
		if(!M.implant(H, owner.current))
			qdel(M)
	. = ..() //sure ok you stole the arrow

/obj/item/carpcaller
	name = "Carp signal"
	desc = "Emit a carp'sian bluespace wave disturbing carpspace that will pull space carps from all over the galaxy to the surrounding area of the station."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	var/remaining_uses = 3

/obj/item/carpcaller/attack_self(mob/user)
	var/datum/round_event_control/carp_migration/newCarpControl = new /datum/round_event_control/carp_migration() //code taken from the portal storm ritual
	var/datum/round_event/carp_migration/newCarpStorm = newCarpControl.runEvent()
	newCarpStorm.setup()
	remaining_uses -= 1
	to_chat(user, "You call a school of space carps to the station")
	if(remaining_uses <= 0) {
		to_chat(user, span_warning("The [src] disappear to carpspace."))
		qdel(src)
	} else {
		to_chat(user, span_warning("The [src] has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."))
	}

/obj/item/carpcaller/examine(mob/user)
	. = ..()
	if(remaining_uses != -1)
		. += "It has [remaining_uses] use[remaining_uses > 1 ? "s" : ""] left."

/obj/item/storage/box/syndicate/contract_kit
	real_name = "Contract Kit"
	desc = "Supplied to Syndicate contractors."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndicate/contractor_loadout
	real_name = "Standard Loadout"
	desc = "Supplied to Syndicate contractors, providing their specialised space suit and chameleon uniform."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/paper/contractor_guide
	name = "Contractor Guide"

/obj/item/paper/contractor_guide/Initialize()
	info = {"<p>Welcome agent, congratulations on your new position as contractor. On top of your already assigned objectives,
			this kit will provide you contracts to take on for TC payments.</p>

			<p>Provided within, we give your specialist contractor space suit. It's even more compact, being able to fit into a pocket, and faster than the
			Syndicate space suit available to you on the uplink. We also provide your chameleon jumpsuit and mask, both of which can be changed
			to any form you need for the moment. The cigarettes are a special blend - it'll heal your injuries slowly overtime.</p>

			<p>Your standard issue contractor baton hits harder than the ones you might be used to, and likely be your go to weapon for kidnapping your
			targets. The three additional items have been randomly selected from what we had available. We hope they're useful to you for your mission.</p>

			<p>The contractor hub, available at the top right of the uplink, will provide you unique items and abilities. These are bought using Contractor Rep,
			with two Rep being provided each time you complete a contract.</p>

			<h3>Using the tablet</h3>
			<ol>
				<li>Open the Syndicate Contract Uplink program.</li>
				<li>Here, you can accept a contract, and redeem your TC payments from completed contracts.</li>
				<li>The payment number shown in brackets is the bonus you'll receive when bringing your target <b>alive</b>. You receive the
				other number regardless of if they were alive or dead.</li>
				<li>Contracts are completed by bringing the target to designated dropoff, calling for extraction, and putting them
				inside the pod.</li>
			</ol>

			<p>Be careful when accepting a contract. While you'll be able to see the location of the dropoff point, cancelling will make it
			unavailable to take on again.</p>
			<p>The tablet can also be recharged at any cell charger.</p>
			<h3>Extracting</h3>
			<ol>
				<li>Make sure both yourself and your target are at the dropoff.</li>
				<li>Call the extraction, and stand back from the drop point.</li>
				<li>If it fails, make sure your target is inside, and there's a free space for the pod to land.</li>
				<li>Grab your target, and drag them into the pod.</li>
			</ol>
			<h3>Ransoms</h3>
			<p>We need your target for our own reasons, but we ransom them back to your mission area once their use is served. They will return back
			from where you sent them off from in several minutes time. Don't worry, we give you a cut of what we get paid. We pay this into whatever
			ID card you have equipped, on top of the TC payment we give.</p>

			<p>Good luck agent. You can burn this document with the supplied lighter.</p>"}

	return ..()

/obj/item/storage/box/syndicate/contractor_loadout/PopulateContents()
	new /obj/item/clothing/head/helmet/space/syndicate/contract(src)
	new /obj/item/clothing/suit/space/syndicate/contract(src)
	new /obj/item/clothing/under/chameleon/syndicate(src)
	new /obj/item/clothing/mask/chameleon/syndicate(src)
	new /obj/item/card/id/syndicate(src)
	new /obj/item/storage/box/fancy/cigarettes/cigpack_syndicate(src)
	new /obj/item/lighter(src)

/obj/item/storage/box/syndicate/contract_kit/PopulateContents()
	new /obj/item/modular_computer/tablet/syndicate_contract_uplink/preset/uplink(src)
	new /obj/item/storage/box/syndicate/contractor_loadout(src)
	new /obj/item/melee/classic_baton/telescopic/contractor_baton(src)
	new /obj/item/bodybag/environmental/prisoner/syndicate(src)

	// All about 4 TC or less - some nukeops only items, but fit nicely to the theme.
	var/list/item_list = list(
		/obj/item/storage/backpack/duffelbag/syndie/x4,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/gun/syringe/syndicate,
		/obj/item/pen/edagger,
		/obj/item/pen/sleepy,
		/obj/item/flashlight/emp,
		/obj/item/book/granter/crafting_recipe/weapons,
		/obj/item/clothing/shoes/chameleon/noslip/syndicate,
		/obj/item/storage/firstaid/tactical,
		/obj/item/clothing/shoes/airshoes,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/camera_bug,
		/obj/item/storage/box/syndie_kit/imp_radio,
		/obj/item/storage/box/syndie_kit/imp_uplink,
		/obj/item/clothing/gloves/krav_maga/combatglovesplus,
		/obj/item/gun/ballistic/automatic/c20r/toy/unrestricted/riot,
		/obj/item/reagent_containers/syringe/stimulants,
		/obj/item/storage/box/syndie_kit/imp_freedom,
		/obj/item/storage/belt/chameleon/syndicate
	)

	var/obj/item1 = pick_n_take(item_list)
	var/obj/item2 = pick_n_take(item_list)
	var/obj/item3 = pick_n_take(item_list)

	// Create two, non repeat items from the list.
	new item1(src)
	new item2(src)
	new item3(src)

	// Paper guide
	new /obj/item/paper/contractor_guide(src)

/obj/item/storage/box/syndie_kit
	name = "box"
	real_name = "box"
	desc = "A sleek, sturdy box."
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndie_kit/origami_bundle
	real_name = "origami kit"
	desc = "A box full of a number of rather masterfully engineered paper planes and a manual on \"The Art of Origami\"."

/obj/item/storage/box/syndie_kit/origami_bundle/PopulateContents()
	new /obj/item/book/granter/action/origami(src)
	for(var/i in 1 to 5)
		new /obj/item/paper(src)

/obj/item/storage/box/syndie_kit/imp_freedom
	real_name = "freedom implant box"

/obj/item/storage/box/syndie_kit/imp_freedom/PopulateContents()
	new /obj/item/implanter/freedom(src)

/obj/item/storage/box/syndie_kit/imp_microbomb
	real_name = "microbomb implant box"

/obj/item/storage/box/syndie_kit/imp_microbomb/PopulateContents()
	new /obj/item/implanter/explosive(src)

/obj/item/storage/box/syndie_kit/imp_macrobomb
	real_name = "macrobomb implant box"

/obj/item/storage/box/syndie_kit/imp_macrobomb/PopulateContents()
	new /obj/item/implanter/explosive_macro(src)

/obj/item/storage/box/syndie_kit/imp_uplink
	real_name = "uplink implant box"

/obj/item/storage/box/syndie_kit/imp_uplink/PopulateContents()
	new /obj/item/implanter/uplink(src)

/obj/item/storage/box/syndie_kit/bioterror
	real_name = "bioterror syringe box"

/obj/item/storage/box/syndie_kit/bioterror/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/syringe/bioterror(src)

/obj/item/storage/box/syndie_kit/imp_adrenal
	real_name = "adrenal implant box"

/obj/item/storage/box/syndie_kit/imp_adrenal/PopulateContents()
	new /obj/item/implanter/adrenalin(src)

/obj/item/storage/box/syndie_kit/imp_storage
	real_name = "storage implant box"

/obj/item/storage/box/syndie_kit/imp_storage/PopulateContents()
	new /obj/item/implanter/storage(src)

/obj/item/storage/box/syndie_kit/imp_stealth
	real_name = "stealth implant box"

/obj/item/storage/box/syndie_kit/imp_stealth/PopulateContents()
	new /obj/item/implanter/stealth(src)

/obj/item/storage/box/syndie_kit/imp_radio
	real_name = "syndicate radio implant box"

/obj/item/storage/box/syndie_kit/imp_radio/PopulateContents()
	new /obj/item/implanter/radio/syndicate(src)

/obj/item/storage/box/syndie_kit/imp_mindshield
	real_name = "mindshield implant box"

/obj/item/storage/box/syndie_kit/imp_mindshield/PopulateContents()
	new /obj/item/implanter/mindshield/tot(src)

/obj/item/storage/box/syndie_kit/space
	real_name = "boxed space suit and helmet"

/obj/item/storage/box/syndie_kit/space/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.set_holdable(list(/obj/item/clothing/suit/space/syndicate, /obj/item/clothing/head/helmet/space/syndicate))

/obj/item/storage/box/syndie_kit/space/PopulateContents()
	if(prob(50))
		new /obj/item/clothing/suit/space/syndicate/black/red(src) // Black and red is so in right now
		new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)

	else
		new /obj/item/clothing/head/helmet/space/syndicate(src)
		new /obj/item/clothing/suit/space/syndicate(src)

/obj/item/storage/box/syndie_kit/emp
	real_name = "EMP kit"

/obj/item/storage/box/syndie_kit/emp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp(src)

/obj/item/storage/box/syndie_kit/chemical
	real_name = "chemical kit"

/obj/item/storage/box/syndie_kit/chemical/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 12

/obj/item/storage/box/syndie_kit/chemical/PopulateContents()
	new /obj/item/reagent_containers/syringe/big/polonium(src)
	new /obj/item/reagent_containers/syringe/big/venom(src)
	new /obj/item/reagent_containers/syringe/big/spewium(src)
	new /obj/item/reagent_containers/syringe/big/histamine(src)
	new /obj/item/reagent_containers/syringe/big/initropidril(src)
	new /obj/item/reagent_containers/syringe/big/pancuronium(src)
	new /obj/item/reagent_containers/syringe/big/sodium_thiopental(src)
	new /obj/item/reagent_containers/syringe/big/curare(src)
	new /obj/item/reagent_containers/syringe/big/amanitin(src)
	new /obj/item/reagent_containers/syringe/big/coniine(src)
	new /obj/item/reagent_containers/syringe/big/relaxant(src)
	new /obj/item/reagent_containers/syringe/big(src)

/obj/item/storage/box/syndie_kit/pistolammo
	real_name = "10mm magazine box"

/obj/item/storage/box/syndie_kit/pistolammo/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/pistolsleepyammo
	real_name = "10mm soporific magazine box"

/obj/item/storage/box/syndie_kit/pistolsleepyammo/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/magazine/m10mm/sp(src)

/obj/item/storage/box/syndie_kit/revolverammo
	real_name = ".357 speed loader box"

/obj/item/storage/box/syndie_kit/revolverammo/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/revolvershotgunammo
	real_name = ".357 Ironfeather speed loader box"

/obj/item/storage/box/syndie_kit/revolvershotgunammo/PopulateContents()
	for(var/i in 1 to 2)
		new /obj/item/ammo_box/a357(src)

/obj/item/storage/box/syndie_kit/nuke
	real_name = "box"

/obj/item/storage/box/syndie_kit/nuke/PopulateContents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	real_name = "box"

/obj/item/storage/box/syndie_kit/supermatter/PopulateContents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/hemostat/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/supermatter_delaminator
	real_name = "box"

/obj/item/storage/box/syndie_kit/supermatter_delaminator/PopulateContents()
	new /obj/item/hemostat/antinoblium(src)
	new /obj/item/antinoblium_container(src)
	new /obj/item/supermatter_corruptor(src)
	new /obj/item/paper/guides/antag/antinoblium_guide(src)


/obj/item/storage/box/syndie_kit/tuberculosisgrenade
	real_name = "virus grenade kit"

/obj/item/storage/box/syndie_kit/tuberculosisgrenade/PopulateContents()
	new /obj/item/grenade/chem_grenade/tuberculosis(src)
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/autoinjector/medipen/tuberculosiscure(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/glass/bottle/tuberculosiscure(src)

/obj/item/storage/box/syndie_kit/chameleon
	real_name = "chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/PopulateContents()
	new /obj/item/clothing/under/chameleon/syndicate(src)
	new /obj/item/clothing/suit/chameleon/syndicate(src)
	new /obj/item/clothing/gloves/chameleon/syndicate(src)
	new /obj/item/clothing/shoes/chameleon/syndicate(src)
	new /obj/item/clothing/glasses/chameleon/syndicate(src)
	new /obj/item/clothing/head/chameleon/syndicate(src)
	new /obj/item/clothing/mask/chameleon/syndicate(src)
	new /obj/item/storage/backpack/chameleon/syndicate(src)
	new /obj/item/radio/headset/chameleon/syndicate(src)
	new /obj/item/stamp/chameleon/syndicate(src)
	new /obj/item/pda/chameleon/syndicate(src)
	
/obj/item/storage/box/syndie_kit/chameleon/plasmaman
	real_name = "chameleon kit"

/obj/item/storage/box/syndie_kit/chameleon/plasmaman/PopulateContents()
	new /obj/item/clothing/under/plasmaman/chameleon/syndicate(src)
	new /obj/item/clothing/suit/chameleon/syndicate(src)
	new /obj/item/clothing/gloves/chameleon/syndicate(src)
	new /obj/item/clothing/shoes/chameleon/syndicate(src)
	new /obj/item/clothing/glasses/chameleon/syndicate(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chameleon/syndicate(src)
	new /obj/item/clothing/mask/chameleon/syndicate(src)
	new /obj/item/storage/backpack/chameleon/syndicate(src)
	new /obj/item/radio/headset/chameleon/syndicate(src)
	new /obj/item/stamp/chameleon/syndicate(src)
	new /obj/item/pda/chameleon/syndicate(src)

//5*(2*4) = 5*8 = 45, 45 damage if you hit one person with all 5 stars.
//Not counting the damage it will do while embedded (2*4 = 8, at 15% chance)
/obj/item/storage/box/syndie_kit/throwing_weapons/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/throwing_star(src)
	for(var/i in 1 to 2)
		new /obj/item/paperplane/syndicate(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/cutouts/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/rainbow(src)

/obj/item/storage/box/syndie_kit/romerol/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/romerol(src)
	new /obj/item/reagent_containers/syringe(src)
	new /obj/item/reagent_containers/dropper(src)

/obj/item/storage/box/syndie_kit/ez_clean/PopulateContents()
	for(var/i in 1 to 3)
		new/obj/item/grenade/chem_grenade/ez_clean(src)

/obj/item/storage/box/hug/reverse_revolver/PopulateContents()
	new /obj/item/gun/ballistic/revolver/reverse(src)

/obj/item/storage/box/syndie_kit/mimery/PopulateContents()
	new /obj/item/book/granter/spell/mimery_blockade(src)
	new /obj/item/book/granter/spell/mimery_guns(src)

/obj/item/storage/box/syndie_kit/centcom_costume/PopulateContents()
	new /obj/item/clothing/under/rank/centcom_officer(src)
	new /obj/item/clothing/head/beret/sec/centcom(src)
	new /obj/item/clothing/shoes/sneakers/black(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/radio/headset/headset_cent/empty(src)
	new /obj/item/clothing/glasses/sunglasses(src)
	new /obj/item/storage/backpack/satchel(src)
	new /obj/item/pda/heads(src)
	new /obj/item/clipboard(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/box/syndie_kit/chameleon/broken/PopulateContents()
	new /obj/item/clothing/under/chameleon/broken(src)
	new /obj/item/clothing/suit/chameleon/broken(src)
	new /obj/item/clothing/gloves/chameleon/broken(src)
	new /obj/item/clothing/shoes/chameleon/noslip/broken(src)
	new /obj/item/clothing/glasses/chameleon/broken(src)
	new /obj/item/clothing/head/chameleon/broken(src)
	new /obj/item/clothing/mask/chameleon/broken(src)
	new /obj/item/storage/backpack/chameleon/broken(src)
	new /obj/item/radio/headset/chameleon/broken(src)
	new /obj/item/stamp/chameleon/broken(src)
	new /obj/item/pda/chameleon/broken(src)
	// No chameleon laser, they can't randomise for //REASONS//

/obj/item/storage/box/syndie_kit/bee_grenades
	real_name = "buzzkill grenade box"
	desc = "A sleek, sturdy box with a buzzing noise coming from the inside. Uh oh."

/obj/item/storage/box/syndie_kit/bee_grenades/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/grenade/spawnergrenade/buzzkill(src)

/obj/item/storage/box/official_posters
	name = "poster box"
	desc = "A box filled with posters."

/obj/item/storage/box/official_posters/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/poster/random_official(src)

/obj/item/storage/box/syndie_kit/augmentation
	real_name = "augmentation kit"

/obj/item/storage/box/syndie_kit/augmentation/PopulateContents()
	new /obj/item/autosurgeon/limb/head/robot(src)
	new /obj/item/autosurgeon/limb/chest/robot(src)
	new /obj/item/autosurgeon/limb/l_arm/robot(src)
	new /obj/item/autosurgeon/limb/r_arm/robot(src)
	new /obj/item/autosurgeon/limb/l_leg/robot(src)
	new /obj/item/autosurgeon/limb/r_leg/robot(src)

/obj/item/storage/box/syndie_kit/augmentation/superior
	real_name = "superior augmentation kit"

/obj/item/storage/box/syndie_kit/augmentation/superior/PopulateContents()
	..()
	new /obj/item/autosurgeon/upgraded_cyberheart(src)
	new /obj/item/autosurgeon/upgraded_cyberliver(src)
	new /obj/item/autosurgeon/upgraded_cyberlungs(src)
	new /obj/item/autosurgeon/upgraded_cyberstomach(src)
	new /obj/item/implanter/empshield(src)

/obj/item/storage/box/beanbag/syndie_darts/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/ammo_casing/shotgun/dart/hidden(src)

/obj/item/storage/box/syndie_kit/buster
	real_name = "Buster kit"

/obj/item/storage/box/syndie_kit/buster/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/food/snacks/monkeycube(src)
	new /obj/item/bodypart/l_arm/robot/buster(src)
