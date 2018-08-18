join_gamelocal dir = scriptPath()
package.path = package.path .. ";" .. dir .. '?.lua'

setImmersiveMode(true)
scriptDimension = 1440
Settings:setScriptDimension(true, scriptDimension)
Settings:setCompareDimension(true, scriptDimension)

scriptTime = Timer()
autoEndTime = 60 * 28

dialogInit()
addRadioGroup("delayTime", 1)
addRadioButton("1 secs", 1)
addRadioButton("3 secs", 3)
addRadioButton("5 secs", 5)
addSeparator()
addRadioGroup("roleSelected", 1)
addRadioButton("Host", 1)
addRadioButton("Join", 2)
addRadioButton("Solo", 3)
addSeparator()
addRadioGroup("repeatMode", 1)
addRadioButton("Once", 1)
addRadioButton("Repeat", 2)
addSeparator()
addRadioGroup("expectNum", 1)
addRadioButton("+1", 1)
addRadioButton("+2", 2)
addRadioButton("+3", 3)
addSeparator()
addEditNumber("strikeTiming", 0.5)
dialogShow("Menu")

action_interval = 3
role_host = false
role_join = true
role_solo = false
repeat_game = false
expect_group_num = 3

-- read input config
action_interval = delayTime

if roleSelected == 1 then
    role_host = true
    role_join = false
elseif roleSelected == 2 then
    role_host = false
    role_join = true
elseif roleSelected == 3 then
    role_host = false
    role_join = false
    role_solo = true
end

if repeatMode == 1 then
    repeat_game = false
else
    repeat_game = true
end

expect_group_num = expectNum

-- common
function checkEndTime()
    if scriptTime:check() > autoEndTime then
        -- auto end
        setMessage("auto end " .. convertTime(scriptTime:check()))
        if endToSmall then
            switchTo(getSmallCode())
            setMessage("auto end, switched " .. convertTime(scriptTime:check()))
        else
            setMessage("auto ended " .. convertTime(scriptTime:check()))
        end
        scriptExit()
    end
end

-- function
function strike_shot()
	p1 = Location(720, 1280)
    p2 = Location(p1:getX() - 300, p1:getY() - 300)

    setManualTouchParameter(100, 1)
    actionList = { {action = "touchDown", target = p1},
        {action = "wait", target = strikeTiming},
        {action = "touchMove", target = p2},
        {action = "touchUp", target = p2} }
    manualTouch(actionList)
end

function join_game()
    toast("join game")
    while true do
        if existsClick(Pattern("join_game.png"):similar(0.95), 1) then
            getLastMatch():highlight(1)
        elseif exists(Pattern("search_s.png"):similar(0.90), 1) then
            getLastMatch():highlight(1)
            longClick(getLastMatch(), 3)
        elseif exists(Pattern("search_again.png"):similar(0.78), 1) then
            getLastMatch():highlight(1)
            toast("join first group")
            click(Location(700, 830))
        elseif exists(Pattern("cannot_found_party.png"):similar(0.83), 1) then
            getLastMatch():highlight(1)
            longClick(Location(713, 1938), 3)
        end
        if existsClick(Pattern("fight.png"):similar(0.93), 1) then
            break
        end
        if exists("blue_menu.png", 1) then
            toast("already in game")
            break
        end
    end
end

function setup_game()
    toast("setup game")
    while true do
        usePreviousSnap(false)
        exists("button_ok.png", 1) -- force snap
        usePreviousSnap(true)
        if exists(Pattern("join_game.png"):similar(0.95), 1) then
            longClick(Location(710, 2010), 5)
        elseif exists(Pattern("game_list.png"):similar(0.98), 1) then
            click(Location(522, 1237))
        elseif existsClick(Pattern("multi_player.png"):similar(0.98), 1) then
            getLastMatch():highlight(1)
        elseif existsClick(Pattern("nearby_friend.png"):similar(0.98), 1) then
            getLastMatch():highlight(1)
        elseif existsClick(Pattern("fight.png"):similar(0.98), 1) then
            getLastMatch():highlight(1)
        elseif exists(Pattern("waiting_for_everybody.png"):similar(0.98), 1) then
            -- counting player number
            usePreviousSnap(false)
            exists("button_ok.png", 1) -- force snap
            counting_workaround = true
            while true do
                num_slot = findAllNoFindException("wait_for_join.png")
                group_num = 3 - #num_slot
                toast("find # " .. group_num)

                if group_num == 3 and counting_workaround then
                    toast("double check group num")
                    counting_workaround = false
                elseif group_num >= expect_group_num then
                    toast("ready to go")                    
                    while true do
                        click(Location(1022, 1975))
                        if exists(Pattern("final_confirm.png"):similar(0.98), 1) then
                            longClick(Location(440, 1493), 3)
                        end
                        if exists(Pattern("waiting_for_everybody.png"):similar(0.98), 1) then
                            toast("retry untill reily start")
                        else
                            toast("retry untill reily start")
                            usePreviousSnap(false)
                            return
                        end
                    end
                end
            end
        end
        if exists("blue_menu.png", 1) then
            toast("already in game")
            break
        end
    end
    usePreviousSnap(false)
