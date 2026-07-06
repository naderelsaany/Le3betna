"use client";

import { motion, AnimatePresence } from "framer-motion";
import { ArrowLeft, ArrowRight } from "lucide-react";
import { DominoState, DominoPiece, DominoEngine } from "@/game-logic/domino";
import React, { useState, useMemo, useEffect, useRef, memo, useId } from "react";

interface DominoBoardProps {
  gameState: DominoState;
  roomStatus: string;
  userId: string;
  players: Record<string, any>;
  onPlacePiece: (pieceId: number, side: "left" | "right") => void;
  onPass: () => void;
  onDraw?: () => void;
}

// -----------------------------
// Shared visual primitives (defs + highlight)
// كل svg يحصل على gradient id فريد عبر useId() لتفادي تعارض
// الـ ids المكررة عند وجود أكثر من عنصر <svg> في نفس الصفحة
// -----------------------------
function TileDefs({ gradientId }: { gradientId: string }) {
  return (
    <defs>
      <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stopColor="#ffffff" />
        <stop offset="100%" stopColor="#f2f4f7" />
      </linearGradient>
    </defs>
  );
}

function TileHighlight({ x, y, w, h }: { x: number; y: number; w: number; h: number }) {
  return (
    <rect
      x={x}
      y={y}
      width={w}
      height={h}
      rx={w * 0.18}
      fill="rgba(255,255,255,.35)"
      pointerEvents="none"
    />
  );
}

function renderDots(
  value: number,
  cx: number,
  cy: number,
  w: number,
  h: number,
  isHorizontal: boolean = false
) {
  const dotPositions: Record<number, [number, number][]> = {
    1: [[0.5, 0.5]],
    2: [
      [0.25, 0.25],
      [0.75, 0.75],
    ],
    3: [
      [0.25, 0.25],
      [0.5, 0.5],
      [0.75, 0.75],
    ],
    4: [
      [0.25, 0.25],
      [0.75, 0.25],
      [0.25, 0.75],
      [0.75, 0.75],
    ],
    5: [
      [0.25, 0.25],
      [0.75, 0.25],
      [0.5, 0.5],
      [0.25, 0.75],
      [0.75, 0.75],
    ],
    6: [
      [0.25, 0.2],
      [0.75, 0.2],
      [0.25, 0.5],
      [0.75, 0.5],
      [0.25, 0.8],
      [0.75, 0.8],
    ],
  };

  const dots = dotPositions[value] || [];
  return dots.map(([dx, dy], i) => {
    const finalDx = isHorizontal ? dy : dx;
    const finalDy = isHorizontal ? 1 - dx : dy;

    return (
      <circle
        key={`${cx}-${cy}-${i}`}
        cx={cx + finalDx * w}
        cy={cy + finalDy * h}
        r={w * 0.08}
        fill="#0f172a"
      />
    );
  });
}

// Domino SVG (VERTICAL - يد اللاعب)
// ملاحظة: لا يوجد drop-shadow على الـ svg نفسه — الظل انتقل للـ wrapper div
// (أرخص للأداء لأن الـ box-shadow لا يعيد حساب blur مع كل تغيير scale/rotate)
const DominoSvg = memo(function DominoSvg({ piece }: { piece: DominoPiece }) {
  const gradientId = useId();
  return (
    <svg viewBox="0 0 100 200" className="w-full h-full">
      <TileDefs gradientId={gradientId} />
      <rect
        x="2"
        y="2"
        width="96"
        height="196"
        rx="10"
        fill={`url(#${gradientId})`}
        stroke="#d8dbe2"
        strokeWidth="2"
      />
      <TileHighlight x={6} y={6} w={88} h={22} />
      <line x1="10" y1="100" x2="90" y2="100" stroke="#d1d5db" strokeWidth="4" strokeLinecap="round" opacity=".8" />
      {renderDots(piece.left, 0, 0, 100, 100)}
      {renderDots(piece.right, 0, 100, 100, 100)}
    </svg>
  );
});

