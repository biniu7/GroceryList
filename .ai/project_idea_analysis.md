# Analiza Pomysłu na Projekt - GroceryList

Data: 2025-10-15
Wersja: 1.0
Status: Final
Kontekst: Kurs 10xDevs, praca po godzinach z AI

## Executive Summary

**Pomysł**: GroceryList - aplikacja webowa do tworzenia list zakupów na podstawie przepisów przypisanych do kalendarza tygodniowego z podziałem na 4 typy posiłków dziennie.

**Profil developera**:
- 15 lat doświadczenia (Angular + Java EE + PostgreSQL)
- 30h tygodniowo (bardzo dobry budżet!)
- Deadline: 14 listopada 2025 (6 tygodni)
- Brak doświadczenia: Astro, Supabase, React 19, AI API
- Cel: Uproszczona wersja MVP jako demo
- Preferencje: Szybkie rozwiązanie, bez AI na start, bez PDF export

**Werdykt końcowy**: ✅ **AKCEPTACJA - PROJEKT JEST REALISTYCZNY DLA CIEBIE!**

Z Twoim doświadczeniem (15 lat) i budżetem czasowym (30h/tydzień = **180 godzin total**) jesteś w stanie zbudować **solidne Extended MVP** w 6 tygodni. Twoje preferencje (bez AI, bez PDF) idealnie pasują do zakresu, który jest realistyczny w deadline.

**Ocena ogólna**: 8.5/10 (bardzo dobry pomysł dla Twojego profilu!)

---

## 1. Czy aplikacja rozwiązuje realny problem?

### Ocena: 9/10 ✅ TAK - problem jest BARDZO realny

### Analiza problemu:

#### Problem 1: Zapominanie składników podczas zakupów
- **Realność**: 10/10 - Każdy, kto robi zakupy, zna ten problem
- **Impact**: Wielokrotne wizyty w sklepie, frustracja, dodatkowe koszty
- **Target group**: Pary 50+, osoby planujące posiłki z wyprzedzeniem

#### Problem 2: Czasochłonne tworzenie listy zakupów z przepisów
- **Realność**: 9/10 - Ręczne przepisywanie składników z 5-7 przepisów to 30-60 minut tygodniowo
- **Impact**: Straty czasowe, brak agregacji (np. mleko w 3 przepisach = 3 osobne pozycje)

#### Problem 3: Rozproszone przepisy
- **Realność**: 8/10 - Przepisy w notesach, książkach, internecie
- **Impact**: Trudność w znalezieniu sprawdzonego przepisu

### Walidacja problemu:

**Konkurencja na rynku**:
- **Mealime** (iOS/Android) - meal planning + shopping lists
- **Paprika** (iOS/Android/Desktop) - recipe manager + meal calendar
- **AnyList** (iOS) - shopping lists + recipes
- **Plan to Eat** (web) - meal planning calendar + auto shopping lists

**Wniosek**: Problem jest realny - istnieją komercyjne aplikacje rozwiązujące podobne problemy. To **waliduje potrzebę rynkową**.

### Ale... Czy Twoja grupa docelowa użyje webowej aplikacji?

**Persona z PRD**: Pary 50+, średnio zaawansowani technologicznie

**Ryzyko**:
- Grupa 50+ może preferować **aplikacje mobilne** (używają telefonu w sklepie)
- Web app na telefonie = gorsza UX niż native app
- **Rekomendacja**: Progressive Web App (PWA) - web app z możliwością instalacji na telefonie

### Wnioski:

✅ **Problem jest realny i wart rozwiązania**

✅ **Istnieje grupa docelowa gotowa płacić za rozwiązanie** (konkurencja komercyjna)

⚠️ **Ryzyko**: Grupa 50+ może mieć trudności z web app (preferują native apps)

🎯 **Rekomendacja**: Zbuduj MVP jako **PWA** (installable web app), nie tylko klasyczny website

---

## 2. Czy w aplikacji można skupić się na 1-2 kluczowych funkcjach?

### Ocena: 6/10 ⚠️ TAK, ale wymaga drastycznych uproszczeń

### Analiza zakresu z PRD:

