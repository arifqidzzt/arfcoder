'use client';

import { useEffect, useState } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useCartStore } from '@/store/useCartStore';
import api from '@/lib/api';
import { useRouter } from 'next/navigation';
import Image from 'next/image';
import toast from 'react-hot-toast';
import { ShoppingCart, Tag, CreditCard } from 'lucide-react';
import { ALL_PAYMENT_METHODS, GROUPED_PAYMENT_METHODS } from '@/lib/paymentMethods';

export default function CheckoutPage() {
  const { token } = useAuthStore();
  const { items, total, clearCart } = useCartStore();
  const [voucher, setVoucher] = useState('');
  const [discount, setDiscount] = useState(0);
  const [appliedVoucher, setAppliedVoucher] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  // Payment method selection state
  const [showPaymentSelector, setShowPaymentSelector] = useState(false);
  const [selectedPaymentMethod, setSelectedPaymentMethod] = useState('');
  const [orderData, setOrderData] = useState<any>(null);

  useEffect(() => {
    if (!token) router.push('/login');
    if (items.length === 0) router.push('/products');
  }, [token, items]);

  const applyVoucher = async () => {
    if (!voucher.trim()) return toast.error('Masukkan kode voucher');
    try {
      const res = await api.post('/vouchers/validate', { code: voucher });
      toast.success('Voucher berhasil digunakan!');
      setDiscount(res.data.discountAmount);
      setAppliedVoucher(voucher);
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Voucher tidak valid');
    }
  };

  const handleCheckout = async () => {
    if (loading) return;
    setLoading(true);

    try {
      const res = await api.post('/orders', {
        items: items.map(i => ({ productId: i.product.id, quantity: i.quantity })),
        voucherCode: appliedVoucher
      });

      const { useCoreApi, availablePaymentMethods, snapToken, order } = res.data;

      // If Core API, show payment method selector
      if (useCoreApi && availablePaymentMethods && availablePaymentMethods.length > 0) {
        setOrderData({ ...order, availablePaymentMethods });
        setShowPaymentSelector(true);
        setLoading(false);
      }
      // Otherwise, use Snap (existing flow)
      else if (snapToken && window.snap) {
        window.snap.pay(snapToken, {
          onSuccess: () => {
            toast.success('Pembayaran Berhasil!');
            clearCart();
            window.location.href = '/orders';
          },
          onPending: () => {
            toast('Menunggu pembayaran...');
            clearCart();
            window.location.href = '/orders';
          },
          onError: () => {
            toast.error('Pembayaran Gagal');
            setLoading(false);
          },
          onClose: () => {
            toast('Anda menutup popup pembayaran');
            setLoading(false);
          },
        });
      } else {
        toast.error('Tidak ada metode pembayaran tersedia');
        setLoading(false);
      }
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Checkout gagal');
      setLoading(false);
    }
  };

  const handlePaymentMethodSelect = async () => {
    if (!selectedPaymentMethod || !orderData) {
      return toast.error('Pilih metode pembayaran');
    }

    setLoading(true);
    try {
      await api.post(`/orders/${orderData.id}/charge`, {
        paymentMethod: selectedPaymentMethod
      });
      clearCart();
      router.push(`/payment/${orderData.id}`);
    } catch (error: any) {
      toast.error(error.response?.data?.message || 'Gagal membuat pembayaran');
      setLoading(false);
    }
  };

  const totalPrice = total();
  const finalAmount = totalPrice - discount;

  // Payment Method Selector Modal
  if (showPaymentSelector) {
    return (
      <div className="min-h-screen bg-gray-50 pb-20">
        <Navbar />
        <main className="max-w-2xl mx-auto px-4 pt-24">
          <h1 className="text-2xl font-black mb-6">Pilih Metode Pembayaran</h1>

          <div className="space-y-4">
            {Object.entries(GROUPED_PAYMENT_METHODS).map(([groupName, methods]) => {
              // Filter methods based on available payment methods from backend
              const availableMethods = methods.filter(method =>
                orderData?.availablePaymentMethods?.includes(method.id)
              );

              // Only show group if it has available methods
              if (availableMethods.length === 0) return null;

              return (
                <div key={groupName} className="bg-white p-4 rounded-xl shadow-sm border">
                  <h3 className="font-bold mb-3 text-sm text-gray-700">{groupName}</h3>
                  <div className="space-y-2">
                    {availableMethods.map(method => (
                      <label
                        key={method.id}
                        className={`flex items-center gap-3 p-3 border-2 rounded-lg cursor-pointer transition ${selectedPaymentMethod === method.id
                          ? 'border-accent bg-accent/5'
                          : 'border-gray-200 hover:border-accent/50'
                          }`}
                      >
                        <input
                          type="radio"
                          name="paymentMethod"
                          value={method.id}
                          checked={selectedPaymentMethod === method.id}
                          onChange={(e) => setSelectedPaymentMethod(e.target.value)}
                          className="w-4 h-4"
                        />
                        <div className="flex-1">
                          <p className="font-semibold text-sm">{method.name}</p>
                          {method.description && (
                            <p className="text-xs text-gray-500">{method.description}</p>
                          )}
                        </div>
                      </label>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>

          <div className="mt-6 flex gap-3">
            <button
              onClick={() => {
                setShowPaymentSelector(false);
                setSelectedPaymentMethod('');
                setLoading(false);
              }}
              className="flex-1 py-3 bg-gray-200 rounded-lg font-bold hover:bg-gray-300"
            >
              Batal
            </button>
            <button
              onClick={handlePaymentMethodSelect}
              disabled={!selectedPaymentMethod || loading}
              className="flex-2 py-3 bg-accent text-white rounded-lg font-bold hover:opacity-90 disabled:bg-gray-300"
            >
              {loading ? 'Memproses...' : 'Lanjutkan Pembayaran'}
            </button>
          </div>
        </main>
      </div>
    );
  }

  // Regular Checkout View
  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <Navbar />
      <main className="max-w-4xl mx-auto px-4 pt-24">
        <h1 className="text-3xl font-black mb-8 flex items-center gap-2">
          <ShoppingCart />
          Checkout
        </h1>

        {/* Cart Items */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <h2 className="font-bold mb-4">Pesanan Anda</h2>
          <div className="space-y-4">
            {items.map((item) => (
              <div key={item.product.id} className="flex gap-4">
                <Image
                  src={item.product.images[0] || '/placeholder.png'}
                  alt={item.product.name}
                  width={80}
                  height={80}
                  className="rounded-lg object-cover"
                />
                <div className="flex-1">
                  <h3 className="font-bold">{item.product.name}</h3>
                  <p className="text-sm text-gray-500">Qty: {item.quantity}</p>
                  <p className="font-bold text-accent">Rp {(item.product.price * item.quantity).toLocaleString('id-ID')}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Voucher */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <h2 className="font-bold mb-4 flex items-center gap-2">
            <Tag size={20} />
            Voucher
          </h2>
          <div className="flex gap-2">
            <input
              type="text"
              placeholder="Masukkan kode voucher"
              value={voucher}
              onChange={(e) => setVoucher(e.target.value.toUpperCase())}
              className="flex-1 px-4 py-2 border rounded-lg"
              disabled={!!appliedVoucher}
            />
            <button
              onClick={applyVoucher}
              disabled={!!appliedVoucher}
              className="px-6 py-2 bg-accent text-white rounded-lg font-bold hover:opacity-90 disabled:bg-gray-300"
            >
              {appliedVoucher ? '✓ Terpakai' : 'Gunakan'}
            </button>
          </div>
          {discount > 0 && (
            <p className="text-sm text-green-600 mt-2">✓ Diskon Rp {discount.toLocaleString('id-ID')} telah diterapkan</p>
          )}
        </div>

        {/* Summary */}
        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
          <h2 className="font-bold mb-4">Ringkasan</h2>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span>Subtotal</span>
              <span>Rp {totalPrice.toLocaleString('id-ID')}</span>
            </div>
            {discount > 0 && (
              <div className="flex justify-between text-green-600">
                <span>Diskon</span>
                <span>- Rp {discount.toLocaleString('id-ID')}</span>
              </div>
            )}
            <div className="pt-2 border-t flex justify-between font-bold text-lg">
              <span>Total</span>
              <span className="text-accent">Rp {finalAmount.toLocaleString('id-ID')}</span>
            </div>
          </div>
        </div>

        {/* Checkout Button */}
        <button
          onClick={handleCheckout}
          disabled={loading || items.length === 0}
          className="w-full py-4 bg-accent text-white rounded-lg font-bold text-lg hover:opacity-90 disabled:bg-gray-300 flex items-center justify-center gap-2"
        >
          <CreditCard />
          {loading ? 'Memproses...' : 'Bayar Sekarang'}
        </button>
      </main>
    </div>
  );
}