// Horizontal domino للسلسلة (chain)
const ChainDominoSvg = memo(function ChainDominoSvg({
  leftVal,
  rightVal,
  isDouble,
}: {
  leftVal: number;
  rightVal: number;
  isDouble: boolean;
}) {
  const gradientId = useId();

  if (isDouble) {
    return (
      <svg viewBox="0 0 50 100" className="w-full h-full">
        <TileDefs gradientId={gradientId} />
        <rect
          x="2"
          y="2"
          width="46"
          height="96"
          rx="7"
          fill={`url(#${gradientId})`}
          stroke="#d8dbe2"
          strokeWidth="2"
        />
        <TileHighlight x={5} y={5} w={40} h={12} />
        <line x1="8" y1="50" x2="42" y2="50" stroke="#d1d5db" strokeWidth="3" strokeLinecap="round" opacity=".8" />
        {renderDots(leftVal, 0, 0, 50, 50)}
        {renderDots(rightVal, 0, 50, 50, 50)}
      </svg>
    );
  }

  return (
    <svg viewBox="0 0 200 100" className="w-full h-full">
      <TileDefs gradientId={gradientId} />
      <rect
        x="2"
        y="2"
        width="196"
        height="96"
        rx="10"
        fill={`url(#${gradientId})`}
        stroke="#d8dbe2"
        strokeWidth="2"
      />
      <TileHighlight x={6} y={6} w={188} h={22} />
      <line x1="100" y1="10" x2="100" y2="90" stroke="#d1d5db" strokeWidth="4" strokeLinecap="round" opacity=".8" />
      {renderDots(leftVal, 0, 0, 100, 100, true)}
      {renderDots(rightVal, 100, 0, 100, 100, true)}
    </svg>
  );
});

