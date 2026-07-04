"use client";

import { useState, useEffect } from "react";
import { collection, query, where, getDocs, setDoc, doc, onSnapshot, deleteDoc } from "firebase/firestore";
import { ref, onValue } from "firebase/database";
import { firestore, rtdb } from "@/firebase/client";
import { User } from "firebase/auth";
import { useRouter } from "next/navigation";
import { useGameRoom } from "@/hooks/useGameRoom";

export interface FriendData {
  id: string;
  displayName: string;
  photoURL: string;
}

interface FriendsListProps {
  user: User | null;
  onSelectChat?: (friend: FriendData) => void;
}

function FriendItem({ friend, onSelectChat, onInvite }: { friend: FriendData, onSelectChat?: (f: FriendData) => void, onInvite: (id: string, gameType: "ludo" | "connect4" | "domino") => void }) {
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    const statusRef = ref(rtdb, `/status/${friend.id}`);
    const unsubscribe = onValue(statusRef, (snap) => {
      const data = snap.val();
      setIsOnline(data?.state === "online");
    });
    return () => unsubscribe();
  }, [friend.id]);

  const [showInviteOptions, setShowInviteOptions] = useState(false);

  return (
    <div className="bg-white/5 border border-white/10 rounded-xl p-3 flex flex-col gap-2">
      <div className="flex items-center gap-3">
        {friend.photoURL ? (
           <img src={friend.photoURL} alt={friend.displayName} className="w-10 h-10 rounded-full border border-white/20" />
        ) : (
           <div className="w-10 h-10 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold">
             {friend.displayName.charAt(0).toUpperCase()}
           </div>
        )}
        <div className="flex flex-col">
          <span className="font-bold text-sm">{friend.displayName}</span>
        </div>
      </div>
      
      {/* Action Buttons */}
      <div className="flex gap-2">
        <button 
          onClick={() => onSelectChat && onSelectChat(friend)}
          className="flex-1 bg-white/10 hover:bg-white/20 px-3 py-1.5 rounded-full text-xs font-medium transition-colors"
        >
          💬 رسالة
        </button>
        <button 
          onClick={() => setShowInviteOptions(!showInviteOptions)}
          className="flex-1 text-primary hover:text-primary-foreground hover:bg-primary px-3 py-1.5 rounded-full text-xs font-medium transition-colors border border-primary"
        >
          🎮 دعوة للعب
        </button>
      </div>

      {showInviteOptions && (
        <div className="flex gap-1 mt-1">
          <button onClick={() => { onInvite(friend.id, "connect4"); setShowInviteOptions(false); }} className="flex-1 bg-blue-600 text-white text-[10px] py-1 rounded-md">4 في صف</button>
          <button onClick={() => { onInvite(friend.id, "ludo"); setShowInviteOptions(false); }} className="flex-1 bg-red-600 text-white text-[10px] py-1 rounded-md">لودو</button>
          <button onClick={() => { onInvite(friend.id, "domino"); setShowInviteOptions(false); }} className="flex-1 bg-green-600 text-white text-[10px] py-1 rounded-md">دومينو</button>
        </div>
      )}
    </div>
  );
}

