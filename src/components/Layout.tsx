import { motion } from 'framer-motion';
import { FiHome, FiSearch, FiUser, FiShoppingBag } from 'react-icons/fi';
import { Link, useLocation } from 'react-router-dom';

export default function Layout({ children }: { children: React.ReactNode }) {
  const location = useLocation();

  const navItems = [
    { icon: FiHome, path: '/', label: 'Accueil' },
    { icon: FiSearch, path: '/recherche', label: 'Recherche' },
    { icon: FiShoppingBag, path: '/commandes', label: 'Commandes' },
    { icon: FiUser, path: '/profil', label: 'Profil' },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-black via-purple-900 to-black">
      <motion.div 
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        className="max-w-6xl mx-auto p-6 pb-24"
      >
        {children}
      </motion.div>
      
      <nav className="fixed bottom-0 left-0 right-0 bg-black/90 backdrop-blur-lg border-t border-white/10">
        <div className="max-w-6xl mx-auto px-6">
          <div className="flex justify-between py-3">
            {navItems.map(({ icon: Icon, path, label }) => (
              <Link
                key={path}
                to={path}
                className={`flex flex-col items-center ${
                  location.pathname === path ? 'text-neon-blue' : 'text-gray-400'
                }`}
              >
                <Icon className="text-xl mb-1" />
                <span className="text-xs">{label}</span>
              </Link>
            ))}
          </div>
        </div>
      </nav>
    </div>
  );
}