#define MAX_SUPPLY_DROPS 4

/obj/machinery/computer/supplydrop_console
	name = "supply drop console"
	desc = "used by shipside staff to issue supply drops to squad beacons"
	icon_state = "supplydrop"
	screen_overlay = "supplydrop_screen"
	interaction_flags = INTERACT_MACHINE_TGUI
	circuit = /obj/item/circuitboard/computer/supplydrop
	faction = FACTION_TERRAGOV
	///Time between two supply drops
	var/launch_cooldown = 30 SECONDS
	///The beacon we will send the supplies
	var/datum/supply_beacon/supply_beacon = null
	///The linked supply pad of this console
	var/obj/structure/supply_drop/supply_pad
	///The content sent
	var/list/supplies = list()
	///X offset of the drop, relative to the supply beacon loc
	var/x_offset = 0
	///Y offset of the drop, relative to the supply beacon loc
	var/y_offset = 0
	COOLDOWN_DECLARE(next_fire)
	///Reference to the balloon vis obj effect
	var/atom/movable/vis_obj/fulton_balloon/balloon
	var/obj/effect/fulton_extraction_holder/holder_obj

/obj/machinery/computer/supplydrop_console/Initialize(mapload)
	. = ..()
	balloon = new()
	holder_obj = new()
	RegisterSignal(SSdcs, COMSIG_GLOB_SUPPLY_BEACON_CREATED, PROC_REF(ping_beacon))
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/supplydrop_console/LateInitialize()
	. = ..()
	for(var/obj/structure/supply_drop/_supply_pad AS in GLOB.supply_pad_list)
		if(_supply_pad.faction == faction)
			supply_pad = _supply_pad
			return

/// Used to notify of a new beacon target
/obj/machinery/computer/supplydrop_console/proc/ping_beacon()
	SIGNAL_HANDLER
	playsound(src,'sound/machines/terminal_prompt_confirm.ogg', 50, TRUE)

/obj/machinery/computer/supplydrop_console/Destroy()
	supply_beacon = null
	supply_pad = null
	return ..()

/obj/machinery/computer/supplydrop_console/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "SupplyDropConsole", name)
		ui.open()


/obj/machinery/computer/supplydrop_console/ui_data(mob/user)
	. = ..()
	.["launch_cooldown"] = launch_cooldown
	.["current_beacon"] = list(
		"name" = supply_beacon?.name,
		"x_coords" = supply_beacon?.drop_location.x,
		"y_coords" = supply_beacon?.drop_location.y
	)
	.["supplies_count"] = length(supplies)
	.["next_fire"] = COOLDOWN_TIMELEFT(src, next_fire)
	.["x_offset"] = x_offset
	.["y_offset"] = y_offset


