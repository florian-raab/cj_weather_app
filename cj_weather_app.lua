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

settings = {
    headline = true,
    weather = true,
    rain = true,
    temperature = true,
    wind = true,
    track = true,
    layout = {
        available = { "Vertical", "Horizontal" },
        selected = 2
    }
}
function script.windowMain(dt)

    start_y = ui.getCursorY()

    function makeBlock(layout, contentWidth, content, last)
        ui.beginGroup()
        content()
        ui.beginGroup()

        if layout == 1 and not last then
            local xy = ui.getCursor()
            ui.drawLine(xy, vec2(xy.x+ui.availableSpaceX(), xy.y), rgbm(5,5,5, 0.5),1)
            ui.offsetCursorY(15)
        end

        if layout == 2 and not last then
            ui.setCursorY(start_y)
            ui.offsetCursorX(contentWidth)
            local xy = ui.getCursor()
            ui.drawLine(xy, vec2(xy.x, xy.y+ui.availableSpaceY()) , rgbm(5,5,5, 0.5),1)
            ui.offsetCursorX(15)
        end

    end

    if settings.weather then

        makeBlock(settings.layout.selected, 220, function()
            ui.header('Weather')
            ui.text("Current:")
            ui.text("Upcoming:")
            ui.text("Transition:")
            ui.beginSubgroup(85)
            ui.offsetCursorY(-3 * ui.textLineHeightWithSpacing())
            ui.text(getWeatherName(ac.getConditionsSet().currentType))
            ui.text(getWeatherName(ac.getConditionsSet().upcomingType))
            ui.progressBar(ac.getConditionsSet().transition, vec2(60, ui.textLineHeight()))
            ui.endGroup()
        end)
    end

    if settings.rain then
        makeBlock(settings.layout.selected, 160, function()
            ui.header('Rain')
            ui.text("Intensity:")
            ui.text("Wetness:")
            ui.text("Water:")
            ui.text("Humidity:")
            ui.beginSubgroup(85)
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

    if settings.temperature then
        makeBlock(settings.layout.selected, 160, function()
            ui.header('Temperature')
            ui.text("Ambient:")
            ui.text("Road:")
            ui.text("Pressure:")
            ui.beginSubgroup(85)
            ui.offsetCursorY(-3 * ui.textLineHeightWithSpacing())
            ui.text(format(ac.getConditionsSet().temperatures["ambient"], "%d") .. " °C")
            ui.text(format(ac.getConditionsSet().temperatures["road"], "%d") .. " °C")
            ui.text(format(ac.getConditionsSet().pressure, "%0.2f") .. " Pa")
            ui.endGroup()
        end)

    end

    if settings.wind then
        makeBlock(settings.layout.selected, 160, function()
            ui.header('Wind')
            ui.text("Speed:")
            ui.text("Direction:")
            ui.beginSubgroup(85)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.text(format(ac.getSimState().windSpeedKmh, "%d") .. " km/h")
            ui.text(format(ac.getSimState().windDirectionDeg, "%d") .. " °N")
            ui.endGroup()
        end)
    end

    if settings.track then
        makeBlock(settings.layout.selected, 160, function()
            ui.header('Track')
            ui.text("Grip:")
            ui.text("Temperature:")
            ui.beginSubgroup(85)
            ui.offsetCursorY(-2 * ui.textLineHeightWithSpacing())
            ui.progressBar(ac.getSimState().roadGrip, vec2(60, ui.textLineHeight()))
            ui.text(format(ac.getSimState().roadTemperature, "%0.2f") .. " °C")
            ui.endGroup()
        end, true)
    end




end


function script.windowSettings(dt)

    local value, changed = ui.combo("", settings.layout.selected, ui.ComboFlags.None, settings.layout.available)
    if changed then
        settings.layout.selected = value
    end
    if ui.checkbox("Weather", settings.weather) then
        settings.weather = not settings.weather
    end
    if ui.checkbox("Rain", settings.rain) then
        settings.rain = not settings.rain
    end
    if ui.checkbox("Temperature", settings.temperature) then
        settings.temperature = not settings.temperature
    end
    if ui.checkbox("Wind", settings.wind) then
        settings.wind = not settings.wind
    end
    if ui.checkbox("Track", settings.track) then
        settings.track = not settings.track
    end
end
