# Dokument wymagań produktu (PRD) - GroceryList MVP

Wersja: 2.0
Data: 2025-10-15
Autor: Product Team
Status: Final

## 1. Przegląd produktu

### 1.1 Wizja produktu

GroceryList to aplikacja webowa umożliwiająca użytkownikom tworzenie list zakupów na podstawie przepisów kulinarnych przypisanych do kalendarza tygodniowego z podziałem na cztery typy posiłków dziennie (śniadanie, drugie śniadanie, obiad, kolacja). Aplikacja rozwiązuje problem czasochłonnego ręcznego tworzenia list zakupów i zapominania składników podczas zakupów.

### 1.2 Cele biznesowe

- Zwalidowanie MVP w ciągu 3 miesięcy od wdrożenia
-Zmniejszenie czasu potrzebnego na stworzenie listy zakupów o 80% (z 30-60 min do 5-10 min)
- Redukcja zapomnianych składników o 90%

### 1.3 Grupa docelowa

Persona główna: "Anna & Marek - Zaplanowana Para"

Demograficzne:
- Wiek: 50-60 lat
- Status: Para małżeńska
- Miejsce zamieszkania: Miasto średniej wielkości

Nawyki zakupowe:
- Robią zakupy raz w tygodniu (sobota lub niedziela)
- Preferują dyskonty (Biedronka, Lidl, Kaufland)
- Planują wydatki z wyprzedzeniem

Nawyki kulinarne:
- Gotują codziennie (lunch i obiad)
- Średniozaawansowani - znają podstawowe przepisy, eksperymentują umiarkowanie
- Planują posiłki z tygodniowym wyprzedzeniem
- Mają około 20-30 ulubionych przepisów, które rotują

Potrzeby technologiczne:
- Używają smartfonów (Android/iOS) na poziomie podstawowym/średnim
- Preferują proste, intuicyjne interfejsy z dużymi przyciskami
- Cenią czytelność i brak skomplikowanych funkcji

### 1.4 Stos technologiczny

Frontend:
- Astro 5 - SSR framework, hybrid rendering
- React 19 - Interaktywne komponenty (islands architecture)
- TypeScript 5 - Type safety
- Tailwind CSS 4 - Utility-first CSS
- Shadcn/ui - UI component library (New York style)

Backend:
- Supabase - Backend-as-a-Service (PostgreSQL database, Authentication, RLS)
- Astro API routes - Server-side endpoints
- Node.js Adapter - Standalone server mode

AI/ML:
- OpenAI GPT-4 API lub Anthropic Claude API - Parsowanie składników z tekstu przepisów

Export:
- jsPDF lub PDFKit - Generowanie PDF
- Plain text formatting - Export TXT

Deployment:
- Vercel lub Netlify - Hosting
- Supabase Cloud - Hosted database (EU region)

## 2. Problem użytkownika

### 2.1 Główne problemy

Problem 1: Zapominanie składników podczas zakupów
- Użytkownicy nie mają jednolitej listy zakupów uwzględniającej wszystkie zaplanowane posiłki
- Skutkuje to wielokrotnymi wizytami w sklepie i frustracją
- Impact: Dodatkowe koszty, niepotrzebne wizyty w sklepie, zakup duplikatów

Problem 2: Tracenie czasu na tworzenie listy zakupów z przepisów
- Ręczne przepisywanie składników z wielu przepisów jest czasochłonne (30-60 minut tygodniowo)
- Trudność w agregowaniu powtarzających się składników z różnych przepisów
- Brak centralnego miejsca do zarządzania przepisami i planowania posiłków
- Impact: Straty czasowe, frustracja, stres związany z planowaniem

Problem 3: Rozproszone przepisy
- Przepisy rozrzucone w notesach, książkach, internecie
- Trudność w szybkim znalezieniu sprawdzonego przepisu
- Brak możliwości łatwego dostępu do ulubionych przepisów w sklepie

### 2.2 Rozwiązanie

GroceryList centralizuje zarządzanie przepisami, umożliwia planowanie posiłków w kalendarzu tygodniowym oraz automatycznie generuje listy zakupów z agregacją składników. Aplikacja redukuje czas potrzebny na stworzenie listy zakupów z 30-60 minut do 5-10 minut i eliminuje problem zapominanych składników poprzez automatyczne sumowanie składników z wielu przepisów.

## 3. Wymagania funkcjonalne

### 3.1 Uwierzytelnianie i zarządzanie kontem użytkownika

FR-AUTH-001: Rejestracja użytkownika
- Użytkownik może zarejestrować konto używając adresu email i hasła
- Wymagane pola: email, hasło (min. 8 znaków)
- Walidacja formatu email
- Weryfikacja email (potwierdzenie przez link w emailu) - wykorzystując Supabase Auth
- Hasło musi spełniać wymagania: min. 8 znaków, mix liter i cyfr

FR-AUTH-002: Logowanie
- Użytkownik może zalogować się używając email + hasło
- Sesja użytkownika jest zachowywana (remember me)
- Możliwość wylogowania

FR-AUTH-003: Resetowanie hasła
- Opcja "Zapomniałeś hasła?" na stronie logowania
- Link resetujący wysyłany na email (Supabase Auth)
- Użytkownik może ustawić nowe hasło przez link

FR-AUTH-004: Usunięcie konta
- Użytkownik może usunąć swoje konto z poziomu ustawień
- Potwierdzenie operacji (modal: "Czy na pewno?")
- Wszystkie dane użytkownika (przepisy, listy) są usuwane z bazy danych (hard delete)
- Zgodność z RODO

### 3.2 Zarządzanie przepisami (CRUD)

FR-RECIPE-001: Dodawanie przepisu
- Użytkownik może dodać nowy przepis przez prosty formularz
- Pole tekstowe (textarea) na wklejenie pełnego przepisu jako plain text
- Po wklejeniu przepisu, AI automatycznie parsuje składniki z tekstu
- AI rozpoznaje: nazwę składnika + ilość + jednostkę + kategorię produktu
- Po parsowaniu, użytkownik widzi listę rozpoznanych składników i może je edytować przed zapisem
- Możliwość ręcznej edycji/dodania/usunięcia składników

FR-RECIPE-002: Obsługa błędów parsowania AI
- Jeśli AI nie rozpozna składników poprawnie lub wystąpi błąd:
  - Przepis zostaje zapisany z pełnym tekstem
  - Lista składników pozostaje pusta
  - Komunikat: "Nie udało się automatycznie rozpoznać składników. Dodaj je ręcznie."
- Użytkownik może ręcznie dodać składniki w trybie edycji przepisu

FR-RECIPE-003: Limit parsowania AI
- Maksymalnie 20 przepisów z AI-parsing miesięcznie na użytkownika
- Po przekroczeniu limitu: komunikat informujący o limicie + możliwość ręcznego dodania składników
- Licznik wykorzystania widoczny w ustawieniach profilu
- Reset licznika na początku każdego miesiąca

FR-RECIPE-004: Przeglądanie przepisów
- Lista wszystkich przepisów użytkownika
- Każda karta przepisu wyświetla tylko nazwę przepisu (minimalistyczny widok)
- Prosty scroll przez listę (brak wyszukiwania/filtrowania w MVP)
- Sortowanie domyślnie: od najnowszych

FR-RECIPE-005: Wyświetlanie szczegółów przepisu
- Kliknięcie w przepis otwiera widok szczegółowy
- Wyświetlane informacje:
  - Nazwa przepisu
  - Pełny tekst przepisu
  - Lista składników (nazwa, ilość, jednostka, kategoria)
- Przyciski akcji: "Edytuj", "Usuń"

FR-RECIPE-006: Edycja przepisu
- Użytkownik może edytować istniejący przepis
- Możliwość zmiany tekstu przepisu
- Możliwość edycji listy składników (dodanie, usunięcie, zmiana ilości/jednostki/kategorii)
- Brak ponownego parsowania AI przy edycji (oszczędność limitu)