**Pełne MVP z PRD zawiera**:
1. Autentykacja (rejestracja, logowanie, reset hasła, usunięcie konta)
2. CRUD przepisów (dodawanie, edycja, usuwanie, przeglądanie)
3. AI parsowanie składników (limit 20/miesiąc)
4. Kalendarz tygodniowy (7 dni × 4 posiłki = 28 slotów)
5. System szablonów tygodnia (template + instances)
6. Generowanie listy zakupów z agregacją składników
7. Grupowanie w kategorie (Nabiał, Warzywa, Owoce, etc.)
8. Edycja listy zakupów (dodawanie wolnych pozycji)
9. Odznaczanie produktów jako "kupione"
10. Eksport do PDF/TXT
11. Dashboard + nawigacja
12. Historia list zakupów

**To jest 12 features = ZA DUŻO dla 6 tygodni po godzinach!**

---

### Core Value Proposition:

**Najważniejsze pytanie**: Co jest KLUCZOWĄ wartością aplikacji?

**Odpowiedź**: **Automatyczne generowanie listy zakupów z przepisów w kalendarzu**

To oznacza, że **minimalne MVP** powinno zawierać:

### Minimal MVP (1-2 kluczowe funkcje):

#### Funkcja 1: Zarządzanie przepisami
- Dodawanie przepisu (nazwa + składniki **ręcznie** - bez AI)
- Lista przepisów
- Usuwanie przepisu

#### Funkcja 2: Generowanie listy zakupów
- Wybór przepisów (multi-select)
- Automatyczna agregacja składników
- Wyświetlenie listy z checkboxami

**Czas realizacji**: 2-3 tygodnie

---

### Extended MVP (3-4 funkcje):

Minimal MVP + 2 dodatkowe funkcje:

#### Funkcja 3: Prosty kalendarz
- Tydzień = 7 dni
- Przypisywanie przepisów do dni (bez podziału na posiłki - uproszczenie!)
- Generowanie listy zakupów z całego tygodnia

#### Funkcja 4: Autentykacja
- Rejestracja + logowanie (Supabase Auth)
- Każdy użytkownik widzi tylko swoje przepisy

**Czas realizacji**: 4-5 tygodni

---

### Full MVP (jak w PRD):

Extended MVP + wszystkie pozostałe funkcje (AI parsing, eksport PDF, system szablonów, historia list, etc.)

**Czas realizacji**: 8-12 tygodni (PONAD deadline!)

---

### Rekomendacja scoping:

Dla **6 tygodni po godzinach** realistyczny jest **Extended MVP**:

```
✅ Autentykacja (Supabase Auth - 2-3 dni)
✅ CRUD przepisów bez AI (ręczne dodawanie składników - 1 tydzień)
✅ Prosty kalendarz (bez podziału na 4 posiłki - 1-1.5 tygodnia)
✅ Generowanie listy zakupów z agregacją (1-1.5 tygodnia)
✅ Checkboxy "kupione" (2-3 dni)
✅ Responsive UI (mobile + desktop - przez cały projekt)
❌ AI parsowanie składników (ODŁOŻYĆ na v2)
❌ Eksport PDF/TXT (ODŁOŻYĆ na v2)
❌ System szablonów tygodnia (ODŁOŻYĆ na v2)
❌ Historia list zakupów (ODŁOŻYĆ na v2)
❌ 4 typy posiłków dziennie (START z 1 posiłkiem/dzień)
```

**Uproszczenia dla Extended MVP**:

1. **Kalendarz**: 7 dni × **1 posiłek** (nie 4) = 7 slotów (zamiast 28)
2. **Bez AI parsing**: Składniki dodawane **ręcznie** (można dodać AI w v2)
3. **Bez eksportu PDF**: Lista tylko w przeglądarce (można dodać PDF w v2)
4. **Brak systemu szablonów**: Tylko bieżący tydzień (można dodać szablony w v2)

---

### Wnioski:

✅ **TAK, można skupić się na 1-2 kluczowych funkcjach** (zarządzanie przepisami + generowanie listy)

⚠️ **ALE: Pełne MVP z PRD to 12 features - za dużo dla 6 tygodni**