export function FriendsList({ user, onSelectChat }: FriendsListProps) {
  const [searchEmail, setSearchEmail] = useState("");
  const [friends, setFriends] = useState<any[]>([]);
  const [invites, setInvites] = useState<any[]>([]);
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  
  // We need to create a room if we invite someone
  const { createRoom } = useGameRoom(user, null);

  useEffect(() => {
    if (!user || user.isAnonymous) return;

    // Listen to following
    const friendsQ = query(collection(firestore, `users/${user.uid}/following`));
    const unsubFriends = onSnapshot(friendsQ, (snap) => {
      setFriends(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    // Listen to invites
    const invitesQ = query(collection(firestore, `users/${user.uid}/invites`));
    const unsubInvites = onSnapshot(invitesQ, (snap) => {
      setInvites(snap.docs.map(d => ({ id: d.id, ...d.data() })));
    });

    return () => {
      unsubFriends();
      unsubInvites();
    };
  }, [user]);

  const handleSearchAndFollow = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!searchEmail.trim() || !user) return;
    setLoading(true);

    // Simplistic search by displayName for the MVP
    const usersRef = collection(firestore, "users");
    const q = query(usersRef, where("displayName", "==", searchEmail.trim()));
    const snap = await getDocs(q);
    
    if (!snap.empty) {
      const friendData = snap.docs[0];
      if (friendData.id !== user.uid) {
        await setDoc(doc(firestore, `users/${user.uid}/following/${friendData.id}`), {
          displayName: friendData.data().displayName,
          photoURL: friendData.data().photoURL || "",
        });
      }
    } else {
      alert("لم يتم العثور على اللاعب.");
    }
    
    setSearchEmail("");
    setLoading(false);
  };

  const handleInvite = async (friendId: string, gameType: "ludo" | "connect4" | "domino") => {
    if (!user) return;
    
    let initialGameState = {};
    if (gameType === "ludo") {
      initialGameState = {
        turnOrder: [],
        currentTurnIndex: 0,
        dice: { value: null, rolledBy: null, rolledAt: null },
        pieces: {},
        winner: null,
        consecutiveSixes: 0,
        version: 1
      };
    } else if (gameType === "connect4") {
      const initialBoard = Array(6).fill(null).map(() => Array(7).fill(0));
      initialGameState = {
        board: initialBoard,
        turn: 1,
        winner: null,
        version: 1
      };
    } else if (gameType === "domino") {
      initialGameState = {
        turnOrder: [],
        currentTurnIndex: 0,
        hands: {},
        chain: { pieces: [], leftEnd: null, rightEnd: null },
        consecutivePasses: 0,
        scores: {},
        targetScore: 101, // default for invites
        roundWinner: null,
        gameWinner: null,
        version: 1,
        needsInitialization: false,
      };
    }

    const code = await createRoom(gameType, 2, initialGameState, gameType === "domino" ? 101 : undefined);
    if (code) {
      // Send invite
      await setDoc(doc(firestore, `users/${friendId}/invites/${user.uid}`), {
        roomId: code,
        senderName: user.displayName || "صديقك",
        gameName: gameType === "domino" ? "دومينو" : gameType === "ludo" ? "لودو" : "4 في صف",
        timestamp: Date.now()
      });
      // Navigate to play page with room id
      router.push(`/play?room=${code}`);
    }
  };

  const handleAcceptInvite = async (inviteId: string, roomId: string) => {
    if (!user) return;
    // Delete the invite
    await deleteDoc(doc(firestore, `users/${user.uid}/invites/${inviteId}`));
    // Route to play page with room id
    router.push(`/play?room=${roomId}`);
  };

  if (!user || user.isAnonymous) {
    return null; 
  }

  return (
    <div className="flex flex-col h-full gap-4">
      {/* Invites Alert */}
      {invites.length > 0 && (
        <div className="flex flex-col gap-2">
          {invites.map(inv => (
            <div key={inv.id} className="bg-primary/20 border border-primary/50 rounded-xl p-3 flex justify-between items-center">
              <span className="text-sm font-bold">🎮 {inv.senderName} يتحداك في {inv.gameName || "لعبة"}!</span>
              <button 
                onClick={() => handleAcceptInvite(inv.id, inv.roomId)}
                className="bg-primary text-white text-xs px-3 py-1.5 rounded-full hover:bg-primary/80"
              >
                قبول (كود: {inv.roomId})
              </button>
            </div>
          ))}
        </div>
      )}

      {/* Add Friend Form */}
      <form onSubmit={handleSearchAndFollow} className="flex gap-2">
        <input 
          value={searchEmail}
          onChange={(e) => setSearchEmail(e.target.value)}
          placeholder="ابحث عن اسم لاعب..."
          className="flex-1 bg-background/50 border border-white/10 rounded-full px-4 py-2 text-sm focus:outline-none focus:border-primary/50"
        />
        <button type="submit" disabled={loading} className="bg-white/10 px-4 py-2 rounded-full text-sm hover:bg-white/20">
          متابعة
        </button>
      </form>

      {/* Friends List */}
      <div className="flex-1 overflow-y-auto flex flex-col gap-2 pr-2">
        {friends.length === 0 && (
          <div className="text-center text-muted-foreground text-sm py-10">
            لم تتابع أحداً بعد.
          </div>
        )}
        {friends.map(friend => (
          <FriendItem 
            key={friend.id} 
            friend={friend} 
            onSelectChat={onSelectChat} 
            onInvite={handleInvite} 
          />
        ))}
      </div>
    </div>
  );
}
