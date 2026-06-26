import Image from 'next/image';
import Link from 'next/link';

export default function Footer() {
  return (
    <footer className="border-t glass-border bg-[var(--bg-card)] pt-16 pb-8 mt-20">
      <div className="max-w-7xl mx-auto px-4 sm:px-8 grid grid-cols-1 md:grid-cols-3 gap-12 text-right">
        
        <div>
          <Link href="/" className="flex items-center gap-3 mb-6">
            <Image src="/logo.webp" alt="شعار لعبتنا" width={40} height={40} className="rounded-xl grayscale opacity-80" />
            <div className="text-2xl font-bold font-cairo text-[var(--text-main)]">لعبتنا</div>
          </Link>
          <p className="text-[var(--text-sub)] font-tajawal text-sm leading-relaxed mb-6">
            أول منصة ألعاب لوحية عربية ومصرية. وجهتك الأولى للاستمتاع بألعاب الدومينو وليدو وأربعة في صف مع أصدقائك مباشرة من المتصفح بدون أي تحميل.
          </p>
        </div>

        <div>
          <h3 className="text-lg font-cairo font-bold mb-6 text-[var(--text-main)]">روابط سريعة</h3>
          <ul className="space-y-4 font-tajawal text-[var(--text-sub)]">
            <li><Link href="/#features" className="hover:text-[var(--accent)] transition-colors">المميزات</Link></li>
            <li><Link href="/blog" className="hover:text-[var(--accent)] transition-colors">المدونة</Link></li>
            <li><Link href="/about" className="hover:text-[var(--accent)] transition-colors">من نحن</Link></li>
          </ul>
        </div>

        <div>
          <h3 className="text-lg font-cairo font-bold mb-6 text-[var(--text-main)]">قانوني</h3>
          <ul className="space-y-4 font-tajawal text-[var(--text-sub)]">
            <li><Link href="/privacy" className="hover:text-[var(--accent)] transition-colors">سياسة الخصوصية</Link></li>
            <li><Link href="/terms" className="hover:text-[var(--accent)] transition-colors">الشروط والأحكام</Link></li>
          </ul>
        </div>

      </div>
      
      <div className="mt-16 pt-8 border-t border-[rgba(255,255,255,0.05)] text-center text-[var(--text-muted)] font-rajdhani text-sm">
        <p>© 2026 Le3betna Platform. All rights reserved.</p>
      </div>
    </footer>
  );
}
