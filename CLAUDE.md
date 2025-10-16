# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GroceryList is an MVP application for creating grocery shopping lists based on recipes assigned to specific days and meals (breakfast, second breakfast, lunch, dinner). The app features a weekly calendar, recipe management, and PDF/TXT export functionality.

## Tech Stack

- **Astro 5** - Server-side rendered framework with hybrid rendering
- **React 19** - For interactive components only
- **TypeScript 5** - Strict type safety
- **Tailwind CSS 4** - Utility-first styling with Vite plugin
- **Shadcn/ui** - UI component library (New York style)
- **Supabase** - Backend services, authentication, and database
- **Node.js Adapter** - Standalone server mode

## Development Commands

```bash
# Development
npm run dev              # Start dev server on port 3000
npm run build            # Build for production
npm run preview          # Preview production build

# Code Quality
npm run lint             # Run ESLint
npm run lint:fix         # Fix ESLint issues automatically
npm run format           # Format with Prettier

# Git hooks via husky and lint-staged are configured
```

## Project Structure

```
./src
├── layouts/           # Astro layouts
├── pages/             # Astro pages (routes)
│   └── api/           # API endpoints (use export const prerender = false)
├── middleware/        # Astro middleware (Supabase client injection)
├── db/                # Supabase clients and database types
├── types.ts           # Shared types (Entities, DTOs)
├── components/        # Static Astro & interactive React components
│   ├── ui/            # Shadcn/ui components
│   └── hooks/         # Custom React hooks
├── lib/               # Services and utility functions
│   └── utils.ts       # cn() utility for class merging
├── styles/            # Global CSS (global.css for Tailwind)
├── assets/            # Internal static assets
└── env.d.ts           # TypeScript environment definitions

./public               # Public assets (served as-is)
```

## Architecture Patterns

### Frontend Component Strategy

- **Astro components (.astro)** - Default choice for static content and layouts
- **React components (.tsx)** - Only when interactivity is needed
- Never use "use client" directives (Next.js-specific, not applicable in Astro)
- Use `client:load`, `client:idle`, or `client:visible` directives in Astro for React hydration

### API Endpoints

- Use uppercase HTTP methods: `export async function GET()`, `export async function POST()`
- Always add `export const prerender = false` for API routes
- Validate inputs with Zod schemas
- Extract business logic into services in `src/lib/services`
- Access Supabase via `context.locals.supabase`, not direct imports

### Database & Backend

- Use the `SupabaseClient` type from `src/db/supabase.client.ts`, not from `@supabase/supabase-js`
- Supabase client is injected via middleware into `context.locals`
- Database types are generated in `src/db/database.types.ts`
- Environment variables: `SUPABASE_URL` and `SUPABASE_KEY`

### Styling Approach

- Tailwind 4 with CSS variables for theming
- Use `cn()` utility from `@/lib/utils` for conditional class merging
- Leverage arbitrary values: `w-[123px]`, `text-[#1da1f2]`
- Responsive variants: `sm:`, `md:`, `lg:`, `xl:`, `2xl:`
- State variants: `hover:`, `focus-visible:`, `active:`, `disabled:`
- Dark mode support via `dark:` variant

### Path Aliases

TypeScript paths configured with `@/` prefix:
- `@/components` → `./src/components`
- `@/lib` → `./src/lib`
- `@/lib/utils` → `./src/lib/utils`

## Coding Standards

### Error Handling

- Prioritize error handling at the beginning of functions
- Use early returns for error conditions (guard clauses)
- Avoid deeply nested if statements
- Place happy path last for readability
- Avoid unnecessary else statements; use if-return pattern
- Implement user-friendly error messages

### React Best Practices

- Functional components with hooks only (no class components)
- Extract logic into custom hooks in `src/components/hooks`
- Use `React.memo()` for expensive components with stable props
- Use `React.lazy()` and `Suspense` for code-splitting
- Use `useCallback` for event handlers passed to children
- Use `useMemo` for expensive calculations
- Use `useId()` for accessibility attribute IDs
- Use `useOptimistic` for optimistic UI updates
- Use `useTransition` for non-urgent state updates

### Astro Specific

- Leverage View Transitions API with ClientRouter
- Use content collections with type safety for structured content
- Implement middleware for request/response modification
- Use `Astro.cookies` for server-side cookie management
- Access environment variables via `import.meta.env`
- Use image optimization with Astro Image integration

### Accessibility (ARIA)

- Use ARIA landmarks for page regions
- Set `aria-expanded` and `aria-controls` for expandable content
- Use `aria-live` regions with appropriate politeness for dynamic updates
- Apply `aria-hidden` for decorative content
- Use `aria-label` or `aria-labelledby` for elements without visible labels
- Use `aria-describedby` for descriptive text associations
- Implement `aria-current` for current item indication
- Avoid redundant ARIA that duplicates native HTML semantics

### Linting & Formatting

- ESLint configured with TypeScript strict rules, React compiler plugin, jsx-a11y
- Prettier with Astro plugin for formatting
- `no-console` warnings enforced (use proper logging in production)
- React hooks rules enforced
- Husky pre-commit hooks run lint-staged automatically

## MVP Scope (from prd.md)

**In scope:**
- Recipe CRUD operations (text-based)
- Weekly calendar with meal assignment (breakfast, second breakfast, lunch, dinner)
- Automatic ingredient list extraction during recipe creation
- User accounts (simple authentication)
- Shopping list generation from selected recipes/meals
- Export to PDF/TXT
- Responsive UI (mobile & desktop)

**Out of scope:**
- Recipe imports from files (JPG, PDF, DOCX)
- Native mobile apps
- Recipe sharing between users
- External shopping service integrations
- Multi-language support (Polish only)
- Advanced meal planning features
- Notifications
- Diet/allergy management
