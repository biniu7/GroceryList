-- =====================================================================================
-- Migration: Initial Schema for GroceryList MVP
-- =====================================================================================
-- Description: Creates core database schema including ENUMs, tables, and constraints
-- Author: Database Team
-- Date: 2025-10-18
--
-- Tables Created:
--   - user_profiles (extended user data with AI parsing limits)
--   - recipes (user recipes with full text)
--   - recipe_ingredients (parsed or manual ingredients)
--   - calendar_template (repeating weekly meal pattern)
--   - calendar_instances (one-time calendar overrides)
--   - shopping_lists (generated shopping list history)
--   - shopping_list_items (aggregated ingredients + manual additions)
--   - shopping_list_sources (tracking which meals were included in list)
--
-- ENUMs Created:
--   - product_category (7 predefined categories for ingredient grouping)
--   - meal_type (4 daily meal types: breakfast, second breakfast, lunch, dinner)
--
-- Notes:
--   - All tables use UUID primary keys for security and compatibility with Supabase Auth
--   - Foreign keys implement appropriate ON DELETE CASCADE or SET NULL based on business logic
--   - RLS is NOT enabled in this migration (separate RLS migration file)
--   - Indexes are NOT created in this migration (separate indexes migration file)
-- =====================================================================================

-- =====================================================================================
-- SECTION 1: ENUM TYPES
-- =====================================================================================

-- product_category: Categories for ingredient grouping in shopping lists
-- Based on PRD FR-SHOPLIST-003 (7 predefined categories)
create type product_category as enum (
  'nabial',      -- dairy products
  'warzywa',     -- vegetables
  'owoce',       -- fruits
  'mieso',       -- meat
  'pieczywo',    -- bread and bakery
  'przyprawy',   -- spices and seasonings
  'inne'         -- other/uncategorized
);

comment on type product_category is 'Product categories for shopping list grouping (7 predefined categories from PRD FR-SHOPLIST-003)';

-- meal_type: Types of daily meals for calendar planning
-- Based on PRD FR-CALENDAR-001 (4 meals per day)
create type meal_type as enum (
  'sniadanie',          -- breakfast
  'drugie_sniadanie',   -- second breakfast
  'obiad',              -- lunch
  'kolacja'             -- dinner
);

comment on type meal_type is 'Types of daily meals (4 types as per PRD FR-CALENDAR-001)';

