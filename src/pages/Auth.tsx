import { useState } from 'react';
import { useForm } from 'react-hook-form';
import { motion } from 'framer-motion';
import { FiMail, FiLock, FiUser, FiEye } from 'react-icons/fi';
import { auth } from '../lib/firebase';
import { createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth';
import { useNavigate } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import Logo from '../components/Logo';

interface AuthFormData {
  email: string;
  password: string;
  name?: string;
}

export default function Auth() {
  const [isLogin, setIsLogin] = useState(true);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const setGuestMode = useAuthStore((state) => state.setGuestMode);
  const { register, handleSubmit, formState: { errors } } = useForm<AuthFormData>();

  const onSubmit = async (data: AuthFormData) => {
    try {
      if (isLogin) {
        await signInWithEmailAndPassword(auth, data.email, data.password);
      } else {
        await createUserWithEmailAndPassword(auth, data.email, data.password);
      }
      navigate('/');
    } catch (err) {
      setError('Une erreur est survenue. Veuillez réessayer.');
    }
  };

  const handleGuestMode = () => {
    setGuestMode(true);
    navigate('/');
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="w-full max-w-md"
      >
        <div className="mb-8 flex justify-center">
          <Logo />
        </div>

        <div className="glass-card p-8">
          <h2 className="text-2xl font-bold mb-6 text-center">
            {isLogin ? 'Connexion' : 'Créer un compte'}
          </h2>

          <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
            {!isLogin && (
              <div>
                <div className="relative">
                  <FiUser className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                  <input
                    {...register('name', { required: !isLogin })}
                    type="text"
                    placeholder="Nom complet"
                    className="w-full pl-10 pr-4 py-2 rounded-lg bg-black/50 border border-white/10 focus:outline-none focus:border-neon-blue"
                  />
                </div>
                {errors.name && (
                  <span className="text-red-500 text-sm">Ce champ est requis</span>
                )}
              </div>
            )}

            <div>
              <div className="relative">
                <FiMail className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  {...register('email', { required: true, pattern: /^\S+@\S+$/i })}
                  type="email"
                  placeholder="Email"
                  className="w-full pl-10 pr-4 py-2 rounded-lg bg-black/50 border border-white/10 focus:outline-none focus:border-neon-blue"
                />
              </div>
              {errors.email && (
                <span className="text-red-500 text-sm">Email invalide</span>
              )}
            </div>

            <div>
              <div className="relative">
                <FiLock className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" />
                <input
                  {...register('password', { required: true, minLength: 6 })}
                  type="password"
                  placeholder="Mot de passe"
                  className="w-full pl-10 pr-4 py-2 rounded-lg bg-black/50 border border-white/10 focus:outline-none focus:border-neon-blue"
                />
              </div>
              {errors.password && (
                <span className="text-red-500 text-sm">
                  Le mot de passe doit contenir au moins 6 caractères
                </span>
              )}
            </div>

            {error && (
              <div className="text-red-500 text-sm text-center">{error}</div>
            )}

            <button
              type="submit"
              className="w-full py-2 px-4 bg-gradient-to-r from-neon-blue to-neon-purple rounded-lg font-semibold hover:opacity-90 transition-opacity"
            >
              {isLogin ? 'Se connecter' : 'Créer un compte'}
            </button>
          </form>

          <div className="mt-4 flex flex-col gap-2">
            <button
              onClick={() => setIsLogin(!isLogin)}
              className="w-full text-sm text-gray-400 hover:text-white"
            >
              {isLogin
                ? "Pas encore de compte ? S'inscrire"
                : 'Déjà un compte ? Se connecter'}
            </button>

            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-white/10"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-black text-gray-400">ou</span>
              </div>
            </div>

            <button
              onClick={handleGuestMode}
              className="w-full py-2 px-4 bg-black/50 border border-white/10 rounded-lg font-semibold hover:border-neon-blue transition-colors flex items-center justify-center gap-2"
            >
              <FiEye className="text-neon-blue" />
              <span>Continuer en tant qu'invité</span>
            </button>
          </div>
        </div>
      </motion.div>
    </div>
  );
}