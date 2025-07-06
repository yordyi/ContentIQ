# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Core Commands
- `npm run dev` - Start development server with Turbopack (faster than standard Next.js dev)
- `npm run build` - Build production version
- `npm run start` - Start production server
- `npm run lint` - Run ESLint for code quality checks

### Development Server
The project uses Next.js 15.3.5 with Turbopack for faster development builds. The dev server typically runs on port 3000, but will automatically use an available port if 3000 is occupied.

## Architecture Overview

### Project Structure
This is a Next.js 15 TypeScript application using the App Router pattern with a component-based architecture for an AI content value calculator.

### Key Architecture Patterns

**State Management Flow:**
- Main page (`src/app/page.tsx`) handles URL input and Calculator component visibility
- Calculator component (`src/components/Calculator.tsx`) manages analysis state and mock data generation
- State flows: URL input → Form submission → Calculator display → Analysis execution → Results display

**Component Hierarchy:**
```
Home (page.tsx)
├── URL Input Form
├── Calculator Component (conditional render)
│   ├── Analysis Button
│   ├── Loading Spinner
│   └── Results Display Grid
└── Feature Cards Grid
```

**Styling Architecture:**
- Uses Tailwind CSS 4.0 with custom utility classes
- Custom CSS classes in `globals.css`:
  - `.glass-morphism` - Backdrop blur effect for cards
  - `.gradient-text` - Text gradient utility
  - `.float-animation` - Floating animation keyframes
- Design system based on purple-blue gradient theme with glassmorphism effects

### Component Design Patterns

**Calculator Component Logic:**
- Implements three-state pattern: idle → analyzing → results
- Uses TypeScript interfaces for type safety on analysis results
- Mock data generation with randomized realistic values
- Async state management with proper loading states

**UI Patterns:**
- Responsive grid layouts (mobile-first approach)
- Conditional rendering based on state
- Glassmorphism design with backdrop-blur effects
- Hover states and smooth transitions

### TypeScript Configuration
- Uses strict mode with path mapping (`@/*` → `./src/*`)
- Client-side components marked with `"use client"` directive
- Proper typing for React components and state management

### Current MVP Status
The application currently generates mock analysis data. The Calculator component simulates a 2-second analysis process and returns randomized metrics including page count, word count, content uniqueness, estimated value, and quality scores.

### Future Development Considerations
- Real website analysis will require API routes and web scraping capabilities
- User authentication system for result history
- Database integration for storing analysis results
- API rate limiting for web scraping operations