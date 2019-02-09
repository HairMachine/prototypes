components = {
    city = {
        draw = "board",
        x = 12,
        y = 12,
        grid = {},
        tileSizeX = 16,
        tileSizeY = 16
    },
    players = {
        draw = "pieces",
        pieces = {
            {
                glyph = "@",
                location = "city",
                x = 5,
                y = 5,
                actions = 2,
                actionsDoneThisTurn = 0,
                hp = 5,
                maxHp = 5,
                sanity = 5,
                maxSanity = 5,
                skills = {
                    lore = 2,
                    influence = 2,
                    observation = 2,
                    strength = 2,
                    will = 2
                }
            },
            {
                glyph = "@",
                location = "city",
                x = 10,
                y = 8,
                actions = 2,
                actionsDoneThisTurn = 0,
                hp = 5,
                maxHp = 5,
                sanity = 5,
                maxSanity = 5,
                skills = {
                    lore = 2,
                    influence = 2,
                    observation = 2,
                    strength = 2,
                    will = 2
                }
            }
        }
    },
    gates = {
        draw = "pieces",
        pieces = {}
    },
    monsters = {
        draw = "pieces",
        pieces = {}
    },
    clues = {
        draw = "pieces",
        pieces = {}
    },
    items = {},
    mythosEffects = {
        {
            name = "spawnGate",
            chance = 10
        },
        {
            name = "spawnMonster",
            chance = 5
        }
    },
    monsterTypes = {
        
    },
    currentPlayer = 1,
}

helpers = {
    currentPlayerCanMove = function(x, y)
        local player = components.players.pieces[components.currentPlayer]
        if player.actionsDoneThisTurn >= player.actions then
            return false
        end
        if player.x < 1 or player.y < 1 or player.x > components.city.x or player.y > components.city.y then
            return false
        end
        return true
    end,
    currentPlayerTravel = function(x, y)
        local player = components.players.pieces[components.currentPlayer]
        player.x = player.x + x
        player.y = player.y + y
        player.actionsDoneThisTurn = player.actionsDoneThisTurn + 1
    end,
    skillTest = function(skillVal, difficulty, target)
        local player = components.players.pieces[components.currentPlayer]
        local successes = 0
        local modVal = skillVal - difficulty
        if modVal <= 0 then return 0 end
        for i = 0, modVal do
            local roll = math.random(1, 6)
            if roll >= target then successes = successes + 1 end
        end
        return successes
    end
}

