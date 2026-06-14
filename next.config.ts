import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  images: {
    remotePatterns: [
      { protocol: "https", hostname: "**.supabase.co" },
      { protocol: "https", hostname: "images.unsplash.com" }
    ]
  },
  async headers() {
    return [
      {
        source: "/api/geo/:path*",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
          { key: "Access-Control-Allow-Methods", value: "GET" },
          { key: "Cache-Control", value: "public, s-maxage=3600, stale-while-revalidate=86400" }
        ]
      },
      {
        source: "/(llms.txt|company.json|products.json|faqs.json)",
        headers: [
          { key: "Access-Control-Allow-Origin", value: "*" },
          { key: "Cache-Control", value: "public, s-maxage=86400" }
        ]
      }
    ];
  }
};

export default nextConfig;
