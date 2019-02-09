components = {
    -- like a kind of simple token.
    phase = "setup",
    -- this component is like a "layout" or something. -> Actually there should be a separate "Layout" config! <-
    board = {
        draw = "board",
        screenX = 0,
        screenY = 0,
        x = 10,
        y = 10,
        tileSizeX = 16,
        tileSizeY = 16,
        gridType = "tiles",
        grid = {}
    },
    -- This is like a stack of components; it's used here to generate a tile layout on the board
    tiles = {
        {glyph = "G"}, {glyph = "M"}
    },
    -- standard piece component
    character = {
        draw = "piece",
        location = "board",
        x = 5,
        y = 5,
        glyph = "@",
        hp = 10
    },
    monsterTypes = {
        {glyph = "g", hp = 2},
        {glyph = "o", hp = 5}
    },
    monsters = {
        draw = "pieces",
        pieces = {}
    }
}

-- These rules are atomic, and take no parameters. The user should be able to specify "rulesets",
-- which translate a UI action into a series of rules. All constraints must pass for a ruleset to be 
-- legal.

-- Rule Templates should be added: this is when you want to parametrise rules. Kind of like C macros I guess,
-- in that they are basically code replacement.

rules = {
    generateBoard = {
        constraints = function(c)
            return c.phase == "setup"
        end,
        action = function(c)
            for x = 1, c.board.x do
                c.board.grid[x] = {}
                for y = 1, c.board.y do
                    c.board.grid[x][y] = c.tiles[math.random(1, #c.tiles)]
                end
            end
        end
    },
    spawnMonsters = {
        constraints = function(c)
            return c.phase == "setup"
        end,
        action = function(c)
            for i = 1, 5 do
                local mon = c.monsterTypes[math.random(1, #c.monsterTypes)]
                table.insert(c.monsters.pieces, {
                    glyph = mon.glyph,
                    hp = mon.hp,
                    x = math.random(1, c.board.x),
                    y = math.random(1, c.board.y),
                    location = "board"
                })
            end
        end
    },
    startGame = {
        constraints = function(c)
            return c.phase == "setup"
        end,
        action = function(c)
            c.phase = "game"
        end
    },
    movePlayerUp = {
        constraints = function(c)
            local notblocked = true
            for k,v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y - 1 and v.x == c.character.x then
                    notblocked = false
                end
            end
            return c.phase == "game" and c.character.y > 1 and notblocked
        end,
        action = function(c)
            c.character.y = c.character.y - 1
            rosenberg.hook("endTurn")
        end
    },
    movePlayerRight = {
        constraints = function(c)
            local notblocked = true
            for k,v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x + 1 then
                    notblocked = false
                end
            end
            return c.phase == "game" and c.character.x < c.board.x and notblocked
        end,
        action = function(c)
            c.character.x = c.character.x + 1
            rosenberg.hook("endTurn")
        end
    },
    movePlayerDown = {
        constraints = function(c)
            local notblocked = true
            for k,v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y + 1 and v.x == c.character.x then
                    notblocked = false
                end
            end
            return c.phase == "game" and c.character.y < c.board.y and notblocked
        end,
        action = function(c)
            c.character.y = c.character.y + 1
            rosenberg.hook("endTurn")
        end
    },
    movePlayerLeft = {
        constraints = function(c)
            local notblocked = true
            for k,v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x - 1 then
                    notblocked = false
                end
            end
            return c.phase == "game" and c.character.x > 1 and notblocked
        end,
        action = function(c)
            c.character.x = c.character.x - 1
            rosenberg.hook("endTurn")
        end
    },
    -- potentially have what is returned from "constraints" passed into action?
    attackPlayerUp = {
        constraints = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y - 1 and v.x == c.character.x then
                    return true
                end
            end
        end,
        action = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y - 1 and v.x == c.character.x then
                    v.hp = v.hp - 1
                    if v.hp <= 0 then
                        table.remove(c.monsters.pieces, k)
                    end
                    rosenberg.hook("endTurn")
                    return
                end
            end
        end
    },
    attackPlayerRight = {
        constraints = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x + 1 then
                    return true
                end
            end
        end,
        action = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x + 1 then
                    v.hp = v.hp - 1
                    if v.hp <= 0 then
                        table.remove(c.monsters.pieces, k)
                    end
                    rosenberg.hook("endTurn")
                    return
                end
            end
        end
    },
    attackPlayerDown = {
        constraints = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y + 1 and v.x == c.character.x then
                    return true
                end
            end
        end,
        action = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y + 1 and v.x == c.character.x then
                    v.hp = v.hp - 1
                    if v.hp <= 0 then
                        table.remove(c.monsters.pieces, k)
                    end
                    rosenberg.hook("endTurn")
                    return
                end
            end
        end
    },
    attackPlayerLeft = {
        constraints = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x - 1 then
                    return true
                end
            end
        end,
        action = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                if v.y == c.character.y and v.x == c.character.x - 1 then
                    v.hp = v.hp - 1
                    if v.hp <= 0 then
                        table.remove(c.monsters.pieces, k)
                    end
                    rosenberg.hook("endTurn")
                    return
                end
            end
        end
    },
    moveMonsters = {
        constraints = function(c)
            return false
        end,
        action = function(c)
            for k, v in ipairs(c.monsters.pieces) do
                local xdiff = v.x - c.character.x
                local ydiff = v.y - c.character.y
                local newY = v.y
                local newX = v.x
                if math.abs(xdiff) > math.abs(ydiff) and xdiff < 0 then
                    newX = newX + 1
                elseif math.abs(xdiff) > math.abs(ydiff) and xdiff > 0 then
                    newX = newX - 1
                elseif math.abs(ydiff) >= math.abs(xdiff) and ydiff < 0 then
                    newY = newY + 1
                elseif math.abs(ydiff) >= math.abs(xdiff) and ydiff > 0 then
                    newY = newY - 1
                end
                if newX == c.character.x and newY == c.character.y then
                    c.character.hp = c.character.hp - 1
                    if c.character.hp <= 0 then
                        rosenberg.hook("gameOver")
                    end
                else
                    v.x = newX
                    v.y = newY
                end
            end
        end
    }
}

hooks = {
    startGame = {
        {rule = "generateBoard"},
        {rule = "spawnMonsters"},
        {rule = "startGame"}
    },
    endTurn = {
        {rule = "moveMonsters"},
    },
    gameOver = {}
}