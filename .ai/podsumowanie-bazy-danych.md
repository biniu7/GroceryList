# Podsumowanie Planowania Bazy Danych - GroceryList MVP

**Data:** 2025-10-18
**Wersja:** 2.0
**Status:** Final

---

## Decisions

### Decyzje Architekturalne

1. **Akceptacja wszystkich 40 rekomendacji** - Użytkownik zaakceptował wszystkie zaproponowane pytania i zalecenia dotyczące schematu bazy danych PostgreSQL bez zastrzeżeń.

2. **Wybór PostgreSQL jako głównej bazy danych** - Zgodnie z tech stackiem, wykorzystanie Supabase (managed PostgreSQL) z Row Level Security.

3. **Podejście denormalizacyjne dla MVP** - Priorytet dla prostoty i szybkości dostarczenia nad pełną normalizacją.

4. **Hard delete zamiast soft delete** - Brak wymagań biznesowych dla odzyskiwania usuniętych danych w MVP.

5. **Snapshot approach dla list zakupów** - Lista zakupów przechowuje kopię składników zamiast referencji, co zapewnia niezmienność historyczną.

---

## Matched Recommendations

### 1. Architektura Użytkowników
- **Tabela `auth.users`** zarządzana przez Supabase Auth jako single source of truth
- **Tabela `public.user_profiles`** dla rozszerzeń biznesowych (licznik AI, preferencje)
- Relacja: `user_id REFERENCES auth.users(id) ON DELETE CASCADE`
- Automatyczne tworzenie profilu przez trigger PostgreSQL przy rejestracji

### 2. Model Przepisów
- **Dual storage**: surowy tekst przepisu + sparsowana lista składników
- **Tabela `recipes`**: `recipe_text TEXT`, `name VARCHAR(255)`
- **Tabela `recipe_ingredients`**: relacja 1:N z `recipes`
- Denormalizacja składników (brak osobnej tabeli `ingredients`)
- ON DELETE CASCADE dla składników przy usunięciu przepisu

### 3. System Kalendarza
- **Dwie tabele**: `calendar_template` (szablon) + `calendar_instances` (nadpisania)
- **Logika**: instance ma priorytet nad template
- **Reprezentacja dni**: INT (1-7) zgodnie z ISO 8601
- **Typy posiłków**: ENUM ('sniadanie', 'drugie_sniadanie', 'obiad', 'kolacja')
- UNIQUE constraint: `(user_id, day_of_week, meal_type)` dla template
- UNIQUE constraint: `(user_id, date, meal_type)` dla instances
- ON DELETE SET NULL dla `recipe_id` (komórka pusteje, nie znika)

### 4. Listy Zakupów
- **Snapshot approach**: `shopping_list_items` zawiera kopię składników
- **Agregacja**: case-insensitive matching przez `LOWER(ingredient_name)`
- **Brak konwersji jednostek**: różne jednostki = osobne pozycje
- **Tabela `shopping_list_sources`**: śledzenie źródła (meal_date, meal_type, recipe_id)
- **Persystencja checkboxów**: kolumna `is_checked BOOLEAN`
- **Ręczne pozycje**: kolumna `is_manual BOOLEAN`

### 5. Kategorie i Typy
- **Product categories**: PostgreSQL ENUM (7 wartości: nabial, warzywa, owoce, mieso, pieczywo, przyprawy, inne)
- **Meal types**: PostgreSQL ENUM (4 wartości)
- **Jednostki miary**: inline VARCHAR(50) bez normalizacji

### 6. Limit Parsowania AI
- Licznik w `user_profiles`: `ai_parsing_count INT`, `ai_parsing_reset_date DATE`
- Reset przez logikę aplikacji (nie trigger bazodanowy)
- Walidacja przed wywołaniem API

### 7. Bezpieczeństwo (RLS)
- **Row Level Security** włączone dla wszystkich tabel
- **4 polityki** dla każdej tabeli: SELECT, INSERT, UPDATE, DELETE
- Warunek: `auth.uid() = user_id`
- Izolacja danych między użytkownikami

### 8. Indeksy Wydajnościowe
- `idx_recipes_user_id` - filtrowanie przepisów użytkownika
- `idx_calendar_template_user` - composite (user_id, day_of_week, meal_type)
- `idx_calendar_instances_user_date` - composite (user_id, date, meal_type)
- `idx_shopping_lists_user_created` - composite (user_id, created_at DESC)
- `idx_recipe_ingredients_name_lower` - functional index na LOWER(ingredient_name)

### 9. Constraints i Walidacja
- `quantity DECIMAL(10,2) CHECK (quantity > 0)` - tylko dodatnie ilości
- `recipe_text TEXT CHECK (LENGTH(recipe_text) <= 5000)` - limit 5000 znaków
- `day_of_week INT CHECK (day_of_week >= 1 AND day_of_week <= 7)`
- Automatyczne timestampy: `created_at`, `updated_at` z triggerem

