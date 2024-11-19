import { useState } from 'react';
import { motion } from 'framer-motion';
import { FiClock, FiPackage, FiTruck, FiCheck } from 'react-icons/fi';
import { Order } from '../types';

const orders: Order[] = [
  {
    id: 1,
    restaurantName: "Cyber Sushi Lab",
    status: "delivering",
    items: [
      { name: "California Roll", quantity: 2, price: 12.99 },
      { name: "Salmon Nigiri", quantity: 4, price: 8.99 }
    ],
    total: 59.94,
    date: "2024-02-10T15:30:00"
  },
  {
    id: 2,
    restaurantName: "Neon Burger",
    status: "delivered",
    items: [
      { name: "Cyber Burger", quantity: 1, price: 15.99 },
      { name: "Frites Quantiques", quantity: 1, price: 5.99 }
    ],
    total: 21.98,
    date: "2024-02-09T20:15:00"
  }
];

const statusIcons = {
  pending: FiClock,
  preparing: FiPackage,
  delivering: FiTruck,
  delivered: FiCheck
};

const statusColors = {
  pending: "text-yellow-500",
  preparing: "text-blue-500",
  delivering: "text-purple-500",
  delivered: "text-green-500"
};

export default function Orders() {
  const [activeTab, setActiveTab] = useState<'active' | 'history'>('active');
  
  const activeOrders = orders.filter(order => 
    ['pending', 'preparing', 'delivering'].includes(order.status)
  );
  
  const orderHistory = orders.filter(order => 
    order.status === 'delivered'
  );

  const renderOrder = (order: Order) => {
    const StatusIcon = statusIcons[order.status];
    const statusColor = statusColors[order.status];

    return (
      <motion.div
        key={order.id}
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="glass-card p-4 mb-4"
      >
        <div className="flex justify-between items-start mb-4">
          <div>
            <h3 className="text-lg font-semibold">{order.restaurantName}</h3>
            <p className="text-sm text-gray-400">
              {new Date(order.date).toLocaleDateString('fr-FR', {
                day: 'numeric',
                month: 'long',
                hour: '2-digit',
                minute: '2-digit'
              })}
            </p>
          </div>
          <div className={`flex items-center ${statusColor}`}>
            <StatusIcon className="mr-2" />
            <span className="text-sm capitalize">{order.status}</span>
          </div>
        </div>

        <div className="space-y-2 mb-4">
          {order.items.map((item, index) => (
            <div key={index} className="flex justify-between text-sm">
              <span>{item.quantity}x {item.name}</span>
              <span>{(item.price * item.quantity).toFixed(2)}€</span>
            </div>
          ))}
        </div>

        <div className="border-t border-white/10 pt-3 flex justify-between font-semibold">
          <span>Total</span>
          <span>{order.total.toFixed(2)}€</span>
        </div>
      </motion.div>
    );
  };

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-bold">Mes commandes</h1>

      <div className="flex space-x-4 mb-6">
        <button
          onClick={() => setActiveTab('active')}
          className={`px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'active'
              ? 'bg-neon-blue text-black'
              : 'bg-black/50 text-white'
          }`}
        >
          En cours
        </button>
        <button
          onClick={() => setActiveTab('history')}
          className={`px-4 py-2 rounded-lg transition-colors ${
            activeTab === 'history'
              ? 'bg-neon-blue text-black'
              : 'bg-black/50 text-white'
          }`}
        >
          Historique
        </button>
      </div>

      <div className="space-y-4">
        {activeTab === 'active' ? (
          activeOrders.length > 0 ? (
            activeOrders.map(renderOrder)
          ) : (
            <p className="text-center text-gray-400">Aucune commande en cours</p>
          )
        ) : (
          orderHistory.length > 0 ? (
            orderHistory.map(renderOrder)
          ) : (
            <p className="text-center text-gray-400">Aucune commande passée</p>
          )
        )}
      </div>
    </div>
  );
}