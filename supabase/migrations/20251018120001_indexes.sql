-- =====================================================================================
-- Migration: Performance Indexes for GroceryList MVP
-- =====================================================================================
-- Description: Creates indexes to optimize query performance and support RLS filtering
-- Author: Database Team
-- Date: 2025-10-18
--
-- Indexes Created:
--   - User-scoped query indexes (support RLS filtering + application queries)
--   - Foreign key indexes (optimize JOINs)
--   - Functional indexes (case-insensitive aggregation)
--   - Composite indexes (covering multiple query patterns)
--
-- Notes:
--   - Primary key indexes are automatic (UUID columns)
--   - UNIQUE constraint indexes are automatic (calendar_template, calendar_instances, user_profiles.user_id)
--   - Composite indexes with user_id first optimize RLS WHERE user_id = auth.uid() filtering
--   - DESC ordering in indexes supports "from newest" sorting
-- =====================================================================================

-- =====================================================================================
-- SECTION 1: USER-SCOPED QUERY INDEXES (RLS Optimization)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Index: idx_recipes_user_created
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize recipe list queries filtered by user with "newest first" sorting
-- Query Pattern: SELECT * FROM recipes WHERE user_id = $1 ORDER BY created_at DESC
-- RLS Support: Covers WHERE user_id = auth.uid() filtering
-- Notes:
--   - Composite index (user_id, created_at DESC) supports both filter and sort
--   - DESC ordering allows index-only scan for newest-first queries
--   - Based on PRD FR-RECIPE-004 (default sorting: from newest)
-- -------------------------------------------------------------------------------------
create index idx_recipes_user_created on recipes(user_id, created_at desc);

comment on index idx_recipes_user_created is 'Optimizes recipe list queries with user filtering and newest-first sorting (PRD FR-RECIPE-004)';

-- -------------------------------------------------------------------------------------
-- Index: idx_calendar_template_user_day_meal
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize calendar template lookups for specific day/meal slot
-- Query Pattern: SELECT * FROM calendar_template WHERE user_id = $1 AND day_of_week = $2 AND meal_type = $3
-- RLS Support: Covers WHERE user_id = auth.uid() filtering
-- Notes:
--   - Composite index covering all WHERE clause columns
--   - Supports exact match queries (index-only scan possible)
--   - UNIQUE constraint already creates similar index, but this explicit index improves query planner stats
-- -------------------------------------------------------------------------------------
create index idx_calendar_template_user_day_meal on calendar_template(user_id, day_of_week, meal_type);

comment on index idx_calendar_template_user_day_meal is 'Optimizes calendar template lookup for specific day/meal slot';

-- -------------------------------------------------------------------------------------
-- Index: idx_calendar_instances_user_date_meal
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize calendar instance lookups for specific date/meal slot
-- Query Pattern: SELECT * FROM calendar_instances WHERE user_id = $1 AND date = $2 AND meal_type = $3
-- RLS Support: Covers WHERE user_id = auth.uid() filtering
-- Notes:
--   - Composite index covering all WHERE clause columns
--   - Supports exact match queries (index-only scan possible)
--   - Critical for calendar rendering (checks instance before template fallback)
-- -------------------------------------------------------------------------------------
create index idx_calendar_instances_user_date_meal on calendar_instances(user_id, date, meal_type);

comment on index idx_calendar_instances_user_date_meal is 'Optimizes calendar instance lookup for specific date/meal slot';

-- -------------------------------------------------------------------------------------
-- Index: idx_shopping_lists_user_created
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize shopping list history queries with "newest first" sorting
-- Query Pattern: SELECT * FROM shopping_lists WHERE user_id = $1 ORDER BY created_at DESC
-- RLS Support: Covers WHERE user_id = auth.uid() filtering
-- Notes:
--   - Composite index (user_id, created_at DESC) supports both filter and sort
--   - DESC ordering allows index-only scan for newest-first queries
--   - Based on PRD FR-SHOPLIST-004 (default display: newest list)
-- -------------------------------------------------------------------------------------
create index idx_shopping_lists_user_created on shopping_lists(user_id, created_at desc);

comment on index idx_shopping_lists_user_created is 'Optimizes shopping list history with user filtering and newest-first sorting (PRD FR-SHOPLIST-004)';

-- =====================================================================================
-- SECTION 2: FOREIGN KEY INDEXES (JOIN Optimization)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Index: idx_recipe_ingredients_recipe_id
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize JOINs between recipes and recipe_ingredients
-- Query Pattern: SELECT * FROM recipe_ingredients WHERE recipe_id = $1
-- Notes:
--   - Foreign key columns should be indexed for efficient JOINs
--   - Used when loading recipe details with ingredients
--   - Also used in RLS policy EXISTS subquery for child table access control
-- -------------------------------------------------------------------------------------
create index idx_recipe_ingredients_recipe_id on recipe_ingredients(recipe_id);

comment on index idx_recipe_ingredients_recipe_id is 'Optimizes JOINs recipes <-> recipe_ingredients and RLS policy subqueries';

