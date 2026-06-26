'use client';
import { motion } from 'framer-motion';
import { Play, Users, Trophy } from 'lucide-react';

export default function Home() {
  return (
    <div className="min-h-screen bg-background text-white selection:bg-primary selection:text-white">
      {/* Navbar */}
      <nav className="fixed top-0 w-full flex justify-between items-center px-8 py-6 z-50 backdrop-blur-md bg-background/80 border-b border-white/5">
        <div className="text-2xl font-bold tracking-wider">
          <span className="text-primary">L</span>e3betna
        </div>
        <button 
          onClick={() => window.open('http://localhost:8080', '_blank')}
          className="px-6 py-2 bg-white/10 hover:bg-white/20 rounded-full transition-all border border-white/10">
          العب الآن
        </button>
      </nav>

      {/* Hero Section */}
      <main className="pt-32 pb-16 px-4 sm:px-8 max-w-7xl mx-auto flex flex-col items-center text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="max-w-4xl"
        >
          <div className="inline-block mb-4 px-4 py-1.5 rounded-full border border-primary/30 bg-primary/10 text-primary text-sm font-medium">
            مرحباً بك في عصر الألعاب الجديد
          </div>
          <h1 className="text-5xl sm:text-7xl font-extrabold tracking-tight mb-8 leading-tight">
            العب مع صحابك <br />
            <span className="text-transparent bg-clip-text bg-gradient-to-r from-primary to-secondary">
              بدون أي تحميل
            </span>
          </h1>
          <p className="text-xl text-gray-400 mb-12 max-w-2xl mx-auto">
            أول منصة ألعاب لوحية مصرية PWA. دومينو، ليدو، وأربعة في صف، كلها في مكان واحد ومجانية 100%.
          </p>

          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <button 
              onClick={() => window.open('http://localhost:8080', '_blank')}
              className="group relative px-8 py-4 bg-primary rounded-xl font-bold text-lg overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_rgba(94,106,210,0.4)] flex items-center gap-2">
              <Play className="w-5 h-5 fill-current" />
              <span>ابدأ اللعب فوراً</span>
            </button>
            <button className="px-8 py-4 bg-surface rounded-xl font-bold text-lg border border-white/10 hover:bg-white/5 transition-all">
              استكشف الألعاب
            </button>
          </div>
        </motion.div>

        {/* Features */}
        <motion.div 
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mt-32 grid grid-cols-1 md:grid-cols-3 gap-8 w-full"
        >
          <div className="bg-surface p-8 rounded-2xl border border-white/5 flex flex-col items-center text-center">
            <div className="w-16 h-16 bg-primary/20 rounded-2xl flex items-center justify-center mb-6 text-primary">
              <Play className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-bold mb-3">PWA خفيف جداً</h3>
            <p className="text-gray-400">لا داعي لتحميل مساحات ضخمة، اللعبة تعمل على المتصفح مباشرة كأنها تطبيق.</p>
          </div>
          <div className="bg-surface p-8 rounded-2xl border border-white/5 flex flex-col items-center text-center">
            <div className="w-16 h-16 bg-secondary/20 rounded-2xl flex items-center justify-center mb-6 text-secondary">
              <Users className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-bold mb-3">العب مع أي حد</h3>
            <p className="text-gray-400">انشئ غرفة وابعت الكود لصاحبك. ثواني وهتكونوا بتلعبوا مع بعض في نفس اللحظة.</p>
          </div>
          <div className="bg-surface p-8 rounded-2xl border border-white/5 flex flex-col items-center text-center">
            <div className="w-16 h-16 bg-green-500/20 rounded-2xl flex items-center justify-center mb-6 text-green-500">
              <Trophy className="w-8 h-8" />
            </div>
            <h3 className="text-xl font-bold mb-3">روح مصرية</h3>
            <p className="text-gray-400">دومينو بلدي وقواعد أصلية، وممكن ترمي شبشب على صاحبك لو كسبك!</p>
          </div>
        </motion.div>
      </main>

      {/* Footer */}
      <footer className="border-t border-white/10 py-8 text-center text-gray-500 mt-20">
        <p>© 2026 Le3betna Platform. All rights reserved.</p>
      </footer>
    </div>
  );
}