🎯 **Rekomendacja**: Zbudować **Extended MVP** (4 kluczowe funkcje) w 6 tygodni, reszta w v2

---

## 3. Czy jestem w stanie wdrożyć ten pomysł w 6 tygodni pracując po godzinach z AI?

### Ocena: 9/10 ✅ TAK - projekt jest REALISTYCZNY dla Twojego profilu!

### Twój profil (z odpowiedzi):

**Doświadczenie**:
- ✅ **15 lat programowania** - senior developer
- ✅ **Angular + JavaScript** - solidne fundamenty frontend
- ✅ **Java EE** - backend experience (będzie pomocny przy Supabase)
- ✅ **PostgreSQL + MySQL** - znasz relacyjne bazy danych (OGROMNA zaleta!)
- ⚠️ **Brak doświadczenia**: Astro, Supabase, React 19, AI API (ale to nie problem z AI helper)

**Dostępność**:
- ✅ **30 godzin tygodniowo** - BARDZO DOBRY budżet czasowy!
- ✅ **Deadline**: 14 listopada 2025 (6 tygodni od dziś)
- ✅ **Pracujesz solo** z pomocą AI (Claude/Cursor)

**Oczekiwania**:
- ✅ **Uproszczona wersja MVP** (doskonałe podejście!)
- ✅ **Jako demo** (nie produkcja - mniejsza presja)
- ✅ **Responsive** (mobile + desktop)
- ✅ **Bez AI parsing** (oszczędność 12-16h)
- ✅ **Bez PDF export** (oszczędność 8-12h)

**Budżet czasowy**:
- 6 tygodni × 30h = **180 godzin TOTAL** 🎉

To jest **3× więcej** niż typowy developer po godzinach (60-90h)!

---

### Analiza czasochłonności (Extended MVP):

| Feature | Szacowany czas | Uwagi |
|---------|----------------|-------|
| **Setup projektu** | 4-6h | Astro + React + TypeScript + Tailwind + Supabase config |
| **Autentykacja** | 6-8h | Supabase Auth (rejestracja, logowanie, protected routes) |
| **CRUD przepisów** | 12-16h | Dodawanie, edycja, usuwanie, lista przepisów |
| **Formularz składników** | 6-8h | Dodawanie składników ręcznie (tabela z polami) |
| **Kalendarz tygodniowy** | 12-16h | Widok 7 dni, przypisywanie przepisów, desktop + mobile |
| **Generowanie listy** | 10-14h | Agregacja składników, sumowanie ilości, grupowanie w kategorie |
| **Checkboxy "kupione"** | 4-6h | Toggle checkbox + zapis stanu w DB |
| **UI/UX polish** | 8-12h | Responsywność, accessibility, empty states |
| **Testing + bugfixing** | 8-12h | Manualne testy, naprawianie bugów |
| **Deployment** | 2-4h | Wdrożenie na Vercel/Netlify + Supabase setup |
| **SUMA** | **72-102h** | **Średnio 87h** |

**Wniosek**: Extended MVP wymaga **72-102 godzin** (średnio 87h)

**Twój budżet**: **180 godzin** (30h × 6 tygodni) 🎉

**Werdykt**: ✅ **ŚWIETNIE! Masz 2× więcej czasu niż potrzeba!**

Z Twoim budżetem (180h) możesz zbudować Extended MVP (87h) i **zostanie Ci jeszcze 90h** na:
- Dodatkowe features (np. eksport TXT, 4 typy posiłków)
- Polish (lepszy UI/UX, animacje, transitions)
- Buffor na nieprzewidziane problemy
- Możliwość dodania AI parsing (jeśli znajdziesz free tier API)

---

### Pełne MVP z PRD (wszystkie 12 features):

| Dodatkowe features | Szacowany czas |
|-------------------|----------------|
| AI parsowanie składników | +12-16h (integracja API, prompt engineering, error handling) |
| Eksport PDF/TXT | +8-12h (jsPDF setup, formatowanie, testowanie) |
| System szablonów | +10-14h (template + instances, modal wyboru) |
| 4 typy posiłków | +8-10h (zmiana kalendarza z 7 do 28 slotów, UI complexity) |
| Historia list zakupów | +6-8h (dodatkowe widoki, query history) |
| **SUMA dodatkowa** | **+44-60h** |

