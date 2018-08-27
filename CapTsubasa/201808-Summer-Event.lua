--
--
-- Created by IntelliJ IDEA.
-- User: timothy
-- Date: 17/8/2018
-- Time: 22:27
-- To change this template use File | Settings | File Templates.
--
BUILD_NUMBER="V20180827-1"

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
regionGuildGameShowArea = Region(212,76,874,552)
regionCenter = Region(208,24,862,693)
regionErrorDialog = Region(371,111,509,507)

scriptTime = Timer()
noOfGamesFinished = 0

selected_verbose = "0 - NONE"
stage =  230
gameMode = 30
attackMode = 0
gameMode = 21
selected_guild_event = ""
joinFromHomeSwitch=true


--- Display menu
function mainMenu()
    dialogInit()
    addTextView(BUILD_NUMBER);
    addSeparator()
    -- Dialog for select Game Mode
    addRadioGroup("gameMode", 21)
    addRadioButton("Join Guild", 21)
    --addRadioButton("Create Myself", 10)
    --addRadioButton("Create Guild", 20)
    --addRadioButton("Create Public", 30)
    addRadioButton("Join Public", 31)
    addSeparator()

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
    local errorTime = Timer()
    logger.trace("Handle error - BEGIN: "..errorTime:check())
    -- Prevent cap screen again for error checking
    usePreviousSnap(false)
    snapshot()
    logger.trace("Handle error - Snapshot: "..errorTime:check())
    if  regionErrorDialog:existsClick(Pattern("ok-button.png"):similar(0.90), 0) then
        logger.trace("Handle error - OK: "..errorTime:check())

        if regionErrorDialog:exists(Pattern("dismissed-text.png"):similar(0.90),0) then
            logger.trace("Handle error - Dismissed: "..errorTime:check())
            -- handle dismiss
            logger.info ("Ooh, dismissed")
            --usePreviousSnap(false)
            --regionLowerHalf:existsClick(Pattern("confirm-join.png"):similar(0.90), 0)

            logger.trace("Handle error - Dismissed END: "..errorTime:check())
            return true;
        end

        logger.trace("Handle error - OK END: "..errorTime:check())
        usePreviousSnap(false)
        return true;
    -- ToDo: handle comm error, dismiss
    elseif regionErrorDialog:existsClick(Pattern("reconnect.png"):similar(0.90),0) then
        logger.trace("Handle error - RECONNECT: "..errorTime:check())
        usePreviousSnap(false)

        logger.info ("Ooh, no connection")
        -- start from home
        if gameMode==21 then
            joinFromHome_JoinGuild()
        elseif gameMode==31 then
            joinFromHome()
        end

        logger.trace("Handle error - RECONNECT - RESUME: "..errorTime:check())
        return true;
    end

    -- handle item full
    modsell.check()

    --public game comm error

   -- Enable screen cap
    usePreviousSnap(false)
    logger.trace("Handle error - END: "..errorTime:check())
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
                        handle_ingame_events()
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

function handle_ingame_events()
   local in_game_pre_screen_2_clicked = false

    -- Joined a game, do in game handling
    logger.trace("GAME STARTED: ".. t:check());
    local counterInGame = 1
    while(true) do
        local isAttacking=false
        -- To-Do:  Long waiting time to restart the game

        -- Check for the complete match screen
        -- Disable capture cache
        logger.trace("In Game - before chcck complete match: ".. t:check());
        usePreviousSnap(false)
--[[
        if not in_game_pre_screen_1_clicked and regionLowerHalf:existsClick(Pattern("img_start_game_screen_1.png"):similar(0.90), 0) then
            in_game_pre_screen_1_clicked = true;
            logger.debug("START GAME PRE SCREEN 1 clicked")
        else
--]]
         if not in_game_pre_screen_2_clicked and Region(48,158,666,831):existsClick(Pattern("img_start_game_screen_2.png"):similar(0.90), 0) then
            in_game_pre_screen_2_clicked = true;
            logger.debug("In Game - START GAME PRE SCREEN 2 clicked")
        elseif (counterInGame%4==0   and regionCenter:exists(Pattern("complete-match-text.png"):similar(0.90),0)) then
            noOfGamesFinished = noOfGamesFinished + 1
            logger.info("In Game - Click through all screens")

            while(true) do
                click( Location(300, 300))
                if(regionLowerHalf:existsClick("finish-match.png", 2)) then
                    wait(0.5)
                    click( Location(640, 675))
                    break;
                end
            end

            logger.info("In Game - Completing game")
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
            if counterInGame %5 == 0 then
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
    logger.trace("In Game - end: ".. t:check());

    -- Disable capture cache
    usePreviousSnap(false)
end

function recurringJoinGuild()
       local iterations_to_show_text_and_check_error = 5
       t = Timer();
       local counter = 1
        while(true) do
            local sucessfulTriggerScreen = false

            if (counter%iterations_to_show_text_and_check_error==0) then
                logger.info("# of games finished:" .. noOfGamesFinished)
            end

            -- Go to the Waiting Room if exists
            -- Use last capture image for checking
            --usePreviousSnap(true)
            logger.debug("BEGIN Loop");
            snapshot()
            logger.trace("Snapshot: ".. t:check());

            if Region(1080,634,172,86):exists(Pattern("img_guild_game_join_screen.png"):similar(0.90), 0) then
                -- Join selected event(s)
                usePreviousSnap(false)
                logger.info("BEGIN WAIT JOIN GAME: " .. noOfGamesFinished)
                if regionGuildGameShowArea:existsClick(Pattern(guild_event_to_join()):similar(0.90), 10) then
                    logger.trace("JOINED GAME: "..t:check())
                    wait(0.3)
                end
            elseif Region(903,443,365,202):existsClick(Pattern("confirm-join.png"):similar(0.90),0) then
                logger.trace("CONFIRM JOIN: "..t:check())
                sucessfulTriggerScreen = true
            elseif Region(683,109,556,428):existsClick(Pattern("join-guild-game.png"):similar(0.90),0) then
                logger.trace("JOIN GUILD GAME: "..t:check())
                sucessfulTriggerScreen = true
            elseif Region(421,511,519,209):existsClick(Pattern("img_start_game_screen_1.png"):similar(0.90), 0) then
                logger.trace("GAME STARTED: "..t:check())
                sucessfulTriggerScreen = true
                handle_ingame_events()
            end

            if not sucessfulTriggerScreen then
                logger.trace("Before handle Error: ".. t:check());
                if counter%iterations_to_show_text_and_check_error == 0 then
                    regionLowerHalf:existsClick(Pattern("finish-match.png"):similar(0.90), 0)
                    handleError()
                end
                logger.trace("After handle Error: ".. t:check());
            end
            counter = counter + 1
            usePreviousSnap(false)
        end
end

--[[
function create_guild_game()
    while(true) do
        if existsClick(Pattern(guild_event_to_join()):similar(0.90), 0) then -- Join selected event(s)
    end

"normal-game.png"
"join-event"
"game-join-event-img-0002.png"
    "img-stage-extreme.png" /     "img-stage-very-hard.png" /     "img-stage-hard.png"
"ready-button.png"
"create-guild-game.png"
"button-recruit.png"

    local roomWaitTime = Timer()
    while(true) do
        wait(1)
        -- 3
        -- 2
        if roomWaitTime:check()>120 then
                "button-game-start.png"
        end
        -- 1
        if roomWaitTime:check()>150 then
                "button-game-start.png"
        end
    end
end
--]]

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
