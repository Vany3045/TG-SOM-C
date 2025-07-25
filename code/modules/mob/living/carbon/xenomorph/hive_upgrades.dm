#define PRIMORDIAL_TIER_ONE "Primordial Tier One"
#define PRIMORDIAL_TIER_TWO "Primordial Tier Two"
#define PRIMORDIAL_TIER_THREE "Primordial Tier Three"
#define PRIMORDIAL_TIER_FOUR "Primordial Tier Four"

GLOBAL_LIST_INIT(upgrade_categories, list("Buildings", "Defences", "Primordial"))//, "Xenos"))//uncomment to unlock globally
GLOBAL_LIST_INIT(tier_to_primo_upgrade, list(
	XENO_TIER_ONE = PRIMORDIAL_TIER_ONE,
	XENO_TIER_TWO = PRIMORDIAL_TIER_TWO,
	XENO_TIER_THREE = PRIMORDIAL_TIER_THREE,
	XENO_TIER_FOUR = PRIMORDIAL_TIER_FOUR,
))

/datum/hive_purchases
	interaction_flags = INTERACT_UI_INTERACT
	///Flat list of upgrades we can buy
	var/list/buyable_upgrades = list()
	///Assocative list name = upgraderef
	var/list/datum/hive_upgrade/upgrades_by_name = list()

// ***************************************
// *********** UI for hive store/blessing menu
// ***************************************

///Initializing hive status with all relevant to be purchased upgrades.
/datum/hive_purchases/proc/setup_upgrades()
	for(var/type in subtypesof(/datum/hive_upgrade))
		var/datum/hive_upgrade/upgrade = new type
		if(upgrade.name == "Error upgrade") //defaultname just skip it its probably organisation
			continue
		if(!(SSticker.mode.xeno_abilities_flags & upgrade.gamemode_flags))
			continue
		buyable_upgrades += upgrade
		upgrades_by_name[upgrade.name] = upgrade

/datum/hive_purchases/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BlessingMenu", "Queen Mothers Blessings")
		ui.open()

/datum/hive_purchases/ui_state(mob/user)
	return GLOB.conscious_state

/datum/hive_purchases/ui_assets(mob/user)
	. = ..()
	. += get_asset_datum(/datum/asset/spritesheet/blessingmenu)

/datum/hive_purchases/ui_data(mob/user)
	. = ..()

	var/mob/living/carbon/xenomorph/X = user

	.["upgrades"] = list()
	for(var/datum/hive_upgrade/upgrade AS in buyable_upgrades)
		.["upgrades"] += list(list("name" = upgrade.name, "desc" = upgrade.desc, "category" = upgrade.category,\
		"cost" = upgrade.psypoint_cost, "times_bought" = upgrade.times_bought, "iconstate" = upgrade.icon))
	.["psypoints"] = SSpoints.xeno_points_by_hive[X.hive.hivenumber]

/datum/hive_purchases/ui_static_data(mob/user)
	. = ..()
	.["categories"] = GLOB.upgrade_categories

/datum/hive_purchases/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("buy")
			var/buying = params["buyname"]
			var/datum/hive_upgrade/upgrade = upgrades_by_name[buying]
			var/mob/living/carbon/xenomorph/user = usr
			if(!upgrade.can_buy(user, FALSE))
				return
			if(!upgrade.on_buy(user))
				return
			log_game("[key_name(user)] has purchased \a [upgrade] Blessing for [upgrade.psypoint_cost] psypoints for the [user.hive.hivenumber] hive")
			if(upgrade.upgrade_flags & UPGRADE_FLAG_MESSAGE_HIVE)
				xeno_message("[user] has purchased \a [upgrade] Blessing", "xenoannounce", 5, user.hivenumber)

/datum/hive_upgrade
	///name of the upgrade, string, used in ui
	var/name = "Error upgrade"
	///desc of the upgrade, string, used in ui
	var/desc = "Error upgrade description"
	///name of the category it belongs to, string, used in ui
	var/category = "ERROR CATEGORY"
	///Psy point cost, float
	var/psypoint_cost = 10
	///upgrade flag var
	var/upgrade_flags = NONE
	///gamemode flags to whether this upgrade is purchasable
	var/gamemode_flags = ABILITY_ALL_GAMEMODE
	///int of the times we bought this upgrade
	var/times_bought = 0
	///string for UI icon in buyable_icons.dmi for this upgrade
	var/icon = "larvasilo"

/**
 * Buys the upgrade and applies its effects
 * returns true on success false on fail
 * Arguments:
 * * buyer: Xeno trying to buy this upgrade
 */
