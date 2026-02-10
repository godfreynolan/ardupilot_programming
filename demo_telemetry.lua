-- demo_telemetry.lua

function update()
  -- 1. Get the roll attitude in Radians
  local roll_rads = ahrs:get_roll_rad()
  local roll_deg = math.deg(roll_rads)

  -- 2. Get Altitude (Safe Mode)
  local pos = ahrs:get_position()
  local home = ahrs:get_home()
  local alt_m = 0.0

  -- SAFETY CHECK: We can only calculate AGL if we have BOTH current pos AND home
  if pos and home then 
      -- Calculate difference in CM, then convert to Meters (* 0.01)
      local alt_cm = pos:alt() - home:alt()
      alt_m = alt_cm * 0.01
  else
      -- If no home/GPS yet, we just report 0.0
      alt_m = 0.0
  end

  -- 3. Report to Ground Station
  -- We use string.format to make it look nice (1 decimal place)
  gcs:send_text(6, string.format("DEMO: Roll: %.1f deg | Alt: %.1f m", roll_deg, alt_m))

  return update, 1000 -- Run every 1 second
end

return update()