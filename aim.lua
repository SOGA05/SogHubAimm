-- Accès aux services Roblox
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

-- Chargement des frameworks et bibliothèques
local Framework = require(ReplicatedFirst.Framework)
local Wrapper = getupvalue(getupvalue(Framework.require, 1), 1)

local Libraries = Wrapper.Libraries
local Bullets = Libraries.Bullets

-- Variables globales
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configuration
local MAX_DISTANCE = 200 -- Portée maximale en studs
local CLOSEST_DISTANCE_THRESHOLD = 100 -- Distance minimale en pixels à l'écran

-- Fonction pour trouver le joueur le plus proche
local function getClosestPlayer()
    local closestDistance = CLOSEST_DISTANCE_THRESHOLD
    local closestCharacter = nil

    for _, player in ipairs(Players:GetPlayers()) do
        -- Ignorer le joueur local
        if player == LocalPlayer then continue end

        -- Vérifier si le joueur a un personnage avec une tête
        local character = player.Character
        if not character or not character:FindFirstChild("Head") then continue end

        local head = character.Head

        -- Vérifier si le joueur est visible à l'écran
        local screenPosition, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen then continue end

        -- Calculer la distance à l'écran
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local screenDistance = (screenCenter - Vector2.new(screenPosition.X, screenPosition.Y)).Magnitude

        -- Calculer la distance en 3D
        local worldDistance = (head.Position - Camera.CFrame.Position).Magnitude

        -- Filtrer par distance maximale et sélectionner le plus proche
        if worldDistance <= MAX_DISTANCE and screenDistance < closestDistance then
            closestDistance = screenDistance
            closestCharacter = character
        end
    end

    return closestCharacter
end

-- Hook de la fonction Bullets.Fire
local originalFire = hookfunction(Bullets.Fire, function(weaponData, characterData, _, gunData, origin, direction, ...)
    local closestCharacter = getClosestPlayer()

    -- Si un ennemi est trouvé, recalculer la direction
    if closestCharacter and closestCharacter:FindFirstChild("Head") then
        local targetPosition = closestCharacter.Head.Position
        direction = (targetPosition - origin).Unit -- Normalisation de la direction
    end

    -- Appeler la fonction originale
    return originalFire(weaponData, characterData, _, gunData, origin, direction, ...)
end)

-- Message de confirmation
print("[Aimbot] Script chargé et fonctionnel.")
