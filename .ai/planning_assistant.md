# Product Requirements Document (PRD)
# GroceryList - MVP

**Wersja:** 1.0
**Data:** 2025-10-13
**Autor:** Product Team
**Status:** Draft

---

## 1. Executive Summary

**GroceryList** to aplikacja webowa, która umożliwia użytkownikom tworzenie list zakupów na podstawie przepisów kulinarnych przypisanych do kalendarza tygodniowego z podziałem na posiłki. Aplikacja rozwiązuje problem czasochłonnego ręcznego tworzenia list zakupów i zapominania składników podczas zakupów.

### Kluczowe cele MVP:
- Umożliwienie łatwego zarządzania przepisami kulinarnymi
- Planowanie posiłków w kalendarzu tygodniowym
- Automatyczne generowanie list zakupów z agregacją składników
- Eksport list do formatu PDF/TXT gotowego do druku

### Grupa docelowa:
Pary w wieku 50+, średniozaawansowani kulinarnie, robiący zakupy raz w tygodniu w dyskontach, gotujący codziennie z planowaniem posiłków z wyprzedzeniem.

---

## 2. Problem Statement

### Główne problemy użytkowników:

1. **Zapominanie składników podczas zakupów**
   - Użytkownicy nie mają jednolitej listy zakupów uwzględniającej wszystkie zaplanowane posiłki
   - Skutkuje to wielokrotnymi wizytami w sklepie i frustracją

2. **Tracenie czasu na tworzenie listy zakupów z przepisów**
   - Ręczne przepisywanie składników z wielu przepisów jest czasochłonne
   - Trudność w agregowaniu powtarzających się składników z różnych przepisów
   - Brak centralnego miejsca do zarządzania przepisami i planowania posiłków

### Impact:
- Straty czasowe: ~30-60 minut tygodniowo na ręczne tworzenie list
- Dodatkowe koszty: niepotrzebne wizyty w sklepie, zakup duplikatów
- Frustracja: stres związany z zapominaniem składników

---

## 3. Target Users & Personas

### Persona 1: "Anna & Marek - Zaplanowana Para"

**Demograficzne:**
- Wiek: 50-60 lat
- Status: Para małżeńska
- Miejsce zamieszkania: Miasto średniej wielkości

**Nawyki zakupowe:**
- Robią zakupy raz w tygodniu (sobota lub niedziela)
- Preferują dyskonty (Biedronka, Lidl, Kaufland)
- Planują wydatki z wyprzedzeniem

**Nawyki kulinarne:**
- Gotują codziennie (lunch i obiad)
- Średniozaawansowani - znają podstawowe przepisy, eksperymentują umiarkowanie
- Planują posiłki z tygodniowym wyprzedzeniem
- Mają ~20-30 ulubionych przepisów, które rotują

**Potrzeby technologiczne:**
- Używają smartfonów (Android/iOS) na poziomie podstawowym/średnim
- Preferują proste, intuicyjne interfejsy z dużymi przyciskami
- Cenią czytelność i brak skomplikowanych funkcji

**Goals:**
- Zaoszczędzić czas na planowaniu zakupów
- Uniknąć zapominania składników
- Mieć wszystkie przepisy w jednym miejscu
- Móc wydrukować listę zakupów przed wyjściem do sklepu

**Pain Points:**
- Przepisy rozrzucone w notesach, książkach, internecie
- Trudność w szybkim znalezieniu sprawdzonego przepisu
- Czasochłonne przepisywanie składników do listy zakupów
- Zapominanie o składnikach używanych w wielu przepisach (np. mleko, jajka)

---

## 4. Product Vision & Goals

### Vision Statement:
*"GroceryList to najprostsze narzędzie do planowania posiłków i zakupów dla osób, które gotują regularnie i cenią organizację."*

### Product Goals:

**Cel biznesowy:**
- Zwalidowanie MVP w ciągu 3 miesięcy od wdrożenia
- Zdobycie 100 aktywnych użytkowników tygodniowo w pierwszym kwartale
- Osiągnięcie 30-day retention na poziomie min. 40%

**Cele użytkownika:**
- Zmniejszenie czasu potrzebnego na stworzenie listy zakupów o 80% (z 30-60 min do 5-10 min)
- Redukcja zapomnianych składników o 90%
- Centralizacja wszystkich przepisów użytkownika w jednym miejscu

**Cele techniczne:**
- Responsive web app działająca na mobile i desktop
- Czas ładowania strony < 2 sekundy
- Dostępność aplikacji 99%+
- Bezpieczne przechowywanie danych użytkowników (RODO compliance)

---

## 5. Success Metrics (KPIs)

### Metryki kluczowe dla MVP:

| Metryka | Cel MVP | Sposób pomiaru |
|---------|---------|----------------|
| **WAU (Weekly Active Users)** | 50+ użytkowników po 8 tygodniach | Liczba unikalnych użytkowników logujących się w danym tygodniu |
| **Liczba list zakupów/użytkownika miesięcznie** | Średnio 3-4 listy | Średnia liczba wygenerowanych list na aktywnego użytkownika |
| **Średnia liczba przepisów na użytkownika** | 10+ przepisów | Średnia liczba zapisanych przepisów w bazie użytkownika |
| **30-day retention** | 40%+ | % użytkowników aktywnych po 30 dniach od rejestracji |
| **NPS (Net Promoter Score)** | 50+ | Ankieta po 2 tygodniach użytkowania: "Jak prawdopodobne, że polecisz GroceryList?" (0-10) |

### Metryki pomocnicze:

- **Wskaźnik eksportu do PDF/TXT:** % list zakupów, które zostały wyeksportowane (cel: 70%+)
- **Sukces parsowania AI:** % przepisów, w których AI poprawnie rozpoznało składniki (cel: 80%+)
- **Średni czas sesji:** Średni czas spędzony w aplikacji podczas jednej wizyty (cel: 5-10 minut)
- **Bounce rate:** % użytkowników, którzy opuścili stronę bez żadnej interakcji (cel: <30%)

---

## 6. Feature Requirements

### 6.1 User Authentication & Account Management

**Priority:** P0 (Must Have)
**Phase:** Faza 1

#### Functional Requirements:

**FR-AUTH-001: Rejestracja użytkownika**
- Użytkownik może zarejestrować konto używając adresu email i hasła
- Wymagane pola: email, hasło (min. 8 znaków)
- Walidacja formatu email
- Weryfikacja email (potwierdzenie przez link w emailu) - wykorzystując Supabase Auth
- Hasło musi spełniać wymagania: min. 8 znaków, mix liter i cyfr

**FR-AUTH-002: Logowanie**
- Użytkownik może zalogować się używając email + hasło
- Sesja użytkownika jest zachowywana (remember me)
- Możliwość wylogowania

**FR-AUTH-003: Resetowanie hasła**
- Opcja "Zapomniałeś hasła?" na stronie logowania
- Link resetujący wysyłany na email (Supabase Auth)
- Użytkownik może ustawić nowe hasło przez link

**FR-AUTH-004: Usunięcie konta**
- Użytkownik może usunąć swoje konto z poziomu ustawień
- Potwierdzenie operacji (modal: "Czy na pewno?")
- Wszystkie dane użytkownika (przepisy, listy) są usuwane z bazy danych
- Zgodność z RODO

#### UI/UX Requirements:
- Prosta strona logowania z logo aplikacji
- Formularz rejestracji z czytelną walidacją błędów
- Komunikaty o błędach wyświetlane inline (czerwony tekst pod polem)
- Duże przyciski (min. 44px wysokości) dla grupy 50+

#### Technical Requirements:
- Wykorzystanie Supabase Auth (email + password provider)
- Sesje zarządzane przez Supabase
- Middleware Astro do sprawdzania autentykacji (context.locals.supabase)

---

### 6.2 Recipe Management (CRUD)

**Priority:** P0 (Must Have)
**Phase:** Faza 1

#### Functional Requirements:

