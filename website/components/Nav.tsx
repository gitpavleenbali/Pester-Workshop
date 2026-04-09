"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { FlaskConical, BookOpen, Code2, GitCompare, Layers, Home, ExternalLink, Play } from "lucide-react";

const links = [
  { href: "/", label: "Home", icon: Home },
  { href: "/modules", label: "Modules", icon: BookOpen },
  { href: "/lab", label: "Lab", icon: FlaskConical },
  { href: "/simulation", label: "Simulation", icon: Play },
  { href: "/pscode", label: "PSCode", icon: Code2 },
  { href: "/mapping", label: "Mapping", icon: GitCompare },
  { href: "/concepts", label: "Concepts", icon: Layers },
];

export default function Nav() {
  const pathname = usePathname();
  const base = process.env.__NEXT_ROUTER_BASEPATH || "";

  return (
    <nav className="sticky top-0 z-50 bg-[#060a12]/95 backdrop-blur-sm border-b border-slate-800">
      <div className="max-w-6xl mx-auto px-4 h-14 flex items-center gap-6">
        <Link href="/" className="font-extrabold text-cyan-400 tracking-tight text-sm whitespace-nowrap">
          PESTER WORKSHOP
        </Link>

        <div className="hidden md:flex items-center gap-1 flex-1">
          {links.map(({ href, label, icon: Icon }) => {
            const fullHref = `${base}${href}`;
            const active = pathname === fullHref || pathname === href;
            return (
              <Link
                key={href}
                href={href}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-md text-xs font-medium transition-colors ${
                  active
                    ? "bg-violet-500/10 text-violet-400"
                    : "text-slate-400 hover:text-slate-200 hover:bg-slate-800/50"
                }`}
              >
                <Icon size={14} />
                {label}
              </Link>
            );
          })}
        </div>

        <a
          href="https://pester.dev"
          target="_blank"
          rel="noopener noreferrer"
          className="text-xs text-slate-500 hover:text-cyan-400 flex items-center gap-1 transition-colors"
        >
          pester.dev <ExternalLink size={10} />
        </a>
      </div>
    </nav>
  );
}
