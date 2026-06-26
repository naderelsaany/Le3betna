'use client';
import { motion } from 'framer-motion';
import { Play, Users, Trophy } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-[var(--bg)] text-[var(--text-main)] selection:bg-[var(--accent)] selection:text-white">
      {/* Navbar */}
      <nav className="fixed top-0 w-full flex justify-between items-center px-8 py-6 z-50 backdrop-blur-md bg-[var(--bg)]/80 border-b glass-border">
        <div className="text-2xl font-bold tracking-wider font-cairo text-[var(--accent)]">
          لعبتنا
        </div>
        <Link 
          href="https://le3betna-32671.web.app" target="_blank"
          className="px-6 py-2 bg-white/10 hover:bg-white/20 rounded-[12px] transition-transform duration-150 ease-out hover:scale-95 glass-border font-tajawal font-bold text-[var(--text-main)]">
          العب الآن
        </Link>
      </nav>

      {/* Hero Section */}
      <main className="pt-32 pb-16 px-4 sm:px-8 max-w-7xl mx-auto flex flex-col items-center text-center relative">
        
        {/* Subtle geometric pattern overlay */}
        <div className="absolute inset-0 pointer-events-none opacity-[0.04]" style={{ backgroundImage: 'radial-gradient(circle at center, white 1px, transparent 1px)', backgroundSize: '24px 24px' }}></div>

        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, ease: 'easeOut' }}
          className="max-w-4xl relative z-10"
        >
          <div className="inline-block mb-4 px-4 py-1.5 rounded-full glass-border bg-[var(--bg-card)] text-[var(--teal)] text-sm font-tajawal font-medium">
            مرحباً بك في عصر الألعاب الجديد
          </div>
          <h1 className="text-5xl sm:text-[80px] font-cairo font-black tracking-tight mb-8 leading-tight text-[var(--text-main)]">
            العب مع صحابك <br />
            <span className="text-[var(--accent)]">
              بدون أي تحميل
            </span>
          </h1>
          <p className="text-xl text-[var(--text-sub)] mb-12 max-w-2xl mx-auto font-tajawal">
            أول منصة ألعاب لوحية مصرية. دومينو، ليدو، وأربعة في صف، كلها في مكان واحد ومجانية 100%.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link 
              href="https://le3betna-32671.web.app" target="_blank"
              className="glow-btn group relative px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white transition-transform duration-150 ease-out hover:scale-95 flex items-center gap-2">
              <Play className="w-5 h-5 fill-current" />
              <span>ابدأ اللعب فوراً</span>
            </Link>
          </div>
        </motion.div>

        {/* Feature Cards */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.1, ease: 'easeOut' }}
          className="mt-32 grid grid-cols-1 md:grid-cols-3 gap-6 w-full relative z-10"
        >
          <div className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--teal)]">
              <Play className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-cairo font-bold mb-2 text-[var(--text-main)]">خفيف جداً</h3>
            <p className="text-[var(--text-sub)] font-tajawal text-[15px]">لا داعي لتحميل مساحات ضخمة، اللعبة تعمل على المتصفح مباشرة كأنها تطبيق.</p>
          </div>
          <div className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--gold)]">
              <Users className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-cairo font-bold mb-2 text-[var(--text-main)]">العب مع أي حد</h3>
            <p className="text-[var(--text-sub)] font-tajawal text-[15px]">انشئ غرفة وابعت الكود لصاحبك. ثواني وهتكونوا بتلعبوا مع بعض في نفس اللحظة.</p>
          </div>
          <div className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
            <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--teal)]">
              <Trophy className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-cairo font-bold mb-2 text-[var(--text-main)]">روح مصرية</h3>
            <p className="text-[var(--text-sub)] font-tajawal text-[15px]">دومينو بلدي وقواعد أصلية، وممكن ترمي شبشب على صاحبك لو كسبك!</p>
          </div>
        </motion.div>

        {/* Game Cards */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.3, delay: 0.2, ease: 'easeOut' }}
          className="mt-24 w-full relative z-10"
        >
          <h2 className="text-3xl font-cairo font-bold mb-8 text-right text-[var(--text-main)]">الألعاب المتاحة</h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
            
            {/* Domino */}
            <div className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
              <Image src="/images/domino.png" alt="لعبة دومينو" fill className="object-cover transition-transform duration-500 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
              <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">دومينو</h3>
              </div>
            </div>

            {/* Ludo */}
            <div className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
              <Image src="/images/ludo.png" alt="لعبة ليدو" fill className="object-cover transition-transform duration-500 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
              <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">ليدو</h3>
              </div>
            </div>

            {/* Connect 4 */}
            <div className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
              <Image src="/images/connect4.png" alt="لعبة أربعة في صف" fill className="object-cover transition-transform duration-500 group-hover:scale-110" />
              <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
              <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">أربعة في صف</h3>
              </div>
            </div>

          </div>
        </motion.div>
      </main>

      {/* Footer */}
      <footer className="border-t glass-border py-8 text-center text-[var(--text-muted)] mt-20 font-rajdhani">
        <p>© 2026 Le3betna Platform. All rights reserved.</p>
      </footer>
    </div>
  );
}
