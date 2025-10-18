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


## FRONTEND

### Guidelines for ASTRO

#### ASTRO_CODING_STANDARDS

- Use Astro components (.astro) for static content and layout
- Implement framework components in {{framework_name}} only when interactivity is needed
- Leverage View Transitions API for smooth page transitions
- Use content collections with type safety for blog posts, documentation, etc.
- Implement middleware for request/response modification
- Use image optimization with the Astro Image integration
- Leverage Server Endpoints for API routes
- Implement hybrid rendering with server-side rendering where needed
- Use Astro.cookies for server-side cookie management
- Leverage import.meta.env for environment variables

#### ASTRO_ISLANDS

- Use client:visible directive for components that should hydrate when visible in viewport
- Implement shared state with nanostores instead of prop drilling between islands
- Use content collections for type-safe content management of structured content
- Leverage client:media directive for components that should only hydrate at specific breakpoints
- Implement partial hydration strategies to minimize JavaScript sent to the client
- Use client:only for components that should never render on the server
- Leverage client:idle for non-critical UI elements that can wait until the browser is idle
- Implement client:load for components that should hydrate immediately
- Use Astro's transition:* directives for view transitions between pages
- Leverage props for passing data from Astro to framework components


### Guidelines for REACT

#### REACT_CODING_STANDARDS

- Use functional components with hooks instead of class components
- Implement React.memo() for expensive components that render often with the same props
- Utilize React.lazy() and Suspense for code-splitting and performance optimization
- Use the useCallback hook for event handlers passed to child components to prevent unnecessary re-renders
- Prefer useMemo for expensive calculations to avoid recomputation on every render
- Implement useId() for generating unique IDs for accessibility attributes
- Use the new use hook for data fetching in React 19+ projects
- Leverage Server Components for {{data_fetching_heavy_components}} when using React with Next.js or similar frameworks
- Consider using the new useOptimistic hook for optimistic UI updates in forms
- Use useTransition for non-urgent state updates to keep the UI responsive

#### REACT_ROUTER

- Use createBrowserRouter instead of BrowserRouter for better data loading and error handling
- Implement lazy loading with React.lazy() for route components to improve initial load time
- Use the useNavigate hook instead of the navigate component prop for programmatic navigation
- Leverage loader and action functions to handle data fetching and mutations at the route level
- Implement error boundaries with errorElement to gracefully handle routing and data errors
- Use relative paths with dot notation (e.g., "../parent") to maintain route hierarchy flexibility
- Utilize the useRouteLoaderData hook to access data from parent routes
- Implement fetchers for non-navigation data mutations
- Use route.lazy() for route-level code splitting with automatic loading states
- Implement shouldRevalidate functions to control when data revalidation happens after navigation

#### REACT_QUERY

- Use TanStack Query (formerly React Query) with appropriate staleTime and gcTime based on data freshness requirements
- Implement the useInfiniteQuery hook for pagination and infinite scrolling
- Use optimistic updates for mutations to make the UI feel more responsive
- Leverage queryClient.setQueryDefaults to establish consistent settings for query categories
- Use suspense mode with <Suspense> boundaries for a more declarative data fetching approach
- Implement retry logic with custom backoff algorithms for transient network issues
- Use the select option to transform and extract specific data from query results
- Implement mutations with onMutate, onError, and onSettled for robust error handling
- Use Query Keys structuring pattern ([entity, params]) for better organization and automatic refetching
- Implement query invalidation strategies to keep data fresh after mutations


### Guidelines for STYLING

#### TAILWIND

- Use the @layer directive to organize styles into components, utilities, and base layers
- Implement Just-in-Time (JIT) mode for development efficiency and smaller CSS bundles
- Use arbitrary values with square brackets (e.g., w-[123px]) for precise one-off designs
- Leverage the @apply directive in component classes to reuse utility combinations
- Implement the Tailwind configuration file for customizing theme, plugins, and variants
- Use component extraction for repeated UI patterns instead of copying utility classes
- Leverage the theme() function in CSS for accessing Tailwind theme values
- Implement dark mode with the dark: variant
- Use responsive variants (sm:, md:, lg:, etc.) for adaptive designs
- Leverage state variants (hover:, focus:, active:, etc.) for interactive elements

## CODING_PRACTICES

### Guidelines for SUPPORT_LEVEL

#### SUPPORT_BEGINNER

- When running in agent mode, execute up to 3 actions at a time and ask for approval or course correction afterwards.
- Write code with clear variable names and include explanatory comments for non-obvious logic. Avoid shorthand syntax and complex patterns.
- Provide full implementations rather than partial snippets. Include import statements, required dependencies, and initialization code.
- Add defensive coding patterns and clear error handling. Include validation for user inputs and explicit type checking.
- Suggest simpler solutions first, then offer more optimized versions with explanations of the trade-offs.
- Briefly explain why certain approaches are used and link to relevant documentation or learning resources.
- When suggesting fixes for errors, explain the root cause and how the solution addresses it to build understanding. Ask for confirmation before proceeding.
- Offer introducing basic test cases that demonstrate how the code works and common edge cases to consider.

### Guidelines for ARCHITECTURE

#### CLEAN_ARCHITECTURE

- Strictly separate code into layers: entities, use cases, interfaces, and frameworks
- Ensure dependencies point inward, with inner layers having no knowledge of outer layers
- Implement domain entities that encapsulate {{business_rules}} without framework dependencies
- Use interfaces (ports) and implementations (adapters) to isolate external dependencies
- Create use cases that orchestrate entity interactions for specific business operations
- Implement mappers to transform data between layers to maintain separation of concerns


### Guidelines for STATIC_ANALYSIS

#### ESLINT

- Configure project-specific rules in eslint.config.js to enforce consistent coding standards
- Use shareable configs like eslint-config-airbnb or eslint-config-standard as a foundation
- Implement custom rules for {{project_specific_patterns}} to maintain codebase consistency
- Configure integration with Prettier to avoid rule conflicts for code formatting
- Use the --fix flag in CI/CD pipelines to automatically correct fixable issues
- Implement staged linting with husky and lint-staged to prevent committing non-compliant code

#### PRETTIER

- Define a consistent .prettierrc configuration across all {{project_repositories}}
- Configure editor integration to format on save for immediate feedback
- Use .prettierignore to exclude generated files, build artifacts, and {{specific_excluded_patterns}}
- Set printWidth based on team preferences (80-120 characters) to improve code readability
- Configure consistent quote style and semicolon usage to match team conventions
- Implement CI checks to ensure all committed code adheres to the defined style
