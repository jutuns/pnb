--=================================================--
--================ DONT EDIT BELOW ================--
--=================================================--

activateScript = false

HWIDZ = {
    "0F8BFBFF00050654",
    "078BFBFF00A20F12",
    "x",
}
function get_hwid()
    local cmd = io.popen("wmic cpu get ProcessorId /format:list")
    if cmd then
        local output = cmd:read("*a")
        cmd:close()
        local hwid = output:match("ProcessorId=(%w+)")
        return hwid or "HWID not found"
    else
        return "Unable to execute the command"
    end
end
local hwid = get_hwid()
for _,hw in pairs(HWIDZ) do
    if hw == hwid then
        activateScript = true
    end
end
if not activateScript then
    print("HWID NOT REGISTERED, CONTACT : JUTUN STORE")
    print(hwid)
end

bot = getBot()
bot.legit_mode = false
bot.collect_range = 1
botIndex = 0
LastIndex = 0
botposX = 0
botposY = 0
gaiaX = 0
gaiaY = 0
utX = 0
utY = 0
worldPNB = ""
ttlWorld = #worldList

if activateScript then
    for i, botz in pairs(getBots()) do
        if botz.name:upper() == bot.name:upper() then
            botIndex = i
        end
        LastIndex = i
    end
    maxBot = math.floor(LastIndex/ttlWorld)
end

function round(n)
    return n % 1 > 0.5 and math.ceil(n) or math.floor(n)
end

function tileDrop(x,y,num)
    local count = 0
    local stack = 0
    for _,obj in pairs(bot:getWorld():getObjects()) do
        if round(obj.x / 32) == x and math.floor(obj.y / 32) == y then
            count = count + obj.count
            stack = stack + 1
        end
    end
    if count <= (4000 - num) then
        return true
    end
    return false
end

