import { motion } from 'framer-motion';
import { FiClock, FiStar, FiHeart } from 'react-icons/fi';
import { Link } from 'react-router-dom';
import { Restaurant } from '../types';
import { useAuthStore } from '../store/authStore';

interface Props {
  restaurant: Restaurant;
}

export default function RestaurantCard({ restaurant }: Props) {
  const { user } = useAuthStore();
  const isFavorite = user?.favoriteRestaurants?.includes(restaurant.id);

  const handleFavoriteClick = (e: React.MouseEvent) => {
    e.preventDefault();
    // Toggle favorite logic will be implemented here
  };

  return (
    <Link to={`/restaurant/${restaurant.id}`}>
      <motion.div
        whileHover={{ scale: 1.02 }}
        className="glass-card overflow-hidden relative group"
      >
        <div className="absolute top-4 right-4 z-10">
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={handleFavoriteClick}
            className={`p-2 rounded-full ${
              isFavorite ? "bg-neon-pink" : "bg-black/50"
            } backdrop-blur-sm`}
          >
            <FiHeart className={isFavorite ? "fill-current" : ""} />
          </motion.button>
        </div>

        <div className="relative">
          <img 
            src={restaurant.image} 
            alt={restaurant.name}
            className="w-full h-48 object-cover transition-transform group-hover:scale-105"
          />
          <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
            <h3 className="text-xl font-semibold mb-1">{restaurant.name}</h3>
            <p className="text-gray-300">{restaurant.category}</p>
          </div>
        </div>

        <div className="p-4 bg-black/50">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-2">
              <div className="flex items-center">
                <FiStar className="text-yellow-400 mr-1" />
                <span>{restaurant.rating}</span>
              </div>
              <span className="text-gray-400">•</span>
              <span className="text-sm text-gray-400">
                {restaurant.reviews?.length || 0} avis
              </span>
            </div>
            <div className="flex items-center text-neon-blue">
              <FiClock className="mr-1" />
              <span>{restaurant.deliveryTime} min</span>
            </div>
          </div>
        </div>
      </motion.div>
    </Link>
  );
}