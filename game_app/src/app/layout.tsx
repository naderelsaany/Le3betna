import type { Metadata, Viewport } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import Script from "next/script";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  metadataBase: new URL("https://le3betna-game.vercel.app"),
  title: {
    default: "لعبتنا | دومينو ولودو أونلاين مجاناً",
    template: "%s | لعبتنا",
  },
  applicationName: "لعبتنا",
  description: "العب أقوى الألعاب اللوحية المصرية أونلاين مع أصدقائك. دومينو، لودو، وأربعة في صف بدون تحميل وبدون إعلانات مزعجة. ادخل العب فوراً!",
  keywords: ["لعبة دومينو", "دومينو مصري", "لودو", "ألعاب لوحية", "لعبة أونلاين", "لعبتنا", "أربعة في صف"],
  manifest: "/manifest.json",
  icons: {
    icon: "/icon.png",
    apple: "/apple-icon.png",
    shortcut: "/favicon.ico",
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: "black-translucent",
    title: "لعبتنا",
  },
  openGraph: {
    title: "لعبتنا | دومينو ولودو أونلاين مجاناً",
    description: "العب أقوى الألعاب اللوحية المصرية أونلاين مع أصدقائك بدون تحميل.",
    url: "/",
    siteName: "لعبتنا",
    images: [
      {
        url: "https://le3betna.vercel.app/logo.png",
        width: 1200,
        height: 630,
        alt: "لعبتنا - منصة ألعاب لوحية",
      },
    ],
    locale: "ar_EG",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "لعبتنا | العب دومينو ولودو أونلاين",
    description: "تحدى أصدقائك في أقوى الألعاب اللوحية المصرية.",
    images: ["https://le3betna.vercel.app/logo.png"],
  },
  alternates: {
    canonical: "/",
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  viewportFit: "cover",
  themeColor: "#0D0D1A",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="ar"
      dir="rtl"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased dark`}
    >
      <body className="min-h-full min-h-dvh flex flex-col bg-background text-foreground overscroll-none">
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "SoftwareApplication",
              "name": "لعبتنا - Le3betna Game",
              "applicationCategory": "GameApplication",
              "operatingSystem": "Web, Android, iOS",
              "offers": {
                "@type": "Offer",
                "price": "0",
                "priceCurrency": "EGP"
              },
              "description": "منصة ألعاب لوحية مصرية تتيح لك لعب الدومينو واللودو مع أصدقائك أونلاين.",
              "url": "https://le3betna-game.vercel.app"
            }),
          }}
        />
        <div className="hidden landscape-lock-overlay fixed inset-0 z-[99999] bg-background/95 backdrop-blur-md flex-col items-center justify-center text-center p-8 gap-6">
          <div className="w-24 h-24 border-4 border-primary rounded-3xl flex items-center justify-center animate-[spin_2s_ease-in-out_infinite]">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="text-primary">
              <rect width="14" height="20" x="5" y="2" rx="2" ry="2"/>
              <path d="M12 18h.01"/>
            </svg>
          </div>
          <h2 className="text-3xl font-bold text-primary tracking-tight">يرجى تدوير الهاتف</h2>
          <p className="text-muted-foreground text-lg max-w-sm leading-relaxed">
            لعبتنا مصممة للعمل في الوضع الرأسي (Portrait) فقط لتوفير أفضل تجربة لعب. يرجى إرجاع الهاتف لوضعه الطبيعي.
          </p>
        </div>
        {children}
        <Script id="register-sw" strategy="afterInteractive">
          {`
            if ('serviceWorker' in navigator) {
              window.addEventListener('load', function() {
                navigator.serviceWorker.register('/sw.js').then(
                  function(registration) {
                    console.log('Service Worker registration successful with scope: ', registration.scope);
                  },
                  function(err) {
                    console.log('Service Worker registration failed: ', err);
                  }
                );
              });
            }
          `}
        </Script>
        {/* Google Analytics */}
        <Script src="https://www.googletagmanager.com/gtag/js?id=G-LMGQ3RL48H" strategy="afterInteractive" />
        <Script id="google-analytics" strategy="afterInteractive">
          {`
            window.dataLayer = window.dataLayer || [];
            function gtag(){dataLayer.push(arguments);}
            gtag('js', new Date());
            gtag('config', 'G-LMGQ3RL48H');
          `}
        </Script>
      </body>
    </html>
  );
}