**Pełne MVP TOTAL**: 87h + 55h = **142 godziny**

**Twój budżet**: 60-90 godzin

**Werdykt**: ❌ **NIEMOŻLIWE** - potrzebujesz 142h, masz 60-90h

---

### Analiza ryzyk czasowych:

#### Czynniki zwiększające czas:

1. **React 19 + Tailwind 4 (bleeding edge)** - +10-20% czasu (debugging niestabilnych wersji)
2. **Brak doświadczenia z Astro** - +20-30% czasu (learning curve)
3. **Brak doświadczenia z Supabase** - +10-15% czasu (learning RLS policies, Auth API)
4. **Problemy z AI API** (jeśli włączysz AI parsing) - +10-20% czasu (prompt engineering, rate limiting)
5. **Nieprzewidziane bugi** - +15-25% czasu (zawsze występują)

**Pesymistyczny scenariusz**: 87h × 1.7 = **148 godzin** (PONAD deadline!)

#### Czynniki zmniejszające czas:

1. **Pomoc AI** (Claude/Cursor) - -20-30% czasu (generowanie boilerplate, komponentów)
2. **Supabase BaaS** (gotowy backend) - -30-40% czasu (vs pisanie backend od zera)
3. **Shadcn/ui lub Mantine** (gotowe komponenty) - -10-15% czasu (vs pisanie UI od zera)
4. **Rezygnacja z AI parsing** - -12-16h
5. **Rezygnacja z PDF export** - -8-12h

**Optymistyczny scenariusz**: 87h × 0.6 = **52 godziny** (MOŻLIWE!)

---

### Wnioski:

✅ **Extended MVP (4 funkcje)** jest **możliwy w 6 tygodni** jeśli:
- Pracujesz **15h tygodniowo** (nie 10h)
- Używasz **stabilnych technologii** (React 18, Tailwind 3 - nie bleeding edge)
- **Rezygnujesz z AI parsing i PDF export** w MVP
- Używasz **gotowych komponentów UI** (Mantine/Shadcn)
- Masz pomoc AI (Claude/Cursor) dla przyspieszenia kodowania

❌ **Pełne MVP z PRD (12 funkcji)** jest **niemożliwy w 6 tygodni** po godzinach

🎯 **Rekomendacja**: **Extended MVP** z możliwością rozszerzenia w v2 (post-kurs)

---

## 4. Potencjalne trudności

### 4.1 Trudności techniczne (wysokie ryzyko)

#### Trudność 1: React 19 + Tailwind 4 (bleeding edge)

**Opis**: React 19 jest w fazie RC (Release Candidate), Tailwind 4 w alpha/beta

**Ryzyko**: 🔴 WYSOKIE
- Breaking changes przed finalnym wydaniem
- Bugi w nowych features (useOptimistic, useTransition)
- Ograniczona dokumentacja i przykłady
- Community support słabszy niż dla stabilnych wersji

**Impact**: +10-20% czasu (debugging, workarounds)

**Mitigacja**:
- ✅ **Użyć React 18 + Tailwind 3** (stabilne wersje)
- ✅ Upgrade do React 19/Tailwind 4 w v2 (po kursie)

---

#### Trudność 2: Astro + React hybryda (learning curve)

**Opis**: Astro to framework wymagający decyzji, kiedy używać .astro, a kiedy .tsx

**Ryzyko**: 🟡 ŚREDNIE (jeśli nie znasz Astro)

**Learning curve**:
- Rozumienie Islands Architecture (hydration: client:load, client:idle, etc.)
- Wiedza, kiedy używać Astro components (.astro) vs React (.tsx)
- Zarządzanie stanem między Astro a React

**Impact**: +20-30% czasu (jeśli brak doświadczenia z Astro)

**Mitigacja**:
- ✅ Alternatywa: **Next.js 14** (prostszy mental model, full React)
- ✅ Tutorial Astro (1-2 dni) przed startem projektu
- ✅ AI pomoże z boilerplate (Cursor/Claude zna Astro)

