#!/usr/bin/env fish

set display    "eDP-1"
set state_file "/tmp/.color_cal_active"
set shader     "$HOME/.config/hypr/shaders/color_calibration.glsl"
set log        "$HOME/.color_calibration.log"

function apply_cal
    hyprctl eval 'hl.config({ decoration = { screen_shader = "'"$shader"'" } })'
    wlr-randr --output $display --brightness 0.96
    touch $state_file
    notify-send "🎨 Calibration ON" "Warm profile active"
    echo (date)" — ON" >> $log
end

function remove_cal
    hyprctl eval 'hl.config({ decoration = { screen_shader = "" } })'
    wlr-randr --output $display --brightness 1.0
    rm -f $state_file
    notify-send "🖥️ Calibration OFF" "Reset to default"
    echo (date)" — OFF" >> $log
end

if test -f $state_file
    remove_cal
else
    apply_cal
end
