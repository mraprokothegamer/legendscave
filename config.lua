Config = {}

Config.Debug = false

Config.UI = {
    NetworkName = 'BLACKNET // 7',
    Status = 'SECURE',
    MarketState = 'ONLINE',
    Currency = 'CASH',
    DeliveryMode = 'RANDOM DEAD DROP'
}

-- =========================================================
-- BLACK MARKET PHONE
-- =========================================================

-- Existing Rockstar public phone-box props.
-- The resource DOES NOT spawn these.
Config.PhoneBoxProps = {
    `prop_phonebox_01`,
    `prop_phonebox_01a`,
    `prop_phonebox_01b`,
    `prop_phonebox_02`,
    `prop_phonebox_03`,
    `prop_phonebox_04`
}

-- Distance used by ox_target for existing public phones.
Config.PhoneTargetDistance = 1.8

-- Cash required to make the Black Market call.
Config.CallPrice = 200000
Config.CallMoneyType = 'cash'

-- Physical card issued after a successful call.
Config.AccessItem = 'card_access_pack'

-- =========================================================
-- DEALER
-- =========================================================

Config.DealerCoords = vector4(602.55, -441.88, 23.74, 359.02)
Config.DealerModel = `g_m_m_armboss_01`
Config.DealerTargetDistance = 2.0

-- =========================================================
-- DELIVERY
-- =========================================================

-- Existing Rockstar mailbox/postbox props.
-- The resource DOES NOT spawn these.
Config.MailboxProps = {
    `prop_mailbox_01`,
    `prop_mailbox_02`,
    `prop_mailbox_03`,
    `prop_postbox_01a`,
    `prop_postbox_ss_01`,
    `prop_postbox_ss_02`
}

-- The script scans the world for existing props.
-- Increase this if your map streams props farther away.
Config.MailboxInteractionDistance = 2.0

-- Any of these Rockstar mailbox/postbox models can be used.
-- The resource does NOT spawn or move mailboxes.

-- =========================================================
-- POLICE
-- =========================================================

Config.AlertChance = 25

-- =========================================================
-- PURCHASE
-- =========================================================

-- One package at a time.
Config.MaxCartLines = 50
Config.MaxQuantityPerItem = 50
Config.ServerCollectionDistance = 5.0
Config.OneActiveDelivery = true

-- ox_inventory item image location used by the Black Market UI.
Config.InventoryImagePath = 'nui://ox_inventory/web/images/'

-- Optional cooldown between completed/expired purchases.
-- Set to 0 for no additional cooldown.
Config.Cooldown = 300

-- =========================================================
-- ITEMS
-- =========================================================

