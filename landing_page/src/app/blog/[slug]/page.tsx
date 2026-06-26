import { Metadata } from 'next';
import { notFound } from 'next/navigation';
import fs from 'fs';
import path from 'path';
import matter from 'gray-matter';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';
import { getArticles } from '../page';

function getArticleContent(slug: string) {
  const filePath = path.join(process.cwd(), `content/blog/${slug}.md`);
  if (!fs.existsSync(filePath)) return null;
  
  const fileContents = fs.readFileSync(filePath, 'utf8');
  return matter(fileContents);
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const { slug } = await params;
  const articles = getArticles();
  const article = articles.find((a) => a.slug === slug);
  if (!article) return { title: 'مقال غير موجود' };
  
  return {
    title: `${article.title} - مدونة لعبتنا`,
    description: article.excerpt,
  };
}

export default async function BlogPost({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const articles = getArticles();
  const article = articles.find((a) => a.slug === slug);
  const markdownData = getArticleContent(slug);

  if (!article || !markdownData) {
    notFound();
  }

  return (
    <div className="max-w-3xl mx-auto px-4 sm:px-8 py-16 text-right">
      <div className="text-[var(--teal)] font-rajdhani mb-4">{article.date}</div>
      <h1 className="text-4xl md:text-5xl font-cairo font-black mb-8 text-[var(--accent)] leading-tight">
        {article.title}
      </h1>
      <div className="prose prose-invert prose-lg max-w-none font-tajawal text-[var(--text-sub)] leading-loose
        prose-headings:font-cairo prose-headings:font-bold prose-headings:text-[var(--text-main)] prose-headings:mt-12 prose-headings:mb-4
        prose-p:mb-6 prose-strong:text-white prose-ul:list-disc prose-ul:pl-6 prose-ul:mb-6 prose-li:mb-2">
        <ReactMarkdown remarkPlugins={[remarkGfm]}>
          {markdownData.content}
        </ReactMarkdown>
      </div>
    </div>
  );
}
