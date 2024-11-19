import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { MenuItem } from '../types';
import { useCartStore } from '../store/cartStore';

interface Props {
  category: string;
  items: MenuItem[];
}

export default function MenuSection({ category, items }: Props) {
  const [selectedItem, setSelectedItem] = useState<MenuItem | null>(null);
  const addItem = useCartStore((state) => state.addItem);

  return (
    <div className="space-y-4">
      <h3 className="text-xl font-semibold">{category}</h3>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {items.map((item) => (
          <motion.div
            key={item.id}
            whileHover={{ scale: 1.02 }}
            className="glass-card p-4 cursor-pointer"
            onClick={() => setSelectedItem(item)}
          >
            <div className="flex gap-4">
              <img
                src={item.image}
                alt={item.name}
                className="w-24 h-24 object-cover rounded-lg"
              />
              <div className="flex-1">
                <h4 className="font-semibold">{item.name}</h4>
                <p className="text-sm text-gray-400 line-clamp-2">
                  {item.description}
                </p>
                <p className="mt-2 text-neon-blue font-semibold">
                  {item.price.toFixed(2)}€
                </p>
              </div>
            </div>
          </motion.div>
        ))}
      </div>

      <AnimatePresence>
        {selectedItem && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 z-50"
            onClick={() => setSelectedItem(null)}
          >
            <motion.div
              initial={{ scale: 0.9 }}
              animate={{ scale: 1 }}
              exit={{ scale: 0.9 }}
              className="glass-card p-6 max-w-md w-full"
              onClick={(e) => e.stopPropagation()}
            >
              <img
                src={selectedItem.image}
                alt={selectedItem.name}
                className="w-full h-48 object-cover rounded-lg mb-4"
              />
              <h3 className="text-xl font-semibold mb-2">{selectedItem.name}</h3>
              <p className="text-gray-400 mb-4">{selectedItem.description}</p>
              <div className="flex justify-between items-center">
                <p className="text-xl font-semibold text-neon-blue">
                  {selectedItem.price.toFixed(2)}€
                </p>
                <button
                  onClick={() => {
                    addItem(selectedItem);
                    setSelectedItem(null);
                  }}
                  className="px-6 py-2 bg-gradient-to-r from-neon-blue to-neon-purple rounded-lg font-semibold hover:opacity-90 transition-opacity"
                >
                  Ajouter au panier
                </button>
              </div>
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  );
}