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

layoutAvailable = { "Vertical", "Horizontal" }

local config = ac.storage {
    headline = true,
    weather = true,
    rain = true,
    temperature = true,
    wind = true,
    track = true,
    selectedLayout = 2
}

function script.windowMain(dt)

    start_y = ui.getCursorY()

    function makeBlock(layout, contentWidth, content)
        ui.beginGroup()
        content()
        ui.beginGroup()

        if layout == 1 then
            local xy = ui.getCursor()
            ui.drawLine(xy, vec2(xy.x + ui.availableSpaceX(), xy.y), rgbm(5, 5, 5, 0.5), 1)
            ui.offsetCursorY(10)
        end

        if layout == 2 then
            ui.setCursorY(start_y)
            ui.offsetCursorX(contentWidth)
            local xy = ui.getCursor()
            ui.drawLine(xy, vec2(xy.x, xy.y + ui.availableSpaceY()), rgbm(5, 5, 5, 0.5), 1)
            ui.offsetCursorX(10)
        end

    end

    if config.weather then

        makeBlock(config.selectedLayout, 200, function()
            ui.header('Weather')
            ui.text("Current:")
            ui.text("Upcoming:")
            ui.text("Transition:")
            ui.beginSubgroup(75)
            ui.offsetCursorY(-3 * ui.textLineHeightWithSpacing())
            ui.text(getWeatherName(ac.getConditionsSet().currentType))
            ui.text(getWeatherName(ac.getConditionsSet().upcomingType))
            ui.progressBar(ac.getConditionsSet().transition, vec2(60, ui.textLineHeight()))
            ui.endGroup()
        end)
    end

    if config.rain then
        makeBlock(config.selectedLayout, 140, function()
            ui.header('Rain')
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

    end

    if config.temperature then
        makeBlock(config.selectedLayout, 125, function()
            ui.header('Temperature')
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

    end

    if config.wind then
        makeBlock(config.selectedLayout, 125, function()
            ui.header('Wind')
            ui.text("Speed:")
            ui.text("Direction:")
            ui.beginSubgroup(70)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.text(format(ac.getSimState().windSpeedKmh, "%d") .. " km/h")
            ui.text(format(ac.getSimState().windDirectionDeg, "%d") .. " °N")
            ui.endGroup()
        end)
    end

    if config.track then
        makeBlock(config.selectedLayout, 130, function()
            ui.header('Track')
            ui.text("Grip:")
            ui.text("Temp:")
            ui.beginSubgroup(60)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.progressBar(ac.getSimState().roadGrip, vec2(60, ui.textLineHeight()))
            ui.text(format(ac.getSimState().roadTemperature, "%0.2f") .. " °C")
            ui.endGroup()
        end, true)
    end


end

function script.windowSettings(dt)

    local value, changed = ui.combo("", config.selectedLayout, ui.ComboFlags.None, layoutAvailable)
    if changed then
        config.selectedLayout = value
    end
    if ui.checkbox("Weather", config.weather) then
        config.weather = not config.weather
    end
    if ui.checkbox("Rain", config.rain) then
        config.rain = not config.rain
    end
    if ui.checkbox("Temperature", config.temperature) then
        config.temperature = not config.temperature
    end
    if ui.checkbox("Wind", config.wind) then
        config.wind = not config.wind
    end
    if ui.checkbox("Track", config.track) then
        config.track = not config.track
    end
end