Config.Items = {
    {
        label = 'Hatchet',
        item = 'WEAPON_HATCHET',
        price = 24000,
        desc = 'Compact chopping tool.',
        category = 'Weapons'
    },
    {
        label = 'Crowbar',
        item = 'WEAPON_CROWBAR',
        price = 1800,
        desc = 'Heavy-duty forced-entry tool.',
        category = 'Weapons'
    },
    {
        label = 'C4 Charge',
        item = 'c4',
        price = 7500,
        desc = 'Highly illegal explosive charge.',
        category = 'Weapons'
    },
    {
        label = 'Body Armour',
        item = 'armour',
        price = 5000,
        desc = 'Protective ballistic armour.',
        category = 'Weapons'
    },
    {
        label = 'Heavy Suppressor',
        item = 'at_suppressor_heavy',
        price = 32000,
        desc = 'Heavy-duty weapon suppressor attachment.',
        category = 'Weapons'
    },
    {
        label = 'Extended Rifle Clip',
        item = 'at_clip_extended_rifle',
        price = 27500,
        desc = 'Extended rifle magazine attachment.',
        category = 'Weapons'
    },

    {
        label = 'Drill',
        item = 'drill',
        price = 8500,
        desc = 'Portable drilling equipment.',
        category = 'Tools'
    },
    {
        label = 'Lockpick',
        item = 'lockpick',
        price = 3500,
        desc = 'Basic lock bypass tool.',
        category = 'Tools'
    },
    {
        label = 'Advanced Lockpick',
        item = 'advancedlockpick',
        price = 8500,
        desc = 'Professional lock bypass equipment.',
        category = 'Tools'
    },
    {
        label = 'Thermite',
        item = 'thermite',
        price = 1500,
        desc = 'Industrial cutting compound.',
        category = 'Tools'
    },
    {
        label = 'Torque Wrench',
        item = 'torque_wrench',
        price = 7500,
        desc = 'Specialised mechanical tool.',
        category = 'Tools'
    },
    {
        label = 'Electronic Kit',
        item = 'electronickit',
        price = 9000,
        desc = 'Electronic bypass equipment.',
        category = 'Tools'
    },
    {
        label = 'Screwdriver Set',
        item = 'screwdriverset',
        price = 5000,
        desc = 'Professional screwdriver set.',
        category = 'Tools'
    },
    {
        label = 'Wire Cutters',
        item = 'wirecutters',
        price = 4000,
        desc = 'Precision wire cutters.',
        category = 'Tools'
    },
    {
        label = 'Grinder',
        item = 'grinder',
        price = 12000,
        desc = 'Compact industrial grinder.',
        category = 'Tools'
    },
    {
        label = 'Rope',
        item = 'rope',
        price = 2500,
        desc = 'Heavy-duty rope.',
        category = 'Tools'
    },
    {
        label = 'VirusHost',
        item = 'virushost',
        price = 15000,
        desc = 'A basic ATM hacking device.',
        category = 'Tools'
    },
    {
        label = 'MuskCode',
        item = 'muskcode',
        price = 25000,
        desc = 'An encrypted ATM bypass device.',
        category = 'Tools'
    },
    {
        label = 'WirePro',
        item = 'wirepro',
        price = 40000,
        desc = 'A high-end ATM root access device.',
        category = 'Tools'
    },

    {
        label = 'Trojan USB',
        item = 'trojan_usb',
        price = 36000,
        desc = 'Encrypted access tool.',
        category = 'SpyGear'
    },
    {
        label = 'Gaming Laptop',
        item = 'gaming_laptop',
        price = 45000,
        desc = 'High-performance laptop.',
        category = 'SpyGear'
    },
    {
        label = 'Watch',
        item = 'watch',
        price = 9500,
        desc = 'Compact electronic watch.',
        category = 'SpyGear'
    },
    {
        label = 'Monitor',
        item = 'monitor',
        price = 14000,
        desc = 'Portable display monitor.',
        category = 'SpyGear'
    },
    {
        label = 'Security Card A',
        item = 'security_card_01',
        price = 18000,
        desc = 'Restricted access security card.',
        category = 'SpyGear'
    },
    {
        label = 'Security Card B',
        item = 'security_card_02',
        price = 22000,
        desc = 'High-clearance security card.',
        category = 'SpyGear'
    },
    {
        label = 'Fraud Laptop',
        item = 'fraud_laptop',
        price = 650000,
        desc = 'Specialised computer for underground operations.',
        category = 'SpyGear'
    },
    {
        label = 'Spy Binoculars',
        item = 'spy_binoculars',
        price = 18000,
        desc = 'Long-range observation equipment.',
        category = 'SpyGear'
    },
    {
        label = 'Spy GPS',
        item = 'spy_gps',
        price = 25000,
        desc = 'Discreet GPS tracking device.',
        category = 'SpyGear'
    },
    {
        label = 'Spy Camera',
        item = 'spy_cam',
        price = 22000,
        desc = 'Compact surveillance camera.',
        category = 'SpyGear'
    },
    {
        label = 'Motion Sensor',
        item = 'spy_motionsensor',
        price = 27500,
        desc = 'Portable motion detection system.',
        category = 'SpyGear'
    },
    {
        label = 'Spy Camera Terminal',
        item = 'spy_cam_terminal',
        price = 40000,
        desc = 'Remote camera monitoring terminal.',
        category = 'SpyGear'
    },
    {
        label = 'Spy Detector',
        item = 'spy_detector',
        price = 30000,
        desc = 'Device for detecting surveillance equipment.',
        category = 'SpyGear'
    },
    {
        label = 'Contracts Tablet',
        item = 'contracts_tablet',
        price = 55000,
        desc = 'Encrypted underground contracts terminal.',
        category = 'SpyGear'
    },
    {
        label = 'Hack Card',
        item = 'hack_card',
        price = 27500,
        desc = 'Encrypted access card.',
        category = 'SpyGear'
    },
    {
        label = 'Digital Radio',
        item = 'radio',
        price = 25000,
        desc = 'An encrypted handheld radio with location-beacon support.',
        category = 'SpyGear'
    },
    {
        label = 'Radio Cell',
        item = 'radiocell',
        price = 3000,
        desc = 'A replacement power cell for a digital radio.',
        category = 'SpyGear'
    },
    {
        label = 'Signal Jammer',
        item = 'jammer',
        price = 75000,
        desc = 'A configurable radio-frequency jammer.',
        category = 'SpyGear'
    },

    {
        label = 'Savanna Guard',
        item = 'savanna_guard',
        price = 500000,
        desc = 'Black-market consumable.',
        category = 'Consumables'
    },
    {
        label = 'Marula Vifgor',
        item = 'marula_vifgor',
        price = 50000,
        desc = 'Black-market consumable.',
        category = 'Consumables'
    },
    {
        label = 'Baobab Rush',
        item = 'baobab_rush',
        price = 50000,
        desc = 'Black-market consumable.',
        category = 'Consumables'
    },

    {
        label = 'Soil Bag',
        item = 'soil_bag',
        price = 5000,
        desc = 'Bag of soil for planting.',
        category = 'WeedGrowing'
    },
    {
        label = 'Fertilizer',
        item = 'fertilizer',
        price = 15000,
        desc = 'Plant growth fertilizer.',
        category = 'WeedGrowing'
    },
    {
        label = 'Empty Pot',
        item = 'empty_pot',
        price = 2500,
        desc = 'Empty growing pot.',
        category = 'WeedGrowing'
    },
    {
        label = 'Weed Table',
        item = 'weed_table',
        price = 850000,
        desc = 'Growing equipment.',
        category = 'WeedGrowing'
    },
    {
        label = 'Rolling Paper',
        item = 'rolling_paper',
        price = 1500,
        desc = 'Rolling papers.',
        category = 'WeedGrowing'
    },
    {
        label = 'Empty Bag',
        item = 'empty_bag',
        price = 1000,
        desc = 'Small empty packaging bag.',
        category = 'WeedGrowing'
    },
    {
        label = 'Empty Baggie',
        item = 'kq_empty_baggie',
        price = 1200,
        desc = 'Empty baggie for packaging.',
        category = 'WeedGrowing'
    },
    {
        label = 'Water Bottle',
        item = 'water_bottle',
        price = 1000,
        desc = 'Water for plant cultivation.',
        category = 'WeedGrowing'
    }
}

Config.DeliveryDelay = 30000
Config.DeliveryPickupTime = 300000
