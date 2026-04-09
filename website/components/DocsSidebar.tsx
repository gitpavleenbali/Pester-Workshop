"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { BookOpen, Building2, Shield, FlaskConical, Code2, GitCompare, Layers, Home, ChevronRight } from "lucide-react";

const sections = [
  {
    label: "Workshop",
    items: [
      { href: "/", label: "Home", icon: Home },
      { href: "/lab", label: "Interactive Lab", icon: FlaskConical },
      { href: "/pscode", label: "PSCode Modules", icon: Code2 },
      { href: "/mapping", label: "Test Mapping", icon: GitCompare },
      { href: "/concepts", label: "Pester Concepts", icon: Layers },
    ],
  },
  {
    label: "Modules",
    items: [
      { href: "/modules/01-pester-introduction", label: "01. Pester Introduction", icon: BookOpen },
      { href: "/modules/02-enterprise-positioning", label: "02. Enterprise Positioning", icon: Building2 },
      { href: "/modules/03-mocking-and-test-isolation", label: "03. Mocking & Isolation", icon: Shield },
    ],
  },
];

export default function DocsSidebar() {
  const pathname = usePathname();

  return (
    <aside className="hidden lg:block w-60 shrink-0 border-r border-slate-800 bg-[#060a12]">
      <div className="sticky top-14 h-[calc(100vh-56px)] overflow-y-auto py-4">
        {sections.map((section) => (
          <div key={section.label} className="mb-4">
            <div className="px-4 py-1 text-[10px] uppercase tracking-widest text-slate-500 font-bold">
              {section.label}
            </div>
            {section.items.map((item) => {
              const active =
                pathname === item.href ||
                pathname === `/Pester-Workshop${item.href}`;
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`flex items-center gap-2 px-4 py-2 text-[13px] transition-colors ${
                    active
                      ? "text-violet-400 bg-violet-500/10 border-r-2 border-violet-400"
                      : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
                  }`}
                >
                  <item.icon size={14} className="shrink-0" />
                  <span className="truncate">{item.label}</span>
                </Link>
              );
            })}
          </div>
        ))}
      </div>
    </aside>
  );
}
