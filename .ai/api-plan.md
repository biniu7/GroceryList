# REST API Plan

**Project:** GroceryList MVP
**Version:** 1.0
**Date:** 2025-10-18
**Status:** Ready for Implementation

---

## 1. Resources

| Resource | Database Table | Description |
|----------|---------------|-------------|
| User Profile | `user_profiles` | Extended user profile with AI parsing limits |
| Recipe | `recipes` | User recipes with full text and metadata |
| Recipe Ingredient | `recipe_ingredients` | Individual ingredients belonging to recipes |
| Calendar Template | `calendar_template` | Repeating weekly meal pattern |
| Calendar Instance | `calendar_instances` | One-time calendar overrides for specific dates |
| Shopping List | `shopping_lists` | Generated shopping lists (history) |
| Shopping List Item | `shopping_list_items` | Individual items on shopping lists |
| Shopping List Source | `shopping_list_sources` | Tracking which meals contributed to list |

---

## 2. Endpoints

### 2.1 Authentication

Authentication is handled by Supabase Auth. API endpoints receive authenticated user context via middleware (`context.locals.supabase`).

#### Register User
**Handled by Supabase Auth SDK (client-side)**
- Method: POST
- Endpoint: Supabase Auth `/auth/v1/signup`
- Required: email, password
- Returns: User object + session tokens

#### Login
**Handled by Supabase Auth SDK (client-side)**
- Method: POST
- Endpoint: Supabase Auth `/auth/v1/token?grant_type=password`

#### Password Reset
**Handled by Supabase Auth SDK (client-side)**
- Method: POST
- Endpoint: Supabase Auth `/auth/v1/recover`

#### Delete Account
**Method:** DELETE
**Path:** `/api/user/account`
**Description:** Delete user account and all associated data (GDPR compliance)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Account deleted successfully"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 401 Unauthorized: Missing or invalid JWT token
- 500 Internal Server Error: Database error

---

### 2.2 User Profile

#### Get User Profile
**Method:** GET
**Path:** `/api/user/profile`
**Description:** Retrieve current user's profile including AI parsing limit status

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "ai_parsing_count": 5,
  "ai_parsing_limit": 20,
  "ai_parsing_reset_date": "2025-11-01",
  "created_at": "2025-10-01T10:00:00Z",
  "updated_at": "2025-10-18T14:30:00Z"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 401 Unauthorized
- 404 Not Found: Profile not found (auto-created on signup, should not occur)

---

#### Update User Profile
**Method:** PATCH
**Path:** `/api/user/profile`
**Description:** Update user profile (currently only used internally for AI parsing count)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "ai_parsing_count": 6
}
```

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "ai_parsing_count": 6,
  "ai_parsing_limit": 20,
  "ai_parsing_reset_date": "2025-11-01",
  "updated_at": "2025-10-18T14:35:00Z"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 400 Bad Request: Invalid data (e.g., negative count)
- 401 Unauthorized

---

### 2.3 Recipes

#### List Recipes
**Method:** GET
**Path:** `/api/recipes`
**Description:** Get all recipes for authenticated user

**Query Parameters:**
- `include_ingredients` (optional, boolean, default: false) - Include ingredients array in response

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "recipes": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "name": "Scrambled Eggs",
      "recipe_text": "Beat 3 eggs with salt...",
      "created_at": "2025-10-15T09:00:00Z",
      "updated_at": "2025-10-15T09:00:00Z",
      "ingredients": [
        {
          "id": "uuid",
          "ingredient_name": "eggs",
          "quantity": 3,
          "unit": "pcs",
          "category": "inne"
        }
      ]
    }
  ],
  "count": 15
}
```
**Status Code:** 200 OK

**Notes:**
- Sorted by `created_at DESC` (newest first)
- No pagination in MVP (expected max ~50 recipes per user)
- If `include_ingredients=false`, `ingredients` array is omitted

---

#### Get Recipe
**Method:** GET
**Path:** `/api/recipes/:id`
**Description:** Get single recipe with all ingredients

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "name": "Scrambled Eggs",
  "recipe_text": "Beat 3 eggs with salt...",
  "created_at": "2025-10-15T09:00:00Z",
  "updated_at": "2025-10-15T09:00:00Z",
  "ingredients": [
    {
      "id": "uuid",
      "recipe_id": "uuid",
      "ingredient_name": "eggs",
      "quantity": 3,
      "unit": "pcs",
      "category": "inne",
      "created_at": "2025-10-15T09:00:00Z"
    },
    {
      "id": "uuid",
      "recipe_id": "uuid",
      "ingredient_name": "salt",
      "quantity": null,
      "unit": null,
      "category": "przyprawy",
      "created_at": "2025-10-15T09:00:00Z"
    }
  ]
}
```
**Status Code:** 200 OK

**Error Responses:**
- 401 Unauthorized
- 404 Not Found: Recipe doesn't exist or doesn't belong to user

---

#### Create Recipe (Manual)
**Method:** POST
**Path:** `/api/recipes`
**Description:** Create recipe with manually entered ingredients (no AI parsing)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "name": "Scrambled Eggs",
  "recipe_text": "Beat 3 eggs with salt and pepper. Heat butter in pan...",
  "ingredients": [
    {
      "ingredient_name": "eggs",
      "quantity": 3,
      "unit": "pcs",
      "category": "inne"
    },
    {
      "ingredient_name": "butter",
      "quantity": 20,
      "unit": "g",
      "category": "nabial"
    }
  ]
}
```

