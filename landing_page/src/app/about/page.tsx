import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'من نحن - لعبتنا',
  description: 'تعرف على قصة منصة لعبتنا، أول منصة ألعاب لوحية مصرية تهدف إلى جمع الأصدقاء.',
};

export default function AboutPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-8 py-16 text-right">
      <h1 className="text-4xl font-cairo font-bold mb-8 text-[var(--accent)]">من نحن</h1>
      <div className="prose prose-invert max-w-none font-tajawal text-[var(--text-sub)] leading-loose">
        <p className="text-lg mb-6">
          أهلاً بك في <strong>لعبتنا</strong>، الوجهة الأولى لمحبي الألعاب اللوحية الكلاسيكية في مصر والعالم العربي.
        </p>
        <h2 className="text-2xl font-cairo font-bold mt-12 mb-4 text-[var(--text-main)]">قصتنا</h2>
        <p className="mb-6">
          بدأت فكرة "لعبتنا" من رغبتنا في رقمنة الألعاب التي نشأنا عليها مثل الدومينو وليدو وأربعة في صف، لتقديمها في قالب عصري وسريع يمكن الوصول إليه من أي مكان وبدون الحاجة لتحميل مساحات ضخمة.
        </p>
        <h2 className="text-2xl font-cairo font-bold mt-12 mb-4 text-[var(--text-main)]">رؤيتنا</h2>
        <p className="mb-6">
          نسعى لأن نكون المنصة الترفيهية الأولى التي تجمع الأصدقاء والعائلة معاً من خلال تجارب لعب جماعية سهلة الاستخدام ومجانية بالكامل.
        </p>
      </div>
    </div>
  );
}
