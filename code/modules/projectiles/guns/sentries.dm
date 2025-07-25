/obj/item/weapon/gun/sentry
	name = "sentry"
	desc = "sentry"
	icon = 'icons/obj/sentry.dmi'

	worn_icon_list = list(
		slot_l_hand_str = 'icons/mob/inhands/items_lefthand_1.dmi',
		slot_r_hand_str = 'icons/mob/inhands/items_righthand_1.dmi',
	)

	fire_sound = 'sound/weapons/guns/fire/smg_heavy.ogg'
	reload_sound = 'sound/weapons/guns/interact/smartgun_unload.ogg'

	max_integrity = 200
	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 80, ACID = 50)

	fire_delay = 0.6 SECONDS
	extra_delay = 0.6 SECONDS
	burst_delay = 0.3 SECONDS
	scatter = 20
	scatter_unwielded = 0
	burst_scatter_mult = 0
	burst_amount = 4
	turret_flags = TURRET_HAS_CAMERA|TURRET_SAFETY|TURRET_ALERTS
	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_IFF|GUN_SMOKE_PARTICLES
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	deployable_item = /obj/machinery/deployable/mounted/sentry
	item_flags = IS_DEPLOYABLE|TWOHANDED|IS_SENTRY
	deploy_time = 5 SECONDS

	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

/obj/item/weapon/gun/sentry/update_worn_icon_state()
	return

// *******************************
// ********* UPGRADE KIT *********
// *******************************

/obj/item/weapon/gun/sentry/basic/proc/get_upgrade_list()
	. += list(
		"Sniper Upgrade" = image(icon = 'icons/mob/radial.dmi', icon_state = "sniper_icon"),
		"Shotgun Upgrade" = image(icon = 'icons/mob/radial.dmi', icon_state = "shotgun_icon"),
		"Mini Upgrade" = image(icon = 'icons/mob/radial.dmi', icon_state = "mini_icon"),
		"Flamer Upgrade"  = image(icon = 'icons/mob/radial.dmi', icon_state = "flamer_icon"),
	)

/obj/item/weapon/gun/sentry/basic/proc/upgrade_string_to_type(upgrade_string)
	switch(upgrade_string)
		if("Sniper Upgrade")
			return /obj/item/weapon/gun/sentry/sniper
		if("Shotgun Upgrade")
			return /obj/item/weapon/gun/sentry/shotgun
		if("Mini Upgrade")
			return /obj/item/weapon/gun/sentry/mini
		if("Flamer Upgrade")
			return /obj/item/weapon/gun/sentry/flamer

/obj/item/sentry_upgrade_kit
	name = "Набор улучшения TUR-B"
	desc = "Набор инструментов, используемый для улучшения базовой модели турелей."

	icon = 'icons/obj/sentry.dmi'
	icon_state = "upgradekit"

/obj/item/sentry_upgrade_kit/afterattack(atom/target, mob/user, proximity_flag, click_parameters, proximity)
	if(!ishuman(user))
		return ..()

	if(!istype(target, /obj/item/weapon/gun/sentry/basic))
		return ..()

	var/obj/item/weapon/gun/sentry/basic/sentry = target
	var/mob/living/carbon/human/human = user

	var/list/upgrade_list = sentry.get_upgrade_list()
	if(!length(upgrade_list))
		return

	var/chosen_upgrade = show_radial_menu(user, target, upgrade_list, require_near = TRUE)
	if(QDELETED(sentry) || !upgrade_list[chosen_upgrade])
		return

	if((user.get_active_held_item()) != src)
		to_chat(user, span_warning("You must be holding [src] to upgrade [sentry]!"))
		return

	var/type_to_change_to = sentry.upgrade_string_to_type(chosen_upgrade)
	if(!type_to_change_to)
		return

	playsound(user, 'sound/misc/electronics_1.ogg', 50)
	icon_state = "upgradekit_open"
	if(!do_after(user, 4 SECONDS, NONE, src, BUSY_ICON_ENERGY, prog_bar = null))
		icon_state = initial(icon_state)
		return

	human.dropItemToGround(sentry)
	qdel(sentry)

	sentry = new type_to_change_to()
	human.put_in_any_hand_if_possible(sentry)

	if(sentry.loc != human)
		sentry.forceMove(human.loc)

	human.drop_held_item()
	qdel(src)

