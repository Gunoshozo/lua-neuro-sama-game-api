local sfx = {}

sfx.win = love.audio.newSource("assets/win.ogg", "static")
sfx.win:setVolume(0.1)
sfx.loss = love.audio.newSource("assets/loss.ogg","static")
sfx.loss:setVolume(0.1)
sfx.draw = love.audio.newSource("assets/draw.ogg","static")
sfx.draw:setVolume(0.1)


return sfx
