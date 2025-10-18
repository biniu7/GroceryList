-- =====================================================================================
-- Migration: Row Level Security (RLS) Policies for GroceryList MVP
-- =====================================================================================
-- Description: Enables RLS and creates security policies for complete data isolation
-- Author: Database Team
-- Date: 2025-10-18
--
-- Security Model:
--   - Every user sees ONLY their own data (complete isolation)
--   - Main tables (with user_id): Direct user_id = auth.uid() check
--   - Child tables (without user_id): EXISTS subquery with JOIN to parent table
--   - Separate policies for each operation (SELECT, INSERT, UPDATE, DELETE)
--   - Separate policies for each role (anon, authenticated) for granularity
--
-- Tables Secured:
--   - user_profiles (direct user_id check)
--   - recipes (direct user_id check)
--   - recipe_ingredients (via recipes JOIN)
--   - calendar_template (direct user_id check)
--   - calendar_instances (direct user_id check)
--   - shopping_lists (direct user_id check)
--   - shopping_list_items (via shopping_lists JOIN)
--   - shopping_list_sources (via shopping_lists JOIN)
--
-- Notes:
--   - RLS policies are automatically enforced by PostgreSQL for all queries
--   - Policies use auth.uid() function (Supabase helper returning JWT user ID)
--   - Even with GRANT SELECT, users cannot see other users' data
--   - SECURITY DEFINER functions bypass RLS (used in triggers for auto-creation)
-- =====================================================================================

-- =====================================================================================
-- SECTION 1: ENABLE ROW LEVEL SECURITY
-- =====================================================================================
-- Enable RLS for all user-owned tables
-- After enabling, default behavior is to DENY ALL ACCESS until policies are created
-- This ensures no data leaks if policies are incomplete
-- =====================================================================================

alter table user_profiles enable row level security;
alter table recipes enable row level security;
alter table recipe_ingredients enable row level security;
alter table calendar_template enable row level security;
alter table calendar_instances enable row level security;
alter table shopping_lists enable row level security;
alter table shopping_list_items enable row level security;
alter table shopping_list_sources enable row level security;

-- =====================================================================================
-- SECTION 2: POLICIES FOR MAIN TABLES (Direct user_id check)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Table: user_profiles
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage only their own profile
-- Auth Check: user_id = auth.uid() (direct column match)
-- Rationale:
--   - User profile is 1:1 with auth.users
--   - Only the profile owner should access/modify their data
--   - anon role has no access (must be authenticated to have a profile)
-- -------------------------------------------------------------------------------------

-- anon role: No access (profiles only for authenticated users)
create policy "anon users cannot select user_profiles"
  on user_profiles for select
  to anon
  using (false);

create policy "anon users cannot insert user_profiles"
  on user_profiles for insert
  to anon
  with check (false);

create policy "anon users cannot update user_profiles"
  on user_profiles for update
  to anon
  using (false);

create policy "anon users cannot delete user_profiles"
  on user_profiles for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on own profile
create policy "authenticated users can select own profile"
  on user_profiles for select
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can select own profile" on user_profiles is
  'Users can view only their own profile (user_id must match authenticated user UUID from JWT)';

create policy "authenticated users can insert own profile"
  on user_profiles for insert
  to authenticated
  with check (auth.uid() = user_id);

comment on policy "authenticated users can insert own profile" on user_profiles is
  'Users can create only their own profile (user_id must match authenticated user UUID). Note: Usually created via trigger, manual insert is edge case';

create policy "authenticated users can update own profile"
  on user_profiles for update
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can update own profile" on user_profiles is
  'Users can update only their own profile (e.g., incrementing ai_parsing_count)';

create policy "authenticated users can delete own profile"
  on user_profiles for delete
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can delete own profile" on user_profiles is
  'Users can delete only their own profile (usually via account deletion, cascades from auth.users)';

-- -------------------------------------------------------------------------------------
-- Table: recipes
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage only their own recipes
-- Auth Check: user_id = auth.uid() (direct column match)
-- Rationale:
--   - Recipes are private to each user (PRD: no sharing in MVP)
--   - Only the recipe owner should access/modify their recipes
--   - anon role has no access (must be authenticated to create recipes)
-- -------------------------------------------------------------------------------------

-- anon role: No access (recipes only for authenticated users)
create policy "anon users cannot select recipes"
  on recipes for select
  to anon
  using (false);

create policy "anon users cannot insert recipes"
  on recipes for insert
  to anon
  with check (false);

create policy "anon users cannot update recipes"
  on recipes for update
  to anon
  using (false);

create policy "anon users cannot delete recipes"
  on recipes for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on own recipes
create policy "authenticated users can select own recipes"
  on recipes for select
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can select own recipes" on recipes is
  'Users can view only their own recipes (user_id must match authenticated user UUID). Enforces data isolation per PRD requirement';

