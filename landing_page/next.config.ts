import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      {
        source: '/:path*',
        has: [
          {
            type: 'host',
            value: 'le3betna.vercel.app',
          },
        ],
        destination: 'https://le3betna.cc.cd/:path*',
        permanent: true,
      },
    ];
  },
};

export default nextConfig;
