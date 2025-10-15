# Podsumowanie Sesji Planowania PRD - GroceryList MVP

## Decyzje Projektowe

1. **Cel produktu**: Aplikacja webowa umożliwiająca tworzenie list zakupów na podstawie przepisów przypisanych do kalendarza tygodniowego z podziałem na 4 posiłki dziennie
2. **Grupa docelowa**: Pary w wieku 50+, średniozaawansowani kulinarnie, robiący zakupy raz w tygodniu
3. **Stos technologiczny**: Astro 5 + React 19 + TypeScript 5 + Tailwind CSS 4 + Shadcn/ui + Supabase
4. **Model AI**: OpenAI GPT-4 lub Anthropic Claude API do parsowania składników z tekstu przepisów
5. **Limit AI parsowania**: 20 przepisów miesięcznie na użytkownika (kontrola kosztów)
6. **System kalendarza**: Szablon tygodniowy (powtarzający się) z możliwością nadpisania dla konkretnego tygodnia
7. **Struktura posiłków**: 4 typy dziennie - śniadanie, drugie śniadanie, obiad, kolacja
8. **Eksport**: PDF i TXT z checkboxami do odznaczania podczas zakupów
9. **Timeline MVP**: 6-9 tygodni w 4 fazach rozwoju
10. **Autentykacja**: Email + hasło przez Supabase Auth (bez OAuth w MVP)

## Dopasowane Zalecenia do PRD

1. **Prostota interfejsu**: Duże przyciski (min 44px), czcionki 16-18px, wysokie kontrasty dla grupy 50+
2. **Mobile-first approach**: Responsywny design z priorytetem dla urządzeń mobilnych
3. **Accessibility**: Zgodność z WCAG 2.1 Level AA, keyboard navigation, screen reader support
4. **Error handling z fallback**: Jeśli AI nie rozpozna składników, użytkownik dodaje je ręcznie
5. **RODO compliance**: Możliwość usunięcia konta, dane w EU (Supabase), przejrzysta polityka prywatności
6. **Iteracyjne testowanie**: Walidacja MVP z min. 20 beta testerów przed pełnym wdrożeniem
7. **Performance targets**: Czas ładowania < 2s, dostępność 99%+, Lighthouse score 90+
8. **Agregacja inteligentna**: Sumowanie składników o tej samej nazwie i jednostce
9. **Rate limiting**: Kontrola wykorzystania AI API przez limit miesięczny
10. **Row Level Security**: Użytkownik widzi tylko swoje dane (Supabase RLS policies)

## Szczegółowe Podsumowanie Planowania PRD

### Główne Wymagania Funkcjonalne

#### 1. Zarządzanie Przepisami (Faza 1: 2-3 tygodnie)
- **CRUD przepisów**: Użytkownik może dodawać, przeglądać, edytować i usuwać przepisy
- **AI parsowanie składników**: Automatyczne rozpoznawanie składników z tekstu (nazwa, ilość, jednostka, kategoria)
- **Obsługa błędów AI**: Fallback do ręcznego dodawania składników, komunikat o błędzie
- **Limit AI**: 20 parsowań/użytkownik/miesiąc z licznikiem w ustawieniach
- **Edycja składników**: Użytkownik może ręcznie poprawić rozpoznane składniki przed zapisem

#### 2. Kalendarz i Planowanie Posiłków (Faza 2: 2-3 tygodnie)
- **Kalendarz tygodniowy**: 7 dni × 4 posiłki (28 slotów)
- **System szablonów**: Szablon tygodnia (powtarzający się) + instancje (nadpisania dla konkretnego tygodnia)
- **Modal wyboru**: "Zmienić tylko ten tydzień czy szablon?" przy każdej modyfikacji
- **Przypisywanie przepisów**: Flow z checkboxami - wybór przepisu → zaznaczenie dni/posiłków → przypisanie
- **Responsywność**: Desktop (tabela 7×4), Mobile (akordeon z rozwijalnymi dniami)

