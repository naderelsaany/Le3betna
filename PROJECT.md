# Project: Le3betna Game Logic Review and Auto-Fixing

## Architecture
- React Frontend (Next.js 15, Zustand, Tailwind)
- Firebase Realtime Database & Firestore for game state sync, presence, and chat.
- game-logic/ containing pure logic for Ludo, Connect4, Domino.
- hooks/ (useLudo, useConnect4, useDomino, useGameEngine, useGameRoom) connecting UI to Firebase.

## Milestones
| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| 1 | Exploration & Test Suite Setup | Run initial review of Ludo, Connect4, Domino logic & hooks; configure basic validation tests. | none | IN_PROGRESS |
| 2 | Ludo Logic & Hook Fixes | Fix Ludo rules, token movements, dice rolls, Firebase sync, and potential cheats. | M1 | PLANNED |
| 3 | Connect4 Logic & Hook Fixes | Fix Connect4 column placing, win check, Firebase transactions, and synchronization. | M1 | PLANNED |
| 4 | Domino Logic & Hook Fixes | Fix Domino matching, drawing, valid moves, blocking, and Firebase sync. | M1 | PLANNED |
| 5 | UI & React Performance | Optimize hooks and components to reduce re-renders (useMemo, React.memo, useCallback). | M2, M3, M4 | PLANNED |
| 6 | E2E / Integration Verification | Run final npm run build and lint checks, verify game play flows. | M5 | PLANNED |

## Interface Contracts
### UI ↔ Game Logic Hooks
- Hooks must expose clear methods: `makeMove`, `resetGame`, `rollDice` (Ludo), `playTile`/`drawTile` (Domino).
- State must only update React-side state via Zustand / local state after/during Firebase sync, using Firebase as the source of truth to prevent split-brain state.
