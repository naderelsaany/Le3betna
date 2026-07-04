"use client";

import React, { memo, useMemo } from "react";
import { motion } from "framer-motion";
import { LudoState, PlayerColor, LudoEngine } from "@/game-logic/ludo";
import { LudoMap } from "@/game-logic/LudoMap";

interface LudoBoardProps {
  roomId: string;
  gameState: LudoState;
  roomStatus: "waiting" | "playing" | "finished";
  myColor: PlayerColor | undefined;
  onMakeMove: (pieceIndex: number) => void;
  userId?: string;
  players: Record<string, { color: number }>;
}

const themeColors = {
  1: "#ef4444", // Red
  2: "#22c55e", // Green
  3: "#eab308", // Yellow
  4: "#3b82f6", // Blue
} as const;

const getStrokeColor = (colorId: number) => {
  switch (colorId) {
    case 1: return "#b91c1c";
    case 2: return "#15803d";
    case 3: return "#a16207";
    case 4: return "#1d4ed8";
    default: return "#000";
  }
};

// Memoized LudoPiece to prevent whole board re-renders
const LudoPiece = memo(({ 
  roomId, 
  uid, 
  idx, 
  pColor, 
  pos, 
  isClickable, 
  onMakeMove,
  dx = 0,
  dy = 0
}: { 
  roomId: string, 
  uid: string, 
  idx: number, 
  pColor: PlayerColor, 
  pos: number, 
  isClickable: boolean, 
  onMakeMove: (idx: number) => void,
  dx?: number,
  dy?: number
}) => {
  let coord = { x: 0, y: 0 };
  if (pos === -1) {
    coord = LudoMap.bases[pColor][idx];
  } else if (pos >= 0 && pos <= 50) {
    const absPos = LudoEngine.getAbsolutePosition(pColor, pos);
    coord = LudoMap.track[absPos];
  } else if (pos >= 51 && pos <= 55) {
    coord = LudoMap.homeStretch[pColor][pos - 51];
  } else if (pos === 56) {
    coord = { x: LudoMap.homeCenter.x - 50, y: LudoMap.homeCenter.y - 50 };
  }

  return (
    <motion.circle
      layout
      layoutId={`piece-${roomId}-${uid}-${idx}`} // fixed layoutId without version to allow smooth transitions
      initial={false}
      animate={{
        cx: coord.x + 50 + dx,
        cy: coord.y + 50 + dy,
      }}
      transition={{ type: "spring", stiffness: 200, damping: 20 }}
      r={30}
      fill={themeColors[pColor]}
      stroke={isClickable ? "#ffffff" : getStrokeColor(pColor)}
      strokeWidth={isClickable ? 6 : 3}
      className={`piece-gpu ${isClickable ? "cursor-pointer" : "cursor-default"}`}
      onClick={() => isClickable && onMakeMove(idx)}
      style={{
        filter: isClickable ? "drop-shadow(0px 0px 15px rgba(255,255,255,0.8))" : "drop-shadow(0px 4px 6px rgba(0,0,0,0.5))",
      }}
    />
  );
});
LudoPiece.displayName = "LudoPiece";

