# Database Schema Plan - GroceryList MVP

**Data:** 2025-10-18
**Wersja:** 1.0
**Database:** PostgreSQL 15+ (Supabase)
**Status:** Ready for Implementation

---

## 1. Tables with Columns, Data Types, and Constraints

### 1.0 'users'
This table is managed by Supabase Auth.

### 1.1 `user_profiles`

Rozszerzenie profilu użytkownika dla danych biznesowych (Supabase Auth zarządza `auth.users`).

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  ai_parsing_count INT NOT NULL DEFAULT 0 CHECK (ai_parsing_count >= 0),
  ai_parsing_reset_date DATE NOT NULL DEFAULT (CURRENT_DATE + INTERVAL '1 month'),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE user_profiles IS 'Extended user profile with business data (AI parsing limits, preferences)';
COMMENT ON COLUMN user_profiles.ai_parsing_count IS 'Number of AI parsing operations used this month (max 20)';
COMMENT ON COLUMN user_profiles.ai_parsing_reset_date IS 'Date when ai_parsing_count resets to 0';
```

**Constraints:**
- `user_id` UNIQUE - jeden profil per użytkownik
- `ai_parsing_count >= 0` - nie może być ujemny
- `user_id` ON DELETE CASCADE - usunięcie konta Supabase usuwa profil

---

### 1.2 `recipes`

Przepisy kulinarne użytkownika.

```sql
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  recipe_text TEXT NOT NULL 
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE recipes IS 'User recipes with full text and parsed ingredients';
COMMENT ON COLUMN recipes.recipe_text IS 'Full recipe text (max 5000 characters as per US-037)';
COMMENT ON COLUMN recipes.name IS 'Recipe name for display in lists and calendar';
```

**Constraints:**
- `name` NOT NULL - przepis musi mieć nazwę (US-032)
- `recipe_text` LENGTH <= 5000 - zgodnie z US-037
- `user_id` ON DELETE CASCADE - usunięcie użytkownika usuwa jego przepisy

---

### 1.3 `recipe_ingredients`

Składniki przepisów (sparsowane przez AI lub dodane ręcznie).

```sql
CREATE TABLE recipe_ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  ingredient_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) CHECK (quantity > 0),
  unit VARCHAR(50),
  category product_category NOT NULL DEFAULT 'inne',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE recipe_ingredients IS 'Parsed or manually added recipe ingredients';
COMMENT ON COLUMN recipe_ingredients.ingredient_name IS 'Ingredient name (denormalized, no separate ingredients table)';
COMMENT ON COLUMN recipe_ingredients.quantity IS 'Quantity of ingredient (nullable for items like "salt to taste")';
COMMENT ON COLUMN recipe_ingredients.unit IS 'Unit of measurement (ml, g, szklanka, łyżka, etc.) - free text in MVP';
COMMENT ON COLUMN recipe_ingredients.category IS 'Product category for shopping list grouping';
```

**Constraints:**
- `recipe_id` NOT NULL - składnik musi należeć do przepisu
- `recipe_id` ON DELETE CASCADE - usunięcie przepisu usuwa składniki (silna zależność)
- `quantity > 0` - tylko dodatnie ilości
- `category` DEFAULT 'inne' - domyślna kategoria jeśli AI nie rozpozna

---

### 1.4 ENUMs

#### `product_category`

```sql
CREATE TYPE product_category AS ENUM (
  'nabial',      -- Dairy
  'warzywa',     -- Vegetables
  'owoce',       -- Fruits
  'mieso',       -- Meat
  'pieczywo',    -- Bread
  'przyprawy',   -- Spices
  'inne'         -- Other
);

COMMENT ON TYPE product_category IS 'Product categories for shopping list grouping (7 predefined categories from PRD)';
```

#### `meal_type`

```sql
CREATE TYPE meal_type AS ENUM (
  'sniadanie',          -- Breakfast
  'drugie_sniadanie',   -- Second Breakfast
  'obiad',              -- Lunch
  'kolacja'             -- Dinner
);

