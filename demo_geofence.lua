-- demo_geofence.lua

local GEOFENCE_RADIUS_M = 1000  -- Maximum authorized distance from Home (Meters)
local MODE_RTL          = 11   -- Mode 11: Return-To-Launch (ArduPlane)
local SEVERITY_CRITICAL = 0    -- MAV_SEVERITY_EMERGENCY (Red Alert)
local SEVERITY_INFO     = 6    -- MAV_SEVERITY_INFO (Standard telemetry)

function update()
  -- 1. Acquire Telemetry
  local current_loc = ahrs:get_position()
  local home_loc    = ahrs:get_home()
  
  -- Verify GPS lock and Home position validity before proceeding
  if current_loc and home_loc then
      
      -- 2. Calculate Radial Distance
      local distance_m = current_loc:get_distance(home_loc)
      
      -- 3. Safety Logic Check
      if distance_m > GEOFENCE_RADIUS_M then
          
          -- Check current flight mode to prevent redundant commands
          local current_mode = vehicle:get_mode()
          
          if current_mode ~= MODE_RTL then
             -- BREACH DETECTED: Execute Failsafe
             gcs:send_text(SEVERITY_CRITICAL, "ALERT: GEOFENCE BREACH DETECTED.")
             gcs:send_text(SEVERITY_CRITICAL, string.format("Range: %.0fm > Limit: %.0fm. Engaging RTL.", distance_m, GEOFENCE_RADIUS_M))
             
             -- Force Autonomous Return
             vehicle:set_mode(MODE_RTL)
          end
      end
  end

  return update, 1000 -- Run every 1 second
end

return update()