/obj/item/weapon/gun/sentry/basic
	name = "\improper Турель TUR-B \"Базис\""
	desc = "Развёртываемая автоматическая турель, имеет встроенный ИИ. Не имеет каких-либо модификаций. Ведёт эффективный и точный огонь."
	icon_state = "sentry"
	worn_icon_state = "sentry"

	turret_range = 8
	deploy_time = 5 SECONDS
	max_shells = 500
	fire_delay = 0.25 SECONDS

	scatter = 2

	ammo_datum_type = /datum/ammo/bullet/turret
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg102,
	)

/obj/item/weapon/gun/sentry/pod_sentry
	name = "\improper Турель TUR-B \"Базис\""
	desc = "Развёртываемая автоматическая турель со встроенным ИИ. Не имеет каких-либо модификаций. Ведёт эффективный и точный огонь."
	icon_state = "podsentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	sentry_iff_signal = TGMC_LOYALIST_IFF
	turret_range = 10
	knockdown_threshold = 500
	max_shells = 500
	fire_delay = 0.15 SECONDS
	burst_amount = 1
	scatter = 12
	ammo_datum_type = /datum/ammo/bullet/turret
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

//thrown SOM sentry
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope
	name = "\improper Турель COPE"
	desc = "The Centurion Omnidirectional Point-defense Energy sentry is a man portable, automated weapon system utilised by the SOM. It is activated in hand then thrown into place before it deploys, where it's ground hugging profile makes it a difficult target to accurately hit. Equipped with a compact volkite weapon system, and a recharging battery to allow for prolonged use, but can take normal volkite cells in a pinch."
	icon_state = "cope"
	icon = 'icons/obj/sentry.dmi'
	max_integrity = 225
	integrity_failure = 50
	deploy_time = 1 SECONDS
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	deployable_item = /obj/machinery/deployable/mounted/sentry/cope
	turret_range = 9
	w_class = WEIGHT_CLASS_NORMAL //same as other sentries
	sentry_iff_signal = SOM_IFF

	soft_armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, FIRE = 80, ACID = 50)

	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_AMMO_COUNT_BY_SHOTS_REMAINING|GUN_ENERGY|GUN_SMOKE_PARTICLES
	reciever_flags = AMMO_RECIEVER_MAGAZINES|AMMO_RECIEVER_DO_NOT_EJECT_HANDFULS|AMMO_RECIEVER_CYCLE_ONLY_BEFORE_FIRE //doesn't autoeject its recharging battery
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	item_flags = IS_DEPLOYABLE|TWOHANDED

	max_shots = 150
	rounds_per_shot = 12
	fire_delay = 0.2 SECONDS
	scatter = -3
	damage_falloff_mult = 0.5
	ammo_datum_type = /datum/ammo/energy/volkite/light
	default_ammo_type = /obj/item/cell/lasgun/volkite/turret
	allowed_ammo_types = list(/obj/item/cell/lasgun/volkite/turret, /obj/item/cell/lasgun/volkite)

	///How long to deploy after thrown
	var/det_time = 4 SECONDS
	///The sound made when activated
	var/arm_sound = 'sound/weapons/armbomb.ogg'

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/attack_self(mob/user)
	if(active)
		return

	if(!user.dextrous)
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return

	activate(user)

	user.visible_message(span_warning("[user] primes \a [name]!"), \
	span_warning("You prime \a [name]!"))

	if(iscarbon(user))
		var/mob/living/carbon/C = user
		C.throw_mode_on()

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/activate(mob/user)
	if(active)
		return

	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 25, 1, 6)
	var/obj/item/card/id/user_id = user?.get_idcard(TRUE)
	if(user_id)
		sentry_iff_signal = user_id?.iff_signal
	addtimer(CALLBACK(src, PROC_REF(prime), user), det_time)

