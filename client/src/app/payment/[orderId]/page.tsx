'use client';

import { useEffect, useState, use } from 'react';
import Navbar from '@/components/Navbar';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import { getPaymentMethodName, isInstantPayment } from '@/lib/paymentMethods';
import { ArrowLeft, Copy, Clock, CheckCircle, AlertCircle } from 'lucide-react';
import toast from 'react-hot-toast';

interface PaymentPageProps {
    params: Promise<{ orderId: string }>;
}

export default function PaymentPage({ params }: PaymentPageProps) {
    const { orderId } = use(params);
    const [order, setOrder] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [timeLeft, setTimeLeft] = useState('');
    const [paymentExpired, setPaymentExpired] = useState(false);
    const [regenerating, setRegenerating] = useState(false);
    const { token } = useAuthStore();
    const router = useRouter();

    // Fetch order data
    useEffect(() => {
        if (token) fetchOrder();
    }, [orderId, token]);

    const fetchOrder = async () => {
        try {
            const res = await api.get(`/orders/${orderId}`);
            setOrder(res.data);
        } catch (error) {
            toast.error('Gagal memuat pesanan');
        } finally {
            setLoading(false);
        }
    };

    // Countdown timer
    useEffect(() => {
        if (!order?.paymentExpiredAt) return;

        const interval = setInterval(() => {
            const now = new Date().getTime();
            const target = new Date(order.paymentExpiredAt).getTime();
            const distance = target - now;

            if (distance < 0) {
                setTimeLeft('Expired');
                setPaymentExpired(true);
                clearInterval(interval);
            } else {
                const hours = Math.floor((distance % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((distance % (1000 * 60)) / 1000);
                setTimeLeft(`${hours}j ${minutes}m ${seconds}s`);
            }
        }, 1000);

        return () => clearInterval(interval);
    }, [order]);

    // Check payment status every 10 seconds
    useEffect(() => {
        if (!order || order.status !== 'PENDING') return;

        const interval = setInterval(async () => {
            try {
                const res = await api.get(`/orders/${orderId}/payment-status`);
                if (res.data.transactionStatus === 'settlement' || res.data.status === 'PAID') {
                    toast.success('Pembayaran Berhasil!');
                    router.push(`/orders/${orderId}`);
                }
            } catch (error) {
                // Silent fail
            }
        }, 10000);

        return () => clearInterval(interval);
    }, [order, orderId]);

    const handleCopy = (text: string) => {
        navigator.clipboard.writeText(text);
        toast.success('Disalin!');
    };

    const handleRegeneratePayment = async () => {
        setRegenerating(true);
        try {
            const res = await api.post(`/orders/${orderId}/regenerate-payment`, {});
            toast.success('Pembayaran berhasil di-generate ulang!');
            fetchOrder(); // Refresh order data
            setPaymentExpired(false);
        } catch (error: any) {
            toast.error(error.response?.data?.message || 'Gagal regenerate pembayaran');
        } finally {
            setRegenerating(false);
        }
    };

    if (loading) return <div className="min-h-screen bg-gray-50 pt-24 text-center">Memuat...</div>;
    if (!order) return <div className="min-h-screen bg-gray-50 pt-24 text-center">Pesanan tidak ditemukan</div>;

    // Check if order expired (>24 hours)
    const orderExpired = new Date().getTime() - new Date(order.createdAt).getTime() > 24 * 60 * 60 * 1000;

    return (
        <div className="min-h-screen bg-gray-50 pb-20">
            <Navbar />
            <main className="max-w-2xl mx-auto px-4 pt-24">

                {/* Header */}
                <div className="flex items-center gap-4 mb-6">
                    <button onClick={() => router.push(`/orders/${orderId}`)} className="p-2 bg-white rounded-full border border-gray-200 hover:bg-gray-100">
                        <ArrowLeft size={20} />
                    </button>
                    <div>
                        <h1 className="text-xl font-bold">Menunggu Pembayaran</h1>
                        <p className="text-sm text-gray-500">Invoice: {order.invoiceNumber}</p>
                    </div>
                </div>

                {/* Payment Expired Modal */}
                {paymentExpired && !orderExpired && (
                    <div className="bg-orange-50 border border-orange-200 rounded-xl p-6 mb-6">
                        <div className="flex items-start gap-3">
                            <AlertCircle className="text-orange-600 shrink-0 mt-1" size={24} />
                            <div className="flex-1">
                                <h3 className="font-bold text-orange-800 mb-2">Pembayaran Expired</h3>
                                <p className="text-sm text-orange-700 mb-4">
                                    Kode pembayaran Anda sudah tidak berlaku. Silakan generate ulang untuk melanjutkan pembayaran.
                                </p>
                                <button
                                    onClick={handleRegeneratePayment}
                                    disabled={regenerating}
                                    className="px-4 py-2 bg-orange-600 text-white rounded-lg font-bold hover:bg-orange-700 disabled:bg-gray-300"
                                >
                                    {regenerating ? 'Memproses...' : 'Generate Ulang Pembayaran'}
                                </button>
                            </div>
                        </div>
                    </div>
                )}

                {/* Order Expired */}
                {orderExpired && (
                    <div className="bg-red-50 border border-red-200 rounded-xl p-6 mb-6">
                        <div className="flex items-start gap-3">
                            <AlertCircle className="text-red-600 shrink-0" size={24} />
                            <div>
                                <h3 className="font-bold text-red-800 mb-2">Pesanan Expired</h3>
                                <p className="text-sm text-red-700">
                                    Pesanan Anda sudah melewati batas waktu 24 jam. Silakan buat pesanan baru.
                                </p>
                            </div>
                        </div>
                    </div>
                )}

                {!paymentExpired && !orderExpired && (
                    <>
                        {/* Countdown Timer */}
                        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2 text-gray-600">
                                    <Clock size={20} />
                                    <span className="text-sm font-medium">Selesaikan pembayaran dalam</span>
                                </div>
                                <span className="text-xl font-black text-accent">{timeLeft}</span>
                            </div>
                        </div>

                        {/* Payment Method Info */}
                        <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
                            <h3 className="font-bold mb-4">Metode Pembayaran</h3>
                            <p className="text-lg font-bold text-accent">{getPaymentMethodName(order.coreApiPaymentMethod)}</p>
                        </div>

                        {/* VA Number (Bank Transfer) */}
                        {order.coreApiVaNumber && (
                            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
                                <h3 className="font-bold mb-4">Nomor Virtual Account</h3>
                                <div className="flex items-center justify-between bg-gray-50 p-4 rounded-lg border border-gray-200">
                                    <span className="text-2xl font-mono font-bold tracking-wider">{order.coreApiVaNumber}</span>
                                    <button onClick={() => handleCopy(order.coreApiVaNumber)} className="p-2 hover:bg-gray-200 rounded-lg">
                                        <Copy size={20} />
                                    </button>
                                </div>
                                <p className="text-xs text-gray-500 mt-2">Bank: {order.coreApiBankCode?.toUpperCase()}</p>
                            </div>
                        )}

                        {/* QRIS */}
                        {order.coreApiQrisUrl && (
                            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
                                <h3 className="font-bold mb-4 text-center">Scan QR Code</h3>
                                <div className="flex justify-center">
                                    <img src={order.coreApiQrisUrl} alt="QRIS Code" className="w-64 h-64 border rounded-lg" />
                                </div>
                                <p className="text-xs text-gray-500 text-center mt-4">Scan dengan aplikasi e-wallet Anda</p>
                            </div>
                        )}

                        {/* Deeplink (GoPay/ShopeePay) */}
                        {order.coreApiDeeplinkUrl && (
                            <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100 mb-6">
                                <h3 className="font-bold mb-4">Bayar dengan Aplikasi</h3>
                                <a
                                    href={order.coreApiDeeplinkUrl}
                                    target="_blank"
                                    rel="noopener noreferrer"
                                    className="block w-full py-4 bg-accent text-white text-center rounded-lg font-bold hover:opacity-90"
                                >
                                    Buka {getPaymentMethodName(order.coreApiPaymentMethod)}
                                </a>
                            </div>
                        )}

                        {/* Payment Instructions */}
                        <div className="bg-blue-50 rounded-xl p-6 border border-blue-100 mb-6">
                            <h3 className="font-bold text-blue-800 mb-3">Cara Pembayaran</h3>
                            <ol className="text-sm text-blue-700 space-y-2 list-decimal list-inside">
                                {order.coreApiVaNumber && (
                                    <>
                                        <li>Buka aplikasi mobile banking atau ATM</li>
                                        <li>Pilih menu Transfer atau Bayar</li>
                                        <li>Masukkan nomor Virtual Account di atas</li>
                                        <li>Periksa detail pembayaran</li>
                                        <li>Konfirmasi pembayaran</li>
                                    </>
                                )}
                                {order.coreApiQrisUrl && (
                                    <>
                                        <li>Buka aplikasi e-wallet Anda (GoPay, OVO, Dana, dll)</li>
                                        <li>Pilih menu Scan QR</li>
                                        <li>Arahkan kamera ke QR code di atas</li>
                                        <li>Periksa detail pembayaran</li>
                                        <li>Konfirmasi pembayaran</li>
                                    </>
                                )}
                                {order.coreApiDeeplinkUrl && (
                                    <>
                                        <li>Klik tombol di atas untuk membuka aplikasi</li>
                                        <li>Login ke akun Anda</li>
                                        <li>Periksa detail pembayaran</li>
                                        <li>Konfirmasi pembayaran</li>
                                    </>
                                )}
                            </ol>
                        </div>
                    </>
                )}

                {/* Price Summary */}
                <div className="bg-white rounded-xl p-6 shadow-sm border border-gray-100">
                    <h3 className="font-bold mb-4">Rincian Pembayaran</h3>
                    <div className="space-y-3">
                        {order.items.map((item: any, idx: number) => (
                            <div key={idx} className="flex justify-between text-sm">
                                <span className="text-gray-600">{item.product.name} (x{item.quantity})</span>
                                <span className="font-medium">Rp {(item.price * item.quantity).toLocaleString('id-ID')}</span>
                            </div>
                        ))}
                        {order.discountApplied > 0 && (
                            <div className="flex justify-between text-sm text-green-600">
                                <span>Diskon</span>
                                <span className="font-medium">-Rp {order.discountApplied.toLocaleString('id-ID')}</span>
                            </div>
                        )}
                        <div className="pt-3 border-t border-gray-100 flex justify-between items-center">
                            <span className="font-bold">Total Pembayaran</span>
                            <span className="text-2xl font-black text-accent">Rp {order.totalAmount.toLocaleString('id-ID')}</span>
                        </div>
                    </div>
                </div>

            </main>
        </div>
    );
}
