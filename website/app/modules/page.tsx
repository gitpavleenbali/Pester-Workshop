import Nav from "@/components/Nav";
import DocsSidebar from "@/components/DocsSidebar";
import Footer from "@/components/Footer";
import Link from "next/link";
import { MODULE_SLUGS, MODULE_META } from "@/lib/modules";
import { ArrowRight, Clock } from "lucide-react";

export default function ModulesIndex() {
  return (
    <>
      <Nav />
      <div className="flex min-h-[calc(100vh-56px)]">
        <DocsSidebar />
        <main className="flex-1 px-6 md:px-10 py-10 max-w-4xl">
          <div className="text-xs uppercase tracking-widest text-violet-400 font-bold mb-1">
            Day 1 — Presentation Materials
          </div>
          <h1 className="text-3xl font-extrabold mb-3 bg-gradient-to-r from-cyan-400 to-violet-400 bg-clip-text text-transparent">
            Workshop Modules
          </h1>
          <p className="text-slate-400 mb-10 max-w-xl leading-relaxed">
            Three enriched presentations with collapsible sections, Mermaid diagrams,
            and external references. Click any module to read the full content.
          </p>

          <div className="space-y-4">
            {MODULE_SLUGS.map((slug) => {
              const meta = MODULE_META[slug];
              const num = slug.split("-")[0];
              return (
                <Link
                  key={slug}
                  href={`/modules/${slug}`}
                  className="group flex gap-5 p-6 rounded-xl border border-slate-700/50 bg-slate-800/20 hover:border-violet-500/30 hover:bg-violet-500/5 transition-all"
                >
                  <div className="w-14 h-14 rounded-xl bg-gradient-to-br from-violet-500/20 to-blue-500/20 flex items-center justify-center text-xl font-extrabold text-violet-400 shrink-0">
                    {num}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h2 className="text-lg font-bold group-hover:text-violet-300 transition-colors">
                      {meta.title}
                    </h2>
                    <div className="flex items-center gap-3 text-xs text-slate-500 mt-1 mb-2">
                      <span className="flex items-center gap-1"><Clock size={12} /> {meta.duration}</span>
                    </div>
                    <p className="text-sm text-slate-400 leading-relaxed">{meta.description}</p>
                  </div>
                  <ArrowRight size={18} className="text-slate-600 group-hover:text-violet-400 self-center transition-colors shrink-0" />
                </Link>
              );
            })}
          </div>
        </main>
      </div>
      <Footer />
    </>
  );
}