create policy "authenticated users can insert own recipes"
  on recipes for insert
  to authenticated
  with check (auth.uid() = user_id);

comment on policy "authenticated users can insert own recipes" on recipes is
  'Users can create recipes only for themselves (user_id must match authenticated user UUID). Prevents creating recipes for other users';

create policy "authenticated users can update own recipes"
  on recipes for update
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can update own recipes" on recipes is
  'Users can update only their own recipes (PRD FR-RECIPE-006: edit recipe). Changes do not affect old shopping lists (snapshot approach)';

create policy "authenticated users can delete own recipes"
  on recipes for delete
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can delete own recipes" on recipes is
  'Users can delete only their own recipes (PRD FR-RECIPE-007, US-012). Cascades to recipe_ingredients, sets calendar slots to NULL';

-- -------------------------------------------------------------------------------------
-- Table: calendar_template
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage only their own calendar template
-- Auth Check: user_id = auth.uid() (direct column match)
-- Rationale:
--   - Calendar template is personal meal planning (PRD FR-CALENDAR-002)
--   - Only the owner should access/modify their template
--   - anon role has no access (must be authenticated to plan meals)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select calendar_template"
  on calendar_template for select
  to anon
  using (false);

create policy "anon users cannot insert calendar_template"
  on calendar_template for insert
  to anon
  with check (false);

create policy "anon users cannot update calendar_template"
  on calendar_template for update
  to anon
  using (false);

create policy "anon users cannot delete calendar_template"
  on calendar_template for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on own template
create policy "authenticated users can select own calendar_template"
  on calendar_template for select
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can select own calendar_template" on calendar_template is
  'Users can view only their own calendar template (repeating weekly pattern)';

create policy "authenticated users can insert own calendar_template"
  on calendar_template for insert
  to authenticated
  with check (auth.uid() = user_id);

comment on policy "authenticated users can insert own calendar_template" on calendar_template is
  'Users can create template slots only for themselves (PRD FR-CALENDAR-002: assigning recipes to template)';

create policy "authenticated users can update own calendar_template"
  on calendar_template for update
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can update own calendar_template" on calendar_template is
  'Users can update only their own template (PRD US-015: changing recipe in template slot)';

create policy "authenticated users can delete own calendar_template"
  on calendar_template for delete
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can delete own calendar_template" on calendar_template is
  'Users can delete only their own template slots (PRD FR-CALENDAR-005: removing recipe from template)';

-- -------------------------------------------------------------------------------------
-- Table: calendar_instances
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage only their own calendar instances
-- Auth Check: user_id = auth.uid() (direct column match)
-- Rationale:
--   - Calendar instances are personal one-time overrides (PRD FR-CALENDAR-002)
--   - Only the owner should access/modify their instances
--   - anon role has no access (must be authenticated to plan meals)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select calendar_instances"
  on calendar_instances for select
  to anon
  using (false);

create policy "anon users cannot insert calendar_instances"
  on calendar_instances for insert
  to anon
  with check (false);

create policy "anon users cannot update calendar_instances"
  on calendar_instances for update
  to anon
  using (false);

create policy "anon users cannot delete calendar_instances"
  on calendar_instances for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on own instances
create policy "authenticated users can select own calendar_instances"
  on calendar_instances for select
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can select own calendar_instances" on calendar_instances is
  'Users can view only their own calendar instances (one-time changes for specific dates)';

create policy "authenticated users can insert own calendar_instances"
  on calendar_instances for insert
  to authenticated
  with check (auth.uid() = user_id);

comment on policy "authenticated users can insert own calendar_instances" on calendar_instances is
  'Users can create instances only for themselves (PRD FR-CALENDAR-003: assigning recipe to specific date)';

create policy "authenticated users can update own calendar_instances"
  on calendar_instances for update
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can update own calendar_instances" on calendar_instances is
  'Users can update only their own instances (changing recipe for specific date)';

create policy "authenticated users can delete own calendar_instances"
  on calendar_instances for delete
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can delete own calendar_instances" on calendar_instances is
  'Users can delete only their own instances (PRD FR-CALENDAR-005: removing recipe from specific date)';

-- -------------------------------------------------------------------------------------
-- Table: shopping_lists
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage only their own shopping lists
-- Auth Check: user_id = auth.uid() (direct column match)
-- Rationale:
--   - Shopping lists are private to each user (PRD FR-SHOPLIST-001)
--   - Only the owner should access/modify their lists
--   - anon role has no access (must be authenticated to generate lists)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select shopping_lists"
  on shopping_lists for select
  to anon
  using (false);

create policy "anon users cannot insert shopping_lists"
  on shopping_lists for insert
  to anon
  with check (false);

create policy "anon users cannot update shopping_lists"
  on shopping_lists for update
  to anon
  using (false);