end

function open_game()
    toast("open game")
    while true do
        usePreviousSnap(false)
        exists("button_ok.png", 1) -- force snap
        usePreviousSnap(true)
        if exists(Pattern("join_game.png"):similar(0.95), 1) then
            longClick(Location(710, 2010), 5)
        elseif exists(Pattern("game_list.png"):similar(0.98), 1) then
            click(Location(522, 1237))
        elseif existsClick(Pattern("single_player.png"):similar(0.98), 1) then
            getLastMatch():highlight(1)
        elseif existsClick(Pattern("fight.png"):similar(0.98), 1) then
            getLastMatch():highlight(1)
            usePreviousSnap(false)
            return
        end
        if exists("blue_menu.png", 1) then
            toast("already in game")
            break
        end
    end
    usePreviousSnap(false)
end

function close_game()
    retry = 10
    extra = false
    stop = false
    while true do
        usePreviousSnap(false)
        exists("button_ok.png", 1) -- hacking snap
        usePreviousSnap(true)
        if existsClick(Pattern("button_ok.png"):similar(0.98), 1) then
            toast("little hint")
        elseif existsClick(Pattern("reward.png"):similar(0.98), 1) then
            toast("get reward")
            longClick(getLastMatch(), 2)
        elseif existsClick(Pattern("special_reward.png"):similar(0.98), 1) then
            toast("get special reward")
            longClick(getLastMatch(), 2)
        elseif exists(Pattern("challenge.png"):similar(0.95), 1) then
            getLastMatch():highlight(1)
            longClick(getLastMatch(), 3)
            retry = -1  -- let script exit
            extra = true
        elseif existsClick(Pattern("score_bonus.png"):similar(0.98), 1) then
            toast("get bouns")
            longClick(getLastMatch(), 2)
        --elseif existsClick(Pattern("green_ok.png"):similar(0.95), 1) then
        --    toast("green ok")
        --    --retry = -1  -- let script exit
        elseif existsClick(Pattern("friendship.png"):similar(0.98), 1) then
            toast("friend status")
            getLastMatch():highlight(1)
            longClick(getLastMatch(), 2)
            click(Location(715, 2250))
            --retry = -1  -- let script exit
        elseif exists(Pattern("join_game.png"):similar(0.95), 1) then
            getLastMatch():highlight(1)
            retry = -1  -- let script exit
        else
            toast("detect nothing")
            --click(Location(1439, 1687))
            click(Location(10, 100))
            retry = retry - 1
        end
        if stop then
            toast("exit finishing")
            break
        end
        if retry < 0 then
            toast("exit finishing")
            break
        end
    end
    usePreviousSnap(false)
    return extra
end

function play_game()
    while true do
        strike_shot()
        wait(action_interval)

        if exists(Pattern("button_ok.png"):similar(0.98), 1) then
            toast("finishing")
            longClick(getLastMatch(), 3)
            break
        elseif exists(Pattern("join_game.png"):similar(0.95), 1) then
            getLastMatch():highlight(1)
            break
        end
    end
end

function start_game()
    toast("waiting for game start")
    while true do
        if exists("blue_menu.png", 1) then
            toast("game already start")
            break
        end
        --avoid screen timeout
        click(Location(10, 100))
    end
end

-- main
while true do
    if role_join then
        join_game()
    elseif role_host then
        setup_game()
    elseif role_solo then
        open_game()
    end

    while true do
        start_game()
        play_game()
        extra = close_game()
        if extra == false then
            break
        end
        -- in this case, nothing to do for whos role_join
        if role_host then
            setup_game()
        elseif role_join then
            join_game()
        end
    end

    if repeat_game == false then
        toast("already once, exit")
        scriptExit()
    end

    checkEndTime()
end
