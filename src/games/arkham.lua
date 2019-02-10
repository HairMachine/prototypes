components = {
    city = {
        draw = "board",
        x = 8,
        y = 8,
        grid = {},
        tileSizeX = 16,
        tileSizeY = 16,
        startX = 0,
        startY = 0
    },
    status = {
    	draw = "textbox",
    	text = "",
    	startX = 0,
    	startY = 300
	},
    players = {
        draw = "pieces",
        pieces = {
            {
                glyph = "@",
                color = {1, 1, 0},
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
                },
                clues = 0,
                items = {}
            },
            {
                glyph = "@",
                location = "city",
                x = 3,
                y = 3,
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
                },
                clues = 0,
                items = {}
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
    encounters = {
    	standard = {
    		{
    			text = "You find a strange sign daubed on a wall.",
    			skill = "lore",
    			unique = 0
    		},
    		{
    			text = "You see something poking out from under a heavy stone.",
    			skill = "strength",
    			unique = 0
    		},
    		{
    			text = "Something bothers you about this place, but you can't put your finger on it.",
    			skill = "observation",
    			unique = 0
    		},
    		{
    			text = "You come across a scene of horror!",
    			skill = "will",
    			unique = 0
    		}
    	}
	},
    items = {
    	draw = "pieces",
    	pieces = {}
    },
    mythosEffects = {
        {
            name = "spawnGate",
            chance = 10
        },
        {
            name = "spawnMonster",
            chance = 10
        },
        {
        	name = "spawnClue",
        	chance = 10
    	},
    	{
    		name = "spawnItem",
    		chance = 10
    	}
    },
    monsterTypes = {
        
    },
    itemData = {
    	{
    		name = "shotgun",
    		chance = 5,
    		bonus = {
    			strength = 2
    		}
    	},
    	{
    		name = "derringer",
    		chance = 10,
    		bonus = {
    			strength = 1
    		}
    	},
    	{
    		name = "necronomicon",
    		chance = 1,
    		bonus = {
    			lore = 4,
    			sanity = -2
    		}
    	},
    	{
    		name = "lens",
    		chance = 10,
    		bonus = {
    			observation = 1
    		}
    	},
    	{
    		name = "whisky",
    		chance = 15,
    		bonus = {},
    		active = {
    			sanity = 3
    		}
    	},
    	{
    		name = "philtre of haste",
    		chance = 4,
    		bonus = {},
    		active = {
    			actions = 1
    		}
    	},
    	{
    		name = "bandages",
    		chance = 8,
    		bonus = {},
    		active = {
    			hp = 2
    		}
    	}
	},
    currentPlayer = 1,
}

helpers = {
	location = function(glyph)
		local sx
        local sy
        local done = false
        while not done do
        	sx = math.random(1, components.city.x)
        	sy = math.random(1, components.city.y)
        	if components.city.grid[sx][sy].glyph == "." then
        		components.city.grid[sx][sy].glyph = glyph
        		done = true
        	end
        end
	end,
    currentPlayerCanMove = function(x, y)
        local player = components.players.pieces[components.currentPlayer]
        if player.actionsDoneThisTurn >= player.actions then
            return false
        end
        if player.x + x < 1 or player.y + y < 1 or player.x + x > components.city.x or player.y + y > components.city.y then
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
    end,
    getItem = function(item)
    	local player = components.players.pieces[components.currentPlayer]
		for k, v in ipairs(player.items) do
			if v.name == item then return v end
		end
		return nil
	end,
	updateStatus = function()
    	local player = components.players.pieces[components.currentPlayer]
    	components.status.text = "HP: "..player.hp.. " Sanity: "..player.sanity.." Clues: "..player.clues
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
            end
            helpers.location("G")
            helpers.location("L")
            helpers.location("S")
            helpers.location("B")
            for i = 1, 3 do
                rules.spawnClue.action()
            end
            rules.spawnItem.action()
            rules.spawnItem.action()
            helpers.updateStatus()
        end
    },
    travelNorth = {
        constraints = function()
            return helpers.currentPlayerCanMove(0, -1)
        end,
        action = function()
            helpers.currentPlayerTravel(0, -1)
        end
    },
    travelEast = {
        constraints = function()
            return helpers.currentPlayerCanMove(1, 0)
        end,
        action = function()
            helpers.currentPlayerTravel(1, 0)
        end
    },
    travelSouth = {
        constraints = function()
            return helpers.currentPlayerCanMove(0, 1)
        end,
        action = function()
            helpers.currentPlayerTravel(0, 1)
        end
    },
    travelWest = {
        constraints = function()
            return helpers.currentPlayerCanMove(-1, 0)
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
                	local willBonus = 0
                	local strBonus = 0
                	for ki, item in ipairs(player.items) do
                		if item.data.bonus.will == "will" then
            				willBonus = willBonus + item.data.bonus.will
                		elseif item.data.bonus.strength then
                			strBonus = strBonus + item.data.bonus.strength
                		end
                	end
                    local fearSave = helpers.skillTest(player.skills.will + willBonus, v.willTest, 5)
                    local sanDam = v.fear - fearSave
                    if sanDam > 0 then 
                        player.sanity = player.sanity - sanDam 
                        print("Player loses "..sanDam.." sanity!")
                    end
                    local hurtSave = helpers.skillTest(player.skills.strength + strBonus, v.strTest, 5)
                    local hpDam = v.strength - hurtSave
                    if hpDam > 0 then
                        player.hp = player.hp - hpDam
                        print("Player takes "..hpDam.. " damage!")
                    end
                    v.hp = v.hp - hurtSave
                    print("Monster takes "..math.abs(hurtSave).. "damage!")
                end
            end            
            rules.endTurn.action()
        end
    },
    getItem = {
        constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            for k, v in ipairs(components.items.pieces) do
                if v.x == player.x and v.y == player.y then
                    return true
                end
            end
            return false
        end,
        action = function()
            local player = components.players.pieces[components.currentPlayer]
            for k, v in ipairs(components.items.pieces) do
                if v.x == player.x and v.y == player.y then
                	print("Picked up "..v.data.name.."!")
                    table.insert(player.items, v)
                    table.remove(components.items.pieces, k)
                    rules.endTurn.action()
                    return
                end
            end
        end
    },
    rest = {
        constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            return player.hp < player.maxHp or player.sanity > player.maxSanity and player.actionsDoneThisTurn < player.actions
        end,
        action = function()
            local player = components.players.pieces[components.currentPlayer]
            player.hp = player.hp + 1
            player.sanity = player.sanity + 1
            player.actionsDoneThisTurn = player.actionsDoneThisTurn + 1
        end
    },
    getClue = {
    	constraints = function()
            local player = components.players.pieces[components.currentPlayer]
    		for k, v in ipairs(components.clues.pieces) do
    			if v.x == player.x and v.y == player.y then
    				return true
    			end
    		end
    		return false
    	end,
    	action = function()
            local player = components.players.pieces[components.currentPlayer]
    		for k, v in ipairs(components.clues.pieces) do
    			if v.x == player.x and v.y == player.y then
    				local enc = components.encounters.standard[math.random(1, #components.encounters.standard)]
    				print(enc.text)
    				local success = helpers.skillTest(player.skills[enc.skill], 0, 5)
    				if success then
    					print("You have discovered a CLUE!")
    					player.clues = player.clues + 1
    					table.remove(components.clues.pieces, k)
    					rules.endTurn.action()
    					return
    				end
    			end
    		end
    	end
	},
	closeGate = {
		constraints = function()
            local player = components.players.pieces[components.currentPlayer]
            for k, v in ipairs(components.gates.pieces) do
        		if v.x == player.x and v.y == player.y and player.clues >= 5 then
        			return true
        		end
            end
            return false
		end,
		action = function()
            local player = components.players.pieces[components.currentPlayer]
			for k, v in ipairs(components.gates.pieces) do
        		if v.x == player.x and v.y == player.y then
        			print("Using your accumulated knowledge, you close the gate!")
        			table.remove(components.gates.pieces, k)
        			player.clues = player.clues - 5
        		end
            end
		end
	},
	drinkWhisky = {
		constraints = function()
            return helpers.getItem("whisky") ~= nil and player.sanity < player.maxSanity
		end,
		action = function()
			local item = helpers.getItem("whisky")
            local player = components.players.pieces[components.currentPlayer]
            player.sanity = player.sanity + item.data.active.sanity
            if player.sanity > player.maxSanity then player.sanity = player.maxSanity end
		end
	},
	drinkPhiltreOfHaste = {
		constraints = function()
            local player = components.players.pieces[components.currentPlayer]
			return helpers.getItem("philtre of haste") ~= nil and player.actionsDoneThisTurn > 0
		end,
		action = function()
            local player = components.players.pieces[components.currentPlayer]
			local item = helpers.getItem("philtre of haste")
			player.actionsDoneThisTurn = player.actionsDoneThisTurn - item.data.active.actions
		end
	},
	useBandages = {
		constraints = function()
            local player = components.players.pieces[components.currentPlayer]
			return helpers.getItem("bandages") ~= nil and player.hp < player.maxHp
		end,
		action = function()
            local player = components.players.pieces[components.currentPlayer]
			local item = helpers.getItem("bandages")
			player.hp = player.hp + item.active.hp
			if player.hp > player.maxHp then player.hp = player.maxHp end
		end
	},
    endTurn = {
        constraints = function()
            return true
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
            -- check whether there are too many gates
            if #components.monsters.pieces > 5 then
            	rosenberg.hook("gameOver")
            end
            -- check whether the player has won!
            if #components.gates.pieces == 0 then
            	rosenberg.hook("gameOver")
            end
            -- check whether we should kill monsters
            for i = #components.monsters.pieces, 1, -1 do
                if components.monsters.pieces[i].hp <= 0 then
                    print("Monster is defeated!")
                    table.remove(components.monsters.pieces, i)
                end
            end
            components.players.pieces[components.currentPlayer].color = nil
            components.currentPlayer = components.currentPlayer + 1
            if components.currentPlayer > #components.players.pieces then
                rules.mythosPhase.action()
            else
            	components.players.pieces[components.currentPlayer].color = {1, 1, 0}
            end
            helpers.updateStatus()
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
            for k, gate in ipairs(components.gates.pieces) do
            	if math.random(1, 6) >= 4 then
            		print("Monster emerged from a gate at "..gate.x..", "..gate.y.."!")
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
            end
        end
    },
    spawnClue = {
        constraints = function()
            return false
        end,
        action = function()
            table.insert(components.clues.pieces, {
                x = math.random(1, components.city.x),
                y = math.random(1, components.city.y),
                glyph = "?",
                location = "city",
                color = {0, 1, 0}
            })
        end
    },
    spawnItem = {
    	constraints = function()
    		return false
    	end,
    	action = function()
    		table.insert(components.items.pieces, {
    			x = math.random(1, components.city.x),
    			y = math.random(1, components.city.y),
    			glyph = "!",
    			location = "city",
    			color = {0.5, 0.5, 1},
    			data = rosenberg.rollOnTable(components.itemData)
    		})		
    	end
	},
    mythosPhase = {
        constraints = function()
            return false
        end,
        action = function()
            print("THE MYTHOS ACTS...")
            local effect = rosenberg.rollOnTable(components.mythosEffects)            
            if not rules[effect.name] then error("Game error: attempted to trigger non-existent rule "..effect) end
            rules[effect.name].action()
            for k, v in ipairs(components.players.pieces) do
                v.actionsDoneThisTurn = 0
            end
            components.currentPlayer = 1
            components.players.pieces[components.currentPlayer].color = {1, 1, 0}
        end
    }
}

hooks = {
    startGame = {
        {rule = "setupCity"},
        {rule = "spawnGate"}
    }
}

hotkeys = {
	up = "travelNorth",
	left = "travelWest",
	down = "travelSouth",
	right = "travelEast",
	space = "endTurn"
}
hotkeys[","] = "getItem"
hotkeys["x"] = "getClue"
hotkeys["f"] = "fight"
hotkeys["r"] = "rest"