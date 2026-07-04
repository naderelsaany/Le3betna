import { useEffect, useState } from "react";
import { signInAnonymously, onAuthStateChanged, User, GoogleAuthProvider, signInWithPopup, linkWithCredential, signOut } from "firebase/auth";
import { auth, firestore } from "@/firebase/client";
import { doc, setDoc, getDoc, serverTimestamp } from "firebase/firestore";

export function useAuth() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    // Listen for auth state changes
    const unsubscribe = onAuthStateChanged(auth, async (currentUser) => {
      if (currentUser) {
        setUser(currentUser);
        setLoading(false);
      } else {
        // If not logged in, sign in anonymously automatically for the MVP
        try {
          await signInAnonymously(auth);
        } catch (error: any) {
          console.error("Auth error", error);
          setError(error.message);
          setLoading(false);
        }
      }
    });

    return () => unsubscribe();
  }, []);

  const signInWithGoogle = async () => {
    try {
      setLoading(true);
      setError(null);
      const provider = new GoogleAuthProvider();
      
      let finalUser: User | null = null;

      // If user is already anonymous, try to link the Google account
      if (auth.currentUser && auth.currentUser.isAnonymous) {
        try {
          const result = await signInWithPopup(auth, provider);
          const credential = GoogleAuthProvider.credentialFromResult(result);
          if (credential) {
             const linkedResult = await linkWithCredential(auth.currentUser, credential);
             finalUser = linkedResult.user;
          }
        } catch (linkError: any) {
          // If linking fails (e.g. email already exists), just sign in with Google normally
          console.warn("Linking failed, signing in directly", linkError);
          const result = await signInWithPopup(auth, provider);
          finalUser = result.user;
        }
      } else {
        // Normal sign in
        const result = await signInWithPopup(auth, provider);
        finalUser = result.user;
      }

      // Save user to Firestore Users Collection
      if (finalUser) {
        const userRef = doc(firestore, `users/${finalUser.uid}`);
        const userDoc = await getDoc(userRef);
        
        if (!userDoc.exists()) {
          await setDoc(userRef, {
            uid: finalUser.uid,
            displayName: finalUser.displayName || "لاعب غامض",
            photoURL: finalUser.photoURL || "",
            createdAt: serverTimestamp(),
            lastSeen: serverTimestamp(),
            rating: 1000 // Default rating
          }, { merge: true });
        } else {
          await setDoc(userRef, { lastSeen: serverTimestamp() }, { merge: true });
        }
      }

      setLoading(false);
    } catch (err: any) {
      console.error(err);
      setError(err.message);
      setLoading(false);
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error("Error signing out", error);
    }
  };

  return { user, loading, error, signInWithGoogle, logout };
}
