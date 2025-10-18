# Podsumowanie planowania bazy danych - GroceryList MVP

## Decisions

### Decyzje dotyczące struktury tabel i relacji

1. **Prywatność danych użytkowników** - Każdy użytkownik ma własne, prywatne przepisy z polem `user_id` i politykami RLS ograniczającymi dostęp tylko do właściciela.

2. **Osobna tabela składników** - Składniki przechowywane w dedykowanej tabeli `recipe_ingredients` z kolumnami: `id`, `recipe_id`, `name`, `quantity`, `unit`, `category`. Pełny tekst przepisu w kolumnie `full_text` w tabeli `recipes`.

3. **System szablonów kalendarza** - Dwie tabele dla kalendarza:
   - `calendar_templates` - szablon powtarzający się co tydzień
   - `calendar_instances` - nadpisania dla konkretnych tygodni

4. **Tracking limitu AI** - Tabela `ai_usage_log` z kolumnami: `user_id`, `month`, `parsing_count`. Reset na początku miesiąca przez logikę aplikacyjną lub trigger PostgreSQL.

5. **Agregacja składników** - Oryginalne składniki w `recipe_ingredients`, zagregowane w `shopping_list_items`. Agregacja wykonywana w logice aplikacyjnej.

6. **Źródła list zakupów** - Junction table `shopping_list_sources` śledzi pochodzenie składników z kolumnami: `shopping_list_id`, `recipe_id`, `meal_date`, `meal_type`.

7. **Kategorie produktów** - Użycie typu ENUM PostgreSQL `product_category_enum`.

8. **Stan checkboxów** - Kolumna `is_checked` (boolean, default FALSE) w `shopping_list_items` z indeksem na `shopping_list_id` + `is_checked`.

9. **Wolne pozycje** - Kolumna `is_manual` (boolean) w `shopping_list_items` do oznaczenia produktów dodanych ręcznie.

10. **Usuwanie przepisów** - `ON DELETE CASCADE` dla przypisań w kalendarzu.

11. **Jednostki miary** - Typ TEXT dla MVP (wolny tekst bez konwersji).

12. **Indeksy wydajnościowe** - Indeksy na: `recipes(user_id, created_at DESC)`, `calendar_templates(user_id, day_of_week, meal_type)`, `calendar_instances(user_id, specific_date, meal_type)`, `shopping_list_items(shopping_list_id, category)`, `recipe_ingredients(recipe_id)`.

13. **Polityki RLS** - Prosty model: SELECT/INSERT/UPDATE/DELETE tylko dla właściciela (WHERE user_id = auth.uid()) dla wszystkich tabel.

14. **Zarządzanie migracjami** - Migracje zarządzane lokalnie przez pliki SQL w `supabase/migrations/` z wersjonowaniem w git.

15. **Usuwanie konta** - `ON DELETE CASCADE` dla wszystkich kluczy obcych `user_id` (zgodność z RODO).

### Decyzje dotyczące typów danych i implementacji

16. **Day of week** - ENUM `day_of_week_enum` z wartościami: `'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'`.

17. **Meal type** - ENUM `meal_type_enum` z wartościami: `'breakfast', 'second_breakfast', 'lunch', 'dinner'`.

18. **Timestamps audytowe** - `created_at` i `updated_at` (TIMESTAMPTZ) dla tabel: `recipes`, `shopping_lists`. Tylko `created_at` dla `ai_usage_log`. Brak dla tabel relacyjnych.

19. **Nazwa przepisu** - `VARCHAR(200) NOT NULL`.

20. **Tekst przepisu** - Typ `TEXT` bez limitu bazy danych, walidacja 5000 znaków w aplikacji.

21. **Nullable quantity/unit** - `quantity DECIMAL(10,2) NULL`, `unit TEXT NULL` w `recipe_ingredients`.

22. **PK dla ai_usage_log** - Klucz kompozytowy `PRIMARY KEY (user_id, month)`.

23. **Unikalne nazwy przepisów** - BRAK constraintu UNIQUE (użytkownik może mieć duplikaty nazw).

24. **Soft delete** - NIE dla MVP (hard delete zgodnie z PRD).

25. **Domyślna kategoria** - `category product_category_enum DEFAULT 'other'`.

26. **Struktura shopping_list_sources** - Minimalna struktura: `shopping_list_id`, `recipe_id`, `meal_date`, `meal_type` z composite PK.