**Validation:**
- `name`: required, max 255 characters
- `recipe_text`: required, max 5000 characters
- `ingredients`: optional array
- Each ingredient:
  - `ingredient_name`: required, max 255 characters
  - `quantity`: optional, must be > 0 if provided
  - `unit`: optional, max 50 characters
  - `category`: required, must be valid enum value

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "name": "Scrambled Eggs",
  "recipe_text": "Beat 3 eggs with salt and pepper...",
  "created_at": "2025-10-18T15:00:00Z",
  "updated_at": "2025-10-18T15:00:00Z",
  "ingredients": [
    {
      "id": "uuid",
      "recipe_id": "uuid",
      "ingredient_name": "eggs",
      "quantity": 3,
      "unit": "pcs",
      "category": "inne",
      "created_at": "2025-10-18T15:00:00Z"
    }
  ]
}
```
**Status Code:** 201 Created

**Error Responses:**
- 400 Bad Request: Validation errors
  ```json
  {
    "error": "Validation failed",
    "details": {
      "name": "Recipe name is required",
      "recipe_text": "Recipe text exceeds maximum length of 5000 characters"
    }
  }
  ```
- 401 Unauthorized

---

#### Parse Recipe with AI
**Method:** POST
**Path:** `/api/recipes/parse`
**Description:** Parse recipe text using AI to extract ingredients

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "recipe_text": "Beat 3 eggs with pinch of salt. Heat 20g butter in pan..."
}
```

**Business Logic:**
1. Check `user_profiles.ai_parsing_count < 20`
2. Check if `ai_parsing_reset_date <= CURRENT_DATE`, reset counter if true
3. Call AI API (OpenAI/Anthropic) to parse ingredients
4. Increment `ai_parsing_count` on success
5. Return parsed ingredients for user review

**Success Response:**
```json
{
  "ingredients": [
    {
      "ingredient_name": "eggs",
      "quantity": 3,
      "unit": "pcs",
      "category": "inne"
    },
    {
      "ingredient_name": "salt",
      "quantity": null,
      "unit": null,
      "category": "przyprawy"
    },
    {
      "ingredient_name": "butter",
      "quantity": 20,
      "unit": "g",
      "category": "nabial"
    }
  ],
  "parsing_count": 6,
  "parsing_limit": 20
}
```
**Status Code:** 200 OK

**Error Responses:**
- 400 Bad Request: Recipe text empty or exceeds 5000 characters
- 401 Unauthorized
- 429 Too Many Requests: AI parsing limit exceeded
  ```json
  {
    "error": "AI parsing limit exceeded",
    "message": "You have used 20/20 AI parsings this month. Limit resets on 2025-11-01.",
    "parsing_count": 20,
    "parsing_limit": 20,
    "reset_date": "2025-11-01"
  }
  ```
- 500 Internal Server Error: AI API failure
  ```json
  {
    "error": "AI parsing failed",
    "message": "Unable to parse ingredients. Please add them manually."
  }
  ```

**Notes:**
- This endpoint does NOT create a recipe, it only parses and returns ingredients
- User reviews ingredients in UI, then calls POST `/api/recipes` to save
- Parsing timeout: 10 seconds (AI should respond in 3-5s typically)

---

#### Update Recipe
**Method:** PUT
**Path:** `/api/recipes/:id`
**Description:** Update recipe and its ingredients

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "name": "Scrambled Eggs (Updated)",
  "recipe_text": "Updated text...",
  "ingredients": [
    {
      "id": "uuid",
      "ingredient_name": "eggs",
      "quantity": 4,
      "unit": "pcs",
      "category": "inne"
    },
    {
      "ingredient_name": "milk",
      "quantity": 50,
      "unit": "ml",
      "category": "nabial"
    }
  ]
}
```

**Business Logic:**
- Existing ingredients with `id` are updated
- Ingredients without `id` are created (new)
- Existing ingredients not in array are deleted
- No AI re-parsing (saves quota)

**Success Response:**
```json
{
  "id": "uuid",
  "name": "Scrambled Eggs (Updated)",
  "recipe_text": "Updated text...",
  "updated_at": "2025-10-18T16:00:00Z",
  "ingredients": [...]
}
```
**Status Code:** 200 OK

**Error Responses:**
- 400 Bad Request: Validation errors
- 401 Unauthorized
- 404 Not Found: Recipe doesn't exist or doesn't belong to user

---

#### Delete Recipe
**Method:** DELETE
**Path:** `/api/recipes/:id`
**Description:** Delete recipe

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Recipe deleted successfully"
}
```
**Status Code:** 200 OK

**Business Logic:**
- Database CASCADE deletes all `recipe_ingredients`
- Database SET NULL on `calendar_template.recipe_id` and `calendar_instances.recipe_id`
- Old `shopping_list_sources` keep reference (historical tracking)

**Error Responses:**
- 401 Unauthorized
- 404 Not Found

---

### 2.4 Calendar Template

#### Get Calendar Template
**Method:** GET
**Path:** `/api/calendar/template`
**Description:** Get user's weekly meal template (repeating pattern)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "template": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "day_of_week": 1,
      "meal_type": "sniadanie",
      "recipe_id": "uuid",
      "recipe": {
        "id": "uuid",
        "name": "Scrambled Eggs"
      },
      "created_at": "2025-10-15T10:00:00Z",
      "updated_at": "2025-10-15T10:00:00Z"
    }
  ]
}
```
**Status Code:** 200 OK

**Notes:**
- Returns all 28 possible slots (7 days × 4 meal types) if they exist
- Empty slots are not returned (client fills with null)
- `day_of_week`: 1 = Monday, 7 = Sunday (ISO 8601)
- `meal_type`: "sniadanie", "drugie_sniadanie", "obiad", "kolacja"

---

#### Set Calendar Template Slot
**Method:** PUT
**Path:** `/api/calendar/template`
**Description:** Assign recipe to template slot (repeating weekly)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "day_of_week": 1,
  "meal_type": "sniadanie",
  "recipe_id": "uuid"
}
```

