import { useEffect } from "react";
import { ref, onValue, onDisconnect, set, serverTimestamp } from "firebase/database";
import { rtdb } from "@/firebase/client";
import { User } from "firebase/auth";

export function usePresence(user: User | null) {
  useEffect(() => {
    if (!user || user.isAnonymous) return;

    const userStatusDatabaseRef = ref(rtdb, `/status/${user.uid}`);
    const connectedRef = ref(rtdb, ".info/connected");

    const unsubscribe = onValue(connectedRef, (snap) => {
      if (snap.val() === true) {
        const disconnectRef = onDisconnect(userStatusDatabaseRef);
        disconnectRef.set({
          state: "offline",
          lastChanged: serverTimestamp(),
        }).then(() => {
          set(userStatusDatabaseRef, {
            state: "online",
            lastChanged: serverTimestamp(),
          });
        });
      }
    });

    return () => {
      unsubscribe();
      set(userStatusDatabaseRef, {
        state: "offline",
        lastChanged: serverTimestamp(),
      });
    };
  }, [user]);
}
