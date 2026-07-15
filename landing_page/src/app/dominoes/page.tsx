import { Metadata } from "next";
import Link from "next/link";
import { Play, Shield, Zap } from "lucide-react";
import { HeroMotion, FadeInUp } from "../../components/MotionWrappers";

export const metadata: Metadata = {
  title: "لعب دومينو مصري أونلاين مع الأصدقاء",
  description: "أفضل منصة للعب الدومينو المصري أونلاين. أنشئ غرفة والعب مع أصدقائك بدون تحميل. قواعد كلاسيكية، دردشة، وتجربة سريعة جداً للموبايل والكمبيوتر.",
  keywords: ["دومينو اونلاين", "دومينو مصري", "لعب دومينو مع الاصدقاء", "دومينو بدون تحميل", "العاب متصفح جماعية"],
  alternates: {
    canonical: "https://le3betna.cc.cd/dominoes",
  },
};

export default function DominoesPage() {
  return (
    <div className="pt-32 pb-16 px-4 sm:px-8 max-w-4xl mx-auto text-right">
      <HeroMotion>
        <h1 className="text-4xl sm:text-5xl font-cairo font-black mb-6 text-[var(--text-main)]">
          لعب دومينو مصري أونلاين <span className="text-[var(--accent)]">مع الأصدقاء</span>
        </h1>
        <p className="text-xl text-[var(--text-sub)] mb-8 font-tajawal leading-relaxed">
          استمتع بأقوى لعبة دومينو أونلاين صُممت خصيصاً للاعبين في مصر والوطن العربي. بدون الحاجة لتحميل تطبيقات ثقيلة، يمكنك الآن دعوة أصدقائك واللعب مباشرة من متصفحك سواء على الموبايل أو الكمبيوتر.
        </p>
        
        <div className="flex gap-4 justify-start mb-16">
          <Link 
            href="https://le3betna-game.vercel.app" 
            target="_blank" 
            rel="noopener noreferrer"
            className="glow-btn px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white flex items-center gap-2 hover:scale-95 transition-transform"
          >
            <Play className="w-5 h-5 fill-current" />
            ابدأ اللعب الآن مجاناً
          </Link>
        </div>
      </HeroMotion>

      <FadeInUp delay={0.2} className="space-y-12">
        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <Zap className="text-[var(--gold)]" /> لماذا نلعب الدومينو هنا؟
          </h2>
          <p className="text-[var(--text-sub)] font-tajawal leading-relaxed mb-4">
            لعبة الدومينو هي من أشهر الألعاب اللوحية في مصر، والكثير يبحث عن طريقة للعب "دومينو اونلاين" بدون تعقيدات. منصة لعبتنا توفر لك بيئة لعب سريعة وخفيفة جداً تعمل على كافة الأجهزة بمجرد ضغطة زر.
          </p>
          <ul className="list-disc list-inside text-[var(--text-sub)] font-tajawal space-y-2">
            <li>إنشاء غرفة خاصة برقم سري لدعوة الأصدقاء فقط.</li>
            <li>لعب سريع وتجاوب ممتاز مع الهواتف الذكية (موبايل).</li>
            <li>قواعد الدومينو المصرية الكلاسيكية التي نحبها جميعاً.</li>
          </ul>
        </section>

        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <Shield className="text-[var(--teal)]" /> بدون تحميل، حماية وأمان
          </h2>
          <p className="text-[var(--text-sub)] font-tajawal leading-relaxed">
            لا داعي للبحث عن "تحميل لعبة دومينو" بعد الآن. ألعاب المتصفح الجماعية أصبحت الحل الأمثل لتوفير مساحة الهاتف واللعب في بيئة آمنة تماماً بدون إعلانات مزعجة تقطع عليك لحظات الحماس.
          </p>
        </section>
      </FadeInUp>
    </div>
  );
}
