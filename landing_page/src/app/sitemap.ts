import type { MetadataRoute } from 'next';

export default function sitemap(): MetadataRoute.Sitemap {
  const baseUrl = 'https://le3betna.cc.cd';

  const routes = [
    '',
    '/dominoes',
    '/ludo',
    '/connect4',
    '/vs/yalla-ludo',
    '/vs/domino-cafe',
    '/about',
    '/blog',
    '/privacy',
    '/terms'
  ];

  const staticPages: MetadataRoute.Sitemap = routes.map(route => ({
    url: `${baseUrl}${route}`,
    lastModified: new Date(),
    changeFrequency: (route === '' ? 'daily' : 'weekly') as "daily" | "weekly",
    priority: route === '' ? 1 : 0.8,
  }));

  return staticPages;
}
