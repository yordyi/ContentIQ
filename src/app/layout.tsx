import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ContentIQ - AI爬虫收益计算器",
  description: "计算您的内容被AI训练的潜在价值，为内容创作者提供收益估算和权益保护建议",
  keywords: "AI训练,内容价值,收益计算,版权保护,内容创作者",
  authors: [{ name: "ContentIQ Team" }],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh-CN">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
