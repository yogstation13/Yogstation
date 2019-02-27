/datum/bank_account/bank_card_talk(message)
	if(!message || !bank_cards.len)
		return
	for(var/obj/A in bank_cards)
		playsound(A, 'sound/machines/twobeep.ogg', 50, TRUE)
		A.send_speech(message, 1, src, , A.get_spans(), message_language = A.get_default_language())