27. **Constraint dat tygodnia** - CHECK constraint: `week_end_date = week_start_date + INTERVAL '6 days'`.

28. **Indeksy na datach** - Złożony indeks `(user_id, specific_date, meal_type)` wystarczający dla MVP.

29. **Primary Keys** - UUID dla wszystkich tabel (zgodność z Supabase Auth, bezpieczeństwo).

30. **RLS dla tabel relacyjnych** - Policy używające JOIN do sprawdzenia własności przez powiązanie z tabelą nadrzędną (np. `recipe_ingredients` przez `recipes`).

---

## Matched Recommendations

### Struktura bazy danych

1. **Tabela `recipes`**
   - `id` UUID PRIMARY KEY
   - `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
   - `name` VARCHAR(200) NOT NULL
   - `full_text` TEXT NOT NULL
   - `created_at` TIMESTAMPTZ DEFAULT NOW()
   - `updated_at` TIMESTAMPTZ DEFAULT NOW()
   - Index: `(user_id, created_at DESC)`
   - RLS: WHERE user_id = auth.uid()

2. **Tabela `recipe_ingredients`**
   - `id` UUID PRIMARY KEY
   - `recipe_id` UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE
   - `name` VARCHAR(200) NOT NULL
   - `quantity` DECIMAL(10,2) NULL
   - `unit` TEXT NULL
   - `category` product_category_enum DEFAULT 'other'
   - Index: `(recipe_id)`
   - RLS: Przez JOIN z `recipes`

3. **ENUM Types**
   - `product_category_enum`: 'dairy', 'vegetables', 'fruits', 'meat', 'bread', 'spices', 'other'
   - `day_of_week_enum`: 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
   - `meal_type_enum`: 'breakfast', 'second_breakfast', 'lunch', 'dinner'

4. **Tabela `calendar_templates`**
   - `id` UUID PRIMARY KEY
   - `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
   - `day_of_week` day_of_week_enum NOT NULL
   - `meal_type` meal_type_enum NOT NULL
   - `recipe_id` UUID REFERENCES recipes(id) ON DELETE CASCADE
   - Index: `(user_id, day_of_week, meal_type)`
   - UNIQUE: `(user_id, day_of_week, meal_type)`
   - RLS: WHERE user_id = auth.uid()

