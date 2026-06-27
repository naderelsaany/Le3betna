# 🎮 لعبتنا — خطة تنفيذ شاملة ومحسنة (Master Blueprint)

> **ملاحظة للـ AI المنفذ:** هذه الوثيقة هي المرجع الوحيد والمحدث للمشروع. تم تنقيحها ودمج التعديلات الأمنية والمعمارية بها، بالإضافة للـ Design System الجديد وسجل المهام. **يجب عليك تحديث قسم (سجل التحديثات - Changelog) في هذا الملف بعد كل تعديل تقوم به لتتذكر ما قمت بفعله دائماً.**

---

## 📌 نظرة عامة سريعة (TL;DR للـ AI)

| البند | القيمة |
|---|---|
| اسم المشروع | لعبتنا (Le3betna) |
| نوع التطبيق | PWA + Flutter Web |
| التكلفة | صفر دولار (Zero-Cost) |
| الدومين الأساسي للعبة | `https://le3betna-32671.web.app` |
| دومين صفحة الهبوط | `https://le3betna.vercel.app` |
| الألعاب (V1) | أربعة في صف (منجز)، دومينو (منجز)، لودو (متبقي) |
| Backend | Firebase Spark (مجاني) + Realtime Database |
| Frontend | Flutter Web (PWA) بتصميم فخم (Dark First) |

---

## 1. الرؤية والأهداف التجارية

منصة ألعاب لوحية اجتماعية مجانية 100% تجمع المصريين والعرب في "رومات" للعب معاً بدون تحميل. 
**الهوية البصرية:** تم اعتماد نظام تصميم عالمي פריموم (Premium) مستوحى من Discord و Linear و Riot Games، مع الحفاظ على الروح المصرية (إيموجي شبشب، طماطم).

---

## 2. البنية التقنية (Tech Stack)

### 2.1 Frontend — Flutter Web (PWA)
- **الـ Renderer:** تم تفعيل `--web-renderer auto` في Github Actions ليتم التحميل بسرعة عبر HTML في الهواتف، و CanvasKit للديسكتوب.
- **التصميم (Design System):**
  - تم اعتماد برومبت الـ Premium Design System بشكل كامل كمرجع لواجهة المستخدم.
  - **الألوان الأساسية:** `Indigo #6366F1`، خلفيات `Deep Blue #0B1120` و `Surface #111827`.
  - **الخطوط:** `Cairo` للعناوين و `Tajawal` للنصوص (كبديل عربي لـ Inter المذكور في البرومبت).
  - **المؤثرات:** الاعتماد على Glassmorphism في الـ Cards و Dialogs و Overlays فقط لمنع استهلاك الموارد.

### 2.2 Backend — Firebase (Security & Performance)
لتفادي استهلاك الباندويث وضمان الأمان:
- **الأداء:** استخدام مسار `transient/{uid}` للتفاعلات العابرة، وتحديث `lastMove` فقط لتجنب جلب كامل הـ `gameState`.
- **الحماية (Rules):** منع تعديل الـ `gameState` إلا لمنشئ الغرفة (Host)، وعزل أوراق الدومينو للمستخدم في `hands/{uid}` لمنع كشفها للخصم.

### 2.3 Landing Page — Next.js
مبنية بـ Next.js ومربوطة بـ Google Search Console. تحتوي على خريطة الموقع (`sitemap.xml`) ومحسنة كلياً للـ SEO (استخدام `<h3>` صحيح، توحيد كلمة "لودو"، ولا توجد أخطاء تحميل).

---

## 3. منطق الألعاب (Game Logic) وحل الثغرات

### 3.1 الدومينو البلدي
- **التوجيه:** فحص القطع من الجهتين (يمين/يسار) قبل وضعها.
- **الانسداد (Block):** حساب الفائز بناءً على أقل مجموع نقاط في حالة القفلة التامة.

### 3.2 أربعة في صف (Connect 4)
- **التعادل:** اكتشاف التعادل إذا امتلأت الـ 42 خانة بدون تشكيل خط 4 أفقي/رأسي/قطري.

### 3.3 لودو (Ludo)
- **الأمان:** وضع 8 مربعات النجمة كمناطق آمنة (Safe Zones) تمنع أكل التوكنز.
- **حركة التوكن:** تحويل موقع القطعة المحلي (Local) إلى مؤشر عالمي (Global) للتحقق من الاصطدام بشكل آمن ومزامنتها على Firebase.

