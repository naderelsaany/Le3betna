# Original User Request

## Initial Request — 2026-07-04T22:07:29+03:00

إجراء مراجعة برمجية شاملة وإصلاح مباشر (Auto-Fix) لمنطق الألعاب (Ludo, Connect4, Domino) في مشروع Le3betna لاكتشاف أي ثغرات أو أخطاء برمجية أو مشاكل في التزامن.

Working directory: `/c/Users/naderelsadany/Desktop/Le3betna/game_app`
Integrity mode: benchmark

## Requirements

### R1. إصلاح منطق الألعاب والثغرات
تحليل وتعديل ملفات `game-logic` والـ `hooks` لضمان الحماية ضد حالات الـ Race Conditions والتلاعب وحل أي ثغرات محتملة.

### R2. إصلاح واجهة المستخدم والـ State
حل أي مشاكل في الـ UI تعيق التزامن السليم مع حالة الـ Backend وتقليل الـ Re-renders غير الضرورية باستخدام التقنيات المناسبة (e.g. `React.memo`, `useMemo`).

### R3. توافق الـ Firebase
التأكد من أن الأكواد المعدلة تتواصل بكفاءة وأمان مع قاعدة بيانات Firebase (Realtime Database & Firestore).

## Acceptance Criteria

### Verification & Testing
- [ ] أمر `npm run build` ينتهي بنجاح (Exit code 0) بدون أي أخطاء TypeScript أو Linting بعد إجراء التعديلات.
- [ ] عدم وجود أكواد متكررة أو غير مستخدمة بناءً على مبادئ (DRY/SOLID) وقواعد `Clean Code`.
- [ ] إصلاح أي أخطاء متعلقة بمنطق الألعاب بشكل كامل داخل الكود بدلاً من كتابة ملاحظات فقط.
