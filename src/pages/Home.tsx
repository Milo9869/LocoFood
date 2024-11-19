import { useState } from 'react';
import Logo from '../components/Logo';
import SearchBar from '../components/SearchBar';
import RestaurantList from '../components/RestaurantList';

export default function Home() {
  const [searchTerm, setSearchTerm] = useState('');

  return (
    <div className="space-y-8">
      <Logo />
      <SearchBar 
        value={searchTerm}
        onChange={setSearchTerm}
        placeholder="Rechercher un restaurant ou un plat..."
      />
      <RestaurantList />
    </div>
  );
}