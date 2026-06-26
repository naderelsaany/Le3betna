# 🎮 لعبتنا — خطة تنفيذ شاملة ومحسنة (Master Blueprint)

> **ملاحظة للـ AI المنفذ:** هذه الوثيقة هي المرجع الوحيد والمحدث للمشروع. تم تنقيحها ودمج التعديلات الأمنية والمعمارية بها لتكون خالية من الأخطاء. نفّذ كل تعليمة بالترتيب.

---

## 📌 نظرة عامة سريعة (TL;DR للـ AI)

| البند | القيمة |
|---|---|
| اسم المشروع | لعبتنا (Le3betna) |
| نوع التطبيق | PWA + Flutter Web |
| التكلفة | صفر دولار (Zero-Cost) |
| الجمهور المستهدف | الشباب المصري والعربي |
| الألعاب (V1) | دومينو بلدي، ليدو، أربعة في صف |
| Backend | Firebase Spark (مجاني) |
| Frontend | Flutter Web (PWA) |
| Landing Page | Next.js على Vercel |
| الاستضافة | Firebase Hosting + Vercel (مجاني) |

---

## 1. الرؤية والأهداف التجارية

### 1.1 ما هو المشروع؟
منصة ألعاب لوحية اجتماعية مجانية 100% تجمع المصريين والعرب في "رومات" للعب معاً بدون تحميل. تعمل كـ PWA على جميع المنصات.

### 1.2 المشكلة التي يحلها
- التطبيقات الموجودة مدفوعة أو مليئة بالإعلانات.
- الهوية المصرية غائبة عن معظم هذه التطبيقات.

### 1.3 قيمة المشروع الجوهرية
- **مجاني 100%** و **بلا تحميل**.
- **هوية مصرية** (شبشب، طماطم، إيموجي محلي).

---

## 2. البنية التقنية الكاملة (Tech Stack)

> ⚠️ **قاعدة ذهبية للـ AI:** لا تستخدم أي خدمة مدفوعة.

### 2.1 Frontend — Flutter Web (PWA)

**إعداد Flutter للـ PWA:**
```bash
flutter create le3betna --platforms web
cd le3betna
flutter build web --release --web-renderer auto
```
*ملاحظة: نستخدم `auto` لتقليل مساحة التحميل على الموبايل (HTML) واستخدام CanvasKit للكمبيوتر.*

### 2.2 Backend — Firebase Spark Plan (مجاني)

**هيكل قاعدة البيانات (Realtime Database Schema المحسن):**
```json
{
  "users": {
    "{uid}": {
      "displayName": "Ahmed",
      "photoURL": "https://...",
      "createdAt": 1700000000,
      "stats": { "gamesPlayed": 0, "wins": 0 }
    }
  },
  "rooms": {
    "{roomCode}": {
      "hostUid": "uid1",
      "gameType": "domino",
      "status": "waiting",
      "maxPlayers": 4,
      "players": {
        "{uid}": {
          "displayName": "Ahmed",
          "photoURL": "https://...",
          "isReady": false,
          "status": "online" // يتم تغييره لـ offline عند الانقطاع
        }
      },
      "gameState": {
        "currentPlayer": 1,
        "currentPlayerUid": "uid1",
        "moveIndex": 0
      },
      "hands": {
        "{uid}": [/* أوراق اللاعب (مفصولة للخصوصية) */]
      },
      "moves": {
        "{moveId}": { /* سجل الحركات لتفادي التلاعب */ }
      },
      "lastMove": { /* آخر حركة تم تنفيذها للـ Sync السريع */ },
      "transient": {
        "{uid}": {
          "t": "slipper", // نوع التفاعل
          "target": "uid2",
          "ts": 1700000000
        }
      }
    }
  }
}
```