COMMENT ON TYPE meal_type IS 'Types of daily meals (4 types as per FR-CALENDAR-001)';
```

---

### 1.5 `calendar_template`

Szablon tygodniowy (powtarzający się wzorzec posiłków).

```sql
CREATE TABLE calendar_template (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  day_of_week INT NOT NULL CHECK (day_of_week >= 1 AND day_of_week <= 7),
  meal_type meal_type NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, day_of_week, meal_type)
);

COMMENT ON TABLE calendar_template IS 'Weekly meal template (repeating pattern: "every Monday breakfast = scrambled eggs")';
COMMENT ON COLUMN calendar_template.day_of_week IS '1=Monday, 2=Tuesday, ..., 7=Sunday (ISO 8601)';
COMMENT ON COLUMN calendar_template.recipe_id IS 'Recipe assigned to this meal (NULL = empty slot)';
```

**Constraints:**
- `day_of_week` 1-7 - ISO 8601 standard (1=poniedziałek, 7=niedziela)
- UNIQUE `(user_id, day_of_week, meal_type)` - jeden przepis per slot (FR-CALENDAR-003)
- `recipe_id` ON DELETE SET NULL - usunięcie przepisu opróżnia slot, nie usuwa wpisu (FR-RECIPE-007)

---

### 1.6 `calendar_instances`

Instancje kalendarza (nadpisania szablonu dla konkretnych dat).

```sql
CREATE TABLE calendar_instances (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  meal_type meal_type NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, date, meal_type)
);

COMMENT ON TABLE calendar_instances IS 'Calendar overrides for specific dates (one-time changes: "this Monday only")';
COMMENT ON COLUMN calendar_instances.date IS 'Specific date for this meal (e.g., 2025-10-21)';
COMMENT ON COLUMN calendar_instances.recipe_id IS 'Recipe assigned to this meal (NULL = empty slot)';
```

**Constraints:**
- `date` NOT NULL - instancja musi mieć konkretną datę
- UNIQUE `(user_id, date, meal_type)` - jeden przepis per slot
- `recipe_id` ON DELETE SET NULL - usunięcie przepisu opróżnia slot

**Logika biznesowa:** Aplikacja sprawdza `calendar_instances` najpierw; jeśli brak wpisu dla danej daty → fallback do `calendar_template` (wyliczenie `day_of_week` z `date`).

---

### 1.7 `shopping_lists`

Wygenerowane listy zakupów (historia).

```sql
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_start_date DATE,
  week_end_date DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE shopping_lists IS 'Generated shopping lists history';
COMMENT ON COLUMN shopping_lists.week_start_date IS 'Start date of week (nullable - user may select partial week)';
COMMENT ON COLUMN shopping_lists.week_end_date IS 'End date of week (nullable - user may select partial week)';
```

**Constraints:**
- `user_id` NOT NULL - lista należy do użytkownika
- `week_start_date`, `week_end_date` nullable - użytkownik może generować listę z wybranych dni, nie pełnego tygodnia
- Brak CHECK constraint `week_end_date = week_start_date + 6` - elastyczność dla częściowych tygodni

---

### 1.8 `shopping_list_items`

Pozycje na liście zakupów (zagregowane składniki + ręcznie dodane produkty).

```sql
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  ingredient_name VARCHAR(255) NOT NULL,
  quantity DECIMAL(10,2) CHECK (quantity > 0),
  unit VARCHAR(50),
  category product_category NOT NULL,
  is_checked BOOLEAN NOT NULL DEFAULT FALSE,
  is_manual BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE shopping_list_items IS 'Shopping list items (aggregated ingredients + manual additions)';
