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

dialogInit()
addRadioGroup("stage", 1)
addRadioButton("Stage 2 - 30 stma", 230)
addRadioButton("Stage 2 - 45 stma", 245)
addRadioButton("Stage 1 - 60 stma", 160)
dialogShow("Menu")

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

function joinFromHome()
    toast("Select Normal Game")
    if existsClick(Pattern("normal-game.png"):similar(0.90), 30) then
        toast("Select Event Game")
        if existsClick(Pattern("join-event.png"):similar(0.90), 30) then
            toast("Select 18 Summer Event")
            if existsClick(Pattern("18summer-event.png"):similar(0.90), 30) then
                toast("Loop game now")

                recurringJoin();
            end
        end
    end
end

function recurringJoin()
    while(true) do
        toast("Select Event Row 2")
        if existsClick(Pattern(stage_pic):similar(0.95), 30) then
            toast("select match")
            if existsClick(Pattern("ready-button.png"):similar(0.90), 30) then
                toast("Select Join Public Game")
                if existsClick(Pattern("join-public.png"):similar(0.90), 30) then
                    toast("Select Team")
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 30) then
                        --wait for game eend
                        while(true) do
                            toast("Wait completion of - # of games finished:" .. noOfGamesFinished)
                            if existsClick(Pattern("complete-match-text.png"):similar(0.90), 30) then
                                toast("Click through all screen")
                                -- score page
                                wait(3)
                                click(getLastMatch())
                                -- gift page 1
                                wait(3)
                                click(getLastMatch())
                                -- gift page 2
                                wait(3)
                                click(getLastMatch())
                                -- gift page 3
                                wait(3)
                                click(getLastMatch())

                                toast("Click Finish Match Button")
                                existsClick(Pattern("finish-match.png"):similar(0.90), 30)
                                noOfGamesFinished = noOfGamesFinished + 1
                                break;
                            end

                            -- check error
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
