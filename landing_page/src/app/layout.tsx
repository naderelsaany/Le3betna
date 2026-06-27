import type { Metadata } from "next";
import { Cairo, Tajawal } from "next/font/google";
import Navbar from "../components/Navbar";
import Footer from "../components/Footer";
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
  title: "Le3betna | لعبتنا - أول منصة ألعاب لوحية مصرية",
  description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
    },
  },
  openGraph: {
    title: "لعبتنا | دومينو ولودو أونلاين — Le3betna",
    description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
    url: "/",
    siteName: "Le3betna",
    images: [
      {
        url: "/logo.png", // will resolve to https://le3betna.vercel.app/logo.png
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
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "WebApplication",
              name: "لعبتنا - Le3betna",
              description: "أول منصة ألعاب لوحية مصرية. العب دومينو، لودو، أربعة في صف مجاناً بدون تحميل.",
              applicationCategory: "GameApplication",
              operatingSystem: "All",
              inLanguage: "ar",
              offers: {
                "@type": "Offer",
                price: "0",
                priceCurrency: "EGP",
              },
            }),
          }}
        />
        <Navbar />
        <div className="pt-24 min-h-screen">
          {children}
        </div>
        <Footer />
        <Analytics />
      </body>
    </html>
  );
}