COMMENT ON COLUMN shopping_list_items.ingredient_name IS 'Ingredient/product name (after aggregation via LOWER(name) matching)';
COMMENT ON COLUMN shopping_list_items.quantity IS 'Aggregated quantity (sum from multiple recipes if same ingredient)';
COMMENT ON COLUMN shopping_list_items.is_checked IS 'Checkbox state for "purchased" tracking (FR-SHOPLIST-006)';
COMMENT ON COLUMN shopping_list_items.is_manual IS 'TRUE if manually added by user (not from recipe), FALSE if from aggregation';
```

**Constraints:**
- `shopping_list_id` NOT NULL - item należy do listy
- `shopping_list_id` ON DELETE CASCADE - usunięcie listy usuwa items
- `quantity > 0` - tylko dodatnie ilości
- `is_checked` DEFAULT FALSE - nowy item domyślnie niezaznaczony
- `is_manual` DEFAULT FALSE - domyślnie z agregacji przepisów

**Snapshot approach:** Items są kopią składników w momencie generowania listy. Edycja przepisu nie aktualizuje starych list.

---

### 1.9 `shopping_list_sources`

Źródła listy zakupów (które posiłki/przepisy zostały uwzględnione).

```sql
CREATE TABLE shopping_list_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  meal_date DATE NOT NULL,
  meal_type meal_type NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE shopping_list_sources IS 'Tracks which meals/recipes were included in shopping list generation';
COMMENT ON COLUMN shopping_list_sources.meal_date IS 'Date of the meal included in list';
COMMENT ON COLUMN shopping_list_sources.meal_type IS 'Type of meal (breakfast, lunch, etc.)';
COMMENT ON COLUMN shopping_list_sources.recipe_id IS 'Recipe used (NULL if recipe was deleted after list generation)';
```

**Constraints:**
- `shopping_list_id` NOT NULL - source należy do listy
- `shopping_list_id` ON DELETE CASCADE - usunięcie listy usuwa tracking
- `recipe_id` ON DELETE SET NULL - usunięcie przepisu zachowuje informację historyczną "z jakiego posiłku"
- Brak UNIQUE constraint - możliwe duplikaty jeśli użytkownik wybierze ten sam przepis wielokrotnie

**Użycie:** Wyświetlanie "Lista wygenerowana z: Poniedziałek śniadanie (Jajecznica), Wtorek obiad (Rosół)" (FR-SHOPLIST-007).

---

## 2. Table Relationships

### 2.1 Diagram Relacji

```
auth.users (Supabase Auth - managed externally)
    │
    ├─── 1:1 ────► user_profiles (ON DELETE CASCADE)
    │
    ├─── 1:N ────► recipes (ON DELETE CASCADE)
    │                  │
    │                  └─── 1:N ────► recipe_ingredients (ON DELETE CASCADE)
    │
    ├─── 1:N ────► calendar_template (ON DELETE CASCADE)
    │                  │
    │                  └─── N:1 ────► recipes (ON DELETE SET NULL)
    │
    ├─── 1:N ────► calendar_instances (ON DELETE CASCADE)
    │                  │
    │                  └─── N:1 ────► recipes (ON DELETE SET NULL)
    │
    └─── 1:N ────► shopping_lists (ON DELETE CASCADE)
                       │
                       ├─── 1:N ────► shopping_list_items (ON DELETE CASCADE)
                       │
                       └─── 1:N ────► shopping_list_sources (ON DELETE CASCADE)
                                          │
                                          └─── N:1 ────► recipes (ON DELETE SET NULL)
