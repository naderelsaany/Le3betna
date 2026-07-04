"use client";

import { useAuth } from "@/hooks/useAuth";
import { useRouter } from "next/navigation";

import { useState } from "react";
import { PrivateChat } from "@/components/dashboard/PrivateChat";
import { FriendsList, FriendData } from "@/components/dashboard/FriendsList";
import { usePresence } from "@/hooks/usePresence";

export default function DashboardPage() {
  const { user, loading, signInWithGoogle, logout } = useAuth();
  const router = useRouter();
  const [activeChatFriend, setActiveChatFriend] = useState<FriendData | null>(null);

  // Activate presence
  usePresence(user);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        {/* Skeleton loader */}
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-white/5 animate-pulse" />
          <div className="w-40 h-5 bg-white/5 rounded-full animate-pulse" />
          <div className="w-24 h-3 bg-white/5 rounded-full animate-pulse" />
        </div>
      </div>
    );
  }

  const isAnonymous = !user || user.isAnonymous;

  return (
    <div className="min-h-screen bg-background text-foreground">
      {/* Navbar */}
      <header className="border-b border-white/5 bg-secondary/20 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between">
          <h1 className="text-2xl font-bold tracking-tighter text-primary flex items-center gap-2.5">
              <img src="/app_icon.png" alt="لعبتنا" className="w-8 h-8 rounded-lg shadow-sm" />
            لعبتنا
          </h1>

          <div className="flex items-center gap-4">
            {isAnonymous ? (
              <button
                onClick={signInWithGoogle}
                className="bg-white/10 hover:bg-white/20 text-white px-4 py-2 rounded-full text-sm font-medium transition-colors flex items-center gap-2"
              >
                <svg viewBox="0 0 24 24" className="w-5 h-5 fill-current">
                  <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
                  <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
                  <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05"/>
                  <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
                </svg>
                تسجيل الدخول
              </button>
            ) : (
              <div className="flex items-center gap-3">
                <div className="flex items-center gap-3 bg-white/5 pl-2 pr-4 py-1.5 rounded-full border border-white/10">
                  {user?.photoURL && (
                    <img src={user.photoURL} alt="Profile" className="w-8 h-8 rounded-full border border-white/20" />
                  )}
                  <span className="text-sm font-medium">{user?.displayName}</span>
                </div>
                <button
                  onClick={logout}
                  className="bg-red-500/10 hover:bg-red-500/20 text-red-500 p-2 rounded-full border border-red-500/20 transition-colors"
                  title="تسجيل الخروج"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                    <polyline points="16 17 21 12 16 7"></polyline>
                    <line x1="21" y1="12" x2="9" y2="12"></line>
                  </svg>
                </button>
              </div>
            )}
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 py-8 grid grid-cols-1 lg:grid-cols-3 gap-8">
        
        {/* Left Column: Games (Takes up 2 cols on lg) */}
        <div className="lg:col-span-2 space-y-8">
          <section>
            <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
              <svg viewBox="0 0 24 24" className="w-5 h-5 text-primary" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M6 12h4l2 8 3-16 2 8h4"/>
              </svg>
              الألعاب المتاحة
            </h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              
              {/* Connect 4 Card */}
              <div 
                onClick={() => router.push('/play?game=connect4')}
                className="group relative overflow-hidden bg-card border border-white/10 rounded-3xl p-6 cursor-pointer hover:border-primary/50 transition-all duration-300 shadow-lg hover:shadow-[0_0_30px_rgba(94,106,210,0.15)] hover:-translate-y-1"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-primary/10 rounded-full blur-3xl -mr-10 -mt-10 group-hover:bg-primary/20 transition-all" />
                
                {/* Game icon */}
                <div className="w-12 h-12 bg-primary/10 rounded-xl flex items-center justify-center mb-4 group-hover:bg-primary/20 transition-colors">
                  <svg viewBox="0 0 24 24" className="w-6 h-6 text-primary" fill="none" stroke="currentColor" strokeWidth="2">
                    <rect x="3" y="3" width="18" height="18" rx="3" />
                    <circle cx="9" cy="9" r="2" fill="#3b82f6" stroke="none"/>
                    <circle cx="15" cy="9" r="2" fill="#ef4444" stroke="none"/>
                    <circle cx="9" cy="15" r="2" fill="#ef4444" stroke="none"/>
                    <circle cx="15" cy="15" r="2" fill="#3b82f6" stroke="none"/>
                  </svg>
                </div>

                <h3 className="text-2xl font-bold mb-2">أربعة في صف</h3>
                <p className="text-muted-foreground text-sm mb-6 max-w-[80%]">
                  اللعبة الكلاسيكية للتفكير الاستراتيجي. تحدى أصدقائك أو لاعبين عشوائيين.
                </p>
                
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold px-3 py-1 bg-green-500/20 text-green-400 rounded-full">جاهزة للعب</span>
                  <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
                    <svg viewBox="0 0 24 24" className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <path d="m9 18 6-6-6-6"/>
                    </svg>
                  </div>
                </div>
              </div>

              {/* Ludo Card */}
              <div 
                onClick={() => router.push('/play?game=ludo')}
                className="group relative overflow-hidden bg-card border border-white/10 rounded-3xl p-6 cursor-pointer hover:border-red-500/50 transition-all duration-300 shadow-lg hover:shadow-[0_0_30px_rgba(239,68,68,0.15)] hover:-translate-y-1"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-red-500/10 rounded-full blur-3xl -mr-10 -mt-10 group-hover:bg-red-500/20 transition-all" />
                
                {/* Game icon */}
                <div className="w-12 h-12 bg-red-500/10 rounded-xl flex items-center justify-center mb-4 group-hover:bg-red-500/20 transition-colors">
                  <svg viewBox="0 0 40 40" className="w-6 h-6">
                    <rect x="4" y="4" width="32" height="32" rx="6" fill="none" stroke="#ef4444" strokeWidth="3"/>
                    <circle cx="13" cy="13" r="3.5" fill="#ef4444"/>
                    <circle cx="27" cy="13" r="3.5" fill="#ef4444"/>
                    <circle cx="20" cy="20" r="3.5" fill="#ef4444"/>
                    <circle cx="13" cy="27" r="3.5" fill="#ef4444"/>
                    <circle cx="27" cy="27" r="3.5" fill="#ef4444"/>
                  </svg>
                </div>

                <h3 className="text-2xl font-bold mb-2">لودو (Ludo)</h3>
                <p className="text-muted-foreground text-sm mb-6 max-w-[80%]">
                  لعبة الطاولة الشهيرة لأربعة لاعبين. العب مع أصدقائك الآن.
                </p>
                
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold px-3 py-1 bg-green-500/20 text-green-400 rounded-full">جاهزة للعب</span>
                  <div className="w-10 h-10 rounded-full bg-red-500/20 flex items-center justify-center group-hover:bg-red-500 group-hover:text-white transition-colors">
                    <svg viewBox="0 0 24 24" className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <path d="m9 18 6-6-6-6"/>
                    </svg>
                  </div>
                </div>
              </div>

              {/* Domino Card */}
              <div 
                onClick={() => router.push('/play?game=domino')}
                className="group relative overflow-hidden bg-card border border-white/10 rounded-3xl p-6 cursor-pointer hover:border-yellow-500/50 transition-all duration-300 shadow-lg hover:shadow-[0_0_30px_rgba(234,179,8,0.15)] hover:-translate-y-1"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-yellow-500/10 rounded-full blur-3xl -mr-10 -mt-10 group-hover:bg-yellow-500/20 transition-all" />
                
                {/* Game icon */}
                <div className="w-12 h-12 bg-yellow-500/10 rounded-xl flex items-center justify-center mb-4 group-hover:bg-yellow-500/20 transition-colors">
                  <svg viewBox="0 0 40 40" className="w-6 h-6">
                    <rect x="4" y="10" width="32" height="20" rx="3" fill="none" stroke="#eab308" strokeWidth="3"/>
                    <line x1="20" y1="10" x2="20" y2="30" stroke="#eab308" strokeWidth="3"/>
                    <circle cx="12" cy="15" r="2.5" fill="#eab308"/>
                    <circle cx="28" cy="15" r="2.5" fill="#eab308"/>
                    <circle cx="12" cy="25" r="2.5" fill="#eab308"/>
                    <circle cx="28" cy="25" r="2.5" fill="#eab308"/>
                  </svg>
                </div>

                <h3 className="text-2xl font-bold mb-2">دومينو</h3>
                <p className="text-muted-foreground text-sm mb-6 max-w-[80%]">
                  لعبة الدومينو بالقواعد المصرية (بدون سحب). العب 1 ضد 1 أو نظام فرق 4 لاعبين.
                </p>
                
                <div className="flex items-center justify-between">
                  <span className="text-xs font-bold px-3 py-1 bg-green-500/20 text-green-400 rounded-full">جديد</span>
                  <div className="w-10 h-10 rounded-full bg-yellow-500/20 flex items-center justify-center group-hover:bg-yellow-500 group-hover:text-white transition-colors">
                    <svg viewBox="0 0 24 24" className="w-5 h-5" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                      <path d="m9 18 6-6-6-6"/>
                    </svg>
                  </div>
                </div>
              </div>

            </div>
          </section>

          {/* Private Chat */}
          <section>
            <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
              <svg viewBox="0 0 24 24" className="w-5 h-5 text-primary" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/>
              </svg>
              المحادثات الخاصة
            </h2>
            <div className="h-80 border border-white/10 rounded-3xl overflow-hidden shadow-lg bg-card">
              <PrivateChat user={user} friend={activeChatFriend} />
            </div>
          </section>
        </div>

        {/* Right Column: Friends/Social */}
        <div className="space-y-8">
          <section className="bg-card border border-white/10 rounded-3xl p-6 h-[500px] flex flex-col">
            <h2 className="text-xl font-bold mb-4 flex items-center gap-2">
              <svg viewBox="0 0 24 24" className="w-5 h-5 text-primary" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
                <path d="M22 21v-2a4 4 0 0 0-3-3.87"/>
                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
              </svg>
              الأصدقاء والدعوات
            </h2>
            
            {isAnonymous ? (
              <div className="flex-1 flex flex-col items-center justify-center text-center gap-4">
                <div className="w-16 h-16 bg-primary/15 rounded-2xl flex items-center justify-center">
                  <svg viewBox="0 0 24 24" className="w-8 h-8 text-primary" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <rect width="18" height="11" x="3" y="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                  </svg>
                </div>
                <p className="text-muted-foreground text-sm max-w-[200px]">
                  سجل دخول بحساب جوجل عشان تقدر تضيف أصدقاء وتبعتلهم دعوات مباشرة.
                </p>
                <button
                  onClick={signInWithGoogle}
                  className="bg-primary hover:bg-primary/90 text-primary-foreground px-6 py-2 rounded-full text-sm font-medium transition-colors"
                >
                  تسجيل الدخول
                </button>
              </div>
            ) : (
              <div className="flex-1 h-full overflow-hidden">
                <FriendsList user={user} onSelectChat={(friend) => setActiveChatFriend(friend)} />
              </div>
            )}
          </section>
        </div>

      </main>
    </div>
  );
}
