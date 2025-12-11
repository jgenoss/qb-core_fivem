local currentCamera = nil
local vehicleCameras = {}
local isTransitioning = false
local cameraPreset = nil
function exitCamera()
-- Destroy existing cameras
for cameraName, cameraHandle in pairs(vehicleCameras) do
DestroyCam(cameraHandle, true) -- Destroy camera with smooth blend out
end
-- Disable rendering of script cameras
RenderScriptCams(false, false, 0, true, true)
currentCamera = nil
end
function toggleCamTemporarily(toggle)
RenderScriptCams(toggle, false, 0, true, true)
end
function setupVehicleCamera(entity)
-- Get vehicle model dimensions
local modelHash = GetEntityModel(entity)
local minDimensions, maxDimensions = GetModelDimensions(modelHash)
local yOffset = (maxDimensions.y - minDimensions.y) * 0.9
local xOffset = (maxDimensions.x - minDimensions.x) * 0.9
local zOffset = (maxDimensions.z - minDimensions.z) * 0.9
-- Create the default camera
local defaultCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, xOffset * 1.5, maxDimensions.y + 1.0, 0.0)
SetCamCoord(defaultCamera, offsetPos.x, offsetPos.y, offsetPos.z + 1.0)
PointCamAtEntity(defaultCamera, entity, 0.0, 0.0, 0.0, false)
SetCamFov(defaultCamera, 60.0)
-- Create the front camera
local frontCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, yOffset, 0.0)
SetCamCoord(frontCamera, offsetPos.x, offsetPos.y, offsetPos.z + 1.0)
PointCamAtEntity(frontCamera, entity, 0.0, 0.0, 0.0, true)
SetCamFov(frontCamera, GetGameplayCamFov())
-- Create the back camera
local backCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, -yOffset, 0.0)
SetCamCoord(backCamera, offsetPos.x, offsetPos.y, offsetPos.z + 1.0)
PointCamAtEntity(backCamera, entity, 0.0, 0.0, 0.0, true)
SetCamFov(backCamera, GetGameplayCamFov())
-- Create the exhaust camera
local exhaustCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, -yOffset, 0.0)
SetCamCoord(exhaustCamera, offsetPos.x, offsetPos.y, offsetPos.z + 0.5)
PointCamAtEntity(exhaustCamera, entity, 0.0, 0.0, 0.0, true)
SetCamFov(exhaustCamera, GetGameplayCamFov())
-- Create the side camera
local sideCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, yOffset, 0.0, 0.0)
SetCamCoord(sideCamera, offsetPos.x, offsetPos.y, offsetPos.z + 0.5)
PointCamAtEntity(sideCamera, entity, 0.0, -0.25, 0.0, true)
SetCamFov(sideCamera, GetGameplayCamFov())
-- Create the engine bay camera
local engineBayCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, yOffset * 0.7, 0.5)
SetCamCoord(engineBayCamera, offsetPos.x, offsetPos.y, offsetPos.z + 1.0)
PointCamAtEntity(engineBayCamera, entity, 0.0, 0.0, -1.0, true)
SetCamFov(engineBayCamera, GetGameplayCamFov())
-- Create the roof camera
local roofCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, maxDimensions.z)
SetCamCoord(roofCamera, offsetPos.x, offsetPos.y - 1.25, offsetPos.z + xOffset / 1.5)
PointCamAtEntity(roofCamera, entity, 0.0, 0.0, 0.0, false)
SetCamFov(roofCamera, GetGameplayCamFov())
-- Create the pov camera
local boneIndex = GetEntityBoneIndexByName(entity, "seat_dside_f")
local bonePos = GetWorldPositionOfEntityBone(entity, boneIndex)
local forwardVector = GetEntityForwardVector(entity)
local x = -0.1
local y = -0.4
local z = 0.6
local cameraX = bonePos.x + forwardVector.x * x + -0.1
local cameraY = bonePos.y + forwardVector.y * x
local cameraZ = bonePos.z + z
local povCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
SetCamCoord(povCamera, cameraX, cameraY, cameraZ)
local pointAtX = forwardVector.x * 0.5 + cameraX
local pointAtY = forwardVector.y * 0.5 + cameraY
local pointAtZ = bonePos.z + 0.4
PointCamAtCoord(povCamera, pointAtX, pointAtY, pointAtZ)
SetCamFov(povCamera, 70.0)
-- Create the door speaker camera
local doorSpeakerCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, 0.5)
SetCamCoord(doorSpeakerCamera, offsetPos.x, offsetPos.y, offsetPos.z)
local offsetPos2 = GetOffsetFromEntityInWorldCoords(entity, 1.5, 1.0, 0.5)
PointCamAtCoord(doorSpeakerCamera, offsetPos2.x, offsetPos2.y, offsetPos2.z)
SetCamFov(doorSpeakerCamera, 100.0)
-- Create the interior camera
local yOffsetCalc = maxDimensions.y - minDimensions.y
local zOffsetCalc = maxDimensions.z - minDimensions.z
local interiorY = yOffsetCalc * 0.5
local interiorCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
local interiorYPos = maxDimensions.y - interiorY * 0.5
local offsetPos = GetOffsetFromEntityInWorldCoords(entity, 0.0, interiorYPos, minDimensions.z + zOffsetCalc / 2)
SetCamCoord(interiorCamera, offsetPos.x, offsetPos.y, offsetPos.z)
local yInteriorPoint = minDimensions.y + yOffsetCalc * 0.25
local offsetPoint = GetOffsetFromEntityInWorldCoords(entity, 0.0, yInteriorPoint, minDimensions.z + zOffsetCalc / 2)
PointCamAtCoord(interiorCamera, offsetPoint.x, offsetPoint.y, offsetPoint.z)
SetCamFov(interiorCamera, 100.0)
-- Store camera handles in a table
vehicleCameras = {
default = defaultCamera,
frontCamera = frontCamera,
backCamera = backCamera,
exhaust = exhaustCamera,
sideCamera = sideCamera,
engineBay = engineBayCamera,
roof = roofCamera,
pov = povCamera,
doorSpeaker = doorSpeakerCamera,
interior = interiorCamera
}
-- Activate the default camera
SetCamActive(defaultCamera, true)
RenderScriptCams(true, false, 0, true, true)
currentCamera = defaultCamera -- Set the current camera
cameraPreset = "default"
end
function moveCameraToVehiclePreset(cameraName)
if not currentCamera then
return false -- No current camera
end
if cameraPreset == cameraName then
return false -- Already using this camera
end
local newCamera = vehicleCameras[cameraName]
if not newCamera then
return false -- Invalid camera name
end
cameraPreset = cameraName
SetCamActiveWithInterp(newCamera, currentCamera, 500, 1, 1)
SetCamActive(currentCamera, false)
currentCamera = newCamera -- Update the current camera
return true
end
function transitionCamera(cameraName)
CreateThread(function()
while true do
if not isTransitioning then
break
end
Wait(100)
end
isTransitioning = true
local success = moveCameraToVehiclePreset(cameraName)
if success then
Wait(500)
end
isTransitioning = false
end)
end