---

#### Trudność 3: Supabase RLS Policies (security)

**Opis**: Row Level Security (RLS) w Supabase wymaga pisania SQL policies

**Ryzyko**: 🟡 ŚREDNIE (jeśli brak doświadczenia z PostgreSQL)

**Złożoność**:
- Pisanie RLS policies w SQL (nie w TypeScript)
- Debugowanie permissions (trudne do zdiagnozowania błędy)
- Różne policies dla SELECT, INSERT, UPDATE, DELETE

**Przykład RLS policy**:
```sql
CREATE POLICY "Users can view their own recipes"
  ON recipes FOR SELECT
  USING (auth.uid() = user_id);
```

**Impact**: +10-15% czasu (jeśli brak doświadczenia z SQL)

**Mitigacja**:
- ✅ Dokumentacja Supabase jest dobra (przykłady RLS)
- ✅ AI pomoże z generowaniem RLS policies
- ✅ Zacząć od prostych policies (user_id check)

---

#### Trudność 4: AI parsowanie składników (jeśli włączysz)

**Opis**: Integracja z OpenAI/Anthropic API, prompt engineering

**Ryzyko**: 🔴 WYSOKIE (jeśli brak doświadczenia z AI API)

**Złożoność**:
- Prompt engineering (jak napisać prompt, żeby AI poprawnie rozpoznało składniki?)
- Error handling (co jeśli AI nie rozpozna składników?)
- Rate limiting (limit 20 parsowań/miesiąc na użytkownika)
- Koszty API (GPT-4 jest drogi)

**Impact**: +12-16h (integracja + testowanie + error handling)

**Mitigacja**:
- ✅ **REZYGNACJA z AI parsing w MVP** (największa oszczędność czasu!)
- ✅ Składniki dodawane **ręcznie** w MVP
- ✅ AI parsing w v2 (post-kurs)

---

#### Trudność 5: Eksport PDF (jeśli włączysz)

**Opis**: Generowanie PDF z listy zakupów (jsPDF/PDFKit)

**Ryzyko**: 🟡 ŚREDNIE

**Złożoność**:
- Konfiguracja jsPDF/PDFKit
- Formatowanie (checkboxy, kategorie, paginacja)
- Testowanie (czy PDF jest czytelny na wydruku?)

**Impact**: +8-12h

**Mitigacja**:
- ✅ **REZYGNACJA z PDF export w MVP** (oszczędność czasu!)
- ✅ Export TXT (prostsze, 2-3h) jako alternatywa
- ✅ PDF export w v2

---

### 4.2 Trudności projektowe (średnie ryzyko)

#### Trudność 6: Agregacja składników

**Opis**: Sumowanie składników z wielu przepisów (np. mleko 500ml + mleko 200ml = 700ml)

**Ryzyko**: 🟡 ŚREDNIE

**Złożoność**:
- Grupowanie po nazwie (lowercase matching: "Mleko" = "mleko")
- Sumowanie ilości (tylko jeśli jednostki są zgodne)
- Różne jednostki (1 szklanka vs 250ml - brak konwersji w MVP)

**Przykładowy kod**:
```typescript
// Grupowanie składników po nazwie
const grouped = ingredients.reduce((acc, ingredient) => {
  const key = ingredient.name.toLowerCase();
  if (!acc[key]) {
    acc[key] = { ...ingredient, quantity: 0 };
  }
  // Sumowanie tylko jeśli jednostki są zgodne
  if (acc[key].unit === ingredient.unit) {
    acc[key].quantity += ingredient.quantity;
  } else {
    // Różne jednostki - dodaj jako osobny składnik
    acc[`${key}_${ingredient.unit}`] = ingredient;
  }
  return acc;
}, {});
```

**Impact**: 4-6h (logika + testowanie)

**Mitigacja**:
- ✅ AI pomoże z logiką agregacji
- ✅ Zacząć od prostego matching (nazwa + jednostka)
- ✅ Konwersja jednostek w v2

---

#### Trudność 7: Responsywność (mobile + desktop)

