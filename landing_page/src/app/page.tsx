'use client';
import { motion } from 'framer-motion';
import { Play, Users, Trophy, ChevronDown, CheckCircle2 } from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';
import { useState } from 'react';

export default function Home() {
  return (
    <div className="text-[var(--text-main)] selection:bg-[var(--accent)] selection:text-white">
      <main>
        {/* Hero Section */}
        <header className="pt-32 pb-16 px-4 sm:px-8 max-w-7xl mx-auto flex flex-col items-center text-center relative">
          <div className="absolute inset-0 pointer-events-none opacity-[0.04]" style={{ backgroundImage: 'radial-gradient(circle at center, white 1px, transparent 1px)', backgroundSize: '24px 24px' }}></div>

          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.3, ease: 'easeOut' }}
            className="max-w-4xl relative z-10"
          >
            <div className="inline-block mb-4 px-4 py-1.5 rounded-full glass-border bg-[var(--bg-card)] text-[var(--teal)] text-sm font-tajawal font-medium">
              منصة الألعاب اللوحية الرائدة
            </div>
            <h1 className="text-4xl sm:text-6xl md:text-[80px] font-cairo font-black tracking-tight mb-8 leading-tight text-[var(--text-main)]">
              العب دومينو ولودو <br />
              <span className="text-[var(--accent)]">مباشرة من المتصفح</span>
            </h1>
            <p className="text-xl text-[var(--text-sub)] mb-12 max-w-2xl mx-auto font-tajawal leading-relaxed">
              منصة ألعاب لوحية سريعة ومجانية. استمتع بألعابك المفضلة مثل الدومينو ولودو وأربعة في صف بدون الحاجة لتثبيت تطبيقات تستهلك مساحة جهازك. تجربة لعب جماعي سلسة صُممت خصيصاً لتجمع الأصدقاء في أي وقت ومن أي مكان.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
              <Link 
                href="https://le3betna-32671.web.app" target="_blank" rel="noopener noreferrer"
                className="glow-btn group relative px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white transition-transform duration-150 ease-out hover:scale-95 flex items-center gap-2">
                <Play className="w-5 h-5 fill-current" />
                <span>بدء اللعب مجاناً</span>
              </Link>
              <Link 
                href="#features"
                className="px-8 py-4 bg-[var(--bg-card)] rounded-[12px] font-tajawal font-bold text-lg text-[var(--text-main)] transition-transform duration-150 ease-out hover:scale-95 glass-border">
                استكشف المميزات
              </Link>
            </div>
          </motion.div>
        </header>

        {/* Feature Cards */}
        <section 
          id="features"
          className="mt-32 w-full max-w-7xl mx-auto px-4 sm:px-8 relative z-10 scroll-mt-24"
        >
          <motion.div 
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, delay: 0.1, ease: 'easeOut' }}
          >
            <h2 className="text-3xl font-cairo font-bold mb-8 text-center text-[var(--text-main)]">لماذا تختار منصة لعبتنا؟</h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              <article className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--teal)] bg-[var(--teal)]/10">
                  <Play className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-cairo font-bold mb-3 text-[var(--text-main)]">تجربة لعب فورية</h3>
                <p className="text-[var(--text-sub)] font-tajawal text-[15px] leading-relaxed">ادخل وابدأ اللعب فوراً. تصميم خفيف جداً يضمن أداء سريع وسلس على مختلف الأجهزة، بدون الحاجة لتحميل مساحات ضخمة.</p>
              </article>
              <article className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--gold)] bg-[var(--gold)]/10">
                  <Users className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-cairo font-bold mb-3 text-[var(--text-main)]">تواصل ولعب جماعي</h3>
                <p className="text-[var(--text-sub)] font-tajawal text-[15px] leading-relaxed">أنشئ غرفة خاصة وشارك الرابط مع أصدقائك لبدء التحدي في ثوانٍ. استمتع بألعاب أونلاين تدعم تعدد اللاعبين بكل سهولة.</p>
              </article>
              <article className="bg-[var(--bg-card)] p-6 rounded-[20px] glass-border flex flex-col items-start text-right">
                <div className="w-10 h-10 rounded-xl flex items-center justify-center mb-4 text-[var(--accent)] bg-[var(--accent)]/10">
                  <Trophy className="w-6 h-6" />
                </div>
                <h3 className="text-xl font-cairo font-bold mb-3 text-[var(--text-main)]">قواعد أصلية كلاسيكية</h3>
                <p className="text-[var(--text-sub)] font-tajawal text-[15px] leading-relaxed">نقدم الألعاب اللوحية التي تعرفها وتحبها، بنفس القواعد المألوفة والمؤثرات الصوتية التفاعلية الممتعة.</p>
              </article>
            </div>
          </motion.div>
        </section>

        {/* How to Play Section */}
        <section className="mt-32 w-full max-w-7xl mx-auto px-4 sm:px-8 relative z-10 bg-[var(--bg-card)] rounded-[24px] glass-border p-8 md:p-12 overflow-hidden">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, ease: 'easeOut' }}
            className="flex flex-col md:flex-row gap-12 items-center"
          >
            <div className="flex-1 text-right">
              <h2 className="text-3xl font-cairo font-bold mb-6 text-[var(--text-main)]">كيفية اللعب في 3 خطوات بسيطة</h2>
              <p className="text-[var(--text-sub)] font-tajawal text-lg leading-relaxed mb-8">
                صممنا منصة لعبتنا لتكون الأسهل والأسرع لبدء ألعابك المفضلة مثل لودو أونلاين والدومينو. لا حاجة لحسابات معقدة أو تحميل إضافي، فقط اتبع الخطوات وابدأ المرح.
              </p>
              <ul className="space-y-4">
                <li className="flex items-start gap-4">
                  <div className="mt-1 bg-[var(--teal)]/20 text-[var(--teal)] p-1 rounded-full"><CheckCircle2 className="w-5 h-5" /></div>
                  <div>
                    <h4 className="font-cairo font-bold text-lg">اختر اللعبة</h4>
                    <p className="text-[var(--text-sub)] font-tajawal text-sm mt-1">تصفح مجموعة الألعاب واضغط على اللعبة التي تريدها سواء الدومينو أو أربعة في صف.</p>
                  </div>
                </li>
                <li className="flex items-start gap-4">
                  <div className="mt-1 bg-[var(--teal)]/20 text-[var(--teal)] p-1 rounded-full"><CheckCircle2 className="w-5 h-5" /></div>
                  <div>
                    <h4 className="font-cairo font-bold text-lg">أنشئ غرفة أو انضم</h4>
                    <p className="text-[var(--text-sub)] font-tajawal text-sm mt-1">يمكنك إنشاء غرفة خاصة ومشاركة كود الدخول مع أصدقائك عبر الواتساب، أو الانضمام لغرفة موجودة.</p>
                  </div>
                </li>
                <li className="flex items-start gap-4">
                  <div className="mt-1 bg-[var(--teal)]/20 text-[var(--teal)] p-1 rounded-full"><CheckCircle2 className="w-5 h-5" /></div>
                  <div>
                    <h4 className="font-cairo font-bold text-lg">استمتع باللعب</h4>
                    <p className="text-[var(--text-sub)] font-tajawal text-sm mt-1">ابنِ استراتيجيتك، العب دورك، واستمتع بتجربة ألعاب متصفح تفاعلية لا تُنسى.</p>
                  </div>
                </li>
              </ul>
            </div>
            <div className="flex-1 w-full relative h-[400px] rounded-2xl overflow-hidden glass-border">
              <div className="absolute inset-0 bg-gradient-to-tr from-[var(--bg)] to-[var(--bg-card)] opacity-50 z-0"></div>
              <div className="absolute inset-0 flex items-center justify-center z-10 flex-col">
                 <Trophy className="w-24 h-24 text-[var(--gold)] mb-4 opacity-80" />
                 <span className="font-cairo font-bold text-2xl text-[var(--text-main)]">العب، تنافس، واربح</span>
              </div>
            </div>
          </motion.div>
        </section>

        {/* Game Cards */}
        <section className="mt-24 w-full max-w-7xl mx-auto px-4 sm:px-8 relative z-10">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, delay: 0.2, ease: 'easeOut' }}
          >
            <h2 className="text-3xl font-cairo font-bold mb-8 text-center text-[var(--text-main)]">اكتشف الألعاب المتاحة</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
              
              {/* Domino */}
              <article className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
                <Image src="/images/domino.png" alt="لعبة دومينو أونلاين" fill sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw" priority={true} className="object-cover transition-transform duration-500 group-hover:scale-110" />
                <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
                <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                  <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">دومينو</h3>
                </div>
              </article>

              {/* Ludo */}
              <article className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
                <Image src="/images/ludo.png" alt="لعبة لودو مع الأصدقاء" fill sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw" priority={true} className="object-cover transition-transform duration-500 group-hover:scale-110" />
                <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
                <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                  <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">لودو</h3>
                </div>
              </article>

              {/* Connect 4 */}
              <article className="relative aspect-[3/4] rounded-[20px] glass-border overflow-hidden group cursor-pointer bg-[var(--bg-card)] transition-transform duration-150 ease-out hover:scale-95">
                <Image src="/images/connect4.png" alt="لعبة أربعة في صف" fill sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw" priority={true} className="object-cover transition-transform duration-500 group-hover:scale-110" />
                <div className="absolute inset-0 bg-gradient-to-t from-[rgba(13,13,26,0.9)] to-transparent z-10"></div>
                <div className="absolute bottom-6 left-6 right-6 z-20 text-right">
                  <h3 className="text-2xl font-cairo font-bold text-[var(--text-main)]">أربعة في صف</h3>
                </div>
              </article>

            </div>
          </motion.div>
        </section>

        {/* FAQ Section */}
        <section className="mt-32 pb-32 w-full max-w-3xl mx-auto px-4 sm:px-8 relative z-10 text-right">
          <motion.div
            initial={{ opacity: 0, y: 40 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.3, delay: 0.3, ease: 'easeOut' }}
          >
            <h2 className="text-3xl font-cairo font-bold mb-8 text-center text-[var(--text-main)]">الأسئلة الشائعة</h2>
            <div className="space-y-4">
              <FAQItem question="هل أحتاج لتحميل تطبيق للعب؟" answer="لا إطلاقاً! منصة لعبتنا تعمل بالكامل من خلال متصفح الويب الخاص بك. يمكنك بدء ألعاب متصفح ممتعة مثل الدومينو ولودو بمجرد الدخول إلى الموقع." />
              <FAQItem question="هل يمكنني اللعب مع أصدقائي عن بعد؟" answer="نعم، تم تصميم المنصة خصيصاً للعب الجماعي أونلاين. يمكنك إنشاء غرفة خاصة بك وإرسال كود الغرفة لأصدقائك لينضموا إليك في ثوانٍ معدودة." />
              <FAQItem question="هل المنصة مجانية وهل تحتوي على إعلانات مزعجة؟" answer="نعم، منصة لعبتنا مجانية بالكامل. هدفنا هو تقديم مساحة ترفيهية احترافية تجمع الأصدقاء بألعاب كلاسيكية مجانية بدون تشويش الإعلانات المزعجة." />
              <FAQItem question="كيف يمكنني الفوز في الألعاب؟" answer="تعتمد الألعاب على مزيج من الحظ والاستراتيجية. يمكنك زيارة قسم 'المدونة' لدينا لقراءة أفضل استراتيجيات الفوز وتكتيكات اللعب للألعاب المختلفة." />
            </div>
          </motion.div>
        </section>

      </main>
    </div>
  );
}

function FAQItem({ question, answer }: { question: string, answer: string }) {
  const [isOpen, setIsOpen] = useState(false);
  return (
    <article className="bg-[var(--bg-card)] rounded-[16px] glass-border overflow-hidden">
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between p-6 text-right font-tajawal font-bold text-lg text-[var(--text-main)] hover:bg-[rgba(255,255,255,0.02)] transition-colors"
        aria-expanded={isOpen}
      >
        <span>{question}</span>
        <ChevronDown className={`w-5 h-5 transition-transform duration-300 ${isOpen ? 'rotate-180 text-[var(--accent)]' : 'text-[var(--text-muted)]'}`} />
      </button>
      <div className={`transition-all duration-300 ease-in-out ${isOpen ? 'max-h-48 opacity-100' : 'max-h-0 opacity-0'}`}>
        <p className="px-6 pb-6 text-[var(--text-sub)] font-tajawal text-[15px] leading-relaxed">
          {answer}
        </p>
      </div>
    </article>
  );
}

