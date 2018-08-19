--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 17/8/2018
-- Time: 22:27
-- To change this template use File | Settings | File Templates.
--
setImmersiveMode(true)
scriptDimension = 1280
Settings:setScriptDimension(true, scriptDimension)
Settings:setCompareDimension(true, scriptDimension)

scriptTime = Timer()
noOfGamesFinished = 0

stage =  230
gameMode = 30

dialogInit()
-- Dialog for select Stage
addRadioGroup("stage", 1)
addRadioButton("Stage 2 - 30 stma", 230)
addRadioButton("Stage 2 - 45 stma", 245)
addRadioButton("Stage 1 - 60 stma", 160)

--[[
-- Dialog for select Game Mode
addSeparator()
addRadioGroup("gameMode", 1)
addRadioButton("Create Myself", 10)
addRadioButton("Create Guild", 20)
addRadioButton("Join Guild", 21)
addRadioButton("Create Public", 30)
addRadioButton("Join Public", 31)
--]]

dialogShow("Menu")

-- Set Stage picture
stage_pic = "event-row2-text.png"
if stage==230 then
  stage_pic  = "stage-2-2.png"
elseif stage==245 then
  stage_pic =   "event-row2-text.png"
elseif stage==160 then
    stage_pic =   "event-row1-text.png"
end

--handle error
function handleError()
    -- ToDo: handle comm error, dismiss
    toast("Handle Error")

    -- handle disconnected, retry it
    if existsClick(Pattern("reconnect.png"):similar(0.90), 5) then
        toast ("Ooh, no connection")
        -- retry 3 times
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)

        -- start from home
        existsClick(Pattern("normal-game.png"):similar(0.90), 20)
        existsClick(Pattern("join-event.png"):similar(0.90), 20)
        existsClick(Pattern("18summer-event.png"):similar(0.90), 20)
        return
    end

    -- handle dismiss
    if exists(Pattern("dismissed-text.png"):similar(0.90), 5) then
        toast ("Ooh, dismissed")
        existsClick(Pattern("ok-button.png"):similar(0.90), 20)
        existsClick(Pattern("confirm-join.png"):similar(0.90), 20)
        return
    end

    --public game comm error
end

function find_daily_event()
    -- Src: Right hand side point
    p1 = Location(1120, 335)
    -- Destination: Left hand side point
    p2 = Location(p1:getX() - 300, p1:getY() - 300)

    setManualTouchParameter(100, 1)
    actionList = { {action = "touchDown", target = p1},
        {action = "wait", target = strikeTiming},
        {action = "touchMove", target = p2},
        {action = "touchUp", target = p2} }
    manualTouch(actionList)
end

function joinFromHome()
    toast("Select Normal Game")
    if existsClick(Pattern("normal-game.png"):similar(0.90), 50) then
        toast("Select Event Game")
        if existsClick(Pattern("join-event.png"):similar(0.90), 50) then
            toast("Select 18 Summer Event")
            if existsClick(Pattern("18summer-event.png"):similar(0.90), 50) then
                toast("Loop game now")

                recurringJoin();
            end
        end
    end
end

-- To-Do: To be implemeted
function start_game_with_joiner()
    -- To-Do: To implement
end

-- To-Do: To be implemeted
function wait_joiner()
    toast("waiting for joiner")
    while true do
        -- To-Do: To implement menu selection later
        if exists(joiners_pic, 1) then
            toast("Enough Joiner")
            break
        end
        --avoid screen timeout
        --click(Location(10, 100))
        start_game_with_joiner()
    end
end

function recurringJoin()
    while(true) do
        toast("Select Stage: " .. stage)
        if existsClick(Pattern(stage_pic):similar(0.95), 50) then
            toast("Start Stage")
            if existsClick(Pattern("ready-button.png"):similar(0.90), 50) then
                toast("Select Join Public Game")
                if existsClick(Pattern("join-public.png"):similar(0.90), 50) then
                    wait(5)
                    toast("Select Team")
                    -- To-Do: Implement select team function
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 30) then
                        t = Timer()
                        --wait for game end
                        while(true) do
                            -- To-Do: Long waiting time to restart the game

                            toast("Wait completion - # of games finished:" .. noOfGamesFinished .. " wait time: " .. t:check())
                            -- Check for the complete match screen
                            if exists(Pattern("complete-match-text.png"):similar(0.90), 30) then
                                toast("Click through all screens")
                                while(true) do
                                    if(existsClick(Pattern("finish-match.png"):similar(0.90), 3)) then
                                        noOfGamesFinished = noOfGamesFinished + 1
                                        break;
                                    else
                                        toast("Click ...")
                                        click(getLastMatch())
                                    end
                                end

                                noOfGamesFinished = noOfGamesFinished + 1

                               -- wait long enough for the game menu
                                wait(20)
                                break;
                            end

                            -- check error and handle for next game
                            handleError()
                        end
                end
            end
        end
     end
    end
end

-- main
joinFromHome()
scriptExit("End: " + noOfGamesFinished)