FR-RECIPE-007: Usuwanie przepisu
- Użytkownik może usunąć przepis
- Potwierdzenie operacji (modal: "Czy na pewno usunąć przepis [nazwa]?")
- Po usunięciu, przepis znika z listy i kalendarza (jeśli był przypisany - ON DELETE SET NULL)

### 3.3 Kalendarz tygodniowy i planowanie posiłków

FR-CALENDAR-001: Wyświetlanie kalendarza tygodniowego
- Kalendarz pokazuje 7 dni tygodnia (Poniedziałek - Niedziela)
- Każdy dzień ma 4 typy posiłków: Śniadanie, Drugie śniadanie, Obiad, Kolacja
- Kalendarz pokazuje bieżący tydzień (od poniedziałku do niedzieli)
- Na desktop: widok tabelaryczny (7 kolumn x 4 wiersze)
- Na mobile: widok listy z akordeonami (dzień po dniu)

FR-CALENDAR-002: System szablonów tygodnia
- Użytkownik pracuje na "szablonie tygodnia", który automatycznie się powtarza co tydzień
- Szablon to wzorzec posiłków: "każdy poniedziałek na śniadanie - jajecznica"
- Użytkownik może modyfikować konkretny tydzień (instancję)
- Przy każdej zmianie przepisu w kalendarzu, pojawia się pytanie:
  - Modal: "Zmienić tylko ten tydzień czy szablon na stałe?"
  - Opcje: [Tylko ten tydzień] [Szablon (zawsze)]

FR-CALENDAR-003: Przypisywanie przepisu do posiłku
- Przepływ: Użytkownik najpierw wybiera przepis z listy przepisów
- Po wybraniu przepisu, otwiera się widok kalendarza z checkboxami przy każdym dniu/posiłku
- Użytkownik zaznacza checkboxami, gdzie chce przypisać przepis
- Przycisk "Przypisz" zatwierdza operację
- Jeden posiłek = maksymalnie jeden przepis (MVP uproszczone)

FR-CALENDAR-004: Wyświetlanie przypisanych przepisów
- Każda komórka kalendarza (dzień + posiłek) pokazuje nazwę przypisanego przepisu
- Jeśli brak przepisu: pusta komórka z ikoną "+"
- Kliknięcie w przepis otwiera szczegóły przepisu

FR-CALENDAR-005: Usuwanie przepisu z kalendarza
- Użytkownik może usunąć przepis z konkretnego dnia/posiłku (ikona "x")
- Pytanie: "Usunąć tylko z tego tygodnia czy z szablonu?"
- Opcje: [Tylko ten tydzień] [Z szablonu]

FR-CALENDAR-006: Puste stany (empty states)
- Jeśli kalendarz jest pusty (brak przepisów):
  - Komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
  - Przycisk: "Dodaj pierwszy przepis"

### 3.4 Generowanie listy zakupów

FR-SHOPLIST-001: Generowanie listy zakupów z kalendarza
- Na widoku kalendarza: przycisk "Generuj listę zakupów"
- Po kliknięciu: kalendarz przechodzi w "tryb selekcji"
- Pojawiają się checkboxy przy każdym przypisanym posiłku
- Użytkownik zaznacza, które posiłki chce uwzględnić w liście zakupów
- Przycisk "Generuj listę" tworzy nową listę zakupów

FR-SHOPLIST-002: Agregacja składników
- System automatycznie sumuje składniki z zaznaczonych posiłków/przepisów
- Jeśli ten sam składnik występuje w wielu przepisach:
  - Składniki są zsumowane według nazwy (np. "mleko" + "mleko" = jedna pozycja)
  - Ilości są dodawane (500ml + 200ml = 700ml)
  - Jednostka jest zachowana (jeśli zgodna)
- Jeśli jednostki są różne (np. "1 szklanka mleka" + "200ml mleka"):
  - Brak inteligentnej konwersji w MVP
  - Składniki pozostają osobno

FR-SHOPLIST-003: Grupowanie w kategorie
- Lista zakupów jest podzielona na kategorie produktów:
  - Nabiał
  - Warzywa
  - Owoce
  - Mięso
  - Pieczywo
  - Przyprawy
  - Inne
- Predefiniowana lista kategorii
- Jeśli AI przypisało błędną kategorię, użytkownik może ją ręcznie zmienić

FR-SHOPLIST-004: Przeglądanie listy zakupów
- Lista wszystkich wygenerowanych list zakupów (historia)
- Każda lista: data utworzenia + liczba produktów
- Domyślnie wyświetlana najnowsza lista

FR-SHOPLIST-005: Edycja listy zakupów
- Użytkownik może ręcznie edytować wygenerowaną listę:
  - Dodawanie produktu (dowolny, nie tylko ze składników)
  - Usuwanie produktu
  - Zmiana ilości
  - Zmiana kategorii
- Ręcznie dodane produkty oznaczone jako "wolne pozycje" (nie związane z przepisem)

FR-SHOPLIST-006: Odznaczanie produktów jako "kupione"
- Każdy produkt na liście ma checkbox
- Użytkownik może odznaczać produkty podczas zakupów
- Stan checkboxów jest zapisywany w bazie danych
- Odznaczone produkty są przekreślone (CSS: text-decoration: line-through)

FR-SHOPLIST-007: Zapis listy w bazie danych
- Każda wygenerowana lista jest zapisywana w bazie danych
- Lista zawiera:
  - Datę utworzenia
  - Źródło: które posiłki/przepisy zostały uwzględnione
  - Listę produktów (zsumowanych składników + wolne pozycje)
  - Stan każdego produktu (kupiony/niekupiony)

### 3.5 Eksport do PDF/TXT

FR-EXPORT-001: Eksport do PDF
- Użytkownik może wyeksportować listę zakupów do formatu PDF
- Przycisk "Pobierz PDF" na widoku listy zakupów
- Natychmiastowe pobranie pliku PDF (bez modala/preview)
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.pdf`

FR-EXPORT-002: Eksport do TXT
- Użytkownik może wyeksportować listę zakupów do formatu TXT
- Przycisk "Pobierz TXT" na widoku listy zakupów
- Natychmiastowe pobranie pliku TXT
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.txt`

FR-EXPORT-003: Format eksportu
- Nagłówek:
  - "Lista zakupów na tydzień [data początku] - [data końca]"
  - Data wygenerowania
- Treść:
  - Lista składników zgrupowana w kategorie
  - Każda kategoria: nagłówek (np. "NABIAŁ:")
  - Każdy składnik: [ ] Nazwa - ilość jednostka
  - Checkbox ([ ] w TXT, unchecked box w PDF) do odznaczania podczas zakupów

FR-EXPORT-004: Format PDF
- Czysty, minimalistyczny layout
- Czcionka: sans-serif, rozmiar 12pt
- Checkboxy jako puste kwadraty (☐)
- Podział na sekcje (kategorie) z pogrubionym nagłówkiem
- Paginacja (jeśli lista jest długa)

### 3.6 Dashboard i nawigacja

FR-DASHBOARD-001: Dashboard centralny
- Po zalogowaniu, użytkownik widzi dashboard z kafelkami:
  - Moje Przepisy (link do listy przepisów)
  - Kalendarz Tygodnia (link do kalendarza)
  - Lista Zakupów (link do list zakupów)
  - Moje Konto (link do ustawień)
- Każdy kafelek: duża ikona + tytuł + krótki opis

FR-DASHBOARD-002: Empty state
- Jeśli użytkownik nie ma żadnych przepisów:
  - Komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
  - Przycisk: "Dodaj pierwszy przepis" (link do formularza dodawania)

FR-DASHBOARD-003: Nawigacja
- Dashboard jest stroną główną (po zalogowaniu)
- Możliwość powrotu do dashboardu z każdego widoku (logo/link w nagłówku)

