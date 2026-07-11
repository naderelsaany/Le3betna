import type { Metadata } from "next";
import Link from "next/link";
import { CheckCircle2, XCircle, Play } from "lucide-react";

export const metadata: Metadata = {
  title: "لعبتنا ضد يلا لودو (Yalla Ludo) | أيهما أفضل للعب أونلاين؟",
  description: "مقارنة شاملة بين منصة لعبتنا وتطبيق يلا لودو. تعرف على الفرق في المميزات، الإعلانات، واللعب المباشر بدون تحميل.",
  alternates: {
    canonical: "https://le3betna.vercel.app/vs/yalla-ludo",
  }
};

export default function YallaLudoComparison() {
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
      <h1 className="text-4xl font-black mb-6 text-[var(--accent)]">لعبتنا ضد يلا لودو (Yalla Ludo)</h1>
      <p className="text-lg mb-8 text-gray-300">
        هل تبحث عن أفضل بديل لتطبيق يلا لودو؟ في هذه الصفحة سنقارن بين منصة <strong>لعبتنا</strong> وتطبيق <strong>يلا لودو</strong> لنساعدك في اختيار المنصة الأنسب لك للعب مع أصدقائك.
      </p>

      <div className="overflow-x-auto mb-12">
        <table className="w-full text-right border-collapse border border-gray-700 bg-[var(--bg-light)]">
          <thead>
            <tr className="bg-gray-800">
              <th className="p-4 border border-gray-700 w-1/3">الميزة</th>
              <th className="p-4 border border-gray-700 text-center w-1/3 text-[var(--accent)] font-bold">لعبتنا</th>
              <th className="p-4 border border-gray-700 text-center w-1/3 text-gray-400">يلا لودو</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">تحميل وتثبيت</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> لا يحتاج (متصفح مباشر)</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> يحتاج تحميل تطبيق ثقيل</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">الإعلانات</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> بدون إعلانات نهائياً</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> مليء بالإعلانات المزعجة</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">المشتريات داخل اللعبة</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> مجاني بالكامل 100%</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-red-500 ml-2" size={20} /> يعتمد على الشراء (Pay to win)</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">غرف خاصة للأصدقاء</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> نعم (كود 4 أرقام بسيط)</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> نعم</td>
            </tr>
            <tr>
              <td className="p-4 border border-gray-700 font-semibold">الثقافة والتصميم</td>
              <td className="p-4 border border-gray-700 text-center"><CheckCircle2 className="inline text-green-500 ml-2" size={20} /> مصري وعربي أصيل</td>
              <td className="p-4 border border-gray-700 text-center"><XCircle className="inline text-yellow-500 ml-2" size={20} /> تصميم آسيوي عام</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="mb-12 bg-gray-800 p-6 rounded-lg border border-gray-700">
        <h2 className="text-2xl font-bold mb-4 text-white">الخلاصة: ليه تختار "لعبتنا"؟</h2>
        <p className="text-lg leading-relaxed text-gray-300">
          إذا كنت تبحث عن تجربة لعب صافية، سريعة، ومجانية بالكامل للعب اللودو والدومينو مع أصحابك بدون ما تضطر تحمل تطبيقات ثقيلة أو تتفرج على إعلانات كل دقيقة، فإن <strong>لعبتنا</strong> هي البديل المثالي لك. بضغطة زر واحدة تقدر تعمل غرفة وتشارك الكود مع أصحابك وتبدأ اللعب فوراً بدون تعقيد.
        </p>
      </div>

      <div className="text-center">
        <Link href="https://le3betna-game.vercel.app" className="inline-flex items-center gap-2 bg-[var(--accent)] text-white font-bold py-4 px-8 rounded-full hover:scale-105 transition-transform text-xl shadow-lg shadow-blue-500/30">
          <Play size={24} fill="currentColor" /> العب الآن مجاناً
        </Link>
      </div>
    </div>
  );
}
