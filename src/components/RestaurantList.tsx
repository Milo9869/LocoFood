import { useState } from 'react';
import { motion } from 'framer-motion';
import RestaurantCard from './RestaurantCard';
import { Restaurant } from '../types';

const restaurants: Restaurant[] = [
  {
    id: 1,
    name: "Cyber Sushi Lab",
    image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500",
    rating: 4.8,
    deliveryTime: "20-30",
    category: "Japonais",
    latitude: 48.8566,
    longitude: 2.3522,
    reviews: []
  },
  {
    id: 2,
    name: "Neon Burger",
    image: "https://images.unsplash.com/photo-1586816001966-79b736744398?w=500",
    rating: 4.5,
    deliveryTime: "25-35",
    category: "Burger",
    latitude: 48.8606,
    longitude: 2.3376,
    reviews: []
  },
  {
    id: 3,
    name: "Digital Poke",
    image: "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500",
    rating: 4.7,
    deliveryTime: "15-25",
    category: "Hawaien",
    latitude: 48.8656,
    longitude: 2.3412,
    reviews: []
  }
];

export default function RestaurantList() {
  const [selectedCategory, setSelectedCategory] = useState<string>("all");

  const categories = ["all", "Japonais", "Burger", "Hawaien"];

  const filteredRestaurants = selectedCategory === "all"
    ? restaurants
    : restaurants.filter(r => r.category === selectedCategory);

  return (
    <div className="space-y-6">
      <div className="flex gap-4 overflow-x-auto pb-4">
        {categories.map(category => (
          <button
            key={category}
            onClick={() => setSelectedCategory(category)}
            className={`px-4 py-2 rounded-full whitespace-nowrap transition-colors ${
              selectedCategory === category
                ? "bg-neon-blue text-black"
                : "bg-black/50 text-white"
            }`}
          >
            {category === "all" ? "Tous" : category}
          </button>
        ))}
      </div>

      <motion.div 
        className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
      >
        {filteredRestaurants.map(restaurant => (
          <RestaurantCard key={restaurant.id} restaurant={restaurant} />
        ))}
      </motion.div>
    </div>
  );
}