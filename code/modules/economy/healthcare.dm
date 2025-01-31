#define CARE_BASIC_CHECKUP "Basic Checkup"
#define CARE_VACCINATION "Vaccination"
#define CARE_MINOR_SURGERY "Minor Surgery"
#define CARE_MAJOR_SURGERY "Major Surgery"
#define CARE_EMERGENCY "Emergency Care"
#define CARE_PRESCRIPTION "Prescription"
#define CARE_MENTAL "Mental Health Consultataion"

/// This machine is designed to encourage medical staff to charge patients exorbitant prices for basic care
/obj/machinery/healthcare_computer
	name = "healthcare computer"
	desc = "A convenient and user-friendly computer interface for all of your healthcare needs."
	icon = 'yogstation/icons/obj/register.dmi'
	icon_state = "register"
	clicksound = "keyboard"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF // death & taxes
	flags_1 = NODECONSTRUCT_1
	var/obj/item/radio/radio
	var/current_price = 0
	var/list/selected_care
	var/static/list/available_care
	var/department_tax = 0.08

/obj/machinery/healthcare_computer/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.keyslot = new /obj/item/encryptionkey/headset_med
	radio.subspace_transmission = TRUE
	radio.listening = FALSE
	radio.recalculateChannels()

	if(available_care && islist(available_care))
		return

	available_care = list(
		CARE_BASIC_CHECKUP = floor(50 * (1.0 + department_tax)),
		CARE_VACCINATION = floor(75 * (1.0 + department_tax)),
        CARE_MINOR_SURGERY = floor(150 * (1.0 + department_tax)),
		CARE_MAJOR_SURGERY = floor(300 * (1.0 + department_tax)),
        CARE_EMERGENCY = floor(200 * (1.0 + department_tax)),
		CARE_PRESCRIPTION = floor(100 * (1.0 + department_tax)),
		CARE_MENTAL = floor(100 * (1.0 + department_tax)),
	)

/obj/machinery/healthcare_computer/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.combat_mode && user.stat == CONSCIOUS)
		ui_interact(user)
		return .
	return

/obj/machinery/healthcare_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!is_operational())
		return
	if (!ui)
		ui = new(user, src, "Healthcare", name)
		ui.open()

/obj/machinery/healthcare_computer/ui_data(mob/user)
	. = ..()
	var/payee = "none"
	var/obj/item/card/id/card = user.get_idcard(TRUE)
	if(card?.registered_account?.account_holder)
		payee = card.registered_account.account_holder
	.["payee"] = payee
	.["current_price"] = current_price
	.["selected_care"] = selected_care
	.["available_care"] = available_care

/obj/machinery/healthcare_computer/ui_act(action, list/params)
	if(..())
		return TRUE
	if(!is_operational())
		return

	switch(action)
		if("toggle_care")
			var/care_name = params["care"]
			if(!istext(care_name))
				return
			if(!available_care[care_name])
				return
			if(!selected_care)
				selected_care = list()
			if(care_name in selected_care)
				selected_care -= care_name
				current_price -= available_care[care_name]
			else
				selected_care |= care_name
				current_price += available_care[care_name]
			return TRUE
		if("pay_for_care")
			var/card = usr.get_idcard(TRUE)
			if(!card)
				return
			if(!charge_card(card))
				return
			return TRUE

/obj/machinery/healthcare_computer/proc/charge_card(obj/item/card/id/victim)
	if(!victim.registered_account)
		return FALSE
	if(current_price <= 0)
		return FALSE
	if(!selected_care || !islist(selected_care) || selected_care.len == 0)
		return FALSE
	if(!victim || !istype(victim))
		return FALSE

	if(!victim.registered_account.has_money(-1050))
		victim.registered_account.bank_card_talk("Severe debt fraud detected! This ID will now self-destruct. Please contact a member of command to be issued a new ID.", TRUE)
		qdel(victim)
		playsound(src.loc, 'sound/items/pshred.ogg', 75, TRUE)
		return

	victim.registered_account._adjust_money(-current_price) // can't pay? it's ok, you'll just go into debt
	. = TRUE

	var/list/datum/bank_account/payouts = list()
	var/m_staff_amt = 0
	for(var/datum/bank_account/account_id as anything in SSeconomy.bank_accounts)
		var/datum/bank_account/account = SSeconomy.bank_accounts[account_id]
		if(account.account_job && (account.account_job.title in GLOB.medical_positions))
			payouts += account
			m_staff_amt += 1

	var/datum/bank_account/med_account = SSeconomy.get_dep_account(ACCOUNT_MED)
	med_account.adjust_money(floor(current_price * department_tax))
	var/after_tax = current_price * (1.0 - department_tax)

	var/payout_amt = floor(after_tax / m_staff_amt)
	for(var/datum/bank_account/medical_staff as anything in payouts)
		medical_staff.adjust_money(payout_amt)

	var/care = selected_care.Join(", ")
	radio.talk_into(src, "[victim.registered_account.account_holder] has paid for [care]. Medical staff have been paid [payout_amt]cr each.", RADIO_CHANNEL_MEDICAL)

	current_price = 0
	selected_care = null

	say("Thank you for your patronage, [victim.registered_account.account_holder]! Medical staff have been paid and notified. You are entitled to the following: [care]")
	playsound(src.loc, 'sound/effects/cashregister.ogg', 20, TRUE)

#undef CARE_BASIC_CHECKUP
#undef CARE_VACCINATION
#undef CARE_MINOR_SURGERY
#undef CARE_MAJOR_SURGERY
#undef CARE_EMERGENCY
#undef CARE_PRESCRIPTION
#undef CARE_MENTAL