**قواعد أمان Firebase (Security Rules المحسنة):**
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null",
        ".write": "auth != null && auth.uid === $uid"
      }
    },
    "rooms": {
      "$roomCode": {
        ".write": "auth != null && (!data.exists() || data.child('hostUid').val() === auth.uid)",
        ".read": "auth != null",
        "players": {
          "$uid": {
            ".write": "auth != null && auth.uid === $uid && (
              !data.exists() ? (
                root.child('rooms').child($roomCode).child('status').val() === 'waiting' &&
                root.child('rooms').child($roomCode).child('players').numChildren() < root.child('rooms').child($roomCode).child('maxPlayers').val()
              ) : true
            )"
          }
        },
        "gameState": {
          ".write": "auth != null && (
            (!data.exists() && root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid) ||
            data.child('currentPlayerUid').val() === auth.uid || 
            (data.child('currentPlayer').val() === 1 && data.child('player1Uid').val() === auth.uid) || 
            (data.child('currentPlayer').val() === 2 && data.child('player2Uid').val() === auth.uid) || 
            root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid
          )"
        },
        "hands": {
          "$uid": {
            ".read": "auth != null && auth.uid === $uid",
            ".write": "auth != null && (
              auth.uid === $uid || 
              root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid ||
              !data.exists()
            )"
          }
        },
        "moves": {
          "$moveId": {
            ".write": "auth != null && !data.exists() && (
              root.child('rooms').child($roomCode).child('gameState').child('currentPlayerUid').val() === auth.uid ||
              root.child('rooms').child($roomCode).child('hostUid').val() === auth.uid
            )",
            ".validate": "newData.hasChildren(['timestamp'])"
          }
        },
        "transient": {
          "$uid": {
            ".write": "auth != null && auth.uid === $uid"
          }
        }
      }
    }
  }
}
```

### 2.3 صفحة الهبوط — Next.js على Vercel
تُبنى باستخدام Next.js لتحسين ה-SEO، وتحتوي على Hero، Features، HowToPlay.

---

## 3. نظام الأنيميشن والصوتيات

### 3.1 تحسين الأنيميشن
لتفادي سقوط الـ FPS على الأجهزة المتوسطة:
```dart
// إيقاف الـ Animation Controller صراحة لمنع تسريب الذاكرة
class OptimizedRiveAnimation extends StatefulWidget {
  // ...
  void dispose() {
    _controller?.isActive = false;
    _controller?.dispose();
    super.dispose();
  }
}
```
*قلل إطارات الأنيميشن البعيدة إلى 30 FPS إذا لزم الأمر.*

### 3.2 إدارة الصوتيات
لا تقم بتشغيل الصوت تلقائياً (لمنع حظر iOS Safari).
```dart
class SoundManager {
  // استخدام Preloading
  Future<void> preloadAllSounds() async { /* ... */ }
  // تشغيل عبر تفاعل المستخدم فقط
  Future<void> playSound(String fileName) async {
    final player = _preloadedPlayers[fileName];
    await player?.stop(); // تجنب التعارض
    await player?.resume();
  }
}
```

---

## 4. رحلة المستخدم (User Journey)
- **انقطاع الشبكة:** لا تحذف اللاعب. استخدم `onDisconnect().update({'status': 'offline'})`. امنحه مهلة 10 ثوان للعودة، وخزن الـ `gameState` محلياً عبر SharedPreferences للاسترداد.
- **توليد الكود:** 6 أحرف/أرقام (مثال: ABCD23).

---

## 5. منطق الألعاب (Game Logic المحسن)

### 5.1 الدومينو البلدي
- **الأوراق:** تُخزن في `rooms/{code}/hands/{uid}`.
- **التوجيه الدقيق:**
```dart
DominoTile orientTile(DominoTile tile, int openEnd, String side) {
  if (side == 'left') {
    if (tile.right == openEnd) return tile;
    return DominoTile(left: tile.right, right: tile.left, id: tile.id);
  } else {
    if (tile.left == openEnd) return tile;
    return DominoTile(left: tile.right, right: tile.left, id: tile.id);
  }
}
```
- **حساب القفلة والانسداد:**
```dart
bool isGameBlocked(int passCount, int activePlayersCount) {
  return passCount >= activePlayersCount;
}