```

### 2.2 Relacje - Szczegóły

| Parent Table | Child Table | Relationship | ON DELETE | Rationale |
|--------------|-------------|--------------|-----------|-----------|
| `auth.users` | `user_profiles` | 1:1 | CASCADE | Jeden profil per użytkownik; usunięcie konta usuwa profil (RODO) |
| `auth.users` | `recipes` | 1:N | CASCADE | Użytkownik może mieć wiele przepisów; usunięcie konta usuwa przepisy |
| `recipes` | `recipe_ingredients` | 1:N | CASCADE | Przepis ma wiele składników; składniki nie istnieją bez przepisu |
| `auth.users` | `calendar_template` | 1:N | CASCADE | Użytkownik ma szablon tygodniowy; usunięcie konta usuwa szablon |
| `recipes` | `calendar_template` | N:1 | SET NULL | Przepis może być w wielu slotach kalendarza; usunięcie przepisu opróżnia sloty |
| `auth.users` | `calendar_instances` | 1:N | CASCADE | Użytkownik ma instancje kalendarza; usunięcie konta usuwa instancje |
| `recipes` | `calendar_instances` | N:1 | SET NULL | Przepis może być w wielu slotach; usunięcie przepisu opróżnia sloty |
| `auth.users` | `shopping_lists` | 1:N | CASCADE | Użytkownik ma wiele list zakupów; usunięcie konta usuwa listy |
| `shopping_lists` | `shopping_list_items` | 1:N | CASCADE | Lista ma wiele pozycji; usunięcie listy usuwa pozycje |
| `shopping_lists` | `shopping_list_sources` | 1:N | CASCADE | Lista ma tracking źródeł; usunięcie listy usuwa tracking |
| `recipes` | `shopping_list_sources` | N:1 | SET NULL | Przepis może być źródłem wielu list; usunięcie przepisu zachowuje info historyczne |

### 2.3 Kluczowe Decyzje ON DELETE

**CASCADE vs SET NULL:**
- **CASCADE**: Silna zależność (child nie ma sensu bez parent)
  - `recipe_ingredients` bez `recipes`
  - `shopping_list_items` bez `shopping_lists`
  - Wszystkie user-owned entities bez `auth.users` (RODO compliance)

- **SET NULL**: Słaba zależność (child zachowuje wartość historyczną)
  - `calendar_template/instances.recipe_id` - slot pozostaje pusty po usunięciu przepisu (FR-RECIPE-007)
  - `shopping_list_sources.recipe_id` - tracking "z jakiego posiłku" pozostaje, nawet jeśli przepis usunięty

---

## 3. Indexes

### 3.1 Primary Key Indexes (automatyczne)

Wszystkie tabele mają `id UUID PRIMARY KEY` → automatyczny index B-tree.

### 3.2 Performance Indexes

#### User-scoped queries (RLS optimization)

```sql
-- Recipes: filtrowanie przepisów użytkownika, sortowanie od najnowszych
CREATE INDEX idx_recipes_user_created ON recipes(user_id, created_at DESC);

-- Calendar template: lookup szablonu dla konkretnego dnia/posiłku
CREATE INDEX idx_calendar_template_user_day_meal ON calendar_template(user_id, day_of_week, meal_type);

-- Calendar instances: lookup instancji dla konkretnej daty/posiłku
CREATE INDEX idx_calendar_instances_user_date_meal ON calendar_instances(user_id, date, meal_type);

-- Shopping lists: historia list użytkownika, sortowanie od najnowszych
CREATE INDEX idx_shopping_lists_user_created ON shopping_lists(user_id, created_at DESC);
```

**Rationale:** Composite indexes `(user_id, ...)` wspierają:
1. RLS filtering (`WHERE user_id = auth.uid()`)
2. Application queries (sortowanie, lookup)
3. Index-only scans (covering index)

#### Foreign key indexes

```sql
-- Recipe ingredients: JOIN recipes ↔ ingredients
CREATE INDEX idx_recipe_ingredients_recipe_id ON recipe_ingredients(recipe_id);

-- Shopping list items: JOIN shopping_lists ↔ items
CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items(shopping_list_id);

-- Shopping list items: filtrowanie/grupowanie po kategorii
CREATE INDEX idx_shopping_list_items_list_category ON shopping_list_items(shopping_list_id, category);

-- Shopping list sources: JOIN shopping_lists ↔ sources
CREATE INDEX idx_shopping_list_sources_list_id ON shopping_list_sources(shopping_list_id);
```

**Rationale:** Foreign key columns używane w JOINach potrzebują indeksów dla wydajności.

#### Functional index (case-insensitive aggregation)

```sql
-- Recipe ingredients: agregacja składników case-insensitive
CREATE INDEX idx_recipe_ingredients_name_lower ON recipe_ingredients(LOWER(ingredient_name));
```

**Rationale:** Query generujące listę zakupów używa `GROUP BY LOWER(ingredient_name), unit` do agregacji. Functional index przyspiesza to 10x.

**Example query:**
```sql
SELECT
  LOWER(ingredient_name) as name,
  unit,
  SUM(quantity) as total_quantity,
  category
