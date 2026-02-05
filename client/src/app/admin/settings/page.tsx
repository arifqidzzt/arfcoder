'use client';

import { useState, useEffect } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import { useRouter } from 'next/navigation';
import api from '@/lib/api';
import toast from 'react-hot-toast';
import { Settings, Save } from 'lucide-react';
import { GROUPED_PAYMENT_METHODS } from '@/lib/paymentMethods';

export default function SettingsPage() {
    const { token, user } = useAuthStore();
    const router = useRouter();
    const [loading, setLoading] = useState(false);
    const [paymentMode, setPaymentMode] = useState('snap');
    const [defaultMethods, setDefaultMethods] = useState<string[]>([]);

    useEffect(() => {
        if (!token || (user?.role !== 'ADMIN' && user?.role !== 'SUPER_ADMIN')) {
            router.push('/');
            return;
        }

        loadSettings();
    }, [token, user]);

    const loadSettings = async () => {
        try {
            const res = await api.get('/settings');
            setPaymentMode(res.data.paymentMode || 'snap');
            setDefaultMethods(res.data.defaultPaymentMethods || []);
        } catch (error) {
            console.error('Failed to load settings');
        }
    };

    const handleSave = async () => {
        setLoading(true);
        try {
            await api.put('/settings', {
                paymentMode,
                defaultPaymentMethods: defaultMethods
            });
            toast.success('Pengaturan berhasil disimpan!');
        } catch (error: any) {
            toast.error(error.response?.data?.message || 'Gagal menyimpan pengaturan');
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen bg-gray-50 p-8">
            <div className="max-w-4xl mx-auto">
                <div className="bg-white rounded-xl shadow-sm border p-6">
                    <h1 className="text-2xl font-black mb-6 flex items-center gap-2">
                        <Settings />
                        Pengaturan Pembayaran Global
                    </h1>

                    {/* Payment Mode */}
                    <div className="mb-8">
                        <label className="block font-bold mb-3">Mode Pembayaran</label>
                        <div className="space-y-3">
                            <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50 transition">
                                <input
                                    type="radio"
                                    value="snap"
                                    checked={paymentMode === 'snap'}
                                    onChange={() => setPaymentMode('snap')}
                                    className="w-5 h-5"
                                />
                                <div>
                                    <div className="font-semibold">Snap (Otomatis)</div>
                                    <div className="text-sm text-gray-500">Midtrans Snap - Semua metode pembayaran otomatis tersedia</div>
                                </div>
                            </label>

                            <label className="flex items-center gap-3 p-4 border-2 rounded-lg cursor-pointer hover:bg-gray-50 transition">
                                <input
                                    type="radio"
                                    value="core_api"
                                    checked={paymentMode === 'core_api'}
                                    onChange={() => setPaymentMode('core_api')}
                                    className="w-5 h-5"
                                />
                                <div>
                                    <div className="font-semibold">Core API (Manual)</div>
                                    <div className="text-sm text-gray-500">Pilih metode pembayaran manual per produk</div>
                                </div>
                            </label>
                        </div>
                    </div>

                    {/* Default Payment Methods (only for Core API mode) */}
                    {paymentMode === 'core_api' && (
                        <div className="mb-8">
                            <label className="block font-bold mb-3">Metode Pembayaran Default</label>
                            <p className="text-sm text-gray-500 mb-4">
                                Metode yang dipilih akan menjadi default untuk produk yang tidak mengatur metode spesifik
                            </p>

                            {Object.entries(GROUPED_PAYMENT_METHODS).map(([groupName, methods]) => (
                                <div key={groupName} className="mb-4">
                                    <h3 className="text-xs font-semibold text-gray-700 mb-2">{groupName}</h3>
                                    <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
                                        {methods.map(method => (
                                            <label
                                                key={method.id}
                                                className="flex items-center gap-2 p-3 border rounded-lg hover:bg-gray-50 cursor-pointer"
                                            >
                                                <input
                                                    type="checkbox"
                                                    checked={defaultMethods.includes(method.id)}
                                                    onChange={(e) => {
                                                        if (e.target.checked) {
                                                            setDefaultMethods([...defaultMethods, method.id]);
                                                        } else {
                                                            setDefaultMethods(defaultMethods.filter(m => m !== method.id));
                                                        }
                                                    }}
                                                    className="w-4 h-4"
                                                />
                                                <span className="text-sm">{method.name}</span>
                                            </label>
                                        ))}
                                    </div>
                                </div>
                            ))}

                            <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-200">
                                <p className="text-sm text-blue-700">
                                    <strong>📌 Info:</strong> {defaultMethods.length === 0
                                        ? 'Tidak ada metode default. Produk harus mengatur metode sendiri.'
                                        : `${defaultMethods.length} metode terpilih sebagai default`}
                                </p>
                            </div>
                        </div>
                    )}

                    {/* Save Button */}
                    <button
                        onClick={handleSave}
                        disabled={loading}
                        className="w-full md:w-auto px-8 py-3 bg-accent text-white rounded-lg font-bold hover:opacity-90 disabled:bg-gray-300 flex items-center justify-center gap-2"
                    >
                        <Save size={20} />
                        {loading ? 'Menyimpan...' : 'Simpan Pengaturan'}
                    </button>
                </div>
            </div>
        </div>
    );
}
