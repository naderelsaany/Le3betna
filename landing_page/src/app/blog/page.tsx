import { Metadata } from 'next';
import Link from 'next/link';

export const metadata: Metadata = {
  title: 'المدونة - لعبتنا',
  description: 'اقرأ أحدث المقالات والنصائح حول الألعاب اللوحية، ليدو، الدومينو وأربعة في صف.',
};

// Mock data for articles
export const articles = [
  {
    slug: 'how-to-play-domino-online',
    title: 'كيف تلعب الدومينو أونلاين وتحقق الفوز دائماً؟',
    excerpt: 'دليلك الشامل لتعلم قواعد الدومينو المصرية الأصيلة، استراتيجيات الفوز، وكيفية اللعب مع أصدقائك عبر المتصفح بدون تحميل.',
    date: '2026-06-27'
  },
  {
    slug: 'best-ludo-strategies',
    title: 'أفضل استراتيجيات الفوز في لعبة الليدو',
    excerpt: 'لعبة الليدو ليست مجرد حظ! تعرف على أفضل الطرق لحماية أحجارك، متى تخاطر، وكيف تدير اللوحة بذكاء للتغلب على أصدقائك.',
    date: '2026-06-26'
  },
  {
    slug: 'benefits-of-board-games',
    title: 'لماذا تلعب الألعاب اللوحية؟ فوائد مذهلة للصحة العقلية',
    excerpt: 'الألعاب اللوحية كالدومينو وليدو ليست للترفيه فقط، اكتشف كيف تساعد هذه الألعاب في تحسين الذاكرة والتفكير الاستراتيجي.',
    date: '2026-06-25'
  },
  {
    slug: 'domino-history-and-origins',
    title: 'تاريخ لعبة الدومينو: من أين بدأت وكيف وصلت إلينا؟',
    excerpt: 'تعرف على القصة المذهلة وراء لعبة الدومينو، وكيف تطورت عبر العصور لتصبح واحدة من أشهر الألعاب اللوحية في العالم.',
    date: '2026-06-24'
  },
  {
    slug: 'connect4-winning-tactics',
    title: 'تكتيكات الفوز في لعبة أربعة في صف للمبتدئين',
    excerpt: 'لعبة أربعة في صف تعتمد على التوقع السريع والتخطيط. اكتشف التكتيكات الأساسية لتضمن الفوز على خصومك.',
    date: '2026-06-23'
  },
  {
    slug: 'play-games-without-download',
    title: 'مميزات لعب الألعاب اللوحية مباشرة من المتصفح',
    excerpt: 'لماذا تستهلك مساحة هاتفك في تحميل تطبيقات الألعاب؟ تعرف على مميزات الألعاب السحابية وألعاب المتصفح مثل لعبتنا.',
    date: '2026-06-22'
  },
  {
    slug: 'ludo-vs-domino-which-is-better',
    title: 'ليدو أم الدومينو: أيهما أفضل لقضاء وقت ممتع؟',
    excerpt: 'مقارنة شاملة بين أشهر لعبتين لوحيتين. ما هي اللعبة الأنسب لك ولأصدقائك في سهرة ممتعة؟',
    date: '2026-06-21'
  },
  {
    slug: 'how-to-create-private-rooms',
    title: 'كيفية إنشاء غرف لعب خاصة مع أصدقائك أونلاين',
    excerpt: 'خطوات بسيطة لإنشاء غرفة مغلقة لك ولأصدقائك فقط للعب الدومينو أو ليدو بكل خصوصية وسهولة عبر الإنترنت.',
    date: '2026-06-20'
  },
  {
    slug: 'family-games-online',
    title: 'أفضل الألعاب العائلية التي يمكنك لعبها أونلاين مجاناً',
    excerpt: 'اجمع عائلتك من مختلف الأماكن وتواصلوا عبر الألعاب اللوحية المجانية التي تناسب جميع الأعمار.',
    date: '2026-06-19'
  },
  {
    slug: 'browser-games-performance',
    title: 'كيف تضمن أفضل أداء عند لعب ألعاب المتصفح',
    excerpt: 'نصائح بسيطة لتسريع متصفحك وتقليل التقطيع (اللاج) أثناء لعب الدومينو أو ليدو أونلاين.',
    date: '2026-06-18'
  }
];

export default function BlogPage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-8 py-16 text-right">
      <h1 className="text-4xl font-cairo font-bold mb-4 text-[var(--accent)]">مدونة لعبتنا</h1>
      <p className="text-xl text-[var(--text-sub)] font-tajawal mb-12">
        نصائح، استراتيجيات، وأخبار حول عالم الألعاب اللوحية.
      </p>

      <div className="grid grid-cols-1 gap-8">
        {articles.map((article) => (
          <Link href={`/blog/${article.slug}`} key={article.slug} className="block group">
            <div className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border transition-transform duration-200 hover:scale-[1.02]">
              <div className="text-sm text-[var(--teal)] font-rajdhani mb-3">{article.date}</div>
              <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] group-hover:text-[var(--accent)] transition-colors">
                {article.title}
              </h2>
              <p className="font-tajawal text-[var(--text-sub)] leading-relaxed">
                {article.excerpt}
              </p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
