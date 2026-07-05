import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async rewrites() {
    return [
      {
        source: '/play',
        destination: 'https://le3betna-game.vercel.app',
      },
      {
        source: '/play/:path*',
        destination: 'https://le3betna-game.vercel.app/:path*',
      },
    ];
  },
};

export default nextConfig;
