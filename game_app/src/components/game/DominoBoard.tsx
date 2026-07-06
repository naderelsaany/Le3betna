"use client";

import { motion, AnimatePresence, useAnimation, useReducedMotion } from "framer-motion";
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
  const [draggingPieceId, setDraggingPieceId] = useState<number | null>(null);
  // الزون النشطة أثناء السحب (لإضاءتها حيّاً بدل الانتظار لحين الإفلات)
  const [activeZone, setActiveZone] = useState<"left" | "right" | null>(null);
  const boardRef = useRef<HTMLDivElement>(null);
  const [boardWidth, setBoardWidth] = useState(800);
  const shouldReduceMotion = useReducedMotion();

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
        {/* Drop Zones - Glass Card + إضاءة حية أثناء السحب */}
        <AnimatePresence>
          {draggingPieceId !== null && chainPieces.length > 0 && (
            <>
              <motion.div
                id="domino-left-zone"
                initial={{ opacity: 0, x: -20 }}
                animate={{
                  opacity: 1,
                  x: 0,
                  scale: activeZone === "left" ? 1.06 : 1,
                }}
                exit={{ opacity: 0, x: -20 }}
                transition={{ type: "spring", stiffness: 400, damping: 26 }}
                className="absolute left-2 md:left-6 top-1/2 -translate-y-1/2 w-20 md:w-28 h-40 rounded-2xl z-20 flex flex-col items-center justify-center gap-1 text-primary font-bold backdrop-blur-[12px]"
                style={{
                  background: "linear-gradient(180deg, rgba(255,255,255,.08), rgba(255,255,255,.02))",
                  border: activeZone === "left" ? "1px solid hsl(var(--primary) / 0.6)" : "1px solid rgba(255,255,255,.18)",
                  boxShadow:
                    activeZone === "left"
                      ? "0 10px 30px rgba(0,0,0,.25), 0 0 22px hsl(var(--primary) / 0.35)"
                      : "0 10px 30px rgba(0,0,0,.18)",
                }}
              >
                <ArrowLeft className="w-5 h-5" />
                <span>شمال</span>
              </motion.div>
              <motion.div
                id="domino-right-zone"
                initial={{ opacity: 0, x: 20 }}
                animate={{
                  opacity: 1,
                  x: 0,
                  scale: activeZone === "right" ? 1.06 : 1,
                }}
                exit={{ opacity: 0, x: 20 }}
                transition={{ type: "spring", stiffness: 400, damping: 26 }}
                className="absolute right-2 md:right-6 top-1/2 -translate-y-1/2 w-20 md:w-28 h-40 rounded-2xl z-20 flex flex-col items-center justify-center gap-1 text-blue-400 font-bold backdrop-blur-[12px]"
                style={{
                  background: "linear-gradient(180deg, rgba(255,255,255,.08), rgba(255,255,255,.02))",
                  border: activeZone === "right" ? "1px solid rgba(96,165,250,.6)" : "1px solid rgba(255,255,255,.18)",
                  boxShadow:
                    activeZone === "right"
                      ? "0 10px 30px rgba(0,0,0,.25), 0 0 22px rgba(96,165,250,.35)"
                      : "0 10px 30px rgba(0,0,0,.18)",
                }}
              >
                <ArrowRight className="w-5 h-5" />
                <span>يمين</span>
              </motion.div>
            </>
          )}
        </AnimatePresence>

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
      <div className="w-full bg-secondary/20 rounded-3xl p-4 border border-white/5 relative h-48 sm:h-56 flex items-end justify-center overflow-visible">
        <AnimatePresence>
          {isMyTurn && !canPlay && !gameState.roundWinner && !gameState.gameWinner && (
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: 10 }}
              className="absolute top-4 left-1/2 -translate-x-1/2 z-50"
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
                    {gameState.boneyard && gameState.boneyard.length > 0 ? `سحب (${gameState.boneyard.length})` : "البنك فارغ"}
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

        <div className="flex items-end justify-center w-full relative h-full">
          <AnimatePresence>
            {myHandIds.map((pieceId, i) => {
              const piece = DominoEngine.getPieceById(pieceId);
              const isValid = validMoves.includes(pieceId);

              const canPlayLeft = chainPieces.length === 0 || piece.left === gameState.chain?.leftEnd || piece.right === gameState.chain?.leftEnd;
              const canPlayRight = chainPieces.length > 0 && (piece.left === gameState.chain?.rightEnd || piece.right === gameState.chain?.rightEnd);

              return (
                <DraggableDominoTile
                  key={`hand-${pieceId}`}
                  piece={piece}
                  pieceId={pieceId}
                  index={i}
                  total={myHandIds.length}
                  isMyTurn={isMyTurn}
                  isValid={isValid}
                  roomStatus={roomStatus}
                  canPlayLeft={canPlayLeft}
                  canPlayRight={canPlayRight}
                  chainLength={chainPieces.length}
                  roundWinner={gameState.roundWinner}
                  onPlacePiece={onPlacePiece}
                  setDraggingPieceId={setDraggingPieceId}
                  setActiveZone={setActiveZone}
                  shouldReduceMotion={shouldReduceMotion}
                />
              );
            })}
          </AnimatePresence>
        </div>
      </div>
    </div>
  );
}

