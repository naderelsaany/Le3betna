import type { Metadata } from "next";
import Link from "next/link";
import { CheckCircle2, XCircle, Play } from "lucide-react";

export const metadata: Metadata = {
  title: "لعبتنا ضد دومينو كافيه (Domino Cafe) | أيهما أفضل للدومينو؟",
  description: "مقارنة شاملة بين منصة لعبتنا وتطبيق دومينو كافيه. تعرف على الفرق في مميزات لعب الدومينو، الأداء، واللعب بدون إعلانات.",
  alternates: {
    canonical: "https://le3betna.cc.cd/vs/domino-cafe",
  }
};

export default function DominoCafeComparison() {
  return (
    <div className="container mx-auto px-4 py-12 max-w-4xl text-right">
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{
          __html: JSON.stringify({
            "@context": "https://schema.org",
            "@type": "SoftwareApplication",
            "name": "لعبتنا",
            "applicationCategory": "GameApplication",
            "operatingSystem": "All",
            "offers": {
              "@type": "Offer",
              "price": "0",
              "priceCurrency": "EGP"
            }
          }),
        }}
      />
      <h1 className="text-4xl font-black mb-6 text-[var(--accent)]">لعبتنا ضد دومينو كافيه (Domino Cafe)</h1>
      <p className="text-lg mb-8 text-gray-300">
        عشاق الدومينو يبحثون دائماً عن أفضل تجربة أونلاين. هنا نقارن بين منصة <strong>لعبتنا</strong> وتطبيق <strong>دومينو كافيه</strong> لنوضح لك أفضل خيار للعب الدومينو مع أصدقائك بحرية تامة.
      </p>

      <div className="overflow-x-auto mb-12">
        <table className="w-full text-right border-collapse border border-gray-700 bg-[var(--bg-light)]">
          <thead>
            <tr className="bg-gray-800">
              <th className="p-4 border border-gray-700 w-1/3">الميزة</th>
              <th className="p-4 border border-gray-700 text-center w-1/3 text-[var(--accent)] font-bold">لعبتنا</th>
              <th className="p-4 border border-gray-700 text-center w-1/3 text-gray-400">دومينو كافيه</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">سهولة البدء والوصول</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> مباشرة من المتصفح (لا يحتاج تحميل)</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> يحتاج تحميل مساحة كبيرة من المتجر</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">دعم الأجهزة</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> يعمل على كل الهواتف وأجهزة الكمبيوتر</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-yellow-500 ml-2" size={20} /> مخصص للهواتف فقط</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">نظام الإعلانات</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> نظيف تماماً بدون إعلانات</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> يعرض إعلانات تقطع اللعب</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">التكلفة والشراء</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> مجاني 100% بدون عملات افتراضية</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> يتطلب شحن وعملات افتراضية</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">تحكم بالشاشة (Zoom)</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> متوفر (تحكم يدوي وأوتوماتيكي للوضوح)</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-yellow-500 ml-2" size={20} /> متوفر ولكن محدود</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="mb-12 bg-gray-800 p-6 rounded-lg border border-gray-700">
        <h2 className="text-2xl font-bold mb-4 text-white">الخلاصة: ليه تختار "لعبتنا" للدومينو؟</h2>
        <p className="text-lg leading-relaxed text-gray-300">
          إذا كان يهمك اللعب فوراً بدون انتظار تحميل، واللعب على شاشة الكمبيوتر الكبيرة أو الهاتف بنفس السهولة، وبدون أن تخسر أموالك في شحن عملات افتراضية، فمنصة <strong>لعبتنا</strong> تقدم لك أفضل تجربة دومينو مصرية أصيلة وبشكل مجاني تماماً.
        </p>
      </div>

      <div className="text-center">
        <Link href="https://le3betna-game.vercel.app" className="inline-flex items-center gap-2 bg-[var(--accent)] text-white font-bold py-4 px-8 rounded-full hover:scale-105 transition-transform text-xl shadow-lg shadow-blue-500/30">
          <Play size={24} fill="currentColor" /> العب دومينو الآن
        </Link>
      </div>
    </div>
  );
}