**Opis**: Aplikacja musi działać na telefonie (grupa 50+ używa telefonu w sklepie)

**Ryzyko**: 🟡 ŚREDNIE

**Złożoność**:
- Kalendarz: desktop (tabela 7×4) vs mobile (akordeon)
- Nawigacja: desktop (menu poziome) vs mobile (hamburger menu)
- Formularze: duże przyciski (44px) dla touch
- Testowanie na różnych urządzeniach

**Impact**: +15-20% czasu (przez cały projekt)

**Mitigacja**:
- ✅ **Mobile-first approach** (projektuj najpierw dla mobile)
- ✅ Tailwind CSS (responsive utilities: sm:, md:, lg:)
- ✅ Testowanie na prawdziwym telefonie (nie tylko Chrome DevTools)

---

#### Trudność 8: Accessibility (WCAG 2.1 Level AA)

**Opis**: Aplikacja dla grupy 50+ wymaga wysokiej dostępności

**Ryzyko**: 🟡 ŚREDNIE

**Wymagania**:
- Keyboard navigation (Tab, Enter, Escape)
- Screen reader support (ARIA labels)
- Color contrast (min. 4.5:1)
- Duże czcionki (min. 16px body text)
- Duże przyciski (min. 44px wysokości)

**Impact**: +10-15% czasu (przez cały projekt)

**Mitigacja**:
- ✅ Używaj **semantic HTML** (nav, main, section, article)
- ✅ Gotowa biblioteka UI z a11y (Mantine, Radix UI)
- ✅ Lighthouse Accessibility audit (Google Chrome)

---

### 4.3 Trudności organizacyjne (niskie ryzyko)

#### Trudność 9: Scope creep

**Opis**: Pokusa dodawania nowych features w trakcie projektu

**Ryzyko**: 🟡 ŚREDNIE

**Problem**: "Może jeszcze dodam AI parsing?", "Może jeszcze zrobię eksport PDF?"

**Impact**: +20-40h (jeśli dodasz features mid-project)

**Mitigacja**:
- ✅ **Ścisły scope MVP** (lista features BEFORE start)
- ✅ Zapisz pomysły na v2 (nie implementuj w MVP)
- ✅ Deadline reminder (6 tygodni to niewiele!)

---

#### Trudność 10: Brak feedbacku od użytkowników

**Opis**: Budujesz aplikację bez walidacji z prawdziwymi użytkownikami (grupa 50+)

**Ryzyko**: 🟡 ŚREDNIE

**Problem**: Możesz zbudować coś, czego grupa docelowa nie będzie umiała używać

**Mitigacja**:
- ✅ **User testing** z 2-3 osobami 50+ (rodzice, znajomi)
- ✅ Proste UI (duże przyciski, czytelne czcionki)
- ✅ Onboarding hints ("Dodaj pierwszy przepis", "Zaplanuj tydzień")

---

### 4.4 Podsumowanie trudności

| Trudność | Ryzyko | Impact | Mitigacja |
|----------|--------|--------|-----------|
| React 19 + Tailwind 4 | 🔴 Wysokie | +10-20% czasu | Użyć React 18 + Tailwind 3 |
| Astro + React hybryda | 🟡 Średnie | +20-30% czasu | Tutorial Astro (1-2 dni) lub Next.js |
| Supabase RLS | 🟡 Średnie | +10-15% czasu | Dokumentacja + AI |
| AI parsing | 🔴 Wysokie | +12-16h | **ODŁOŻYĆ na v2** |
| PDF export | 🟡 Średnie | +8-12h | **ODŁOŻYĆ na v2** |
| Agregacja składników | 🟡 Średnie | 4-6h | AI pomoże |
| Responsywność | 🟡 Średnie | +15-20% czasu | Mobile-first + Tailwind |
| Accessibility | 🟡 Średnie | +10-15% czasu | Semantic HTML + UI library |
| Scope creep | 🟡 Średnie | +20-40h | Ścisły scope MVP |
| Brak user testing | 🟡 Średnie | N/A | Testing z 2-3 osobami 50+ |

---

## 5. Rekomendacje finalne

### 5.1 Zmodyfikowany scope MVP (REALISTYCZNY dla 6 tygodni)

