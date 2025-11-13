---------------------------------------------------------------------------------------------------
-- Mission Control Mod - Platform Utilities Library
---------------------------------------------------------------------------------------------------
-- Purpose: Platform detection, orbit status checking, and space location queries
--
-- This module provides PURE FUNCTIONS for querying platform state. It does NOT:
--   - Store platform state in global (that's scripts/globals.lua)
--   - Update receiver connections (that's scripts/receiver_combinator.lua)
--   - Transmit signals (that's scripts/network_manager.lua)
--
-- All functions are stateless and safe to call from anywhere.
--
-- Factorio 2.0 Platform API Reference:
--   - surface.platform → LuaSpacePlatform or nil
--   - platform.space_location → LuaSpaceLocation or nil (nil when in transit)
--   - platform.speed → number (0 when stationary)
--   - game.space_platforms → array of all LuaSpacePlatforms
--
-- Dependencies: None
---------------------------------------------------------------------------------------------------

local platform_utils = {}

---------------------------------------------------------------------------------------------------
-- PLATFORM DETECTION
---------------------------------------------------------------------------------------------------

--- Check if a surface is a space platform
-- @param surface LuaSurface: Surface to check
-- @return boolean: True if surface is a platform, false otherwise
--
-- Usage:
--   if platform_utils.is_platform_surface(entity.surface) then
--     -- Entity is on a platform
--   end
--
-- Note: Returns false for regular planetary surfaces and nil input
function platform_utils.is_platform_surface(surface)
  if not surface or not surface.valid then
    return false
  end

  -- In Factorio 2.0, platforms have the .platform property
  return surface.platform ~= nil
end

--- Get platform object from surface
-- @param surface LuaSurface: Platform surface to query
-- @return LuaSpacePlatform|nil: Platform object or nil if not a platform
--
-- Usage:
--   local platform = platform_utils.get_platform_for_surface(entity.surface)
--   if platform then
--     -- Access platform properties
--     local location = platform.space_location
--   end
--
-- Note: Returns nil for non-platform surfaces
function platform_utils.get_platform_for_surface(surface)
  if not surface or not surface.valid then
    return nil
  end

  return surface.platform
end

--- Get platform from entity's surface
-- Convenience function that extracts platform from entity in one call
-- @param entity LuaEntity: Entity on platform
-- @return LuaSpacePlatform|nil: Platform or nil if entity not on platform
--
-- Usage:
--   local platform = platform_utils.get_platform_from_entity(receiver_entity)
--   if platform then
--     -- Work with platform
--   end
--
-- Note: Returns nil if entity is invalid or not on a platform surface
function platform_utils.get_platform_from_entity(entity)
  if not entity or not entity.valid then
    return nil
  end

  return platform_utils.get_platform_for_surface(entity.surface)
end

---------------------------------------------------------------------------------------------------
-- ORBIT STATUS QUERIES
---------------------------------------------------------------------------------------------------

--- Check if platform is stationary (not traveling between locations)
-- @param platform LuaSpacePlatform: Platform to check
-- @return boolean: True if platform is not in transit, false if traveling
--
-- Usage:
--   if platform_utils.is_platform_stationary(platform) then
--     -- Safe to activate receiver connection
--   end
--
-- Implementation Note:
--   A platform is stationary when:
--     1. It has a valid space_location (not nil)
--     2. Its speed is 0 (not accelerating/decelerating)
--
-- Edge Cases:
--   - Returns false if platform is destroyed/invalid
--   - Returns false during acceleration and deceleration phases
function platform_utils.is_platform_stationary(platform)
  if not platform or not platform.valid then
    return false
  end

  -- Platform must have a location (not in transit between locations)
  if not platform.space_location then
    return false
  end

  -- Platform must have zero speed (completely stopped)
  return platform.speed == 0
end

--- Get surface that platform is currently orbiting
-- @param platform LuaSpacePlatform: Platform to query
-- @return LuaSurface|nil: Orbited surface or nil if in transit or orbiting space
--
-- Usage:
--   local orbited = platform_utils.get_orbited_surface(platform)
--   if orbited then
--     log("Platform is orbiting " .. orbited.name)
--   end
--
-- Implementation Note:
--   Returns the planet/moon surface if platform is at a planetary orbit location.
--   Returns nil if:
--     - Platform is in transit (no space_location)
--     - Platform is in deep space (space_location exists but no planet)
--     - Platform or space_location is invalid
--
-- Edge Cases:
--   - Asteroid fields and other non-planetary locations return nil
--   - Platform in transit returns nil
function platform_utils.get_orbited_surface(platform)
  if not platform or not platform.valid then
    return nil
  end

  local space_location = platform.space_location
  if not space_location then
    return nil
  end

  -- Check if the space location has an associated planet/surface
  -- In Factorio 2.0, space_location.surface gives the orbited surface
  if space_location.surface and space_location.surface.valid then
    return space_location.surface
  end

  return nil
end

--- Check if platform is orbiting a specific surface AND is stationary
-- This is the primary function for checking receiver connection eligibility
-- @param platform_id number: Platform unit_number to check
-- @param surface_index number: Target surface index to match
-- @return boolean: True if platform is orbiting the surface AND stationary
--
-- Usage:
--   -- Check if receiver's platform is connected to configured planet
--   if platform_utils.is_platform_orbiting(receiver_platform_id, nauvis_index) then
--     -- Activate signal relay
--   end
--
-- Implementation Note:
--   This combines orbit detection AND stationary check because receivers
--   should only be active when BOTH conditions are met.
--
-- Edge Cases:
--   - Returns false if platform doesn't exist (destroyed)
--   - Returns false if platform is traveling
--   - Returns false if orbiting different surface
--   - Returns false if in deep space
function platform_utils.is_platform_orbiting(platform_id, surface_index)
  if not platform_id or not surface_index then
    return false
  end

  -- Get platform by ID
  local platform = game.space_platforms[platform_id]
  if not platform or not platform.valid then
    return false
  end

  -- Platform must be stationary (not traveling)
  if not platform_utils.is_platform_stationary(platform) then
    return false
  end

  -- Platform must be orbiting the target surface
  local orbited = platform_utils.get_orbited_surface(platform)
  if not orbited then
    return false
  end

  return orbited.index == surface_index
end

---------------------------------------------------------------------------------------------------
-- PLATFORM ENUMERATION
---------------------------------------------------------------------------------------------------

--- Find all platforms in the game
-- @return array: Array of LuaSpacePlatform objects (may be empty)
--
-- Usage:
--   for _, platform in pairs(platform_utils.find_all_platforms()) do
--     log("Found platform: " .. platform.name)
--   end
--
-- Performance Note:
--   This iterates game.space_platforms which is maintained by the engine.
--   Safe to call frequently but prefer caching results if used in tight loops.
--
-- Edge Cases:
--   - Returns empty table if no platforms exist
--   - Only returns valid platforms
function platform_utils.find_all_platforms()
  local platforms = {}

  if not game.space_platforms then
    return platforms
  end

  for _, platform in pairs(game.space_platforms) do
    if platform and platform.valid then
      table.insert(platforms, platform)
    end
  end

  return platforms
end

---------------------------------------------------------------------------------------------------
-- RELATIONSHIP QUERIES
---------------------------------------------------------------------------------------------------

--- Check if two entities are on the same platform
-- @param entity_a LuaEntity: First entity
-- @param entity_b LuaEntity: Second entity
-- @return boolean: True if both entities are on the same platform
--
-- Usage:
--   if platform_utils.on_same_platform(receiver_a, receiver_b) then
--     -- Both receivers share platform infrastructure
--   end
--
-- Implementation Note:
--   Returns false if either entity is invalid, on different surfaces,
--   or if either is not on a platform at all.
--
-- Edge Cases:
--   - Returns false if either entity is on a planetary surface
--   - Returns false if entities are on different platforms
--   - Returns false if either entity is invalid
function platform_utils.on_same_platform(entity_a, entity_b)
  if not entity_a or not entity_a.valid then
    return false
  end

  if not entity_b or not entity_b.valid then
    return false
  end

  -- Both must be on platform surfaces
  local platform_a = platform_utils.get_platform_from_entity(entity_a)
  local platform_b = platform_utils.get_platform_from_entity(entity_b)

  if not platform_a or not platform_b then
    return false
  end

  -- Compare platform unit numbers
  return platform_a.unit_number == platform_b.unit_number
end

---------------------------------------------------------------------------------------------------
-- TESTING & DEBUGGING UTILITIES
---------------------------------------------------------------------------------------------------

--- Get human-readable platform status string
-- NOT part of core API - provided for debugging and logging
-- @param platform LuaSpacePlatform: Platform to describe
-- @return string: Status description
--
-- Usage:
--   log(platform_utils.get_platform_status_string(platform))
--   -- Output: "Platform 'Alpha' stationary at Nauvis" or "Platform 'Beta' in transit"
function platform_utils.get_platform_status_string(platform)
  if not platform or not platform.valid then
    return "Invalid platform"
  end

  local name = platform.name or "Unnamed"
  local speed = platform.speed or 0

  if not platform.space_location then
    return string.format("Platform '%s' in transit (speed: %.2f)", name, speed)
  end

  local orbited = platform_utils.get_orbited_surface(platform)
  if orbited then
    local status = speed == 0 and "stationary at" or "approaching"
    return string.format("Platform '%s' %s %s", name, status, orbited.name)
  else
    return string.format("Platform '%s' in deep space (speed: %.2f)", name, speed)
  end
end

---------------------------------------------------------------------------------------------------
-- UNIT TESTS (Inline Documentation)
---------------------------------------------------------------------------------------------------

--[[
UNIT TEST EXAMPLES:

-- Test 1: Platform detection
local nauvis = game.surfaces["nauvis"]
assert(platform_utils.is_platform_surface(nauvis) == false, "Nauvis is not a platform")

local platform_surface = some_receiver.surface
if platform_utils.is_platform_surface(platform_surface) then
  local platform = platform_utils.get_platform_for_surface(platform_surface)
  assert(platform ~= nil, "Platform surface should have platform object")
end

-- Test 2: Orbit status
local platform = platform_utils.get_platform_from_entity(receiver)
if platform then
  local is_stationary = platform_utils.is_platform_stationary(platform)
  local orbited = platform_utils.get_orbited_surface(platform)

  if is_stationary and orbited then
    log("Platform is stationary at " .. orbited.name)
  elseif not is_stationary then
    log("Platform is traveling (speed: " .. platform.speed .. ")")
  else
    log("Platform is in deep space")
  end
end

-- Test 3: Specific orbit check
local nauvis_index = game.surfaces["nauvis"].index
if platform_utils.is_platform_orbiting(platform.unit_number, nauvis_index) then
  log("Platform is orbiting Nauvis and stationary - receiver active")
end

-- Test 4: Platform enumeration
local all_platforms = platform_utils.find_all_platforms()
log("Found " .. #all_platforms .. " platforms in game")

-- Test 5: Same platform check
if platform_utils.on_same_platform(receiver_a, receiver_b) then
  log("Both receivers on same platform")
end

-- Test 6: Edge cases
assert(platform_utils.is_platform_surface(nil) == false, "Nil surface handled")
assert(platform_utils.get_platform_from_entity(nil) == nil, "Nil entity handled")
assert(platform_utils.is_platform_stationary(nil) == false, "Nil platform handled")
assert(platform_utils.on_same_platform(nil, nil) == false, "Nil entities handled")

-- Test 7: Invalid entity handling
local destroyed_entity = ... -- entity that was just destroyed
assert(platform_utils.get_platform_from_entity(destroyed_entity) == nil, "Destroyed entity handled")
]]

---------------------------------------------------------------------------------------------------
-- BOUNDARY COMPLIANCE VERIFICATION
---------------------------------------------------------------------------------------------------

--[[
RESPONSIBILITY MATRIX COMPLIANCE CHECKLIST:

✅ OWNS (correctly implemented):
  - Platform detection (is_platform_surface)
  - Platform object retrieval (get_platform_for_surface, get_platform_from_entity)
  - Orbit status checking (is_platform_orbiting, get_orbited_surface)
  - Platform movement state (is_platform_stationary)
  - Surface-platform relationship queries (on_same_platform)
  - Platform enumeration (find_all_platforms)

✅ DOES NOT OWN (correctly omitted):
  - NO global state access (pure functions only)
  - NO receiver-specific logic (that's scripts/receiver_combinator.lua)
  - NO signal transmission (that's scripts/network_manager.lua)
  - NO entity registration/tracking (that's scripts/globals.lua)

✅ DECISION CRITERIA COMPLIANCE:
  - All functions are queries about platforms ✓
  - All functions determine state without side effects ✓
  - NO functions act on platform state ✓
  - NO functions store data ✓

✅ DEPENDENCY RULES:
  - ZERO dependencies on other modules ✓
  - NO global state access ✓
  - Uses only Factorio engine API ✓
  - Can be called from any module safely ✓
]]

---------------------------------------------------------------------------------------------------
-- DESIGN DECISIONS LOG
---------------------------------------------------------------------------------------------------

--[[
DESIGN DECISION 1: is_platform_orbiting combines orbit + stationary check
RATIONALE:
  - Primary use case (receiver activation) requires BOTH conditions
  - Prevents callers from forgetting to check both
  - More semantic than separate checks
  - Aligns with spec: "only active when orbiting AND stationary"

DESIGN DECISION 2: Platform lookup by unit_number in is_platform_orbiting
RATIONALE:
  - Global state stores unit_numbers, not platform objects (serialization)
  - Matches how entity references are stored in global
  - Platform objects can't be serialized across save/load
  - Follows Factorio best practices for entity references

DESIGN DECISION 3: Separate get_orbited_surface from is_platform_orbiting
RATIONALE:
  - Allows querying orbit target without stationary requirement
  - Useful for UI display ("Platform approaching Nauvis...")
  - Follows single responsibility principle
  - More flexible for future features

DESIGN DECISION 4: get_platform_status_string included despite being debug-only
RATIONALE:
  - Extremely useful for logging and debugging
  - Doesn't violate purity (no side effects)
  - Documented as non-core utility
  - Low maintenance burden (~10 lines)

DESIGN DECISION 5: All validation returns false instead of raising errors
RATIONALE:
  - Factorio convention: graceful degradation
  - Destroyed entities are normal (not exceptional)
  - Callers can handle nil/false uniformly
  - Better performance (no exception overhead)

DESIGN DECISION 6: on_same_platform compares unit_numbers not object equality
RATIONALE:
  - Platform object references may differ but represent same platform
  - unit_number is the stable unique identifier
  - Consistent with Factorio entity identity semantics
  - Robust across save/load cycles
]]

---------------------------------------------------------------------------------------------------

return platform_utils
