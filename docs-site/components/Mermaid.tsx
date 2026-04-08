"use client";

import { useEffect, useRef } from "react";

export default function Mermaid({ chart }: { chart: string }) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    let cancelled = false;
    import("mermaid").then((m) => {
      if (cancelled) return;
      m.default.initialize({
        startOnLoad: false,
        theme: "dark",
        themeVariables: {
          primaryColor: "#8b5cf6",
          primaryTextColor: "#f8fafc",
          primaryBorderColor: "#6366f1",
          lineColor: "#64748b",
          secondaryColor: "#1e293b",
          tertiaryColor: "#0f172a",
        },
      });
      const id = `mermaid-${Math.random().toString(36).slice(2, 9)}`;
      m.default.render(id, chart).then(({ svg }) => {
        if (!cancelled && ref.current) {
          ref.current.innerHTML = svg;
        }
      });
    });
    return () => {
      cancelled = true;
    };
  }, [chart]);

  return (
    <div
      ref={ref}
      className="mermaid-container flex justify-center my-6 p-4 bg-slate-900/50 rounded-xl border border-slate-700/50"
    />
  );
}