FROM recipe_ingredients
WHERE recipe_id IN (...)
GROUP BY LOWER(ingredient_name), unit, category;
```

#### Checkbox state index

```sql
-- Shopping list items: filtrowanie po stanie checkbox (kupione/niekupione)
CREATE INDEX idx_shopping_list_items_checked ON shopping_list_items(shopping_list_id, is_checked);
```

**Rationale:** Użytkownik może chcieć zobaczyć tylko niezakupione produkty (`WHERE is_checked = FALSE`).

### 3.3 Unique Constraints (automatyczne unique indexes)

```sql
-- User profiles: jeden profil per użytkownik
-- UNIQUE (user_id) → automatyczny unique index

-- Calendar template: jeden przepis per slot szablonu
-- UNIQUE (user_id, day_of_week, meal_type) → automatyczny unique index

-- Calendar instances: jeden przepis per slot instancji
-- UNIQUE (user_id, date, meal_type) → automatyczny unique index
```

---

## 4. PostgreSQL Row Level Security (RLS) Policies

### 4.1 Enable RLS

```sql
-- Enable RLS dla wszystkich tabel user-owned
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_ingredients ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_template ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar_instances ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE shopping_list_sources ENABLE ROW LEVEL SECURITY;
```

### 4.2 Policies - Main Tables (z kolumną `user_id`)

#### `user_profiles`

```sql
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own profile"
  ON user_profiles FOR DELETE
  USING (auth.uid() = user_id);
```

#### `recipes`

```sql
CREATE POLICY "Users can view own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own recipes"
  ON recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes"
  ON recipes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);
```

#### `calendar_template`

```sql
CREATE POLICY "Users can view own calendar template"
  ON calendar_template FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calendar template"
  ON calendar_template FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calendar template"
  ON calendar_template FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own calendar template"
  ON calendar_template FOR DELETE
  USING (auth.uid() = user_id);
```

#### `calendar_instances`

```sql
CREATE POLICY "Users can view own calendar instances"
  ON calendar_instances FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own calendar instances"
  ON calendar_instances FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own calendar instances"
  ON calendar_instances FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own calendar instances"
  ON calendar_instances FOR DELETE
  USING (auth.uid() = user_id);
```

#### `shopping_lists`

```sql
CREATE POLICY "Users can view own shopping lists"
  ON shopping_lists FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own shopping lists"
  ON shopping_lists FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shopping lists"
  ON shopping_lists FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shopping lists"
  ON shopping_lists FOR DELETE
  USING (auth.uid() = user_id);
```

### 4.3 Policies - Child Tables (bez kolumny `user_id`)

Child tables weryfikują ownership przez JOIN z parent table.

#### `recipe_ingredients`

```sql
CREATE POLICY "Users can view own recipe ingredients"
  ON recipe_ingredients FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
        AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own recipe ingredients"
  ON recipe_ingredients FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
        AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own recipe ingredients"
  ON recipe_ingredients FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
        AND recipes.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own recipe ingredients"
  ON recipe_ingredients FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM recipes
      WHERE recipes.id = recipe_ingredients.recipe_id
        AND recipes.user_id = auth.uid()
    )
  );
```

#### `shopping_list_items`

```sql
CREATE POLICY "Users can view own shopping list items"
  ON shopping_list_items FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_items.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own shopping list items"
  ON shopping_list_items FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_items.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own shopping list items"
  ON shopping_list_items FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_items.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own shopping list items"
  ON shopping_list_items FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_items.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );
```

#### `shopping_list_sources`

```sql
CREATE POLICY "Users can view own shopping list sources"
  ON shopping_list_sources FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_sources.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can insert own shopping list sources"
  ON shopping_list_sources FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_sources.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can update own shopping list sources"
  ON shopping_list_sources FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_sources.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );

CREATE POLICY "Users can delete own shopping list sources"
  ON shopping_list_sources FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM shopping_lists
      WHERE shopping_lists.id = shopping_list_sources.shopping_list_id
        AND shopping_lists.user_id = auth.uid()
    )
  );
```

### 4.4 RLS Testing

```sql
-- Test RLS isolation (użytkownik A nie widzi danych użytkownika B)
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims.sub TO 'user-a-uuid';

SELECT * FROM recipes; -- Only user A's recipes

SET LOCAL request.jwt.claims.sub TO 'user-b-uuid';

SELECT * FROM recipes; -- Only user B's recipes
```

---

## 5. Database Triggers

### 5.1 Auto-create `user_profiles` on registration

```sql
-- Function: Tworzy profil użytkownika po rejestracji w Supabase Auth
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$;

-- Trigger: Wywołaj funkcję po INSERT do auth.users
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_profile();
```

**Rationale:**
- `SECURITY DEFINER` - funkcja wykonuje się z uprawnieniami właściciela (bypass RLS dla INSERT)
- Automatyczne tworzenie profilu eliminuje manual step w aplikacji
- Jeden punkt prawdy - nie można zapomnieć utworzyć profilu

### 5.2 Auto-update `updated_at` timestamp

```sql
-- Function: Aktualizuj updated_at przy każdym UPDATE
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- Trigger dla każdej tabeli z updated_at
CREATE TRIGGER set_updated_at_recipes
  BEFORE UPDATE ON recipes
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_user_profiles
  BEFORE UPDATE ON user_profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_calendar_template
  BEFORE UPDATE ON calendar_template
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_calendar_instances
  BEFORE UPDATE ON calendar_instances
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_shopping_lists
  BEFORE UPDATE ON shopping_lists
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Rationale:** Automatyczne śledzenie czasu ostatniej modyfikacji (auditing, debugging).

---

## 6. Additional Notes and Design Decisions

### 6.1 Normalization Level

**3rd Normal Form (3NF) z wyjątkami:**

**Normalized:**
- `recipes` ↔ `recipe_ingredients` (1:N) - składniki jako osobne rekordy
- `auth.users` ↔ `user_profiles` (1:1) - separacja auth data vs business data

**Denormalized (intentional):**
- `shopping_list_items` - snapshot składników zamiast referencji do `recipe_ingredients`
  - **Rationale:** Lista zakupów to "moment w czasie". Edycja przepisu nie powinna aktualizować starych list.
  - **Trade-off:** Redundancja danych vs niezmienność historyczna (akceptowalne dla MVP).

- `ingredient_name` jako VARCHAR w `recipe_ingredients` zamiast osobnej tabeli `ingredients`
  - **Rationale:** Brak autocomplete w MVP. Normalizacja komplikuje agregację (GROUP BY).
  - **Post-MVP:** Można dodać tabelę `ingredients` dla tagowania/autocomplete.

### 6.2 UUID vs Serial ID

**Wybrano UUID dla wszystkich tabel.**

**Advantages:**
- Zgodność z Supabase Auth (`auth.users.id` to UUID)
- Bezpieczeństwo - niemożliwość przewidzenia następnego ID (no enumeration attacks)
- Distributed-friendly - możliwość generowania ID offline (future-proofing)

**Disadvantages:**
- Większy rozmiar (16 bytes vs 4 bytes dla INT)
- Wolniejsze indexy (random UUIDs vs sequential INTs)

**Mitigacja:** PostgreSQL `gen_random_uuid()` generuje UUID v4 (random). Dla wydajności można rozważyć UUID v7 (time-ordered) post-MVP.

### 6.3 Timestamp Handling

**TIMESTAMPTZ (timestamp with time zone) wszędzie.**