///Reverts the gun back to it's unarmed state, allowing it to be activated again
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/proc/reset()
	active = FALSE
	icon_state = initial(icon_state)

///Deploys the weapon into a sentry after activation
/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/proc/prime(mob/user)
	if(!isturf(loc)) //no deploying out of bags or in hand
		reset()
		return
	do_deploy(user)

/obj/item/weapon/gun/energy/lasgun/lasrifle/volkite/cope/predeployed
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/weapon/gun/sentry/basic/premade
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/basic/premade/radial
	turret_range = 9
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS|TURRET_RADIAL
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP

/obj/item/weapon/gun/sentry/basic/dropship
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	var/obj/structure/dropship_equipment/shuttle/sentry_holder/deployment_system
	turret_flags = TURRET_HAS_CAMERA|TURRET_IMMOBILE
	density = FALSE

/obj/item/weapon/gun/sentry/basic/fob_sentry
	max_integrity = INFINITY //Good luck killing it
	fire_delay = 0.2 SECONDS
	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	sentry_iff_signal = TGMC_LOYALIST_IFF
	item_flags = IS_DEPLOYABLE|DEPLOY_ON_INITIALIZE|DEPLOYED_NO_PICKUP
	turret_flags = TURRET_IMMOBILE|TURRET_RADIAL|TURRET_LOCKED|TURRET_ON
	default_ammo_type = /obj/item/ammo_magazine/sentry/fob_sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/fob_sentry)

/obj/item/weapon/gun/sentry/mini
	name = "\improper Турель TUR-M \"Гном\""
	desc = "Развёртываемая автоматическая турель, имеет встроенный ИИ. Установлена модификация с уменьшением габаритов и калибра, крайне лёгок в установке."
	icon_state = "minisentry"
	worn_icon_state = "sentry"

	fire_sound = 'sound/items/turrets/turret_smg.ogg'

	max_shells = 300
	knockdown_threshold = 80

	ammo_datum_type = /datum/ammo/bullet/turret/mini
	default_ammo_type = /obj/item/ammo_magazine/minisentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/minisentry)

	fire_delay = 0.15 SECONDS
	burst_delay = 0.1 SECONDS
	burst_amount = 3
	extra_delay = 0.5 SECONDS
	scatter = 4

	deploy_time = 3 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)

/obj/item/weapon/gun/sentry/mini/combat_patrol
	sentry_iff_signal = TGMC_LOYALIST_IFF
	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS

/obj/item/weapon/gun/sentry/premade
	name = "SG-577 Gauss Turret"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an armor penetrating MIC Gauss Cannon and a high-capacity drum magazine."
	icon_state = "sentry"
	turret_flags = TURRET_HAS_CAMERA|TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL
	max_shells = 100

	ammo_datum_type = /datum/ammo/bullet/turret/gauss
	default_ammo_type = /obj/item/ammo_magazine/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC, GUN_FIREMODE_AUTOBURST)
	item_flags = IS_DEPLOYABLE|TWOHANDED|DEPLOYED_NO_PICKUP|DEPLOY_ON_INITIALIZE

/obj/item/weapon/gun/sentry/premade/dumb
	name = "\improper Modified ST-571 sentry gun"
	desc = "A deployable, semi-automated turret with AI targeting capabilities. Armed with an M30 Autocannon and a 500-round drum magazine. This one's IFF system has been disabled, and it will open fire on any targets within range."
	gun_features_flags = GUN_AMMO_COUNTER|GUN_DEPLOYED_FIRE_ONLY|GUN_WIELDED_FIRING_ONLY|GUN_SMOKE_PARTICLES
	ammo_datum_type = /datum/ammo/bullet/turret/dumb
	default_ammo_type = /obj/item/ammo_magazine/sentry_premade/dumb
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry_premade/dumb)
	max_shells = 500
	turret_flags = TURRET_ON|TURRET_IMMOBILE|TURRET_SAFETY|TURRET_RADIAL

