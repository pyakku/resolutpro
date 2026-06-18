# P3 Audit — React Migration

## What This App Is
Enterprise compliance & audit management platform. Migrating from FlutterFlow to React.
Live Flutter app: https://app.p3audit.com

## Stack
- React 18 + TypeScript (strict mode)
- Vite (build tool)
- React Router v6 (routing)
- Zustand (global state)
- TanStack Query v5 (server state + caching)
- Axios (HTTP client)
- Tailwind CSS (styling)
- React Hook Form + Zod (forms + validation)
- Recharts (charts)
- Framer Motion (animations)
- i18next (8 languages)

## Backend
- API base URL: `https://xjno-rqiq-2v6x.n7.xano.io/api:_nmR0lo4`
- Auth: JWT Bearer token
- AI: Google Gemini 1.5 (document extraction + assessment generation)
- All apis to be created inside this group - `resolut_apis` - `https://xjno-rqiq-2v6x.n7.xano.io/api:_nmR0lo4`

## Commands
```bash
npm run dev       # start dev server
npm run build     # production build
npm run test      # Vitest unit tests
npm run lint      # ESLint
npm run format    # Prettier
```

## Brand Tokens
- `#1d2428` — primary dark (nav, headers)
- `#5e90c0` — primary light (CTAs, links)
- `#D5E8F0` — light blue (Accents)
- `#000000` - black (Texts)

## Rules
- See Rules/components.md — component patterns
- See Rules/api.md — API & data fetching
- See Rules/auth.md — auth & RBAC
- See Rules/forms.md — forms & validation
- See Rules/state.md — state management
