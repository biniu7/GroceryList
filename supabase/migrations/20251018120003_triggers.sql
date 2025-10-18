-- =====================================================================================
-- Migration: Database Triggers and Functions for GroceryList MVP
-- =====================================================================================
-- Description: Creates PostgreSQL functions and triggers for automated tasks
-- Author: Database Team
-- Date: 2025-10-18
--
-- Functions Created:
--   - create_user_profile() - Auto-creates user_profiles row when user registers
--   - update_updated_at_column() - Auto-updates updated_at timestamp on row UPDATE
--
-- Triggers Created:
--   - on_auth_user_created (auth.users) - Calls create_user_profile()
--   - set_updated_at_* (recipes, user_profiles, etc.) - Calls update_updated_at_column()
--
-- Notes:
--   - SECURITY DEFINER allows triggers to bypass RLS for system operations
--   - Triggers execute automatically (no application code needed)
--   - Functions are idempotent (safe to run multiple times)
-- =====================================================================================

-- =====================================================================================
-- SECTION 1: USER PROFILE AUTO-CREATION
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Function: create_user_profile()
-- -------------------------------------------------------------------------------------
-- Purpose: Automatically creates user_profiles row when user registers via Supabase Auth
-- Trigger: AFTER INSERT on auth.users
-- Security: SECURITY DEFINER (bypasses RLS to insert into public.user_profiles)
-- Rationale:
--   - Ensures every authenticated user has a profile (1:1 relationship)
--   - Eliminates manual profile creation step in application code
--   - Initializes ai_parsing_count to 0 and reset_date to next month
-- Returns: NEW row (trigger continuation)
-- Error Handling: If INSERT fails, trigger aborts and registration fails (desired behavior)
-- -------------------------------------------------------------------------------------
create or replace function create_user_profile()
returns trigger
security definer
language plpgsql
as $$
begin
  -- Insert user_profiles row for newly created auth.users row
  -- user_id references auth.users(id) via foreign key
  -- Default values:
  --   - ai_parsing_count: 0 (no AI parsing used yet)
  --   - ai_parsing_reset_date: current_date + 1 month (next reset)
  --   - created_at, updated_at: now() (automatic timestamps)
  insert into public.user_profiles (user_id)
  values (new.id);

  return new;
end;
$$;

comment on function create_user_profile() is
  'Auto-creates user_profiles row when user registers via Supabase Auth. Called by on_auth_user_created trigger.';

-- -------------------------------------------------------------------------------------
-- Trigger: on_auth_user_created
-- -------------------------------------------------------------------------------------
-- Purpose: Call create_user_profile() after user registration
-- Timing: AFTER INSERT (profile created after auth.users row exists)
-- Scope: FOR EACH ROW (one profile per user)
-- Rationale:
--   - AFTER INSERT ensures auth.users.id exists before foreign key reference
--   - FOR EACH ROW handles bulk inserts (edge case, usually one user at a time)
-- -------------------------------------------------------------------------------------
create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function create_user_profile();

-- Note: Cannot add COMMENT on trigger in auth schema (permission denied)
-- Purpose: Auto-creates user_profiles row when user registers. Ensures 1:1 relationship between auth.users and user_profiles.

-- =====================================================================================
-- SECTION 2: AUTO-UPDATE TIMESTAMPS
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Function: update_updated_at_column()
-- -------------------------------------------------------------------------------------
-- Purpose: Automatically updates updated_at timestamp when row is modified
-- Trigger: BEFORE UPDATE on tables with updated_at column
-- Security: No SECURITY DEFINER needed (operates on current row, respects RLS)
-- Rationale:
--   - Ensures updated_at accurately reflects last modification time
--   - Eliminates manual timestamp updates in application code
--   - Supports auditing and debugging (when was this row last changed?)
-- Returns: NEW row with updated_at set to now()
-- Performance: Negligible overhead (single function call per UPDATE)
-- -------------------------------------------------------------------------------------
create or replace function update_updated_at_column()
returns trigger
language plpgsql
as $$
begin
  -- Set updated_at to current timestamp (UTC)
  -- PostgreSQL now() returns timestamptz (timezone-aware)
  new.updated_at = now();

  return new;
end;
$$;

comment on function update_updated_at_column() is
  'Auto-updates updated_at timestamp when row is modified. Called by set_updated_at_* triggers on tables with updated_at column.';

-- -------------------------------------------------------------------------------------
-- Triggers: set_updated_at_* (one per table with updated_at column)
-- -------------------------------------------------------------------------------------
-- Purpose: Call update_updated_at_column() before row UPDATE
-- Timing: BEFORE UPDATE (timestamp updated before row is written to disk)
-- Scope: FOR EACH ROW (each updated row gets new timestamp)
-- Tables: recipes, user_profiles, calendar_template, calendar_instances, shopping_lists
-- Rationale:
--   - BEFORE UPDATE ensures timestamp is part of the UPDATE transaction
--   - FOR EACH ROW handles bulk updates (UPDATE ... WHERE ... affecting multiple rows)
-- Performance: ~1-2% overhead per UPDATE (acceptable for audit trail)
-- -------------------------------------------------------------------------------------

-- Trigger for recipes table
create trigger set_updated_at_recipes
  before update on recipes
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at_recipes on recipes is
  'Auto-updates updated_at timestamp when recipe is modified (PRD FR-RECIPE-006: edit recipe)';

-- Trigger for user_profiles table
create trigger set_updated_at_user_profiles
  before update on user_profiles
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at_user_profiles on user_profiles is
  'Auto-updates updated_at timestamp when user profile is modified (e.g., incrementing ai_parsing_count)';

-- Trigger for calendar_template table
create trigger set_updated_at_calendar_template
  before update on calendar_template
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at_calendar_template on calendar_template is
  'Auto-updates updated_at timestamp when calendar template is modified (PRD US-015: editing template)';

-- Trigger for calendar_instances table
create trigger set_updated_at_calendar_instances
  before update on calendar_instances
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at_calendar_instances on calendar_instances is
  'Auto-updates updated_at timestamp when calendar instance is modified (changing recipe for specific date)';

-- Trigger for shopping_lists table
create trigger set_updated_at_shopping_lists
  before update on shopping_lists
  for each row
  execute function update_updated_at_column();

comment on trigger set_updated_at_shopping_lists on shopping_lists is
  'Auto-updates updated_at timestamp when shopping list is modified (e.g., updating week_start_date)';

-- =====================================================================================
-- MIGRATION COMPLETE
-- =====================================================================================
-- Trigger Summary:
--   - 1 function for user profile auto-creation (SECURITY DEFINER)
--   - 1 function for timestamp auto-update (standard)
--   - 1 trigger on auth.users (auto-create profile)
--   - 5 triggers on tables with updated_at (auto-update timestamp)
--   Total: 2 functions, 6 triggers
--
-- Testing Triggers:
--   1. User profile creation:
--      - Register new user via Supabase Auth
--      - Verify user_profiles row exists with user_id = auth.users.id
--      - Verify ai_parsing_count = 0, reset_date = next month
--
--   2. Timestamp updates:
--      - UPDATE any row in recipes/user_profiles/calendar/shopping_lists
--      - Verify updated_at changed to current timestamp
--      - Verify created_at unchanged (only updated_at should change)
--
-- Next steps:
--   1. Test all migrations in local Supabase instance
--   2. Verify RLS policies work correctly with triggers
--   3. Run integration tests (user registration, recipe CRUD, list generation)
--   4. Deploy to staging environment
-- =====================================================================================