create policy "anon users cannot delete shopping_lists"
  on shopping_lists for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on own lists
create policy "authenticated users can select own shopping_lists"
  on shopping_lists for select
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can select own shopping_lists" on shopping_lists is
  'Users can view only their own shopping lists (PRD FR-SHOPLIST-004: history of lists)';

create policy "authenticated users can insert own shopping_lists"
  on shopping_lists for insert
  to authenticated
  with check (auth.uid() = user_id);

comment on policy "authenticated users can insert own shopping_lists" on shopping_lists is
  'Users can create shopping lists only for themselves (PRD FR-SHOPLIST-001: generating list from calendar)';

create policy "authenticated users can update own shopping_lists"
  on shopping_lists for update
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can update own shopping_lists" on shopping_lists is
  'Users can update only their own shopping lists (e.g., updating week_start_date)';

create policy "authenticated users can delete own shopping_lists"
  on shopping_lists for delete
  to authenticated
  using (auth.uid() = user_id);

comment on policy "authenticated users can delete own shopping_lists" on shopping_lists is
  'Users can delete only their own shopping lists (removing old lists from history)';

-- =====================================================================================
-- SECTION 3: POLICIES FOR CHILD TABLES (JOIN to parent for ownership check)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Table: recipe_ingredients
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage ingredients only for their own recipes
-- Auth Check: EXISTS subquery with JOIN to recipes table
-- Rationale:
--   - recipe_ingredients has no user_id column (belongs to recipe, not directly to user)
--   - Ownership is transitive: recipe_ingredients → recipes → user
--   - Check via EXISTS (SELECT 1 FROM recipes WHERE id = recipe_id AND user_id = auth.uid())
-- Performance:
--   - EXISTS subquery uses idx_recipe_ingredients_recipe_id index
--   - JOIN to recipes table is fast (primary key lookup)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select recipe_ingredients"
  on recipe_ingredients for select
  to anon
  using (false);

create policy "anon users cannot insert recipe_ingredients"
  on recipe_ingredients for insert
  to anon
  with check (false);

create policy "anon users cannot update recipe_ingredients"
  on recipe_ingredients for update
  to anon
  using (false);

create policy "anon users cannot delete recipe_ingredients"
  on recipe_ingredients for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on ingredients of own recipes
