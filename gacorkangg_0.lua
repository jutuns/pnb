-------------------- Dont Edit Below -------------------
------------------- Created by Jutun -------------------

activateScript = false
HWIDZ = "0F8BFBFF00050654"
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
if HWIDZ == hwid then
    activateScript = true
end
if not activateScript then
    print("HWID NOT REGISTERED, CONTACT : JUTUN STORE")
    print(hwid)
end

if activateScript then
    totalWorld = #worldList
    totalBot = #getBots()
    maxBot = totalBot / totalWorld
    bot.legit_mode = false
    indexBot = 0
    indexLast = 0
    botposX = 0
    botposY = 0
    gaiaX = 0
    gaiaY = 0
    utX = 0
    utY = 0
    worldPNB = ""
    t = os.time()
    for i, botz in pairs(getBots()) do
        if botz.name:upper() == bot.name:upper() then
            indexBot = i
        end
        indexLast = i
    end
end

function botEvents()
    local te = os.time() - t
    local text = [[
        $webHookUrl = "]]..webhookGems..[[/messages/]]..messageId..[["
        $thumbnailObject = @{
            url = "https://i.ibb.co/tYT5fkv/Jutun-Store.png"
        }
        $footerObject = @{
            text = "]]..(os.date("!%a %b %d, %Y at %I:%M %p", os.time() + 7 * 60 * 60))..[["
        }
        $fieldArray = @(
            @{
                name = "INFO"
                value = "<:arrow:1160743652088365096> World : ]]..bot:getWorld().name.."\n"..[[<:gems:1167424601559666719> Gems : ]]..countGems()..[["
                inline = "false"
            }
            @{
                name = "BOT UPTIME"
                value = "<:arrow:1160743652088365096> ]]..math.floor(te/86400)..[[ Days ]]..math.floor(te%86400/3600)..[[ Hours ]]..math.floor(te%86400%3600/60)..[[ Minutes"
                inline = "false"
            }
        )
        $embedObject = @{
            title = "<:globe:1011929997679796254> **INFORMATION**"
            color = "16777215"
            thumbnail = $thumbnailObject
            footer = $footerObject
            fields = $fieldArray
        }
        $embedArray = @($embedObject)
        $payload = @{
            embeds = $embedArray
        }
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Patch -ContentType 'application/json'
    ]]
    local file = io.popen("powershell -command -", "w")
    file:write(text)
    file:close()
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
    if count <= (4000 - num) and stack < 15 then
        return true
    end
    return false
end

function reconnect(world,id,x,y)
    while (not bot:isInWorld(world:upper()) or getTile(getBot().x,getBot().y).fg == 6) and bot.status == BotStatus.online do
        while bot:isResting() do
            sleep(2000)
        end
        bot:warp(world,id)
        sleep(delayWarp)
    end
    if bot.status ~= BotStatus.online then
        while bot:isResting() do
            sleep(2000)
        end
        while bot.status ~= BotStatus.online do
            bot:connect()
            sleep(8000)
            if bot.status == BotStatus.account_banned then
                bot.auto_reconnect = false
                stopScript()
            end
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
    otw(storageBlock,doorBlock)
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
    otw(worldPNB,doorPNB)
end

function countGems()
    gmzz = 0
    for _, obj in pairs(bot:getWorld():getObjects()) do
        if obj.id == 112 then
            gmzz = gmzz + obj.count
        end
    end
    return gmzz
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
    checkz = 0
    if bot:getInventory():findItem(itmId) == 0 then
        takeBlock()
    end
    bot:findPath(botposX,botposY)
    while bot:getInventory():findItem(itmId) > 0 and bot:isInWorld(worldPNB:upper()) and bot:isInTile(botposX,botposY) do
        while getTile(botposX,botposY+2).fg == 0 and getTile(botposX,botposY+2).bg == 0 and bot:isInTile(botposX,botposY) do
            bot:place(botposX,botposY+2,itmId)
            sleep(delayPlace)
            reconnect(worldPNB,doorPNB,botposX,botposY)
        end
        while getTile(botposX,botposY+2).fg ~= 0 or getTile(botposX,botposY+2).bg ~= 0 and bot:isInTile(botposX,botposY) do
            bot:hit(botposX,botposY+2)
            sleep(delayPunch)
            reconnect(worldPNB,doorPNB,botposX,botposY)
        end
        if checkz == 10 then
            checkGems()
            checkz = 0
            reconnect(worldPNB,doorPNB,botposX,botposY)
        else
            checkz = checkz + 1
        end
    end