**Nazwa**: GroceryList - Extended MVP

**Core features** (must-have):

1. ✅ **Autentykacja** (Supabase Auth)
   - Rejestracja + logowanie + wylogowanie
   - Protected routes (middleware)

2. ✅ **CRUD przepisów** (bez AI)
   - Dodawanie przepisu (nazwa + składniki ręcznie)
   - Lista przepisów (cards z nazwą)
   - Szczegóły przepisu (nazwa + składniki + pełny tekst)
   - Edycja przepisu
   - Usuwanie przepisu

3. ✅ **Prosty kalendarz tygodniowy**
   - 7 dni × **1 posiłek** = 7 slotów (nie 28!)
   - Przypisywanie przepisów do dni
   - Usuwanie przepisów z dni

4. ✅ **Generowanie listy zakupów**
   - Wybór przepisów z kalendarza (checkboxy)
   - Agregacja składników (sumowanie po nazwie + jednostce)
   - Grupowanie w kategorie (Nabiał, Warzywa, Owoce, Mięso, Inne)
   - Checkboxy "kupione" (toggle + zapis w DB)

5. ✅ **Responsywność**
   - Mobile + desktop
   - Duże przyciski (44px) dla grupy 50+
   - Czytelne czcionki (min. 16px)

**Excluded from MVP** (odłożyć na v2):

- ❌ AI parsowanie składników → składniki ręcznie
- ❌ Eksport PDF/TXT → tylko widok w przeglądarce
- ❌ System szablonów tygodnia → tylko bieżący tydzień
- ❌ 4 typy posiłków → START z 1 posiłkiem/dzień
- ❌ Historia list zakupów → tylko najnowsza lista
- ❌ Edycja listy zakupów (wolne pozycje) → tylko z przepisów

**Szacowany czas**: **52-72 godziny** (realny dla 6 tygodni po 12-15h/tydzień)

---

### 5.2 Zmodyfikowany tech stack (STABILNY)

**Proponowane zmiany** (względem PRD):

```yaml
Frontend:
  - Astro 5 ✅ (lub Next.js 14 jako alternatywa)
  - React 18 ⚠️ ZMIANA (zamiast React 19 - stabilność!)
  - TypeScript 5 ✅

Styling:
  - Tailwind CSS 3.x ⚠️ ZMIANA (zamiast 4 - stabilność!)
  - Mantine ⚠️ ZMIANA (zamiast Shadcn/ui - mniej konfiguracji)

Backend:
  - Supabase ✅

Deployment:
  - Vercel Adapter ⚠️ ZMIANA (zamiast Node.js - prostsze)
```

**Uzasadnienie**:
- React 18 + Tailwind 3 = stabilne, dojrzałe, doskonale udokumentowane
- Mantine = gotowe komponenty UI z accessibility out-of-the-box
- Vercel Adapter = prostsze wdrożenie (serverless)

---

### 5.3 Harmonogram 6-tygodniowy (Extended MVP)

#### Tydzień 1: Setup + Autentykacja (12-15h)
- Setup projektu (Astro/Next.js + React + TypeScript + Tailwind + Supabase)
- Konfiguracja Supabase (database, auth)
- Rejestracja + logowanie (Supabase Auth)
- Protected routes (middleware)
- Landing page + Dashboard

#### Tydzień 2: CRUD przepisów - część 1 (12-15h)
- Database schema (recipes, ingredients)
- Dodawanie przepisu (formularz: nazwa + składniki ręcznie)
- Lista przepisów (cards)
- Szczegóły przepisu

#### Tydzień 3: CRUD przepisów - część 2 (12-15h)
- Edycja przepisu
- Usuwanie przepisu
- Formularz składników (dodawanie, usuwanie wierszy)
- Walidacja (Zod schemas)

#### Tydzień 4: Kalendarz tygodniowy (12-15h)
- Database schema (calendar)
- Widok kalendarza (7 dni × 1 posiłek)
- Przypisywanie przepisów do dni
- Usuwanie przepisów z dni
- Responsive (desktop + mobile)

