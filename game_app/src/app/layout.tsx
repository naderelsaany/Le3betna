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
      </body>
    </html>
  );
}
