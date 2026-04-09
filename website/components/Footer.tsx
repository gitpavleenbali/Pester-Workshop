import { ExternalLink, Github, BookOpen } from "lucide-react";

const footerLinks = [
  { label: "Pester Docs", href: "https://pester.dev" },
  { label: "Pester GitHub", href: "https://github.com/pester/Pester" },
  { label: "PowerShell Docs", href: "https://learn.microsoft.com/en-us/powershell/" },
];

export default function Footer() {
  return (
    <footer className="border-t border-slate-800 py-10 text-center text-slate-500 text-xs">
      <div className="flex justify-center gap-6 mb-4 flex-wrap">
        {footerLinks.map((l) => (
          <a
            key={l.href}
            href={l.href}
            target="_blank"
            rel="noopener noreferrer"
            className="text-cyan-500/70 hover:text-cyan-400 flex items-center gap-1 transition-colors text-sm"
          >
            {l.label} <ExternalLink size={10} />
          </a>
        ))}
      </div>
      <p>Pester Workshop 2026</p>
    </footer>
  );
}