#### Tydzień 5: Lista zakupów (12-15h)
- Database schema (shopping_lists, shopping_list_items)
- Wybór przepisów z kalendarza (checkboxy)
- Agregacja składników (sumowanie)
- Grupowanie w kategorie
- Wyświetlenie listy

#### Tydzień 6: Polish + Deployment (12-15h)
- Checkboxy "kupione" (toggle + zapis w DB)
- UI/UX polish (empty states, loading states, error messages)
- Responsywność (testowanie na telefonie)
- Accessibility (keyboard navigation, ARIA labels)
- Deployment (Vercel + Supabase)

**TOTAL**: **72-90 godzin** (12-15h/tydzień)

---

### 5.4 Co zrobić jeśli braknie czasu?

**Fallback plan** (Minimal MVP):

Jeśli po 4 tygodniach widzisz, że nie nadążasz, **skup się na Minimal MVP**:

1. ✅ CRUD przepisów (ręczne składniki)
2. ✅ Wybór przepisów (multi-select)
3. ✅ Generowanie listy zakupów (agregacja + checkboxy)
4. ❌ Kalendarz → odłożyć na v2
5. ❌ Autentykacja → odłożyć na v2 (single-user app)

**Czas**: **40-50 godzin** (możliwe w 4 tygodnie)

---

## 6. Wnioski końcowe

### Ocena pomysłu: 7/10 ✅ DOBRY POMYSŁ

**Mocne strony**:
- ✅ Rozwiązuje realny problem (9/10)
- ✅ Istnieje grupa docelowa gotowa płacić
- ✅ Można zbudować MVP w 6 tygodni (z uproszczeniami)
- ✅ Dobry projekt portfolio dla kursu 10xDevs
- ✅ Możliwość rozbudowy w przyszłości (v2, v3)

**Słabe strony**:
- ⚠️ Pełne MVP z PRD (12 features) jest za duże dla 6 tygodni
- ⚠️ Grupa 50+ może preferować native app (nie web app)
- ⚠️ Konkurencja na rynku (Mealime, Paprika, AnyList)
- ⚠️ Proponowany tech stack (React 19, Tailwind 4) jest niestabilny

---

### Rekomendacja finalna: ✅ AKCEPTACJA Z MODYFIKACJAMI

**Zbuduj Extended MVP** (nie pełne MVP z PRD):

```
✅ Autentykacja (Supabase Auth)
✅ CRUD przepisów (ręczne składniki - bez AI)
✅ Prosty kalendarz (7 dni × 1 posiłek)
✅ Lista zakupów (agregacja + checkboxy)
✅ Responsive (mobile + desktop)
❌ AI parsing → v2
❌ PDF export → v2
❌ Szablony tygodnia → v2
❌ 4 typy posiłków → v2
```

**Tech stack** (stabilny):
- Astro 5 (lub Next.js 14) + React 18 + TypeScript 5 + Tailwind 3 + Mantine + Supabase

**Czas**: 6 tygodni × 12-15h = **72-90 godzin**

**Fallback**: Minimal MVP (CRUD + lista zakupów bez kalendarza) jeśli braknie czasu

---

### Następne kroki:

1. ✅ **Zaakceptuj zmodyfikowany scope** (Extended MVP)
2. ✅ **Zmień tech stack** (React 18 + Tailwind 3)
3. ✅ **Setup projektu** (tydzień 1)
4. ✅ **Trzymaj się harmonogramu** (6 tygodni)
5. ✅ **User testing** (2-3 osoby 50+ po 4 tygodniach)
6. ✅ **Deployment** (tydzień 6)
7. ✅ **Prezentacja na kursie 10xDevs** 🎉

---

### Pytanie do Ciebie:

**Czy jesteś gotów zaakceptować Extended MVP (4 kluczowe funkcje) i odłożyć resztę na v2?**

Jeśli TAK → START projektu! 🚀

Jeśli NIE → Przedyskutujmy, które features są dla Ciebie must-have i jak zmodyfikować scope.

---

Dokument przygotowany: 2025-10-15
Autor: Claude Code Analysis Team
Kontekst: Kurs 10xDevs, analiza wykonalności projektu GroceryList