-- =====================================================================================
-- SECTION 2: CORE TABLES
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Table: user_profiles
-- -------------------------------------------------------------------------------------
-- Purpose: Extended user profile with business data (AI parsing limits, preferences)
-- Relationship: 1:1 with auth.users (managed by Supabase Auth)
-- ON DELETE: CASCADE - deleting Supabase auth account deletes profile (RODO compliance)
-- Notes:
--   - Automatically created via trigger when user registers (see triggers migration)
--   - ai_parsing_count tracks monthly AI usage (max 20 per PRD FR-RECIPE-003)
--   - ai_parsing_reset_date determines when counter resets (1st of next month)
-- -------------------------------------------------------------------------------------
create table user_profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid unique not null references auth.users(id) on delete cascade,
  ai_parsing_count int not null default 0 check (ai_parsing_count >= 0),
  ai_parsing_reset_date date not null default (current_date + interval '1 month'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table user_profiles is 'Extended user profile with business data (AI parsing limits, preferences)';
comment on column user_profiles.ai_parsing_count is 'Number of AI parsing operations used this month (max 20 per PRD FR-RECIPE-003)';
comment on column user_profiles.ai_parsing_reset_date is 'Date when ai_parsing_count resets to 0 (1st of next month)';

-- -------------------------------------------------------------------------------------
-- Table: recipes
-- -------------------------------------------------------------------------------------
-- Purpose: User recipes with full text and parsed ingredients
-- Relationship: N:1 with auth.users (user owns many recipes)
-- ON DELETE: CASCADE - deleting user deletes all their recipes
-- Notes:
--   - recipe_text max 5000 chars enforced in application (PRD US-037), not DB constraint
--   - name is required for display in lists and calendar
--   - Ingredients stored separately in recipe_ingredients table (1:N relationship)
-- -------------------------------------------------------------------------------------
create table recipes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name varchar(255) not null,
  recipe_text text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table recipes is 'User recipes with full text and parsed ingredients';
comment on column recipes.recipe_text is 'Full recipe text (max 5000 characters validated in application per PRD US-037)';
comment on column recipes.name is 'Recipe name for display in lists and calendar';

-- -------------------------------------------------------------------------------------
-- Table: recipe_ingredients
-- -------------------------------------------------------------------------------------
-- Purpose: Parsed or manually added recipe ingredients
-- Relationship: N:1 with recipes (recipe has many ingredients)
-- ON DELETE: CASCADE - deleting recipe deletes all its ingredients (strong dependency)
-- Notes:
--   - ingredient_name is denormalized (no separate ingredients table in MVP)
--   - quantity is nullable for items like "salt to taste" (PRD FR-RECIPE-001)
--   - unit is free text in MVP (ml, g, szklanka, łyżka, etc.) - no unit conversion
--   - category defaults to 'inne' if AI parsing fails to categorize
-- -------------------------------------------------------------------------------------
create table recipe_ingredients (
  id uuid primary key default gen_random_uuid(),
  recipe_id uuid not null references recipes(id) on delete cascade,
  ingredient_name varchar(255) not null,
  quantity decimal(10,2) check (quantity is null or quantity > 0),
  unit varchar(50),
  category product_category not null default 'inne',
  created_at timestamptz not null default now()
);

comment on table recipe_ingredients is 'Parsed or manually added recipe ingredients';
comment on column recipe_ingredients.ingredient_name is 'Ingredient name (denormalized, no separate ingredients table in MVP)';
comment on column recipe_ingredients.quantity is 'Quantity of ingredient (nullable for items like "salt to taste")';
comment on column recipe_ingredients.unit is 'Unit of measurement (ml, g, szklanka, łyżka, etc.) - free text in MVP, no conversion';
comment on column recipe_ingredients.category is 'Product category for shopping list grouping';

-- -------------------------------------------------------------------------------------
-- Table: calendar_template
-- -------------------------------------------------------------------------------------
-- Purpose: Weekly meal template (repeating pattern: "every Monday breakfast = scrambled eggs")
-- Relationship: N:1 with auth.users (user owns template), N:1 with recipes (template references recipes)
-- ON DELETE: CASCADE for user_id, SET NULL for recipe_id
-- Notes:
--   - day_of_week: 1=Monday, 2=Tuesday, ..., 7=Sunday (ISO 8601 standard)
--   - recipe_id can be NULL (empty meal slot)
--   - UNIQUE constraint ensures one recipe per (user, day, meal_type) slot
--   - If recipe is deleted, slot becomes empty (NULL) but template entry remains
-- -------------------------------------------------------------------------------------
create table calendar_template (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  day_of_week int not null check (day_of_week >= 1 and day_of_week <= 7),
  meal_type meal_type not null,
  recipe_id uuid references recipes(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, day_of_week, meal_type)
);

comment on table calendar_template is 'Weekly meal template (repeating pattern: "every Monday breakfast = scrambled eggs")';
comment on column calendar_template.day_of_week is '1=Monday, 2=Tuesday, ..., 7=Sunday (ISO 8601 standard)';
comment on column calendar_template.recipe_id is 'Recipe assigned to this meal slot (NULL = empty slot)';

-- -------------------------------------------------------------------------------------
-- Table: calendar_instances
-- -------------------------------------------------------------------------------------
-- Purpose: Calendar overrides for specific dates (one-time changes: "this Monday only")
-- Relationship: N:1 with auth.users (user owns instances), N:1 with recipes (instance references recipes)
-- ON DELETE: CASCADE for user_id, SET NULL for recipe_id
-- Business Logic: Application checks instances first; if no instance for date → fallback to template
-- Notes:
--   - date is specific date (e.g., 2025-10-21) not day_of_week
--   - recipe_id can be NULL (empty meal slot)
--   - UNIQUE constraint ensures one recipe per (user, date, meal_type) slot
--   - If recipe is deleted, slot becomes empty (NULL) but instance entry remains
-- -------------------------------------------------------------------------------------
create table calendar_instances (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  meal_type meal_type not null,
  recipe_id uuid references recipes(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, date, meal_type)
);

comment on table calendar_instances is 'Calendar overrides for specific dates (one-time changes: "this Monday only")';
comment on column calendar_instances.date is 'Specific date for this meal (e.g., 2025-10-21)';
comment on column calendar_instances.recipe_id is 'Recipe assigned to this meal slot (NULL = empty slot)';

-- -------------------------------------------------------------------------------------
-- Table: shopping_lists
-- -------------------------------------------------------------------------------------
-- Purpose: Generated shopping lists history
-- Relationship: N:1 with auth.users (user owns many shopping lists)
-- ON DELETE: CASCADE - deleting user deletes all their shopping lists
-- Notes:
--   - week_start_date and week_end_date are nullable (user may select partial week)
--   - No CHECK constraint on date range for flexibility (user can select any days)
--   - Items stored separately in shopping_list_items table (1:N relationship)
--   - Sources tracked in shopping_list_sources table (which meals were included)
-- -------------------------------------------------------------------------------------
create table shopping_lists (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  week_start_date date,
  week_end_date date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table shopping_lists is 'Generated shopping lists history';
comment on column shopping_lists.week_start_date is 'Start date of week (nullable - user may select partial week)';
comment on column shopping_lists.week_end_date is 'End date of week (nullable - user may select partial week)';

-- -------------------------------------------------------------------------------------
-- Table: shopping_list_items
-- -------------------------------------------------------------------------------------
-- Purpose: Shopping list items (aggregated ingredients + manual additions)
-- Relationship: N:1 with shopping_lists (list has many items)
-- ON DELETE: CASCADE - deleting shopping list deletes all its items
-- Snapshot Approach: Items are a copy of ingredients at generation time
--                    Editing recipe after list generation does NOT update old lists
-- Notes:
--   - ingredient_name is aggregated via LOWER(name) matching from multiple recipes
--   - quantity is sum of quantities from all recipes if same ingredient
--   - is_checked tracks "purchased" state (PRD FR-SHOPLIST-006)
--   - is_manual = TRUE if manually added by user, FALSE if from recipe aggregation
-- -------------------------------------------------------------------------------------
create table shopping_list_items (
  id uuid primary key default gen_random_uuid(),
  shopping_list_id uuid not null references shopping_lists(id) on delete cascade,
  ingredient_name varchar(255) not null,
  quantity decimal(10,2) check (quantity is null or quantity > 0),
  unit varchar(50),
  category product_category not null,
  is_checked boolean not null default false,
  is_manual boolean not null default false,
  created_at timestamptz not null default now()
);

comment on table shopping_list_items is 'Shopping list items (aggregated ingredients + manual additions)';
comment on column shopping_list_items.ingredient_name is 'Ingredient/product name (after aggregation via LOWER(name) matching)';
comment on column shopping_list_items.quantity is 'Aggregated quantity (sum from multiple recipes if same ingredient)';
comment on column shopping_list_items.is_checked is 'Checkbox state for "purchased" tracking (PRD FR-SHOPLIST-006)';
comment on column shopping_list_items.is_manual is 'TRUE if manually added by user (not from recipe), FALSE if from aggregation';

-- -------------------------------------------------------------------------------------
-- Table: shopping_list_sources
-- -------------------------------------------------------------------------------------
-- Purpose: Tracks which meals/recipes were included in shopping list generation
-- Relationship: N:1 with shopping_lists (list has many sources), N:1 with recipes (optional)
-- ON DELETE: CASCADE for shopping_list_id, SET NULL for recipe_id
-- Notes:
--   - meal_date and meal_type identify which meal was included
--   - recipe_id can be NULL if recipe was deleted after list generation
--   - Used for display: "List generated from: Monday breakfast (Scrambled eggs), Tuesday lunch (Soup)"
--   - No UNIQUE constraint - possible duplicates if user selects same recipe multiple times
-- -------------------------------------------------------------------------------------
create table shopping_list_sources (
  id uuid primary key default gen_random_uuid(),
  shopping_list_id uuid not null references shopping_lists(id) on delete cascade,
  meal_date date not null,
  meal_type meal_type not null,
  recipe_id uuid references recipes(id) on delete set null,
  created_at timestamptz not null default now()
);

comment on table shopping_list_sources is 'Tracks which meals/recipes were included in shopping list generation (PRD FR-SHOPLIST-007)';
comment on column shopping_list_sources.meal_date is 'Date of the meal included in list generation';
comment on column shopping_list_sources.meal_type is 'Type of meal (breakfast, lunch, etc.)';
comment on column shopping_list_sources.recipe_id is 'Recipe used (NULL if recipe was deleted after list generation)';

-- =====================================================================================
-- MIGRATION COMPLETE
-- =====================================================================================
-- Next steps:
--   1. Run indexes migration (20251018120001_indexes.sql)
--   2. Run RLS policies migration (20251018120002_rls_policies.sql)
--   3. Run triggers migration (20251018120003_triggers.sql)
-- =====================================================================================
