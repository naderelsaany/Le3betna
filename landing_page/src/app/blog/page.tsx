import { Metadata } from 'next';
import Link from 'next/link';
import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';

export const metadata: Metadata = {
  title: 'المدونة - لعبتنا',
  description: 'اقرأ أحدث المقالات والنصائح حول الألعاب اللوحية، ليدو، الدومينو وأربعة في صف.',
};

export type Article = {
  slug: string;
  title: string;
  excerpt: string;
  date: string;
};

export function getArticles(): Article[] {
  const contentDir = path.join(process.cwd(), 'content/blog');
  if (!fs.existsSync(contentDir)) return [];
  
  const files = fs.readdirSync(contentDir);
  const articles = files
    .filter((filename) => filename.endsWith('.md'))
    .map((filename) => {
      const slug = filename.replace('.md', '');
      const filePath = path.join(contentDir, filename);
      const fileContents = fs.readFileSync(filePath, 'utf8');
      const { data } = matter(fileContents);

      return {
        slug,
        title: data.title || 'بدون عنوان',
        excerpt: data.excerpt || '',
        date: data.date || '',
      };
    })
    .sort((a, b) => (new Date(b.date).getTime() - new Date(a.date).getTime()));

  return articles;
}

export default function BlogPage() {
  const articles = getArticles();

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
