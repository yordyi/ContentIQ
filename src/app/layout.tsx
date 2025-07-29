import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "ContentIQ - AI爬虫收益计算器",
  description: "计算您的内容被AI训练的潜在价值",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="zh">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
}
