import { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { motion } from 'framer-motion';
import { FiStar, FiClock, FiHeart } from 'react-icons/fi';
import { Restaurant, MenuItem } from '../types';
import MenuSection from '../components/MenuSection';

const mockMenu: MenuItem[] = [
  {
    id: 1,
    name: "California Roll",
    description: "Avocat, crabe, concombre, tobiko",
    price: 12.99,
    image: "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=500",
    category: "Sushis"
  },
  {
    id: 2,
    name: "Salmon Nigiri",
    description: "Saumon frais sur riz vinaigré",
    price: 8.99,
    image: "https://images.unsplash.com/photo-1633478961956-1eb9c131a9c4?w=500",
    category: "Sushis"
  },
  {
    id: 3,
    name: "Miso Ramen",
    description: "Nouilles, bouillon miso, porc, œuf mariné",
    price: 15.99,
    image: "https://images.unsplash.com/photo-1591814468924-caf88d1232e1?w=500",
    category: "Plats Chauds"
  }
];

export default function RestaurantDetail() {
  const { id } = useParams();
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [activeTab, setActiveTab] = useState<'menu' | 'avis'>('menu');

  useEffect(() => {
    // Simuler un appel API pour récupérer les détails du restaurant
    const fetchRestaurant = async () => {
      // En production, ceci serait un appel API réel
      const mockRestaurant: Restaurant = {
        id: Number(id),
        name: "Cyber Sushi Lab",
        image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500",
        rating: 4.8,
        deliveryTime: "20-30",
        category: "Japonais",
        menu: mockMenu,
        reviews: []
      };
      setRestaurant(mockRestaurant);
    };

    fetchRestaurant();
  }, [id]);

  if (!restaurant) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="w-8 h-8 border-4 border-neon-blue border-t-transparent rounded-full animate-spin"></div>
      </div>
    );
  }

  const menuByCategory = mockMenu.reduce((acc, item) => {
    if (!acc[item.category]) {
      acc[item.category] = [];
    }
    acc[item.category].push(item);
    return acc;
  }, {} as Record<string, MenuItem[]>);

  return (
    <div className="space-y-6">
      <div className="relative h-64">
        <img
          src={restaurant.image}
          alt={restaurant.name}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent"></div>
        <div className="absolute bottom-0 left-0 right-0 p-6">
          <h1 className="text-3xl font-bold mb-2">{restaurant.name}</h1>
          <div className="flex items-center space-x-4 text-sm">
            <div className="flex items-center">
              <FiStar className="text-yellow-400 mr-1" />
              <span>{restaurant.rating}</span>
            </div>
            <span className="text-gray-400">•</span>
            <span>{restaurant.category}</span>
            <span className="text-gray-400">•</span>
            <div className="flex items-center text-neon-blue">
              <FiClock className="mr-1" />
              <span>{restaurant.deliveryTime} min</span>
            </div>
          </div>
        </div>
      </div>

      <div className="flex gap-4 border-b border-white/10">
        <button
          onClick={() => setActiveTab('menu')}
          className={`px-4 py-2 font-semibold ${
            activeTab === 'menu'
              ? 'text-neon-blue border-b-2 border-neon-blue'
              : 'text-gray-400'
          }`}
        >
          Menu
        </button>
        <button
          onClick={() => setActiveTab('avis')}
          className={`px-4 py-2 font-semibold ${
            activeTab === 'avis'
              ? 'text-neon-blue border-b-2 border-neon-blue'
              : 'text-gray-400'
          }`}
        >
          Avis
        </button>
      </div>

      {activeTab === 'menu' ? (
        <div className="space-y-8">
          {Object.entries(menuByCategory).map(([category, items]) => (
            <MenuSection key={category} category={category} items={items} />
          ))}
        </div>
      ) : (
        <div className="text-center py-8 text-gray-400">
          Aucun avis pour le moment
        </div>
      )}
    </div>
  );
}