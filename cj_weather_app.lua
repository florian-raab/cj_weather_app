function getWeatherName(weatherType)
    for name, value in pairs(ac.WeatherType) do
        if value == weatherType then
            return name
        end
    end
    return "Unknown" -- Return "Unknown" if the weather type is not found
end

function format(num, f)
    if not f then
        f = "%.2f"
    end
    return f:format(num)
end

local config = ac.storage {
    headline = true,
    weather = true,
    rain = true,
    temperature = true,
    wind = true,
    track = true,
    scale = 1,
    selectedLayout = 1,
    textColor = rgbm(1, 1, 1, 1),
    backgroundColor = rgbm(0, 0, 0, 0.3)
}

local weather_fx = ac.INIConfig.cspModule(ac.CSPModuleID.WeatherFX)
local controller = weather_fx:get("BASIC", "IMPLEMENTATION")
local controllerLabels = {
    ["pure"] = "Pure()",
    ["sol"] = "Sol",
}

function drawMainUI(activeContentCount)
    local drawnContentCount = 0

    function makeBlock(layout, contentWidth, content)
        ui.beginGroup()
        content()
        ui.beginGroup()
        local lineColor = config.textColor:clone():mul(rgbm(1, 1, 1, 0.3))
        if layout == 1 then
            ui.setCursorY(start_y)
            ui.offsetCursorX(contentWidth)
            local xy = ui.getCursor()
            if drawnContentCount < (activeContentCount - 1) then
                ui.drawLine(xy, vec2(xy.x, xy.y + ui.availableSpaceY()), lineColor, 1)
            end
            ui.offsetCursorX(10)
        end
        if layout == 2 then
            local xy = ui.getCursor()
            if drawnContentCount < (activeContentCount - 1) then
                ui.drawLine(xy, vec2(xy.x + ui.availableSpaceX(), xy.y), lineColor, 1)
            end
            ui.offsetCursorY(10)
        end
    end

    ui.drawRectFilled(vec2(0, 0), ui.windowSize(), config.backgroundColor, 15)
    ui.pushStyleColor(ui.StyleColor.Text, config.textColor)

    start_y = ui.getCursorY()

    if config.weather then
        makeBlock(config.selectedLayout, 200, function()
            ui.setNextTextBold()
            ui.pushFont(ui.Font.Title)
            ui.text('Weather')
            ui.popFont()
            ui.text("Controller:")
            ui.text("Current:")
            ui.text("Upcoming:")
            ui.text("Transition:")
            ui.beginSubgroup(75)
            ui.offsetCursorY(-4 * ui.textLineHeightWithSpacing())
            ui.text(controllerLabels[controller[1]] or controller[1])
            ui.text(getWeatherName(ac.getConditionsSet().currentType))
            ui.text(getWeatherName(ac.getConditionsSet().upcomingType))
            ui.progressBar(ac.getConditionsSet().transition, vec2(60, ui.textLineHeight()))
            ui.endGroup()
        end)
        drawnContentCount = drawnContentCount + 1
    end

    if config.rain then
        makeBlock(config.selectedLayout, 140, function()
            ui.setNextTextBold()
            ui.pushFont(ui.Font.Title)
            ui.text('Rain')
            ui.popFont()
            ui.text("Intensity:")
            ui.text("Wetness:")
            ui.text("Water:")
            ui.text("Humidity:")
            ui.beginSubgroup(70)
            ui.offsetCursorY(-4 * ui.textLineHeightWithSpacing())
            local isOnline = ac.getSimState().isOnlineRace
            local rainMultiplier = isOnline and 5 or 1
            ui.progressBar(ac.getConditionsSet().rainIntensity * rainMultiplier, vec2(60, ui.textLineHeight()))
            ui.progressBar(ac.getConditionsSet().rainWetness * rainMultiplier, vec2(60, ui.textLineHeight()))
            ui.progressBar(ac.getConditionsSet().rainWater, vec2(60, ui.textLineHeight()))
            ui.progressBar(ac.getConditionsSet().humidity, vec2(60, ui.textLineHeight()))
            ui.endGroup()
        end)
        drawnContentCount = drawnContentCount + 1
    end

    if config.temperature then
        makeBlock(config.selectedLayout, 125, function()
            ui.setNextTextBold()
            ui.pushFont(ui.Font.Title)
            ui.text('Temperature')
            ui.popFont()
            ui.text("Ambient:")
            ui.text("Road:")
            ui.text("Pressure:")
            ui.beginSubgroup(70)
            ui.offsetCursorY(-3 * ui.textLineHeightWithSpacing())
            ui.text(format(ac.getConditionsSet().temperatures["ambient"], "%d") .. " °C")
            ui.text(format(ac.getConditionsSet().temperatures["road"], "%d") .. " °C")
            ui.text(format(ac.getConditionsSet().pressure, "%0.2f") .. " Pa")
            ui.endGroup()
        end)
        drawnContentCount = drawnContentCount + 1
    end

    if config.wind then
        makeBlock(config.selectedLayout, 125, function()
            ui.setNextTextBold()
            ui.pushFont(ui.Font.Title)
            ui.text('Wind')
            ui.popFont()
            ui.text("Speed:")
            ui.text("Direction:")
            ui.beginSubgroup(70)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.text(format(ac.getSimState().windSpeedKmh, "%d") .. " km/h")
            ui.text(format(ac.getSimState().windDirectionDeg, "%d") .. " °N")
            ui.endGroup()
        end)
        drawnContentCount = drawnContentCount + 1
    end

    if config.track then
        makeBlock(config.selectedLayout, 130, function()
            ui.setNextTextBold()
            ui.pushFont(ui.Font.Title)
            ui.text('Track')
            ui.popFont()
            ui.text("Grip:")
            ui.text("Temp:")
            ui.beginSubgroup(60)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.progressBar(ac.getSimState().roadGrip, vec2(60, ui.textLineHeight()))
            ui.text(format(ac.getSimState().roadTemperature, "%0.2f") .. " °C")
            ui.endGroup()
        end)
        drawnContentCount = drawnContentCount + 1
    end

    if activeContentCount == 0 then
        ui.pushFont(ui.Font.Title)
        ui.image("icon.png", vec2(ui.fontSize(), ui.fontSize()))
        ui.setCursor(vec2(20 + ui.fontSize(), 3))
        ui.textColored("CJ Weather App - No Content Selected!")
        ui.popFont()
    end