create policy "authenticated users can select own recipe_ingredients"
  on recipe_ingredients for select
  to authenticated
  using (
    exists (
      select 1 from recipes
      where recipes.id = recipe_ingredients.recipe_id
        and recipes.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can select own recipe_ingredients" on recipe_ingredients is
  'Users can view ingredients only for their own recipes. Ownership checked via JOIN to recipes table (transitive: ingredient → recipe → user)';

create policy "authenticated users can insert own recipe_ingredients"
  on recipe_ingredients for insert
  to authenticated
  with check (
    exists (
      select 1 from recipes
      where recipes.id = recipe_ingredients.recipe_id
        and recipes.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can insert own recipe_ingredients" on recipe_ingredients is
  'Users can add ingredients only to their own recipes (PRD FR-RECIPE-001: AI parsing or manual addition). Prevents adding ingredients to other users recipes';

create policy "authenticated users can update own recipe_ingredients"
  on recipe_ingredients for update
  to authenticated
  using (
    exists (
      select 1 from recipes
      where recipes.id = recipe_ingredients.recipe_id
        and recipes.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can update own recipe_ingredients" on recipe_ingredients is
  'Users can edit ingredients only for their own recipes (PRD FR-RECIPE-006: editing ingredient quantities, units, categories)';

create policy "authenticated users can delete own recipe_ingredients"
  on recipe_ingredients for delete
  to authenticated
  using (
    exists (
      select 1 from recipes
      where recipes.id = recipe_ingredients.recipe_id
        and recipes.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can delete own recipe_ingredients" on recipe_ingredients is
  'Users can remove ingredients only from their own recipes (PRD FR-RECIPE-006: removing ingredient from recipe)';

-- -------------------------------------------------------------------------------------
-- Table: shopping_list_items
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage items only for their own shopping lists
-- Auth Check: EXISTS subquery with JOIN to shopping_lists table
-- Rationale:
--   - shopping_list_items has no user_id column (belongs to shopping_list, not directly to user)
--   - Ownership is transitive: shopping_list_items → shopping_lists → user
--   - Check via EXISTS (SELECT 1 FROM shopping_lists WHERE id = shopping_list_id AND user_id = auth.uid())
-- Performance:
--   - EXISTS subquery uses idx_shopping_list_items_list_id index
--   - JOIN to shopping_lists table is fast (primary key lookup)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select shopping_list_items"
  on shopping_list_items for select
  to anon
  using (false);

create policy "anon users cannot insert shopping_list_items"
  on shopping_list_items for insert
  to anon
  with check (false);

create policy "anon users cannot update shopping_list_items"
  on shopping_list_items for update
  to anon
  using (false);

create policy "anon users cannot delete shopping_list_items"
  on shopping_list_items for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on items of own shopping lists
create policy "authenticated users can select own shopping_list_items"
  on shopping_list_items for select
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_items.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can select own shopping_list_items" on shopping_list_items is
  'Users can view items only for their own shopping lists. Ownership checked via JOIN to shopping_lists table';

create policy "authenticated users can insert own shopping_list_items"
  on shopping_list_items for insert
  to authenticated
  with check (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_items.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can insert own shopping_list_items" on shopping_list_items is
  'Users can add items only to their own shopping lists (PRD FR-SHOPLIST-005: manually adding "free items" like toilet paper). Prevents adding items to other users lists';

create policy "authenticated users can update own shopping_list_items"
  on shopping_list_items for update
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_items.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can update own shopping_list_items" on shopping_list_items is
  'Users can edit items only for their own shopping lists (PRD FR-SHOPLIST-005: changing quantities, FR-SHOPLIST-006: checking/unchecking items)';

create policy "authenticated users can delete own shopping_list_items"
  on shopping_list_items for delete
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_items.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can delete own shopping_list_items" on shopping_list_items is
  'Users can remove items only from their own shopping lists (PRD FR-SHOPLIST-005: deleting item from list)';

-- -------------------------------------------------------------------------------------
-- Table: shopping_list_sources
-- -------------------------------------------------------------------------------------
-- Security Model: Users can manage sources only for their own shopping lists
-- Auth Check: EXISTS subquery with JOIN to shopping_lists table
-- Rationale:
--   - shopping_list_sources has no user_id column (belongs to shopping_list, not directly to user)
--   - Ownership is transitive: shopping_list_sources → shopping_lists → user
--   - Check via EXISTS (SELECT 1 FROM shopping_lists WHERE id = shopping_list_id AND user_id = auth.uid())
-- Performance:
--   - EXISTS subquery uses idx_shopping_list_sources_list_id index
--   - JOIN to shopping_lists table is fast (primary key lookup)
-- -------------------------------------------------------------------------------------

-- anon role: No access
create policy "anon users cannot select shopping_list_sources"
  on shopping_list_sources for select
  to anon
  using (false);

create policy "anon users cannot insert shopping_list_sources"
  on shopping_list_sources for insert
  to anon
  with check (false);

create policy "anon users cannot update shopping_list_sources"
  on shopping_list_sources for update
  to anon
  using (false);

create policy "anon users cannot delete shopping_list_sources"
  on shopping_list_sources for delete
  to anon
  using (false);

-- authenticated role: Full CRUD on sources of own shopping lists
create policy "authenticated users can select own shopping_list_sources"
  on shopping_list_sources for select
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_sources.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can select own shopping_list_sources" on shopping_list_sources is
  'Users can view sources only for their own shopping lists (PRD FR-SHOPLIST-007: tracking which meals were included)';

create policy "authenticated users can insert own shopping_list_sources"
  on shopping_list_sources for insert
  to authenticated
  with check (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_sources.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can insert own shopping_list_sources" on shopping_list_sources is
  'Users can add sources only to their own shopping lists (tracking meal origins during list generation)';

create policy "authenticated users can update own shopping_list_sources"
  on shopping_list_sources for update
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_sources.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can update own shopping_list_sources" on shopping_list_sources is
  'Users can edit sources only for their own shopping lists (edge case, usually read-only after creation)';

create policy "authenticated users can delete own shopping_list_sources"
  on shopping_list_sources for delete
  to authenticated
  using (
    exists (
      select 1 from shopping_lists
      where shopping_lists.id = shopping_list_sources.shopping_list_id
        and shopping_lists.user_id = auth.uid()
    )
  );

comment on policy "authenticated users can delete own shopping_list_sources" on shopping_list_sources is
  'Users can remove sources only from their own shopping lists (cleaning up source tracking)';

-- =====================================================================================
-- MIGRATION COMPLETE
-- =====================================================================================
-- RLS Policy Summary:
--   - 8 tables secured with RLS
--   - 64 total policies (8 tables × 4 operations × 2 roles)
--   - Complete data isolation: users cannot see/modify each other's data
--   - Enforced at database level (even with direct SQL access)
--
-- Testing RLS:
--   1. Test with different users: SET LOCAL request.jwt.claims.sub TO 'user-uuid';
--   2. Verify user A cannot see user B's data
--   3. Verify user A cannot insert/update/delete user B's data
--   4. Verify anon role has no access (all operations blocked)
--
-- Next steps:
--   1. Run triggers migration (20251018120003_triggers.sql)
--   2. Test RLS policies with sample data
--   3. Verify RODO compliance (user deletion cascades correctly)
-- =====================================================================================