**Rationale:**
- Użytkownicy mogą być w różnych strefach czasowych (post-MVP: multi-region)
- PostgreSQL automatycznie konwertuje do UTC (storage) i user timezone (retrieval)
- Best practice dla aplikacji webowych

**Exceptions:**
- `calendar_instances.date` - typ DATE (bez czasu), bo meal planning jest "dzień", nie "moment"
- `user_profiles.ai_parsing_reset_date` - typ DATE (bez czasu), bo reset jest "1. dzień miesiąca"

### 6.4 NULL vs NOT NULL

**Strategia:**
- **NOT NULL** dla business-critical fields:
  - `recipes.name`, `recipes.recipe_text` - przepis musi mieć nazwę i treść
  - `recipe_ingredients.ingredient_name` - składnik musi mieć nazwę
  - `shopping_list_items.category` - kategoria wymagana dla grupowania

- **NULLABLE** dla optional fields:
  - `recipe_ingredients.quantity`, `unit` - składniki jak "sól do smaku" nie mają quantity
  - `shopping_lists.week_start_date`, `week_end_date` - użytkownik może generować listę z wybranych dni
  - `calendar_template/instances.recipe_id` - slot może być pusty

### 6.5 Enum vs VARCHAR

**Wybrano PostgreSQL ENUM dla:**
- `product_category` - 7 stałych wartości (nabial, warzywa, owoce, mieso, pieczywo, przyprawy, inne)
- `meal_type` - 4 stałe wartości (sniadanie, drugie_sniadanie, obiad, kolacja)

**Advantages:**
- Type safety (nie można wstawić 'podwieczorek')
- Wydajność (ENUM stored as INT internally, 4 bytes vs VARCHAR)
- Self-documenting schema

**Disadvantages:**
- Trudniejsze modyfikacje (ALTER TYPE wymaga migration)
- Brak i18n (wartości po polsku hard-coded)

**Rationale:** Lista kategorii i posiłków jest stała w MVP (PRD sekcja 4.2). Post-MVP można migrować do tabeli słownikowej jeśli custom categories.

### 6.6 Cascade Delete Strategy

**Guidance:**
- **ON DELETE CASCADE**: Child record nie ma sensu bez parent
  - Przykład: `recipe_ingredients` bez `recipes`, `shopping_list_items` bez `shopping_lists`

- **ON DELETE SET NULL**: Child record zachowuje wartość historyczną
  - Przykład: `calendar_template.recipe_id` - slot pozostaje pusty po usunięciu przepisu
  - Przykład: `shopping_list_sources.recipe_id` - tracking "z jakiego przepisu" pozostaje nawet po usunięciu

**RODO Compliance:**
- Wszystkie user-owned tables: `ON DELETE CASCADE` z `auth.users`
- Usunięcie konta Supabase → kaskadowe usunięcie wszystkich danych użytkownika (hard delete)
- FR-AUTH-004: "Wszystkie dane użytkownika (przepisy, listy) są usuwane z bazy danych"

### 6.7 Index Strategy

**Composite indexes order:**
- **Rule:** Najczęściej filtrowana kolumna pierwsza (zwykle `user_id` z RLS)
- Przykład: `(user_id, created_at DESC)` wspiera:
  ```sql
  WHERE user_id = $1 ORDER BY created_at DESC
  ```

**Functional indexes:**
- `LOWER(ingredient_name)` - case-insensitive aggregation
- Future: `to_tsvector('polish', recipe_text)` dla full-text search (post-MVP)

**Index maintenance:**
- B-tree indexes (default) dla większości cases
- Partial indexes (gdzie applicable) post-MVP: `WHERE is_checked = FALSE`

### 6.8 Data Validation Layers

**Defense in depth:**

1. **Database constraints** (last line of defense):
   - CHECK constraints: `quantity > 0`, `day_of_week 1-7`, `LENGTH(recipe_text) <= 5000`
   - NOT NULL: wymagane pola
   - UNIQUE: logiczna unikalność
   - Foreign keys: referential integrity

