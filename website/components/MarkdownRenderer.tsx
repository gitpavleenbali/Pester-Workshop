"use client";

import { useEffect, useState } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import rehypeRaw from "rehype-raw";
import rehypeSlug from "rehype-slug";
import dynamic from "next/dynamic";

const MermaidBlock = dynamic(() => import("@/components/Mermaid"), { ssr: false });

interface TocItem {
  id: string;
  text: string;
  level: number;
}

function extractToc(markdown: string): TocItem[] {
  const items: TocItem[] = [];
  const lines = markdown.split("\n");
  for (const line of lines) {
    const match = line.match(/^(#{2,3})\s+(.+)$/);
    if (match) {
      const level = match[1].length;
      const text = match[2].replace(/[`*_\[\]()]/g, "").trim();
      const id = text
        .toLowerCase()
        .replace(/[^\w\s-]/g, "")
        .replace(/\s+/g, "-")
        .replace(/-+/g, "-");
      items.push({ id, text, level });
    }
  }
  return items;
}

export default function MarkdownRenderer({
  content,
  title,
}: {
  content: string;
  title: string;
}) {
  const [activeId, setActiveId] = useState("");
  const toc = extractToc(content);

  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            setActiveId(entry.target.id);
          }
        }
      },
      { rootMargin: "-80px 0px -80% 0px" }
    );

    const headings = document.querySelectorAll("h2[id], h3[id]");
    headings.forEach((h) => observer.observe(h));
    return () => observer.disconnect();
  }, [content]);

  return (
    <div className="flex gap-0 min-h-[calc(100vh-56px)]">
      {/* Right TOC */}
      <aside className="hidden xl:block w-64 shrink-0 order-2">
        <div className="sticky top-16 p-4 max-h-[calc(100vh-64px)] overflow-y-auto">
          <div className="text-[10px] uppercase tracking-widest text-slate-500 font-bold mb-3">
            On this page
          </div>
          <nav className="space-y-0.5">
            {toc.map((item) => (
              <a
                key={item.id}
                href={`#${item.id}`}
                className={`block text-xs py-1 transition-colors border-l-2 ${
                  item.level === 3 ? "pl-5" : "pl-3"
                } ${
                  activeId === item.id
                    ? "text-violet-400 border-violet-400"
                    : "text-slate-500 hover:text-slate-300 border-transparent"
                }`}
              >
                {item.text}
              </a>
            ))}
          </nav>
        </div>
      </aside>

      {/* Main content */}
      <article className="flex-1 min-w-0 max-w-4xl px-6 md:px-10 py-10 order-1">
        <div className="prose prose-invert prose-slate max-w-none
          prose-headings:scroll-mt-20
          prose-h1:text-3xl prose-h1:font-extrabold prose-h1:bg-gradient-to-r prose-h1:from-cyan-400 prose-h1:to-violet-400 prose-h1:bg-clip-text prose-h1:text-transparent
          prose-h2:text-xl prose-h2:font-bold prose-h2:text-slate-100 prose-h2:border-b prose-h2:border-slate-700/50 prose-h2:pb-2 prose-h2:mt-12
          prose-h3:text-base prose-h3:font-semibold prose-h3:text-cyan-400
          prose-p:text-slate-300 prose-p:leading-relaxed
          prose-a:text-cyan-400 prose-a:no-underline hover:prose-a:underline
          prose-strong:text-slate-100
          prose-code:text-violet-400 prose-code:bg-violet-500/10 prose-code:px-1.5 prose-code:py-0.5 prose-code:rounded prose-code:text-sm prose-code:before:content-none prose-code:after:content-none
          prose-pre:bg-[#0d1117] prose-pre:border prose-pre:border-slate-700 prose-pre:rounded-xl
          prose-table:text-sm
          prose-th:bg-violet-500/8 prose-th:text-violet-300 prose-th:font-semibold prose-th:text-xs prose-th:uppercase prose-th:tracking-wider
          prose-td:border-slate-700 prose-td:text-slate-300 prose-td:py-2
          prose-tr:border-slate-700
          prose-blockquote:border-violet-500/50 prose-blockquote:bg-violet-500/5 prose-blockquote:rounded-r-lg prose-blockquote:py-1 prose-blockquote:text-slate-300
          prose-li:text-slate-300 prose-li:marker:text-violet-400
          prose-hr:border-slate-700/50
        ">
          <ReactMarkdown
            remarkPlugins={[remarkGfm]}
            rehypePlugins={[rehypeRaw, rehypeSlug]}
            components={{
              code({ className, children, ...props }) {
                const match = /language-(\w+)/.exec(className || "");
                const lang = match?.[1];
                const code = String(children).replace(/\n$/, "");

                if (lang === "mermaid") {
                  return <MermaidBlock chart={code} />;
                }

                if (lang) {
                  return (
                    <code
                      className={`block text-[13px] leading-relaxed ${className}`}
                      {...props}
                    >
                      {children}
                    </code>
                  );
                }

                return (
                  <code className={className} {...props}>
                    {children}
                  </code>
                );
              },
            }}
          >
            {content}
          </ReactMarkdown>
        </div>
      </article>
    </div>
  );
}