/datum/hive_upgrade/proc/on_buy(mob/living/carbon/xenomorph/buyer)
	SHOULD_CALL_PARENT(TRUE)
	SSpoints.xeno_points_by_hive[buyer.hivenumber] -= psypoint_cost
	times_bought++
	/*RUTGMC EDIT begin */
	if(buyer.status_flags & INCORPOREAL)
		to_chat(buyer, span_xenowarning("You can't build in this form!"))
		return FALSE
	/*RUTGMC EDIT end*/
	return TRUE

/**
 * Whether we can buy this upgrade, used to set the menu button as grey or not
 * returns true on can false on cannot
 * Arguments:
 * * buyer: Xeno trying to buy this upgrade
 * * silent: whether to send error messages to the buyer
 */
/datum/hive_upgrade/proc/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	SHOULD_CALL_PARENT(TRUE)
	if((upgrade_flags & UPGRADE_FLAG_ONETIME) && times_bought)
		return FALSE
	if(buyer.status_flags & INCORPOREAL)
		to_chat(buyer, span_xenowarning("You can't build in this form!"))
		return FALSE
	if(SSpoints.xeno_points_by_hive[buyer.hivenumber] < psypoint_cost)
		if(!silent)
			to_chat(buyer, span_xenowarning("You need [psypoint_cost-SSpoints.xeno_points_by_hive[buyer.hivenumber]] more points to request this blessing!"))
		return FALSE
	return TRUE

/datum/hive_upgrade/building
	category = "Buildings"
	///The type of building created
	var/building_type
	///Building time, in seconds. 10 by default.
	var/building_time = 10 SECONDS

/datum/hive_upgrade/building/can_buy(mob/living/carbon/xenomorph/buyer, silent)
	. = ..()
	if(!.)
		return
	var/turf/buildloc = get_turf(buyer)
	if(!buildloc)
		return FALSE

	if(!buildloc.is_weedable())
		if(!silent)
			to_chat(buyer, span_warning("We can't do that here."))
		return FALSE

	var/obj/alien/weeds/alien_weeds = locate() in buildloc

	if(!alien_weeds)
		if(!silent)
			to_chat(buyer, span_warning("We can only shape on weeds. We must find some resin before we start building!"))
		return FALSE

	if(!buildloc.check_alien_construction(buyer, silent, building_type) || !buildloc.check_disallow_alien_fortification(buyer, silent))
		return FALSE

/datum/hive_upgrade/building/on_buy(mob/living/carbon/xenomorph/buyer)
	if(!do_after(buyer, building_time, NONE, buyer, BUSY_ICON_BUILD))
		return FALSE

	if(!can_buy(buyer, FALSE))
		return FALSE

	var/atom/built = new building_type(get_turf(buyer), buyer.hivenumber)
	to_chat(buyer, span_notice("We build [built] for [psypoint_cost] psy points."))
	log_game("[buyer] has built \a [built] in [AREACOORD(built)], spending [psypoint_cost] psy points in the process")
	xeno_message("[buyer] has built \a [built] at [get_area(built)]!", "xenoannounce", 5, buyer.hivenumber)
	return ..()

/datum/hive_upgrade/building/silo
	name = "Larva Silo"
	desc = "Constructs a silo that generates xeno larvas over time."
	psypoint_cost = SILO_PRICE
	icon = "larvasilo"
	upgrade_flags = ABILITY_NUCLEARWAR
	building_type = /obj/structure/xeno/silo

/datum/hive_upgrade/building/silo/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return

	var/turf/buildloc = get_turf(buyer)
	if(!buildloc)
		return FALSE

	if(buildloc.density)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot build in a dense location!"))
		return FALSE

	for(var/hive in GLOB.xeno_resin_silos_by_hive)
		for(var/silo in hive)
			if(get_dist(silo, buyer) < 15)
				to_chat(buyer, span_xenowarning("Another silo is too close!"))
				return FALSE

	var/max_silo = SSticker.mode.max_silo_ammount
	if(length(GLOB.xeno_resin_silos_by_hive[buyer.hivenumber]) >= max_silo)
		if(!silent)
			to_chat(buyer, span_xenowarning("Hive cannot support more than [max_silo] active silos!"))
		return FALSE

/datum/hive_upgrade/building/evotower
	name = "Evolution Tower"
	desc = "Constructs a tower that increases the rate of evolution point and maturity point generation by 1.5 per tower."
	psypoint_cost = 300
	icon = "evotower"
	upgrade_flags = ABILITY_NUCLEARWAR
	building_type = /obj/structure/xeno/evotower

