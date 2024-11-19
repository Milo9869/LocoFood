import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Layout from './components/Layout';
import AuthGuard from './components/AuthGuard';
import Home from './pages/Home';
import MapView from './pages/Map';
import Orders from './pages/Orders';
import Auth from './pages/Auth';
import RestaurantDetail from './pages/RestaurantDetail';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/auth" element={<Auth />} />
        <Route
          path="/"
          element={
            <AuthGuard>
              <Layout>
                <Routes>
                  <Route index element={<Home />} />
                  <Route path="/restaurant/:id" element={<RestaurantDetail />} />
                  <Route path="/recherche" element={<MapView />} />
                  <Route path="/commandes" element={<Orders />} />
                  <Route path="/profil" element={<div>Page Profil</div>} />
                </Routes>
              </Layout>
            </AuthGuard>
          }
        />
      </Routes>
    </BrowserRouter>
  );
}

export default App;