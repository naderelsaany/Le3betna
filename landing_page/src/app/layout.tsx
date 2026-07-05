import type { Metadata } from "next";
import { Cairo, Tajawal } from "next/font/google";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
import Script from "next/script";
import "./globals.css";

const cairo = Cairo({
  subsets: ["arabic", "latin"],
  weight: ["700", "800", "900"],
  variable: "--font-cairo",
});

const tajawal = Tajawal({
  subsets: ["arabic"],
  weight: ["400", "500"],
  variable: "--font-tajawal",
});

import { Analytics } from '@vercel/analytics/react';

export const metadata: Metadata = {
  metadataBase: new URL("https://le3betna.vercel.app"),
  title: {
    default: "لعبتنا | أول منصة ألعاب لوحية مصرية",
    template: "%s | لعبتنا",
  },
  applicationName: "لعبتنا",
  description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً وبدون تحميل. استمتع بتجربة ألعاب متصفح سريعة مع أصدقائك في غرف لعب خاصة وتحديات مستمرة.",
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
    },
  },
  icons: {
    icon: "/icon.png",
    apple: "/apple-icon.png",
    shortcut: "/favicon.ico",
  },
  openGraph: {
    title: "لعبتنا | دومينو ولودو أونلاين — Le3betna",
    description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
    url: "/",
    siteName: "لعبتنا",
    images: [
      {
        url: "/logo.png",
        width: 1200,
        height: 630,
        alt: "شعار لعبتنا",
      },
    ],
    locale: "ar_EG",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "لعبتنا | دومينو ولودو أونلاين — Le3betna",
    description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
    images: ["/logo.png"],
  },
  alternates: {
    canonical: "/",
    languages: {
      "ar-EG": "/",
    },
  },
  verification: {
    google: "cNHfGJiXXVT2uaJ8q7mofplDpWfTNvatP1Sqsz6syiU",
  },
};

export const viewport = {
  themeColor: "#0D0D1A",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={`${cairo.variable} ${tajawal.variable}`}>
      <body className={`font-tajawal min-h-screen antialiased bg-[var(--bg)] text-[var(--text-main)]`}>
        <noscript>
          <div className="bg-[var(--accent)] text-white text-center p-4">
            للحصول على أفضل تجربة للعبتنا، يرجى تفعيل جافاسكربت (JavaScript) في متصفحك.
          </div>
        </noscript>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify([
              {
                "@context": "https://schema.org",
                "@type": "WebSite",
                "name": "لعبتنا",
                "alternateName": ["Le3betna", "لعبة لعبتنا"],
                "url": "https://le3betna.vercel.app/"
              },
              {
                "@context": "https://schema.org",
                "@type": "Organization",
                "name": "لعبتنا",
                "url": "https://le3betna.vercel.app/",
                "logo": "https://le3betna.vercel.app/logo.png",
                "description": "منصة ألعاب لوحية مصرية أونلاين مجانية.",
                "sameAs": []
              },
              {
                "@context": "https://schema.org",
                "@type": "WebApplication",
                "name": "لعبتنا - Le3betna",
                "description": "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
                "applicationCategory": "GameApplication",
                "operatingSystem": "All",
                "inLanguage": "ar",
                "url": "https://le3betna.vercel.app/",
                "offers": {
                  "@type": "Offer",
                  "price": "0",
                  "priceCurrency": "EGP"
                }
              }
            ]),
          }}
        />
        <Navbar />
        <div className="pt-24 min-h-screen">
          {children}
        </div>
        <Footer />
        <Analytics />
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