### 10. Nazewnictwo
- **Tabele**: plural snake_case (`recipes`, `shopping_lists`)
- **Kolumny**: snake_case (`recipe_id`, `meal_type`)
- **Klucze obce**: `{table}_id` pattern
- Konsystencja z PostgreSQL ecosystem

---

## Database Planning Summary

### Główne Wymagania Schematu

**Funkcjonalne obszary:**
1. **Autentykacja i zarządzanie użytkownikami** - email/hasło, reset, usunięcie konta
2. **CRUD przepisów** - tekst + AI parsing składników (limit 20/miesiąc)
3. **Kalendarz tygodniowy** - 7 dni × 4 posiłki, system szablonów
4. **Generowanie list zakupów** - agregacja składników, grupowanie w kategorie
5. **Eksport** - PDF/TXT (generowany on-the-fly, bez persystencji)

### Kluczowe Encje i Relacje

```
auth.users (Supabase Auth)
    ↓ 1:1 ON DELETE CASCADE
user_profiles
    ├─ ai_parsing_count
    └─ ai_parsing_reset_date

users
    ↓ 1:N
recipes
    ├─ recipe_text (TEXT, max 5000 chars)
    ├─ name (VARCHAR(255))
    └─ 1:N → recipe_ingredients
              ├─ ingredient_name (VARCHAR(255))
              ├─ quantity (DECIMAL(10,2))
              ├─ unit (VARCHAR(50))
              └─ category (ENUM)

users
    ↓ 1:N
calendar_template
    ├─ day_of_week (INT 1-7)
    ├─ meal_type (ENUM)
    └─ recipe_id (NULL ON DELETE)

users
    ↓ 1:N
calendar_instances
    ├─ date (DATE)
    ├─ meal_type (ENUM)
    └─ recipe_id (NULL ON DELETE)

users
    ↓ 1:N
shopping_lists
    ├─ week_start_date (DATE, nullable)
    ├─ week_end_date (DATE, nullable)
    ├─ 1:N → shopping_list_items
    │         ├─ ingredient_name
    │         ├─ quantity
    │         ├─ unit
    │         ├─ category
    │         ├─ is_checked (BOOLEAN)
    │         └─ is_manual (BOOLEAN)
    └─ 1:N → shopping_list_sources
              ├─ meal_date
              ├─ meal_type
              └─ recipe_id (NULL ON DELETE)
```

### Strategia Bezpieczeństwa

**Warstwa 1: Row Level Security (RLS)**
- Wszystkie tabele w schemacie `public` mają `ENABLE ROW LEVEL SECURITY`
- 4 polityki per tabela (SELECT/INSERT/UPDATE/DELETE) z warunkiem `auth.uid() = user_id`
- Test: użytkownik A nie widzi/nie edytuje danych użytkownika B

**Warstwa 2: Constraints Bazodanowe**
- CHECK constraints dla wartości biznesowych (quantity > 0, day_of_week 1-7)
- UNIQUE constraints dla unikalności (kalendarz: jeden przepis per posiłek)
- NOT NULL dla wymaganych pól
- ENUM types dla kontrolowanych słowników

**Warstwa 3: Referential Integrity**
- Foreign keys z odpowiednimi ON DELETE policies:
  - CASCADE: user_profiles, recipe_ingredients, shopping_list_items
  - SET NULL: calendar recipes, shopping_list_sources.recipe_id
- Zapobiega orphaned records i dangling pointers

**Warstwa 4: Application Layer**
- Walidacja inputu (Zod schemas w API routes)
- Komunikaty potwierdzenia przed DELETE operations
- Rate limiting dla AI parsing (20/miesiąc per user)

**Warstwa 5: Supabase Infrastructure**
- HTTPS transport (TLS 1.3)
- JWT authentication z refresh tokens
- Password hashing (bcrypt przez Supabase Auth)
- Point-in-Time Recovery backups (7-30 dni retention)
- EU region compliance (RODO)

### Optymalizacje Wydajnościowe

**Indeksowanie:**
- Composite indexes dla queries z RLS: `(user_id, other_columns)`
- Functional index dla case-insensitive search: `LOWER(ingredient_name)`
- DESC ordering w index dla sortowania "od najnowszych"

**Query Patterns:**
- Agregacja składników: `GROUP BY LOWER(ingredient_name), unit`
- Calendar lookup: composite index covering `(user_id, date/day_of_week, meal_type)`
- Upsert dla concurrent updates: `INSERT ... ON CONFLICT ... DO UPDATE`

**Denormalizacja:**
- Shopping list items = snapshot (szybkie queries, brak JOINs)
- Brak normalizacji ingredient names (prostsze agregacje)
- Trade-off: storage cost vs query speed (akceptowalny dla MVP)

