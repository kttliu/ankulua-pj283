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
attackMode = 0
gameMode = 21

dialogInit()
-- Dialog for select Stage
addRadioGroup("stage", 230)
addRadioButton("Stage 2 - 30 stma", 230)
addRadioButton("Stage 2 - 45 stma", 245)
addRadioButton("Stage 1 - 60 stma", 160)

-- Dialog for select Game Mode
addSeparator()
addRadioGroup("gameMode", 21)
addRadioButton("Join Guild", 21)
--addRadioButton("Create Myself", 10)
--addRadioButton("Create Guild", 20)
--addRadioButton("Create Public", 30)
addRadioButton("Join Public", 31)

-- Set Attack Mode or Not
addSeparator()
addRadioGroup("attackMode", 1)
addRadioButton("No Change", 0)
addRadioButton("Attack", 1)



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

function createlogfile()
    local now = os.time()
    local now_str = os.date("%c", now)

    local fileName = scriptPath() .. "log.txt"
    file = io.open(fileName, "w")
    file:write("LOG Start: " .. now_str, "\n")
end

function log(msg)
    toast(msg)

    local now = os.time()
    local now_str = os.date("%c", now)
    file:write(now_str .. " : " .. msg, "\n")
end

--handle error
function handleError()
    -- Prevent cap screen again for error checking
    usePreviousSnap(true)

    -- ToDo: handle comm error, dismiss
    if existsClick(Pattern("reconnect.png"):similar(0.90), 1) then
        usePreviousSnap(false)
        -- handle disconnected, retry it
        log ("Ooh, no connection")
        -- retry 3 times
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)

        -- start from home
        if gameMode==21 then
            joinFromHome_JoinGuild()
        elseif gameMode==31 then
            joinFromHome()
        end
    elseif exists(Pattern("dismissed-text.png"):similar(0.90), 1) then
        usePreviousSnap(false)
        -- handle dismiss
        log ("Ooh, dismissed")
        existsClick(Pattern("ok-button.png"):similar(0.90), 20)
        existsClick(Pattern("confirm-join.png"):similar(0.90), 20)
     elseif  exists(Pattern("too-many-joiner.png"):similar(0.90), 1) then
        log ("Ooh, too many joiners")
        existsClick(Pattern("ok-button.png"):similar(0.90), 20)
     end
    --public game comm error

   -- Enable screen cap
    usePreviousSnap(false)
end

function find_daily_event()
    -- Src: Right hand side point
    local p1 = Location(1120, 335)
    -- Destination: Left hand side point
    local p2 = Location(p1:getX() - 300, p1:getY() - 300)

    setManualTouchParameter(100, 1)
    local actionList = { {action = "touchDown", target = p1},
        {action = "wait", target = strikeTiming},
        {action = "touchMove", target = p2},
        {action = "touchUp", target = p2} }
    manualTouch(actionList)
end

function joinFromHome()
    log("Select Normal Game")
    if existsClick(Pattern("normal-game.png"):similar(0.90), 50) then
        log("Select Event Game")
        if existsClick(Pattern("join-event.png"):similar(0.90), 50) then
            log("Select 18 Summer Event")
            if existsClick(Pattern("18summer-event.png"):similar(0.90), 50) then
                log("Loop game now")
            end
        end
    end
end

function joinFromHome_JoinGuild()
    log("Select Normal Game")
    existsClick(Pattern("normal-game.png"):similar(0.90), 50)
end

function setAttackMode()
    if(attackMode==1) then
        if existsClick(Pattern("attack-mode-button.png"):similar(0.95), 1) then
            log("Change to Attack Mode")
        end
    end
end

