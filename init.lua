-- Fall damage
fall = {
    '1 hit the ground too hard',
    '1 jumped off a cliff',
    '1 thought water canceled fall damage',
    "1 fell and couldn't get back up"
}

-- Burning in fire
burn = {
    '1 burned to a crisp',
    '1 got a little too warm',
    '1 got too close to the camp fire',
    '1 forgot to stop, drop, and roll'
}

-- Drowning
drown = {
    '1 drowned',
    '1 ran out of air',
    '1 tried to impersonate an anchor',
    "1 forgot they aren't a fish"
}

-- Burning in lava
lava = {
    '1 thought lava was cool',
    '1 tried to swim in lava',
    '1 melted in lava',
    '1 fell whilst trying to reach that last diamond'
}

-- Killed by other player
pvp = {
    '1 was slain by 2',
    '1 was killed by 2',
    '1 was put to the sword by 2',
    '1 lost a PVP battle to 2'
}

-- Killed by mob
mob = {
    '1 was slain by 2',
    '1 was killed by 2',
    "1 got on 2's last nerve",
    '1 forgot to feed 2'
}

-- Everything else
other = {
    '1 died',
    '1 gave up on life',
    '1 passed out - permanantly',
    '1 did something fatal'
}

function send_death_message(cause, victim, killer)
    meta = victim:get_meta()
    show_death_messages = meta:get_string('show_death_messages')

    if show_death_messages == '' or show_death_messages == 'yes' then
        random_selection = cause[math.random(4)]
        death_message = string.gsub(random_selection, '1', victim:get_player_name())

        if killer then
            if killer:is_player() then
                death_message = string.gsub(death_message, '2', killer:get_player_name())
            else
                -- Get entity name, excluding mod name ("mymod:enemy" -> "enemy")
                entity_name = killer:get_luaentity().name
                index, _ = string.find(entity_name, ':')
                entity_name = string.sub(entity_name, index + 1)

                death_message = string.gsub(death_message, '2', entity_name)
            end
        end

        minetest.chat_send_all(death_message)
    end
end

minetest.register_on_dieplayer(function(player, reason)
    if reason.object then
        if reason.object:is_player() then
            -- Player was killed by player
            send_death_message(pvp, player, reason.object)
        
        else
            -- Player was killed by mob
            send_death_message(mob, player, reason.object)

        end
    else
        if reason.type == 'fall' then
            -- Player was killed by fall damage
            send_death_message(fall, player)

        elseif reason.type == 'drown' then
            -- Player drowned
            send_death_message(drown, player)

        elseif reason.type == 'node_damage' then
            if string.match(reason.node, 'lava') then
                -- Player burned in lava
                send_death_message(lava, player)

            elseif string.match(reason.node, 'fire') then
                -- Player burned in fire
                send_death_message(burn, player)

            else
                -- Reason not detected, send general death message
                send_death_message(other, player)
            end
        else
            send_death_message(other, player)
        end
    end
end)

minetest.register_chatcommand('toggle_death_messages', {
    description = 'Toggles death messages appearing in chat when you die',
    func = function(name)
        meta = minetest.get_player_by_name(name):get_meta()
        show_death_messages = meta:get_string('show_death_messages')

        if show_death_messages == '' or show_death_messages == 'yes' then
            -- Turn death messages off
            meta:set_string('show_death_messages', 'no')
            minetest.chat_send_player(name, minetest.colorize('green', 'You will no longer send death messages'))
            minetest.log('action', name .. ' disabled their death messages')
        
        else
            -- Turn death messages on
            meta:set_string('show_death_messages', 'yes')
            minetest.chat_send_player(name, minetest.colorize('green', 'You will now send death messages'))
            minetest.log('action', name .. ' enabled their death messages')
        end
    end
})
