require "games/arkham"

rosenberg = {}

rosenberg.render = {
    board = function(b)
        for x = 1, b.x do
            for y = 1, b.y do
                love.graphics.print(b.grid[x][y].glyph, x * b.tileSizeX, y * b.tileSizeY)
            end
        end
    end,
    piece = function(p)
        if not p.location then error("Game error: no location set for a piece!") end
        local x = p.x * components[p.location].tileSizeX
        local y = p.y * components[p.location].tileSizeY
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
    end
}

function rosenberg.hook(hook)
    for k, v in ipairs(hooks[hook]) do
        rules[v.rule].action(components)
    end
    if hook == "gameOver" then
        love.event.quit()
    end
end

function love.load()
    if not components then error("Game error: components not set!") end
    if not rules then error("Game error: rules not set!") end
    if not hooks then error("Game error: hooks not set!") end
    if not hooks.startGame then error("Game error: startGame hook not created!") end
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