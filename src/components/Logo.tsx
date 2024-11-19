import { motion } from 'framer-motion';
import { FiTruck } from 'react-icons/fi';

export default function Logo() {
  return (
    <div className="flex items-center gap-2">
      <motion.div
        initial={{ x: -100 }}
        animate={{ x: 0 }}
        className="text-neon-blue"
      >
        <FiTruck className="text-3xl" />
      </motion.div>
      <h1 className="text-4xl font-bold bg-gradient-to-r from-neon-blue via-neon-purple to-neon-pink text-transparent bg-clip-text animate-gradient">
        LocoFood
      </h1>
    </div>
  );
}