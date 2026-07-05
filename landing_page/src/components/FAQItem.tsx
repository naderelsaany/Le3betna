'use client';
import { useState, useId } from 'react';
import { ChevronDown } from 'lucide-react';

export default function FAQItem({ question, answer }: { question: string, answer: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const contentId = useId();
  
  return (
    <article className="bg-[var(--bg-card)] rounded-[16px] glass-border overflow-hidden">
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className="w-full flex items-center justify-between p-6 text-right font-tajawal font-bold text-lg text-[var(--text-main)] hover:bg-[rgba(255,255,255,0.02)] transition-colors"
        aria-expanded={isOpen}
        aria-controls={contentId}
      >
        <span>{question}</span>
        <ChevronDown className={`w-5 h-5 transition-transform duration-300 ${isOpen ? 'rotate-180 text-[var(--accent)]' : 'text-[var(--text-muted)]'}`} />
      </button>
      <div 
        id={contentId}
        className={`grid transition-all duration-300 ease-in-out ${isOpen ? 'grid-rows-[1fr] opacity-100' : 'grid-rows-[0fr] opacity-0'}`}
      >
        <div className="overflow-hidden">
          <p className="px-6 pb-6 text-[var(--text-sub)] font-tajawal text-[15px] leading-relaxed">
            {answer}
          </p>
        </div>
      </div>
    </article>
  );
}
