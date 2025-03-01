/obj/machinery/vending/snack
	name = "\improper Getmore Chocolate Corp"
	desc = "A snack machine courtesy of the Getmore Chocolate Corporation, based out of Mars."
	product_slogans = "Try our new nougat bar!;Twice the calories for half the price!"
	product_ads = "The healthiest!;Award-winning chocolate bars!;Mmm! So good!;Oh my god it's so juicy!;Have a snack.;Snacks are good for you!;Have some more Getmore!;Best quality snacks straight from mars.;We love chocolate!;Try our new jerky!"
	icon_state = "snack"
	//MonkeStation Edit Start: Reduction of Junk Food
	products = list(/obj/item/food/spacetwinkie = 2,
					/obj/item/food/cheesiehonkers = 2,
					/obj/item/food/candy = 2,
		            /obj/item/food/chips = 2,
		            /obj/item/food/sosjerky = 2,
					/obj/item/food/no_raisin = 2,
					/obj/item/food/peanuts = 6,
					/obj/item/food/peanuts/random = 3,
					/obj/item/food/cnds = 6,
					/obj/item/food/cnds/random = 3,
					/obj/item/reagent_containers/food/drinks/dry_ramen = 2,
					/obj/item/food/energybar = 6)
	contraband = list(/obj/item/food/syndicake = 2)
	//MonkeStation Edit End
	refill_canister = /obj/item/vending_refill/snack
	var/chef_compartment_access = "28" //ACCESS_KITCHEN
	default_price = 50 //MonkeStation Edit: Reduction of junk food
	extra_price = 30
	payment_department = NO_FREEBIES //MonkeStation Edit: NO FREE LUNCH

/obj/item/vending_refill/snack
	machine_name = "Getmore Chocolate Corp"

/obj/machinery/vending/snack/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/food))
		if(!compartment_access_check(user))
			return
		var/obj/item/food/S = W
		if(!S.junkiness)
			if(!iscompartmentfull(user))
				if(!user.transferItemToLoc(W, src))
					return
				food_load(W)
				to_chat(user, "<span class='notice'>You insert [W] into [src]'s chef compartment.</span>")
		else
			to_chat(user, "<span class='notice'>[src]'s chef compartment does not accept junk food.</span>")

	else if(istype(W, /obj/item/storage/bag/tray))
		if(!compartment_access_check(user))
			return
		var/obj/item/storage/T = W
		var/loaded = 0
		var/denied_items = 0
		for(var/obj/item/food/S in T.contents)
			if(iscompartmentfull(user))
				break
			if(!S.junkiness)
				SEND_SIGNAL(T, COMSIG_TRY_STORAGE_TAKE, S, src, TRUE)
				food_load(S)
				loaded++
			else
				denied_items++
		if(denied_items)
			to_chat(user, "<span class='notice'>[src] refuses some items.</span>")
		if(loaded)
			to_chat(user, "<span class='notice'>You insert [loaded] dishes into [src]'s chef compartment.</span>")
		updateUsrDialog()
		return

	else
		return ..()

/obj/machinery/vending/snack/Destroy()
	for(var/obj/item/food/S in contents)
		S.forceMove(get_turf(src))
	return ..()

/obj/machinery/vending/snack/proc/compartment_access_check(user)
	req_access_txt = chef_compartment_access
	if(!allowed(user) && !(obj_flags & EMAGGED) && scan_id)
		to_chat(user, "<span class='warning'>[src]'s chef compartment blinks red: Access denied.</span>")
		req_access_txt = "0"
		return 0
	req_access_txt = "0"
	return 1

/obj/machinery/vending/snack/proc/iscompartmentfull(mob/user)
	if(contents.len >= 30) // no more than 30 dishes can fit inside
		to_chat(user, "<span class='warning'>[src]'s chef compartment is full.</span>")
		return 1
	return 0

/obj/machinery/vending/snack/proc/food_load(obj/item/food/S)
	if(dish_quants[S.name])
		dish_quants[S.name]++
	else
		dish_quants[S.name] = 1
	sortList(dish_quants)

/obj/machinery/vending/snack/random
	name = "\improper Random Snackies"
	icon_state = "random_snack"
	desc = "Uh oh!"

/obj/machinery/vending/snack/random/Initialize(mapload)
	..()
	var/T = pick(subtypesof(/obj/machinery/vending/snack) - /obj/machinery/vending/snack/random)
	new T(loc)
	return INITIALIZE_HINT_QDEL

/obj/machinery/vending/snack/blue
	icon_state = "snackblue"

/obj/machinery/vending/snack/orange
	icon_state = "snackorange"

/obj/machinery/vending/snack/green
	icon_state = "snackgreen"

/obj/machinery/vending/snack/teal
	icon_state = "snackteal"
