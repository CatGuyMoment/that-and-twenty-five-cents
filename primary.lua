local PATH = workspace.Paths.Letters

local RESET_PATH = workspace.Paths.RESET

local TOUCHING_PART = game.Players.LocalPlayer.Character['Left Leg']

local letters = {'S','O','P','Y','K','X','D','Q','H','A','R','W','Z','C','U','T'}

function boolToNum(boolean)
    if boolean then
        return 1
    end
    return 0
end


local partStates = {


}


local INIT_WAIT_TIME = 0.5
local RUN_WAIT_TIME = 0.5


local GLOBAL_TRUTH_TABLE = {}

function touchPart(part)
    local state = not partStates[part]
    firetouchinterest(TOUCHING_PART,part,boolToNum(state))

    partStates[part] = state


end


function prepareOptimalTouching()
    for _,letterName in pairs(letters) do
        firetouchinterest(TOUCHING_PART,PATH[letterName],1)


    end

    task.wait(INIT_WAIT_TIME)

    firetouchinterest(TOUCHING_PART,RESET_PATH,1)

    task.wait(INIT_WAIT_TIME)

    for _,letterName in pairs(letters) do
        partStates[PATH[letterName]] = false
        firetouchinterest(TOUCHING_PART,PATH[letterName],0)
    end


    task.wait(INIT_WAIT_TIME)


    firetouchinterest(TOUCHING_PART,RESET_PATH,0)
    partStates[RESET_PATH] = false
    
    task.wait(INIT_WAIT_TIME)

end


function attemptToGetTruthTable(n)
    local localLetters = table.clone(letters)

    table.insert(localLetters,n,'RESET')
    local connections = {}
    
    local outputOrder = {}


    for _,letterName in pairs(localLetters) do
        local letterInstance
        if letterName == 'RESET' then
            letterInstance = RESET_PATH
            
        else
            letterInstance = PATH[letterName]
            table.insert(connections,

                    letterInstance.Changed:Once(function()
                        table.insert(outputOrder, letterName)
                    
                    end)
        
            )
            
        end
        
        touchPart(letterInstance)
        


    end
    task.wait(INIT_WAIT_TIME)

    for _,connection in pairs(connections) do
        connection:Disconnect()
    end





    for _, letterName in pairs(letters) do
        if PATH[letterName].Material ~= Enum.Material.Neon then

            return false

        end

    end

    table.insert(outputOrder,1,'RESET')
    local finalOutput = {}

    for i,receivedLetter in pairs(outputOrder) do
        table.insert(finalOutput,table.find(localLetters,receivedLetter))

    end


    return finalOutput
end



function initialize()
    prepareOptimalTouching()

    local truthTable = {}
    for i=1,16 do
        
        local output = attemptToGetTruthTable(i)
        task.wait(INIT_WAIT_TIME)
        touchPart(RESET_PATH)
        task.wait(INIT_WAIT_TIME)

        if output then
            GLOBAL_TRUTH_TABLE = output
            -- break
        end
    end
    
    
end

function encode(sequence)
    truthTable = GLOBAL_TRUTH_TABLE

    finalSequence = {}
    for i,truthIndex in pairs(truthTable) do
        letter = sequence[i]

        finalSequence[truthIndex] = letter

    end
    return finalSequence
end



function try(stringValue) --must be len 16

    local preEncode = stringValue:split('')

    table.insert(preEncode,1,'RESET')

    local prepared = encode(preEncode)

    for _,letterName in pairs(prepared) do
        local letterInstance
        if letterName == 'RESET' then
            letterInstance = RESET_PATH
            
        else
            letterInstance = PATH[letterName]
        end
        print(letterInstance)
        touchPart(letterInstance)
    end
    task.wait(RUN_WAIT_TIME)
end


initialize()

try('PXRQWTUACZHKSODY')