import { create } from 'zustand';
import { CartItem } from '../types';

interface CartState {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (itemId: number) => void;
  updateQuantity: (itemId: number, quantity: number) => void;
  clearCart: () => void;
  total: number;
}

export const useCartStore = create<CartState>((set, get) => ({
  items: [],
  total: 0,
  
  addItem: (item) => set((state) => {
    const existingItem = state.items.find((i) => i.id === item.id);
    if (existingItem) {
      return {
        items: state.items.map((i) =>
          i.id === item.id ? { ...i, quantity: i.quantity + 1 } : i
        ),
        total: state.total + item.price,
      };
    }
    return {
      items: [...state.items, { ...item, quantity: 1 }],
      total: state.total + item.price,
    };
  }),

  removeItem: (itemId) => set((state) => {
    const item = state.items.find((i) => i.id === itemId);
    return {
      items: state.items.filter((i) => i.id !== itemId),
      total: state.total - (item ? item.price * item.quantity : 0),
    };
  }),

  updateQuantity: (itemId, quantity) => set((state) => {
    const item = state.items.find((i) => i.id === itemId);
    if (!item) return state;
    
    const quantityDiff = quantity - item.quantity;
    return {
      items: state.items.map((i) =>
        i.id === itemId ? { ...i, quantity } : i
      ),
      total: state.total + (item.price * quantityDiff),
    };
  }),

  clearCart: () => set({ items: [], total: 0 }),
}));