**FR-RECIPE-001: Dodawanie przepisu**
- Użytkownik może dodać nowy przepis przez prosty formularz
- Pole tekstowe (textarea) na wklejenie pełnego przepisu jako plain text
- Po wklejeniu przepisu, AI automatycznie parsuje składniki z tekstu
- AI rozpoznaje: nazwę składnika + ilość + jednostkę + kategorię produktu
  - Przykład: "mleko - 500ml - nabiał"
- Po parsowaniu, użytkownik widzi listę rozpoznanych składników i może je edytować przed zapisem
- Możliwość ręcznej edycji/dodania/usunięcia składników

**FR-RECIPE-002: Obsługa błędów parsowania AI**
- Jeśli AI nie rozpozna składników poprawnie lub wystąpi błąd:
  - Przepis zostaje zapisany z pełnym tekstem
  - Lista składników pozostaje pusta
  - Komunikat: "Nie udało się automatycznie rozpoznać składników. Dodaj je ręcznie."
- Użytkownik może ręcznie dodać składniki w trybie edycji przepisu

**FR-RECIPE-003: Limit parsowania AI**
- Maksymalnie 20 przepisów z AI-parsing miesięcznie na użytkownika
- Po przekroczeniu limitu: komunikat informujący o limicie + możliwość ręcznego dodania składników
- Licznik wykorzystania widoczny w ustawieniach profilu

**FR-RECIPE-004: Przeglądanie przepisów**
- Lista wszystkich przepisów użytkownika
- Każda karta przepisu wyświetla tylko nazwę przepisu (minimalistyczny widok)
- Prosty scroll przez listę (brak wyszukiwania/filtrowania w MVP)
- Sortowanie domyślnie: od najnowszych

**FR-RECIPE-005: Wyświetlanie szczegółów przepisu**
- Kliknięcie w przepis otwiera widok szczegółowy
- Wyświetlane informacje:
  - Nazwa przepisu
  - Pełny tekst przepisu
  - Lista składników (nazwa, ilość, jednostka, kategoria)
- Przyciski akcji: "Edytuj", "Usuń"

**FR-RECIPE-006: Edycja przepisu**
- Użytkownik może edytować istniejący przepis
- Możliwość zmiany tekstu przepisu
- Możliwość edycji listy składników (dodanie, usunięcie, zmiana ilości/jednostki/kategorii)
- Brak ponownego parsowania AI przy edycji (oszczędność limitu)

**FR-RECIPE-007: Usuwanie przepisu**
- Użytkownik może usunąć przepis
- Potwierdzenie operacji (modal: "Czy na pewno usunąć przepis [nazwa]?")
- Po usunięciu, przepis znika z listy i kalendarza (jeśli był przypisany)

#### UI/UX Requirements:
- Duży przycisk "+ Dodaj przepis" widoczny na liście przepisów
- Formularz dodawania przepisu:
  - Pole "Nazwa przepisu" (input text)
  - Pole "Przepis" (textarea, min. 10 linii)
  - Przycisk "Rozpoznaj składniki" (wywołuje AI)
  - Loader/spinner podczas parsowania AI
- Widok rozpoznanych składników:
  - Tabela: Nazwa | Ilość | Jednostka | Kategoria
  - Każdy wiersz edytowalny inline
  - Przycisk "+ Dodaj składnik ręcznie"
  - Przycisk "Zapisz przepis"

#### Technical Requirements:
- API endpoint: POST /api/recipes (dodawanie)
- API endpoint: GET /api/recipes (lista)
- API endpoint: GET /api/recipes/[id] (szczegóły)
- API endpoint: PUT /api/recipes/[id] (edycja)
- API endpoint: DELETE /api/recipes/[id] (usuwanie)
- API endpoint: POST /api/recipes/parse (parsowanie AI)
- Integracja z AI API (OpenAI GPT-4 lub Claude API) dla parsowania składników
- Tabele w Supabase:
  - `recipes`: id, user_id, name, full_text, created_at, updated_at
  - `ingredients`: id, recipe_id, name, quantity, unit, category, order
- Walidacja: Zod schemas dla wszystkich requestów
- Rate limiting dla AI parsing (20/user/month)

#### AI Prompt Engineering:
```
Zadanie: Rozpoznaj składniki z poniższego przepisu kulinarnego.

Przepis:
{full_recipe_text}

Zwróć JSON array obiektów z następującymi polami:
- name: nazwa składnika (lowercase, singular)
- quantity: ilość (number lub null)
- unit: jednostka miary (np. "ml", "g", "szt.", "szklanka", "łyżka") lub null
- category: kategoria produktu z listy: "nabiał", "warzywa", "owoce", "mięso", "pieczywo", "przyprawy", "inne"

Przykład:
[
  {"name": "mleko", "quantity": 500, "unit": "ml", "category": "nabiał"},
  {"name": "jajka", "quantity": 3, "unit": "szt.", "category": "nabiał"},
  {"name": "mąka", "quantity": 2, "unit": "szklanka", "category": "inne"}
]

Jeśli nie możesz rozpoznać składnika, pomiń go.
```

---

### 6.3 Weekly Calendar & Meal Planning

**Priority:** P0 (Must Have)
**Phase:** Faza 2

#### Functional Requirements:

**FR-CALENDAR-001: Wyświetlanie kalendarza tygodniowego**
- Kalendarz pokazuje 7 dni tygodnia (Poniedziałek - Niedziela)
- Każdy dzień ma 4 typy posiłków: Śniadanie, Drugie śniadanie, Obiad, Kolacja
- Kalendarz pokazuje bieżący tydzień (od poniedziałku do niedzieli)
- Na desktop: widok tabelaryczny (7 kolumn x 4 wiersze)
- Na mobile: widok listy z akordeonami (dzień po dniu)

**FR-CALENDAR-002: System szablonów tygodnia**
- Użytkownik pracuje na "szablonie tygodnia", który automatycznie się powtarza co tydzień
- Szablon to wzorzec posiłków: "każdy poniedziałek na śniadanie - jajecznica"
- Użytkownik może modyfikować konkretny tydzień (instancję)
- Przy każdej zmianie przepisu w kalendarzu, pojawia się pytanie:
  - Modal: "Zmienić tylko ten tydzień czy szablon na stałe?"
  - Opcje: [Tylko ten tydzień] [Szablon (zawsze)]

**FR-CALENDAR-003: Przypisywanie przepisu do posiłku**
- Przepływ: Użytkownik najpierw wybiera przepis z listy przepisów
- Po wybraniu przepisu, otwiera się widok kalendarza z checkboxami przy każdym dniu/posiłku
- Użytkownik zaznacza checkboxami, gdzie chce przypisać przepis
- Przycisk "Przypisz" zatwierdza operację
- Jeden posiłek = maksymalnie jeden przepis (MVP uproszczone)

**FR-CALENDAR-004: Wyświetlanie przypisanych przepisów**
- Każda komórka kalendarza (dzień + posiłek) pokazuje nazwę przypisanego przepisu
- Jeśli brak przepisu: pusta komórka z ikoną "+"
- Kliknięcie w przepis otwiera szczegóły przepisu

**FR-CALENDAR-005: Usuwanie przepisu z kalendarza**
- Użytkownik może usunąć przepis z konkretnego dnia/posiłku (ikona "x")
- Pytanie: "Usunąć tylko z tego tygodnia czy z szablonu?"
- Opcje: [Tylko ten tydzień] [Z szablonu]

**FR-CALENDAR-006: Puste stany (empty states)**
- Jeśli kalendarz jest pusty (brak przepisów):
  - Komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
  - Przycisk: "Dodaj pierwszy przepis"

#### UI/UX Requirements:

**Desktop view:**
- Tabela 7x4 z nagłówkami dni i posiłków
- Każda komórka: nazwa przepisu (text wrap) + ikona "x" (remove)
- Pusta komórka: ikona "+" z tooltipem "Przypisz przepis"

**Mobile view (responsywny):**
- Akordeon: każdy dzień to osobna sekcja (rozwijana)
- Wewnątrz dnia: lista 4 posiłków (karty)
- Każda karta posiłku: nazwa posiłku + przypisany przepis (jeśli jest)

