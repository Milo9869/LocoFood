import { useState, useEffect } from 'react';
import Map, { Marker, Popup, NavigationControl } from 'react-map-gl';
import { FiMapPin, FiAlertCircle } from 'react-icons/fi';
import { Restaurant } from '../types';
import 'mapbox-gl/dist/mapbox-gl.css';

// Using a public token for demo purposes. In production, use environment variables
const MAPBOX_TOKEN = 'pk.eyJ1IjoibG9jb2Zvb2QiLCJhIjoiY2x0MHB3NHpzMDJ3eDJrcGR5ZDJqcHN2YyJ9.3_Q6q6Br3IqkBcPpqc_N_Q';

const PARIS_COORDINATES: [number, number] = [2.3522, 48.8566];

const restaurants: Restaurant[] = [
  {
    id: 1,
    name: "Cyber Sushi Lab",
    image: "https://images.unsplash.com/photo-1579871494447-9811cf80d66c?w=500",
    rating: 4.8,
    deliveryTime: "20-30",
    category: "Japonais",
    latitude: 48.8566,
    longitude: 2.3522
  },
  {
    id: 2,
    name: "Neon Burger",
    image: "https://images.unsplash.com/photo-1586816001966-79b736744398?w=500",
    rating: 4.5,
    deliveryTime: "25-35",
    category: "Burger",
    latitude: 48.8606,
    longitude: 2.3376
  }
];

export default function MapView() {
  const [userLocation, setUserLocation] = useState<[number, number]>(PARIS_COORDINATES);
  const [selectedRestaurant, setSelectedRestaurant] = useState<Restaurant | null>(null);
  const [locationError, setLocationError] = useState<string>('');

  useEffect(() => {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          setUserLocation([position.coords.longitude, position.coords.latitude]);
          setLocationError('');
        },
        (error) => {
          let errorMessage = 'Impossible d\'obtenir votre position';
          if (error.code === 1) {
            errorMessage = 'Veuillez autoriser l\'accès à votre position pour une meilleure expérience';
          }
          setLocationError(errorMessage);
        },
        {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0
        }
      );
    } else {
      setLocationError('La géolocalisation n\'est pas supportée par votre navigateur');
    }
  }, []);

  return (
    <div className="space-y-4">
      {locationError && (
        <div className="glass-card p-4 flex items-center gap-2 text-yellow-400">
          <FiAlertCircle />
          <p className="text-sm">{locationError}</p>
        </div>
      )}
      
      <div className="h-[calc(100vh-10rem)]">
        <Map
          mapboxAccessToken={MAPBOX_TOKEN}
          initialViewState={{
            longitude: userLocation[0],
            latitude: userLocation[1],
            zoom: 13
          }}
          style={{ width: '100%', height: '100%', borderRadius: '0.75rem' }}
          mapStyle="mapbox://styles/mapbox/dark-v11"
        >
          <NavigationControl />
          
          {/* User Location Marker */}
          <Marker
            longitude={userLocation[0]}
            latitude={userLocation[1]}
            anchor="bottom"
          >
            <div className="w-4 h-4 bg-neon-blue rounded-full animate-pulse" />
          </Marker>

          {/* Restaurant Markers */}
          {restaurants.map((restaurant) => (
            <Marker
              key={restaurant.id}
              longitude={restaurant.longitude}
              latitude={restaurant.latitude}
              anchor="bottom"
              onClick={(e) => {
                e.originalEvent.stopPropagation();
                setSelectedRestaurant(restaurant);
              }}
            >
              <FiMapPin className="text-2xl text-neon-pink cursor-pointer hover:scale-110 transition-transform" />
            </Marker>
          ))}

          {/* Restaurant Popup */}
          {selectedRestaurant && (
            <Popup
              longitude={selectedRestaurant.longitude}
              latitude={selectedRestaurant.latitude}
              anchor="bottom"
              onClose={() => setSelectedRestaurant(null)}
              className="glass-card"
            >
              <div className="p-2">
                <img 
                  src={selectedRestaurant.image} 
                  alt={selectedRestaurant.name}
                  className="w-full h-24 object-cover rounded-lg mb-2"
                />
                <h3 className="font-semibold">{selectedRestaurant.name}</h3>
                <p className="text-sm text-gray-400">{selectedRestaurant.category}</p>
                <p className="text-sm text-neon-blue">{selectedRestaurant.deliveryTime} min</p>
              </div>
            </Popup>
          )}
        </Map>
      </div>
    </div>
  );
}