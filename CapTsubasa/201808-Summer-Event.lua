--
--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 17/8/2018
-- Time: 22:27
-- To change this template use File | Settings | File Templates.
--

-- Load logger module
logger =  require(scriptPath().."module/mod_logger")
modsell=  require(scriptPath().."module/mod_sell")

-- Global Paramaeters
setImmersiveMode(true)
scriptDimension = 1280
Settings:setCompareDimension(true, scriptDimension)
Settings:setScriptDimension(true, scriptDimension)

screenSize = getRealScreenSize()
screenSizeWidth = screenSize:getX() -- the width of device real screen
screenSizeHeight = screenSize:getY() -- the height of device real screen

regionUpperHalf = Region(0, 0, screenSizeWidth,screenSizeHeight/2)
regionLowerHalf=Region(0, screenSizeHeight/2, screenSizeWidth,screenSizeHeight/2)
regionLeftHalf=Region(0, 0, screenSizeWidth/2,screenSizeHeight)
regionRightHalf=Region(screenSizeWidth/2, 0, screenSizeWidth/2,screenSizeHeight)
regionInGameAttackModeButtons = Region(0,screenSizeHeight*7/8,screenSizeWidth/2,screenSizeHeight/8)
regionGuildGameShowArea = Region(207,76,1035,552)
regionCenter = Region(208,24,862,693)
regionErrorDialog = Region(266,133,742,444)

scriptTime = Timer()
noOfGamesFinished = 0

selected_verbose = "0 - NONE"
stage =  230
gameMode = 30
attackMode = 0
gameMode = 21
selected_guild_event = ""
joinFromHomeSwitch=true
debugMode=false

--- Display menu
function mainMenu()
    dialogInit()
    -- Dialog for select Game Mode
    addRadioGroup("gameMode", 21)
    addRadioButton("Join Guild", 21)
    --addRadioButton("Create Myself", 10)
    --addRadioButton("Create Guild", 20)
    --addRadioButton("Create Public", 30)
    addRadioButton("Join Public", 31)
    addSeparator()

    addCheckBox("debugMode", "Enable Log", false)
    addCheckBox("attackModeBoolean", "Attack!", false)
    addCheckBox("joinFromHomeSwitch","Join From Home", true)

    addSeparator()
    local spinnerItems = {"0 - NONE", "1 - INFO", "2 - DEBUG", "3 - TRACE" }
    addTextView("Verbose:  ")
    addSpinner("selected_verbose", spinnerItems, "0 - NONE")

    dialogShow("Menu")
end

function menu_join_public_game()
    if gameMode==31 then
        dialogInit()
        -- Dialog for select Stage
        addRadioGroup("stage", 230)
        addRadioButton("Stage 2 - 30 stma", 230)
        addRadioButton("Stage 2 - 45 stma", 245)
        addRadioButton("Stage 1 - 60 stma", 160)

        dialogShow("Menu")
    end
end

function menu_join_guild_game()
    if gameMode==21 then
        dialogInit()
        -- Guild Game - Event to join
        local spinnerItems = {"0000 - Any", "0001 - 2018 Summer Event"}
        addTextView("Guild Event To Join:  ")
        addSpinner("selected_guild_event", spinnerItems, "0000 - Any")

        dialogShow("Menu")
    end
end

mainMenu()
menu_join_public_game()
menu_join_guild_game()

if attackModeBoolean then
    attackMode = 1
else
    attackMode = 0
end

logger.set(string.sub(selected_verbose,1,2) + 0)