### Skalowalność

**Do 50k Weekly Active Users:**
- Supabase free tier: 500MB DB, 2GB transfer (wystarczy dla ~1000 users)
- Paid tier ($25/m): 8GB DB, 100GB transfer (obsłuży 50k WAU)
- Horizontal scaling: Supabase auto-scaling dla read replicas

**Wąskie gardła (post-MVP):**
- AI parsing API costs (mitigacja: limit 20/miesiąc)
- Aggregation queries dla list zakupów (mitigacja: functional indexes)
- Concurrent calendar updates (mitigacja: upsert pattern)

**Future-proofing:**
- `created_at`/`updated_at` dla wszystkich tabel (auditing ready)
- Extensible structure (łatwe ADD COLUMN dla nowych features)
- Generic `user_profiles` dla przyszłych user settings

### Strategia Deployment

**Migration Strategy:**
- Supabase migrations w folderze `supabase/migrations/`
- Numerowane pliki: `20251018000000_initial_schema.sql`
- Wersjonowanie w git (rollback możliwy)

**Seed Data:**
- Brak pre-populated data (user-generated content)
- Opcjonalnie: default categories w ENUM (hard-coded)

**Testing:**
- Local Supabase CLI dla dev environment
- RLS policies testing: `SET LOCAL ROLE authenticated; SET LOCAL request.jwt.claims.sub TO 'user-uuid';`
- Integration tests dla critical paths (recipe CRUD, list generation)

---

## Unresolved Issues

### Brak Nierozwiązanych Kwestii Krytycznych

Wszystkie kluczowe decyzje zostały podjęte i zaakceptowane. Poniżej wymieniono obszary, które mogą wymagać dalszego doprecyzowania podczas implementacji:

### Obszary do Monitorowania

1. **AI Parsing Accuracy**
   - Issue: Sukces parsowania składników 80%+ (cel PRD)
   - Action: Iteracyjne testowanie promptu na różnych przepisach
   - Fallback: Ręczne dodawanie składników jeśli AI zawiedzie

2. **Agregacja Składników - Edge Cases**
   - Issue: Synonimy ("pomidor" vs "pomidory"), ortografia
   - MVP: Brak inteligentnej agregacji, exact lowercase match
   - Post-MVP: Fuzzy matching lub normalizacja słownikowa

3. **Concurrent Updates - Race Conditions**
   - Issue: Użytkownik edytuje kalendarz z dwóch urządzeń jednocześnie
   - MVP: Last-write-wins przez upsert pattern
   - Post-MVP: Optimistic locking z `version` column jeśli problematyczne

4. **Shopping List Snapshot vs Live Data**
   - Decision: Snapshot approach (lista niezmienna po wygenerowaniu)
   - Trade-off: Edycja przepisu nie aktualizuje starych list
   - Akceptowalne dla MVP (user expectation: "lista to moment w czasie")

5. **Performance Testing**
   - Issue: Brak testów obciążeniowych dla agregacji składników
   - Action: Testowanie z realistic dataset (20+ recipes, 200+ ingredients)
   - Threshold: Query time < 500ms dla generowania listy

### Opcjonalne Usprawnienia (Post-MVP)

1. **Full-text Search dla przepisów** - `CREATE INDEX ... USING GIN(to_tsvector('polish', recipe_text))`
2. **Materialized View dla popularnych agregacji** - cache dla często generowanych list
3. **Partitioning** - `calendar_instances` po `date` dla długoterminowej historii
4. **Audit Log** - trigger logujący DELETE operations do recovery
5. **Unit Conversions Table** - inteligentna konwersja ml ↔ szklanki

---

## Next Steps

### Implementacja Schematu

1. **Utworzenie struktury katalogów Supabase**
   ```bash
   supabase init
   supabase/
   ├── migrations/
   │   └── 20251018000000_initial_schema.sql
   └── seed.sql (opcjonalnie)
   ```

2. **Generowanie TypeScript types**
   ```bash
   supabase gen types typescript --project-id <project-id> > src/db/database.types.ts
   ```

3. **Setup RLS Policies**
   - Utworzenie polityk dla wszystkich tabel
   - Testowanie izolacji danych między użytkownikami

4. **Implementacja Triggers**
   - `create_user_profile()` przy rejestracji
   - `update_updated_at_column()` dla timestampów

5. **Walidacja przez Integration Tests**
   - CRUD operations dla wszystkich encji
   - Generowanie listy zakupów z agregacją
   - RLS policies enforcement

---

**Dokument przygotowany przez:** Claude Code
**Źródła:** PRD v2.0, Tech Stack Analysis, 40 pytań i rekomendacji
**Status:** Gotowy do implementacji
