/*
	Global associative list for caching humanoid icons.
	Index format m or f, followed by a string of 0 and 1 to represent bodyparts followed by husk fat hulk skeleton 1 or 0.
	TODO: Proper documentation
	icon_key is [species.race_key][g][husk][fat][hulk][skeleton][ethnicity][height]
*/
GLOBAL_LIST_EMPTY(human_icon_cache)

	///////////////////////
	//UPDATE_ICONS SYSTEM//
	///////////////////////
/*

Another feature of this new system is that our lists are indexed. This means we can update specific overlays!
So we only regenerate icons when we need them to be updated! This is the main saving for this system.

In practice this means that:
	Everytime you do something minor like take a pen out of your pocket, we only update the in-hand overlay
	etc...


There are several things that need to be remembered:

>	Whenever we do something that should cause an overlay to update (which doesn't use standard procs
	( i.e. you do something like l_hand = /obj/item/something new(src) )
	You will need to call the relevant update_inv_* proc:
		update_inv_head()
		update_inv_wear_suit()
		update_inv_gloves()
		update_inv_shoes()
		update_inv_w_uniform()
		update_inv_glasse()
		update_inv_l_hand()
		update_inv_r_hand()
		update_inv_belt()
		update_inv_wear_id()
		update_inv_ears()
		update_inv_s_store()
		update_inv_pockets()
		update_inv_back()
		update_inv_handcuffed()
		update_inv_wear_mask()

	All of these are named after the variable they update from. They are defined at the mob/ level like
	update_clothing was, so you won't cause undefined proc runtimes with usr.update_inv_wear_id() if the usr is a
	corgi etc. Instead, it'll just return without doing any work. So no harm in calling it for corgis and such.


>	There are also these special cases:
		update_mutations()	//handles updating your appearance for certain mutations.  e.g TK head-glows
		UpdateDamageIcon()	//handles damage overlays for brute/burn damage //(will rename this when I geta round to it)
		update_body()	//Handles updating your mob's icon to reflect their gender/race/complexion etc
		update_hair()	//Handles updating your hair overlay (used to be update_face, but mouth and
																			...eyes were merged into update_body)

>	If you need to update all overlays you can use regenerate_icons(). it works exactly like update_clothing used to.


*/

#define worn_icon_state_IF_SET(I) I.worn_icon_state ? I.worn_icon_state : I.icon_state

/mob/living/carbon/human
	var/list/underlays_standing[TOTAL_UNDERLAYS]
	var/previous_damage_appearance // store what the body last looked like, so we only have to update it if something changed

/mob/living/carbon/human/apply_overlay(cache_index)
	var/list/to_add = list()
	SEND_SIGNAL(src, COMSIG_HUMAN_APPLY_OVERLAY, cache_index, to_add)
	var/image/I = overlays_standing[cache_index]
	if(I)
		//TODO THIS SHOULD USE THE API! or even better just make it based off of tg
		to_add += I

	if(get_mob_height() == HUMAN_HEIGHT_MEDIUM)
		overlays += to_add
		return

	var/raw_applied = overlays_standing[cache_index]
	var/string_form_index = num2text(cache_index)
	var/offset_type = GLOB.layers_to_offset[string_form_index]
	if(isnull(offset_type))
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_filters(applied_appearance)
		else if(isimage(raw_applied))
			apply_height_filters(raw_applied)
	else
		if(islist(raw_applied))
			for(var/image/applied_appearance in raw_applied)
				apply_height_offsets(applied_appearance, offset_type)
		else if(isimage(raw_applied))
			apply_height_offsets(raw_applied, offset_type)

	overlays += to_add


/**
 * Used in some circumstances where appearances can get cut off from the mob sprite from being too tall
 *
 * upper_torso is to specify whether the appearance is locate in the upper half of the mob rather than the lower half,
 * higher up things (hats for example) need to be offset more due to the location of the filter displacement
 */
/mob/living/carbon/human/proc/apply_height_offsets(image/appearance, upper_torso)
	var/height_to_use = num2text(get_mob_height())
	var/final_offset = 0
	switch(upper_torso)
		if(UPPER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][1]
		if(LOWER_BODY)
			final_offset = GLOB.human_heights_to_offsets[height_to_use][2]
		else
			return

	appearance.pixel_y += final_offset
	return appearance