### 3.7 Wymagania niefunkcjonalne

NFR-001: Performance
- Czas ładowania strony < 2 sekundy
- Dostępność aplikacji 99%+
- Parsowanie AI w ciągu 3-5 sekund

NFR-002: Bezpieczeństwo
- Bezpieczne przechowywanie danych użytkowników (RODO compliance)
- Row Level Security (RLS) w Supabase - użytkownik widzi tylko swoje dane
- Hasła zahashowane przez Supabase Auth (bcrypt)
- HTTPS transport (TLS 1.3)
- Tokeny JWT z expiration (Supabase default: 1 godzina)

NFR-003: Accessibility
- Zgodność z WCAG 2.1 Level AA
- Keyboard navigation (wszystkie interaktywne elementy dostępne przez Tab)
- Focus state wyraźnie widoczny (outline)
- Semantic HTML (nav, main, section, article)
- ARIA labels dla ikon bez tekstu
- Color contrast minimum 4.5:1 dla body text

NFR-004: Responsywność
- Mobile-first approach
- Responsive web app działająca na mobile i desktop
- Breakpoints: Mobile (< 640px), Tablet (640px - 1024px), Desktop (> 1024px)

NFR-005: UI/UX dla grupy 50+
- Duże przyciski (min. 44px wysokości)
- Duże czcionki (min. 16px body text)
- Wysoki kontrast
- Jasne CTA (Call To Action)
- Zrozumiałe ikony
- Minimalistyczny interfejs bez zbędnych elementów

## 4. Granice produktu

### 4.1 W zakresie MVP

- CRUD przepisów (text-based)
- AI parsowanie składników z limitem 20 przepisów/miesiąc
- Kalendarz tygodniowy (7 dni x 4 posiłki)
- System szablonów tygodnia (powtarzające się posiłki)
- Przypisywanie przepisów do posiłków
- Generowanie listy zakupów z agregacją składników
- Grupowanie składników w kategorie
- Edycja listy zakupów (dodawanie wolnych pozycji)
- Odznaczanie produktów jako "kupione"
- Eksport do PDF/TXT
- Responsywny UI (mobile + desktop)
- Prosty system kont użytkowników (email + hasło)

### 4.2 Poza zakresem MVP

- Import przepisów z plików (JPG, PDF, DOCX)
- Aplikacje mobilne (native iOS/Android)
- Udostępnianie przepisów między użytkownikami
- Integracja z zewnętrznymi serwisami zakupowymi (np. Glovo, Frisco)
- Obsługa wielu języków (na początek tylko polski)
- Kalendarz miesięczny (tylko tygodniowy)
- Powiadomienia (email, SMS, push)
- Zaawansowane wyszukiwanie/filtrowanie przepisów
- Integracja z asystentami głosowymi (Alexa, Google Assistant)
- Obsługa diet i alergii (wegetariańska, bezglutenowa, etc.)
- Integracja z kalendarzem (Google Calendar, iCal)
- Zaawansowane zarządzanie użytkownikami (role, uprawnienia)
- Zaawansowane bezpieczeństwo (2FA, szyfrowanie end-to-end)
- Wiele przepisów na jeden posiłek (tylko 1 przepis = 1 posiłek)
- OAuth providers (Google, Facebook login)
- Automatyczna konwersja jednostek miary (ml → szklanki, etc.)
- Zdjęcia przepisów (tylko tekst)

### 4.3 Ograniczenia techniczne

- AI parsowanie: Limit 20 przepisów/miesiąc na użytkownika (kontrola kosztów)
- AI parsowanie: Bez inteligentnej konwersji jednostek (1 szklanka ≠ 250ml automatycznie)
- AI parsowanie: Sukces parsowania cel 80%+ (nie 100%)
- Kalendarz: Tylko widok tygodniowy (brak widoku miesięcznego, rocznego)
- Kalendarz: Brak historii wcześniejszych tygodni (nie można przeglądać przeszłości)
- Lista zakupów: Agregacja składników tylko po nazwie (lowercase matching)
- Lista zakupów: Brak automatycznego grupowania synonimów (np. "pomidor" ≠ "pomidory")
- Performance: Brak paginacji w liście przepisów (MVP zakłada max około 50 przepisów na użytkownika)
- Performance: Brak cache'owania AI responses (każde parsowanie = nowe wywołanie API)
- Bezpieczeństwo: Podstawowe uwierzytelnienie (email + hasło), brak 2FA
- Bezpieczeństwo: Brak szyfrowania danych w spoczynku (tylko transport HTTPS)

## 5. Historyjki użytkowników

### 5.1 Autentykacja i bezpieczeństwo

US-001: Rejestracja nowego użytkownika
Tytuł: Jako nowy użytkownik chcę zarejestrować konto używając email i hasła
Opis: Użytkownik odwiedza aplikację po raz pierwszy i chce założyć konto, aby móc zarządzać przepisami i listami zakupów.

Kryteria akceptacji:
- Strona rejestracji zawiera formularz z polami: email, hasło, potwierdzenie hasła
- Email jest walidowany (poprawny format)
- Hasło musi mieć minimum 8 znaków, zawierać litery i cyfry
- Po rejestracji użytkownik otrzymuje email weryfikacyjny
- Komunikat o błędzie wyświetlany inline (czerwony tekst pod polem) dla nieprawidłowych danych
- Po kliknięciu linku w emailu konto jest aktywowane
- Po aktywacji użytkownik jest przekierowywany do strony logowania

---

US-002: Logowanie do aplikacji
Tytuł: Jako zarejestrowany użytkownik chcę zalogować się do aplikacji
Opis: Użytkownik ma już konto i chce uzyskać dostęp do swoich przepisów i list zakupów.

Kryteria akceptacji:
- Strona logowania zawiera pola: email, hasło
- Przycisk "Zaloguj się" wysyła dane do Supabase Auth
- Po poprawnym zalogowaniu użytkownik jest przekierowywany do dashboardu
- Sesja jest zachowywana (remember me) - użytkownik nie musi logować się ponownie
- W przypadku błędnych danych wyświetlany jest komunikat: "Nieprawidłowy email lub hasło"
- Link "Zapomniałeś hasła?" jest widoczny na stronie logowania

---

US-003: Reset hasła
Tytuł: Jako użytkownik chcę zresetować hasło, gdy je zapomnę
Opis: Użytkownik zapomniał hasła i potrzebuje możliwości ustawienia nowego.

Kryteria akceptacji:
- Kliknięcie "Zapomniałeś hasła?" otwiera formularz z polem email
- Po podaniu email i kliknięciu "Wyślij link" użytkownik otrzymuje email z linkiem resetującym
- Link w emailu prowadzi do formularza ustawienia nowego hasła
- Nowe hasło musi spełniać wymagania: min. 8 znaków, mix liter i cyfr
- Po ustawieniu nowego hasła użytkownik jest przekierowywany do strony logowania
- Komunikat sukcesu: "Hasło zostało zmienione. Możesz się teraz zalogować."

---

US-004: Wylogowanie z aplikacji
Tytuł: Jako zalogowany użytkownik chcę móc się wylogować
Opis: Użytkownik chce zakończyć sesję i bezpiecznie wylogować się z aplikacji.

Kryteria akceptacji:
- Przycisk "Wyloguj" jest widoczny w nawigacji/menu użytkownika
- Po kliknięciu "Wyloguj" sesja użytkownika jest kończona
- Użytkownik jest przekierowywany do strony logowania
- Po wylogowaniu użytkownik nie może uzyskać dostępu do chronionych stron bez ponownego logowania

---

US-005: Usunięcie konta
Tytuł: Jako użytkownik chcę móc usunąć swoje konto wraz z wszystkimi danymi
Opis: Użytkownik nie chce już korzystać z aplikacji i chce usunąć swoje konto zgodnie z RODO.

