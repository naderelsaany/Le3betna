import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'الشروط والأحكام - لعبتنا',
  description: 'الشروط والأحكام الخاصة باستخدام منصة لعبتنا للألعاب اللوحية.',
  alternates: {
    canonical: '/terms',
  },
};

export default function TermsPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-8 py-16 text-right">
      <h1 className="text-4xl font-cairo font-bold mb-8 text-[var(--accent)]">الشروط والأحكام</h1>
      <div className="prose prose-invert max-w-none font-tajawal text-[var(--text-sub)] leading-loose">
        <p className="mb-6">آخر تحديث: 27 يونيو 2026</p>
        
        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">1. قبول الشروط</h2>
        <p className="mb-6">
          باستخدامك لمنصة "لعبتنا"، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يرجى عدم استخدام المنصة.
        </p>

        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">2. الاستخدام العادل</h2>
        <p className="mb-6">
          المنصة مصممة للترفيه عن المستخدمين. يُمنع منعاً باتاً استخدام برامج الطرف الثالث، أو محاولة اختراق غرف اللعب، أو استغلال أي ثغرات برمجية لإفساد تجربة الآخرين.
        </p>

        <h2 className="text-2xl font-cairo font-bold mt-8 mb-4 text-[var(--text-main)]">3. حقوق الملكية الفضية</h2>
        <p className="mb-6">
          جميع حقوق التصميم، الأكواد، والعلامات التجارية المستخدمة في المنصة مملوكة بالكامل لمنصة "لعبتنا". لا يجوز نسخ أو إعادة إنتاج أي جزء منها دون إذن مسبق.
        </p>
      </div>
    </div>
  );
}