/datum/hive_upgrade/building/psychictower
	name = "Psychic Relay"
	desc = "Constructs a tower that increases the number of available slots of higher tier castes."
	psypoint_cost = 300
	icon = "maturitytower"
	upgrade_flags = ABILITY_NUCLEARWAR
	building_type = /obj/structure/xeno/psychictower

/datum/hive_upgrade/building/pherotower
	name = "Pheromone Tower"
	desc = "Constructs a tower that emanates a selectable type of pheromone."
	psypoint_cost = 150
	icon = "pherotower"
	upgrade_flags = ABILITY_NUCLEARWAR
	building_type = /obj/structure/xeno/pherotower
	building_time = 5 SECONDS

/datum/hive_upgrade/building/spawner
	name = "Spawner"
	desc = "Constructs a spawner that generates ai xenos over time"
	psypoint_cost = 600
	icon = "spawner"
	upgrade_flags = ABILITY_NUCLEARWAR
	building_type = /obj/structure/xeno/spawner

/datum/hive_upgrade/building/upgrade_chamber
	upgrade_flags = ABILITY_NUCLEARWAR
	var/max_chambers = 3

/datum/hive_upgrade/building/upgrade_chamber/shell
	name = "Shell Upgrade Chamber"
	desc = "Constructs a chamber that allows xenos to buy survival mutations. Build up to 3 structures to increase mutation power."
	icon = "shell"
	psypoint_cost = 200
	building_type = /obj/structure/xeno/upgrade_chamber/shell

/datum/hive_upgrade/building/upgrade_chamber/shell/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return

	var/turf/buildloc = get_turf(buyer)
	if(!buildloc)
		return FALSE
	if(length(buyer.hive.shell_chambers) >= max_chambers)
		to_chat(buyer, span_xenowarning("Hive cannot support more than [max_chambers] active shell chambers!"))
		return FALSE

/datum/hive_upgrade/building/upgrade_chamber/spur
	name = "Spur Upgrade Chamber"
	desc = "Constructs a chamber that allows xenos to buy attack mutations. Build up to 3 structures to increase mutation power."
	icon = "spur"
	psypoint_cost = 150
	building_type = /obj/structure/xeno/upgrade_chamber/spur

/datum/hive_upgrade/building/upgrade_chamber/spur/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return

	var/turf/buildloc = get_turf(buyer)
	if(!buildloc)
		return FALSE

	if(length(buyer.hive.spur_chambers) >= max_chambers)
		to_chat(buyer, span_xenowarning("Hive cannot support more than [max_chambers] active spur chambers!"))
		return FALSE

/datum/hive_upgrade/building/upgrade_chamber/veil
	name = "Veil Upgrade Chamber"
	desc = "Constructs a chamber that allows xenos to buy utility mutations. Build up to 3 structures to increase mutation power."
	icon = "veil"
	psypoint_cost = 100
	building_type = /obj/structure/xeno/upgrade_chamber/veil

/datum/hive_upgrade/building/upgrade_chamber/veil/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return

	var/turf/buildloc = get_turf(buyer)
	if(!buildloc)
		return FALSE
	if(length(buyer.hive.veil_chambers) >= max_chambers)
		to_chat(buyer, span_xenowarning("Hive cannot support more than [max_chambers] active veil chambers!"))
		return FALSE

/datum/hive_upgrade/defence
	category = "Defences"

/datum/hive_upgrade/defence/turret
	name = "Acid Turret"
	desc = "Places a acid spitting resin turret under you. Must be at least 6 tiles away from other turrets, not near fog, and on a weeded area."
	icon = "acidturret"
	psypoint_cost = 80
	gamemode_flags = ABILITY_NUCLEARWAR
	///How long to build one turret
	var/build_time = 10 SECONDS
	///What type of turret is built
	var/turret_type = /obj/structure/xeno/turret

/datum/hive_upgrade/defence/turret/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/xenomorph/blocker = locate() in T
	if(blocker && blocker != buyer && blocker.stat != DEAD)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot build with [blocker] in the way!"))
		return FALSE

	if(!T.is_weedable())
		return FALSE

	if(!buyer.loc_weeds_type)
		if(!silent)
			to_chat(buyer, span_xenowarning("No weeds here!"))
		return FALSE

	if(!T.check_alien_construction(buyer, silent, /obj/structure/xeno/turret) || !T.check_disallow_alien_fortification(buyer))
		return FALSE

	for(var/obj/structure/xeno/turret/turret AS in GLOB.xeno_resin_turrets_by_hive[blocker.hivenumber])
		if(get_dist(turret, buyer) < 6)
			if(!silent)
				to_chat(buyer, span_xenowarning("Another turret is too close!"))
			return FALSE

	return TRUE