String resolveBlockedGameWinner(Map<String, List<DominoTile>> playerHands) {
  String? winnerUid;
  int minScore = 9999;
  playerHands.forEach((uid, hand) {
    int handScore = hand.fold(0, (sum, tile) => sum + tile.left + tile.right);
    if (handScore < minScore) {
      minScore = handScore;
      winnerUid = uid;
    }
  });
  return winnerUid ?? '';
}
```

### 5.2 أربعة في صف (Connect 4)
- **كشف التعادل:**
```dart
bool isConnect4Draw(List<List<int>> board) {
  return board[0].every((cell) => cell != 0); // الصف العلوي ممتلئ
}
```

### 5.3 ليدو (Ludo)
- **تتبع المسار محلياً وعالمياً:**
```dart
int getGlobalIndex(int localStep, String color) {
  if (localStep < 0 || localStep > 50) return -1; // بالبيت أو الممر الآمن
  final Map<String, int> startOffsets = {'red': 0, 'blue': 13, 'yellow': 26, 'green': 39};
  return (localStep + (startOffsets[color] ?? 0)) % 52;
}
```
- **الأكل الآمن:**
```dart
void capturePiece({required Piece attackingPiece, required List<Piece> allPieces, required List<int> globalSafePositions}) {
  if (attackingPiece.position < 0 || attackingPiece.position > 50) return;
  final attackingGlobal = getGlobalIndex(attackingPiece.position, attackingPiece.color);
  if (globalSafePositions.contains(attackingGlobal)) return;
  
  for (final piece in allPieces) {
    if (piece.owner != attackingPiece.owner && piece.position >= 0 && piece.position <= 50) {
      if (getGlobalIndex(piece.position, piece.color) == attackingGlobal) {
        piece.position = -1; // إرجاع للبيت
      }
    }
  }
}
```

---

## 6. نظام المزامنة الفورية (Event Sourced Sync)

لتخفيف الضغط على قاعدة البيانات، نقوم بتحديث مؤشر `moveIndex` عبر `Transaction` ثم كتابة تفاصيل الحركة بمسار مسطح:
```dart
Future<bool> playMoveWithIndex(...) async {
  final moveIndexRef = FirebaseDatabase.instance.ref('rooms/$roomCode/gameState/moveIndex');
  final lastMoveRef = FirebaseDatabase.instance.ref('rooms/$roomCode/lastMove');

  final tx = await moveIndexRef.runTransaction((current) {
    if (current == null) return Transaction.success(1);
    return Transaction.success((current as int) + 1);
  });

  if (tx.committed) {
    await lastMoveRef.set({...moveData, 'moveIndex': tx.snapshot.value, 'sender': playerUid, 'timestamp': ServerValue.timestamp});
    return true;
  }
  return false;
}
```
*العميل يستمع لمسار `lastMove` فقط بدلاً من `gameState` بالكامل.*

---

## 7. إعداد PWA و SEO
- **Service Worker:** أضف ملفات `canvaskit` لتقليل وقت التحميل.
```javascript
const STATIC_ASSETS = [
  '/', '/main.dart.js', '/manifest.json',
  'https://unpkg.com/canvaskit-wasm@0.37.1/bin/canvaskit.wasm',
  'https://unpkg.com/canvaskit-wasm@0.37.1/bin/canvaskit.js'
];
```
- **SEO:** استخدام Next.js للـ Landing Page بجميع الـ Meta tags و Schema.org.

---

## 8. قواعد التصميم المتجاوب (Responsive Design)

لضمان توافق اللعبة 100% مع جميع أحجام شاشات الهواتف المحمولة والـ Tablets:
- **`SafeArea`**: التغليف الإلزامي لكل الشاشات (Scaffolds) لمنع تداخل واجهة اللعب مع شريط البطارية أو الـ Notch.
- **`LayoutBuilder` و `MediaQuery`**: الاعتماد عليها لحساب المساحات المتاحة وبناء واجهات ديناميكية تتكيف مع الطول والعرض.
- **`AspectRatio`**: استخدامه مع الحاويات الخاصة بلوحات اللعب (الدومينو، ليدو، 4 في صف) لضمان الحفاظ على الأبعاد المربعة أو المستطيلة ومنع تشوه أو تمطط (Stretch) الرسومات.

---

## 9. مراحل التنفيذ التفصيلية

- **المرحلة 0 (يوم 1):** إنشاء مشاريع Flutter و Next.js وربط Firebase. ✅ (مكتمل)
- **المرحلة 1 (أسبوع 1):** الـ Design System، المصادقة، ضغط الصور. ✅ (مكتمل - تم إضافة Profile Settings مع image_picker بضغط 50%)
- **المرحلة 2 (أسبوع 2):** نظام الغرف، الانضمام، والتعامل مع انقطاع الشبكة. ✅ (مكتمل)
- **المرحلة 3 (أسابيع 3-5):** الألعاب بالترتيب: **Connect 4** ✅ (مكتمل) ← **الدومينو** ✅ (مكتمل) ← **ليدو** ⏳ (متبقي)
- **المرحلة 4 (أسبوع 6):** تفاعلات الـ `transient`، الأصوات (SoundManager)، والأنيميشن المحسن. ⏳ (متبقي)
- **المرحلة 5 (أسبوع 7):** صفحة الهبوط (Next.js) والنشر. ⏳ (متبقي)

---

## 9.5 خطة التنفيذ التفصيلية للمتبقي (The Final Push)
بناءً على التوجيهات، سيتم تنفيذ المهام المتبقية كالتالي:

### 1. التفاعلات الحية والأصوات (Quick Wins & Engagement)
- **الصوت (SoundManager):** دمج مكتبة `audioplayers` أو `just_audio`. تحميل الأصوات مسبقاً (Preloading). إضافة صوت رمي النرد/سقوط القرص، وصوت الفوز/الخسارة. زر كتم الصوت في الـ AppBar.
- **التفاعلات (Transient Emojis):** إنشاء مسار `transient` في Firebase لكل غرفة. عند الضغط على إيموجي (مثلاً شبشب أو طماطم)، يتم تسجيله في قاعدة البيانات ويختفي بعد ثوانٍ، ويتم عرضه كـ Floating Animation على شاشة كل اللاعبين.

### 2. محرك الليدو (The Ludo Engine)
- **شبكة المسار (Path Grid):** رسم لوحة الليدو الكلاسيكية (مربعات حمراء، خضراء، زرقاء، صفراء) عبر `CustomPainter`.
- **المنطق (Logic):**
  - **النرد:** مولد أرقام عشوائي يزامن النتيجة عبر Firebase. للحصول على 6 يسمح بخروج التوكن أو اللعب مرة إضافية.
  - **حركة التوكن:** تحويل الـ Local Step (من 0 إلى 56) إلى Global Index لحساب الاصطدامات.
  - **الأمان:** وضع مربعات النجمة كمناطق آمنة (Safe Zones) تمنع أكل التوكنز.
  - **حالة اللعبة:** مزامنة مراكز الـ 16 توكن (4 لكل لاعب) على Firebase.

### 3. صفحة الهبوط (Next.js Landing Page)
- إنشاء تطبيق Next.js في مجلد منفصل `landing_page`.
- تصميم يعكس نفس الهوية البصرية (Dark Mode, Indigo).
- أزرار "Play Now" توجه المستخدم إلى رابط الـ PWA الفعلي.

---

## 10. قائمة التحقق النهائية (Launch Checklist)
- [ ] Lighthouse score > 90 على Performance.
- [ ] حجم bundle < 3 MB.
- [ ] قواعد الأمان مفعّلة ومجربة (تمنع الغش).
- [ ] اختبار انقطاع الإنترنت فجأة واسترداد الحالة.
- [ ] كتابة Unit Tests لاختبار منطق الفوز/التعادل في كل لعبة.

---
*آخر تحديث: يونيو 2026 — نسخة منقحة ومؤمنة بالكامل من قبل AI Audit Team.*
