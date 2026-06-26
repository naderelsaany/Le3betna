# Le3betna — Design System Master Prompt

أنت مصمم وبرمجي مشروع "لعبتنا". طبّق هذا النظام على كل شاشة وكل مكوّن بدون استثناء.

---

### 🎨 IDENTITY & MOOD
المشروع يجمع بين ثلاثة عناصر:
- الطابع المصري الأصيل (ألوان دافئة، شخصية حيوية، تفاعلية مضحكة)
- الحداثة الرقمية (أنيميشن سلس، تصميم نظيف، تجربة مستخدم عالمية)
- اللعب الاجتماعي (واجهة لا تشتّت، كل عنصر يخدم متعة اللعب)

---

### 🖌️ COLOR PALETTE
```dart
// PRIMARY BRAND
static const Color bgDeep   = Color(0xFF0D0D1A); // خلفية الشاشة الرئيسية
static const Color bgCard   = Color(0xFF1A1A2E); // خلفية البطاقات والغرف
static const Color bgPanel  = Color(0xFF16213E); // الأبانيل والشرائح

// ACCENT
static const Color accentRed  = Color(0xFFE94560); // CTA + تنبيهات + الدومينو
static const Color accentGold = Color(0xFFFFB703); // كود الغرفة + الفوز + النجوم
static const Color accentTeal = Color(0xFF06D6A0); // نجاح + انتهاء الدور

// PLAYER COLORS (ليدو + أربعة في صف)
static const Color playerRed    = Color(0xFFE94560);
static const Color playerBlue   = Color(0xFF4CC9F0);
static const Color playerYellow = Color(0xFFFFB703);
static const Color playerGreen  = Color(0xFF06D6A0);
```
**قاعدة الألوان:**
- الخلفيات دائماً من `bgDeep` ← `bgCard` ← `bgPanel` (من الأعمق للأفتح)
- أي CTA أساسي واحد فقط في الشاشة = `accentRed`
- الإنجازات والأكواد = `accentGold`
- النجاح والتأكيد = `accentTeal`
- **التطبيق يعتمد على الـ Dark Mode كلياً.** (لا يتم دعم الـ Light mode للحفاظ على طابع اللعبة).

---

### ✍️ TYPOGRAPHY
```dart
// HEADLINES & TITLES (عربي)
GoogleFonts.cairo(fontWeight: FontWeight.w900) // شاشات البداية
GoogleFonts.cairo(fontWeight: FontWeight.w700) // عناوين الأقسام

// BODY TEXT (عربي)
GoogleFonts.tajawal(fontWeight: FontWeight.w400) // نصوص عادية
GoogleFonts.tajawal(fontWeight: FontWeight.w500) // تسميات وعلامات

// NUMBERS & CODES (إنجليزي)
GoogleFonts.rajdhani(fontWeight: FontWeight.w700, letterSpacing: 6) // كود الغرفة
GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w500) // أرقام الألعاب
```

---

### 📐 SPACING & LAYOUT
```dart
// نظام 8px Grid — كل المسافات مضاعفات لـ 4
XS:  4px   (مسافة داخلية صغيرة)
SM:  8px   (gap بين عناصر متقاربة)
MD:  16px  (padding الـ cards)
LG:  24px  (مسافة بين الأقسام)
XL:  32px  (margin الشاشات)
XXL: 48px  (مسافات كبيرة — Desktop فقط)

// BORDER RADIUS
XS: 6px   (badges, chips)
SM: 10px  (buttons, inputs)
MD: 16px  (cards, panels)
LG: 24px  (modals, bottom sheets)
FULL: 100px (avatars, pills)
```

---

### 🎮 GAME UI RULES
**شاشة اللعب (أولوية عالية):**
1. لا يوجد تشتيت — فقط اللوحة + اللاعبون + أدوات التفاعل
2. صور اللاعبين: دائماً في الأركان، حجم 56x56 dp، border بلون اللاعب
3. "دورك" يُعلَن بـ: pulse animation على إطار الصورة + glow خفيف على bgDeep
4. أي حركة غير مسموحة: shake animation للعنصر (لا toast، لا dialog)
5. الفوز: confetti full-screen + بطاقة منتصف شبه شفافة

**بطاقة الدومينو:**
- نسبة العرض للطول: 1:2
- ألوان النقاط: accentRed على bgCard
- عند الوضع على اللوحة: slide + snap animation (200ms, easeOut)

**ليدو:**
- اللوحة دائماً في المنتصف، تشغل 70% من ارتفاع الشاشة
- النرد: في ركن اللاعب الحالي، bounce animation عند الرمي

**أربعة في صف:**
- الشبكة: 7 أعمدة × 6 صفوف، مربعة دائماً (aspect ratio 1:1 للخانة)
- القرص يسقط بـ drop animation (gravity curve, 350ms)