----- End Menu Processing


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
    -- Prevent cap screen again for error checking
    --exists(Pattern("dummy.png"):similar(0.90),0)
    usePreviousSnap(false)
    snapshot()
    logger.debug("Handle error")
    if regionErrorDialog:exists(Pattern("dismissed-text.png"):similar(0.90),0) then
        -- handle dismiss
        logger.info ("Ooh, dismissed")

        regionCenter:existsClick(Pattern("ok-button.png"):similar(0.90), 30)
        usePreviousSnap(false)
        regionLowerHalf:existsClick(Pattern("confirm-join.png"):similar(0.90), 30)
        return true;
    -- ToDo: handle comm error, dismiss
    elseif regionErrorDialog:existsClick(Pattern("reconnect.png"):similar(0.90),0) then
        usePreviousSnap(false)
        -- handle disconnected, retry it
        logger.info ("Ooh, no connection")
        -- retry 3 times
        regionErrorDialogexistsClick(Pattern("reconnect.png"):similar(0.90), 10)
        regionErrorDialogexistsClick(Pattern("reconnect.png"):similar(0.90), 10)

        -- start from home
        if gameMode==21 then
            joinFromHome_JoinGuild()
        elseif gameMode==31 then
            joinFromHome()
        end
        return true;
--[[
     elseif  regionCenter:exists(Pattern("too-many-joiner.png"):similar(0.90), 0) then
        log ("Ooh, too many joiners")
        existsClick(Pattern("ok-button.png"):similar(0.90), 30)
        return true;
    elseif  regionCenter:exists(Pattern("room-disappear-text.png"):similar(0.90), 0) then
        log ("Ooh, room disappeared")
        existsClick(Pattern("ok-button.png"):similar(0.90), 20)
        return true;
--]]
    elseif  regionErrorDialog:existsClick(Pattern("ok-button.png"):similar(0.90), 0) then
        return true;
    end

    -- handle item full
    modsell.check()

    --public game comm error

   -- Enable screen cap
    usePreviousSnap(false)
    return false;
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
    logger.debug("Select Normal Game")
    if existsClick(Pattern("normal-game.png"):similar(0.90), 50) then
        logger.debug("Select Event Game")
        if existsClick(Pattern("join-event.png"):similar(0.90), 50) then
            logger.debug("Select 18 Summer Event")
            if existsClick(Pattern("18summer-event.png"):similar(0.90), 50) then
                logger.debug("Loop game now")
            end
        end
    end
end

function joinFromHome_JoinGuild()
    logger.info("Select Normal Game")
    regionRightHalf:existsClick(Pattern("normal-game.png"):similar(0.90), 50)
end

-- Set to attack mode
-- param: flag  to indicate if last attemp is sucessful
-- return true if cannot deteled (i.e. Attack button is ON); otherwise false
function setAttackMode(isAttacking)
    if(attackMode==1 and isAttacking==false) then
        if regionInGameAttackModeButtons:existsClick(Pattern("attack-mode-button.png"):similar(0.95),0) then
            logger.info ("Changing to Attack Mode")
            return false
        end
        return true
    end
end

--[[
-- To-Do: To be implemeted
function start_game_with_joiner()
    -- To-Do: To implement
end

-- To-Do: To be implemeted
function wait_joiner()
    logger.debug("waiting for joiner")
    while true do
        -- To-Do: To implement menu selection later
        if exists(joiners_pic, 1) then
            logger.debug("Enough Joiner")
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
        logger.debug("Found ball in the front")
        front_field_area : existsClick(Pattern(imageToSearch_Shoot):similar(0.95), 1)
        logger.debug("Shoot!!!")
    end
    usePreviousSnap(false)
end
--]]

function recurringJoin()
    while(true) do
        logger.info("Select Stage: " .. stage)
        if existsClick(Pattern(stage_pic):similar(0.90), 30) then
            logger.info("Start Stage")
            if existsClick(Pattern("ready-button.png"):similar(0.90), 40) then
                logger.info("Select Join Public Game")
                if existsClick(Pattern("join-public.png"):similar(0.90), 40) then
                    wait(5)
                    logger.info("Select Team")
                    -- To-Do: Implement select team function
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 30) then
                        t = Timer()
                        --wait for game end
                        local isAttacking=false
                        while(true) do
                            -- To-Do: Long waiting time to restart the game

                            logger.info("# of games finished:" .. noOfGamesFinished .. " wait time: " .. t:check())
                            -- Check game started

                           -- Shoot in the front
                           -- shootIfGetBallInFrontArea()

                           -- Set Attack Mode
                            isAttacking = setAttackMode(isAttacking)

                            -- Check for the complete match screen
                            if exists(Pattern("complete-match-text.png"):similar(0.90), 1) then
                                logger.info ("Click through all screens")
                                while(true) do
                                    if(existsClick(Pattern("finish-match.png"):similar(0.90), 1)) then
                                        noOfGamesFinished = noOfGamesFinished + 1
                                        break;
                                    else
                                        logger.info ("Click ...")
                                        click(getLastMatch())
                                    end
                                end

                                noOfGamesFinished = noOfGamesFinished + 1

                               -- wait long enough for the game menu
                                logger.info("Completing game and wait for stage menu")
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

