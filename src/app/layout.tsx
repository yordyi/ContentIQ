import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ContentIQ - AI爬虫收益计算器",
  description: "计算您的内容被AI训练的潜在价值，分析网站内容质量和AI训练收益估算",
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