Kryteria akceptacji:
- W ustawieniach konta znajduje się przycisk "Usuń konto"
- Po kliknięciu pojawia się modal z pytaniem: "Czy na pewno chcesz usunąć konto? Ta operacja jest nieodwracalna."
- Modal zawiera przyciski: [Anuluj] [Usuń konto]
- Po potwierdzeniu wszystkie dane użytkownika (przepisy, listy zakupów, konto) są usuwane z bazy danych (hard delete)
- Użytkownik jest przekierowywany do strony głównej (landing page)
- Komunikat: "Twoje konto zostało usunięte."

---

### 5.2 Zarządzanie przepisami

US-006: Dodawanie pierwszego przepisu
Tytuł: Jako nowy użytkownik chcę dodać swój pierwszy przepis do aplikacji
Opis: Użytkownik chce wprowadzić przepis, aby móc zacząć planować posiłki i tworzyć listy zakupów.

Kryteria akceptacji:
- Dashboard zawiera przycisk "+ Dodaj przepis" (duży, wyraźny)
- Po kliknięciu otwiera się formularz z polami: "Nazwa przepisu" (input text), "Przepis" (textarea, min. 10 linii)
- Użytkownik wkleja pełny tekst przepisu do pola "Przepis"
- Przycisk "Rozpoznaj składniki" wywołuje AI parsing
- Podczas parsowania wyświetlany jest loader/spinner z komunikatem "Rozpoznawanie składników..."
- Po 3-5 sekundach użytkownik widzi tabelę rozpoznanych składników: Nazwa | Ilość | Jednostka | Kategoria
- Każdy wiersz tabeli jest edytowalny inline
- Przycisk "+ Dodaj składnik ręcznie" pozwala dodać składnik, którego AI nie rozpoznało
- Przycisk "Zapisz przepis" zapisuje przepis w bazie danych
- Po zapisaniu użytkownik jest przekierowywany do listy przepisów, gdzie widzi nowo dodany przepis

---

US-007: Obsługa błędu parsowania AI
Tytuł: Jako użytkownik chcę móc dodać przepis ręcznie, gdy AI nie rozpozna składników
Opis: AI nie zawsze poprawnie rozpoznaje składniki. Użytkownik potrzebuje fallback do ręcznego dodawania.

Kryteria akceptacji:
- Jeśli AI nie rozpozna składników lub wystąpi błąd, wyświetlany jest komunikat: "Nie udało się automatycznie rozpoznać składników. Dodaj je ręcznie."
- Przepis zostaje zapisany z pełnym tekstem
- Lista składników pozostaje pusta
- Użytkownik może ręcznie dodać składniki klikając "+ Dodaj składnik"
- Formularz dodawania składnika zawiera pola: Nazwa, Ilość, Jednostka, Kategoria (dropdown)
- Po dodaniu składników użytkownik klika "Zapisz przepis"
- Przepis pojawia się na liście przepisów

---

US-008: Przekroczenie limitu AI parsowania
Tytuł: Jako użytkownik chcę wiedzieć, kiedy przekroczę limit AI parsowania
Opis: Użytkownik ma limit 20 parsowań AI miesięcznie. Po przekroczeniu limitu powinien być o tym poinformowany.

Kryteria akceptacji:
- Licznik wykorzystania AI parsowania jest widoczny w ustawieniach profilu: "Wykorzystano X/20 parsowań w tym miesiącu"
- Po przekroczeniu limitu (20 parsowań) przycisk "Rozpoznaj składniki" jest nieaktywny (disabled)
- Komunikat: "Osiągnięto limit parsowań AI (20/miesiąc). Możesz dodać składniki ręcznie."
- Użytkownik może nadal dodawać przepisy, ale musi ręcznie wprowadzić składniki
- Licznik resetuje się automatycznie 1. dnia każdego miesiąca

---

US-009: Przeglądanie listy przepisów
Tytuł: Jako użytkownik chcę przeglądać wszystkie moje przepisy
Opis: Użytkownik chce zobaczyć listę wszystkich zapisanych przepisów, aby móc je łatwo znaleźć i przypisać do kalendarza.

Kryteria akceptacji:
- Widok "Moje Przepisy" wyświetla listę wszystkich przepisów użytkownika
- Każda karta przepisu wyświetla tylko nazwę przepisu (minimalistyczny widok)
- Przepisy są sortowane od najnowszych (domyślnie)
- Lista jest scrollowalna (brak paginacji w MVP)
- Przycisk "+ Dodaj przepis" jest widoczny na górze listy
- Jeśli użytkownik nie ma żadnych przepisów, wyświetlany jest empty state: "Nie masz jeszcze żadnych przepisów. Dodaj pierwszy przepis!" z przyciskiem "Dodaj przepis"

---

US-010: Wyświetlanie szczegółów przepisu
Tytuł: Jako użytkownik chcę zobaczyć szczegóły przepisu
Opis: Użytkownik klika na przepis i chce zobaczyć pełny tekst oraz listę składników.

Kryteria akceptacji:
- Kliknięcie w kartę przepisu otwiera widok szczegółowy
- Widok szczegółowy wyświetla:
  - Nazwę przepisu (duża czcionka, nagłówek)
  - Pełny tekst przepisu
  - Lista składników w formie tabeli: Nazwa | Ilość | Jednostka | Kategoria
- Przyciski akcji: "Edytuj", "Usuń", "Przypisz do kalendarza"
- Przycisk "Powrót do listy" prowadzi z powrotem do listy przepisów

---

US-011: Edycja przepisu
Tytuł: Jako użytkownik chcę edytować istniejący przepis
Opis: Użytkownik chce zmienić tekst przepisu lub poprawić listę składników.

Kryteria akceptacji:
- W widoku szczegółów przepisu znajduje się przycisk "Edytuj"
- Po kliknięciu otwiera się formularz edycji z polami:
  - Nazwa przepisu (edytowalna)
  - Pełny tekst przepisu (edytowalny textarea)
  - Lista składników (edytowalna tabela)
- Użytkownik może:
  - Zmienić tekst przepisu
  - Dodać nowy składnik (przycisk "+ Dodaj składnik")
  - Usunąć składnik (ikona "x" przy składniku)
  - Zmienić ilość/jednostkę/kategorię składnika (edycja inline)
- Brak ponownego parsowania AI przy edycji (oszczędność limitu)
- Przycisk "Zapisz zmiany" zapisuje edytowany przepis
- Po zapisaniu użytkownik wraca do widoku szczegółów przepisu

---

US-012: Usuwanie przepisu
Tytuł: Jako użytkownik chcę usunąć przepis, którego już nie potrzebuję
Opis: Użytkownik chce usunąć przepis z bazy danych.

Kryteria akceptacji:
- W widoku szczegółów przepisu znajduje się przycisk "Usuń"
- Po kliknięciu pojawia się modal z pytaniem: "Czy na pewno usunąć przepis [nazwa]?"
- Modal zawiera przyciski: [Anuluj] [Usuń]
- Po potwierdzeniu przepis jest usuwany z bazy danych
- Przepis znika z listy przepisów
- Jeśli przepis był przypisany do kalendarza, komórki kalendarza stają się puste (ON DELETE SET NULL)
- Użytkownik jest przekierowywany do listy przepisów
- Komunikat: "Przepis został usunięty."

---

### 5.3 Kalendarz i planowanie posiłków

US-013: Wyświetlanie kalendarza tygodniowego
Tytuł: Jako użytkownik chcę zobaczyć kalendarz tygodniowy z moimi posiłkami
Opis: Użytkownik chce zaplanować posiłki na cały tydzień i zobaczyć je w przejrzystej formie.

