require("graphics")
require("state")

local graphics = Graphics.new()
local state = State.new()

local image_data_sent = false
local audio_data_sent = false
local last_exposure_time = 0

MESSAGE_START_FLAG = "\x10"
MESSAGE_TEXT_FLAG = "\x11"
MESSAGE_AUDIO_FLAG = "\x12"
MESSAGE_IMAGE_FLAG = "\x13"
MESSAGE_END_FLAG = "\x16"

function bluetooth_callback(message)
    if string.sub(message, 1, 1) == MESSAGE_START_FLAG then
        graphics:clear()
    elseif string.sub(message, 1, 1) == MESSAGE_TEXT_FLAG then
        if state:is("WAIT") then
            graphics:clear()
            state:switch("SHOW")
        end
        if state:is("SHOW") then
            graphics:append_text(string.sub(message, 2))
        end
    end
end

function send_data(data)
    while true do
        if pcall(frame.bluetooth.send, data) then
            break
        end
    end
end

frame.bluetooth.receive_callback(bluetooth_callback)

while true do
    if state:is("START") then
        state:on_entry(function()
            graphics:clear()
            graphics:append_text("Noa: \"Standing by! Tap and ask me anything\"")
        end)
        state:switch_on_tap("LISTEN")
        state:switch_after(30, "SLEEP")
    elseif state:is("LISTEN") then
        state:on_entry(function()
            frame.camera.capture()
            graphics:clear()
            graphics:append_text("Noa: *Listening*")
            frame.microphone.record(10, 8000, 8) -- TODO switch to improved API: frame.microphone.record()
            send_data(MESSAGE_START_FLAG)
            image_data_sent = false
            audio_data_sent = false
        end)

        if state:has_been() > 1.2 and image_data_sent == false then
            while true do
                local image_data = frame.camera.read(frame.bluetooth.max_length() - 1)
                if (image_data == nil) then
                    break
                end
                send_data(MESSAGE_IMAGE_FLAG .. image_data)
            end
            image_data_sent = true
        end

        local audio_data = frame.microphone.read(
            math.floor((frame.bluetooth.max_length() - 1) / 4) * 4
        )
        if audio_data ~= nil then
            send_data(MESSAGE_AUDIO_FLAG .. audio_data)
        end

        if state:has_been() > 2 then
            state:switch_on_tap("WAIT")
            state:switch_on_double_tap("SLEEP")
        end
        state:switch_after(10, "WAIT")
    elseif state:is("WAIT") then
        state:on_entry(function()
            frame.microphone.stop()
            graphics:clear()
            graphics:append_text("Noa: \"I'm on it...\"")
        end)
        if state:has_been() > 1.4 and audio_data_sent == false then
            while true do
                local audio_data = frame.microphone.read(
                    math.floor((frame.bluetooth.max_length() - 1) / 4) * 4
                )
                if (audio_data == nil) then
                    break
                end
                send_data(MESSAGE_AUDIO_FLAG .. audio_data)
            end
            audio_data_sent = true
            send_data(MESSAGE_END_FLAG)
        end
        state:switch_on_tap("LISTEN")
        state:switch_on_double_tap("SLEEP")
    elseif state:is("SHOW") then
        graphics:on_complete(function()
            state:switch("HOLD")
        end)
        state:switch_on_tap("LISTEN")
        state:switch_on_double_tap("SLEEP")
    elseif state:is("HOLD") then
        state:switch_on_tap("LISTEN")
        state:switch_on_double_tap("SLEEP")
    elseif state:is("SLEEP") then
        state:on_entry(function()
            frame.sleep()
        end)
    end

    graphics:print_text()

    if (frame.time.utc() - last_exposure_time) > 0.033 then
        frame.camera.auto()
        last_exposure_time = frame.time.utc()
    end

    collectgarbage("collect")
end
