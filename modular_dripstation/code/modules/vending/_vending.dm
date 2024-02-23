/obj/machinery/vending
	icon = 'modular_dripstation/icons/obj/vending.dmi'
	clicksound = null
	/// How long vendor takes to vend one item.
	var/vend_delay = 12

/obj/machinery/vending/cart
	icon_vend = "cart-vend"
	req_access = list(ACCESS_HOP)

/obj/machinery/vending/dinnerware
	icon_vend = "dinnerware-vend"
	icon_deny = "dinnerware-deny"
	req_access = list(ACCESS_KITCHEN)

/obj/machinery/vending/medical
	icon_vend = "med-vend"
	req_access = list(ACCESS_MEDICAL)
	light_mask = "med-light-mask"

/obj/machinery/vending/medical/syndicate_access
	icon_state = "syndi-big-med"
	icon_vend = "syndi-big-med-vend"
	icon_deny = "syndi-big-med-deny"
	light_color = LIGHT_COLOR_INTENSE_RED

/obj/machinery/vending/wallhypo
	req_access = list(ACCESS_MEDICAL)
	light_mask = "med-light-mask"

/obj/machinery/vending/hydroseeds
	icon_vend = "seeds-vend"
	icon_deny = "seeds-deny"
	light_color = LIGHT_COLOR_BLUEGREEN
	req_access = list(ACCESS_HYDROPONICS)

/obj/machinery/vending/wallgene
	req_access = list(ACCESS_GENETICS)
	light_mask = "wallmed-light-mask"

/obj/machinery/vending/hydronutrients
	icon_vend = "nutri-vend"
	light_color = LIGHT_COLOR_BLUEGREEN
	req_access = list(ACCESS_HYDROPONICS)

/obj/machinery/vending/wardrobe/sec_wardrobe
	icon_vend = "secdrobe-vend"
	icon_deny = "secdrobe-deny"
	light_color = LIGHT_COLOR_INTENSE_RED
	req_access = list(ACCESS_SECURITY)

/obj/machinery/vending/wardrobe/medi_wardrobe
	icon_vend = "medidrobe-vend"
	icon_deny = "medidrobe-deny"
	req_access = list(ACCESS_MEDICAL)

/obj/machinery/vending/wardrobe/engi_wardrobe
	icon_vend = "engidrobe-vend"
	icon_deny = "engidrobe-deny"
	req_access = list(ACCESS_ENGINE_EQUIP)

/obj/machinery/vending/wardrobe/atmos_wardrobe
	icon_vend = "atmosdrobe-vend"
	icon_deny = "atmosdrobe-deny"
	req_access = list(ACCESS_ATMOSPHERICS)

/obj/machinery/vending/wardrobe/sig_wardrobe
	icon_vend = "sigdrobe-vend"
	icon_deny = "sigdrobe-deny"
	req_access = list(ACCESS_TCOM_ADMIN)
	light_color = COLOR_VIVID_YELLOW

/obj/machinery/vending/wardrobe/cargo_wardrobe
	icon_vend = "cargodrobe-vend"
	icon_deny = "cargodrobe-deny"
	req_access = list(ACCESS_CARGO)
	light_color = COLOR_VIVID_YELLOW

/obj/machinery/vending/wardrobe/robo_wardrobe
	icon_vend = "robodrobe-vend"
	icon_deny = "robodrobe-deny"
	req_access = list(ACCESS_ROBO_CONTROL)

/obj/machinery/vending/wardrobe/science_wardrobe
	icon_vend = "scidrobe-vend"
	icon_deny = "scidrobe-deny"
	req_access = list(ACCESS_RESEARCH)

/obj/machinery/vending/wardrobe/hydro_wardrobe
	icon_vend = "hydrobe-vend"
	icon_deny = "hydrobe-deny"
	req_access = list(ACCESS_HYDROPONICS)

/obj/machinery/vending/wardrobe/curator_wardrobe
	icon_vend = "curadrobe-vend"
	icon_deny = "curadrobe-deny"
	req_access = list(ACCESS_LIBRARY)

/obj/machinery/vending/wardrobe/bar_wardrobe
	icon_vend = "bardrobe-vend"
	icon_deny = "bardrobe-deny"
	req_access = list(ACCESS_BAR)

/obj/machinery/vending/wardrobe/chef_wardrobe
	icon_vend = "chefdrobe-vend"
	icon_deny = "chefdrobe-deny"
	req_access = list(ACCESS_KITCHEN)

/obj/machinery/vending/wardrobe/jani_wardrobe
	icon_vend = "janidrobe-vend"
	icon_deny = "janidrobe-deny"
	req_access = list(ACCESS_JANITOR)

/obj/machinery/vending/wardrobe/law_wardrobe
	icon_vend = "lawdrobe-vend"
	icon_deny = "lawdrobe-deny"
	req_access = list(ACCESS_LAWYER)

/obj/machinery/vending/wardrobe/chap_wardrobe
	icon_vend = "chapdrobe-vend"
	icon_deny = "chapdrobe-deny"
	req_access = list(ACCESS_CHAPEL_OFFICE)

/obj/machinery/vending/wardrobe/chem_wardrobe
	icon_vend = "chemdrobe-vend"
	icon_deny = "chemdrobe-deny"
	req_access = list(ACCESS_CHEMISTRY)

/obj/machinery/vending/wardrobe/gene_wardrobe
	icon_vend = "genedrobe-vend"
	icon_deny = "genedrobe-deny"
	req_access = list(ACCESS_GENETICS)