/obj/item/weapon/gun/sentry/premade/dumb/hostile
	name = "malfunctioning ST-571 sentry gun"
	desc = "Oh god oh fuck."
	turret_flags = TURRET_LOCKED|TURRET_ON|TURRET_IMMOBILE|TURRET_RADIAL
	sentry_iff_signal = NONE

/obj/item/weapon/gun/sentry/premade/canterbury
	name = "SG-577 Gauss Dropship Turret"
	ammo_datum_type = /datum/ammo/bullet/turret
	sentry_iff_signal = TGMC_LOYALIST_IFF

// Sniper Sentry

/obj/item/weapon/gun/sentry/sniper
	name = "\improper Турель TUR-SN \"Оса\""
	desc = "Развёртываемая автоматическая турель, имеет встроенный ИИ. Установлена модификация для ведения огня большим калибром на дальние дистанции."
	icon_state = "sentry_sniper"
	worn_icon_state = "sentry"

	fire_sound = 'sound/items/turrets/turret_sniper.ogg'

	turret_range = 14
	deploy_time = 5 SECONDS
	max_shells = 75
	fire_delay = 2 SECONDS

	extra_delay = 6 SECONDS
	burst_amount = 2

	scatter = 0

	ammo_datum_type = /datum/ammo/bullet/turret/sniper
	default_ammo_type = /obj/item/ammo_magazine/sentry/sniper
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/sniper)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/invisible)
	starting_attachment_types = list(/obj/item/attachable/scope/unremovable/invisible,)

// Shotgun Sentry

/obj/item/weapon/gun/sentry/shotgun
	name = "\improper Турель TUR-SH \"Бык\""
	desc = "Развёртываемая автоматическая турель, имеет встроенный ИИ. Установлена модификация для ведения массивного огня на ближние дистанции."
	icon_state = "sentry_shotgun"
	worn_icon_state = "sentry"

	fire_sound = 'sound/items/turrets/turret_shotgun.ogg'

	turret_range = 5
	deploy_time = 5 SECONDS
	max_shells = 75
	fire_delay = 1 SECONDS

	extra_delay = 4 SECONDS
	burst_amount = 2

	scatter = 5

	ammo_datum_type = /datum/ammo/bullet/turret/buckshot
	default_ammo_type = /obj/item/ammo_magazine/sentry/shotgun
	allowed_ammo_types = list(/obj/item/ammo_magazine/sentry/shotgun)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)

	attachable_allowed = list(/obj/item/attachable/scope/unremovable/hsg102)
	starting_attachment_types = list(
		/obj/item/attachable/scope/unremovable/hsg102,
	)


// Flamer Sentry

/obj/item/weapon/gun/sentry/flamer
	name = "\improper Турель TUR-F \"Феникс\""
	desc = "Развёртываемая автоматическая турель, имеет встроенный ИИ. Установлена модификация для ведения огня подожёнными сгустками горючего."
	icon_state = "sentry_flamer"
	worn_icon_state = "sentry"

	fire_sound = 'sound/weapons/guns/fire/flamethrower3.ogg'

	turret_flags = TURRET_HAS_CAMERA|TURRET_ALERTS
	turret_range = 8
	deploy_time = 5 SECONDS
	max_shells = 100
	fire_delay = 3 SECONDS

	burst_amount = 3
	extra_delay = 10 SECONDS

	scatter = 1

	ammo_datum_type = /datum/ammo/flamethrower/turret
	default_ammo_type = /obj/item/ammo_magazine/flamer_tank/large/sentry
	allowed_ammo_types = list(/obj/item/ammo_magazine/flamer_tank/large/sentry)

	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