Kryteria akceptacji:
- Widok "Kalendarz Tygodnia" wyświetla kalendarz dla bieżącego tygodnia (Poniedziałek - Niedziela)
- Każdy dzień ma 4 typy posiłków: Śniadanie, Drugie śniadanie, Obiad, Kolacja
- Na desktop: widok tabelaryczny (7 kolumn x 4 wiersze)
- Na mobile: widok listy z akordeonami (każdy dzień to osobna sekcja rozwijana)
- Każda komórka kalendarza (dzień + posiłek) pokazuje nazwę przypisanego przepisu lub jest pusta z ikoną "+"
- Przycisk "Generuj listę zakupów" jest widoczny na górze kalendarza

---

US-014: Przypisywanie przepisu do wielu posiłków
Tytuł: Jako użytkownik chcę przypisać przepis do wielu dni/posiłków naraz
Opis: Użytkownik chce zaplanować ten sam przepis na kilka dni (np. śniadanie przez cały tydzień).

Kryteria akceptacji:
- Użytkownik wchodzi w "Moje Przepisy" i klika na przepis
- W widoku szczegółów przepisu znajduje się przycisk "Przypisz do kalendarza"
- Po kliknięciu otwiera się modal "Przypisz przepis: [nazwa przepisu]"
- Modal wyświetla kalendarz z checkboxami przy każdym posiłku (7 dni x 4 posiłki = 28 checkboxów)
- Użytkownik zaznacza checkboxy przy dniach/posiłkach, gdzie chce przypisać przepis
- Przyciski w modalu: [Anuluj] [Przypisz]
- Po kliknięciu "Przypisz" pojawia się pytanie: "Zmienić tylko ten tydzień czy szablon na stałe?"
- Opcje: [Tylko ten tydzień] [Szablon (zawsze)]
- Po wyborze modal się zamyka
- Przepis pojawia się w zaznaczonych komórkach kalendarza

---

US-015: Edycja szablonu tygodnia
Tytuł: Jako użytkownik chcę edytować szablon tygodnia, aby posiłki powtarzały się co tydzień
Opis: Użytkownik ma ulubiony zestaw posiłków, który chce powtarzać co tydzień automatycznie.

Kryteria akceptacji:
- Przy przypisywaniu lub usuwaniu przepisu z kalendarza pojawia się pytanie: "Jak chcesz zmienić ten przepis?"
- Modal wyświetla dwie opcje:
  - [Tylko ten tydzień] - zmiana dotyczy tylko bieżącego tygodnia (instancja)
  - [Szablon (zawsze)] - zmiana dotyczy szablonu tygodnia (powtarza się co tydzień)
- Po wyborze "Szablon (zawsze)" zmiana jest zapisywana w tabeli `calendar_template`
- W kolejnych tygodniach przepis automatycznie pojawia się w odpowiednich komórkach kalendarza
- Użytkownik może nadpisać szablon dla konkretnego tygodnia wybierając "Tylko ten tydzień"

---

US-016: Usuwanie przepisu z kalendarza
Tytuł: Jako użytkownik chcę usunąć przepis z konkretnego dnia/posiłku
Opis: Użytkownik nie chce już mieć danego przepisu w kalendarzu i chce go usunąć.

Kryteria akceptacji:
- Każda komórka kalendarza z przypisanym przepisem ma ikonę "x" (usuwanie)
- Po kliknięciu "x" pojawia się pytanie: "Usunąć tylko z tego tygodnia czy z szablonu?"
- Opcje: [Tylko ten tydzień] [Z szablonu]
- Po wyborze "Tylko ten tydzień" przepis jest usuwany z tabeli `calendar_instances` (tylko dla tego tygodnia)
- Po wyborze "Z szablonu" przepis jest usuwany z tabeli `calendar_template` (na stałe)
- Komórka kalendarza staje się pusta z ikoną "+"

---

US-017: Pusta komórka kalendarza (empty state)
Tytuł: Jako użytkownik chcę zobaczyć komunikat, gdy mój kalendarz jest pusty
Opis: Nowy użytkownik nie ma żadnych przepisów przypisanych do kalendarza i potrzebuje wskazówki, co zrobić dalej.

Kryteria akceptacji:
- Jeśli kalendarz jest całkowicie pusty (brak przepisów), wyświetlany jest komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
- Przycisk "Dodaj pierwszy przepis" prowadzi do formularza dodawania przepisu
- Komunikat jest wyświetlany centralnie na stronie kalendarza

---

US-018: Kliknięcie w przepis w kalendarzu
Tytuł: Jako użytkownik chcę zobaczyć szczegóły przepisu klikając na niego w kalendarzu
Opis: Użytkownik widzi przepis w kalendarzu i chce szybko sprawdzić jego szczegóły.

Kryteria akceptacji:
- Kliknięcie w nazwę przepisu w komórce kalendarza otwiera widok szczegółów przepisu
- Widok szczegółów wyświetla nazwę, pełny tekst, listę składników
- Użytkownik może wrócić do kalendarza klikając "Powrót do kalendarza"

---

### 5.4 Generowanie listy zakupów

US-019: Generowanie listy zakupów z kalendarza
Tytuł: Jako użytkownik chcę wygenerować listę zakupów z zaplanowanych posiłków
Opis: Użytkownik zaplanował posiłki na tydzień i chce automatycznie wygenerować listę zakupów.

Kryteria akceptacji:
- Na widoku kalendarza znajduje się przycisk "Generuj listę zakupów" (duży, wyraźny)
- Po kliknięciu kalendarz przechodzi w "tryb selekcji"
- Pojawiają się checkboxy przy każdym przypisanym posiłku w kalendarzu
- Użytkownik zaznacza, które posiłki chce uwzględnić w liście zakupów
- Przycisk "Generuj listę" (aktywny tylko gdy zaznaczono minimum 1 posiłek)
- Po kliknięciu "Generuj listę" wyświetlany jest loader/spinner (2-3 sekundy)
- Użytkownik jest przekierowywany do widoku "Lista Zakupów"
- Wygenerowana lista zawiera wszystkie składniki z zaznaczonych posiłków

---

US-020: Agregacja składników w liście zakupów
Tytuł: Jako użytkownik chcę, aby składniki z wielu przepisów były automatycznie zsumowane
Opis: Użytkownik zaznaczył kilka posiłków, które zawierają ten sam składnik (np. mleko). Chce zobaczyć zsumowaną ilość.

Kryteria akceptacji:
- Jeśli ten sam składnik występuje w wielu przepisach, system automatycznie sumuje ilości
- Przykład: "mleko 500ml" + "mleko 200ml" = "mleko 700ml" (jedna pozycja na liście)
- Składniki są grupowane według nazwy (lowercase matching, np. "Mleko" = "mleko")
- Jeśli jednostki są zgodne, ilości są dodawane
- Jeśli jednostki są różne (np. "1 szklanka mleka" + "200ml mleka"), składniki pozostają osobno (brak konwersji w MVP)

---

US-021: Grupowanie składników w kategorie
Tytuł: Jako użytkownik chcę, aby lista zakupów była podzielona na kategorie produktów
Opis: Użytkownik chce łatwo nawigować po liście zakupów podczas zakupów w sklepie. Kategorie ułatwiają znalezienie produktów.

Kryteria akceptacji:
- Lista zakupów jest podzielona na kategorie: Nabiał, Warzywa, Owoce, Mięso, Pieczywo, Przyprawy, Inne
- Każda kategoria ma nagłówek (np. "NABIAŁ:")
- Pod nagłówkiem wyświetlana jest lista składników należących do tej kategorii
- Kategorie są wyświetlane w stałej kolejności
- Jeśli kategoria jest pusta (brak składników), nie jest wyświetlana

---

US-022: Przeglądanie historii list zakupów
Tytuł: Jako użytkownik chcę zobaczyć wszystkie wcześniej wygenerowane listy zakupów
Opis: Użytkownik chce wrócić do starej listy zakupów lub porównać listy z różnych tygodni.

Kryteria akceptacji:
- Widok "Lista Zakupów" wyświetla listę wszystkich wygenerowanych list zakupów (historia)
- Każda lista wyświetla: datę utworzenia, liczbę produktów, tydzień (data początku - data końca)
- Domyślnie wyświetlana jest najnowsza lista
- Użytkownik może kliknąć na starą listę, aby zobaczyć jej szczegóły
- Lista jest sortowana od najnowszych