**Validation:**
- `day_of_week`: required, 1-7
- `meal_type`: required, valid enum
- `recipe_id`: optional (null to clear slot)

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "day_of_week": 1,
  "meal_type": "sniadanie",
  "recipe_id": "uuid",
  "recipe": {
    "id": "uuid",
    "name": "Scrambled Eggs"
  },
  "updated_at": "2025-10-18T16:30:00Z"
}
```
**Status Code:** 200 OK

**Business Logic:**
- UPSERT operation (insert or update if exists)
- Unique constraint on (user_id, day_of_week, meal_type)
- If `recipe_id` is null, delete the template entry

**Error Responses:**
- 400 Bad Request: Validation errors
- 401 Unauthorized
- 404 Not Found: Recipe doesn't exist

---

#### Delete Calendar Template Slot
**Method:** DELETE
**Path:** `/api/calendar/template`
**Description:** Remove recipe from template slot

**Query Parameters:**
- `day_of_week` (required): 1-7
- `meal_type` (required): enum value

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Template slot cleared"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 400 Bad Request: Missing parameters
- 401 Unauthorized

---

### 2.5 Calendar Instances

#### Get Calendar Instances
**Method:** GET
**Path:** `/api/calendar/instances`
**Description:** Get calendar instances for specific date range

**Query Parameters:**
- `start_date` (required): ISO date (YYYY-MM-DD)
- `end_date` (required): ISO date (YYYY-MM-DD)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "instances": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "date": "2025-10-21",
      "meal_type": "sniadanie",
      "recipe_id": "uuid",
      "recipe": {
        "id": "uuid",
        "name": "Pancakes"
      },
      "created_at": "2025-10-18T10:00:00Z",
      "updated_at": "2025-10-18T10:00:00Z"
    }
  ]
}
```
**Status Code:** 200 OK

**Notes:**
- Returns only instances (overrides), not template
- Client merges with template to build full calendar view

---

#### Get Merged Calendar View
**Method:** GET
**Path:** `/api/calendar/week`
**Description:** Get complete calendar for a specific week (template + instances merged)

**Query Parameters:**
- `week_start` (required): ISO date (Monday of week, YYYY-MM-DD)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "week_start": "2025-10-20",
  "week_end": "2025-10-26",
  "meals": [
    {
      "date": "2025-10-20",
      "day_of_week": 1,
      "meal_type": "sniadanie",
      "recipe_id": "uuid",
      "recipe": {
        "id": "uuid",
        "name": "Scrambled Eggs"
      },
      "source": "template"
    },
    {
      "date": "2025-10-21",
      "day_of_week": 2,
      "meal_type": "sniadanie",
      "recipe_id": "uuid",
      "recipe": {
        "id": "uuid",
        "name": "Pancakes"
      },
      "source": "instance"
    }
  ]
}
```
**Status Code:** 200 OK

**Business Logic:**
1. Query template for user
2. Query instances for date range
3. Merge: instance overrides template
4. Return 28 slots (7 days × 4 meals), null if empty

---

#### Set Calendar Instance
**Method:** PUT
**Path:** `/api/calendar/instances`
**Description:** Assign recipe to specific date/meal (one-time override)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "date": "2025-10-21",
  "meal_type": "sniadanie",
  "recipe_id": "uuid"
}
```

**Validation:**
- `date`: required, valid ISO date
- `meal_type`: required, valid enum
- `recipe_id`: optional (null to clear)

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "date": "2025-10-21",
  "meal_type": "sniadanie",
  "recipe_id": "uuid",
  "recipe": {
    "id": "uuid",
    "name": "Pancakes"
  },
  "updated_at": "2025-10-18T17:00:00Z"
}
```
**Status Code:** 200 OK

**Business Logic:**
- UPSERT operation
- Unique constraint on (user_id, date, meal_type)
- If `recipe_id` is null, delete the instance

**Error Responses:**
- 400 Bad Request: Validation errors
- 401 Unauthorized
- 404 Not Found: Recipe doesn't exist

---

#### Delete Calendar Instance
**Method:** DELETE
**Path:** `/api/calendar/instances`
**Description:** Remove instance (revert to template)

**Query Parameters:**
- `date` (required): ISO date
- `meal_type` (required): enum value

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Instance removed, reverted to template"
}
```
**Status Code:** 200 OK

---

### 2.6 Shopping Lists

#### List Shopping Lists
**Method:** GET
**Path:** `/api/shopping-lists`
**Description:** Get all shopping lists for user (history)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "shopping_lists": [
    {
      "id": "uuid",
      "user_id": "uuid",
      "week_start_date": "2025-10-21",
      "week_end_date": "2025-10-27",
      "created_at": "2025-10-18T18:00:00Z",
      "updated_at": "2025-10-18T18:00:00Z",
      "items_count": 15,
      "checked_count": 8
    }
  ]
}
```
**Status Code:** 200 OK

**Notes:**
- Sorted by `created_at DESC` (newest first)
- Includes aggregated counts (items_count, checked_count)

---

#### Get Shopping List
**Method:** GET
**Path:** `/api/shopping-lists/:id`
**Description:** Get shopping list with all items and sources

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "week_start_date": "2025-10-21",
  "week_end_date": "2025-10-27",
  "created_at": "2025-10-18T18:00:00Z",
  "updated_at": "2025-10-18T18:00:00Z",
  "items": [
    {
      "id": "uuid",
      "shopping_list_id": "uuid",
      "ingredient_name": "eggs",
      "quantity": 12,
      "unit": "pcs",
      "category": "inne",
      "is_checked": false,
      "is_manual": false,
      "created_at": "2025-10-18T18:00:00Z"
    },
    {
      "id": "uuid",
      "shopping_list_id": "uuid",
      "ingredient_name": "milk",
      "quantity": 1,
      "unit": "l",
      "category": "nabial",
      "is_checked": true,
      "is_manual": false,
      "created_at": "2025-10-18T18:00:00Z"
    }
  ],
  "sources": [
    {
      "id": "uuid",
      "shopping_list_id": "uuid",
      "meal_date": "2025-10-21",
      "meal_type": "sniadanie",
      "recipe_id": "uuid",
      "recipe": {
        "id": "uuid",
        "name": "Scrambled Eggs"
      },
      "created_at": "2025-10-18T18:00:00Z"
    }
  ]
}
```
**Status Code:** 200 OK

**Error Responses:**
- 401 Unauthorized
- 404 Not Found

---

