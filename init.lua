local S = minetest.get_translator("public_death_messages")
local NS = function(s) return s end

-- Fall damage
local fall = {
    NS('@1 hit the ground too hard'),
    NS('@1 jumped off a cliff'),
    NS('@1 forgot about fall damage'),
    NS("@1 fell and couldn't get back up")
}

-- Burning in fire
local burn = {
    NS('@1 burned to a crisp'),
    NS('@1 got a little too warm'),
    NS('@1 got too close to the camp fire'),
    NS('@1 got nuked')
}

-- Drowning
local drown = {
    NS('@1 drowned'),
    NS('@1 ran out of air'),
    NS('@1 tried to impersonate an anchor'),
    NS("@1 forgot they weren't a fish")
}

-- Burning in lava
local lava = {
    NS('@1 thought lava was cool'),
    NS('@1 tried to swim in lava'),
    NS('@1 melted in lava'),
    NS('@1 fell whilst trying to reach that last diamond')
}

-- Killed by other player
local pvp = {
    NS('@1 was slain by @2'),
    NS('@1 was killed by @2'),
    NS('@1 was put to the sword by @2'),
    NS('@1 lost a PVP battle to @2')
}

-- Killed by mob
local mob = {
    NS('@1 was slain by @2'),
    NS('@1 was killed by @2'),
    NS("@1 got on @2's last nerve"),
    NS('@1 forgot to feed @2')
}

-- Everything else
local other = {
    NS('@1 died'),
    NS('@1 gave up on life'),
    NS('@1 passed out - permanantly'),
    NS('@1 did something fatal')
}

-- Settings are read from your minetest.conf
-- TOGGLEABLE_DEATH_MESSAGES determines whether players can toggle their death messages.
-- If set to false, not only will they be untoggleable, but death messages are always enabled. The default is true
local TOGGLEABLE_DEATH_MESSAGES = minetest.settings:get_bool("public_death_messages_toggleable", true)

function send_death_message(cause, victim, killer)
    local meta = victim:get_meta()
    local show_death_messages = meta:get_string('show_death_messages')

    if TOGGLEABLE_DEATH_MESSAGES == false or show_death_messages == '' or show_death_messages == 'yes' then
        local death_message = cause[math.random(#cause)]

        if killer then
            local killer_name = ''
            if killer:is_player() then
                killer_name = killer:get_player_name()
            else
                -- Get entity name, excluding mod name ("mymod:enemy" -> "enemy")
                local entity_name = killer:get_luaentity().name
                local index, _ = entity_name:find(':')
                killer_name = entity_name:sub(index + 1)
            end
            death_message = S(death_message, victim:get_player_name(), killer_name)
        else
            death_message = S(death_message, victim:get_player_name())
        end

        minetest.chat_send_all(minetest.colorize('red', death_message))
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
    description = S('Toggles death messages appearing in chat when you die'),
    func = function(name)
        local meta = minetest.get_player_by_name(name):get_meta()
        local show_death_messages = meta:get_string('show_death_messages')

        if TOGGLEABLE_DEATH_MESSAGES == false then
            minetest.chat_send_player(name, minetest.colorize('orangered', S('Death messages cannot be disabled on this server')))

        elseif show_death_messages == '' or show_death_messages == 'yes' then
            -- Turn death messages off
            meta:set_string('show_death_messages', 'no')
            minetest.chat_send_player(name, minetest.colorize('green', S('You will no longer send death messages')))
            minetest.log('action', name .. ' disabled their death messages')

        else
            -- Turn death messages on
            meta:set_string('show_death_messages', 'yes')
            minetest.chat_send_player(name, minetest.colorize('green', S('You will now send death messages')))
            minetest.log('action', name .. ' enabled their death messages')
        end
    end
})