rules = {
    setupCity = {
        constraints = function()
            return false
        end,
        action = function()
            for x = 1, components.city.x do
                components.city.grid[x] = {}
                for y = 1, components.city.y do
                    components.city.grid[x][y] = {
                        glyph = "."
                    }
                end
            end,
            for i = 1, 3 do
                rules.spawnClue.action()
            end
        end
    },
    travelNorth = {
        constraints = function()
            return helpers.currentPlayerCanMove()
        end,
        action = function()
            helpers.currentPlayerTravel(0, -1)
        end
    },
    travelEast = {
        constraints = function()
            return helpers.currentPlayerCanMove()
        end,
        action = function()
            helpers.currentPlayerTravel(1, 0)
        end
    },
    travelSouth = {
        constraints = function()
            return helpers.currentPlayerCanMove()
        end,
        action = function()
            helpers.currentPlayerTravel(0, 1)
        end
    },
    travelWest = {
        constraints = function()
            return helpers.currentPlayerCanMove()
        end,
        action = function()
            helpers.currentPlayerTravel(-1, 0)
        end
    },
    fight = {
        constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            for k, v in ipairs(components.monsters.pieces) do
                if v.x == player.x and v.y == player.y then return true end
            end
            return false
        end,
        action = function()
            print("YOU FIGHT THE MONSTER!")
            local player = components.players.pieces[components.currentPlayer]
            for k, v in ipairs(components.monsters.pieces) do
                if v.x == player.x and v.y == player.y then
                    local fearSave = helpers.skillTest(player.skills.will, v.willTest, 5)
                    local sanDam = v.fear - fearSave
                    if sanDam > 0 then 
                        player.sanity = player.sanity - sanDam 
                        print("Player loses "..sanDam.." sanity!")
                    end
                    local hurtSave = helpers.skillTest(player.skills.strength, v.strTest, 5)
                    local hpDam = v.strength - hurtSave
                    if hpDam > 0 then
                        player.hp = player.hp - hpDam
                        print("Player takes "..hpDam.. " damage!")
                    else
                        v.hp = v.hp + hpDam
                        print("Monster takes "..math.abs(hpDam).. "damage!")
                    end
                    
                end
            end            
            rules.endTurn.action()
        end
    },
    buyItem = {
        constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            for k, v in components.items do
                if v.x == player.x and v.y == player.y then
                    return true
                end
            end
            return false
        end,
        action = function()
            print("Player buys the item!")
        end
    },
    rest = {
        constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            return player.hp < player.maxHp or player.sanity > player.maxSanity
        end,
        action = function()
            local player = components.players.pieces[components.currentPlayer]
            player.hp = player.hp + 1
            player.sanity = player.sanity + 1
        end
    },
    endTurn = {
        constraints = function()
            return false
        end,
        action = function()
            -- check whether we should kill players
            for i = #components.players.pieces, 1, -1 do
                local player = components.players.pieces[i]
                if player.hp <= 0 or player.sanity <= 0 then
                    print("Player is eliminated!")
                    table.remove(components.players.pieces, i)
                end
            end
            if #components.players.pieces <= 0 then
                rosenberg.hook("gameOver")
            end
            -- check whether we should kill monsters
            for i = #components.monsters.pieces, 1, -1 do
                if components.monsters.pieces[i].hp <= 0 then
                    print("Monster is defeated!")
                    table.remove(components.monsters.pieces, i)
                end
            end
            components.currentPlayer = components.currentPlayer + 1
            if components.currentPlayer > #components.players.pieces then
                rules.mythosPhase.action()
            end
        end
    },
    spawnGate = {
        constraints = function()
            return false
        end,
        action = function()
            table.insert(components.gates.pieces, {
                x = math.random(1, components.city.x),
                y = math.random(1, components.city.y),
                glyph = "X",
                location = "city",
                color = {1, 0, 1}
            })
        end
    },
    spawnMonster = {
        constraints = function()
            return false
        end,
        action = function()
            local gate = components.gates.pieces[math.random(1, #components.gates.pieces)]
            print("Spawn monster at "..gate.x..", "..gate.y)
            table.insert(components.monsters.pieces, {
                x = gate.x,
                y = gate.y,
                glyph = "M",
                location = "city",
                color = {1, 0, 0},
                hp = 3,
                strength = 2,
                fear = 2,
                willTest = 0,
                strTest = 0
            })
        end
    },
    spawnClue = {
        constraints = function()
            return true
        end,
        action = function()
            table.insert(components.gates.pieces, {
                x = math.random(1, components.city.x),
                y = math.random(1, components.city.y),
                glyph = "?",
                location = "city",
                color = {0, 1, 0}
            })
        end
    },
    mythosPhase = {
        constraints = function()
            return false
        end,
        action = function()
            print("THE MYTHOS ACTS...")
            local effect = components.mythosEffects[math.random(1, #components.mythosEffects)]
            if effect.name == "spawnGate" then
                rules.spawnGate.action()
            elseif effect.name == "spawnMonster" and #components.gates.pieces > 0 then
                rules.spawnMonster.action()
            end
            for k, v in ipairs(components.players.pieces) do
                v.actionsDoneThisTurn = 0
            end
            components.currentPlayer = 1
        end
    }
}

hooks = {
    startGame = {
        {rule = "setupCity"},
        {rule = "spawnGate"}
    }
}