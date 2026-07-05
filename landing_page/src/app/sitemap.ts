import type { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://le3betna.vercel.app';

  const staticPages: MetadataRoute.Sitemap = ['', '/play', '/privacy', '/terms'].map(route => ({
    url: `${baseUrl}${route}`,
    lastModified: new Date(),
    changeFrequency: (route === '' ? 'daily' : 'monthly') as "daily" | "monthly",
    priority: route === '' ? 1 : (route === '/play' ? 0.9 : 0.8),
  }));

  return staticPages;
}