/obj/machinery/computer/supplydrop_console/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("select_beacon")
			var/list/beacon_list = GLOB.supply_beacon.Copy()
			for(var/beacon_name in beacon_list)
				var/datum/supply_beacon/beacon = beacon_list[beacon_name]
				if(!is_ground_level(beacon.drop_location.z))
					beacon_list -= beacon_name
					continue
			var/datum/supply_beacon/supply_beacon_choice = beacon_list[tgui_input_list(ui.user, "Select the beacon to send supplies", "Beacon choice", beacon_list)]
			if(!istype(supply_beacon_choice))
				return
			supply_beacon = supply_beacon_choice
			RegisterSignal(supply_beacon, COMSIG_QDELETING, PROC_REF(clean_supply_beacon), override = TRUE)
			refresh_pad()
		if("set_x")
			var/new_x = text2num(params["set_x"])
			if(!isnum(new_x))
				return
			x_offset = new_x

		if("set_y")
			var/new_y = text2num(params["set_y"])
			if(!isnum(new_y))
				return
			y_offset = new_y

		if("refresh_pad")
			refresh_pad()

		if("send_beacon")
			if(!COOLDOWN_CHECK(src, next_fire))
				return

			if(!supply_beacon)
				to_chat(usr, "[icon2html(src, usr)] [span_warning("There was an issue with that beacon. Check it's still active.")]")
				return

			if(!length(supplies))
				to_chat(usr, "[icon2html(src, usr)] [span_warning("There wasn't any supplies found on the squads supply pad. Double check the pad.")]")
				return

			if(!istype(supply_beacon.drop_location) || !is_ground_level(supply_beacon.drop_location.z))
				to_chat(usr, "[icon2html(src, usr)] [span_warning("The [supply_beacon.name] was not detected on the ground.")]")
				return
			if(isspaceturf(supply_beacon.drop_location) || supply_beacon.drop_location.density)
				to_chat(usr, "[icon2html(src, usr)] [span_warning("The [supply_beacon.name]'s landing zone appears to be obstructed or out of bounds.")]")
				return

			COOLDOWN_START(src, next_fire, launch_cooldown)
			send_supplydrop(supplies, x_offset, y_offset)

///Clean up the supply beacon var
/obj/machinery/computer/supplydrop_console/proc/clean_supply_beacon()
	SIGNAL_HANDLER
	supply_beacon = null
	refresh_pad()

///Look for the content on the supply pad
/obj/machinery/computer/supplydrop_console/proc/refresh_pad()
	supplies = list()
	if(!supply_beacon)
		return
	for(var/obj/C in supply_pad.loc)
		if(is_type_in_typecache(C, GLOB.supply_drops) && !C.anchored) //Can only send vendors, crates, unmanned vehicles and large crates
			supplies.Add(C)
		if(length(supplies) > MAX_SUPPLY_DROPS)
			break

///Start the supply drop process
/obj/machinery/computer/supplydrop_console/proc/send_supplydrop(list/supplies, x_offset = 0, y_offset = 0)
	if(!supply_beacon)
		stack_trace("Trying to send a supply drop without a supply beacon")
		return

	if(!length(supplies) || length(supplies) > MAX_SUPPLY_DROPS)
		stack_trace("Trying to send a supply drop with an invalid amount of items [length(supplies)]")
		return

	if(!istype(supply_beacon.drop_location) || isspaceturf(supply_beacon.drop_location) || supply_beacon.drop_location.density)
		stack_trace("Trying to send a supply drop to a beacon on an invalid turf")
		return

	x_offset = clamp(round(x_offset), -5, 5)
	y_offset = clamp(round(y_offset), -5, 5)

	supply_pad.visible_message(span_boldnotice("The supply drop is now loading into the launch tube! Stand by!"))
	supply_pad.visible_message(span_warning("\The [supply_pad] whirrs as it beings to load the supply drop into a bluespace launch tube. Stand clear!"))
	for(var/obj/C in supplies)
		C.anchored = TRUE //to avoid accidental pushes
	playsound(supply_pad.loc, 'sound/effects/bamf.ogg', 50, TRUE)
	visible_message("[icon2html(supply_beacon, viewers(supply_beacon))] [span_boldnotice("The [supply_pad.name] begins to beep!")]")
	addtimer(CALLBACK(src, PROC_REF(fire_supplydrop), supplies, x_offset, y_offset), 10 SECONDS)

///Make the supplies teleport
/obj/machinery/computer/supplydrop_console/proc/fire_supplydrop(list/supplies, x_offset, y_offset)
	for(var/obj/C in supplies)
		if(QDELETED(C))
			supplies.Remove(C)
			continue
		if(C.loc != supply_pad.loc) //Crate no longer on pad somehow, abort.
			supplies.Remove(C)
		C.anchored = FALSE //We need to un-anchor the crate after we're finished, even if it fails to send

	if(QDELETED(supply_beacon))
		visible_message("[icon2html(supply_pad, usr)] [span_warning("Launch aborted! Supply beacon signal lost.")]")
		return

	if(!is_ground_level(supply_beacon.drop_location.z))
		visible_message("[icon2html(supply_pad, usr)] [span_warning("Launch aborted! Supply beacon is not groundside.")]")
		return

	if(!length(supplies))
		visible_message("[icon2html(supply_pad, usr)] [span_warning("Launch aborted! No deployable object detected on the drop pad.")]")
		return

	supply_beacon.drop_location.visible_message(span_boldnotice("A supply drop appears suddenly!"))
	playsound(supply_beacon.drop_location,'sound/effects/tadpolehovering.ogg', 30, TRUE)
	playsound(supply_pad.loc,'sound/effects/phasein.ogg', 50, TRUE)
	for(var/obj/C in supplies)
		var/turf/TC = locate(supply_beacon.drop_location.x + x_offset, supply_beacon.drop_location.y + y_offset, supply_beacon.drop_location.z)
		C.moveToNullspace()
		holder_obj.appearance = C.appearance
		holder_obj.forceMove(TC)
		addtimer(CALLBACK(src, PROC_REF(cleanup_delivery), C, TC), 3 SECONDS)

	supply_pad.visible_message("[icon2html(supply_pad, viewers(src))] [span_boldnotice("Supply drop teleported! Another launch will be available in [launch_cooldown * 0.1] seconds.")]")

	balloon.icon_state = initial(balloon.icon_state)
	holder_obj.vis_contents += balloon

	flick("fulton_expand", balloon)
	balloon.icon_state = "fulton_balloon"

	holder_obj.pixel_z = 360
	animate(holder_obj, 3 SECONDS, pixel_z = 0)

/obj/machinery/computer/supplydrop_console/proc/cleanup_delivery(atom/movable/C, turf/TC)
	C.forceMove(TC)
	holder_obj.moveToNullspace()
	holder_obj.pixel_z = initial(C.pixel_z)
	holder_obj.vis_contents -= balloon
	balloon.icon_state = initial(balloon.icon_state)
