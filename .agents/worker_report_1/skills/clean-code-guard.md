# ✅ Clean Code Guard — ضمان الجودة

## 10 Checks إلزامية قبل تسليم أي كود

| # | Check | وصف |
|---|-------|------|
| 1 | **Hallucinated APIs** | كل function/class موجود فعلاً؟ |
| 2 | **Over-Abstraction** | Interface واحدة مع implement واحد؟ Factory بسيط؟ — احذف |
| 3 | **Exception Swallowing** | try: except: pass ممنوع — كل خطأ يتعامل معاه |
| 4 | **Copy-From-Similar Bugs** | فيه blocks متكررة؟ تأكد من كل variable |
| 5 | **Hardcoded Success** | مفيش return success قبل ما الكود يجرب فعلاً |
| 6 | **Comment Pollution** | التعليقات تشرح WHY مش WHAT |
| 7 | **Naming** | الأسماء تكشف الـ intent مش process_data() |
| 8 | **SOLID + KISS + YAGNI + DRY** | كل مبدأ يتأكد |
| 9 | **Placeholder/Dummy Content** | ممنوع بيانات مزيفة في production paths |
| 10 | **UI/UX Quality Gate** | هل الديزاين حديث؟ Dark mode؟ Responsive؟ |