---

### ✨ ANIMATION SYSTEM
```dart
// TIMING (استخدم هذه القيم فقط)
INSTANT:  100ms  // feedback فوري (ضغط زر)
FAST:     200ms  // transitions خفيفة (ظهور badge)
NORMAL:   350ms  // معظم الأنيميشن (حركة قرص، وضع دشة)
SLOW:     600ms  // transitions الشاشات، انيميشن الرمي
DRAMATIC: 1000ms // الفوز، الأنيميشن التفاعلية (شبشب، طماطم)

// CURVES
EASE_OUT:    Curves.easeOut      // معظم الحركات
BOUNCE:      Curves.elasticOut   // إيموجي، ظهور بطاقات
GRAVITY:     Curves.easeIn       // سقوط القرص في connect4
SPRING:      Curves.fastOutSlowIn // tabs، chip selection

// MICRO-INTERACTIONS (إلزامية على كل عنصر قابل للضغط)
scale: 1.0 → 0.95 → 1.0 (easeOut, 150ms)
```

---

### 🃏 COMPONENT LIBRARY
**AppButton:**
- Primary: bgColor=accentRed, textColor=white, radius=10, height=52. Add a subtle colored glow in dark mode (box-shadow with 25% opacity and large blur).
- Secondary: bgColor=transparent, border=accentRed 1.5px, textColor=accentRed
- Ghost: bgColor=bgPanel, textColor=white, no border
- Disabled: opacity=0.5, no scale interaction.
- حالة loading: replace text بـ CircularProgressIndicator (accentGold)

**AppAvatar:**
- حجم صغير: 40px (quick chat)
- حجم عادي: 56px (شاشة اللعب)
- حجم كبير: 80px (بروفايل)
- الـ border: 2px بلون اللاعب عند دوره، transparent غيره

**RoomCodeDisplay:**
- خط Rajdhani Bold، حجم 36px، letterSpacing 8px
- لون accentGold على bgCard
- زر copy بجانبه مع تأثير "تم النسخ"

---

### 🌐 LANDING PAGE RULES (Next.js)
**Fonts:** Cairo (800, 700) + Tajawal (400, 500) من Google Fonts
**Direction:** dir="rtl" على الـ html element
**Grid:** CSS Grid, max-width: 1200px, padding: 0 24px

```css
/* TOKENS */
:root {
  --bg:          #0D0D1A;
  --bg-card:     #1A1A2E;
  --accent:      #E94560;
  --gold:        #FFB703;
  --teal:        #06D6A0;
  --text-main:   #FFFFFF;
  --text-sub:    rgba(255,255,255,0.65);
  --text-muted:  rgba(255,255,255,0.4);
  --radius-card: 20px;
  --radius-btn:  12px;
}
```

**Hero Section:**
- خلفية: `bgDeep` مع pattern هندسي خفيف جداً (opacity: 0.04)
- العنوان الرئيسي: Cairo 900، 56px mobile → 80px desktop
- لا gradients مرئية — flat تماماً
- الـ CTA: زر كبير accentRed، radius 12px، height 56px مع Subtle Glow

**Feature & Game Cards:**
- bg: bgCard، border: 1px solid rgba(255,255,255,0.08)
- أيقونة كبيرة (40px) بلون accentTeal أو accentGold
- لا shadows — فقط border خفيف شفاف للحدود الخارجية.
- نسبة أبعاد بطاقة اللعبة 3:4، border-radius 20px، overlay gradient من أسفل فقط.

---

### 🚫 NEVER DO
- لا gradients مرئية كثيفة (خفيف جداً مسموح في overlays فقط)
- لا drop shadows خارجية صريحة (استخدم inner shadows خفيفة، أو colored glows شفافة للأزرار)
- لا أكثر من لون accent واحد لكل CTA في نفس الشاشة
- لا نصوص أقل من 12px
- لا animations بدون timing function محدد
- لا أكثر من 3 ألوان متمايزة في مكوّن واحد
- لا تغيير style بين الشاشات — consistent دائماً
- لا بطاقة بدون border-radius ≥ 12px
- لا input بدون معالجة SafeArea وKeyboard

### ✅ ALWAYS DO
- كل زر له scale micro-interaction (150ms, easeOut)
- كل شاشة تبدأ بـ FadeIn animation (300ms)
- كل حركة لعبة لها صوت مصاحب خفيف
- RTL: كل الـ padding والـ margin والاتجاهات محسوبة لليمين-لليسار
- Dark mode first: صمّم الداكن أولاً، ولا حاجة للفاتح.
- SafeArea على كل Scaffold
- أي نص طويل: TextOverflow.ellipsis — لا كسر للـ layout
- استخدام Framer Motion في موقع Next.js لتطبيق الحركات بدقة.