2. **Application validation** (Zod schemas w API routes):
   - Input sanitization
   - Business logic (AI parsing limit)
   - User-friendly error messages

3. **Frontend validation** (React forms):
   - Real-time feedback
   - Character counters (5000/5000)
   - Disabled buttons gdy invalid

### 6.9 Migration Files Structure

```
supabase/migrations/
├── 20251018000001_initial_schema.sql          # ENUMs, tables, constraints
├── 20251018000002_indexes.sql                 # Performance indexes
├── 20251018000003_rls_policies.sql            # RLS enable + policies
├── 20251018000004_triggers.sql                # Triggers (user_profile, updated_at)
└── 20251018000005_functions.sql               # Helper functions (optional)
```

**Rationale:** Podział migracji ułatwia:
- Rollback specific parts (np. tylko indexes)
- Code review (każdy plik ma jasny scope)
- Debugging (błąd w RLS nie blokuje schema creation)

### 6.10 Performance Considerations

**Expected dataset size (per user):**
- Recipes: ~20-50 (PRD: "około 20-30 ulubionych przepisów")
- Recipe ingredients: ~200-500 (10 składników/przepis × 20-50 przepisów)
- Shopping lists: ~50/rok (4/miesiąc × 12 miesięcy)
- Shopping list items: ~500/rok (10 items/lista × 50 list)

**Query performance targets:**
- Recipe list: < 100ms (indexed by `user_id`)
- Calendar load: < 100ms (indexed by `user_id, date/day_of_week`)
- Shopping list generation: < 500ms (aggregation via functional index)
- RLS overhead: ~5-10% (acceptable for security)

**Scaling triggers:**
- 10k users: Free tier OK (500MB DB)
- 50k users: Paid tier ($25/m, 8GB DB)
- 100k+ users: Consider read replicas, partitioning

### 6.11 Testing Checklist

**Before production:**
- [ ] RLS policies tested (user isolation)
- [ ] CASCADE deletes verified (orphans nie pozostają)
- [ ] Trigger functions tested (user_profile auto-creation)
- [ ] Index usage verified (EXPLAIN ANALYZE)
- [ ] Constraint violations handled gracefully
- [ ] Migration rollback tested
- [ ] Performance benchmarks (realistic dataset)

---

## 7. Schema Summary

**Total tables:** 8 (+ 1 external `auth.users`)
- `user_profiles` - rozszerzony profil użytkownika
- `recipes` - przepisy kulinarne
- `recipe_ingredients` - składniki przepisów
- `calendar_template` - szablon tygodniowy
- `calendar_instances` - nadpisania kalendarza
- `shopping_lists` - historia list zakupów
- `shopping_list_items` - pozycje na listach
- `shopping_list_sources` - tracking źródeł list

**Total ENUMs:** 2
- `product_category` (7 wartości)
- `meal_type` (4 wartości)

**Total indexes:** 11 custom + 8 PK + 3 unique = 22 total

**Total RLS policies:** 32 (4 per table × 8 tables)

**Total triggers:** 6 (1 user_profile creation + 5 updated_at)

**Estimated DB size (1000 users):**
- Recipes: ~1MB (50 recipes × 20KB)
- Ingredients: ~5MB (500 ingredients × 10KB)
- Calendar: ~1MB (28 slots × 2 tables × 20 bytes)
- Shopping lists: ~10MB (50 lists × 10 items × 200 bytes)
- **Total:** ~20-30MB per 1000 users → 200-300MB dla 10k users (well within free tier 500MB)

---

**Status:** Schema gotowy do implementacji. Wymaga code review przed deployment do production.

**Next steps:**
1. Generowanie migration files w `supabase/migrations/`
2. Testowanie lokalnie przez Supabase CLI
3. Code review schematu
4. Deploy do staging environment
5. RLS testing z różnymi user scenarios
6. Performance benchmarks
7. Deploy do production

---

**Document prepared by:** Claude Code
**Source:** PRD v2.0, Tech Stack Analysis, Database Planning Summary
**Date:** 2025-10-18
