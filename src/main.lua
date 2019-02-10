require "games/arkham"

-- TODO: Create some kind of in-built system to find whether two objects are on the same space. There can be caching to make this faster if needs be (not really important I think)
-- TODO: Message log system
-- TODO: Dynamically generated rules / verbs

rosenberg = {}

rosenberg.render = {
    board = function(b)
        for x = 1, b.x do
            for y = 1, b.y do
                love.graphics.print(b.grid[x][y].glyph, b.startX + x * b.tileSizeX, b.startY + y * b.tileSizeY)
            end
        end
    end,
    piece = function(p)
        if not p.location then error("Game error: no location set for a piece!") end
        local x = p.x * components[p.location].tileSizeX + components[p.location].startX
        local y = p.y * components[p.location].tileSizeY + components[p.location].startY
        if p.color then
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], 1)
        end
        love.graphics.print(p.glyph, x, y)
        love.graphics.setColor(1, 1, 1, 1)
    end,
    pieces = function(p)
        for k, v in ipairs(p.pieces) do
            rosenberg.render.piece(v)
        end
    end,
    textbox = function(p)
        love.graphics.print(p.text, p.startX, p.startY)
    end
}

function rosenberg.hook(hook)
    if hooks[hook] then
        for k, v in ipairs(hooks[hook]) do
            rules[v.rule].action(components)
        end
    end
    if hook == "gameOver" then
        love.event.quit()
    end
end

function rosenberg.rollOnTable(table)
    local tchance = 0
    for k, v in ipairs(table) do
        if not v.chance then error("Game error: missing chance value in table passed to rollOnTable") end
        tchance = tchance + v.chance
    end
    local roll = math.random(1, tchance)
    local tally = 0
    for k, v in ipairs(table) do
        tally = tally + v.chance
        if tally >= roll then
            return v
        end
    end
    error("Rosenberg error: could not select a value from rollOnTable")
end

function love.load()
    if not components then error("Game error: components not set!") end
    if not rules then error("Game error: rules not set!") end
    if not hooks then error("Game error: hooks not set!") end
    if not hooks.startGame then error("Game error: startGame hook not created!") end
    math.randomseed(os.time())
    rosenberg.hook("startGame")
end

function love.draw()
    for k, v in pairs(components) do
        if type(v) == "table" and v.draw then
            if not rosenberg.render[v.draw] then error("Game error: Invalid render mode "..v.draw.."!") end
            rosenberg.render[v.draw](v)
        end
    end
    local startX = 500
    local startY = 0
    love.graphics.rectangle("fill", startX, startY, 500, 800)
    love.graphics.setColor(0, 0, 0, 1)
    for k, v in pairs(rules) do
        if v.constraints(components) then
            love.graphics.print(k, startX, startY)
            startY = startY + 16
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function love.mousepressed(x, y, button, istouch, presses)
    local startX = 500
    local startY = 0
    for k, v in pairs(rules) do
        if not v.constraints then error("Rule error: "..k.." must set constrinats!") end
        if not v.action then error("Rule error: "..k.." must set action!") end
        if v.constraints(components) then
            if (x >= startX and y >= startY and y < startY + 16) then
                v.action(components)
            end
            startY = startY + 16
        end
    end
end

function love.keypressed(key, scancode, isrepeat)
    if not hotkeys then return end
    for k, v in pairs(hotkeys) do
        if k == key and rules[v].constraints() then rules[v].action() end
    end
end
