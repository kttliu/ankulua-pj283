--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 24/8/2018
-- Time: 21:36
-- To change this template use File | Settings | File Templates.
--

local mod_sell =  {}

local region_item_full_dialog_buttons = Region(365,372,548,180)
local region_sell_screen_buttons = Region(0,588,1265,132)
local region_center = Region(379,319,504,269)

function mod_sell.check()
    if region_item_full_dialog_buttons:existsClick(Pattern("mod_sell/button-sell.png"):similar(0.90),0) then
        handle()
        return true
    end
    return false
end

function handle()
    usePreviousSnap(false)
    region_sell_screen_buttons:existsClick(Pattern("mod_sell/button_bulk_sell.png"):similar(0.90),30)
    region_sell_screen_buttons:existsClick(Pattern("mod_sell/button_confirm.png"):similar(0.90),30)
    region_sell_screen_buttons:existsClick(Pattern("mod_sell/button_confirm_sell.png"):similar(0.90),30)
    region_center:existsClick(Pattern("mod_sell/button_ok.png"):similar(0.90),30)
    region_sell_screen_buttons:existsClick(Pattern("mod_sell/button_back.png"):similar(0.90),30)
end

return mod_sell