-- Return the picture of selected game
function guild_event_to_join()
    local event_code = string.sub(selected_guild_event,1,4)
    if event_code=="0000" then
        return "game-join-event-text-any.png"
    else
        return "game-join-event-text-" .. event_code .. ".png"
    end
end

function recurringJoinGuild()
       local counter = 1
        while(true) do
            t = Timer();
            if (counter%10==0) then
                logger.info("# of games finished:" .. noOfGamesFinished)
            end

            -- Go to the Waiting Room if exists
            -- Use last capture image for checking
            --usePreviousSnap(true)
            logger.debug("BEGINE Loop");
            snapshot()
            logger.trace("Snapshot: ".. t:check());

            if regionGuildGameShowArea:existsClick(Pattern(guild_event_to_join()):similar(0.90), 0) then -- Join selected event(s)
            elseif regionLowerHalf:existsClick(Pattern("confirm-join.png"):similar(0.90),0) then
                -- Disable capture cache
                -- usePreviousSnap(false)

               -- Joined a game, do in game handling
                logger.trace("confirm-join 1: ".. t:check());
                local counterInGame = 1
                while(true) do

                    local isAttacking=false
                    -- To-Do:  Long waiting time to restart the game

                    -- Check for the complete match screen
                    -- Disable capture cache
                    logger.trace("In Game - before chcck complete match: ".. t:check());
                    usePreviousSnap(false)
                    if (counterInGame%4==0   and regionCenter:exists(Pattern("complete-match-text.png"):similar(0.90),0)) then
                        noOfGamesFinished = noOfGamesFinished + 1
                        logger.info("Click through all screens")

                        while(true) do
                            click( Location(300, 300))
                            if(regionLowerHalf:existsClick(Pattern("finish-match.png"):similar(0.98), 2)) then
                                wait(1)
                                click( Location(300, 300))
                                break;
                            end
                        end

                        logger.info("Completing game")
                        break;
                    else
                        logger.trace("In Game - Other Start: ".. t:check());
                        usePreviousSnap(true)

                        -- Set Attack Mode
                        isAttacking = setAttackMode(isAttacking)

                        -- Shoot in the front field
                        -- shootIfGetBallInFrontArea()

                        -- check error, handle for next game, if any
                        logger.trace("In Game - before handle error: ".. t:check());
                        if counterInGame %10 == 0 then
                            if handleError() then
                                -- Disable capture cache
                                usePreviousSnap(false)
                                break;
                            end
                        end
                        logger.trace("In Game - after handle error: ".. t:check());

                        -- Disable capture cache
                        usePreviousSnap(false)
                        logger.trace("In Game - Other End: ".. t:check());
                    end
                    counterInGame = counterInGame + 1
                end
                logger.trace("confirm-join 2: ".. t:check());

                -- Disable capture cache
                usePreviousSnap(false)
            elseif regionRightHalf:existsClick(Pattern("join-guild-game.png"):similar(0.90),0) then
            end

            logger.trace("Before handle Error: ".. t:check());
            if counter%10 == 0 then
                regionLowerHalf:existsClick(Pattern("finish-match.png"):similar(0.90), 0)
                handleError()
            end
            logger.trace("After handle Error: ".. t:check());
            counter = counter + 1
        end
end

-- main
if gameMode==21 then
   if(joinFromHomeSwitch) then
    joinFromHome_JoinGuild()
   end
   recurringJoinGuild()
elseif gameMode==31 then
    joinFromHome()
    recurringJoin();
end
scriptExit("End: " + noOfGamesFinished)
