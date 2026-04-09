import { notFound } from "next/navigation";
import { getModuleContent, MODULE_SLUGS, MODULE_META } from "@/lib/modules";
import Nav from "@/components/Nav";
import DocsSidebar from "@/components/DocsSidebar";
import Footer from "@/components/Footer";
import MarkdownRenderer from "@/components/MarkdownRenderer";

export function generateStaticParams() {
  return MODULE_SLUGS.map((slug) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const meta = MODULE_META[slug];
  if (!meta) return { title: "Not Found" };
  return { title: `${meta.title} — Pester Workshop` };
}

export default async function ModulePage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const meta = MODULE_META[slug];
  if (!meta) notFound();

  const content = getModuleContent(slug);

  return (
    <>
      <Nav />
      <div className="flex">
        <DocsSidebar />
        <MarkdownRenderer content={content} title={meta.title} />
      </div>
    </>
  );
}