/datum/hive_upgrade/defence/turret/on_buy(mob/living/carbon/xenomorph/buyer)
	if(!do_after(buyer, build_time, NONE, buyer, BUSY_ICON_BUILD))
		return FALSE

	if(!can_buy(buyer, FALSE))
		return FALSE

	to_chat(buyer, span_xenowarning("We build a new acid turret, spending [psypoint_cost] psychic points in the process"))
	new turret_type(get_turf(buyer), buyer.hivenumber)

	log_game("[buyer] built a turret in [AREACOORD(buyer)], spending [psypoint_cost] psy points in the process")
	xeno_message("[buyer] has built a new turret at [get_area(buyer)]!", "xenoannounce", 5, buyer.hivenumber)

	return ..()

/datum/hive_upgrade/defence/turret/sticky
	name = "Sticky Resin Turret"
	desc = "Places a sticky spit spitting resin turret under you. Must be at least 6 tiles away from other turrets, not near fog, and on a weeded area."
	icon = "resinturret"
	psypoint_cost = 50
	turret_type = /obj/structure/xeno/turret/sticky

/datum/hive_upgrade/xenos
	category = "Xenos"

/datum/hive_upgrade/primordial
	category = "Primordial"
	upgrade_flags = UPGRADE_FLAG_ONETIME|UPGRADE_FLAG_MESSAGE_HIVE

/datum/hive_upgrade/primordial/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!isxenoqueen(buyer) && !isxenoshrike(buyer) && !isxenoking(buyer))
		if(!silent)
			to_chat(buyer, span_xenonotice("You must be a ruler to buy this!"))
		return FALSE

/datum/hive_upgrade/primordial/tier_four
	name = PRIMORDIAL_TIER_FOUR
	desc = "Unlocks the primordial for the last tier"
	psypoint_cost = 800
	icon = "primoqueen"

/datum/hive_upgrade/primordial/tier_three
	name = PRIMORDIAL_TIER_THREE
	desc = "Unlocks the primordial for the third tier"
	psypoint_cost = 1000
	icon = "primorav"

/datum/hive_upgrade/primordial/tier_two
	name = PRIMORDIAL_TIER_TWO
	desc = "Unlocks the primordial for the second tier"
	psypoint_cost = 800
	icon = "primowarrior"

/datum/hive_upgrade/primordial/tier_one
	name = PRIMORDIAL_TIER_ONE
	desc = "Unlocks the primordial for the first tier"
	psypoint_cost = 600
	icon = "primosent"

/datum/hive_upgrade/defence/oblivion
	name = "Oblivion"
	desc = "Destroy the bodies beneath you "
	icon = "smartminions"
	psypoint_cost = 500
	gamemode_flags = ABILITY_NUCLEARWAR

/datum/hive_upgrade/defence/oblivion/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/human/H = locate() in T
	var/mob/living/carbon/human/species/synthetic = locate() in T
	if(!H || H.stat != DEAD || synthetic)
		if(!silent)
			to_chat(buyer, span_xenowarning("You cannot destroy nothing or alive"))
		return FALSE

	return TRUE

/datum/hive_upgrade/defence/oblivion/on_buy(mob/living/carbon/xenomorph/buyer)

	if(!can_buy(buyer, FALSE))
		return FALSE

	var/turf/T = get_turf(buyer)
	var/mob/living/carbon/human/H = locate() in T
	xeno_message("[buyer] sent [H] into oblivion!", "xenoannounce", 5, buyer.hivenumber)
	to_chat(buyer, span_xenowarning("WE HAVE SENT THE [H] INTO OBLIVION"))
	H.gib()

	log_game("[buyer] sent [H] into oblivion, spending [psypoint_cost] psy points in the process")


	return ..()

/datum/hive_upgrade/building/nest
	name = "Thick nest"
	desc = "A very thick nest, oozing with a thick sticky substance."
	psypoint_cost = 0
	icon = "nest"
	building_type = /obj/structure/xeno/thick_nest
	building_time = 5 SECONDS

/datum/hive_upgrade/building/nest/can_buy(mob/living/carbon/xenomorph/buyer, silent = TRUE)
	. = ..()
	if(!.)
		return
	if(length(buyer.hive.thick_nests) >= buyer.hive.max_thick_nests)
		to_chat(buyer, span_xenowarning("You cannot build any more thick nests!"))
		return FALSE
	return .
