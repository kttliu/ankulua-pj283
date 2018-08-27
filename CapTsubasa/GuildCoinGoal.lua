--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 16/8/2018
-- Time: 22:59
-- To change this template use File | Settings | File Templates.
--


setImmersiveMode(true)
scriptDimension = 1280
Settings:setScriptDimension(true, scriptDimension)
Settings:setCompareDimension(true, scriptDimension)

scriptTime = Timer()

-- kick guild coin goal
function guild_coin_goal()
    toast("guild_coin_goal")
    if existsClick(Pattern("guild.png"):similar(0.95), 10) then
        click(getLastMatch())

        if existsClick(Pattern("guild-kick-button.png"):similar(0.95), 10) then
            --click(getLastMatch())
        end

        toast("Loop")
        while (true) do
            check_pocket_full()

            toast("find kick screen")
            if existsClick(Pattern("guild-kick-screen-text.png"):similar(0.95), 10) then
                toast("guild-kick-screen ready")
                click(getLastMatch())
                if existsClick(Pattern("guild-kick-5th-word.png"):similar(0.95), 10) then
                    toast("select 5 ")
                    --click(getLastMatch())
                    if existsClick(Pattern("guild-kick-ok-button.png"):similar(0.90), 10) then
                        --click(getLastMatch())
                        toast("Finding kick again button ")
                        if existsClick(Pattern("guild-kick-again-button.png"):similar(0.75), 10) then
                            --click(getLastMatch())
                            wait(2)
                        end
                    end
                end
            end
        end
    end
end

-- quick auto sell
function quick_auto_sell()
    toast("quick_auto_sell")
    if existsClick(Pattern("player.png"):similar(0.95), 5) then
        --click(getLastMatch())
        if existsClick(Pattern("improve-skill.png"):similar(0.95), 5) then
            --slide
            if existsClick(Pattern("sell.png"):similar(0.95), 5) then
                --click(getLastMatch())
                if existsClick(Pattern("bulk-sell.png"):similar(0.95), 5) then
                    --click(getLastMatch())
                    if existsClick(Pattern("confirm-button.png"):similar(0.95), 5) then
                        --click(getLastMatch())
                        if existsClick(Pattern("re-confirm-sell.png"):similar(0.95), 5) then
                            --click(getLastMatch())
                        end
                    else
                        -- nothing to sell, go home
                        if existsClick(Pattern("home.png"):similar(0.95), 5) then
                            --click(getLastMatch())
                        end
                    end
                end
            end
        end
    end
end

-- bulk_sell
function bulk_sell()
    toast("bulk_sell")
    if existsClick(Pattern("button-bulk-sell.png"):similar(0.90), 15) then
        --click(getLastMatch())
        if existsClick(Pattern("sell-confirm-button.png"):similar(0.90), 10) then
            click(getLastMatch())
            if existsClick(Pattern("re-confirm-sell.png"):similar(0.90), 15) then
                --click(getLastMatch())
                if existsClick(Pattern("ok-button.png"):similar(0.90), 15) then
                    --click(getLastMatch())
                    if existsClick(Pattern("button-back.png"):similar(0.90), 15) then
                        --click(getLastMatch())
                    end
                end
            end
        end
    end
    toast("bulk_sell - END")
end

function check_pocket_full()
    toast("Check pocket full")
    if existsClick(Pattern("sell-button.png"):similar(0.80), 10) then
        toast("pocket full")
        bulk_sell();

        if existsClick(Pattern("guild.png"):similar(0.95), 10) then
            click(getLastMatch())
            if existsClick(Pattern("guild-kick-button.png"):similar(0.95), 10) then
                click(getLastMatch())
            end
        end
    end
end

-- main
guild_coin_goal()
