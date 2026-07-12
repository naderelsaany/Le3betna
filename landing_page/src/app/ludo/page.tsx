import { Metadata } from "next";
import Link from "next/link";
import { Play, Users, Sparkles } from "lucide-react";
import { HeroMotion, FadeInUp } from "../../components/MotionWrappers";

export const metadata: Metadata = {
  title: "لعب لودو بدون تحميل أونلاين",
  description: "العب لودو أونلاين مع الأصدقاء بدون الحاجة لتحميل. أسرع لعبة لودو متصفح في مصر والوطن العربي. أنشئ غرفتك الخاصة وابدأ التحدي فوراً.",
  keywords: ["لعب لودو بدون تحميل", "لودو اونلاين", "لعبة لودو مع الاصدقاء", "لودو متصفح", "العاب جماعية اونلاين"],
};

export default function LudoPage() {
  return (
    <div className="pt-32 pb-16 px-4 sm:px-8 max-w-4xl mx-auto text-right">
      <HeroMotion>
        <h1 className="text-4xl sm:text-5xl font-cairo font-black mb-6 text-[var(--text-main)]">
          لعب لودو بدون تحميل <span className="text-[var(--accent)]">أونلاين</span>
        </h1>
        <p className="text-xl text-[var(--text-sub)] mb-8 font-tajawal leading-relaxed">
          هل تبحث عن طريقة سريعة للاستمتاع بلعبة اللودو؟ منصة لعبتنا تقدم لك أسرع تجربة "لعب لودو بدون تحميل" مباشرة من متصفحك. انسَ مساحات التخزين الكبيرة والتحديثات المزعجة.
        </p>
        
        <div className="flex gap-4 justify-start mb-16">
          <Link 
            href="https://le3betna-game.vercel.app" 
            target="_blank" 
            rel="noopener noreferrer"
            className="glow-btn px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white flex items-center gap-2 hover:scale-95 transition-transform"
          >
            <Play className="w-5 h-5 fill-current" />
            العب لودو الآن مجاناً
          </Link>
        </div>
      </HeroMotion>

      <FadeInUp delay={0.2} className="space-y-12">
        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <Users className="text-[var(--teal)]" /> لودو مع الأصدقاء أونلاين
          </h2>
          <p className="text-[var(--text-sub)] font-tajawal leading-relaxed mb-4">
            لعبة اللودو تصبح أكثر متعة عندما تلعبها مع من تحب. من خلال منصتنا، يمكنك بسهولة إنشاء غرفة لودو خاصة بك وإرسال الرابط لأصدقائك للانضمام والتنافس في تجربة ألعاب جماعية أونلاين فريدة.
          </p>
        </section>

        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <Sparkles className="text-[var(--gold)]" /> مميزات لودو المتصفح
          </h2>
          <ul className="list-disc list-inside text-[var(--text-sub)] font-tajawal space-y-2">
            <li>بدون تحميل: وفر مساحة هاتفك والعب مباشرة.</li>
            <li>سرعة فائقة: تحميل سريع على الهواتف والأجهزة الضعيفة.</li>
            <li>تصميم عربي: واجهة وتصميم يناسب اللاعبين في مصر والوطن العربي.</li>
          </ul>
        </section>
      </FadeInUp>
    </div>
  );
}