// -----------------------------
// Draggable Tile Component
// -----------------------------
const DraggableDominoTile = memo(function DraggableDominoTile({
  piece,
  pieceId,
  index,
  total,
  isMyTurn,
  isValid,
  roomStatus,
  canPlayLeft,
  canPlayRight,
  chainLength,
  roundWinner,
  onPlacePiece,
  setDraggingPieceId,
  setActiveZone,
  shouldReduceMotion,
}: any) {
  const controls = useAnimation();
  const [isHovered, setIsHovered] = useState(false);
  const isPlayable = isMyTurn && isValid && !roundWinner && roomStatus === "playing";

  // إحداثيات الزونز تُحسب مرة وحدة عند بداية السحب فقط
  // (تفادي getBoundingClientRect المتكرر على كل فريم أثناء onDrag)
  const zoneRectsRef = useRef<{ left?: DOMRect; right?: DOMRect }>({});

  const angleStep = Math.min(10, 60 / Math.max(total - 1, 1));
  const startAngle = -((total - 1) * angleStep) / 2;
  const tileWidth = 64;
  const overlap = 0.4;
  const visibleWidth = tileWidth * (1 - overlap);
  const totalWidth = tileWidth + (total - 1) * visibleWidth;
  const startX = -totalWidth / 2 + tileWidth / 2;

  const angle = startAngle + index * angleStep;
  const baseXOffset = startX + index * visibleWidth;
  const baseYOffset = Math.abs(index - (total - 1) / 2) ** 2 * 1.5;

  const hoverLift = shouldReduceMotion ? 0 : 18;
  const hoverScale = shouldReduceMotion ? 1 : 1.08;
  const springConfig = shouldReduceMotion
    ? { type: "tween" as const, duration: 0.1 }
    : { type: "spring" as const, stiffness: 500, damping: 22 };

  useEffect(() => {
    controls.start({
      x: baseXOffset,
      y: isHovered && isPlayable ? baseYOffset - hoverLift : baseYOffset,
      rotate: isHovered && isPlayable ? 0 : angle,
      scale: isHovered && isPlayable ? hoverScale : 1,
      opacity: 1,
      zIndex: isHovered ? 50 : index,
      transition: springConfig,
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [index, total, isHovered, isPlayable, baseXOffset, baseYOffset, angle, controls]);

  const handleDragStart = () => {
    if (!isPlayable) return;
    setDraggingPieceId(pieceId);
    setIsHovered(true);
    zoneRectsRef.current.left = document.getElementById("domino-left-zone")?.getBoundingClientRect();
    zoneRectsRef.current.right = document.getElementById("domino-right-zone")?.getBoundingClientRect();
  };

  const handleDrag = (_e: any, info: any) => {
    if (!isPlayable) return;
    const { x, y } = info.point;
    const { left, right } = zoneRectsRef.current;

    if (left && x >= left.left && x <= left.right && y >= left.top && y <= left.bottom) {
      setActiveZone("left");
    } else if (right && x >= right.left && x <= right.right && y >= right.top && y <= right.bottom) {
      setActiveZone("right");
    } else {
      setActiveZone(null);
    }
  };

  const handleDragEnd = (_e: any, info: any) => {
    setDraggingPieceId(null);
    setIsHovered(false);
    setActiveZone(null);

    if (!isPlayable) return;

    const distance = Math.sqrt(info.offset.x ** 2 + info.offset.y ** 2);

    if (distance < 10) {
      if (chainLength === 0) onPlacePiece(pieceId, "right");
      else if (canPlayLeft && !canPlayRight) onPlacePiece(pieceId, "left");
      else if (canPlayRight && !canPlayLeft) onPlacePiece(pieceId, "right");
      return;
    }

    const dropX = info.point.x;
    const dropY = info.point.y;

    let droppedZone: "left" | "right" | null = null;
    const { left, right } = zoneRectsRef.current;

    if (left && dropX >= left.left && dropX <= left.right && dropY >= left.top && dropY <= left.bottom) {
      droppedZone = "left";
    }
    if (right && dropX >= right.left && dropX <= right.right && dropY >= right.top && dropY <= right.bottom) {
      droppedZone = "right";
    }

    const board = document.getElementById("domino-board-container");
    const boardRect = board?.getBoundingClientRect();
    const droppedOnBoard =
      boardRect && dropY >= boardRect.top && dropY <= boardRect.bottom && dropX >= boardRect.left && dropX <= boardRect.right;

    let played = false;

    if (chainLength === 0) {
      if (droppedOnBoard) {
        onPlacePiece(pieceId, "right");
        played = true;
      }
    } else {
      if (droppedZone === "left" && canPlayLeft) {
        onPlacePiece(pieceId, "left");
        played = true;
      } else if (droppedZone === "right" && canPlayRight) {
        onPlacePiece(pieceId, "right");
        played = true;
      } else if (droppedOnBoard) {
        if (canPlayLeft && !canPlayRight) {
          onPlacePiece(pieceId, "left");
          played = true;
        } else if (canPlayRight && !canPlayLeft) {
          onPlacePiece(pieceId, "right");
          played = true;
        }
      }
    }

    if (!played) {
      controls.start({
        x: baseXOffset,
        y: baseYOffset,
        rotate: angle,
        scale: 1,
        opacity: 1,
        zIndex: index,
        transition: { type: "spring", stiffness: 400, damping: 25 },
      });
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 100 }}
      animate={controls}
      exit={{ opacity: 0, y: 100 }}
      drag={isPlayable}
      dragSnapToOrigin={false}
      dragElastic={0.2}
      onDragStart={handleDragStart}
      onDrag={handleDrag}
      onDragEnd={handleDragEnd}
      onHoverStart={() => isPlayable && setIsHovered(true)}
      onHoverEnd={() => isPlayable && setIsHovered(false)}
      className={`absolute bottom-4 touch-manipulation ${isPlayable ? "cursor-grab active:cursor-grabbing" : "cursor-not-allowed"}`}
      style={{
        transformOrigin: "bottom center",
        left: "50%",
        marginLeft: -32,
        willChange: isHovered ? "transform" : "auto",
      }}
      whileDrag={{
        scale: 1.12,
        y: -8,
        zIndex: 200,
        filter: "brightness(1.05)",
        transition: { duration: 0.12 },
      }}
    >
      <div
        className={`w-14 h-28 sm:w-16 sm:h-32 rounded-xl transition-shadow duration-150 ${
          isPlayable ? "" : "opacity-60 grayscale"
        }`}
        style={{
          boxShadow: isPlayable
            ? "0 10px 25px rgba(0,0,0,.22), 0 0 0 1px rgba(255,255,255,.4), 0 0 18px hsl(var(--primary) / 0.35)"
            : "0 8px 18px rgba(0,0,0,.22)",
        }}
      >
        <DominoSvg piece={piece} />
      </div>
    </motion.div>
  );
});