---

## 4. مراحل التنفيذ والتحديث (Status)

- **المرحلة 0:** إنشاء مشاريع Flutter و Next.js وربط Firebase. ✅ (مكتمل)
- **المرحلة 1:** بناء صفحة الهبوط (Next.js)، ربطها بـ Google Search Console وحل أخطاء الـ SEO. ✅ (مكتمل)
- **المرحلة 2:** بناء הـ Design System (الألوان، الخطوط، الثيم) وإعادة تصميم شاشة الدخول (Login) في Flutter. ✅ (مكتمل)
- **المرحلة 3:** بناء واجهة تحكم اللاعب (Dashboard) ✅ (مكتمل) ونظام الغرف (Lobby). ⏳ (جاري العمل)
- **المرحلة 4:** ربط الألعاب بقاعدة بيانات Firebase المعمارية الجديدة للحماية والأداء. ⏳ (متبقي)
- **المرحلة 5:** محرك اللودو والأصوات التفاعلية (SoundManager). ⏳ (متبقي)

---

## 5. 📝 سجل التحديثات والمهام (AI Task Log)

> **قاعدة ثابتة للـ AI:** في كل مرة تنهي فيها جلسة عمل أو تُكمل ميزة رئيسية، يجب عليك إضافة سطر جديد هنا يحتوي على التاريخ، وما قمت بإنجازه، وما هي الخطوة التالية.

- **[27 يونيو 2026] - إصلاح الرفع وإعادة تصميم واجهة المستخدم:**
  - اكتشاف وإصلاح خطأ في بناء Flutter (`Compile-Time Error`) ناتج عن استخدام `get` بدلاً من `const` في ملف `app_theme.dart` والذي تسبب في فشل Github Actions.
  - تطبيق التصميم الفخم (Premium UI) على شاشة تسجيل الدخول (`login_screen.dart`).
  - إعادة تصميم واجهة اللوحة الرئيسية (`dashboard_screen.dart`) بالكامل مع إضافة مؤثرات حركية (Spring Animations) و اهتزاز عند اللمس، وخلفية ذكية (Ambient Background).
  - **الخطوة التالية:** إعادة تصميم شاشة إنشاء الغرف/الانضمام (Lobby & Room Options).

- **[27 يونيو 2026] - المراجعة وإضافة الـ Design System:** 
  - إجراء فحص شامل لصفحة الهبوط (Landing Page) وحل 5 أخطاء UX/SEO.
  - توثيق الموقع في Google Search Console وإضافة Sitemap.
  - إصلاح مشاكل الـ Web App (OG tags، Ludo، web-renderer، orientation).
  - بناء Design System عالمي (Premium UI) واعتماد برومبت التصميم المخصص.

---

## 6. 🎨 ملحق: Premium Design System Prompt
*هذا هو المرجع الأساسي للتصميم الذي تم الاتفاق عليه لكل المكونات، ومحسن خصيصاً للعبة عربية.*

```text
Create a premium, scalable Design System for a modern multiplayer gaming platform called "Le3betna".
The style should feel like a mix of Discord, Riot Games, Steam, Linear, and Apple Human Interface.
Do NOT use full Glassmorphism everywhere.
Use Glassmorphism only for dialogs, modals, profile cards, sidebars, and overlays.

COLOR PALETTE
Primary: #6366F1 | Secondary: #8B5CF6 | Success: #22C55E | Warning: #F59E0B | Danger: #EF4444
Background: #0B1120 | Surface: #111827 | Border: rgba(255,255,255,0.08)

GLASSMORPHISM
Background: rgba(255,255,255,0.08) | Backdrop Blur: 16px | Border: 1px rgba(255,255,255,0.12)

ANIMATIONS & SPACING
- Navigation/UI: 200ms Ease In Out
- Game Components (Dice, Cards): Spring/Elastic Curves (Bouncy & Snappy)
- Grid System: 8pt

HAPTIC & AUDIO
- Add HapticFeedback (Light impact for buttons, Heavy impact for game moves).
- Add subtle UI click sounds for all interactive elements.

TYPOGRAPHY & RTL
- Strictly support RTL (Right-to-Left) layout natively.
- Font: Cairo for Headings, Tajawal for Body.

ICONS
- Material Symbols Rounded for gaming feel.
```