5. **Tabela `calendar_instances`**
   - `id` UUID PRIMARY KEY
   - `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
   - `specific_date` DATE NOT NULL
   - `meal_type` meal_type_enum NOT NULL
   - `recipe_id` UUID REFERENCES recipes(id) ON DELETE CASCADE
   - Index: `(user_id, specific_date, meal_type)`
   - UNIQUE: `(user_id, specific_date, meal_type)`
   - RLS: WHERE user_id = auth.uid()

6. **Tabela `shopping_lists`**
   - `id` UUID PRIMARY KEY
   - `user_id` UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE
   - `week_start_date` DATE NOT NULL
   - `week_end_date` DATE NOT NULL
   - `created_at` TIMESTAMPTZ DEFAULT NOW()
   - `updated_at` TIMESTAMPTZ DEFAULT NOW()
   - CHECK: `week_end_date = week_start_date + INTERVAL '6 days'`
   - RLS: WHERE user_id = auth.uid()

7. **Tabela `shopping_list_items`**
   - `id` UUID PRIMARY KEY
   - `shopping_list_id` UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE
   - `name` VARCHAR(200) NOT NULL
   - `quantity` DECIMAL(10,2) NULL
   - `unit` TEXT NULL
   - `category` product_category_enum NOT NULL
   - `is_checked` BOOLEAN DEFAULT FALSE
   - `is_manual` BOOLEAN DEFAULT FALSE
   - Index: `(shopping_list_id, category)`
   - Index: `(shopping_list_id, is_checked)`
   - RLS: Przez JOIN z `shopping_lists`

8. **Tabela `shopping_list_sources`**
   - `shopping_list_id` UUID REFERENCES shopping_lists(id) ON DELETE CASCADE
   - `recipe_id` UUID REFERENCES recipes(id) ON DELETE CASCADE
   - `meal_date` DATE NOT NULL
   - `meal_type` meal_type_enum NOT NULL
   - PRIMARY KEY: `(shopping_list_id, recipe_id, meal_date, meal_type)`
   - RLS: Przez JOIN z `shopping_lists`

9. **Tabela `ai_usage_log`**
   - `user_id` UUID REFERENCES auth.users(id) ON DELETE CASCADE
   - `month` DATE NOT NULL
   - `parsing_count` INTEGER DEFAULT 0
   - `created_at` TIMESTAMPTZ DEFAULT NOW()
   - PRIMARY KEY: `(user_id, month)`
   - RLS: WHERE user_id = auth.uid()

### Bezpieczeństwo i wydajność

10. **Row Level Security (RLS)**
    - Wszystkie tabele z włączonym RLS
    - Policy dla tabel głównych: `WHERE user_id = auth.uid()`
    - Policy dla tabel relacyjnych: EXISTS z JOIN do tabeli nadrzędnej

11. **Indeksowanie**
    - Złożone indeksy dla częstych zapytań
    - B-tree dla dat i UUID
    - Indeksy pokrywające user_id dla RLS

12. **Cascading Deletes**
    - `recipes` → `recipe_ingredients` (CASCADE)
    - `recipes` → `calendar_templates` (CASCADE)
    - `recipes` → `calendar_instances` (CASCADE)
    - `auth.users` → wszystkie tabele użytkownika (CASCADE)
    - `shopping_lists` → `shopping_list_items` (CASCADE)
    - `shopping_lists` → `shopping_list_sources` (CASCADE)

13. **Data Integrity**
    - NOT NULL dla pól wymaganych
    - CHECK constraints dla logiki biznesowej (daty tygodnia)
    - UNIQUE constraints dla unikalności logicznej (kalendarz)
    - Foreign keys dla integralności referencyjnej

14. **Migracje**
    - Pliki SQL w `supabase/migrations/`
    - Wersjonowanie w Git
    - Supabase CLI: `supabase db push`

---

## Database Planning Summary

### Główne wymagania dotyczące schematu bazy danych

Schemat bazy danych dla GroceryList MVP został zaprojektowany zgodnie z wymogami PRD, z naciskiem na:

1. **Prywatność i izolację danych** - Wszystkie dane użytkowników są całkowicie oddzielone przez RLS policies, zapewniając zgodność z RODO.

2. **Elastyczność kalendarza** - System podwójnych tabel (`calendar_templates` + `calendar_instances`) umożliwia zarówno powtarzające się szablony tygodniowe, jak i jednorazowe nadpisania.

3. **Wydajność agregacji** - Struktura z oddzielnymi składnikami w `recipe_ingredients` i zagregowanymi w `shopping_list_items` pozwala na elastyczną edycję przy zachowaniu wydajności.

4. **Tracking źródeł** - Junction table `shopping_list_sources` śledzi pochodzenie składników, umożliwiając regenerację i audyt list zakupów.

5. **Kontrola kosztów AI** - Tabela `ai_usage_log` z composite primary key zapewnia efektywne śledzenie limitu 20 parsowań miesięcznie.

### Kluczowe encje i ich relacje

```
auth.users (Supabase Auth)
    ↓ (1:N, ON DELETE CASCADE)
    ├─ recipes
    │   ↓ (1:N, ON DELETE CASCADE)
    │   └─ recipe_ingredients
    │
    ├─ calendar_templates (day_of_week + meal_type → recipe)
    │
    ├─ calendar_instances (specific_date + meal_type → recipe)
    │
    ├─ shopping_lists
    │   ↓ (1:N, ON DELETE CASCADE)
    │   ├─ shopping_list_items (agregowane składniki + wolne pozycje)
    │   └─ shopping_list_sources (tracking: które przepisy → lista)
    │
    └─ ai_usage_log (tracking miesięcznego limitu)
