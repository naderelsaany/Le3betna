## 2026-07-04T19:12:13Z
You are teamwork_preview_worker. Your working directory is C:\Users\naderelsadany\Desktop\Le3betna\.agents\worker_fixes.

DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.

Your task is to fix the bugs, logical flaws, UI state issues, and security vulnerabilities across Ludo, Connect4, and Domino games in `game_app`.

Please read the following explorer reports carefully:
1. Ludo Explorer: C:\Users\naderelsadany\Desktop\Le3betna\.agents\explorer_ludo\handoff.md
2. Connect4 Explorer: C:\Users\naderelsadany\Desktop\Le3betna\.agents\explorer_connect4\handoff.md
3. Domino Explorer: C:\Users\naderelsadany\Desktop\Le3betna\.agents\explorer_domino\handoff.md

Tasks:
1. Connect4:
   - Fix the test failure in `src/game-logic/connect4.test.ts` (empty cells are 0, not null). Run tests via `npx tsx src/game-logic/connect4.test.ts` to verify they pass.
   - Fix the room status finished deadlock: Update room status to "finished" inside the same Firebase transaction that updates the board/winner, rather than after.
   - Fix stale rematch votes by ensuring `rematchVotes` are cleared in `leaveRoom` (`src/hooks/useGameRoom.ts`).
   - Fix spectator colors and interactivity in `src/components/game/Connect4Board.tsx` (ensure spectators are recognized as `myColor === undefined`, don't show "You" or active game buttons for them).
   - Address starting player bias when rematching (e.g. alternate or random starter).

2. Domino:
   - Fix side placement check in `src/game-logic/domino.ts` (ensure piece actually matches the end it's being placed on).
   - Fix state mutation bugs by deep copying `hands` and `boneyard` in `drawPiece` and `dealNewRound` in `src/game-logic/domino.ts`.
   - Fix block (قفلة) logic to loop over all active players in `turnOrder` rather than assuming 2 or 4 players.
   - Fix teammate victory UI text: In 4-player team games, show victory screen to both partners if either wins.

3. Ludo:
   - Fix client-side dice generation cheat: Generate the random dice value inside the transaction function in `src/hooks/useLudo.ts`, rather than on the client before the transaction.
   - Fix overlapping pieces in `src/components/game/LudoBoard.tsx` by applying a coordinate offset to pieces standing on the exact same square.
   - Fix blockade bypass: Implement path/destination checking against enemy blockades in `src/game-logic/ludo.ts`.
   - Fix the 3-sixes penalty: Check and apply the penalty immediately when a 6 is rolled (in `useLudo.ts` transaction), ending the turn immediately if it's the 3rd consecutive six, instead of waiting for them to move a piece first.
   - Fix room finished deadlock: Update the room status to "finished" in the movement transaction.

4. Performance & General:
   - Verify React components are optimized and unnecessary re-renders are mitigated (using React.memo/useMemo where appropriate).
   - Ensure the code complies with typescript and linting rules. Run `npm run build` and ensure it completes successfully (Exit code 0) without any errors.

Write a handoff report at C:\Users\naderelsadany\Desktop\Le3betna\.agents\worker_fixes\handoff.md describing all code changes and showing build/test results.