**Modal przypisywania:**
- Tytuł: "Przypisz przepis: [nazwa przepisu]"
- Kalendarz z checkboxami przy każdym posiłku
- Przyciski: [Anuluj] [Przypisz]

**Modal edycji (szablon vs instancja):**
- Tytuł: "Jak chcesz zmienić ten przepis?"
- Opis: "Możesz zmienić przepis tylko dla tego tygodnia lub na stałe w szablonie."
- Przyciski: [Tylko ten tydzień] [Szablon (zawsze)]

#### Technical Requirements:
- API endpoint: GET /api/calendar/template (szablon tygodnia)
- API endpoint: PUT /api/calendar/template (aktualizacja szablonu)
- API endpoint: GET /api/calendar/week?date=YYYY-MM-DD (instancja konkretnego tygodnia)
- API endpoint: PUT /api/calendar/week (aktualizacja instancji tygodnia)
- Tabele w Supabase:
  - `calendar_template`: id, user_id, day_of_week (1-7), meal_type (enum), recipe_id
  - `calendar_instances`: id, user_id, date, meal_type, recipe_id (override szablonu)
- Logika: jeśli istnieje wpis w `calendar_instances`, użyj go; w przeciwnym razie użyj `calendar_template`

---

### 6.4 Shopping List Generation

**Priority:** P0 (Must Have)
**Phase:** Faza 3

#### Functional Requirements:

**FR-SHOPLIST-001: Generowanie listy zakupów z kalendarza**
- Na widoku kalendarza: przycisk "Generuj listę zakupów"
- Po kliknięciu: kalendarz przechodzi w "tryb selekcji"
- Pojawiają się checkboxy przy każdym przypisanym posiłku
- Użytkownik zaznacza, które posiłki chce uwzględnić w liście zakupów
- Przycisk "Generuj listę" tworzy nową listę zakupów

**FR-SHOPLIST-002: Agregacja składników**
- System automatycznie sumuje składniki z zaznaczonych posiłków/przepisów
- Jeśli ten sam składnik występuje w wielu przepisach:
  - Składniki są zsumowane według nazwy (np. "mleko" + "mleko" = jedna pozycja)
  - Ilości są dodawane (500ml + 200ml = 700ml)
  - Jednostka jest zachowana (jeśli zgodna)
- Jeśli jednostki są różne (np. "1 szklanka mleka" + "200ml mleka"):
  - Brak inteligentnej konwersji w MVP
  - Składniki pozostają osobno

**FR-SHOPLIST-003: Grupowanie w kategorie**
- Lista zakupów jest podzielona na kategorie produktów:
  - Nabiał
  - Warzywa
  - Owoce
  - Mięso
  - Pieczywo
  - Przyprawy
  - Inne
- Predefiniowana lista kategorii
- Użytkownik może dodać własne kategorie (opcjonalnie)
- Jeśli AI przypisało błędną kategorię, użytkownik może ją ręcznie zmienić

**FR-SHOPLIST-004: Przeglądanie listy zakupów**
- Lista wszystkich wygenerowanych list zakupów (historia)
- Każda lista: data utworzenia + liczba produktów
- Domyślnie wyświetlana najnowsza lista

**FR-SHOPLIST-005: Edycja listy zakupów**
- Użytkownik może ręcznie edytować wygenerowaną listę:
  - Dodawanie produktu (dowolny, nie tylko ze składników)
  - Usuwanie produktu
  - Zmiana ilości
  - Zmiana kategorii
- Ręcznie dodane produkty oznaczone jako "wolne pozycje" (nie związane z przepisem)

**FR-SHOPLIST-006: Odznaczanie produktów jako "kupione"**
- Każdy produkt na liście ma checkbox
- Użytkownik może odznaczać produkty podczas zakupów
- Stan checkboxów jest zapisywany w bazie danych
- Odznaczone produkty są przekreślone (CSS: text-decoration: line-through)

**FR-SHOPLIST-007: Zapis listy w bazie danych**
- Każda wygenerowana lista jest zapisywana w bazie danych
- Lista zawiera:
  - Datę utworzenia
  - Źródło: które posiłki/przepisy zostały uwzględnione
  - Listę produktów (zsumowanych składników + wolne pozycje)
  - Stan każdego produktu (kupiony/niekupiony)

#### UI/UX Requirements:

**Widok generowania:**
- Przycisk "Generuj listę zakupów" na górze widoku kalendarza
- Po kliknięciu: checkboxy pojawiają się przy każdym posiłku
- Przyciski: [Anuluj] [Generuj listę]

**Widok listy zakupów:**
- Nagłówek: "Lista zakupów na tydzień [data]"
- Podział na kategorie (sections)
- Każda kategoria: nagłówek + lista produktów
- Każdy produkt: checkbox + nazwa + ilość + jednostka
- Przycisk "Edytuj listę" (otwiera tryb edycji)
- Przyciski: "Pobierz PDF" | "Pobierz TXT"

**Tryb edycji:**
- Każdy produkt ma ikonę "x" (usuń)
- Pola ilość i jednostka są edytowalne inline
- Dropdown do zmiany kategorii
- Przycisk "+ Dodaj produkt" (otwiera formularz)
- Przyciski: [Anuluj] [Zapisz zmiany]

#### Technical Requirements:
- API endpoint: POST /api/shopping-lists (generowanie nowej listy)
- API endpoint: GET /api/shopping-lists (historia list)
- API endpoint: GET /api/shopping-lists/[id] (szczegóły listy)
- API endpoint: PUT /api/shopping-lists/[id] (edycja listy)
- API endpoint: PATCH /api/shopping-lists/[id]/items/[itemId] (toggle checkbox)
- Tabele w Supabase:
  - `shopping_lists`: id, user_id, created_at, week_start_date
  - `shopping_list_items`: id, list_id, name, quantity, unit, category, is_checked, is_manual (czy dodane ręcznie)
  - `shopping_list_sources`: id, list_id, recipe_id (mapowanie: lista -> przepisy)
- Logika agregacji składników (backend):
  - Query: pobranie wszystkich składników z zaznaczonych przepisów
  - Grupowanie po nazwie składnika (lowercase)
  - Sumowanie ilości (jeśli jednostka jest taka sama)
  - Przypisanie do kategorii

---

### 6.5 Export Functionality (PDF/TXT)

**Priority:** P0 (Must Have)
**Phase:** Faza 4

#### Functional Requirements:

**FR-EXPORT-001: Eksport do PDF**
- Użytkownik może wyeksportować listę zakupów do formatu PDF
- Przycisk "Pobierz PDF" na widoku listy zakupów
- Natychmiastowe pobranie pliku PDF (bez modala/preview)
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.pdf`

**FR-EXPORT-002: Eksport do TXT**
- Użytkownik może wyeksportować listę zakupów do formatu TXT
- Przycisk "Pobierz TXT" na widoku listy zakupów
- Natychmiastowe pobranie pliku TXT
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.txt`

**FR-EXPORT-003: Format eksportu**
- **Nagłówek:**
  - "Lista zakupów na tydzień [data początku] - [data końca]"
  - Data wygenerowania
- **Treść:**
  - Lista składników zgrupowana w kategorie
  - Każda kategoria: nagłówek (np. "NABIAŁ:")
  - Każdy składnik: [ ] Nazwa - ilość jednostka
  - Checkbox ([ ] w TXT, unchecked box w PDF) do odznaczania podczas zakupów
- **Przykład TXT:**
  ```
  Lista zakupów na tydzień 14.10.2025 - 20.10.2025
  Wygenerowano: 13.10.2025

  NABIAŁ:
  [ ] Mleko - 1500 ml
  [ ] Jajka - 12 szt.
  [ ] Masło - 200 g

  WARZYWA:
  [ ] Pomidory - 1 kg
  [ ] Ogórki - 3 szt.

  MIĘSO:
  [ ] Kurczak - 500 g
  ```