/**
 * Applies a filter to an appearance according to mob height
 */
/mob/living/carbon/human/proc/apply_height_filters(image/appearance)
	var/static/icon/cut_torso_mask = icon('icons/effects/cut.dmi', "Cut1")
	var/static/icon/cut_legs_mask = icon('icons/effects/cut.dmi', "Cut2")
	var/static/icon/lenghten_torso_mask = icon('icons/effects/cut.dmi', "Cut3")
	var/static/icon/lenghten_legs_mask = icon('icons/effects/cut.dmi', "Cut4")

	appearance.remove_filter(list(
		"Cut_Torso",
		"Cut_Legs",
		"Lenghten_Legs",
		"Lenghten_Torso",
		"Gnome_Cut_Torso",
		"Gnome_Cut_Legs",
		"Monkey_Torso",
		"Monkey_Legs",
		"Monkey_Gnome_Cut_Torso",
		"Monkey_Gnome_Cut_Legs",
	))

	switch(get_mob_height())
		// Don't set this one directly, use TRAIT_DWARF
		if(MONKEY_HEIGHT_DWARF)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Gnome_Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 3),
				),
				list(
					"name" = "Monkey_Gnome_Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		if(MONKEY_HEIGHT_MEDIUM)
			appearance.add_filters(list(
				list(
					"name" = "Monkey_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
				),
				list(
					"name" = "Monkey_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 4),
				),
			))
		if(HUMAN_HEIGHT_DWARF) // tall monkeys and dwarves use the same value
			if(ismonkey(src))
				appearance.add_filters(list(
					list(
						"name" = "Monkey_Torso",
						"priority" = 1,
						"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1),
					),
					list(
						"name" = "Monkey_Legs",
						"priority" = 1,
						"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1),
					),
				))
			else
				appearance.add_filters(list(
					list(
						"name" = "Gnome_Cut_Torso",
						"priority" = 1,
						"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 2),
					),
					list(
						"name" = "Gnome_Cut_Legs",
						"priority" = 1,
						"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 3),
					),
				))
		// Don't set this one directly, use TRAIT_DWARF
		if(HUMAN_HEIGHT_SHORTEST)
			appearance.add_filters(list(
				list(
					"name" = "Cut_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(cut_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Cut_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_SHORT)
			appearance.add_filter("Cut_Legs", 1, displacement_map_filter(cut_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALL)
			appearance.add_filter("Lenghten_Legs", 1, displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1))
		if(HUMAN_HEIGHT_TALLER)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 1),
				),
			))
		if(HUMAN_HEIGHT_TALLEST)
			appearance.add_filters(list(
				list(
					"name" = "Lenghten_Torso",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_torso_mask, x = 0, y = 0, size = 1),
				),
				list(
					"name" = "Lenghten_Legs",
					"priority" = 1,
					"params" = displacement_map_filter(lenghten_legs_mask, x = 0, y = 0, size = 2),
				),
			))

	// Kinda gross but because many humans overlays do not use KEEP_TOGETHER we need to manually propogate the filter
	// Otherwise overlays, such as worn overlays on icons, won't have the filter "applied", and the effect kinda breaks
	if(!(appearance.appearance_flags & KEEP_TOGETHER))
		for(var/image/overlay in list() + appearance.underlays + appearance.overlays)
			apply_height_filters(overlay)

	return appearance

/mob/living/carbon/human/remove_overlay(cache_index)
	var/list/to_remove = list()
	SEND_SIGNAL(src, COMSIG_HUMAN_REMOVE_OVERLAY, cache_index, to_remove)
	if(overlays_standing[cache_index])
		to_remove += overlays_standing[cache_index]
		overlays_standing[cache_index] = null
	overlays -= to_remove

/mob/living/carbon/human/apply_underlay(cache_index)
	var/image/I = underlays_standing[cache_index]
	if(I)
		underlays += I

