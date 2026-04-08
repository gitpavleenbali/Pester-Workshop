import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "export",
  basePath: "/Pester-Workshop",
  images: { unoptimized: true },
  trailingSlash: false,
};

export default nextConfig;
