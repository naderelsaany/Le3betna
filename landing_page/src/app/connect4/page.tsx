import { Metadata } from "next";
import Link from "next/link";
import { Play, BrainCircuit, Target } from "lucide-react";
import { HeroMotion, FadeInUp } from "../../components/MotionWrappers";

export const metadata: Metadata = {
  title: "لعبة أربعة في صف أونلاين - منصة لعبتنا",
  description: "العب أربعة في صف أونلاين مع أصدقائك بدون تحميل. تحدى ذكائك واستراتيجيتك في أقوى لعبة أربعة في صف جماعية على المتصفح مجاناً.",
  keywords: ["أربعة في صف", "اربعة في صف اونلاين", "العاب ذكاء متصفح", "لعبتنا اربعة في صف", "العاب استراتيجية اونلاين"],
  alternates: {
    canonical: "https://le3betna.cc.cd/connect4",
  },
};

export default function Connect4Page() {
  return (
    <div className="pt-32 pb-16 px-4 sm:px-8 max-w-4xl mx-auto text-right">
      <HeroMotion>
        <h1 className="text-4xl sm:text-5xl font-cairo font-black mb-6 text-[var(--text-main)]">
          لعبة أربعة في صف <span className="text-[var(--accent)]">أونلاين</span>
        </h1>
        <p className="text-xl text-[var(--text-sub)] mb-8 font-tajawal leading-relaxed">
          اختبر ذكاءك واستراتيجيتك مع لعبة "أربعة في صف" الكلاسيكية. تحدى أصدقائك أو لاعبين آخرين أونلاين عبر المتصفح بدون أي تحميل، واستمتع بتجربة ألعاب متصفح استراتيجية لا مثيل لها.
        </p>
        
        <div className="flex gap-4 justify-start mb-16">
          <Link 
            href="https://le3betna-game.vercel.app" 
            target="_blank" 
            rel="noopener noreferrer"
            className="glow-btn px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white flex items-center gap-2 hover:scale-95 transition-transform"
          >
            <Play className="w-5 h-5 fill-current" />
            تحدى أصدقائك الآن
          </Link>
        </div>
      </HeroMotion>

      <FadeInUp delay={0.2} className="space-y-12">
        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <BrainCircuit className="text-[var(--accent)]" /> العاب ذكاء واستراتيجية
          </h2>
          <p className="text-[var(--text-sub)] font-tajawal leading-relaxed mb-4">
            لعبة أربعة في صف ليست مجرد لعبة حظ، بل تتطلب تفكيراً استراتيجياً وتوقعاً لخطوات الخصم. في منصة لعبتنا، نضع بين يديك تجربة لعب سلسة تتيح لك التركيز الكامل على خطتك للفوز.
          </p>
        </section>

        <section className="bg-[var(--bg-card)] p-8 rounded-[20px] glass-border">
          <h2 className="text-2xl font-cairo font-bold mb-4 text-[var(--text-main)] flex items-center gap-2">
            <Target className="text-[var(--gold)]" /> القواعد بسيطة والتحدي كبير
          </h2>
          <p className="text-[var(--text-sub)] font-tajawal leading-relaxed">
            الهدف هو وضع أربعة أقراص من لونك في صف واحد (أفقياً، عمودياً، أو قطرياً) قبل خصمك. هل يمكنك منعهم من إكمال صفوفهم بينما تبني صفك الخاص؟ أنشئ غرفة الآن واكتشف من هو الأذكى!
          </p>
        </section>
      </FadeInUp>
    </div>
  );
}
