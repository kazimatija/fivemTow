local Translations = {
    error = {
        nitrous_already_active = 'You already have nitrous installed and activated',
        load_bike = 'Cannot install nitrous on a bike',
        no_turbo = 'You must have turbo installed to do this',
        engine_on = 'You cannot install nitrous with the engine on',
        canceled = 'Canceled',
        engine_remain_off = 'Engine must remain off while you install nitrous',
        no_nitrous = 'You don\'t have any nitrous on you',
        empty_nitrous_bottle = 'This nitrous bottle is empty',
    },
    primary = {
        flowrate = 'Nitrous Flowrate: %{value}',
        mode_purge = 'Mode: Purge',
        mode_nitrous = 'Mode: Nitrous',
    },
    progressbar = {
        load_nitrous = 'Connecting NOS...',
        fill_nitrous = 'Filling Nitrous Bottle',
    },
}

Lang = Locale:new({
    phrases = Translations,
    warnOnMissing = true
})
