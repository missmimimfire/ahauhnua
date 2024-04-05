local ACCOUNT_IDS = {
    5511850552,
    3684569710
}

local LISTING_TYPE = "Misc" -- Type of item to list
local TO_LIST = "Bucket" -- Name of pet/item to list
local LISTING_PRICE = 121000000 -- Amount of gems to put up listing for
local AMOUNT = 1 -- Amount of item to list



local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BoothsBroadcast = ReplicatedStorage.Network:WaitForChild("Booths_Broadcast")

print("Listing Items")
task.spawn(function()
    while true do
        local function getPetID()
            for petID, petData in pairs(require(ReplicatedStorage:WaitForChild("Library")).Save.Get().Inventory[LISTING_TYPE]) do
                if petData["id"] == TO_LIST then
                    return petID
                end
            end
            return false
        end

        local petID = getPetID()
        if petID then
            local listingStatus, listingMessage = ReplicatedStorage.Network.Booths_CreateListing:InvokeServer(petID, LISTING_PRICE, AMOUNT)
            if not listingStatus then
                print("Error occurred when putting up listing: " .. listingMessage)
            end
        end
        task.wait(1)
    end
end)

print("Booth Service Starting")
BoothsBroadcast.OnClientEvent:Connect(funct.,ion(_, boothData)
    if type(boothData) == "table" then
        print("Got Listing")
        local boothOwnerID = boothData["PlayerID"]
        if boothOwnerID ~= game.Players.LocalPlayer.UserId and table.find(ACCOUNT_IDS, boothOwnerID) then
            print("Got listing from " .. tostring(boothOwnerID))
            local listings = boothData["Listings"]
            if type(listings) == "table" then
                for listingID, listingData in pairs(listings) do
                    print("Waiting to purchase item...")
                    local signal
                    signal = game:GetService("RunService").Heartbeat:Connect(function()
                        if listingData["ReadyTimestamp"] < workspace:GetServerTimeNow() then
                            signal:Disconnect()
                            signal = nil
                        end
                    end)

                    repeat
                        task.wait()
                    until signal == nil

                    print("Purchasing item...")
                    local purchaseStatus, purchaseResult = ReplicatedStorage.Network.Booths_RequestPurchase:InvokeServer(boothOwnerID, {[listingID] = AMOUNT})

                    if not purchaseStatus then
                        print("Error occurred purchasing listing: " .. purchaseResult)
                    end
                end
            else
                print("Not selected booth owner ID: " .. tostring(boothOwnerID))
            end
        end
    end
end)