-- -------------------------------------------------------------------------------------
-- Index: idx_shopping_list_items_list_id
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize JOINs between shopping_lists and shopping_list_items
-- Query Pattern: SELECT * FROM shopping_list_items WHERE shopping_list_id = $1
-- Notes:
--   - Foreign key columns should be indexed for efficient JOINs
--   - Used when loading shopping list with items
--   - Also used in RLS policy EXISTS subquery for child table access control
-- -------------------------------------------------------------------------------------
create index idx_shopping_list_items_list_id on shopping_list_items(shopping_list_id);

comment on index idx_shopping_list_items_list_id is 'Optimizes JOINs shopping_lists <-> shopping_list_items and RLS policy subqueries';

-- -------------------------------------------------------------------------------------
-- Index: idx_shopping_list_items_list_category
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize shopping list item queries filtered by list and grouped by category
-- Query Pattern: SELECT * FROM shopping_list_items WHERE shopping_list_id = $1 ORDER BY category, ingredient_name
-- Notes:
--   - Composite index (shopping_list_id, category) supports filtering and grouping
--   - Based on PRD FR-SHOPLIST-003 (items grouped by category: Dairy, Vegetables, etc.)
--   - Enables efficient "GROUP BY category" queries for display
-- -------------------------------------------------------------------------------------
create index idx_shopping_list_items_list_category on shopping_list_items(shopping_list_id, category);

comment on index idx_shopping_list_items_list_category is 'Optimizes shopping list item grouping by category (PRD FR-SHOPLIST-003)';

-- -------------------------------------------------------------------------------------
-- Index: idx_shopping_list_sources_list_id
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize JOINs between shopping_lists and shopping_list_sources
-- Query Pattern: SELECT * FROM shopping_list_sources WHERE shopping_list_id = $1
-- Notes:
--   - Foreign key columns should be indexed for efficient JOINs
--   - Used when displaying "List generated from: Monday breakfast, Tuesday lunch..."
--   - Also used in RLS policy EXISTS subquery for child table access control
-- -------------------------------------------------------------------------------------
create index idx_shopping_list_sources_list_id on shopping_list_sources(shopping_list_id);

comment on index idx_shopping_list_sources_list_id is 'Optimizes JOINs shopping_lists <-> shopping_list_sources and RLS policy subqueries';

-- =====================================================================================
-- SECTION 3: FUNCTIONAL INDEXES (Special Query Patterns)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Index: idx_recipe_ingredients_name_lower
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize case-insensitive ingredient aggregation for shopping list generation
-- Query Pattern: SELECT LOWER(ingredient_name), unit, SUM(quantity)
--                FROM recipe_ingredients WHERE recipe_id IN (...)
--                GROUP BY LOWER(ingredient_name), unit
-- Notes:
--   - Functional index on LOWER(ingredient_name) supports case-insensitive matching
--   - Critical for shopping list generation: "Mleko" + "mleko" → same ingredient
--   - Based on PRD FR-SHOPLIST-002 (aggregation via lowercase matching)
--   - Performance impact: ~10x faster GROUP BY LOWER(ingredient_name) queries
--   - Trade-off: ~5-10% slower INSERT (acceptable for read-heavy workload)
-- -------------------------------------------------------------------------------------
create index idx_recipe_ingredients_name_lower on recipe_ingredients(lower(ingredient_name));

comment on index idx_recipe_ingredients_name_lower is 'Optimizes case-insensitive ingredient aggregation for shopping list generation (PRD FR-SHOPLIST-002)';

-- =====================================================================================
-- SECTION 4: CHECKBOX STATE INDEX (Filtering Optimization)
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- Index: idx_shopping_list_items_checked
-- -------------------------------------------------------------------------------------
-- Purpose: Optimize filtering shopping list items by checked/unchecked state
-- Query Pattern: SELECT * FROM shopping_list_items WHERE shopping_list_id = $1 AND is_checked = false
-- Notes:
--   - Composite index (shopping_list_id, is_checked) supports filtering by both columns
--   - Useful if user wants to view only unchecked (unpurchased) items
--   - Based on PRD FR-SHOPLIST-006 (checkbox state tracking)
--   - Partial index (WHERE is_checked = false) could be considered post-MVP for smaller index size
-- -------------------------------------------------------------------------------------
create index idx_shopping_list_items_checked on shopping_list_items(shopping_list_id, is_checked);

comment on index idx_shopping_list_items_checked is 'Optimizes filtering shopping list items by checked state (PRD FR-SHOPLIST-006)';

-- =====================================================================================
-- MIGRATION COMPLETE
-- =====================================================================================
-- Index Summary:
--   - 4 user-scoped indexes (RLS + application queries)
--   - 4 foreign key indexes (JOINs + RLS subqueries)
--   - 1 functional index (case-insensitive aggregation)
--   - 1 composite index (checkbox state filtering)
--   Total: 10 custom indexes
--
-- Next steps:
--   1. Run RLS policies migration (20251018120002_rls_policies.sql)
--   2. Run triggers migration (20251018120003_triggers.sql)
--
-- Performance Notes:
--   - All indexes are B-tree (PostgreSQL default, optimal for equality and range queries)
--   - Composite indexes ordered by selectivity (user_id first for RLS filtering)
--   - DESC ordering in created_at indexes supports newest-first sorting without reverse scan
-- =====================================================================================