function reconnect(world,id,x,y)
    if bot.status ~= BotStatus.online then
        while bot.status ~= BotStatus.online do
            bot:connect()
            sleep(8000)
        end
        while not bot:isInWorld(world:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
            bot:warp(world,id)
            sleep(delayWarp)
        end
        if x and y then
            bot:findPath(x,y)
            sleep(100)
        end
    end
end

function takeBlock()
    while not bot:isInWorld(storageBlock:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
        bot:warp(storageBlock,doorBlock)
        sleep(delayWarp)
    end
    while bot:getInventory():findItem(itmId) == 0 do
        for _, obj in pairs(bot:getWorld():getObjects()) do
            if obj.id == itmId then
                bot:findPath(math.floor(obj.x/32),math.floor(obj.y/32))
                sleep(100)
                bot:collect(2)
                sleep(100)
                reconnect(storageBlock,doorBlock,math.floor(obj.x/32),math.floor(obj.y/32))
                if bot:getInventory():findItem(itmId) > 0 then
                    break
                end
            end
        end
    end
    while not bot:isInWorld(worldPNB:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
        bot:warp(worldPNB,doorPNB)
        sleep(delayWarp)
    end
end

function checkGems()
    gmz = 0
    for _, obj in pairs(bot:getWorld():getObjects()) do
        if obj.id == 112 then
            gmz = gmz + obj.count
        end
    end
    if gmz >= targetGems then
        bot:say("Reached target gems!")
        sleep(1000)
        bot:stopScript()
        removeBot()
    end
end

function pnb()
    if bot:getInventory():findItem(itmId) == 0 then
        takeBlock()
    end
    sleep(100)
    bot:findPath(botposX,botposY)
    sleep(100)
    while bot:getInventory():findItem(itmId) > 0 and bot:isInWorld(worldPNB:upper()) and bot:isInTile(botposX,botposY) do
        while getTile(botposX,botposY+2).fg == 0 and getTile(botposX,botposY+2).bg == 0 do
            bot:place(botposX,botposY+2,itmId)
            sleep(delayPlace)
            reconnect(worldPNB,doorPNB,botposX,botposY)
        end
        while getTile(botposX,botposY+2).fg ~= 0 or getTile(botposX,botposY+2).bg ~= 0 do
            bot:hit(botposX,botposY+2)
            sleep(delayPunch)
            reconnect(worldPNB,doorPNB,botposX,botposY)
        end
    end
    if removeBotAfterReachGems then
        checkGems()
    end
end

function storeSeed()
    while not bot:isInWorld(storageSeed:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
        bot:warp(storageSeed,doorSeed)
        sleep(delayWarp)
    end
    for _, tile in pairs(bot:getWorld():getTiles()) do
        if tile.fg == patokanDropSeed or tile.bg == patokanDropSeed then
            if tileDrop(tile.x,tile.y,200) then
                bot:findPath(tile.x - 1,tile.y)
                bot:setDirection(false)
                sleep(100)
                bot:fastDrop(itmSeed,bot:getInventory():findItem(itmSeed))
                sleep(100)
                if bot:getInventory():findItem(itmSeed) == 0 then
                    break
                end
            end
        end
    end
    while not bot:isInWorld(worldPNB:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
        bot:warp(worldPNB,doorPNB)
        sleep(delayWarp)
    end
end

function takeGaia()
    bot:findPath(gaiaX,gaiaY-1)
    sleep(1000)
    reconnect(worldPNB,doorPNB,gaiaX,gaiaY-1)
    sleep(100)
    bot:wrench(gaiaX,gaiaY)
    sleep(2000)
    bot:sendPacket(2,"action|dialog_return\ndialog_name|itemsucker_seed\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
    sleep(2000)
    bot:sendPacket(2,"action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nitemtoremove|200")
    sleep(2000)
end

function takeUT()
    bot:findPath(utX,utY-1)
    sleep(2000)
    reconnect(worldPNB,doorPNB,utX,utY-1)
    sleep(100)
    bot:wrench(utX,utY)
    sleep(2000)
    bot:sendPacket(2,"action|dialog_return\ndialog_name|itemsucker_block\ntilex|"..utX.."|\ntiley|"..utY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
    sleep(2000)
    bot:sendPacket(2,"action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..utX.."|\ntiley|"..utY.."|\nitemtoremove|200")
    sleep(2000)
end

if activateScript then
    if botIndex % maxBot == 0 then
        worldPNB = worldList[math.ceil(botIndex/maxBot)]
        bot.auto_collect = false
        sleep(1000)
        bot:warp(worldPNB,doorPNB)
        sleep(delayWarp)
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == 6946 then
                gaiaX = tile.x
                gaiaY = tile.y
            end
        end
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == 6948 then
                utX = tile.x
                utY = tile.y
            end
        end
        while true do
            sleep(intervalRetrieve)
            takeGaia()
            sleep(100)
            takeUT()
            sleep(100)
            if bot:getInventory():findItem(itmId) > 0 then
                for _, tile in pairs(bot:getWorld():getTiles()) do
                    if tile.fg == patokanPNB or tile.bg == patokanPNB then
                        bot:findPath(tile.x - 1,tile.y)
                        bot:setDirection(false)
                        sleep(100)
                        bot:drop(itmId,bot:getInventory():findItem(itmId))
                        sleep(100)
                        reconnect(worldPNB,doorPNB,tile.x - 1,tile.y)
                        sleep(100)
                    end
                    if bot:getInventory():findItem(itmId) == 0 then
                        break
                    end
                end
            end
            if bot:getInventory():findItem(itmSeed) > 0 then
                storeSeed()
            end
            countplayer = #getBots()
            if countplayer == 1 then
                removeBot()
            end
        end
    else
        worldPNB = worldList[math.ceil(botIndex/maxBot)]
        bot.auto_collect = true
        sleep(1000)
        bot:warp(worldPNB,doorPNB)
        sleep(delayWarp)
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == patokanPNB or tile.bg == patokanPNB then
                botposX = tile.x - 1
                botposY = tile.y
                break
            end
        end
        botposX = botposX + botIndex
        sleep(100)
        while true do
            pnb()
        end
    end
end