/mob/living/carbon/human/remove_underlay(cache_index)
	if(underlays_standing[cache_index])
		underlays -= underlays_standing[cache_index]
		underlays_standing[cache_index] = null

GLOBAL_LIST_EMPTY(damage_icon_parts)
///fetches the damage icon part, and caches it if it made a new one
/mob/living/carbon/human/proc/get_damage_icon_part(damage_state, body_part)
	if(GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"])
		return GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"]

	var/brute_state = copytext(damage_state, 1, 2)
	var/burn_state = copytext(damage_state, 2)
	var/icon/brute_state_icon = icon('icons/mob/dam_human.dmi', "[species.brute_damage_icon_state]_[brute_state]")
	var/icon/burn_state_icon = icon('icons/mob/dam_human.dmi', "[species.burn_damage_icon_state]_[burn_state]")
	var/icon/damage_mask_icon = icon(species.damage_mask_icon, body_part)
	var/icon/DI = icon('icons/mob/dam_human.dmi', "00") //starts blank
	if(species.species_flags & GREYSCALE_BLOOD)
		DI.Blend(species.blood_color, ICON_MULTIPLY) 	//coloring with species' blood color
	DI.Blend(brute_state_icon, ICON_OVERLAY)			//add bruises
	DI.Blend(burn_state_icon, ICON_OVERLAY)				//add burns
	DI.Blend(damage_mask_icon, ICON_MULTIPLY)			//mask with this organ's pixels
	GLOB.damage_icon_parts["[damage_state]_[species.blood_color]_[body_part]"] = DI
	return DI

//DAMAGE OVERLAYS
//constructs damage icon for each organ from mask * damage field and saves it in our overlays_ lists
/mob/living/carbon/human/UpdateDamageIcon()
	if(species.species_flags & NO_DAMAGE_OVERLAY)
		return

	// first check whether something actually changed about damage appearance
	var/damage_appearance = ""

	for(var/datum/limb/O in limbs)
		if(O.limb_status & LIMB_DESTROYED)
			damage_appearance += "d"
		else
			damage_appearance += O.damage_state

	if(damage_appearance == previous_damage_appearance)
		// nothing to do here
		return

	remove_overlay(DAMAGE_LAYER)

	previous_damage_appearance = damage_appearance

	var/icon/standing = new('icons/mob/dam_human.dmi', "00")

	var/image/standing_image = image("icon" = standing, "layer" = -DAMAGE_LAYER)

	// blend the individual damage states with our icons
	for(var/o in limbs)
		var/datum/limb/limb_to_update = o
		limb_to_update.update_icon()

		if(limb_to_update.damage_state == "00")
			continue

		var/icon/DI = get_damage_icon_part(limb_to_update.damage_state, limb_to_update.icon_name)

		standing_image.overlays += DI

	overlays_standing[DAMAGE_LAYER] = standing_image

	apply_overlay(DAMAGE_LAYER)

//BASE MOB SPRITE
/mob/living/carbon/human/proc/update_body(update_icons = 1, force_cache_update = 0)
	var/necrosis_color_mod = rgb(10,50,0)

	var/g = get_gender_name(gender)
	var/has_head = 0


	//CACHING: Generate an index key from visible bodyparts.
	//0 = destroyed, 1 = normal, 2 = robotic, 3 = necrotic.

	//Create a new, blank icon for our mob to use.
	if(stand_icon)
		qdel(stand_icon)

	stand_icon = new(species.icon_template ? species.icon_template : 'icons/mob/human.dmi',"blank")

	var/icon_key = "[species.race_key][g][ethnicity]"
	for(var/datum/limb/part in limbs)

		if(istype(part,/datum/limb/head) && !(part.limb_status & LIMB_DESTROYED))
			has_head = 1

		if(part.limb_status & LIMB_DESTROYED)
			icon_key = "[icon_key]0"
		else if(part.limb_status & LIMB_ROBOT)
			icon_key = "[icon_key]2"
		else if(part.limb_status & LIMB_NECROTIZED)
			icon_key = "[icon_key]3"
		else
			icon_key = "[icon_key]1"

	icon_key = "[icon_key][0][0][0][0][ethnicity][get_mob_height()]"

	var/icon/base_icon
	if(!force_cache_update && GLOB.human_icon_cache[icon_key])
		//Icon is cached, use existing icon.
		base_icon = GLOB.human_icon_cache[icon_key]

		//log_debug("Retrieved cached mob icon ([icon_key] \icon[GLOB.human_icon_cache[icon_key]]) for [src].")

	else

	//BEGIN CACHED ICON GENERATION.

		// Why don't we just make skeletons/shadows/golems a species? ~Z
		var/race_icon = species.icobase

		//Robotic limbs are handled in get_icon() so all we worry about are missing or dead limbs.
		//No icon stored, so we need to start with a basic one.
		var/datum/limb/chest = get_limb("chest")
		base_icon = chest.get_icon(race_icon,g)

		if(chest.limb_status & LIMB_NECROTIZED)
			base_icon.ColorTone(necrosis_color_mod)
			base_icon.SetIntensity(0.7)

		for(var/datum/limb/part in limbs)

			var/icon/temp //Hold the bodypart icon for processing.

			if(part.limb_status & LIMB_DESTROYED)
				continue

			if(istype(part, /datum/limb/chest)) //already done above
				continue

			if (istype(part, /datum/limb/groin) || istype(part, /datum/limb/head))
				temp = part.get_icon(race_icon,g)
			else
				temp = part.get_icon(race_icon)

			if(part.limb_status & LIMB_NECROTIZED)
				temp.ColorTone(necrosis_color_mod)
				temp.SetIntensity(0.7)

			//That part makes left and right legs drawn topmost and lowermost when human looks WEST or EAST
			//And no change in rendering for other parts (they icon_position is 0, so goes to 'else' part)
			if(part.icon_position&(LEFT|RIGHT))

				var/icon/temp2 = new('icons/mob/human.dmi',"blank")

				temp2.Insert(new/icon(temp,dir=NORTH),dir=NORTH)
				temp2.Insert(new/icon(temp,dir=SOUTH),dir=SOUTH)

				if(!(part.icon_position & LEFT))
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

				if(!(part.icon_position & RIGHT))
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

				base_icon.Blend(temp2, ICON_OVERLAY)

				if(part.icon_position & LEFT)
					temp2.Insert(new/icon(temp,dir=EAST),dir=EAST)

				if(part.icon_position & RIGHT)
					temp2.Insert(new/icon(temp,dir=WEST),dir=WEST)

				base_icon.Blend(temp2, ICON_UNDERLAY)

			else

				base_icon.Blend(temp, ICON_OVERLAY)

		GLOB.human_icon_cache[icon_key] = base_icon

		//log_debug("Generated new cached mob icon ([icon_key] \icon[GLOB.human_icon_cache[icon_key]]) for [src]. [length(GLOB.human_icon_cache)] cached mob icons.")

	//END CACHED ICON GENERATION.

	stand_icon.Blend(base_icon,ICON_OVERLAY)

	if(has_head)
		//Eyes
		var/icon/eyes = new/icon('icons/mob/human_face.dmi', species.eyes)
		eyes.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
		stand_icon.Blend(eyes, ICON_OVERLAY)

		//Mouth	(lipstick!)
		if(makeup_style && (species?.species_flags & HAS_LIPS))	//skeletons are allowed to wear lipstick no matter what you think, agouri.
			stand_icon.Blend(new/icon('icons/mob/human_face.dmi', "camo_[makeup_style]_s"), ICON_OVERLAY)


	if(species.species_flags & HAS_UNDERWEAR)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear_[underwear]_[gender]"), ICON_OVERLAY)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "undershirt_[undershirt]_[gender]"), ICON_OVERLAY)

	update_bodyparts()
	species?.update_body(src)

//HAIR OVERLAY
/mob/living/carbon/human/proc/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	if(species.species_flags & HAS_NO_HAIR)
		return

	var/datum/limb/head/head_organ = get_limb("head")
	if(!head_organ || (head_organ.limb_status & LIMB_DESTROYED) )
		return

	//masks and helmets can obscure our hair.
	if((head?.inv_hide_flags & HIDEALLHAIR) || (wear_mask?.inv_hide_flags & HIDEALLHAIR))
		return

	//base icons
	var/icon/face_standing = new /icon('icons/mob/human_face.dmi',"bald_s")

	if(f_style && !(wear_suit?.inv_hide_flags & HIDELOWHAIR) && !(wear_mask?.inv_hide_flags & HIDELOWHAIR))
		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[f_style]
		if(facial_hair_style?.species_allowed && (species.name in facial_hair_style.species_allowed))
			var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
			if(facial_hair_style.do_colouration)
				if(facial_hair_style.greyscale_config)
					facial_s = SSgreyscale.GetColoredIconByType(facial_hair_style.greyscale_config, rgb(r_facial, g_facial, b_facial) )
				else
					facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

			face_standing.Blend(facial_s, ICON_OVERLAY)

	if(h_style && !(head?.inv_hide_flags & HIDETOPHAIR))
		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_list[h_style]
		if(hair_style && (species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
			if(hair_style.do_colouration)
				var/icon/grad_s
				if(grad_style && grad_style != "None")
					var/datum/sprite_accessory/gradient = GLOB.hair_gradients_list[grad_style]
					grad_s = new/icon("icon" = gradient.icon, "icon_state" = gradient.icon_state)
					grad_s.Blend(hair_s, ICON_ADD)
					grad_s.Blend(rgb(r_grad, g_grad, b_grad), ICON_ADD)
				hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
				if(!isnull(grad_s))
					hair_s.Blend(grad_s, ICON_OVERLAY)

			face_standing.Blend(hair_s, ICON_OVERLAY)

	var/mutable_appearance/hair_final = mutable_appearance(face_standing, layer =-HAIR_LAYER)

	if(head?.inv_hide_flags & HIDE_EXCESS_HAIR)
		var/image/mask = image('icons/mob/human_face.dmi', null, "Jeager_Mask")
		mask.render_target = "*jaegFACE[REF(src)]"
		hair_final.overlays += mask
		hair_final.filters += filter(arglist(alpha_mask_filter(0, 0, null, "*jaegFACE[REF(src)]")))

	overlays_standing[HAIR_LAYER] = hair_final
	apply_overlay(HAIR_LAYER)

/* --------------------------------------- */
//For legacy support.
/mob/living/carbon/human/regenerate_icons()
	update_bodyparts()
	update_inv_w_uniform()
	update_inv_wear_id()
	update_inv_gloves()
	update_inv_glasses()
	update_inv_ears()
	update_inv_shoes()
	update_inv_s_store()
	update_inv_wear_mask()
	update_inv_head()
	update_inv_belt()
	update_inv_back()
	update_inv_wear_suit()
	update_inv_r_hand()
	update_inv_l_hand()
	update_inv_handcuffed()
	update_inv_pockets()
	update_fire()
	update_burst()
	UpdateDamageIcon()
	update_transform()

/* --------------------------------------- */
//vvvvvv UPDATE_INV PROCS vvvvvv

///snowflake replacement handling since we don't have tg's proper handling of individual body parts as overlays
/mob/living/carbon/human/proc/update_bodyparts()
	remove_overlay(BODYPARTS_LAYER)
	overlays_standing[BODYPARTS_LAYER] = image(icon=stand_icon, layer=-BODYPARTS_LAYER)
	apply_overlay(BODYPARTS_LAYER)

/mob/living/carbon/human/update_inv_w_uniform()
	remove_overlay(UNIFORM_LAYER)
	if(!w_uniform)
		return
	if(client && hud_used?.hud_shown && hud_used.inventory_shown)
		w_uniform.screen_loc = ui_iclothing
		client.screen += w_uniform

	if(wear_suit?.inv_hide_flags & HIDEJUMPSUIT)
		return

	overlays_standing[UNIFORM_LAYER] = w_uniform.make_worn_icon(species.name, slot_w_uniform_str, default_icon = 'icons/mob/clothing/uniforms/uniform_0.dmi', default_layer = UNIFORM_LAYER)

	apply_overlay(UNIFORM_LAYER)
	species?.update_inv_w_uniform(src)

/mob/living/carbon/human/update_inv_wear_id()
	remove_overlay(ID_LAYER)
	if(!wear_id)
		return

	if(client && hud_used?.hud_shown)
		wear_id.screen_loc = ui_id
		client.screen += wear_id

	if(w_uniform?.displays_id || istype(wear_id, /obj/item/card/id/dogtag))
		overlays_standing[ID_LAYER] = wear_id.make_worn_icon(species.name, slot_wear_id_str, default_icon = 'icons/mob/mob.dmi', default_layer = ID_LAYER)

	apply_overlay(ID_LAYER)

/mob/living/carbon/human/update_inv_gloves()
	remove_overlay(GLOVES_LAYER)
	if(gloves)
		if(client && hud_used?.hud_shown && hud_used.inventory_shown)
			gloves.screen_loc = ui_gloves
			client.screen += gloves
		overlays_standing[GLOVES_LAYER] = gloves.make_worn_icon(species.name, slot_gloves_str, default_icon = 'icons/mob/clothing/hands.dmi', default_layer = GLOVES_LAYER)
		apply_overlay(GLOVES_LAYER)
		return

	if(!blood_color || !bloody_hands)
		return
	var/datum/limb/left_hand = get_limb("l_hand")
	var/datum/limb/right_hand = get_limb("r_hand")
	var/mutable_appearance/bloodsies
	if(left_hand.limb_status & LIMB_DESTROYED)
		if(right_hand.limb_status & LIMB_DESTROYED)
			return //No hands.
		bloodsies = mutable_appearance('icons/effects/blood.dmi', "bloodyhand_right") //Only right hand.
	else if(right_hand.limb_status & LIMB_DESTROYED)
		bloodsies = mutable_appearance('icons/effects/blood.dmi', "bloodyhand_left") //Only left hand.
	else
		bloodsies = mutable_appearance('icons/effects/blood.dmi', "bloodyhands") //Both hands.

	bloodsies.color = blood_color
	overlays_standing[GLOVES_LAYER] = bloodsies
	apply_overlay(GLOVES_LAYER)

/mob/living/carbon/human/update_inv_glasses()
	remove_overlay(GLASSES_LAYER)
	remove_overlay(GOGGLES_LAYER)
	if(!glasses)
		return
	if(client &&  hud_used?.hud_shown && hud_used.inventory_shown)
		glasses.screen_loc = ui_glasses
		client.screen += glasses

	var/glasses_layer = GLASSES_LAYER
	if(glasses.goggles_layer)
		glasses_layer = GOGGLES_LAYER

	overlays_standing[glasses_layer] = glasses.make_worn_icon(species.name, slot_glasses_str, default_icon = 'icons/mob/clothing/eyes.dmi', default_layer = glasses_layer)
	apply_overlay(glasses_layer)

/mob/living/carbon/human/update_inv_ears()
	remove_overlay(EARS_LAYER)
	if(!wear_ear)
		return

	if(client && hud_used?.hud_shown && hud_used.inventory_shown)
		wear_ear.screen_loc = ui_wear_ear
		client.screen += wear_ear
	if((head?.inv_hide_flags & HIDEEARS) || (wear_mask?.inv_hide_flags & HIDEEARS))
		return

	overlays_standing[EARS_LAYER] = wear_ear.make_worn_icon(species.name, slot_ear_str, default_icon = 'icons/mob/clothing/ears.dmi', default_layer = EARS_LAYER)
	apply_overlay(EARS_LAYER)

/mob/living/carbon/human/update_inv_shoes()
	remove_overlay(SHOES_LAYER)
	if(shoes)
		if(client && hud_used?.hud_shown && hud_used.inventory_shown)
			shoes.screen_loc = ui_shoes
			client.screen += shoes
	if(wear_suit?.inv_hide_flags & HIDESHOES)
		return

	if(shoes)
		overlays_standing[SHOES_LAYER] = shoes.make_worn_icon(species.name, slot_shoes_str, default_icon = 'icons/mob/clothing/feet.dmi', default_layer = SHOES_LAYER)
	else if(feet_blood_color)
		var/mutable_appearance/bloodsies = mutable_appearance(icon = 'icons/effects/blood.dmi', icon_state = "shoeblood")
		bloodsies.color = feet_blood_color
		overlays_standing[SHOES_LAYER] = bloodsies

	apply_overlay(SHOES_LAYER)

/mob/living/carbon/human/update_inv_s_store()
	remove_overlay(SUIT_STORE_LAYER)
	if(!s_store)
		return

	if(client && hud_used?.hud_shown)
		s_store.screen_loc = ui_sstore1
		client.screen += s_store

	overlays_standing[SUIT_STORE_LAYER] = s_store.make_worn_icon(species.name, slot_s_store_str, default_icon = 'icons/mob/suit_slot.dmi', default_layer = SUIT_STORE_LAYER)
	apply_overlay(SUIT_STORE_LAYER)

/mob/living/carbon/human/update_inv_head()
	remove_overlay(HEAD_LAYER)
	if(!head)
		return

	if(client && hud_used?.hud_shown && hud_used.inventory_shown)
		head.screen_loc = ui_head
		client.screen += head

	overlays_standing[HEAD_LAYER] = head.make_worn_icon(species.name, slot_head_str, default_icon = 'icons/mob/clothing/headwear/head_0.dmi', default_layer = HEAD_LAYER)

	apply_overlay(HEAD_LAYER)
	species?.update_inv_head(src)

/mob/living/carbon/human/update_inv_belt()
	remove_overlay(BELT_LAYER)
	if(!belt)
		return

	if(client && hud_used?.hud_shown)
		belt.screen_loc = ui_belt
		client.screen += belt

	overlays_standing[BELT_LAYER] = belt.make_worn_icon(species.name, slot_belt_str, default_icon = 'icons/mob/clothing/belt.dmi', default_layer = BELT_LAYER)

	apply_overlay(BELT_LAYER)

/mob/living/carbon/human/update_inv_wear_suit()
	remove_overlay(SUIT_LAYER)
	species?.update_inv_wear_suit(src)
	if(!wear_suit)
		return

	if(client && hud_used?.hud_shown && hud_used.inventory_shown)
		wear_suit.screen_loc = ui_oclothing
		client.screen += wear_suit

	overlays_standing[SUIT_LAYER] = wear_suit.make_worn_icon(species.name, slot_wear_suit_str, default_icon = 'icons/mob/clothing/suits/suit_0.dmi', default_layer = SUIT_LAYER)

	apply_overlay(SUIT_LAYER)

/mob/living/carbon/human/update_inv_pockets()
	if(l_store)
		if(client && hud_used?.hud_shown)
			l_store.screen_loc = ui_storage1
			client.screen += l_store
	if(r_store)
		if(client && hud_used?.hud_shown)
			r_store.screen_loc = ui_storage2
			client.screen += r_store

/mob/living/carbon/human/update_inv_wear_mask()
	remove_overlay(FACEMASK_LAYER)
	if(!wear_mask)
		return

	if(head?.inv_hide_flags & HIDEMASK)
		return

	if(client && hud_used?.hud_shown && hud_used.inventory_shown)
		wear_mask.screen_loc = ui_mask
		client.screen += wear_mask

	overlays_standing[FACEMASK_LAYER] = wear_mask.make_worn_icon(species.name, slot_wear_mask_str, default_icon = 'icons/mob/clothing/mask.dmi', default_layer = FACEMASK_LAYER)

	apply_overlay(FACEMASK_LAYER)

/mob/living/carbon/human/update_inv_back()
	remove_overlay(BACK_LAYER)
	if(!back)
		return
	if(client && hud_used?.hud_shown)
		back.screen_loc = ui_back
		client.screen += back

	overlays_standing[BACK_LAYER] = back.make_worn_icon(species.name, slot_back_str, default_icon = 'icons/mob/clothing/back.dmi', default_layer = BACK_LAYER)

	apply_overlay(BACK_LAYER)

/mob/living/carbon/human/update_inv_handcuffed()
	remove_overlay(HANDCUFF_LAYER)
	if(!handcuffed)
		return
	overlays_standing[HANDCUFF_LAYER] = handcuffed.make_worn_icon(species.name, slot_handcuffed_str, default_icon = 'icons/mob/mob.dmi', default_layer = HANDCUFF_LAYER)
	apply_overlay(HANDCUFF_LAYER)

/mob/living/carbon/human/update_inv_r_hand()
	remove_overlay(R_HAND_LAYER)
	if(!r_hand)
		return
	if(client && hud_used?.hud_version != HUD_STYLE_NOHUD)
		client.screen += r_hand
		r_hand.screen_loc = ui_rhand

	overlays_standing[R_HAND_LAYER] = r_hand.make_worn_icon(species.name, slot_r_hand_str, TRUE, 'icons/mob/inhands/items_righthand_1.dmi', R_HAND_LAYER)

	apply_overlay(R_HAND_LAYER)

/mob/living/carbon/human/update_inv_l_hand()
	remove_overlay(L_HAND_LAYER)
	if(!l_hand)
		return

	if(client && hud_used?.hud_version != HUD_STYLE_NOHUD)
		client.screen += l_hand
		l_hand.screen_loc = ui_lhand

	overlays_standing[L_HAND_LAYER] = l_hand.make_worn_icon(species.name, slot_l_hand_str, TRUE, 'icons/mob/inhands/items_lefthand_1.dmi', L_HAND_LAYER)
	apply_overlay(L_HAND_LAYER)


/mob/living/carbon/human/update_burst()
	remove_overlay(BURST_LAYER)
	if(!chestburst)
		return
	overlays_standing[BURST_LAYER] = mutable_appearance('icons/Xeno/Effects.dmi', chestburst == CARBON_IS_CHEST_BURSTING ? "burst_stand" : "bursted_stand", -BURST_LAYER)
	apply_overlay(BURST_LAYER)

/mob/living/carbon/human/update_fire()
	remove_overlay(FIRE_LAYER)
	if(!on_fire)
		return
	overlays_standing[FIRE_LAYER] = mutable_appearance('icons/mob/OnFire.dmi', fire_stacks < 15 ? "Standing_weak" : "Standing_medium", -FIRE_LAYER)
	apply_overlay(FIRE_LAYER)

//HAIR OVERLAY
/mob/living/carbon/human/species/yautja/update_hair()
	//Reset our hair
	remove_overlay(HAIR_LAYER)

	if(species.species_flags & HAS_NO_HAIR)
		return

	var/datum/limb/head/head_organ = get_limb("head")
	if(!head_organ || (head_organ.limb_status & LIMB_DESTROYED) )
		return

	//masks and helmets can obscure our hair.
	if((head?.inv_hide_flags & HIDEALLHAIR) || (wear_mask?.inv_hide_flags & HIDEALLHAIR))
		return

	//base icons
	var/icon/face_standing = new /icon('icons/mob/human_face.dmi',"bald_s")

	if(h_style && !(head?.inv_hide_flags & HIDETOPHAIR))
		var/datum/sprite_accessory/hair_style = GLOB.yautja_hair_styles_list[h_style]
		if(hair_style && (species.name in hair_style.species_allowed))
			var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")

			face_standing.Blend(hair_s, ICON_OVERLAY)

	var/mutable_appearance/hair_final = mutable_appearance(face_standing, layer =-HAIR_LAYER)

	if(head?.inv_hide_flags & HIDE_EXCESS_HAIR)
		var/image/mask = image('icons/mob/human_face.dmi', null, "Jeager_Mask")
		mask.render_target = "*[REF(src)]"
		hair_final.overlays += mask
		hair_final.filters += filter(arglist(alpha_mask_filter(0, 0, null, "*[REF(src)]")))

	overlays_standing[HAIR_LAYER] = hair_final
	apply_overlay(HAIR_LAYER)

/mob/living/carbon/human/proc/add_flay_overlay(stage = 1)
	remove_overlay(FLAY_LAYER)
	var/image/flay_icon = new /image('icons/mob/hunter/dam_human.dmi', "human_[stage]")
	flay_icon.layer = -FLAY_LAYER
	flay_icon.blend_mode = BLEND_INSET_OVERLAY
	overlays_standing[FLAY_LAYER] = flay_icon
	apply_overlay(FLAY_LAYER)