#### 3. Lista Zakupów (Faza 3: 1-2 tygodnie)
- **Generowanie z kalendarza**: Checkboxy przy posiłkach → wybór → generowanie listy
- **Agregacja składników**: Sumowanie składników o tej samej nazwie i jednostce
- **Grupowanie w kategorie**: Nabiał, Warzywa, Owoce, Mięso, Pieczywo, Przyprawy, Inne
- **Edycja listy**: Dodawanie wolnych pozycji, usuwanie, zmiana ilości/jednostki/kategorii
- **Checkboxy "kupione"**: Odznaczanie podczas zakupów, stan zapisywany w bazie
- **Historia list**: Przeglądanie wcześniej wygenerowanych list

#### 4. Eksport (Faza 4: 1 tydzień)
- **PDF**: Czysty layout z checkboxami (☐), paginacja, czcionka 12pt sans-serif
- **TXT**: Plain text z [ ] do odznaczania
- **Format**: Nagłówek (data tygodnia, data generowania) + kategorie + składniki
- **Nazwa pliku**: `lista-zakupow-YYYY-MM-DD.pdf/txt`

### Kluczowe Historie Użytkownika

#### US1: Dodawanie Pierwszego Przepisu
**Jako** nowy użytkownik
**Chcę** dodać swój pierwszy przepis z AI parsowaniem
**Aby** móc zacząć planować posiłki

**Flow**:
1. Klik "+ Dodaj przepis"
2. Wypełnienie: Nazwa + Przepis (textarea)
3. Klik "Rozpoznaj składniki" → loader (3-5s)
4. Wyświetlenie tabeli składników (edytowalnej)
5. Opcjonalna edycja
6. Klik "Zapisz przepis" → redirect do listy

**Acceptance Criteria**:
- ✅ AI parsuje składniki w ciągu 3-5 sekund
- ✅ Użytkownik widzi i może edytować rozpoznane składniki
- ✅ Przepis pojawia się na liście po zapisaniu

#### US2: Planowanie Tygodnia
**Jako** użytkownik z przepisami
**Chcę** zaplanować posiłki na cały tydzień
**Aby** wiedzieć, co będę gotować każdego dnia

**Flow**:
1. Wejście w "Kalendarz Tygodnia"
2. Wejście w "Moje Przepisy" → klik na przepis
3. Modal "Przypisz do kalendarza" z checkboxami
4. Zaznaczenie np. "Poniedziałek - Śniadanie", "Wtorek - Śniadanie"
5. Klik "Przypisz"
6. Przepis widoczny w zaznaczonych komórkach kalendarza

**Acceptance Criteria**:
- ✅ Checkboxy przy każdym dniu/posiłku w modalu
- ✅ Przepis pojawia się w kalendarzu po zatwierdzeniu

#### US3: Generowanie Listy Zakupów
**Jako** użytkownik z zaplanowanym tygodniem
**Chcę** wygenerować listę zakupów z agregacją składników
**Aby** wiedzieć, co kupić w sklepie

**Flow**:
1. Wejście w "Kalendarz Tygodnia"
2. Klik "Generuj listę zakupów"
3. Zaznaczenie checkboxów przy posiłkach (wszystkie lub wybrane dni)
4. Klik "Generuj listę" → loader (2-3s)
5. Redirect do "Lista Zakupów"
6. Składniki podzielone na kategorie, zsumowane

**Acceptance Criteria**:
- ✅ Składniki z wielu przepisów są zsumowane (np. mleko 500ml + 200ml = 700ml)
- ✅ Grupowanie w kategorie działa poprawnie

#### US4: Eksport do PDF
**Jako** użytkownik z wygenerowaną listą
**Chcę** wydrukować listę do zabrania do sklepu
**Aby** mieć fizyczną kopię podczas zakupów

**Flow**:
1. Wejście w "Lista Zakupów"
2. Klik "Pobierz PDF"
3. Plik `lista-zakupow-2025-10-14.pdf` pobierany
4. Otwarcie → lista z kategoriami i checkboxami
5. Wydrukowanie

**Acceptance Criteria**:
- ✅ Plik PDF natychmiast pobierany
- ✅ Format czytelny z checkboxami

#### US5: Odznaczanie Produktów w Sklepie
**Jako** użytkownik w sklepie z telefonem
**Chcę** odznaczać kupione produkty
**Aby** wiedzieć, co mi jeszcze zostało