#### Create Shopping List
**Method:** POST
**Path:** `/api/shopping-lists`
**Description:** Generate shopping list from selected meals

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "meals": [
    {
      "date": "2025-10-21",
      "meal_type": "sniadanie"
    },
    {
      "date": "2025-10-21",
      "meal_type": "obiad"
    },
    {
      "date": "2025-10-22",
      "meal_type": "sniadanie"
    }
  ]
}
```

**Validation:**
- `meals`: required, non-empty array
- Each meal: valid date and meal_type

**Business Logic:**
1. For each meal, get recipe from calendar (instance takes precedence over template)
2. Collect all ingredients from selected recipes
3. Aggregate ingredients:
   - Group by `LOWER(ingredient_name)`, `unit`, `category`
   - Sum quantities where units match
   - Keep separate if units differ
4. Calculate `week_start_date` and `week_end_date` from meal dates
5. Create `shopping_list` record
6. Create `shopping_list_items` records (snapshot)
7. Create `shopping_list_sources` records for tracking

**Success Response:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "week_start_date": "2025-10-21",
  "week_end_date": "2025-10-22",
  "created_at": "2025-10-18T18:30:00Z",
  "items": [...],
  "sources": [...]
}
```
**Status Code:** 201 Created

**Error Responses:**
- 400 Bad Request: Validation errors, empty meals array
- 401 Unauthorized

---

#### Update Shopping List
**Method:** PATCH
**Path:** `/api/shopping-lists/:id`
**Description:** Update shopping list metadata (primarily for future features)

**Notes:** In MVP, lists are mostly immutable except for items. This endpoint is reserved for future use.

---

#### Delete Shopping List
**Method:** DELETE
**Path:** `/api/shopping-lists/:id`
**Description:** Delete shopping list

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Shopping list deleted"
}
```
**Status Code:** 200 OK

**Business Logic:**
- Database CASCADE deletes all items and sources

**Error Responses:**
- 401 Unauthorized
- 404 Not Found

---

### 2.7 Shopping List Items

#### Add Item to Shopping List
**Method:** POST
**Path:** `/api/shopping-lists/:id/items`
**Description:** Add manual item to shopping list

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "ingredient_name": "toilet paper",
  "quantity": 1,
  "unit": "pack",
  "category": "inne"
}
```

**Validation:**
- `ingredient_name`: required, max 255 characters
- `quantity`: optional, must be > 0 if provided
- `unit`: optional, max 50 characters
- `category`: required, valid enum

**Success Response:**
```json
{
  "id": "uuid",
  "shopping_list_id": "uuid",
  "ingredient_name": "toilet paper",
  "quantity": 1,
  "unit": "pack",
  "category": "inne",
  "is_checked": false,
  "is_manual": true,
  "created_at": "2025-10-18T19:00:00Z"
}
```
**Status Code:** 201 Created

**Error Responses:**
- 400 Bad Request: Validation errors
- 401 Unauthorized
- 404 Not Found: Shopping list doesn't exist

---