/obj/machinery/vending/wardrobe/viro_wardrobe
	icon_vend = "virodrobe-vend"
	icon_deny = "virodrobe-deny"
	req_access = list(ACCESS_VIROLOGY)

/obj/machinery/vending/syndichem
	icon_vend = "generic-vend"
	icon_deny = "generic-deny"
	light_mask = "generic-light-mask"

/obj/machinery/vending/tool
	icon_vend = "tool-vend"
	light_color = COLOR_VIVID_YELLOW

/obj/machinery/vending/donksofttoyvendor
	icon_vend = "syndi-vend"
	icon_deny = "syndi-deny"
	light_color = COLOR_THEME_OPERATIVE
	light_mask = "donksoft-light-mask"

/obj/machinery/vending/sustenance
	icon_deny = "sustenance-deny"
	icon_vend = "sustenance-vend"

/obj/machinery/vending/sovietsoda
	icon_deny = "sovietsoda-deny"
	icon_vend = "sovietsoda-vend"
	light_mask = "soviet-light-mask"

/obj/machinery/vending/snack
	icon_vend = "snack-vend"
	icon_deny = "snack-deny"
	light_color = LIGHT_COLOR_BLUEGREEN

/obj/machinery/vending/snack/blue
	icon_vend = "snackblue-vend"
	icon_deny = "snackblue-deny"	

/obj/machinery/vending/snack/orange
	icon_vend = "snackorange-vend"
	icon_deny = "snackorange-deny"	

/obj/machinery/vending/snack/green
	icon_vend = "snackgreen-vend"
	icon_deny = "snackgreen-deny"		

/obj/machinery/vending/snack/teal
	icon_vend = "snackteal-vend"
	icon_deny = "snackteal-deny"

/obj/machinery/vending/security
	icon_vend = "sec-vend"
	light_color = LIGHT_COLOR_HOLY_MAGIC

/obj/machinery/vending/robotics
	icon_vend = "robotics-vend"

/obj/machinery/vending/plasmaresearch
	icon_deny = "generic-deny"
	icon_vend = "generic-vend"
	light_mask = "generic-light-mask"

/obj/machinery/vending/modularpc
	icon_vend = "modularpc-vend"

/obj/machinery/vending/magivend
	icon_deny = "magivend-deny"
	icon_vend = "magivend-vend"

/obj/machinery/vending/toyliberationstation
	icon_vend = "syndi-vend"
	icon_deny = "syndi-deny"
	light_color = COLOR_THEME_OPERATIVE

/obj/machinery/vending/liberationstation
	icon_vend = "liberationstation-vend"
	icon_deny = "liberationstation-deny"

/obj/machinery/vending/games
	icon_deny = "games-deny"
	icon_vend = "games-vend"

/obj/machinery/vending/engivend
	icon_vend = "engivend-vend"

/obj/machinery/vending/engineering
	icon_vend = "engi-vend"

/obj/machinery/vending/cola
	icon_vend = "Cola_Machine-vend"
	icon_deny = "Cola_Machine-deny"	

/obj/machinery/vending/cola/black
	icon_vend = "cola_black-vend"
	icon_deny = "cola_black-deny"			
	light_mask = "cola_black-light-mask"

/obj/machinery/vending/cola/red
	icon_vend = "red_cola-vend"
	icon_deny = "red_cola-deny"
	light_mask = "red_cola-light-mask"

/obj/machinery/vending/cola/space_up
	icon_vend = "space_up-vend"
	icon_deny = "space_up-deny"
	light_mask = "space_up-light-mask"

/obj/machinery/vending/cola/starkist
	icon_vend = "starkist-vend"
	icon_deny = "starkist-deny"
	light_color = LIGHT_COLOR_ORANGE
	light_mask = "starkist-light-mask"

/obj/machinery/vending/cola/sodie
	icon_vend = "soda-vend"
	icon_deny = "soda-deny"
	light_mask = "starkist-light-mask"

/obj/machinery/vending/cola/pwr_game
	icon_vend = "pwr_game-vend"
	icon_deny = "pwr_game-deny"
	light_mask = "pwr-light-mask"

/obj/machinery/vending/cola/shamblers
	icon_vend = "shamblers_juice-vend"
	icon_deny = "shamblers_juice-deny"
	light_mask = "shamblers-light-mask"

/obj/machinery/vending/coffee
	icon_deny = "coffee-deny"
	light_color = LIGHT_COLOR_BROWN

/obj/machinery/vending/clothing
	icon_vend = "clothes-vend"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN

/obj/machinery/vending/cigarette
	icon_vend = "cigs-vend"
	icon_deny = "cigs-deny"

/obj/machinery/vending/boozeomat
	icon_vend = "boozeomat-vend"
	light_color = LIGHT_COLOR_BLUEGREEN

/obj/machinery/vending/autodrobe
	icon_vend = "theater-vend"

/obj/machinery/vending/assist
	icon_vend = "parts-vend"
	icon_deny = "parts-deny"
	light_mask = "parts-light-mask"

/obj/machinery/vending/fishing
	icon_vend = "fishing-vend"
	light_mask = "fishing-light-mask"
	light_color = LIGHT_COLOR_ELECTRIC_GREEN

/obj/machinery/vending/gifts
	icon_vend = "gifts-vend"
	light_color = LIGHT_COLOR_HOLY_MAGIC
