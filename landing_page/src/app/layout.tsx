import type { Metadata } from "next";
import { Cairo, Tajawal } from "next/font/google";
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

export const metadata: Metadata = {
  title: "Le3betna | لعبتنا - أول منصة ألعاب لوحية مصرية",
  description: "أول منصة ألعاب لوحية مصرية. العب دومينو، ليدو، أربعة في صف مجاناً بدون تحميل.",
  openGraph: {
    title: "لعبتنا | دومينو وليدو أونلاين — Le3betna",
    description: "أول منصة ألعاب لوحية مصرية. العب دومينو، ليدو، أربعة في صف مجاناً بدون تحميل.",
    url: "https://le3betna.com",
    siteName: "Le3betna",
    images: [
      {
        url: "https://le3betna.com/logo.webp",
        width: 512,
        height: 512,
        alt: "شعار لعبتنا",
      },
    ],
    locale: "ar_EG",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "لعبتنا | دومينو وليدو أونلاين — Le3betna",
    description: "أول منصة ألعاب لوحية مصرية. العب دومينو، ليدو، أربعة في صف مجاناً بدون تحميل.",
    images: ["https://le3betna.com/logo.webp"],
  },
  alternates: {
    canonical: "https://le3betna.com",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className={`${cairo.variable} ${tajawal.variable}`}>
      <body className={`font-tajawal min-h-screen antialiased bg-[var(--bg)] text-[var(--text-main)]`}>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "WebApplication",
              name: "لعبتنا - Le3betna",
              description: "أول منصة ألعاب لوحية مصرية. العب دومينو، ليدو، أربعة في صف مجاناً بدون تحميل.",
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
        {children}
      </body>
    </html>
  );
}
