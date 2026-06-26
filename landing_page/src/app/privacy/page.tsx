import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'سياسة الخصوصية - لعبتنا',
  description: 'سياسة الخصوصية لمنصة لعبتنا. تعرف على كيفية تعاملنا مع بياناتك.',
};

export default function PrivacyPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-8 py-16 text-right">
      <h1 className="text-4xl font-cairo font-bold mb-8 text-[var(--accent)]">سياسة الخصوصية</h1>
      <div className="prose prose-invert max-w-none font-tajawal text-[var(--text-sub)] leading-loose">
        <p className="mb-6">آخر تحديث: 27 يونيو 2026</p>
        
        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">1. جمع المعلومات</h2>
        <p className="mb-6">
          نحن في منصة "لعبتنا" نحرص بشدة على خصوصية زوارنا. المنصة لا تقوم بجمع أي بيانات شخصية حساسة. نستخدم أدوات التحليل القياسية لفهم كيفية تفاعل المستخدمين مع الألعاب بهدف تحسين التجربة.
        </p>

        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">2. استخدام المعلومات</h2>
        <p className="mb-6">
          يقتصر استخدامنا لأي بيانات إحصائية على تحسين سرعة الألعاب، إصلاح الأخطاء، وضمان استقرار غرف اللعب الجماعي.
        </p>

        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">3. ملفات تعريف الارتباط (Cookies)</h2>
        <p className="mb-6">
          قد نستخدم ملفات تعريف الارتباط لحفظ تفضيلاتك (مثل اسم اللاعب المفضل أو إعدادات الصوت) لضمان عدم الحاجة لإعادة ضبطها في كل مرة تزور فيها المنصة.
        </p>
      </div>
    </div>
  );
}