```

**Kluczowe relacje:**
- Użytkownik → Przepisy (1:N)
- Przepis → Składniki (1:N)
- Użytkownik → Szablony kalendarza (1:N)
- Użytkownik → Instancje kalendarza (1:N)
- Przepis → Kalendarz (N:M przez calendar_templates/instances)
- Użytkownik → Listy zakupów (1:N)
- Lista zakupów → Pozycje (1:N)
- Lista zakupów → Źródła/Przepisy (N:M przez shopping_list_sources)

### Ważne kwestie dotyczące bezpieczeństwa i skalowalności

#### Bezpieczeństwo

1. **Row Level Security (RLS)**
   - Wszystkie tabele z włączonym RLS
   - Polityki zapewniające dostęp tylko do własnych danych (auth.uid())
   - Tabele relacyjne chronione przez JOIN z tabelami nadrzędnymi

2. **Zgodność z RODO**
   - ON DELETE CASCADE dla user_id zapewnia automatyczne usunięcie wszystkich danych użytkownika
   - Hard delete bez soft delete dla prostoty MVP

3. **UUID jako Primary Keys**
   - Niemożliwość przewidzenia ID (bezpieczeństwo)
   - Zgodność z Supabase Auth
   - Przygotowanie na replikację

#### Skalowalność

1. **Indeksowanie strategiczne**
   - Indeksy złożone dla częstych zapytań z user_id
   - Indeksy pokrywające filtrowanie przez RLS
   - B-tree dla dat i sortowania

2. **Normalizacja vs. Denormalizacja**
   - Składniki znormalizowane w recipe_ingredients (elastyczność)
   - Składniki zdenormalizowane w shopping_list_items (wydajność)
   - Balans między edytowalnością a performance

3. **Partycjonowanie przyszłościowe**
   - Struktura pozwala na przyszłe partycjonowanie:
     - `shopping_lists` po `week_start_date`
     - `calendar_instances` po `specific_date`
     - `ai_usage_log` po `month`

4. **Kontrola kosztów**
   - Limit AI parsowania przez `ai_usage_log`
   - Composite PK zapewnia efektywny UPSERT
   - Brak redundantnych danych

### Technologie i narzędzia

- **PostgreSQL** jako główna baza danych (przez Supabase)
- **Supabase Auth** dla zarządzania użytkownikami
- **Supabase RLS** dla security policies
- **PostgreSQL ENUM** dla typów kategorii, dni tygodnia, typów posiłków
- **UUID-OSSP extension** dla generowania UUID
- **TIMESTAMPTZ** dla timestamps z timezone
- **Supabase CLI** dla zarządzania migracjami

---

## Unresolved Issues

### Kwestie wymagające doprecyzowania podczas implementacji

1. **Reset licznika AI parsowania**
   - Decyzja: Trigger PostgreSQL vs. logika aplikacyjna?
   - Rekomendacja: Trigger PostgreSQL byłby bardziej niezawodny (CRON job w Supabase lub pg_cron)
   - Impact: Wymaga dodatkowej konfiguracji, ale eliminuje ryzyko błędu aplikacyjnego

2. **Timezone dla dat kalendarza**
   - Kwestia: Czy `specific_date` w `calendar_instances` powinien być DATE czy TIMESTAMPTZ?
   - Aktualnie: DATE (prostsze dla MVP)
   - Rozważenie: Jeśli użytkownicy będą w różnych strefach czasowych (post-MVP), może wymagać zmiany

3. **Optymalizacja agregacji składników**
   - Kwestia: Czy agregacja składników powinna być cache'owana w bazie?
   - Aktualnie: Agregacja w logice aplikacyjnej przy każdym generowaniu listy
   - Post-MVP: Rozważyć materialized view dla często generowanych list

4. **Migracja danych historycznych**
   - Kwestia: Jak obsłużyć migracje dla istniejących użytkowników przy zmianach schematu?
   - Aktualnie: Brak strategii (MVP fresh start)
   - Rozważenie: Dokumentacja strategii migracji dla przyszłych zmian

5. **Limit długości list zakupów**
   - Kwestia: Czy wprowadzić limit liczby pozycji na liście zakupów?
   - Aktualnie: Brak limitu
   - Rozważenie: Monitoring w fazie beta, ewentualne wprowadzenie soft limit z ostrzeżeniem UX

6. **Archiwizacja starych danych**
   - Kwestia: Czy automatycznie archiwizować stare listy zakupów (np. > 6 miesięcy)?
   - Aktualnie: Brak strategii archiwizacji
   - Post-MVP: Rozważyć partycjonowanie lub soft delete dla starych list

### Obszary do testowania w fazie development

1. **Performance RLS policies** - Czy policies z EXISTS + JOIN nie spowalniają zapytań dla tabel relacyjnych?
2. **Concurrent updates** - Test race conditions przy generowaniu wielu list zakupów jednocześnie
3. **AI usage tracking** - Weryfikacja poprawności UPSERT w `ai_usage_log` przy concurrent requests
4. **Cascade delete performance** - Benchmark usuwania użytkownika z dużą liczbą przepisów (100+)

---

**Status:** Schemat bazy danych zaplanowany i gotowy do implementacji. Wszystkie kluczowe decyzje podjęte. Pozostałe kwestie nie blokują MVP i mogą być rozwiązane iteracyjnie podczas development/testing.