**FR-EXPORT-004: Format PDF**
- Czysty, minimalistyczny layout
- Czcionka: sans-serif, rozmiar 12pt
- Checkboxy jako puste kwadraty (☐)
- Podział na sekcje (kategorie) z pogrubionym nagłówkiem
- Paginacja (jeśli lista jest długa)

#### UI/UX Requirements:
- Dwa osobne przyciski obok siebie: [Pobierz PDF] [Pobierz TXT]
- Ikony: PDF (ikona dokumentu), TXT (ikona pliku tekstowego)
- Loader/spinner podczas generowania (1-2 sekundy)
- Toast notification po udanym eksporcie: "Lista zakupów została pobrana"

#### Technical Requirements:
- API endpoint: GET /api/shopping-lists/[id]/export/pdf
- API endpoint: GET /api/shopping-lists/[id]/export/txt
- Biblioteka do generowania PDF: **jsPDF** lub **PDFKit** (Node.js)
- Export TXT: prosty string formatting + Content-Disposition header
- Response headers:
  - `Content-Type: application/pdf` (PDF)
  - `Content-Type: text/plain; charset=utf-8` (TXT)
  - `Content-Disposition: attachment; filename="lista-zakupow-YYYY-MM-DD.pdf"`

---

### 6.6 Dashboard & Navigation

**Priority:** P0 (Must Have)
**Phase:** Faza 1

#### Functional Requirements:

**FR-DASHBOARD-001: Dashboard centralny**
- Po zalogowaniu, użytkownik widzi dashboard z kafelkami:
  - **Moje Przepisy** (link do listy przepisów)
  - **Kalendarz Tygodnia** (link do kalendarza)
  - **Lista Zakupów** (link do list zakupów)
  - **Moje Konto** (link do ustawień)
- Każdy kafelek: duża ikona + tytuł + krótki opis

**FR-DASHBOARD-002: Empty state**
- Jeśli użytkownik nie ma żadnych przepisów:
  - Komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
  - Przycisk: "Dodaj pierwszy przepis" (link do formularza dodawania)

**FR-DASHBOARD-003: Nawigacja**
- Dashboard jest stroną główną (po zalogowaniu)
- Możliwość powrotu do dashboardu z każdego widoku (logo/link w nagłówku)

#### UI/UX Requirements:

**Desktop:**
- Grid 2x2 z kafelkami (każdy ~250px x 200px)
- Duże ikony (64px)
- Duże czcionki (20pt tytuły, 14pt opisy)
- Sporo white space

**Mobile:**
- Kafelki ułożone pionowo (lista)
- Każdy kafelek: ikona z lewej + tytuł i opis z prawej
- Pełna szerokość ekranu