**Flow**:
1. Otwarcie aplikacji na telefonie
2. Wejście w "Lista Zakupów"
3. Klik checkbox przy "Mleko - 1500ml" → produkt przekreślony
4. Stan zapisywany automatycznie
5. Po odświeżeniu checkbox nadal zaznaczony

**Acceptance Criteria**:
- ✅ Stan checkboxa zapisywany w bazie danych
- ✅ Odznaczone produkty przekreślone (CSS)

### Kryteria Sukcesu i Metryki KPI

#### Metryki Kluczowe dla MVP

| Metryka | Cel MVP | Sposób Pomiaru |
|---------|---------|----------------|
| **WAU (Weekly Active Users)** | 50+ po 8 tygodniach | Liczba unikalnych logowań w tygodniu |
| **Listy/użytkownika miesięcznie** | Średnio 3-4 listy | Średnia wygenerowanych list na aktywnego użytkownika |
| **Przepisy na użytkownika** | 10+ przepisów | Średnia zapisanych przepisów w bazie |
| **30-day retention** | 40%+ | % użytkowników aktywnych po 30 dniach od rejestracji |
| **NPS** | 50+ | Ankieta po 2 tygodniach: "Jak prawdopodobne, że polecisz?" (0-10) |

#### Metryki Pomocnicze

- **Eksport do PDF/TXT**: 70%+ list jest eksportowanych
- **Sukces parsowania AI**: 80%+ przepisów poprawnie rozpoznanych
- **Średni czas sesji**: 5-10 minut
- **Bounce rate**: < 30%

### Architektura Techniczna

#### Frontend
- **Astro 5**: SSR framework z hybrid rendering
- **React 19**: Interaktywne komponenty (islands architecture)
- **TypeScript 5**: Strict type safety
- **Tailwind CSS 4**: Utility-first z Vite plugin
- **Shadcn/ui**: UI components (New York style)

#### Backend
- **Supabase**: PostgreSQL, Authentication, RLS
- **Astro API routes**: Server-side endpoints
- **Node.js Adapter**: Standalone server mode

#### AI/ML
- **OpenAI GPT-4** lub **Anthropic Claude API**: Parsowanie składników

#### Export
- **jsPDF** lub **PDFKit**: Generowanie PDF
- Plain text formatting: Export TXT

#### Deployment
- **Vercel** lub **Netlify**: Hosting
- **Supabase Cloud**: Managed database (EU region)

#### Database Schema (główne tabele)

```sql
-- Przepisy
recipes (id, user_id, name, full_text, created_at, updated_at)
ingredients (id, recipe_id, name, quantity, unit, category, order)

-- Kalendarz
calendar_template (id, user_id, day_of_week, meal_type, recipe_id)  -- Szablon
calendar_instances (id, user_id, date, meal_type, recipe_id)        -- Instancje

-- Listy zakupów
shopping_lists (id, user_id, week_start_date, created_at)
shopping_list_items (id, list_id, name, quantity, unit, category, is_checked, is_manual)
shopping_list_sources (id, list_id, recipe_id, date, meal_type)     -- Mapowanie

-- Ustawienia użytkownika
user_settings (user_id, ai_parsing_count, ai_parsing_reset_date)
```

### Ważne Ograniczenia i Ryzyka

#### Ograniczenia MVP
- **AI parsowanie**: Limit 20 przepisów/miesiąc, brak konwersji jednostek
- **Kalendarz**: Tylko widok tygodniowy, brak historii wcześniejszych tygodni
- **Agregacja**: Tylko po nazwie (lowercase matching), brak synonimów
- **Performance**: Brak paginacji w liście przepisów (zakładane max 50 przepisów)
- **Bezpieczeństwo**: Email + hasło, brak 2FA

#### Identyfikowane Ryzyka i Mitigacja

1. **AI parsowanie < 80% sukcesu**
   - Mitigacja: Iteracyjne testowanie promptu, fallback do ręcznego dodawania, testowanie na 50+ przepisach

2. **Koszt AI API przekroczy budżet**
   - Mitigacja: Limit 20/user/month, monitoring kosztów, możliwość przełączenia na tańszy model

