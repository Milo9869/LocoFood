import { create } from 'zustand';
import { User } from 'firebase/auth';

interface AuthState {
  user: User | null;
  isGuestMode: boolean;
  setUser: (user: User | null) => void;
  setGuestMode: (isGuest: boolean) => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isGuestMode: false,
  setUser: (user) => set({ user }),
  setGuestMode: (isGuest) => set({ isGuestMode: isGuest, user: null }),
}));