--[[
-- To-Do: To be implemeted
function start_game_with_joiner()
    -- To-Do: To implement
end

-- To-Do: To be implemeted
function wait_joiner()
    log("waiting for joiner")
    while true do
        -- To-Do: To implement menu selection later
        if exists(joiners_pic, 1) then
            log("Enough Joiner")
            break
        end
        --avoid screen timeout
        --click(Location(10, 100))
        start_game_with_joiner()
    end
end

function shootIfGetBallInFrontArea()
    local imageToSearch_Ball = "in-game-ball.png"
    local imageToSearch_Shoot = "shoot-button.png"

    local front_field_area = Region(647,62,1272,708)

    if (front_field_area : exists(Pattern(imageToSearch_Ball):similar(0.85), 2)) then
        usePreviousSnap(true)
        log("Found ball in the front")
        front_field_area : existsClick(Pattern(imageToSearch_Shoot):similar(0.95), 1)
        log("Shoot!!!")
    end
    usePreviousSnap(false)
end
--]]

function recurringJoin()
    while(true) do
        log("Select Stage: " .. stage)
        if existsClick(Pattern(stage_pic):similar(0.90), 30) then
            log("Start Stage")
            if existsClick(Pattern("ready-button.png"):similar(0.90), 40) then
                log("Select Join Public Game")
                if existsClick(Pattern("join-public.png"):similar(0.90), 40) then
                    wait(5)
                    log("Select Team")
                    -- To-Do: Implement select team function
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 30) then
                        t = Timer()
                        --wait for game end
                        while(true) do
                            -- To-Do: Long waiting time to restart the game

                            log("# of games finished:" .. noOfGamesFinished .. " wait time: " .. t:check())
                            -- Check game started

                           -- Shoot in the front
                           -- shootIfGetBallInFrontArea()

                           -- Set Attack Mode
                           setAttackMode()

                            -- Check for the complete match screen
                            if exists(Pattern("complete-match-text.png"):similar(0.90), 1) then
                                log("Click through all screens")
                                while(true) do
                                    if(existsClick(Pattern("finish-match.png"):similar(0.90), 1)) then
                                        noOfGamesFinished = noOfGamesFinished + 1
                                        break;
                                    else
                                        log("Click ...")
                                        click(getLastMatch())
                                    end
                                end

                                noOfGamesFinished = noOfGamesFinished + 1

                               -- wait long enough for the game menu
                               log("Completing game and wait for stage menu")
                                wait(20)
                                break;
                            end

                            -- check error, handle for next game, if any
                            handleError()
                        end
                end
            end
        end
     end
    end
end

function recurringJoinGuild()
        while(true) do
                existsClick(Pattern("join-guild-game.png"):similar(0.90), 1)

                log("Waiting Guild Game")
                if existsClick(Pattern("game-join-event-text.png"):similar(0.90), 1) then
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 30) then
                        t = Timer()
                        --wait for game end
                        while(true) do
                            -- To-Do: Long waiting time to restart the game

                            log("# of games finished:" .. noOfGamesFinished .. " wait time: " .. t:check())
                            -- Check game started

                            -- Shoot in the front
                            -- shootIfGetBallInFrontArea()

                            -- Set Attack Mode
                            setAttackMode()

                            -- Check for the complete match screen
                            if exists(Pattern("complete-match-text.png"):similar(0.90), 1) then
                                log("Click through all screens")
                                while(true) do
                                    if(existsClick(Pattern("finish-match.png"):similar(0.90), 1)) then
                                        noOfGamesFinished = noOfGamesFinished + 1
                                        break;
                                    else
                                        log("Click ...")
                                        click(getLastMatch())
                                    end
                                end

                                noOfGamesFinished = noOfGamesFinished + 1

                                -- wait long enough for the game menu
                                log("Completing game and wait for stage menu")
                                wait(10)
                                break;
                            end

                            -- check error, handle for next game, if any
                            handleError()
                        end
                    end
                end
                handleError()
        end
end

-- main
createlogfile()
if gameMode==21 then
    joinFromHome_JoinGuild()
    wait(5)
    recurringJoinGuild()
elseif gameMode==31 then
    joinFromHome()
    recurringJoin();
end
scriptExit("End: " + noOfGamesFinished)