3. **Trudności użytkowników 50+ z obsługą**
   - Mitigacja: Prosty UI (duże przyciski, czytelne czcionki), user testing z min. 5 użytkownikami 50+, tooltips, FAQ

4. **Niska adopcja użytkowników**
   - Mitigacja: Walidacja z 20 beta testerów, ankiety NPS, iteracyjne usprawnienia, marketing w lokalnych grupach

5. **Problemy z performance**
   - Mitigacja: Optymalizacja Astro (SSR + static), code splitting, monitoring Lighthouse/Web Vitals

6. **Naruszenie RODO**
   - Mitigacja: Konsultacja prawna, Supabase EU region, hard delete po usunięciu konta, audyty RLS policies

## Nierozwiązane Kwestie

### Do Rozstrzygnięcia Przed Implementacją

1. **Wybór AI API**: OpenAI (GPT-4) vs Anthropic (Claude)?
   - Kryteria: koszt, dokładność parsowania, dostępność w Polsce
   - Zalecenie: Testowanie obu i porównanie wyników na próbce 20 przepisów

2. **Reset szablonu tygodnia**: Czy automatycznie resetować szablon co miesiąc?
   - Obecnie: Szablon działa "na zawsze"
   - Do rozważenia: Archiwizacja starych szablonów, resetowanie co X miesięcy

3. **Walidacja limitu AI**: Czy 20 parsowań/miesiąc to optymalna wartość?
   - Do zwalidowania na podstawie user testing
   - Możliwość dynamicznego dostosowania (10 dla nowych, 30 dla power users)

4. **Priorytety faz rozwoju**: Czy kolejność Faza 1 → 2 → 3 → 4 jest optymalna?
   - Możliwość równoległego rozwoju niektórych funkcji (np. eksport podczas Fazy 3)

5. **Strategia onboardingu**: Czy potrzebny guided tour dla nowych użytkowników?
   - Grupa 50+ może potrzebować dodatkowego wsparcia
   - Do przetestowania z beta testerami

### Obszary Wymagające Dalszego Wyjaśnienia

1. **Konwersja jednostek**: Jak obsłużyć mieszane jednostki (ml + szklanki)?
   - MVP: Brak automatycznej konwersji (pozostają osobno)
   - Post-MVP: Inteligentna konwersja z predefiniowanymi współczynnikami

2. **Synonimy składników**: Jak obsłużyć "pomidor" vs "pomidory"?
   - MVP: Brak automatycznego grupowania
   - Post-MVP: AI rozpoznaje synonimy i formy liczby mnogiej

3. **Edycja szablonu z przypisanymi przepisami**: Co się dzieje, gdy użytkownik usuwa przepis używany w szablonie?
   - Zalecenie: ON DELETE SET NULL w bazie, pusta komórka w kalendarzu

4. **Limit długości przepisu**: Czy ograniczyć maksymalną długość tekstu przepisu dla AI?
   - Zalecenie: Max 5000 znaków (kontrola kosztów tokenów AI)

5. **Obsługa wielokrotnego przypisania**: Czy przepis może być przypisany do wielu slotów jednocześnie?
   - PRD: Tak, flow z checkboxami pozwala na zaznaczenie wielu dni/posiłków
   - Do potwierdzenia w prototypie

---

## Następne Kroki

1. **Rozstrzygnięcie nierozwiązanych kwestii** (1-3 dni)
2. **Setup projektu**: Inicjalizacja Astro + React + Supabase (1 dzień)
3. **Faza 1: Foundation & Recipe Management** (2-3 tygodnie)
4. **Faza 2: Calendar & Meal Planning** (2-3 tygodnie)
5. **Faza 3: Shopping List Generation** (1-2 tygodnie)
6. **Faza 4: Export & Polish** (1 tydzień)
7. **Beta testing z 20 użytkownikami** (2 tygodnie)
8. **Iteracje na podstawie feedbacku** (1-2 tygodnie)
9. **Publiczne wdrożenie MVP** (po walidacji metryk)

---

*Dokument wygenerowany: 2025-10-15*
*Źródło: .ai/planning_assistant.md*