end

function storeSeed()
    otw(storageSeed,doorSeed)
    for _, tile in pairs(bot:getWorld():getTiles()) do
        if tile.fg == patokanSeed or tile.bg == patokanSeed then
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
end

function storeBlock()
    otw(storageBlock,doorBlock)
    for _, tile in pairs(bot:getWorld():getTiles()) do
        if tile.fg == patokanBlock or tile.bg == patokanBlock then
            if tileDrop(tile.x,tile.y,200) then
                bot:findPath(tile.x - 1,tile.y)
                bot:setDirection(false)
                sleep(100)
                bot:fastDrop(itmId,bot:getInventory():findItem(itmId))
                sleep(100)
                if bot:getInventory():findItem(itmId) == 0 then
                    break
                end
            end
        end
    end
end

function takeGaia()
    if bot:getInventory():findItem(itmSeed) < 200 then
        bot:findPath(gaiaX,gaiaY-1)
        sleep(1000)
        bot:wrench(gaiaX,gaiaY)
        sleep(1500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|itemsucker_seed\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
        sleep(1500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..gaiaX.."|\ntiley|"..gaiaY.."|\nitemtoremove|200")
        sleep(1500)
        reconnect(worldPNB,doorPNB,gaiaX,gaiaY-1)
        sleep(100)
    end
end

function takeUT()
    if bot:getInventory():findItem(itmId) < 200 then
        bot:findPath(utX,utY-1)
        sleep(1500)
        bot:wrench(utX,utY)
        sleep(1500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|itemsucker_block\ntilex|"..utX.."|\ntiley|"..utY.."|\nbuttonClicked|retrieveitem\n\nchk_enablesucking|1")
        sleep(1500)
        bot:sendPacket(2,"action|dialog_return\ndialog_name|itemremovedfromsucker\ntilex|"..utX.."|\ntiley|"..utY.."|\nitemtoremove|200")
        sleep(1500)
        reconnect(worldPNB,doorPNB,utX,utY-1)
        sleep(100)
    end
end

function otw(worldz,id)
    while not bot:isInWorld(worldz:upper()) or getTile(getBot().x,getBot().y).fg == 6 do
        while bot:isResting() do
            sleep(2000)
        end
        bot:warp(worldz,id)
        sleep(delayWarp)
    end
end

function autoTutorial()
    bot.auto_tutorial = true
    while bot:getWorld().name == "EXIT" or bot:getWorld().name:find("TUTORIAL") do
        sleep(5000)
    end
    bot.auto_tutorial = false
end

if activateScript then
    if bot:getInventory():findItem(6336) == 0 then
        autoTutorial()
    end
    worldPNB = worldList[math.ceil(indexBot/maxBot)]
    if indexBot % maxBot == 0 then
        otw(worldPNB,doorPNB)
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
            sleep(restTake)
            countplayer = #getBots()
            if countplayer == totalWorld then
                removeBot()
            end
            takeGaia()
            sleep(100)
            takeUT()
            sleep(100)
            if bot:getInventory():findItem(itmId) > 0 then
                storeBlock()
            end
            if bot:getInventory():findItem(itmSeed) > 0 then
                storeSeed()
            end
            otw(worldPNB,doorPNB)
            sleep(100)
            botEvents()
            sleep(100)
        end
    else
        otw(worldPNB,doorPNB)
        for _, tile in pairs(bot:getWorld():getTiles()) do
            if tile.fg == patokanPNB or tile.bg == patokanPNB then
                botposX = tile.x - 1
                botposY = tile.y
                break
            end
        end
        while indexBot > maxBot do
            indexBot = indexBot - maxBot
        end
        botposX = botposX + indexBot
        sleep(100)
        while true do
            pnb()
        end
    end
end
