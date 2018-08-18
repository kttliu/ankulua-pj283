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

--handle error
function handleError()
    -- ToDo: handle comm error, dismiss
    toast("Handle Error")

    -- handle disconnected, retry it
    if existsClick(Pattern("reconnect.png"):similar(0.90), 5) then
        -- retry 3 times
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)
        existsClick(Pattern("reconnect.png"):similar(0.90), 10)

        -- start from home
        existsClick(Pattern("normal-game.png"):similar(0.90), 20)
        existsClick(Pattern("join-event.png"):similar(0.90), 20)
        existsClick(Pattern("18summer-event.png"):similar(0.90), 20)
        return
    end
    --dismiss (click ok)
    --select team (click join)
end

function joinFromHome()
    toast("Select Normal Game")
    if existsClick(Pattern("normal-game.png"):similar(0.90), 20) then
        toast("Select Event Game")
        if existsClick(Pattern("join-event.png"):similar(0.90), 20) then
            toast("Select 18 Summer Event")
            if existsClick(Pattern("18summer-event.png"):similar(0.90), 20) then
                toast("Loop game now")

                recurringJoin();
            end
        end
    end
end

function recurringJoin()
    while(true) do
        toast("Select row 2 game 3")
        if existsClick(Pattern("event-row2-text.png"):similar(0.90), 20) then
            toast("select match")
            if existsClick(Pattern("ready-button.png"):similar(0.90), 20) then
                toast("Select Join Public Game")
                if existsClick(Pattern("join-public.png"):similar(0.90), 20) then
                    toast("Select Team")
                    if existsClick(Pattern("confirm-join.png"):similar(0.90), 20) then
                        --wait for game eend
                        while(true) do
                            toast("Wait completion")
                            if existsClick(Pattern("complete-match-text.png"):similar(0.90), 100) then
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
                                existsClick(Pattern("finish-match.png"):similar(0.90), 20)
                                break;
                            end


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