export function DominoBoard({
  gameState,
  roomStatus,
  userId,
  players,
  onPlacePiece,
  onPass,
  onDraw,
}: DominoBoardProps) {
  const [selectedPieceId, setSelectedPieceId] = useState<number | null>(null);
  const boardRef = useRef<HTMLDivElement>(null);
  const [boardWidth, setBoardWidth] = useState(800);

  const isMyTurn = gameState.turnOrder[gameState.currentTurnIndex] === userId;
  const myHandIds = gameState.hands[userId] || [];

  const validMoves = useMemo(() => {
    if (!isMyTurn) return [];
    return DominoEngine.getValidMoves(myHandIds, gameState.chain, gameState.isFirstMoveOfRound);
  }, [isMyTurn, myHandIds, gameState.chain, gameState.isFirstMoveOfRound]);

  const chainPieces = gameState.chain?.pieces || [];

  useEffect(() => {
    if (!boardRef.current) return;
    const observer = new ResizeObserver((entries) => {
      setBoardWidth(entries[0].contentRect.width);
    });
    observer.observe(boardRef.current);
    return () => observer.disconnect();
  }, []);

  const chainWidth = useMemo(() => {
    let width = 0;
    chainPieces.forEach((p) => {
      const isDouble = DominoEngine.getPieceById(p.pieceId).isDouble;
      width += isDouble ? 60 : 110;
    });
    return width + Math.max(0, chainPieces.length - 1) * 4;
  }, [chainPieces]);

  const targetScale = useMemo(() => {
    if (boardWidth === 0 || chainWidth === 0) return 1;
    const padding = 40;
    const availableWidth = boardWidth - padding;
    return Math.min(1, availableWidth / chainWidth);
  }, [boardWidth, chainWidth]);

  const canPlay = validMoves.length > 0;
  const opponentUids = gameState.turnOrder.filter((uid) => uid !== userId);

  return (
    <div className="w-full flex flex-col gap-6 items-center select-none overflow-hidden pb-10">
      {/* Opponents & Score */}
      <div className="w-full flex justify-between items-start gap-4 flex-wrap px-2">
        <div className="bg-secondary/40 backdrop-blur-md px-4 py-3 rounded-2xl border border-white/10 flex flex-col gap-2 min-w-[150px]">
          <span className="text-xs text-muted-foreground uppercase tracking-widest font-bold flex justify-between">
            <span>النقاط (الهدف {gameState.targetScore})</span>
            {(gameState.boneyard?.length || 0) > 0 && (
              <span className="text-blue-400">السحب: {gameState.boneyard.length}</span>
            )}
          </span>
          {gameState.turnOrder.map((uid) => (
            <div
              key={`score-${uid}`}
              className={`flex justify-between items-center text-sm ${uid === userId ? "text-primary font-bold" : ""}`}
            >
              <span>{players[uid]?.name || (uid === userId ? "أنت" : "خصم")}</span>
              <span>{gameState.scores[uid]}</span>
            </div>
          ))}
        </div>

        <div className="flex gap-2 sm:gap-4 flex-wrap justify-end">
          {opponentUids.map((uid) => (
            <div
              key={`opp-${uid}`}
              className="bg-secondary/40 backdrop-blur-md px-4 py-3 rounded-2xl border border-white/10 flex flex-col items-center gap-1"
            >
              <span className="text-sm font-bold truncate max-w-[100px]">{players[uid]?.name || "الخصم"}</span>
              <div className="flex gap-1">
                <div className="w-4 h-6 bg-white/20 rounded-sm border border-white/10" />
                <span className="text-xs font-bold font-mono">x{gameState.hands[uid]?.length || 0}</span>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Board (Chain) */}
      <div
        id="domino-board-container"
        ref={boardRef}
        dir="ltr"
        className="w-full min-h-64 md:min-h-80 bg-black/20 rounded-3xl border border-white/10 relative shadow-inner flex items-center justify-center overflow-hidden"
      >
        

        <motion.div
          className="flex items-center justify-center gap-1"
          animate={{ scale: targetScale }}
          transition={{ type: "spring", stiffness: 120, damping: 20 }}
          style={{ transformOrigin: "center center" }}
        >
          {chainPieces.map((placed, idx) => {
            const piece = DominoEngine.getPieceById(placed.pieceId);
            const isDouble = piece.isDouble;

            const leftVal = placed.displayLeft !== undefined ? placed.displayLeft : placed.flipped ? piece.right : piece.left;
            const rightVal = placed.displayRight !== undefined ? placed.displayRight : placed.flipped ? piece.left : piece.right;

            return (
              <motion.div
                key={`chain-${placed.pieceId}-${idx}`}
                initial={{ opacity: 0, scale: 0.5, y: -20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                className={`${
                  isDouble ? "w-12 h-24 sm:w-16 sm:h-32" : "w-24 h-12 sm:w-32 sm:h-16"
                } flex-shrink-0 rounded-lg [box-shadow:0_6px_14px_rgba(0,0,0,.25)]`}
              >
                <ChainDominoSvg leftVal={leftVal} rightVal={rightVal} isDouble={isDouble} />
              </motion.div>
            );
          })}

          {(!gameState.chain?.pieces || gameState.chain.pieces.length === 0) && (
            <div className="text-muted-foreground/50 font-bold text-2xl mx-auto tracking-widest uppercase px-8">
              ابدأ اللعب هنا
            </div>
          )}
        </motion.div>
      </div>

      {/* My Hand */}
      <div className="w-full bg-secondary/20 rounded-3xl p-6 border border-white/5 relative">
        {/* Pass Button */}
        <AnimatePresence>
          {isMyTurn && !canPlay && !gameState.roundWinner && !gameState.gameWinner && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="absolute -top-14 left-1/2 -translate-x-1/2"
            >
              <div className="flex gap-2">
                {gameState.boneyard !== undefined && (
                  <button
                    onClick={onDraw}
                    disabled={!gameState.boneyard || gameState.boneyard.length === 0}
                    className={`px-6 sm:px-8 py-2.5 rounded-full font-bold shadow-lg transition-all ${
                      gameState.boneyard && gameState.boneyard.length > 0
                        ? "bg-blue-500 hover:bg-blue-600 text-white shadow-blue-500/20"
                        : "bg-gray-600/50 text-white/50 cursor-not-allowed"
                    }`}
                  >
                    {gameState.boneyard && gameState.boneyard.length > 0
                      ? `سحب (${gameState.boneyard.length})`
                      : "البنك فارغ"}
                  </button>
                )}
                
                {(!gameState.boneyard || gameState.boneyard.length === 0) && (
                  <button
                    onClick={onPass}
                    className="bg-red-500 hover:bg-red-600 text-white px-6 sm:px-8 py-2.5 rounded-full font-bold shadow-lg shadow-red-500/20 transition-all"
                  >
                    {gameState.boneyard !== undefined ? "باص (لا يوجد لعب)" : "باص (تمرير الدور)"}
                  </button>
                )}
              </div>
            </motion.div>
          )}
        </AnimatePresence>

        <div className="flex flex-wrap justify-center gap-4">
          <AnimatePresence>
            {myHandIds.map((pieceId) => {
              const piece = DominoEngine.getPieceById(pieceId);
              const isValid = validMoves.includes(pieceId);
              
              const chainPieces = gameState.chain?.pieces || [];
              const canPlayLeft = chainPieces.length === 0 || piece.left === gameState.chain?.leftEnd || piece.right === gameState.chain?.leftEnd;
              const canPlayRight = chainPieces.length > 0 && (piece.left === gameState.chain?.rightEnd || piece.right === gameState.chain?.rightEnd);
              
              const isSelected = selectedPieceId === pieceId;
              
              const handlePieceClick = () => {
                if (!isMyTurn || !isValid || gameState.roundWinner || roomStatus !== "playing") return;
                
                if (chainPieces.length === 0) {
                  onPlacePiece(pieceId, 'right');
                } else if (canPlayLeft && !canPlayRight) {
                  onPlacePiece(pieceId, 'left');
                } else if (canPlayRight && !canPlayLeft) {
                  onPlacePiece(pieceId, 'right');
                } else if (canPlayLeft && canPlayRight) {
                  // Can play on both sides, toggle selection to show buttons
                  setSelectedPieceId(isSelected ? null : pieceId);
                }
              };
              
              return (
                <motion.div
                  key={`hand-${pieceId}`}
                  layout
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1, y: isSelected ? -16 : 0 }}
                  exit={{ opacity: 0, scale: 0.5 }}
                  onClick={handlePieceClick}
                  className={`relative group ${!isMyTurn || (!isValid && roomStatus === "playing") ? 'opacity-50 grayscale cursor-not-allowed' : 'cursor-pointer hover:-translate-y-4 transition-transform'} p-2 -m-2 touch-manipulation`}
                >
                  <div className="w-14 h-28 sm:w-16 sm:h-32">
                    <DominoSvg piece={piece} />
                  </div>
                  
                  {/* Action buttons (Shown if selected on mobile, or on hover on desktop if both are possible) */}
                  <AnimatePresence>
                    {isMyTurn && isValid && !gameState.roundWinner && isSelected && (
                      <motion.div 
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        exit={{ opacity: 0, y: 10 }}
                        className="absolute -top-12 left-1/2 -translate-x-1/2 flex gap-2 z-10 max-w-[calc(100vw-2rem)]"
                      >
                        <button onClick={(e) => { e.stopPropagation(); onPlacePiece(pieceId, 'left'); setSelectedPieceId(null); }} className="bg-primary hover:bg-primary/80 text-white font-bold text-sm px-4 py-2.5 rounded-xl shadow-xl whitespace-nowrap border border-white/20">شمال</button>
                        <button onClick={(e) => { e.stopPropagation(); onPlacePiece(pieceId, 'right'); setSelectedPieceId(null); }} className="bg-blue-500 hover:bg-blue-600 text-white font-bold text-sm px-4 py-2.5 rounded-xl shadow-xl whitespace-nowrap border border-white/20">يمين</button>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              );
            })}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}
