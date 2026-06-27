'use client';
import Image from 'next/image';
import Link from 'next/link';

export default function Navbar() {
  return (
    <nav className="fixed top-0 w-full flex justify-between items-center px-4 sm:px-8 py-6 z-50 backdrop-blur-md bg-[var(--bg)]/80 border-b glass-border">
      <div className="flex items-center gap-8">
        <Link href="/" className="flex items-center gap-3">
          <Image src="/logo.webp" alt="شعار لعبتنا" width={40} height={40} priority={true} className="rounded-xl" />
          <div className="text-2xl font-bold tracking-wider font-cairo text-[var(--accent)]">
            لعبتنا
          </div>
        </Link>
        
        {/* Desktop Navigation */}
        <div className="hidden md:flex items-center gap-6 text-[var(--text-sub)] font-tajawal text-[15px] font-medium">
          <Link href="/" className="hover:text-[var(--text-main)] transition-colors">الرئيسية</Link>
          <Link href="/blog" className="hover:text-[var(--text-main)] transition-colors">المدونة</Link>
          <Link href="/about" className="hover:text-[var(--text-main)] transition-colors">من نحن</Link>
          <Link href="/#faq" className="hover:text-[var(--text-main)] transition-colors">الأسئلة الشائعة</Link>
        </div>
      </div>

      <Link 
        href="https://le3betna-32671.web.app" target="_blank" rel="noopener noreferrer"
        className="px-6 py-2 bg-white/10 hover:bg-white/20 rounded-[12px] transition-transform duration-150 ease-out hover:scale-95 glass-border font-tajawal font-bold text-[var(--text-main)]">
        العب الآن
      </Link>
    </nav>
  );
}
