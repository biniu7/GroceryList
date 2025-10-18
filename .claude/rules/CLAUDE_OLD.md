# AI Rules for GroceryList

GroceryList is an MVP application for creating grocery shopping lists based on recipes assigned to specific days and meals (breakfast, second breakfast, lunch, dinner). The app features a weekly calendar, recipe management, and PDF/TXT export functionality.


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


### Guidelines for VERSION_CONTROL

#### GIT

- Use conventional commits to create meaningful commit messages
- Use feature branches with descriptive names following {{branch_naming_convention}}
- Write meaningful commit messages that explain why changes were made, not just what
- Keep commits focused on single logical changes to facilitate code review and bisection
- Use interactive rebase to clean up history before merging feature branches
- Leverage git hooks to enforce code quality checks before commits and pushes

## FRONTEND

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


### Guidelines for ASTRO

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

## BACKEND

### Guidelines for NODE

#### EXPRESS

- Use express-async-errors or wrap async route handlers in try/catch blocks to properly handle promise rejections and prevent server crashes
- Implement middleware for cross-cutting concerns like logging, error handling, and authentication following the chain-of-responsibility pattern
- Use helmet middleware to enhance API security with appropriate HTTP headers for {{security_requirements}}
- Structure routes using the Router class and organize by resource or feature to maintain a clean separation of concerns
- Implement rate limiting for public endpoints to prevent abuse and DoS attacks on {{critical_endpoints}}
- Use environment-specific configuration with dotenv and never hardcode sensitive values like {{database_credentials}} or API keys

#### NEST

- Use dependency injection for services to improve testability and maintainability following SOLID principles
- Implement custom decorators for cross-cutting concerns to keep code DRY and maintain separation of business logic
- Use interceptors for transforming the response data structure consistently for {{api_standards}}
- Leverage NestJS Guards for authorization to centralize access control logic across {{protected_resources}}
- Implement domain-driven design with modules that encapsulate related functionality and maintain clear boundaries
- Use TypeORM or Mongoose with repository patterns to abstract database operations and simplify testing with mocks

#### FASTIFY

- Use the schema validation feature with JSON Schema to validate request and response payloads for {{api_endpoints}}
- Implement the plugin system for modularizing application components and enabling code reuse across projects
- Use fastify-swagger for automatic API documentation generation based on your schema definitions
- Leverage the hooks system (onRequest, preHandler, onSend) for precise control over the request lifecycle
- Use the reply.send() method consistently and avoid mixing with return statements to prevent hard-to-debug issues
- Implement proper error handling with custom error classes and the setErrorHandler hook for {{error_types}}

## DATABASE

### Guidelines for SQL

#### POSTGRES

- Use connection pooling to manage database connections efficiently
- Implement JSONB columns for semi-structured data instead of creating many tables for {{flexible_data}}
- Use materialized views for complex, frequently accessed read-only data