export function LudoBoard({ roomId, gameState, roomStatus, myColor, onMakeMove, userId, players }: LudoBoardProps) {
  const { pieces, currentTurnIndex, turnOrder, version, dice } = gameState;
  const isGameOver = !!gameState.winner;
  const isMyTurn = roomStatus === "playing" && !isGameOver && turnOrder[currentTurnIndex] === userId;

  const colorMap = useMemo(() => {
    const map: Record<string, PlayerColor> = {};
    Object.entries(players).forEach(([pUid, pData]: [string, any]) => {
      map[pUid] = pData.color as PlayerColor;
    });
    return map;
  }, [players]);

  const offsets = useMemo(() => {
    const piecePositions: { uid: string; idx: number; color: PlayerColor; pos: number; key: string }[] = [];
    Object.entries(pieces).forEach(([uid, playerPieces]) => {
      const pColor = players[uid]?.color as PlayerColor;
      if (!pColor) return;
      playerPieces.forEach((pos, idx) => {
        let key = "";
        if (pos === -1) {
          key = `base-${pColor}-${idx}`;
        } else if (pos >= 0 && pos <= 50) {
          const absPos = LudoEngine.getAbsolutePosition(pColor, pos);
          key = `track-${absPos}`;
        } else if (pos >= 51 && pos <= 55) {
          key = `homestretch-${pColor}-${pos}`;
        } else if (pos === 56) {
          key = `homecenter`;
        }
        piecePositions.push({ uid, idx, color: pColor, pos, key });
      });
    });

    const groups: Record<string, typeof piecePositions> = {};
    piecePositions.forEach((p) => {
      if (!groups[p.key]) groups[p.key] = [];
      groups[p.key].push(p);
    });

    const calculatedOffsets: Record<string, { dx: number; dy: number }> = {};
    Object.entries(groups).forEach(([key, group]) => {
      if (group.length <= 1) {
        group.forEach((p) => {
          calculatedOffsets[`${p.uid}-${p.idx}`] = { dx: 0, dy: 0 };
        });
      } else {
        const radius = 15;
        group.forEach((p, index) => {
          const angle = (index * 2 * Math.PI) / group.length;
          const dx = Math.round(radius * Math.cos(angle));
          const dy = Math.round(radius * Math.sin(angle));
          calculatedOffsets[`${p.uid}-${p.idx}`] = { dx, dy };
        });
      }
    });

    return calculatedOffsets;
  }, [pieces, players]);

  const renderPieces = () => {
    const renderedPieces: React.ReactNode[] = [];
    Object.entries(pieces).forEach(([uid, playerPieces]) => {
      const pColor = players[uid]?.color as PlayerColor;
      if (!pColor) return;

      const isMine = uid === userId;
      // We calculate valid moves here and pass it down
      const validMoves = isMine && isMyTurn ? LudoEngine.getValidMoves(playerPieces, dice?.value || null, uid, gameState, colorMap) : [];

      playerPieces.forEach((pos, idx) => {
        const isClickable = validMoves.includes(idx);
        const offset = offsets[`${uid}-${idx}`] || { dx: 0, dy: 0 };
        renderedPieces.push(
          <LudoPiece
            key={`${uid}-${idx}`}
            roomId={roomId}
            uid={uid}
            idx={idx}
            pColor={pColor}
            pos={pos}
            isClickable={isClickable}
            onMakeMove={onMakeMove}
            dx={offset.dx}
            dy={offset.dy}
          />
        );
      });
    });
    return renderedPieces;
  };

  const renderStar = (cx: number, cy: number, color: string) => (
    <path
      d={`M${cx},${cy - 25} l7,15 l17,3 l-12,12 l3,17 l-15,-8 l-15,8 l3,-17 l-12,-12 l17,-3 z`}
      fill={color}
    />
  );

  return (
    <div className="flex flex-col items-center gap-4 w-full max-w-3xl mx-auto p-2 sm:p-4">
      {/* Game Status */}
      <div className="w-full text-center p-3 bg-secondary/30 rounded-2xl border border-white/5 backdrop-blur-md">
        {roomStatus === "waiting" && <p className="animate-pulse">في انتظار اكتمال اللاعبين...</p>}
        {roomStatus === "playing" && !isGameOver && (
          <p className="text-xl font-bold">
            {isMyTurn ? <span className="text-primary">دورك الآن</span> : "دور الخصم"}
          </p>
        )}
        {isGameOver && (
          <p className="text-xl font-bold text-green-500">
            {gameState.winner === userId ? "لقد فزت! 🎉" : "انتهت المباراة!"}
          </p>
        )}
      </div>

      {/* SVG Board */}
      <div className="relative w-full aspect-square max-w-[min(95vw,80dvh)] mx-auto transform-gpu bg-white shadow-2xl rounded-xl overflow-hidden p-2 sm:p-4 border border-white/10">
        <svg viewBox="0 0 1500 1500" className="w-full h-full drop-shadow-md">
          {/* Main Background */}
          <rect x="0" y="0" width="1500" height="1500" fill="#f8fafc" rx="40" />

          {/* Top Left Base (Green) */}
          <rect x="0" y="0" width="600" height="600" fill={themeColors[2]} rx="40" />
          <rect x="100" y="100" width="400" height="400" fill="#ffffff" rx="40" />
          {[LudoMap.bases[2][0], LudoMap.bases[2][1], LudoMap.bases[2][2], LudoMap.bases[2][3]].map((pos, i) => (
            <circle key={`g-slot-${i}`} cx={pos.x + 50} cy={pos.y + 50} r="35" fill="#f1f5f9" stroke="#cbd5e1" strokeWidth="4" />
          ))}

          {/* Top Right Base (Red) */}
          <rect x="900" y="0" width="600" height="600" fill={themeColors[1]} rx="40" />
          <rect x="1000" y="100" width="400" height="400" fill="#ffffff" rx="40" />
          {[LudoMap.bases[1][0], LudoMap.bases[1][1], LudoMap.bases[1][2], LudoMap.bases[1][3]].map((pos, i) => (
            <circle key={`r-slot-${i}`} cx={pos.x + 50} cy={pos.y + 50} r="35" fill="#f1f5f9" stroke="#cbd5e1" strokeWidth="4" />
          ))}

          {/* Bottom Left Base (Yellow) */}
          <rect x="0" y="900" width="600" height="600" fill={themeColors[3]} rx="40" />
          <rect x="100" y="1000" width="400" height="400" fill="#ffffff" rx="40" />
          {[LudoMap.bases[3][0], LudoMap.bases[3][1], LudoMap.bases[3][2], LudoMap.bases[3][3]].map((pos, i) => (
            <circle key={`y-slot-${i}`} cx={pos.x + 50} cy={pos.y + 50} r="35" fill="#f1f5f9" stroke="#cbd5e1" strokeWidth="4" />
          ))}

          {/* Bottom Right Base (Blue) */}
          <rect x="900" y="900" width="600" height="600" fill={themeColors[4]} rx="40" />
          <rect x="1000" y="1000" width="400" height="400" fill="#ffffff" rx="40" />
          {[LudoMap.bases[4][0], LudoMap.bases[4][1], LudoMap.bases[4][2], LudoMap.bases[4][3]].map((pos, i) => (
            <circle key={`b-slot-${i}`} cx={pos.x + 50} cy={pos.y + 50} r="35" fill="#f1f5f9" stroke="#cbd5e1" strokeWidth="4" />
          ))}

          {/* Center Triangles */}
          <polygon points="600,600 900,600 750,750" fill={themeColors[1]} stroke="#000" strokeWidth="2" opacity="0.9" />
          <polygon points="600,600 600,900 750,750" fill={themeColors[2]} stroke="#000" strokeWidth="2" opacity="0.9" />
          <polygon points="600,900 900,900 750,750" fill={themeColors[3]} stroke="#000" strokeWidth="2" opacity="0.9" />
          <polygon points="900,600 900,900 750,750" fill={themeColors[4]} stroke="#000" strokeWidth="2" opacity="0.9" />

          {/* Standard Track */}
          {LudoMap.track.map((pos, i) => {
            let fill = "#ffffff";
            if (i === 0) fill = themeColors[2];
            else if (i === 13) fill = themeColors[1];
            else if (i === 26) fill = themeColors[4];
            else if (i === 39) fill = themeColors[3];
            
            const isStar = [8, 21, 34, 47].includes(i);
            if (isStar) fill = "#e2e8f0";

            return (
              <g key={`track-${i}`}>
                <rect x={pos.x} y={pos.y} width="100" height="100" fill={fill} stroke="#94a3b8" strokeWidth="2" />
                {isStar && renderStar(pos.x + 50, pos.y + 50, "#64748b")}
                {/* Draw arrows at starting points */}
                {i === 0 && <polygon points={`${pos.x + 30},${pos.y + 30} ${pos.x + 70},${pos.y + 50} ${pos.x + 30},${pos.y + 70}`} fill="#fff" opacity="0.7"/>}
                {i === 13 && <polygon points={`${pos.x + 30},${pos.y + 30} ${pos.x + 70},${pos.y + 30} ${pos.x + 50},${pos.y + 70}`} fill="#fff" opacity="0.7"/>}
                {i === 26 && <polygon points={`${pos.x + 70},${pos.y + 30} ${pos.x + 30},${pos.y + 50} ${pos.x + 70},${pos.y + 70}`} fill="#fff" opacity="0.7"/>}
                {i === 39 && <polygon points={`${pos.x + 30},${pos.y + 70} ${pos.x + 70},${pos.y + 70} ${pos.x + 50},${pos.y + 30}`} fill="#fff" opacity="0.7"/>}
              </g>
            );
          })}

          {/* Home Stretches */}
          {Object.entries(LudoMap.homeStretch).map(([colorStr, positions]) => {
            const color = parseInt(colorStr);
            return positions.map((pos, i) => (
              <rect key={`home-${color}-${i}`} x={pos.x} y={pos.y} width="100" height="100" fill={themeColors[color as PlayerColor]} stroke="#ffffff" strokeWidth="4" />
            ));
          })}

          {/* Render the movable pieces */}
          {renderPieces()}

        </svg>
      </div>
    </div>
  );
}