---

US-023: Edycja listy zakupów
Tytuł: Jako użytkownik chcę ręcznie edytować wygenerowaną listę zakupów
Opis: Użytkownik chce dodać wolne pozycje (nie związane z przepisami), usunąć produkty lub zmienić ilości.

Kryteria akceptacji:
- W widoku listy zakupów znajduje się przycisk "Edytuj listę"
- Po kliknięciu otwiera się tryb edycji
- W trybie edycji użytkownik może:
  - Dodać nowy produkt (przycisk "+ Dodaj produkt")
  - Usunąć produkt (ikona "x" przy produkcie)
  - Zmienić ilość i jednostkę (edycja inline)
  - Zmienić kategorię (dropdown)
- Ręcznie dodane produkty są oznaczone jako "wolne pozycje" (is_manual = true)
- Przyciski: [Anuluj] [Zapisz zmiany]
- Po zapisaniu użytkownik wraca do widoku listy zakupów

---

US-024: Odznaczanie produktów podczas zakupów
Tytuł: Jako użytkownik chcę odznaczać produkty, które już kupiłem
Opis: Użytkownik jest w sklepie z telefonem i chce odznaczać produkty, aby wiedzieć, co mu zostało do kupienia.

Kryteria akceptacji:
- Każdy produkt na liście ma checkbox (puste pole)
- Użytkownik może kliknąć checkbox, aby oznaczyć produkt jako "kupiony"
- Odznaczony produkt jest przekreślony (CSS: text-decoration: line-through)
- Stan checkboxa jest zapisywany w bazie danych (is_checked = true)
- Po odświeżeniu strony checkbox jest nadal zaznaczony (stan persystentny)
- Użytkownik może odznaczyć checkbox (ponowne kliknięcie)

---

US-025: Dodawanie wolnej pozycji do listy zakupów
Tytuł: Jako użytkownik chcę dodać produkt do listy, który nie jest składnikiem żadnego przepisu
Opis: Użytkownik chce kupić dodatkowe produkty (np. papier toaletowy, mydło), które nie są częścią przepisów.

Kryteria akceptacji:
- W trybie edycji listy zakupów znajduje się przycisk "+ Dodaj produkt"
- Po kliknięciu otwiera się formularz z polami: Nazwa, Ilość, Jednostka, Kategoria (dropdown)
- Użytkownik wypełnia pola i klika "Dodaj"
- Produkt pojawia się na liście zakupów w odpowiedniej kategorii
- Produkt jest oznaczony jako "wolna pozycja" (is_manual = true, nie związany z przepisem)

---

### 5.5 Eksport listy zakupów

US-026: Eksport listy zakupów do PDF
Tytuł: Jako użytkownik chcę wyeksportować listę zakupów do formatu PDF
Opis: Użytkownik chce wydrukować listę zakupów, aby zabrać ją do sklepu w formie papierowej.