end

function script.windowMain(dt)

    local activeContentCount = 0
    if config.weather then
        activeContentCount = activeContentCount + 1
    end
    if config.rain then
        activeContentCount = activeContentCount + 1
    end
    if config.temperature then
        activeContentCount = activeContentCount + 1
    end
    if config.wind then
        activeContentCount = activeContentCount + 1
    end
    if config.track then
        activeContentCount = activeContentCount + 1
    end

    ui.beginScale()
    drawMainUI(activeContentCount)
    ui.endScale(0.95 * config.scale)

    --if controller[1] ~= "pure" then
    --    ac.shutdownAssettoCorsa()
    --end

end

function script.windowSettings(dt)

    ui.beginTabBar("Settings")

    ui.tabItem("Visible Content", function()
        activeContentCount = 0
        if ui.checkbox("Weather", config.weather) then
            config.weather = not config.weather
            activeContentCount = activeContentCount + 1
        end
        if ui.checkbox("Rain", config.rain) then
            config.rain = not config.rain
            activeContentCount = activeContentCount + 1
        end
        if ui.checkbox("Temperature", config.temperature) then
            config.temperature = not config.temperature
            activeContentCount = activeContentCount + 1
        end
        if ui.checkbox("Wind", config.wind) then
            config.wind = not config.wind
            activeContentCount = activeContentCount + 1
        end
        if ui.checkbox("Track", config.track) then
            config.track = not config.track
            activeContentCount = activeContentCount + 1
        end
    end)
    ui.tabItem("Layout", function()
        local layoutValue, layoutChanged = ui.combo(" ", config.selectedLayout, ui.ComboFlags.None, { "Horizontal","Vertical" })
        if layoutChanged then
            config.selectedLayout = layoutValue
        end
        local value, changed = ui.slider("Size", config.scale, 0.1, 1, '%.1f', 1)
        if changed then
            config.scale = value
        end
    end)
    ui.tabItem("Text Color", function()
        ui.colorPicker(" ", config.textColor, ui.ColorPickerFlags.AlphaBar)
    end)
    ui.tabItem("Background Color", function()
        ui.colorPicker(" ", config.backgroundColor, ui.ColorPickerFlags.AlphaBar)
    end)

    ui.endTabBar()

end
