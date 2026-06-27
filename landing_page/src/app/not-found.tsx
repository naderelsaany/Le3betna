import Link from 'next/link';
import { Home } from 'lucide-react';

export default function NotFound() {
  return (
    <div className="min-h-[70vh] flex flex-col items-center justify-center text-center px-4">
      <h1 className="text-9xl font-cairo font-black text-[var(--accent)] mb-4 drop-shadow-[0_0_15px_rgba(233,69,96,0.3)]">404</h1>
      <h2 className="text-3xl font-cairo font-bold text-[var(--text-main)] mb-6">
        عفواً، هذه الصفحة غير موجودة!
      </h2>
      <p className="text-lg text-[var(--text-sub)] font-tajawal mb-8 max-w-md">
        يبدو أنك وصلت إلى رابط خاطئ أو أن الصفحة التي تبحث عنها قد تم نقلها أو حذفها.
      </p>
      <Link 
        href="/"
        className="glow-btn px-8 py-4 bg-[var(--accent)] rounded-[12px] font-tajawal font-bold text-lg text-white transition-transform duration-150 ease-out hover:scale-95 flex items-center gap-2"
      >
        <Home className="w-5 h-5" />
        <span>العودة للصفحة الرئيسية</span>
      </Link>
    </div>
  );
}