Kryteria akceptacji:
- W widoku listy zakupów znajduje się przycisk "Pobierz PDF"
- Po kliknięciu plik PDF jest natychmiast pobierany (bez preview/modala)
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.pdf`
- Plik PDF zawiera:
  - Nagłówek: "Lista zakupów na tydzień [data początku] - [data końca]", "Wygenerowano: [data]"
  - Składniki zgrupowane w kategorie
  - Każda kategoria: nagłówek pogrubiony (np. "NABIAŁ:")
  - Każdy składnik: ☐ Nazwa - ilość jednostka
  - Czysty, minimalistyczny layout, czcionka sans-serif 12pt
- Plik można otworzyć i wydrukować

---

US-027: Eksport listy zakupów do TXT
Tytuł: Jako użytkownik chcę wyeksportować listę zakupów do formatu TXT
Opis: Użytkownik chce mieć prostą wersję tekstową listy zakupów.

Kryteria akceptacji:
- W widoku listy zakupów znajduje się przycisk "Pobierz TXT"
- Po kliknięciu plik TXT jest natychmiast pobierany
- Nazwa pliku: `lista-zakupow-YYYY-MM-DD.txt`
- Plik TXT zawiera:
  - Nagłówek: "Lista zakupów na tydzień [data początku] - [data końca]", "Wygenerowano: [data]"
  - Składniki zgrupowane w kategorie
  - Każda kategoria: nagłówek (np. "NABIAŁ:")
  - Każdy składnik: [ ] Nazwa - ilość jednostka
- Format plain text (UTF-8)

---

US-028: Format eksportu z checkboxami
Tytuł: Jako użytkownik chcę, aby wyeksportowana lista zawierała checkboxy do odznaczania
Opis: Użytkownik chce odznaczać produkty na wydrukowanej liście podczas zakupów.

Kryteria akceptacji:
- W PDF: checkboxy jako puste kwadraty (☐)
- W TXT: checkboxy jako [ ]
- Użytkownik może ręcznie odznaczać checkboxy długopisem/ołówkiem na wydruku

---

### 5.6 Dashboard i nawigacja

US-029: Wyświetlanie dashboardu po zalogowaniu
Tytuł: Jako zalogowany użytkownik chcę zobaczyć dashboard z głównymi funkcjami aplikacji
Opis: Użytkownik po zalogowaniu chce szybko dostać się do głównych funkcji aplikacji.

Kryteria akceptacji:
- Po zalogowaniu użytkownik jest przekierowywany do dashboardu
- Dashboard wyświetla 4 kafelki:
  - "Moje Przepisy" (link do listy przepisów)
  - "Kalendarz Tygodnia" (link do kalendarza)
  - "Lista Zakupów" (link do list zakupów)
  - "Moje Konto" (link do ustawień)
- Każdy kafelek zawiera: dużą ikonę (64px), tytuł (20pt), krótki opis (14pt)
- Na desktop: grid 2x2 (każdy kafelek około 250px x 200px)
- Na mobile: kafelki ułożone pionowo (lista), pełna szerokość ekranu

---

US-030: Empty state na dashboardzie
Tytuł: Jako nowy użytkownik chcę zobaczyć komunikat zachęcający do dodania pierwszego przepisu
Opis: Nowy użytkownik nie ma żadnych przepisów i potrzebuje wskazówki, od czego zacząć.

Kryteria akceptacji:
- Jeśli użytkownik nie ma żadnych przepisów, dashboard wyświetla komunikat: "Zacznij od dodania przepisów i zaplanowania tygodnia"
- Przycisk "Dodaj pierwszy przepis" prowadzi do formularza dodawania przepisu
- Komunikat jest widoczny centralnie na stronie

---

US-031: Nawigacja między sekcjami
Tytuł: Jako użytkownik chcę łatwo nawigować między sekcjami aplikacji
Opis: Użytkownik chce szybko przejść z kalendarza do przepisów lub listy zakupów.

Kryteria akceptacji:
- Nagłówek aplikacji zawiera logo/link "GroceryList" prowadzący do dashboardu
- Menu nawigacyjne zawiera linki: Dashboard, Moje Przepisy, Kalendarz Tygodnia, Lista Zakupów, Moje Konto
- Aktywna sekcja jest wyróżniona (np. podkreślona, inna kolorystyka)
- Użytkownik może wrócić do dashboardu z dowolnej strony klikając logo

---

### 5.7 Scenariusze brzegowe i walidacja

US-032: Dodawanie przepisu bez nazwy
Tytuł: Jako użytkownik chcę zobaczyć komunikat błędu, gdy nie podam nazwy przepisu
Opis: Użytkownik próbuje zapisać przepis bez wypełnienia pola "Nazwa przepisu".

Kryteria akceptacji:
- Pole "Nazwa przepisu" jest wymagane
- Jeśli użytkownik klika "Zapisz przepis" bez wypełnienia nazwy, wyświetlany jest komunikat błędu: "Pole 'Nazwa przepisu' jest wymagane"
- Komunikat błędu jest wyświetlany inline (czerwony tekst pod polem)
- Przepis nie jest zapisywany

---

US-033: Generowanie listy zakupów bez zaznaczonych posiłków
Tytuł: Jako użytkownik chcę zobaczyć komunikat, gdy próbuję wygenerować listę bez zaznaczonych posiłków
Opis: Użytkownik klika "Generuj listę" ale nie zaznaczył żadnych posiłków.

Kryteria akceptacji:
- Przycisk "Generuj listę" jest nieaktywny (disabled), gdy nie zaznaczono żadnego posiłku
- Jeśli użytkownik nie zaznaczył żadnych posiłków, wyświetlany jest komunikat: "Zaznacz przynajmniej jeden posiłek, aby wygenerować listę zakupów"

---

US-034: Przypisywanie przepisu do kalendarza, gdy brak przepisów
Tytuł: Jako użytkownik chcę zobaczyć komunikat, gdy próbuję przypisać przepis, ale nie mam żadnych przepisów
Opis: Użytkownik chce zaplanować posiłki, ale nie dodał jeszcze żadnych przepisów.

Kryteria akceptacji:
- Jeśli użytkownik wchodzi w kalendarz i nie ma żadnych przepisów, wyświetlany jest komunikat: "Nie masz jeszcze żadnych przepisów. Dodaj pierwszy przepis, aby zaplanować posiłki."
- Przycisk "Dodaj pierwszy przepis" prowadzi do formularza dodawania przepisu

---

US-035: Edycja przepisu używanego w kalendarzu
Tytuł: Jako użytkownik chcę edytować przepis, który jest już przypisany do kalendarza
Opis: Użytkownik chce zmienić składniki przepisu, który jest już zaplanowany w kalendarzu.

Kryteria akceptacji:
- Użytkownik może edytować przepis (zmiana nazwy, tekstu, składników)
- Po zapisaniu zmian przepis jest zaktualizowany w bazie danych
- Zmiana jest widoczna w kalendarzu (zaktualizowana nazwa przepisu)
- Jeśli zmieniono składniki, nowo wygenerowane listy zakupów będą zawierać zaktualizowane składniki

---

US-036: Usuwanie przepisu używanego w kalendarzu
Tytuł: Jako użytkownik chcę usunąć przepis, który jest już przypisany do kalendarza
Opis: Użytkownik chce usunąć przepis, który jest obecnie zaplanowany w kalendarzu.

Kryteria akceptacji:
- Użytkownik może usunąć przepis (przycisk "Usuń")
- Po potwierdzeniu przepis jest usuwany z bazy danych
- Komórki kalendarza, w których był przypisany ten przepis, stają się puste (ON DELETE SET NULL)
- Komunikat: "Przepis został usunięty. Był przypisany do kalendarza i został z niego usunięty."

---

US-037: Przekroczenie maksymalnej długości tekstu przepisu
Tytuł: Jako użytkownik chcę zobaczyć komunikat, gdy tekst przepisu jest za długi
Opis: Użytkownik próbuje dodać bardzo długi przepis (> 5000 znaków).

Kryteria akceptacji:
- Pole "Przepis" ma limit 5000 znaków
- Jeśli użytkownik wklei tekst dłuższy niż 5000 znaków, wyświetlany jest komunikat: "Tekst przepisu jest za długi (maksymalnie 5000 znaków)"
- Licznik znaków jest widoczny pod polem: "X/5000 znaków"

---

### 5.8 Scenariusze responsywności i accessibility

US-038: Przeglądanie aplikacji na urządzeniu mobilnym
Tytuł: Jako użytkownik mobilny chcę, aby aplikacja działała poprawnie na smartfonie
Opis: Użytkownik otwiera aplikację na smartfonie i chce wygodnie z niej korzystać.

Kryteria akceptacji:
- Aplikacja jest w pełni responsywna (breakpoint mobile: < 640px)
- Dashboard: kafelki ułożone pionowo (lista), pełna szerokość ekranu
- Kalendarz: widok listy z akordeonami (każdy dzień to osobna sekcja rozwijana)
- Lista przepisów: karty przepisów ułożone pionowo
- Wszystkie przyciski mają min. 44px wysokości (touch-friendly)
- Czcionki są czytelne (min. 16px body text)

---

US-039: Nawigacja klawiaturą
Tytuł: Jako użytkownik z niepełnosprawnościami chcę móc nawigować aplikację używając klawiatury
Opis: Użytkownik nie może korzystać z myszy i używa klawiatury (Tab, Enter, Space) do nawigacji.

Kryteria akceptacji:
- Wszystkie interaktywne elementy (przyciski, linki, formularze) są dostępne przez Tab
- Focus state jest wyraźnie widoczny (outline)
- Użytkownik może zatwierdzić przycisk/link przez Enter lub Space
- Modalowe okna dialogowe można zamknąć przez Escape
- Skip to main content link na początku strony

---

US-040: Korzystanie z czytnika ekranu
Tytuł: Jako użytkownik niewidomy chcę, aby aplikacja była zgodna z czytnikami ekranu
Opis: Użytkownik korzysta z czytnika ekranu (np. NVDA, JAWS) i chce, aby aplikacja była dostępna.

Kryteria akceptacji:
- Semantic HTML (nav, main, section, article, header, footer)
- ARIA labels dla ikon bez tekstu (np. aria-label="Usuń przepis")
- ARIA live regions dla dynamicznych aktualizacji (np. komunikaty o sukcesie/błędzie)
- Wszystkie obrazy mają alt text
- Formularze mają label powiązane z input (for/id)

---

## 6. Metryki sukcesu

### 6.1 Metryki kluczowe dla MVP

Metryka 1: WAU (Weekly Active Users)
- Cel MVP: 50+ użytkowników po 8 tygodniach od wdrożenia
- Sposób pomiaru: Liczba unikalnych użytkowników logujących się w danym tygodniu
- Definicja sukcesu: Wzrost WAU o minimum 10% tydzień do tygodnia przez pierwsze 8 tygodni

Metryka 2: Liczba list zakupów na użytkownika miesięcznie
- Cel MVP: Średnio 3-4 listy na aktywnego użytkownika
- Sposób pomiaru: Średnia liczba wygenerowanych list na aktywnego użytkownika w danym miesiącu
- Definicja sukcesu: Użytkownicy generują listę zakupów przynajmniej raz w tygodniu

Metryka 3: Średnia liczba przepisów na użytkownika
- Cel MVP: 10+ przepisów na użytkownika
- Sposób pomiaru: Średnia liczba zapisanych przepisów w bazie użytkownika
- Definicja sukcesu: Użytkownicy aktywnie dodają i zarządzają przepisami (minimum 10 przepisów w pierwszym miesiącu użytkowania)

Metryka 4: 30-day retention
- Cel MVP: 40%+ użytkowników aktywnych po 30 dniach od rejestracji
- Sposób pomiaru: % użytkowników, którzy zalogowali się przynajmniej raz w ciągu 30 dni od rejestracji
- Definicja sukcesu: Minimum 40% użytkowników wraca do aplikacji po 30 dniach

Metryka 5: NPS (Net Promoter Score)
- Cel MVP: 50+ punktów
- Sposób pomiaru: Ankieta po 2 tygodniach użytkowania: "Jak prawdopodobne, że polecisz GroceryList znajomemu?" (0-10)
- Definicja sukcesu: NPS minimum 50 (więcej promotorów niż detraktorów)

### 6.2 Metryki pomocnicze

Metryka 6: Wskaźnik eksportu do PDF/TXT
- Cel MVP: 70%+ list zakupów jest eksportowanych
- Sposób pomiaru: % wygenerowanych list, które zostały wyeksportowane do PDF lub TXT
- Znaczenie: Potwierdza, że użytkownicy rzeczywiście używają list podczas zakupów

Metryka 7: Sukces parsowania AI
- Cel MVP: 80%+ przepisów poprawnie rozpoznanych
- Sposób pomiaru: % przepisów, w których AI poprawnie rozpoznało składniki (min. 80% składników bez błędów)
- Znaczenie: Walidacja jakości AI parsowania

Metryka 8: Średni czas sesji
- Cel MVP: 5-10 minut
- Sposób pomiaru: Średni czas spędzony w aplikacji podczas jednej wizyty
- Znaczenie: Potwierdza, że aplikacja jest wydajna (użytkownik szybko wykonuje zadania)

Metryka 9: Bounce rate
- Cel MVP: < 30%
- Sposób pomiaru: % użytkowników, którzy opuścili stronę bez żadnej interakcji
- Znaczenie: Niska wartość potwierdza, że użytkownicy znajdują wartość w aplikacji

Metryka 10: Time to first recipe
- Cel MVP: < 10 minut od rejestracji
- Sposób pomiaru: Średni czas od rejestracji do dodania pierwszego przepisu
- Znaczenie: Potwierdza, że onboarding jest szybki i intuicyjny

### 6.3 Wskaźniki techniczne

Wskaźnik 1: Czas ładowania strony
- Cel MVP: < 2 sekundy (First Contentful Paint)
- Sposób pomiaru: Google Lighthouse Performance score
- Definicja sukcesu: Lighthouse score minimum 90+ na mobile i desktop

Wskaźnik 2: Dostępność aplikacji (uptime)
- Cel MVP: 99%+ dostępności
- Sposób pomiaru: Monitoring Supabase i Vercel/Netlify
- Definicja sukcesu: Maksymalnie 7 godzin downtime rocznie

Wskaźnik 3: Czas parsowania AI
- Cel MVP: 3-5 sekund na przepis
- Sposób pomiaru: Średni czas wywołania API OpenAI/Anthropic
- Definicja sukcesu: Użytkownik nie czeka dłużej niż 5 sekund na parsowanie

Wskaźnik 4: Accessibility score
- Cel MVP: 100% zgodności z WCAG 2.1 Level AA
- Sposób pomiaru: Google Lighthouse Accessibility score
- Definicja sukcesu: Score minimum 90+

### 6.4 Walidacja MVP

Warunek 1: User testing z grupą docelową
- Minimum 20 beta testerów (reprezentujących personę: pary 50+)
- User interviews po 2 tygodniach użytkowania
- Identyfikacja pain points i iteracje przed publicznym wdrożeniem

Warunek 2: Osiągnięcie minimum 3 z 5 kluczowych metryk
- WAU 50+, lub
- Listy zakupów 3-4/użytkownik/miesiąc, lub
- Przepisy 10+/użytkownik, lub
- 30-day retention 40%+, lub
- NPS 50+

Warunek 3: Brak krytycznych bugów
- Zero P0 (critical) bugów w produkcji
- Maksymalnie 5 P1 (high) bugów w produkcji (z planem naprawy w ciągu 7 dni)

---

## 7. Harmonogram rozwoju

### Faza 1: Foundation & Recipe Management (2-3 tygodnie)
- Setup projektu (Astro + React + TypeScript + Tailwind + Supabase)
- Konfiguracja Supabase (database, auth)
- User authentication (rejestracja, logowanie, reset hasła, usunięcie konta)
- Dashboard centralny z kafelkami
- CRUD przepisów (dodawanie, edycja, usuwanie, przeglądanie)
- Integracja AI dla parsowania składników
- Limit parsowania AI (20/miesiąc)
- Obsługa błędów parsowania

### Faza 2: Calendar & Meal Planning (2-3 tygodnie)
- Kalendarz tygodniowy (widok desktop i mobile)
- System szablonów tygodnia
- Przypisywanie przepisów do posiłków (flow z checkboxami)
- Modal: "Zmienić tylko ten tydzień czy szablon?"
- Wyświetlanie przypisanych przepisów w kalendarzu
- Usuwanie przepisów z kalendarza

### Faza 3: Shopping List Generation (1-2 tygodnie)
- Generowanie listy zakupów z zaznaczonych posiłków (checkboxy)
- Agregacja składników (sumowanie ilości)
- Grupowanie w kategorie
- Zapis listy w bazie danych
- Edycja listy (dodawanie wolnych pozycji, usuwanie, zmiana ilości)
- Odznaczanie produktów jako "kupione" (checkboxy)
- Historia list zakupów

### Faza 4: Export & Polish (1 tydzień)
- Eksport listy zakupów do PDF
- Eksport listy zakupów do TXT
- Formatowanie eksportów (nagłówki, kategorie, checkboxy)
- UI polish: ikony, kolory, spacing
- Accessibility improvements (keyboard navigation, ARIA)
- Performance optimization (lazy loading, code splitting)
- Bug fixes

Timeline Summary: 6-9 tygodni → Pełne MVP

---

## 8. Ryzyka i mitigacja

### Ryzyko 1: AI parsowanie składników nie działa poprawnie (sukces < 80%)
Prawdopodobieństwo: Medium
Impact: High

Mitigacja:
- Iteracyjne testowanie promptu AI na różnych przepisach (minimum 50 przepisów testowych)
- Feedback loop: użytkownik może poprawić składniki po parsowaniu
- Fallback: ręczne dodawanie składników (jeśli AI zawiedzie)
- Testowanie na różnych typach przepisów (polskie, włoskie, azjatyckie, etc.)

### Ryzyko 2: Koszt AI API przekroczy budżet
Prawdopodobieństwo: Medium
Impact: Medium

Mitigacja:
- Limit 20 parsowań/użytkownik/miesiąc (rate limiting)
- Monitoring kosztów AI API (dashboard w OpenAI/Anthropic)
- Możliwość przełączenia na tańszy model (np. GPT-3.5 zamiast GPT-4)
- Opcjonalnie: cache'owanie podobnych przepisów (post-MVP)

### Ryzyko 3: Użytkownicy 50+ mają trudności z obsługą aplikacji
Prawdopodobieństwo: Medium
Impact: High

Mitigacja:
- Prosty, intuicyjny UI (duże przyciski, czytelne czcionki)
- Onboarding flow dla nowych użytkowników (opcjonalnie)
- User testing z reprezentatywną grupą (min. 5 użytkowników 50+)
- Tooltips i helpful hints w kluczowych miejscach
- Help/FAQ section w aplikacji

### Ryzyko 4: Niska adopcja użytkowników (brak traction)
Prawdopodobieństwo: Medium
Impact: High

Mitigacja:
- Walidacja MVP z grupą beta testerów (min. 20 osób)
- Zbieranie feedbacku przez ankiety (NPS, user interviews)
- Iteracyjne usprawnienia na podstawie feedbacku
- Marketing: lokalne grupy na Facebooku (grupy kulinarne, dla seniorów)
- Opcjonalnie: referral program (polecanie znajomym)

### Ryzyko 5: Problemy z performance (wolne ładowanie, timeout)
Prawdopodobieństwo: Low
Impact: Medium

Mitigacja:
- Optymalizacja Astro (SSR + static generation gdzie możliwe)
- Code splitting (React components lazy loaded)
- Image optimization (Astro Image)
- Monitoring performance (Lighthouse, Web Vitals)
- Caching strategies (Supabase caching, CDN)

### Ryzyko 6: Naruszenie RODO (problemy prawne)
Prawdopodobieństwo: Low
Impact: High

Mitigacja:
- Konsultacja z prawnikiem (polityka prywatności, ToS)
- Supabase w EU region (dane nie opuszczają EU, poza AI API)
- Jasne zgody użytkownika (checkboxy, informacje)
- Hard delete danych po usunięciu konta
- Regularne audyty bezpieczeństwa (Supabase RLS policies)

---

Dokument PRD v2.0
Ostatnia aktualizacja: 2025-10-15