"use client";

import { useState } from "react";

interface CalculatorProps {
  url: string;
}

export default function Calculator({ url }: CalculatorProps) {
  const [isAnalyzing, setIsAnalyzing] = useState(false);
  const [result, setResult] = useState<{
    pageCount: number;
    wordCount: number;
    uniqueContent: number;
    estimatedValue: number;
    quality: number;
  } | null>(null);

  const analyzeWebsite = async () => {
    setIsAnalyzing(true);
    
    try {
      // 模拟分析过程，显示更真实的进度
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      // 基于URL生成更真实的模拟数据
      const urlHash = url.split('').reduce((a, b) => {
        a = ((a << 5) - a) + b.charCodeAt(0);
        return a & a;
      }, 0);
      
      // 使用URL哈希值作为种子，生成一致的"分析结果"
      const seededRandom = (seed: number) => {
        const x = Math.sin(seed) * 10000;
        return x - Math.floor(x);
      };
      
      const basePages = Math.abs(urlHash) % 500 + 50;
      const pagesMultiplier = seededRandom(Math.abs(urlHash) + 1) * 3 + 1;
      const pageCount = Math.floor(basePages * pagesMultiplier);
      
      const wordsPerPage = Math.floor(seededRandom(Math.abs(urlHash) + 2) * 400 + 200);
      const wordCount = pageCount * wordsPerPage;
      
      const uniqueContent = Math.floor(seededRandom(Math.abs(urlHash) + 3) * 60 + 30);
      const quality = Math.floor(seededRandom(Math.abs(urlHash) + 4) * 30 + 65);
      
      // 基于内容量和质量计算估算价值
      const baseValue = (wordCount / 1000) * (quality / 100) * (uniqueContent / 100);
      const estimatedValue = Math.floor(baseValue * 100) + 500;
      
      const mockResult = {
        pageCount,
        wordCount,
        uniqueContent,
        estimatedValue,
        quality
      };
      
      setResult(mockResult);
    } catch (error) {
      console.error("分析失败:", error);
    } finally {
      setIsAnalyzing(false);
    }
  };

  return (
    <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-8 mt-8">
      <h2 className="text-2xl font-bold text-white mb-6 text-center">
        分析结果
      </h2>
      
      {!result && !isAnalyzing && (
        <div className="text-center">
          <p className="text-gray-300 mb-6">
            准备分析网站: {url}
          </p>
          <button
            onClick={analyzeWebsite}
            className="px-8 py-4 bg-gradient-to-r from-green-500 to-blue-500 text-white text-lg font-semibold rounded-xl hover:from-green-600 hover:to-blue-600 transition-all duration-300 shadow-lg hover:shadow-xl"
          >
            开始深度分析
          </button>
        </div>
      )}

      {isAnalyzing && (
        <div className="text-center">
          <div className="animate-spin rounded-full h-16 w-16 border-b-2 border-purple-400 mx-auto mb-4"></div>
          <p className="text-gray-300">正在分析网站内容...</p>
        </div>
      )}

      {result && (
        <div className="grid md:grid-cols-2 gap-6">
          <div className="bg-white/10 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-white mb-4">内容统计</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-300">页面数量:</span>
                <span className="text-white font-semibold">{result.pageCount}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">总词数:</span>
                <span className="text-white font-semibold">{result.wordCount.toLocaleString()}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">内容独特性:</span>
                <span className="text-white font-semibold">{result.uniqueContent}%</span>
              </div>
            </div>
          </div>

          <div className="bg-white/10 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-white mb-4">价值评估</h3>
            <div className="space-y-3">
              <div className="flex justify-between">
                <span className="text-gray-300">内容质量:</span>
                <span className="text-white font-semibold">{result.quality}/100</span>
              </div>
              <div className="flex justify-between">
                <span className="text-gray-300">估算价值:</span>
                <span className="text-green-400 font-bold text-xl">
                  ¥{result.estimatedValue.toLocaleString()}
                </span>
              </div>
            </div>
          </div>

          <div className="md:col-span-2 bg-white/10 rounded-xl p-6">
            <h3 className="text-lg font-semibold text-white mb-4">建议</h3>
            <ul className="text-gray-300 space-y-2">
              <li>• 考虑为您的内容添加版权声明</li>
              <li>• 了解robots.txt设置以控制爬虫访问</li>
              <li>• 关注AI公司的内容使用政策</li>
              <li>• 考虑加入内容创作者权益保护组织</li>
            </ul>
          </div>
        </div>
      )}
    </div>
  );
}