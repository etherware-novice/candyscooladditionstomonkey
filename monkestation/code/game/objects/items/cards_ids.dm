/obj/item/card/emag/chip
	desc = "It is an ID card, the magnetic strip is exposed and attached to a small chip. The id's shell is still attached, hanging loosely."
	var/mining_points = 0 //For redeeming at mining equipment vendors
	var/list/access = list()
	var/registered_name = null // The name registered_name on the card
	var/assignment = null
	var/access_txt // mapping aid
	var/datum/bank_account/registered_account
	var/obj/machinery/paystand/my_store

/obj/item/card/emag/chip/attack_self(mob/user)
	var/obj/item/card/id/replacement = new(src.loc)
	replacement.mining_points = mining_points
	replacement.assignment = assignment
	replacement.access_txt = access_txt
	replacement.registered_account = registered_account
	replacement.my_store = my_store
	replacement.emagged = 1
	user.put_in_hands(replacement)
	qdel(src)
