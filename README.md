# GroceryList

A web application for creating grocery shopping lists based on recipes assigned to a weekly calendar. Designed for couples aged 50-60 who plan meals weekly and want to reduce shopping time by 80%.

## Table of Contents

- [Project Description](#project-description)
- [Tech Stack](#tech-stack)
- [Getting Started Locally](#getting-started-locally)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## Project Description

GroceryList is an MVP application that solves the time-consuming problem of manually creating shopping lists from multiple recipes. The app enables users to:

- Centralize recipe management in one place
- Plan meals on a weekly calendar with 4 meal types per day (breakfast, second breakfast, lunch, dinner)
- Automatically generate shopping lists with aggregated ingredients from selected meals
- Export lists to PDF/TXT for convenient shopping

**Key Benefits:**
- Reduces shopping list creation time from 30-60 minutes to 5-10 minutes (80% reduction)
- Eliminates forgotten ingredients by 90%
- Provides a simple, accessible interface optimized for users aged 50+

**Target Users:** Couples aged 50-60 who plan meals weekly, shop once per week at discount stores, and cook daily from a rotating set of favorite recipes.

## Tech Stack

### Frontend
- **[Astro 5](https://astro.build/)** - SSR framework with hybrid rendering and islands architecture
- **[React 19](https://react.dev/)** - Interactive components using islands architecture
- **[TypeScript 5](https://www.typescriptlang.org/)** - Type safety and developer experience

### Stylininstall
g
- **[Tailwind CSS 4](https://tailwindcss.com/)** - Utility-first CSS framework with Vite plugin
- **[Shadcn/ui](https://ui.shadcn.com/)** - Accessible UI component library (New York style)
- **[Radix UI](https://www.radix-ui.com/)** - Unstyled, accessible component primitives

### Backend & Services
- **[Supabase](https://supabase.com/)** - Backend-as-a-Service
  - PostgreSQL database
  - Authentication (email + password)
  - Row Level Security (RLS)
  - EU region hosting (RODO/GDPR compliant)

### AI Integration
- **OpenAI GPT-4 API** or **Anthropic Claude API** - Automatic ingredient parsing from recipe text (20 recipes/month limit)

### Export
- **jsPDF** or **PDFKit** - PDF generation
- Plain text formatting - TXT export

### Deployment
- **Vercel** or **Netlify** - Application hosting
- **Supabase Cloud** - Managed database (EU region)
- **@astrojs/node** - Standalone server adapter

### Development Tools
- **ESLint** - Code linting with TypeScript, React, and accessibility rules
- **Prettier** - Code formatting with Astro plugin
- **Husky** - Git hooks for pre-commit checks
- **lint-staged** - Run linters on staged files

## Getting Started Locally

### Prerequisites

- **Node.js**: Version 22.14.0 (use `nvm use` to automatically switch to the correct version)
- **npm**: Comes with Node.js
- **Supabase account**: Create a free account at [supabase.com](https://supabase.com)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/GroceryList.git
   cd GroceryList
   ```

2. **Install Node.js version**
   ```bash
   nvm use
   # This will use Node.js 22.14.0 specified in .nvmrc
   ```

3. **Install dependencies**
   ```bash
   npm install
   ```

4. **Configure environment variables**

   Create a `.env` file in the root directory:
   ```env
   # Supabase
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_KEY=your_supabase_anon_key

   # AI API (choose one)
   OPENAI_API_KEY=your_openai_api_key
   # OR
   ANTHROPIC_API_KEY=your_anthropic_api_key
   ```

   Get your Supabase credentials from your project settings at [app.supabase.com](https://app.supabase.com)

5. **Run the development server**
   ```bash
   npm run dev
   ```

   Open [http://localhost:4321](http://localhost:4321) in your browser.

### Database Setup

1. Navigate to your Supabase project dashboard
2. Run the SQL migrations from `/supabase/migrations` (if available)
3. Configure Row Level Security (RLS) policies for user data isolation

## Available Scripts

| Script | Description |
|--------|-------------|
| `npm run dev` | Start development server on port 4321 with hot reload |
| `npm run build` | Build the application for production |
| `npm run preview` | Preview the production build locally |
| `npm run astro` | Run Astro CLI commands |
| `npm run lint` | Run ESLint to check for code issues |
| `npm run lint:fix` | Automatically fix ESLint issues |
| `npm run format` | Format code with Prettier |

### Git Hooks

Pre-commit hooks are configured via Husky and lint-staged:
- Automatically runs ESLint on `.ts`, `.tsx`, `.astro` files
- Automatically formats `.json`, `.css`, `.md` files with Prettier

## Project Scope

### In Scope (MVP Features)

✅ **Recipe Management**
- CRUD operations for recipes (text-based)
- AI-powered ingredient parsing from recipe text (limit: 20 recipes/month)
- Manual ingredient editing and management
- Recipe categorization

✅ **Weekly Calendar & Meal Planning**
- Calendar view for 7 days with 4 meal types per day
- Template-based week system (repeating meal patterns)
- Assign recipes to specific days and meals
- Desktop (table view) and mobile (accordion view) layouts

✅ **Shopping List Generation**
- Generate shopping lists from selected calendar meals
- Automatic ingredient aggregation (sum quantities)
- Category-based grouping (dairy, vegetables, meat, etc.)
- Manual editing (add/remove items, change quantities)
- Mark items as "purchased" with checkboxes
- Shopping list history

✅ **Export Functionality**
- Export to PDF with clean, printable layout
- Export to TXT for simple text format
- Include checkboxes for marking items during shopping

✅ **User Features**
- Simple authentication (email + password via Supabase)
- Account management (registration, login, password reset, account deletion)
- Responsive UI optimized for ages 50+ (large buttons, high contrast, clear CTAs)
- WCAG 2.1 Level AA accessibility compliance

### Out of Scope (Post-MVP)

❌ Recipe imports from files (JPG, PDF, DOCX)
❌ Native mobile apps (iOS/Android)
❌ Recipe sharing between users
❌ External shopping service integrations (Glovo, Frisco)
❌ Multi-language support (Polish only in MVP)
❌ Monthly/yearly calendar views
❌ Notifications (email, SMS, push)
❌ Advanced search/filtering
❌ Voice assistant integration
❌ Diet/allergy management
❌ Calendar integration (Google Calendar, iCal)
❌ Multiple recipes per meal
❌ OAuth providers (Google, Facebook login)
❌ Automatic unit conversions
❌ Recipe photos

## Project Status

### Current Phase: **Foundation & Setup**

The project is in active development following a 4-phase roadmap:

#### Phase 1: Foundation & Recipe Management (2-3 weeks)
- [x] Project setup (Astro + React + TypeScript + Tailwind)
- [ ] Supabase configuration (database, authentication)
- [ ] User authentication system
- [ ] Dashboard with navigation tiles
- [ ] Recipe CRUD operations
- [ ] AI ingredient parsing integration
- [ ] Parsing limit enforcement (20/month)

#### Phase 2: Calendar & Meal Planning (2-3 weeks)
- [ ] Weekly calendar view (desktop & mobile)
- [ ] Template-based week system
- [ ] Recipe assignment flow with checkboxes
- [ ] "Instance vs Template" modal logic
- [ ] Display assigned recipes in calendar
- [ ] Remove recipes from calendar

#### Phase 3: Shopping List Generation (1-2 weeks)
- [ ] Generate list from selected meals
- [ ] Ingredient aggregation (sum quantities)
- [ ] Category-based grouping
- [ ] Save lists to database
- [ ] Edit lists (add/remove items, change quantities)
- [ ] Mark items as "purchased"
- [ ] Shopping list history

#### Phase 4: Export & Polish (1 week)
- [ ] PDF export
- [ ] TXT export
- [ ] UI polish (icons, colors, spacing)
- [ ] Accessibility improvements
- [ ] Performance optimization
- [ ] Bug fixes

**Timeline:** 6-9 weeks to full MVP

### Success Metrics (MVP Goals)

- **WAU**: 50+ weekly active users after 8 weeks
- **Engagement**: 3-4 shopping lists per user per month
- **Adoption**: 10+ recipes per user
- **Retention**: 40%+ users active after 30 days
- **NPS**: 50+ points
- **Performance**: < 2 second page load (Lighthouse 90+)
- **Accessibility**: WCAG 2.1 Level AA compliance

### Infrastructure Costs

- **MVP (100 users)**: ~$1.50/month
  - Supabase: Free tier
  - AI API (GPT-3.5): $1.50
  - Hosting (Vercel): Free tier

- **Post-MVP (1000 users)**: ~$60/month
  - Supabase: $25 (Pro tier)
  - AI API: $15
  - Hosting: $20 (Pro tier)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Version:** 0.0.1
**Last Updated:** 2025-10-16
**Status:** In Development

For questions or support, please open an issue in the GitHub repository.
