"use client";

import { useState } from "react";
import Calculator from "@/components/Calculator";

export default function Home() {
  const [url, setUrl] = useState("");
  const [showCalculator, setShowCalculator] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (url) {
      setShowCalculator(true);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-900 via-blue-900 to-indigo-900">
      <div className="container mx-auto px-4 py-16">
        <div className="max-w-4xl mx-auto text-center">
          <h1 className="text-5xl md:text-6xl font-bold text-white mb-6 float-animation">
            AI爬虫收益计算器
          </h1>
          <p className="text-xl md:text-2xl text-gray-300 mb-12">
            计算您的内容被AI训练的潜在价值
          </p>
          
          <div className="glass-morphism rounded-2xl p-8 mb-12 pulse-glow">
            <form onSubmit={handleSubmit} className="space-y-6">
              <div>
                <input
                  type="url"
                  value={url}
                  onChange={(e) => setUrl(e.target.value)}
                  placeholder="请输入您的网站URL (例如: https://example.com)"
                  className="w-full px-6 py-4 text-lg rounded-xl bg-white/20 border border-white/30 text-white placeholder-gray-300 focus:outline-none focus:ring-2 focus:ring-purple-400 focus:border-transparent transition-all duration-300"
                  required
                />
              </div>
              <button
                type="submit"
                className="w-full md:w-auto px-8 py-4 bg-gradient-to-r from-purple-500 to-pink-500 text-white text-lg font-semibold rounded-xl hover:from-purple-600 hover:to-pink-600 transition-all duration-300 shadow-lg hover:shadow-xl btn-hover-scale"
              >
                开始分析
              </button>
            </form>
          </div>

          {showCalculator && <Calculator url={url} />}

          <div className="grid md:grid-cols-3 gap-8 text-left">
            <div className="glass-morphism rounded-xl p-6 hover:bg-white/20 transition-all duration-300 btn-hover-scale">
              <h3 className="text-xl font-semibold text-white mb-3">📊 内容分析</h3>
              <p className="text-gray-300">
                分析您网站的内容质量、独特性和AI训练价值
              </p>
            </div>
            <div className="glass-morphism rounded-xl p-6 hover:bg-white/20 transition-all duration-300 btn-hover-scale">
              <h3 className="text-xl font-semibold text-white mb-3">💰 收益估算</h3>
              <p className="text-gray-300">
                基于内容量和质量估算AI公司的潜在使用价值
              </p>
            </div>
            <div className="glass-morphism rounded-xl p-6 hover:bg-white/20 transition-all duration-300 btn-hover-scale">
              <h3 className="text-xl font-semibold text-white mb-3">🔒 权益保护</h3>
              <p className="text-gray-300">
                了解如何保护您的内容权益并获得合理补偿
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
