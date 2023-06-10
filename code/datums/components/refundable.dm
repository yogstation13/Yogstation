/// A very basic component saying that this item is TC-refundable in an uplink.
/// Refundable items are expected to register COMSIG_ITEM_REFUND themselves.
/datum/component/refundable
	var/datum/mind/buyer
	var/tc_cost = 0

/datum/component/refundable/Initialize(datum/mind/buyer, tc_cost)
	src.buyer = buyer
	src.tc_cost = tc_cost