#### Update Shopping List Item
**Method:** PATCH
**Path:** `/api/shopping-lists/:listId/items/:itemId`
**Description:** Update item (quantity, category, checked status)

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>",
  "Content-Type": "application/json"
}
```

**Request Body:**
```json
{
  "quantity": 2,
  "unit": "packs",
  "category": "inne",
  "is_checked": true
}
```

**Success Response:**
```json
{
  "id": "uuid",
  "shopping_list_id": "uuid",
  "ingredient_name": "toilet paper",
  "quantity": 2,
  "unit": "packs",
  "category": "inne",
  "is_checked": true,
  "is_manual": true,
  "created_at": "2025-10-18T19:00:00Z"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 400 Bad Request: Validation errors
- 401 Unauthorized
- 404 Not Found

---

#### Delete Shopping List Item
**Method:** DELETE
**Path:** `/api/shopping-lists/:listId/items/:itemId`
**Description:** Remove item from shopping list

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response:**
```json
{
  "success": true,
  "message": "Item removed from shopping list"
}
```
**Status Code:** 200 OK

**Error Responses:**
- 401 Unauthorized
- 404 Not Found

---

### 2.8 Export

#### Export Shopping List
**Method:** GET
**Path:** `/api/shopping-lists/:id/export`
**Description:** Export shopping list to PDF or TXT

**Query Parameters:**
- `format` (required): "pdf" or "txt"

**Request Headers:**
```json
{
  "Authorization": "Bearer <jwt_token>"
}
```

**Success Response (PDF):**
- **Content-Type:** `application/pdf`
- **Content-Disposition:** `attachment; filename="lista-zakupow-2025-10-21.pdf"`
- **Body:** Binary PDF file

**Success Response (TXT):**
- **Content-Type:** `text/plain; charset=utf-8`
- **Content-Disposition:** `attachment; filename="lista-zakupow-2025-10-21.txt"`
- **Body:** Plain text file

**TXT Format Example:**
```
Lista zakupów na tydzień 2025-10-21 - 2025-10-27
Wygenerowano: 2025-10-18

NABIAŁ:
[ ] mleko - 1 l
[ ] butter - 100 g

WARZYWA:
[ ] tomatoes - 500 g
[ ] onion - 2 pcs

INNE:
[ ] eggs - 12 pcs
```

**PDF Format:**
- Clean, minimalist layout
- Sans-serif font, 12pt
- Empty checkbox (☐) before each item
- Category headers in bold
- Pagination if list is long

**Error Responses:**
- 400 Bad Request: Invalid format parameter
- 401 Unauthorized
- 404 Not Found: Shopping list doesn't exist
- 500 Internal Server Error: PDF generation failed

---

## 3. Authentication and Authorization

### 3.1 Authentication Mechanism

**Supabase Auth with JWT tokens**

- **Registration/Login:** Handled by Supabase Auth SDK (client-side)
- **Session Management:** JWT access token + refresh token
- **Token Storage:** httpOnly cookies (recommended) or localStorage
- **Token Expiration:** 1 hour (default), auto-refresh via refresh token

### 3.2 Authorization Flow

1. User logs in via Supabase Auth SDK
2. Supabase returns JWT access token + refresh token
3. Client includes token in `Authorization: Bearer <token>` header
4. Astro middleware validates token and injects `context.locals.supabase` client
5. All API routes access authenticated Supabase client from `context.locals`
6. Database RLS policies automatically filter by `auth.uid()`

### 3.3 Protected Routes

**All API endpoints require authentication** except:
- Supabase Auth endpoints (handled externally)
- Public landing page (if implemented)

**Implementation in Astro:**
```typescript
// src/middleware/index.ts
export async function onRequest(context, next) {
  const supabase = createSupabaseServerClient(context);
  const { data: { session } } = await supabase.auth.getSession();

  if (!session && context.url.pathname.startsWith('/api/')) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { 'Content-Type': 'application/json' }
    });
  }

  context.locals.supabase = supabase;
  context.locals.user = session?.user;
  return next();
}
```

### 3.4 Row Level Security (RLS)

**Database-level authorization enforced by PostgreSQL policies:**

- All user-owned tables have RLS enabled
- Policies enforce `auth.uid() = user_id` filter
- Child tables verify ownership via JOIN with parent
- API does NOT manually filter by user_id (RLS handles it)

**Example Policy:**
```sql
CREATE POLICY "Users can view own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);
```

**Benefits:**
- Authorization at database level (defense in depth)
- Prevents horizontal privilege escalation
- Simplifies API code (no manual filtering)

---

## 4. Validation and Business Logic

### 4.1 Input Validation

**All endpoints validate input using Zod schemas**

**Example Zod Schema:**
```typescript
import { z } from 'zod';

const createRecipeSchema = z.object({
  name: z.string().min(1).max(255),
  recipe_text: z.string().min(1).max(5000),
  ingredients: z.array(z.object({
    ingredient_name: z.string().min(1).max(255),
    quantity: z.number().positive().optional(),
    unit: z.string().max(50).optional(),
    category: z.enum(['nabial', 'warzywa', 'owoce', 'mieso', 'pieczywo', 'przyprawy', 'inne'])
  })).optional()
});
```

### 4.2 Validation Rules by Resource

#### User Profile
- `ai_parsing_count`: integer >= 0
- `ai_parsing_reset_date`: valid date, future date

#### Recipe
- `name`: required, max 255 chars
- `recipe_text`: required, max 5000 chars (US-037)

#### Recipe Ingredient
- `ingredient_name`: required, max 255 chars
- `quantity`: optional, must be > 0 if provided
- `unit`: optional, max 50 chars
- `category`: required, valid enum value

#### Calendar Template
- `day_of_week`: required, integer 1-7
- `meal_type`: required, valid enum ("sniadanie", "drugie_sniadanie", "obiad", "kolacja")
- `recipe_id`: optional UUID (null to clear slot)

#### Calendar Instance
- `date`: required, valid ISO date (YYYY-MM-DD)
- `meal_type`: required, valid enum
- `recipe_id`: optional UUID

#### Shopping List
- `meals`: required, non-empty array of {date, meal_type}

#### Shopping List Item
- `ingredient_name`: required, max 255 chars
- `quantity`: optional, must be > 0 if provided
- `unit`: optional, max 50 chars
- `category`: required, valid enum
- `is_checked`: boolean, default false

### 4.3 Business Logic Implementation

#### BL-1: AI Parsing Limit Enforcement
**Endpoint:** POST `/api/recipes/parse`

**Logic:**
1. Get `user_profiles` for authenticated user
2. Check if `ai_parsing_reset_date <= CURRENT_DATE`
   - If true: reset `ai_parsing_count = 0`, set `ai_parsing_reset_date = CURRENT_DATE + 1 month`
3. Check if `ai_parsing_count < 20`
   - If false: return 429 error with reset date
4. Call AI API with `recipe_text`
5. On success: increment `ai_parsing_count`
6. Return parsed ingredients

**Error Handling:**
- AI API timeout (10s): return 500 error, suggest manual entry
- AI API failure: return 500 error, do NOT increment counter
- Malformed AI response: return 500 error, log for debugging

---

#### BL-2: Calendar Template vs Instance Precedence
**Endpoint:** GET `/api/calendar/week`

**Logic:**
1. Query `calendar_template` for user
2. Query `calendar_instances` for date range [week_start, week_end]
3. For each day/meal slot:
   - If instance exists for that date/meal → use instance
   - Else if template exists for that day_of_week/meal → use template
   - Else → empty slot (null)
4. Return merged 28-slot array

**Client-Side Decision:**
- When user assigns/removes recipe, UI shows modal: "This week only or template?"
- Client calls appropriate endpoint (PUT `/api/calendar/template` or PUT `/api/calendar/instances`)

---

#### BL-3: Shopping List Ingredient Aggregation
**Endpoint:** POST `/api/shopping-lists`

**Logic:**
1. For each meal in request:
   - Get `date`, `meal_type`
   - Calculate `day_of_week` from date
   - Check `calendar_instances` for (user_id, date, meal_type)
   - If not found, check `calendar_template` for (user_id, day_of_week, meal_type)
   - Get `recipe_id`, fetch recipe with ingredients
2. Collect all ingredients from all selected recipes
3. Aggregate:
   ```sql
   SELECT
     LOWER(ingredient_name) as name,
     unit,
     SUM(quantity) as total_quantity,
     category
   FROM collected_ingredients
   GROUP BY LOWER(ingredient_name), unit, category
   ```
4. Create `shopping_lists` record with `week_start_date` (min date) and `week_end_date` (max date)
5. Insert aggregated ingredients into `shopping_list_items` (set `is_manual = false`)
6. Insert tracking records into `shopping_list_sources`
7. Return created shopping list with items and sources

**Aggregation Rules:**
- Case-insensitive name matching (LOWER())
- Only sum quantities if units match exactly
- If units differ, keep as separate items
- No intelligent unit conversion in MVP (ml → l, g → kg)

---

#### BL-4: Recipe Deletion Cascade
**Endpoint:** DELETE `/api/recipes/:id`

**Logic:**
- Database handles CASCADE for `recipe_ingredients` (ON DELETE CASCADE)
- Database handles SET NULL for `calendar_template.recipe_id` and `calendar_instances.recipe_id`
- `shopping_list_sources.recipe_id` is SET NULL (historical tracking preserved)
- Old `shopping_list_items` are NOT updated (snapshot approach)

**No API-level logic needed** - database constraints handle everything.

---

#### BL-5: Shopping List Snapshot Immutability
**Endpoint:** POST `/api/shopping-lists`

**Design Decision:**
- Shopping list items are a **snapshot** at time of generation
- Editing a recipe does NOT update old shopping lists
- This is intentional (users may have already shopped with old list)

**Implementation:**
- `shopping_list_items` table has no foreign key to `recipe_ingredients`
- Items are copied (denormalized) at creation time
- Old lists remain unchanged even if source recipes are modified/deleted

---

#### BL-6: AI Parsing Reset Schedule
**Trigger:** Checked on every POST `/api/recipes/parse` request

**Logic:**
```typescript
const today = new Date();
const resetDate = new Date(user_profile.ai_parsing_reset_date);

if (today >= resetDate) {
  // Reset counter
  await supabase
    .from('user_profiles')
    .update({
      ai_parsing_count: 0,
      ai_parsing_reset_date: new Date(today.getFullYear(), today.getMonth() + 1, 1) // First day of next month
    })
    .eq('user_id', user.id);
}
```

**Reset Date Calculation:**
- Initial: `CURRENT_DATE + INTERVAL '1 month'` (database default)
- After reset: First day of next month
- Example: User signs up on 2025-10-15 → reset date 2025-11-01 → next reset 2025-12-01

---

## 5. Error Handling

### 5.1 Standard Error Response Format

**All errors return JSON with consistent structure:**

```json
{
  "error": "Error type",
  "message": "Human-readable error message",
  "details": {
    "field": "Specific validation error"
  }
}
```

### 5.2 HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT, PATCH, DELETE |
| 201 | Created | Successful POST (resource created) |
| 400 | Bad Request | Validation errors, malformed request |
| 401 | Unauthorized | Missing or invalid JWT token |
| 403 | Forbidden | Authenticated but not authorized (rare with RLS) |
| 404 | Not Found | Resource doesn't exist or doesn't belong to user |
| 429 | Too Many Requests | Rate limit exceeded (AI parsing) |
| 500 | Internal Server Error | Database error, AI API failure |

### 5.3 Common Error Scenarios

#### Authentication Errors
```json
{
  "error": "Unauthorized",
  "message": "Invalid or missing authentication token"
}
```
**Status:** 401

---

#### Validation Errors
```json
{
  "error": "Validation failed",
  "message": "Request body contains invalid data",
  "details": {
    "name": "Recipe name is required",
    "recipe_text": "Recipe text exceeds maximum length of 5000 characters",
    "ingredients[0].quantity": "Quantity must be a positive number"
  }
}
```
**Status:** 400

---

#### Resource Not Found
```json
{
  "error": "Not found",
  "message": "Recipe not found or you don't have access to it"
}
```
**Status:** 404

---

#### AI Parsing Limit Exceeded
```json
{
  "error": "AI parsing limit exceeded",
  "message": "You have used 20/20 AI parsings this month. Limit resets on 2025-11-01.",
  "parsing_count": 20,
  "parsing_limit": 20,
  "reset_date": "2025-11-01"
}
```
**Status:** 429

---

#### AI Parsing Failure
```json
{
  "error": "AI parsing failed",
  "message": "Unable to parse ingredients from recipe text. Please add ingredients manually.",
  "ai_error": "API timeout"
}
```
**Status:** 500

---

#### Database Error
```json
{
  "error": "Internal server error",
  "message": "An unexpected error occurred. Please try again later.",
  "request_id": "uuid"
}
```
**Status:** 500

**Note:** Never expose internal database errors to client. Log full error server-side with request_id for debugging.

---

## 6. API Design Principles

### 6.1 REST Conventions

- **Resource-based URLs:** Nouns, not verbs (`/api/recipes`, not `/api/get-recipes`)
- **HTTP methods:** GET (read), POST (create), PUT (replace), PATCH (partial update), DELETE (remove)
- **Plural nouns:** `/api/recipes`, not `/api/recipe`
- **Nested resources:** `/api/shopping-lists/:id/items` for sub-resources
- **Query parameters:** For filtering, pagination (future), format selection

### 6.2 Idempotency

- **GET, PUT, DELETE:** Idempotent (same result on multiple calls)
- **POST:** Not idempotent (creates new resource each time)
- **PATCH:** Idempotent for this API (though not guaranteed by HTTP spec)

### 6.3 Versioning

**Version 1 (MVP):** No versioning
- All endpoints under `/api/`
- If breaking changes needed post-MVP, introduce `/api/v2/`

### 6.4 Rate Limiting

**Application-level:**
- AI parsing: 20 per user per month (enforced in business logic)

**Infrastructure-level (future):**
- General API: 100 requests per minute per IP (Vercel Edge Functions)
- Implement if abuse detected

### 6.5 Pagination

**Not implemented in MVP**
- Expected dataset size is small (~50 recipes, ~50 shopping lists per user)
- Add pagination post-MVP if needed: `?page=1&limit=20`

### 6.6 Filtering and Sorting

**Not implemented in MVP**
- Default sorting: `created_at DESC` (newest first)
- Post-MVP: Add query parameters like `?sort=name&order=asc`

### 6.7 CORS

**Configuration:**
- Allow origin: Frontend domain (e.g., `https://grocerylist.app`)
- Allow methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Allow headers: Authorization, Content-Type
- Allow credentials: true (for cookies)

**Astro Middleware:**
```typescript
export function onRequest(context, next) {
  const response = await next();
  response.headers.set('Access-Control-Allow-Origin', context.request.headers.get('Origin') || '*');
  response.headers.set('Access-Control-Allow-Credentials', 'true');
  return response;
}
```

---

## 7. Performance Considerations

### 7.1 Database Query Optimization

**Indexes (from db-plan.md):**
- `idx_recipes_user_created ON recipes(user_id, created_at DESC)` - Fast recipe listing
- `idx_calendar_template_user_day_meal ON calendar_template(user_id, day_of_week, meal_type)` - Fast template lookup
- `idx_calendar_instances_user_date_meal ON calendar_instances(user_id, date, meal_type)` - Fast instance lookup
- `idx_recipe_ingredients_name_lower ON recipe_ingredients(LOWER(ingredient_name))` - Fast aggregation

**N+1 Query Prevention:**
- Use Supabase `.select()` with joins to fetch related data
- Example: `recipes.select('*, ingredients(*)')` instead of separate queries

### 7.2 Caching

**Not implemented in MVP**
- RLS policies prevent simple caching (user-specific data)
- Post-MVP: Cache user profiles, template data (rarely changes)

### 7.3 AI API Optimization

**Timeout:** 10 seconds (AI should respond in 3-5s)
**Retry Logic:** No retries in MVP (fail fast, suggest manual entry)
**Cost Control:** 20 parsings per user per month

### 7.4 Export Generation

**PDF/TXT generation:**
- Server-side rendering (Astro API route)
- Use streaming for large lists (future optimization)
- Cache generated files for 5 minutes (optional)

---

## 8. Security Considerations

### 8.1 Input Sanitization

**Zod validation** handles type safety and format validation.

**XSS Prevention:**
- React auto-escapes JSX output
- Use DOMPurify for `recipe_text` if rendering HTML (currently plain text)

**SQL Injection Prevention:**
- Supabase client uses parameterized queries (safe by default)
- Never concatenate user input into raw SQL

### 8.2 CSRF Protection

**Supabase session cookies** use `SameSite=Lax` (CSRF protection for state-changing requests)

**Additional measures (if needed):**
- CSRF tokens in forms (Astro can generate tokens)
- Double-submit cookie pattern

### 8.3 Rate Limiting

**AI Parsing:** Enforced at application level (20/month)

**General API (future):**
- Implement rate limiting middleware (e.g., `astro-rate-limit`)
- Limit: 100 requests/minute per user

### 8.4 Sensitive Data

**Never expose in API responses:**
- User passwords (hashed by Supabase Auth)
- JWT refresh tokens (httpOnly cookies only)
- Internal database IDs (UUIDs are safe)

**Logging:**
- Log errors server-side with request_id
- Never log passwords, tokens, or PII

### 8.5 HTTPS

**Required in production:**
- Vercel/Netlify enforce HTTPS by default
- All API calls over TLS 1.3

---

## 9. Testing Strategy

### 9.1 Unit Tests

**Test Zod schemas:**
- Valid input passes
- Invalid input throws validation error

**Test business logic:**
- AI parsing counter increment
- Calendar template/instance precedence
- Shopping list aggregation

### 9.2 Integration Tests

**Test API endpoints:**
- Authentication (valid token, invalid token, missing token)
- CRUD operations (create, read, update, delete)
- RLS enforcement (user A cannot access user B's data)

**Tools:**
- Vitest for unit tests
- Playwright or Cypress for E2E tests

### 9.3 Manual Testing Checklist

- [ ] Register new user (Supabase Auth)
- [ ] Create recipe with AI parsing (success path)
- [ ] Create recipe with AI parsing (limit exceeded)
- [ ] Create recipe manually (no AI)
- [ ] Edit recipe (ingredients update)
- [ ] Delete recipe (check calendar is nullified)
- [ ] Set calendar template slot
- [ ] Set calendar instance (override template)
- [ ] Get merged calendar view
- [ ] Generate shopping list (check aggregation)
- [ ] Add manual item to shopping list
- [ ] Check/uncheck items
- [ ] Export to PDF
- [ ] Export to TXT
- [ ] Delete account (all data removed)

---

## 10. API Endpoint Summary Table

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| DELETE | `/api/user/account` | Delete user account | Yes |
| GET | `/api/user/profile` | Get user profile | Yes |
| PATCH | `/api/user/profile` | Update user profile | Yes |
| GET | `/api/recipes` | List all recipes | Yes |
| GET | `/api/recipes/:id` | Get single recipe | Yes |
| POST | `/api/recipes` | Create recipe (manual) | Yes |
| POST | `/api/recipes/parse` | Parse recipe with AI | Yes |
| PUT | `/api/recipes/:id` | Update recipe | Yes |
| DELETE | `/api/recipes/:id` | Delete recipe | Yes |
| GET | `/api/calendar/template` | Get calendar template | Yes |
| PUT | `/api/calendar/template` | Set template slot | Yes |
| DELETE | `/api/calendar/template` | Clear template slot | Yes |
| GET | `/api/calendar/instances` | Get calendar instances | Yes |
| GET | `/api/calendar/week` | Get merged calendar view | Yes |
| PUT | `/api/calendar/instances` | Set instance slot | Yes |
| DELETE | `/api/calendar/instances` | Clear instance slot | Yes |
| GET | `/api/shopping-lists` | List all shopping lists | Yes |
| GET | `/api/shopping-lists/:id` | Get shopping list details | Yes |
| POST | `/api/shopping-lists` | Generate shopping list | Yes |
| DELETE | `/api/shopping-lists/:id` | Delete shopping list | Yes |
| POST | `/api/shopping-lists/:id/items` | Add manual item | Yes |
| PATCH | `/api/shopping-lists/:listId/items/:itemId` | Update item | Yes |
| DELETE | `/api/shopping-lists/:listId/items/:itemId` | Delete item | Yes |
| GET | `/api/shopping-lists/:id/export` | Export to PDF/TXT | Yes |

**Total Endpoints:** 23

---

## 11. Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Set up Astro project with TypeScript
- [ ] Configure Supabase client in middleware
- [ ] Implement authentication middleware
- [ ] Create error handling utilities
- [ ] Set up Zod validation schemas

### Phase 2: User & Recipe Management (Week 2-3)
- [ ] Implement `/api/user/profile` endpoints
- [ ] Implement `/api/recipes` CRUD endpoints
- [ ] Integrate AI parsing API (OpenAI/Anthropic)
- [ ] Implement AI parsing limit logic
- [ ] Test recipe CRUD with RLS

### Phase 3: Calendar System (Week 4-5)
- [ ] Implement `/api/calendar/template` endpoints
- [ ] Implement `/api/calendar/instances` endpoints
- [ ] Implement `/api/calendar/week` merged view
- [ ] Test template vs instance precedence
- [ ] Test calendar with recipe deletion

### Phase 4: Shopping Lists (Week 6-7)
- [ ] Implement `/api/shopping-lists` generation endpoint
- [ ] Implement ingredient aggregation logic
- [ ] Implement `/api/shopping-lists/:id/items` CRUD
- [ ] Test aggregation with various scenarios
- [ ] Test shopping list snapshot immutability

### Phase 5: Export & Polish (Week 8)
- [ ] Implement PDF export (jsPDF or PDFKit)
- [ ] Implement TXT export (plain text formatting)
- [ ] Test exports with various list sizes
- [ ] Add rate limiting middleware
- [ ] Final security audit (CSRF, XSS, RLS)
- [ ] Performance testing with realistic data

### Phase 6: Documentation & Testing (Week 9)
- [ ] Write API integration tests
- [ ] Manual E2E testing with checklist
- [ ] Update API documentation with examples
- [ ] Create Postman/Insomnia collection
- [ ] Deployment to staging environment

---

## 12. Dependencies

### Required NPM Packages

**Core:**
- `@astrojs/node` - Node.js adapter for standalone server
- `@supabase/supabase-js` - Supabase client
- `@supabase/ssr` - Supabase SSR helpers for Astro

**Validation:**
- `zod` - Schema validation

**AI Integration:**
- `openai` or `@anthropic-ai/sdk` - AI API client

**Export:**
- `jspdf` or `pdfkit` - PDF generation
- `pdfkit` likely better for server-side (Node.js)

**Development:**
- `vitest` - Unit testing
- `@playwright/test` - E2E testing (optional)

---

## 13. Future API Enhancements (Post-MVP)

### v1.1 Features
- [ ] Pagination for recipes and shopping lists (`?page=1&limit=20`)
- [ ] Search/filter recipes by name (`?search=eggs`)
- [ ] Sort recipes by name, date (`?sort=name&order=asc`)
- [ ] Batch operations (delete multiple recipes)

### v1.2 Features
- [ ] Recipe sharing between users (public links)
- [ ] Import recipes from URL (web scraping)
- [ ] Smart unit conversion (ml → l, g → kg)
- [ ] Recipe categories/tags

### v2.0 Features
- [ ] Real-time collaboration (Supabase Realtime)
- [ ] Mobile API optimizations (GraphQL?)
- [ ] Advanced analytics (most used ingredients, cost estimation)
- [ ] Integration with external grocery APIs

---

## Appendix A: Sample API Calls

### A.1 Complete Recipe Creation Flow

**Step 1: Parse recipe with AI**
```bash
POST /api/recipes/parse
Authorization: Bearer <token>
Content-Type: application/json

{
  "recipe_text": "Beat 3 eggs with pinch of salt. Heat 20g butter in pan. Cook eggs until done."
}

# Response
{
  "ingredients": [
    {"ingredient_name": "eggs", "quantity": 3, "unit": "pcs", "category": "inne"},
    {"ingredient_name": "salt", "quantity": null, "unit": null, "category": "przyprawy"},
    {"ingredient_name": "butter", "quantity": 20, "unit": "g", "category": "nabial"}
  ],
  "parsing_count": 6,
  "parsing_limit": 20
}
```

**Step 2: User reviews ingredients in UI, then creates recipe**
```bash
POST /api/recipes
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Scrambled Eggs",
  "recipe_text": "Beat 3 eggs with pinch of salt. Heat 20g butter in pan. Cook eggs until done.",
  "ingredients": [
    {"ingredient_name": "eggs", "quantity": 3, "unit": "pcs", "category": "inne"},
    {"ingredient_name": "salt", "quantity": null, "unit": null, "category": "przyprawy"},
    {"ingredient_name": "butter", "quantity": 20, "unit": "g", "category": "nabial"}
  ]
}

# Response: 201 Created + recipe object
```

---

### A.2 Complete Shopping List Generation Flow

**Step 1: Get calendar for week**
```bash
GET /api/calendar/week?week_start=2025-10-20
Authorization: Bearer <token>

# Response: Merged calendar (template + instances)
```

**Step 2: User selects meals in UI, generates list**
```bash
POST /api/shopping-lists
Authorization: Bearer <token>
Content-Type: application/json

{
  "meals": [
    {"date": "2025-10-21", "meal_type": "sniadanie"},
    {"date": "2025-10-21", "meal_type": "obiad"},
    {"date": "2025-10-22", "meal_type": "sniadanie"}
  ]
}

# Response: 201 Created + shopping list with aggregated items
```

**Step 3: User adds manual item**
```bash
POST /api/shopping-lists/{list_id}/items
Authorization: Bearer <token>
Content-Type: application/json

{
  "ingredient_name": "toilet paper",
  "quantity": 1,
  "unit": "pack",
  "category": "inne"
}

# Response: 201 Created + new item
```

**Step 4: User exports to PDF**
```bash
GET /api/shopping-lists/{list_id}/export?format=pdf
Authorization: Bearer <token>

# Response: Binary PDF file download
```

---

## Appendix B: Database Schema Reference

**Refer to:** `.ai/db-plan.md` for complete schema

**Key Tables:**
- `user_profiles` - AI parsing limits
- `recipes` - Recipe text and metadata
- `recipe_ingredients` - Individual ingredients
- `calendar_template` - Weekly repeating pattern
- `calendar_instances` - One-time overrides
- `shopping_lists` - Generated lists
- `shopping_list_items` - Aggregated ingredients snapshot
- `shopping_list_sources` - Meal tracking

**ENUMs:**
- `product_category`: nabial, warzywa, owoce, mieso, pieczywo, przyprawy, inne
- `meal_type`: sniadanie, drugie_sniadanie, obiad, kolacja

---

**Document Status:** Ready for Implementation
**Next Steps:**
1. Generate Supabase migration files
2. Implement API routes in Astro
3. Write integration tests
4. Deploy to staging

---

**Prepared by:** Claude Code
**Source:** Database Plan, PRD v2.0, Tech Stack Analysis
**Date:** 2025-10-18