**Kolory:**
- Główny kolor: niebieski (#3B82F6) lub zielony (#10B981)
- Tło: jasne (#F9FAFB)
- Tekst: ciemny (#1F2937)

#### Technical Requirements:
- Strona: `/dashboard` (protected route)
- Middleware sprawdza autentykację (redirect do /login jeśli niezalogowany)
- Astro layout z navigation bar

---

## 7. User Stories & Use Cases

### User Story 1: Dodawanie pierwszego przepisu
**Jako** nowy użytkownik
**Chcę** dodać swój pierwszy przepis do aplikacji
**Aby** móc zacząć planować posiłki

**Acceptance Criteria:**
- ✅ Użytkownik widzi przycisk "+ Dodaj przepis" na liście przepisów
- ✅ Po kliknięciu otwiera się formularz z polami: Nazwa, Przepis (textarea)
- ✅ Użytkownik wkleja pełny tekst przepisu
- ✅ Po kliknięciu "Rozpoznaj składniki", AI parsuje składniki w ciągu 3-5 sekund
- ✅ Użytkownik widzi listę rozpoznanych składników i może je edytować
- ✅ Po zapisaniu, przepis pojawia się na liście przepisów

**Flow:**
1. Klik "+ Dodaj przepis"
2. Wypełnienie pól: Nazwa, Przepis
3. Klik "Rozpoznaj składniki" → loader
4. Wyświetlenie tabeli składników (edytowalna)
5. Opcjonalna edycja składników
6. Klik "Zapisz przepis"
7. Redirect do listy przepisów → przepis jest widoczny

---

### User Story 2: Planowanie tygodnia
**Jako** użytkownik mający kilka przepisów
**Chcę** zaplanować posiłki na cały tydzień
**Aby** wiedzieć, co będę gotować każdego dnia

**Acceptance Criteria:**
- ✅ Użytkownik przechodzi do widoku "Kalendarz Tygodnia"
- ✅ Widzi pusty kalendarz 7 dni x 4 posiłki
- ✅ Klikając w przepis z listy, otwiera widok przypisywania
- ✅ Zaznacza checkboxami, do których dni/posiłków przypisać przepis
- ✅ Po zatwierdzeniu, przepis pojawia się w kalendarzu

**Flow:**
1. Wejście w "Kalendarz Tygodnia"
2. Wejście w "Moje Przepisy"
3. Klik na przepis → "Przypisz do kalendarza"
4. Modal z kalendarzem i checkboxami
5. Zaznaczenie np. "Poniedziałek - Śniadanie", "Wtorek - Śniadanie"
6. Klik "Przypisz"
7. Powrót do kalendarza → przepis widoczny w zaznaczonych komórkach
8. Powtórzenie dla kolejnych przepisów

---

### User Story 3: Generowanie listy zakupów
**Jako** użytkownik z zaplanowanym tygodniem
**Chcę** wygenerować listę zakupów na podstawie moich posiłków
**Aby** wiedzieć, co kupić w sklepie

**Acceptance Criteria:**
- ✅ Użytkownik widzi przycisk "Generuj listę zakupów" na widoku kalendarza
- ✅ Po kliknięciu, pojawiają się checkboxy przy posiłkach
- ✅ Użytkownik zaznacza, które posiłki uwzględnić
- ✅ Klik "Generuj listę" → lista zakupów jest tworzona w ciągu 2-3 sekund
- ✅ Użytkownik widzi listę składników zgrupowanych w kategorie
- ✅ Składniki z wielu przepisów są zsumowane

**Flow:**
1. Wejście w "Kalendarz Tygodnia"
2. Klik "Generuj listę zakupów"
3. Checkboxy pojawiają się przy każdym posiłku
4. Zaznaczenie wszystkich posiłków (lub tylko wybranych dni)
5. Klik "Generuj listę" → loader
6. Redirect do widoku "Lista Zakupów"
7. Lista składników podzielona na kategorie (Nabiał, Warzywa, etc.)
8. Każdy składnik ma checkbox (do odznaczania)

---

### User Story 4: Eksport listy do PDF
**Jako** użytkownik z wygenerowaną listą zakupów
**Chcę** wydrukować listę do zabrania do sklepu
**Aby** mieć fizyczną kopię podczas zakupów

**Acceptance Criteria:**
- ✅ Użytkownik widzi przycisk "Pobierz PDF" na widoku listy zakupów
- ✅ Po kliknięciu, plik PDF jest natychmiast pobierany
- ✅ Plik PDF zawiera czytelną listę z checkboxami
- ✅ Plik można otworzyć i wydrukować

**Flow:**
1. Wejście w "Lista Zakupów" (najnowsza lista)
2. Klik "Pobierz PDF"
3. Plik `lista-zakupow-2025-10-14.pdf` jest pobierany
4. Otwarcie pliku → widoczna lista z kategoriami i checkboxami
5. Wydrukowanie → zabranie do sklepu

---

### User Story 5: Odznaczanie produktów podczas zakupów
**Jako** użytkownik w sklepie z telefonem
**Chcę** odznaczać produkty, które już włożyłem do koszyka
**Aby** wiedzieć, co mi jeszcze zostało do kupienia

**Acceptance Criteria:**
- ✅ Użytkownik otwiera aplikację na telefonie
- ✅ Wchodzi w "Lista Zakupów" → widzi najnowszą listę
- ✅ Klikając checkbox przy produkcie, produkt jest przekreślany
- ✅ Stan checkboxa jest zapisywany (po odświeżeniu strony checkbox jest nadal zaznaczony)

**Flow:**
1. Otwarcie aplikacji na telefonie w sklepie
2. Wejście w "Lista Zakupów"
3. Przeglądanie listy w kolejności kategorii
4. Klik checkbox przy "Mleko - 1500ml" → produkt przekreślony
5. Kontynuacja zakupów
6. Powrót do aplikacji → checkbox nadal zaznaczony

---

## 8. UI/UX Requirements

### 8.1 Design Principles

**Prostota** - Minimalistyczny interfejs bez zbędnych elementów
**Czytelność** - Duże czcionki (min. 16px body text), wysoki kontrast
**Intuicyjność** - Jasne CTA (Call To Action), zrozumiałe ikony
**Dostępność** - Zgodność z WCAG 2.1 Level AA

### 8.2 Typography

- **Headings:** 24-32px, font-weight: 600-700
- **Body text:** 16-18px, font-weight: 400
- **Small text:** 14px (np. daty, opisy)
- **Font family:** System fonts (sans-serif) - Arial, Helvetica, Segoe UI

### 8.3 Colors

**Paleta główna:**
- Primary: #3B82F6 (niebieski)
- Secondary: #10B981 (zielony)
- Danger: #EF4444 (czerwony)
- Background: #F9FAFB (bardzo jasny szary)
- Text: #1F2937 (ciemny szary)
- Border: #E5E7EB (jasny szary)

**Stany:**
- Hover: Primary darker (np. #2563EB)
- Active/Selected: Primary with opacity
- Disabled: #9CA3AF (szary)

### 8.4 Buttons

**Primary button:**
- Background: Primary color
- Text: white
- Padding: 12px 24px
- Border-radius: 8px
- Font-size: 16px
- Min-height: 44px (touch-friendly)

**Secondary button:**
- Background: transparent
- Border: 1px solid Primary
- Text: Primary color

**Danger button:**
- Background: Danger color
- Text: white

### 8.5 Forms

**Input fields:**
- Height: 44px (min)
- Border: 1px solid #D1D5DB
- Border-radius: 6px
- Padding: 12px
- Focus state: border color → Primary

**Textarea:**
- Min-height: 120px
- Resize: vertical

**Validation:**
- Error message: red text under field
- Error state: red border
- Success state: green border (opcjonalnie)

### 8.6 Responsive Breakpoints

- **Mobile:** < 640px
- **Tablet:** 640px - 1024px
- **Desktop:** > 1024px

**Mobile-first approach:**
- Wszystkie komponenty projektowane najpierw dla mobile
- Progressive enhancement dla większych ekranów

### 8.7 Accessibility (A11y)

**Keyboard navigation:**
- Wszystkie interaktywne elementy dostępne przez Tab
- Focus state wyraźnie widoczny (outline)
- Skip to main content link

**Screen readers:**
- Semantic HTML (nav, main, section, article)
- ARIA labels dla ikon bez tekstu
- ARIA live regions dla dynamicznych aktualizacji (np. toast notifications)

**Color contrast:**
- Minimum 4.5:1 dla body text
- Minimum 3:1 dla large text (18px+)

---

## 9. Technical Architecture

### 9.1 Tech Stack

**Frontend:**
- **Astro 5** - SSR framework, hybrid rendering
- **React 19** - Interaktywne komponenty (islands architecture)
- **TypeScript 5** - Type safety
- **Tailwind CSS 4** - Utility-first CSS
- **Shadcn/ui** - UI component library (New York style)

**Backend:**
- **Supabase** - Backend-as-a-Service:
  - PostgreSQL database
  - Authentication (Supabase Auth)
  - Row Level Security (RLS)
  - Real-time subscriptions (opcjonalnie w przyszłości)
- **Astro API routes** - Server-side endpoints
- **Node.js Adapter** - Standalone server mode

**AI/ML:**
- **OpenAI GPT-4 API** lub **Anthropic Claude API** - Parsowanie składników z tekstu przepisów

**Export:**
- **jsPDF** lub **PDFKit** - Generowanie PDF
- Plain text formatting - Export TXT

**Deployment:**
- **Vercel** lub **Netlify** (zalecane dla Astro)
- **Supabase Cloud** (hosted database)

### 9.2 Database Schema

#### Users (zarządzane przez Supabase Auth)
```sql
-- Tabela auth.users jest wbudowana w Supabase
-- Tylko referencje user_id w pozostałych tabelach
```

#### Recipes
```sql
CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  full_text TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_recipes_user_id ON recipes(user_id);
```

#### Ingredients
```sql
CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity NUMERIC,
  unit TEXT,
  category TEXT NOT NULL,
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ingredients_recipe_id ON ingredients(recipe_id);
```

#### Calendar Template (szablon tygodnia)
```sql
CREATE TYPE meal_type AS ENUM ('breakfast', 'second_breakfast', 'lunch', 'dinner');

CREATE TABLE calendar_template (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7), -- 1=Poniedziałek, 7=Niedziela
  meal_type meal_type NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, day_of_week, meal_type)
);

CREATE INDEX idx_calendar_template_user_id ON calendar_template(user_id);
```

#### Calendar Instances (nadpisanie szablonu dla konkretnego tygodnia)
```sql
CREATE TABLE calendar_instances (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL, -- konkretna data (np. 2025-10-13)
  meal_type meal_type NOT NULL,
  recipe_id UUID REFERENCES recipes(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, date, meal_type)
);

CREATE INDEX idx_calendar_instances_user_id_date ON calendar_instances(user_id, date);
```

#### Shopping Lists
```sql
CREATE TABLE shopping_lists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  week_start_date DATE NOT NULL, -- data początku tygodnia (poniedziałek)
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shopping_lists_user_id ON shopping_lists(user_id);
```

#### Shopping List Items
```sql
CREATE TABLE shopping_list_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity NUMERIC,
  unit TEXT,
  category TEXT NOT NULL,
  is_checked BOOLEAN DEFAULT FALSE,
  is_manual BOOLEAN DEFAULT FALSE, -- czy dodane ręcznie (nie ze składników)
  "order" INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shopping_list_items_list_id ON shopping_list_items(list_id);
```

#### Shopping List Sources (mapowanie lista -> przepisy)
```sql
CREATE TABLE shopping_list_sources (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
  recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  date DATE NOT NULL, -- data posiłku
  meal_type meal_type NOT NULL
);

CREATE INDEX idx_shopping_list_sources_list_id ON shopping_list_sources(list_id);
```

#### User Settings (opcjonalnie)
```sql
CREATE TABLE user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  ai_parsing_count INTEGER DEFAULT 0, -- licznik wykorzystanych parsowań AI w danym miesiącu
  ai_parsing_reset_date DATE DEFAULT CURRENT_DATE, -- data resetu licznika
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### 9.3 Row Level Security (RLS) Policies

```sql
-- Recipes: użytkownik widzi tylko swoje przepisy
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own recipes"
  ON recipes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own recipes"
  ON recipes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own recipes"
  ON recipes FOR DELETE
  USING (auth.uid() = user_id);

-- Analogiczne polityki dla pozostałych tabel (ingredients, calendar_template, etc.)
```

### 9.4 API Routes

**Authentication:**
- `POST /api/auth/register` - Rejestracja (delegowane do Supabase Auth)
- `POST /api/auth/login` - Logowanie (delegowane do Supabase Auth)
- `POST /api/auth/logout` - Wylogowanie
- `POST /api/auth/reset-password` - Reset hasła

**Recipes:**
- `GET /api/recipes` - Lista przepisów użytkownika
- `POST /api/recipes` - Dodanie przepisu
- `GET /api/recipes/[id]` - Szczegóły przepisu
- `PUT /api/recipes/[id]` - Edycja przepisu
- `DELETE /api/recipes/[id]` - Usunięcie przepisu
- `POST /api/recipes/parse` - Parsowanie składników przez AI

**Calendar:**
- `GET /api/calendar/template` - Szablon tygodnia
- `PUT /api/calendar/template` - Aktualizacja szablonu
- `GET /api/calendar/week?date=YYYY-MM-DD` - Widok konkretnego tygodnia (szablon + instancje)
- `PUT /api/calendar/week` - Aktualizacja instancji tygodnia
- `POST /api/calendar/assign` - Przypisanie przepisu do posiłków

**Shopping Lists:**
- `POST /api/shopping-lists` - Generowanie listy zakupów
- `GET /api/shopping-lists` - Historia list zakupów
- `GET /api/shopping-lists/[id]` - Szczegóły listy
- `PUT /api/shopping-lists/[id]` - Edycja listy
- `PATCH /api/shopping-lists/[id]/items/[itemId]` - Toggle checkbox (kupiony/niekupiony)
- `GET /api/shopping-lists/[id]/export/pdf` - Eksport do PDF
- `GET /api/shopping-lists/[id]/export/txt` - Eksport do TXT

**User:**
- `GET /api/user/settings` - Ustawienia użytkownika
- `DELETE /api/user/account` - Usunięcie konta

### 9.5 Folder Structure

```
./src
├── layouts/
│   ├── Layout.astro           # Główny layout
│   └── AuthLayout.astro       # Layout dla stron auth (login, register)
├── pages/
│   ├── index.astro            # Landing page (niezalogowani)
│   ├── login.astro            # Strona logowania
│   ├── register.astro         # Strona rejestracji
│   ├── dashboard.astro        # Dashboard (po zalogowaniu)
│   ├── recipes/
│   │   ├── index.astro        # Lista przepisów
│   │   ├── [id].astro         # Szczegóły przepisu
│   │   └── new.astro          # Formularz dodawania przepisu
│   ├── calendar/
│   │   └── index.astro        # Kalendarz tygodniowy
│   ├── shopping-lists/
│   │   ├── index.astro        # Historia list zakupów
│   │   └── [id].astro         # Szczegóły listy zakupów
│   ├── settings/
│   │   └── index.astro        # Ustawienia użytkownika
│   └── api/
│       ├── auth/
│       │   ├── register.ts
│       │   ├── login.ts
│       │   ├── logout.ts
│       │   └── reset-password.ts
│       ├── recipes/
│       │   ├── index.ts       # GET (lista), POST (dodaj)
│       │   ├── [id].ts        # GET (szczegóły), PUT (edycja), DELETE
│       │   └── parse.ts       # POST (parsowanie AI)
│       ├── calendar/
│       │   ├── template.ts    # GET, PUT
│       │   ├── week.ts        # GET, PUT
│       │   └── assign.ts      # POST
│       ├── shopping-lists/
│       │   ├── index.ts       # GET (historia), POST (generowanie)
│       │   ├── [id].ts        # GET (szczegóły), PUT (edycja)
│       │   ├── [id]/
│       │   │   ├── items/[itemId].ts  # PATCH (toggle checkbox)
│       │   │   └── export/
│       │   │       ├── pdf.ts  # GET
│       │   │       └── txt.ts  # GET
│       └── user/
│           ├── settings.ts    # GET
│           └── account.ts     # DELETE
├── middleware/
│   └── supabase.ts            # Middleware: inject Supabase client do context.locals
├── db/
│   ├── supabase.client.ts     # Supabase client setup
│   └── database.types.ts      # Generated database types
├── types.ts                    # Shared types (Entities, DTOs)
├── components/
│   ├── ui/                     # Shadcn/ui components
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   ├── Checkbox.tsx
│   │   ├── Modal.tsx
│   │   └── ...
│   ├── recipes/
│   │   ├── RecipeCard.astro
│   │   ├── RecipeForm.tsx      # React (interactive)
│   │   └── IngredientsList.tsx
│   ├── calendar/
│   │   ├── CalendarGrid.tsx    # React (interactive)
│   │   └── MealSlot.tsx
│   ├── shopping-lists/
│   │   ├── ShoppingListView.tsx
│   │   └── ShoppingListItem.tsx
│   └── hooks/                  # Custom React hooks
│       ├── useRecipes.ts
│       ├── useCalendar.ts
│       └── useShoppingList.ts
├── lib/
│   ├── utils.ts                # cn() utility, helpers
│   ├── services/
│   │   ├── recipeService.ts    # Business logic dla przepisów
│   │   ├── calendarService.ts
│   │   ├── shoppingListService.ts
│   │   ├── aiService.ts        # Integracja z AI API
│   │   └── exportService.ts    # Generowanie PDF/TXT
│   └── validators/
│       ├── recipeSchemas.ts    # Zod schemas
│       ├── calendarSchemas.ts
│       └── shoppingListSchemas.ts
├── styles/
│   └── global.css              # Tailwind imports + custom styles
├── assets/
│   └── icons/                  # SVG icons
└── env.d.ts
```

### 9.6 Environment Variables

```env
# Supabase
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key  # Tylko backend

# AI API
OPENAI_API_KEY=sk-xxxxx
# lub
ANTHROPIC_API_KEY=sk-ant-xxxxx

# App
PUBLIC_APP_URL=https://grocerylist.app  # Dla emaili, redirects
```

---

## 10. Development Phases

### **Faza 1: Foundation & Recipe Management (2-3 tygodnie)**

**Scope:**
- ✅ Setup projektu (Astro + React + TypeScript + Tailwind + Supabase)
- ✅ Konfiguracja Supabase (database, auth)
- ✅ User authentication (rejestracja, logowanie, reset hasła, usunięcie konta)
- ✅ Dashboard centralny z kafelkami
- ✅ CRUD przepisów (dodawanie, edycja, usuwanie, przeglądanie)
- ✅ Integracja AI dla parsowania składników
- ✅ Limit parsowania AI (20/miesiąc)
- ✅ Obsługa błędów parsowania

**Deliverables:**
- Działająca aplikacja z logowaniem
- Użytkownik może dodać przepis (z AI parsing)
- Użytkownik może przeglądać, edytować, usuwać przepisy
- Dashboard z pustym stanem (empty state)

**Testing:**
- Manualne testy: rejestracja, logowanie, dodawanie przepisu, parsowanie AI
- Walidacja: czy AI poprawnie rozpoznaje składniki (próbki 10 różnych przepisów)

---

### **Faza 2: Calendar & Meal Planning (2-3 tygodnie)**

**Scope:**
- ✅ Kalendarz tygodniowy (widok desktop i mobile)
- ✅ System szablonów tygodnia
- ✅ Przypisywanie przepisów do posiłków (flow z checkboxami)
- ✅ Modal: "Zmienić tylko ten tydzień czy szablon?"
- ✅ Wyświetlanie przypisanych przepisów w kalendarzu
- ✅ Usuwanie przepisów z kalendarza

**Deliverables:**
- Działający kalendarz tygodniowy
- Użytkownik może zaplanować posiłki na cały tydzień
- System szablonów + instancji działa poprawnie

**Testing:**
- Testy: przypisanie przepisu do wielu dni/posiłków
- Testy: edycja szablonu vs instancji
- Testy: responsywność (mobile vs desktop)

---

### **Faza 3: Shopping List Generation (1-2 tygodnie)**

**Scope:**
- ✅ Generowanie listy zakupów z zaznaczonych posiłków (checkboxy)
- ✅ Agregacja składników (sumowanie ilości)
- ✅ Grupowanie w kategorie
- ✅ Zapis listy w bazie danych
- ✅ Edycja listy (dodawanie wolnych pozycji, usuwanie, zmiana ilości)
- ✅ Odznaczanie produktów jako "kupione" (checkboxy)
- ✅ Historia list zakupów

**Deliverables:**
- Użytkownik może wygenerować listę zakupów z kalendarza
- Lista jest prawidłowo agregowana i zgrupowana
- Użytkownik może edytować listę i odznaczać produkty

**Testing:**
- Testy agregacji: czy składniki są poprawnie sumowane?
- Testy kategorii: czy AI przypisało poprawne kategorie?
- Testy checkboxów: czy stan jest zapisywany po odświeżeniu?

---

### **Faza 4: Export & Polish (1 tydzień)**

**Scope:**
- ✅ Eksport listy zakupów do PDF
- ✅ Eksport listy zakupów do TXT
- ✅ Formatowanie eksportów (nagłówki, kategorie, checkboxy)
- ✅ UI polish: ikony, kolory, spacing
- ✅ Accessibility improvements (keyboard navigation, ARIA)
- ✅ Performance optimization (lazy loading, code splitting)
- ✅ Bug fixes

**Deliverables:**
- Użytkownik może pobrać listę zakupów w formatach PDF i TXT
- Aplikacja jest dopracowana wizualnie
- Aplikacja spełnia standardy dostępności (WCAG 2.1 Level AA)

**Testing:**
- Testy eksportu: czy PDF/TXT są poprawnie formatowane?
- Testy accessibility: keyboard navigation, screen reader
- Performance: Lighthouse score (min. 90+ na mobile i desktop)

---

### **Timeline Summary:**

| Faza | Czas | Deliverables |
|------|------|--------------|
| Faza 1 | 2-3 tygodnie | Auth, CRUD przepisów, AI parsing |
| Faza 2 | 2-3 tygodnie | Kalendarz, planowanie posiłków |
| Faza 3 | 1-2 tygodnie | Generowanie listy zakupów, edycja, checkboxy |
| Faza 4 | 1 tydzień | Eksport PDF/TXT, polish |
| **TOTAL** | **6-9 tygodni** | **Pełne MVP** |

---

## 11. Constraints & Out of Scope

### 11.1 In Scope (MVP)

✅ CRUD przepisów (text-based)
✅ AI parsowanie składników
✅ Kalendarz tygodniowy (7 dni x 4 posiłki)
✅ System szablonów tygodnia (powtarzające się posiłki)
✅ Przypisywanie przepisów do posiłków
✅ Generowanie listy zakupów z agregacją składników
✅ Grupowanie składników w kategorie
✅ Edycja listy zakupów (dodawanie wolnych pozycji)
✅ Odznaczanie produktów jako "kupione"
✅ Eksport do PDF/TXT
✅ Responsywny UI (mobile + desktop)
✅ Prosty system kont użytkowników (email + hasło)

### 11.2 Out of Scope (post-MVP)

❌ **Import przepisów z plików** (JPG, PDF, DOCX)
❌ **Aplikacje mobilne** (native iOS/Android)
❌ **Udostępnianie przepisów** między użytkownikami
❌ **Integracja z zewnętrznymi serwisami zakupowymi** (np. Glovo, Frisco)
❌ **Obsługa wielu języków** (na początek tylko polski)
❌ **Kalendarz miesięczny** (tylko tygodniowy)
❌ **Powiadomienia** (email, SMS, push)
❌ **Zaawansowane wyszukiwanie/filtrowanie** przepisów
❌ **Integracja z asystentami głosowymi** (Alexa, Google Assistant)
❌ **Obsługa diet i alergii** (wegetariańska, bezglutenowa, etc.)
❌ **Integracja z kalendarzem** (Google Calendar, iCal)
❌ **Zaawansowane zarządzanie użytkownikami** (role, uprawnienia)
❌ **Zaawansowane bezpieczeństwo** (2FA, szyfrowanie end-to-end)
❌ **Wiele przepisów na jeden posiłek** (tylko 1 przepis = 1 posiłek)
❌ **OAuth providers** (Google, Facebook login)
❌ **Automatyczna konwersja jednostek miary** (ml → szklanki, etc.)
❌ **Zdjęcia przepisów** (tylko tekst)

### 11.3 Technical Constraints

**AI Parsowanie:**
- Limit: 20 przepisów/miesiąc na użytkownika (kontrola kosztów)
- Bez inteligentnej konwersji jednostek (1 szklanka ≠ 250ml automatycznie)
- Sukces parsowania: cel 80%+ (nie 100%)

**Kalendarz:**
- Tylko widok tygodniowy (brak widoku miesięcznego, rocznego)
- Brak historii wcześniejszych tygodni (nie można przeglądać przeszłości)

**Lista zakupów:**
- Agregacja składników tylko po nazwie (lowercase matching)
- Brak automatycznego grupowania synonimów (np. "pomidor" ≠ "pomidory")

**Performance:**
- Brak paginacji w liście przepisów (MVP zakłada max ~50 przepisów na użytkownika)
- Brak cache'owania AI responses (każde parsowanie = nowe wywołanie API)

**Bezpieczeństwo:**
- Podstawowe uwierzytelnienie (email + hasło), brak 2FA
- Brak szyfrowania danych w spoczynku (tylko transport HTTPS)

---

## 12. Privacy & Compliance

### 12.1 RODO Compliance

**Podstawowe wymagania:**
- ✅ Przejrzysta polityka prywatności (link w footer)
- ✅ Zgoda użytkownika na przetwarzanie danych (checkbox przy rejestracji)
- ✅ Możliwość usunięcia konta (hard delete z bazy danych)
- ✅ Dane przechowywane w EU (Supabase EU region)

**Przechowywane dane osobowe:**
- Email (wymagany do logowania)
- Hasło (zahashowane przez Supabase Auth - bcrypt)
- Przepisy i listy zakupów (zawartość należąca do użytkownika)

**Prawa użytkownika:**
- Prawo do usunięcia danych (przycisk w ustawieniach)
- Prawo do dostępu (użytkownik widzi swoje dane w aplikacji)

**Bezpieczeństwo danych:**
- Supabase Row Level Security (RLS) - użytkownik widzi tylko swoje dane
- HTTPS transport (TLS 1.3)
- Hasła zahashowane (bcrypt przez Supabase Auth)
- Tokeny JWT z expiration (Supabase default: 1 godzina)

### 12.2 Polityka Prywatności (podstawowe punkty)

**Jakie dane zbieramy:**
- Adres email (do logowania i komunikacji)
- Przepisy kulinarne (tekst wprowadzony przez użytkownika)
- Listy zakupów (wygenerowane przez system)

**Jak wykorzystujemy dane:**
- Świadczenie usług aplikacji
- Komunikacja z użytkownikiem (np. reset hasła)
- Parsowanie przepisów przez AI (OpenAI/Anthropic) - dane są wysyłane do zewnętrznego API

**Udostępnianie danych:**
- Supabase (hosting bazy danych, EU region)
- OpenAI lub Anthropic (parsowanie składników) - dane przepisów mogą być przesyłane do USA
- Brak sprzedaży danych third-party

**Przechowywanie danych:**
- Dane są przechowywane do momentu usunięcia konta przez użytkownika
- Automatyczne usuwanie danych po usunięciu konta (ON DELETE CASCADE)

**Cookies:**
- Sesja użytkownika (JWT token w cookie)
- Brak cookies śledzących/analytics w MVP (opcjonalnie później)

### 12.3 Terms of Service (podstawowe punkty)

**Korzystanie z usługi:**
- Aplikacja jest darmowa w wersji MVP
- Użytkownik zobowiązuje się nie nadużywać limitu AI parsowania
- Zakaz udostępniania konta innym osobom

**Odpowiedzialność:**
- Aplikacja dostarcza narzędzia do planowania posiłków, ale nie gwarantuje poprawności list zakupów
- Użytkownik jest odpowiedzialny za weryfikację składników (np. alergie)

**Modyfikacje:**
- Możemy wprowadzać zmiany w aplikacji (będziemy informować przez email)

---

## 13. Risks & Mitigation

### Risk 1: AI parsowanie składników nie działa poprawnie (sukces < 80%)

**Likelihood:** Medium
**Impact:** High

**Mitigation:**
- Iteracyjne testowanie promptu AI na różnych przepisach
- Feedback loop: użytkownik może poprawić składniki po parsowaniu
- Fallback: ręczne dodawanie składników (jeśli AI zawiedzie)
- Testowanie na 50+ różnych przepisach przed wdrożeniem

---

### Risk 2: Koszt AI API przekroczy budżet

**Likelihood:** Medium
**Impact:** Medium

**Mitigation:**
- Limit 20 parsowań/użytkownik/miesiąc (rate limiting)
- Monitoring kosztów AI API (dashboard w OpenAI/Anthropic)
- Możliwość przełączenia na tańszy model (np. GPT-3.5 zamiast GPT-4)
- Opcjonalnie: cache'owanie podobnych przepisów (post-MVP)

---

### Risk 3: Użytkownicy 50+ mają trudności z obsługą aplikacji

**Likelihood:** Medium
**Impact:** High

**Mitigation:**
- Prosty, intuicyjny UI (duże przyciski, czytelne czcionki)
- Onboarding flow dla nowych użytkowników (opcjonalnie)
- User testing z reprezentatywną grupą (min. 5 użytkowników 50+)
- Tooltips i helpful hints w kluczowych miejscach
- Help/FAQ section w aplikacji

---

### Risk 4: Niska adopcja użytkowników (brak traction)

**Likelihood:** Medium
**Impact:** High

**Mitigation:**
- Walidacja MVP z grupą beta testerów (min. 20 osób)
- Zbieranie feedbacku przez ankiety (NPS, user interviews)
- Iteracyjne usprawnienia na podstawie feedbacku
- Marketing: lokalne grupy na Facebooku (grupy kulinarne, dla seniorów)
- Opcjonalnie: referral program (polecanie znajomym)

---

### Risk 5: Problemy z performance (wolne ładowanie, timeout)

**Likelihood:** Low
**Impact:** Medium

**Mitigation:**
- Optymalizacja Astro (SSR + static generation gdzie możliwe)
- Code splitting (React components lazy loaded)
- Image optimization (Astro Image)
- Monitoring performance (Lighthouse, Web Vitals)
- Caching strategies (Supabase caching, CDN)

---

### Risk 6: Naruszenie RODO (problemy prawne)

**Likelihood:** Low
**Impact:** High

**Mitigation:**
- Konsultacja z prawnikiem (polityka prywatności, ToS)
- Supabase w EU region (dane nie opuszczają EU, poza AI API)
- Jasne zgody użytkownika (checkboxy, informacje)
- Hard delete danych po usunięciu konta
- Regularne audyty bezpieczeństwa (Supabase RLS policies)

---

## 14. Open Questions & Future Considerations

### Open Questions (do rozstrzygnięcia przed implementacją):

1. **Które AI API wybrać: OpenAI (GPT-4) vs Anthropic (Claude)?**
   - Kryteria: koszt, dokładność parsowania, dostępność w Polsce
   - Rekomendacja: testowanie obu i porównanie wyników

2. **Czy automatycznie resetować szablon tygodnia co miesiąc?**
   - Obecnie: szablon działa "na zawsze"
   - Możliwość: archiwizacja starych szablonów, resetowanie co X miesięcy

3. **Czy limit AI parsowania (20/miesiąc) to dobra wartość?**
   - Do zwalidowania na podstawie user testing
   - Możliwość dynamicznego dostosowania (np. 10 dla nowych, 30 dla power users)

### Future Considerations (post-MVP):

**v1.1 - Enhanced UX:**
- Wyszukiwanie i filtrowanie przepisów (nazwa, składniki)
- Sortowanie przepisów (alfabetycznie, data dodania, popularność)
- Zdjęcia przepisów (upload lub automatyczne z URL)
- Dark mode

**v1.2 - Social Features:**
- Udostępnianie przepisów między użytkownikami
- Publiczne przepisy (biblioteka społeczności)
- Komentarze i oceny przepisów

**v1.3 - Advanced Planning:**
- Kalendarz miesięczny
- Historia poprzednich tygodni
- Powtarzające się posiłki (auto-fill szablonu)
- Wiele przepisów na jeden posiłek

**v1.4 - Integrations:**
- Import przepisów z plików (JPG OCR, PDF parsing)
- Integracja z zewnętrznymi serwisami zakupowymi (API)
- OAuth providers (Google, Facebook login)
- Powiadomienia (email, push)

**v1.5 - Intelligence:**
- Inteligentna konwersja jednostek miary
- Sugestie przepisów na podstawie historii
- Automatyczne wykrywanie brakujących składników
- Obsługa diet i alergii (filtrowanie przepisów)

**v2.0 - Mobile Apps:**
- Native iOS app
- Native Android app
- Synchronizacja między urządzeniami

---

## 15. Appendix

### A. Predefiniowana lista kategorii produktów

1. **Nabiał** - mleko, masło, ser, jogurt, śmietana, twaróg, kefir
2. **Warzywa** - pomidor, ogórek, papryka, cebula, czosnek, marchew, ziemniak, kapusta, brokuły, kalafior, sałata, szpinak, bakłażan, cukinia, etc.
3. **Owoce** - jabłko, banan, pomarańcza, cytryna, gruszka, truskawka, malina, arbuz, winogrona, etc.
4. **Mięso** - kurczak, wołowina, wieprzowina, indyk, ryba, owoce morza, kiełbasa, boczek, szynka, etc.
5. **Pieczywo** - chleb, bułka, bagietka, pita, tortilla, etc.
6. **Przyprawy** - sól, pieprz, papryka, oregano, bazylia, tymianek, curry, kurkuma, cynamon, etc.
7. **Inne** - mąka, ryż, makaron, olej, ocet, cukier, kasza, płatki, etc.

### B. Przykładowe przepisy do testowania AI parsowania

**Przepis 1: omlet**
```
Włoska śnadanowa uczta

Składniki:
. 2 jajka (rozmiar M)
• 30 g mqki orkiszowej
. 50 ml wody
• 4 g oliwy z oliwek (0,5 łyżki)
• 63 g burraty (0,5 kulki)
• 20 g pesto z suszonych pomidorów (1 tyżka)
‣ 10 g zielonego pesto (1 tyżeczka)
• kilka listków świeżej bazylii
• szczypta soli, szczypta pieprzu

Przygotowanie:
.Jajka roztrzep trzepaczkq z solq,
pieprzem i wodq. Dodaj mqkę
i roztrzep na gładkq masę.
2.Masę wlej na patelnie
z rozgrzanq oliwq. Po
przewróceniu na drugq stronq
połowę obłóż poszarpaną na
<awałki burratą. Ściqgnij
z patelni, posmaruj zielonym
pesto i złóż na pót. Wierzch
posmaruj czerwonym pesto
i udekoruj listkami bazyli,

```

**Przepis 2: tortillia**
```
Serowe kieszonki z sałatą grecką

Składniki:
. 1 placek petnoziarnistej tortilli
• 120 g tartej mozzarelli
• 40 g czerwonej papryki
• 400 g pomidorów
• 130 g ogórków
• 25 g czarnych oliwek konserwowych
. 2 g oliwy z oliwek tyżeczka)c
• 20 g sera typu feta
• szczypta soli, szczypta pieprzu


Przygotowanie:
Ugotuj makaron al dente. Podsmaż boczek z czosnkiem.
Wymieszaj jajka z parmezanem. Połącz wszystko i wymieszaj.
```

### C. Glosariusz

- **MVP** - Minimum Viable Product (minimalny produkt funkcjonalny)
- **CRUD** - Create, Read, Update, Delete (podstawowe operacje na danych)
- **AI Parsing** - Automatyczne rozpoznawanie składników z tekstu przepisu przez sztuczną inteligencję
- **RLS** - Row Level Security (zabezpieczenie na poziomie wierszy w bazie danych)
- **SSR** - Server-Side Rendering (renderowanie po stronie serwera)
- **WAU** - Weekly Active Users (liczba aktywnych użytkowników tygodniowo)
- **NPS** - Net Promoter Score (wskaźnik satysfakcji użytkowników)
- **RODO** - Rozporządzenie o Ochronie Danych Osobowych (GDPR)

---

**Koniec dokumentu PRD v1.0**

*Ostatnia aktualizacja: 2025-10-13*
