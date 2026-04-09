import type { NextConfig } from "next";

const isProd = process.env.NODE_ENV === "production" && !process.env.LOCAL_PREVIEW;

const nextConfig: NextConfig = {
  output: "export",
  basePath: isProd ? "/Pester-Workshop" : "",
  images: { unoptimized: true },
  trailingSlash: false,
};

export default nextConfig;
