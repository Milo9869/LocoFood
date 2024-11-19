export interface Restaurant {
  id: number;
  name: string;
  image: string;
  rating: number;
  deliveryTime: string;
  category: string;
  latitude?: number;
  longitude?: number;
  menu?: MenuItem[];
  reviews?: Review[];
}

export interface MenuItem {
  id: number;
  name: string;
  description: string;
  price: number;
  image: string;
  category: string;
}

export interface Review {
  id: number;
  userId: string;
  userName: string;
  rating: number;
  comment: string;
  date: string;
}

export interface Order {
  id: number;
  restaurantName: string;
  status: 'pending' | 'preparing' | 'delivering' | 'delivered';
  items: CartItem[];
  total: number;
  date: string;
  deliveryAddress: string;
  estimatedDeliveryTime?: string;
  driverId?: string;
  driverName?: string;
}

export interface CartItem {
  id: number;
  name: string;
  quantity: number;
  price: number;
}

export interface UserProfile {
  id: string;
  name: string;
  email: string;
  phone?: string;
  addresses: DeliveryAddress[];
  favoriteRestaurants: number[];
  orders: Order[];
}

export interface DeliveryAddress {
  id: string;
  label: string;
  street: string;
  city: string;
  postalCode: string;
  instructions?: string;
  isDefault: boolean;
}