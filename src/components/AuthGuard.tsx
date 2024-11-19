import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from '../lib/firebase';

export default function AuthGuard({ children }: { children: React.ReactNode }) {
  const navigate = useNavigate();
  const { user, isGuestMode, setUser } = useAuthStore();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setUser(user);
      if (!user && !isGuestMode) {
        navigate('/auth');
      }
    });

    return () => unsubscribe();
  }, [navigate, setUser, isGuestMode]);

  if (!user && !isGuestMode) {
    return null;
  }

  return <>{children}</>;
}