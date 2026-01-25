import { useEffect, useState, use } from 'react';
import api from '@/lib/api';
import { useAuthStore } from '@/store/useAuthStore';
import { ArrowLeft, Save, Upload } from 'lucide-react';
import toast from 'react-hot-toast';
import Link from 'next/link';

export default function AdminOrderDetailPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = use(params);
  const [order, setOrder] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const { token } = useAuthStore();
  const [deliveryInfo, setDeliveryInfo] = useState('');

  useEffect(() => {
    if (token) fetchOrder();
  }, [id, token]);

  const fetchOrder = async () => {
    try {
      const res = await api.get(`/orders/${id}`); 
      setOrder(res.data);
      setDeliveryInfo(res.data.deliveryInfo || '');
    } catch (error) {
      toast.error('Gagal memuat pesanan');
    } finally {
      setLoading(false);
    }
  };

  const updateStatus = async (newStatus: string) => {
    try {
      await api.put(`/admin/orders/${id}`, { status: newStatus });
      toast.success(`Status diubah ke ${newStatus}`);
      fetchOrder();
    } catch (error) {
      toast.error('Gagal update status');
    }
  };

  const saveDeliveryInfo = async () => {
    try {
      await api.put(`/admin/orders/${id}/delivery`, { deliveryInfo });
      toast.success('Info pengiriman disimpan');
      updateStatus('SHIPPED'); // Auto update to SHIPPED
    } catch (error) {
      toast.error('Gagal menyimpan info');
    }
  };

  if (loading) return <div className="p-8 text-center">Memuat...</div>;
  if (!order) return <div className="p-8 text-center">Data tidak ditemukan</div>;

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-4xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
           <Link href="/admin/orders" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
             <ArrowLeft size={20} />
           </Link>
           <div>
              <h1 className="text-2xl font-bold">Detail Pesanan #{order.invoiceNumber}</h1>
              <p className="text-gray-500">Kelola pengiriman dan status.</p>
           </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          {/* Main Info */}
          <div className="md:col-span-2 space-y-6">
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
              <h3 className="font-bold mb-4">Item Pesanan</h3>
              {order.items.map((item: any, i: number) => (
                <div key={i} className="flex justify-between py-2 border-b border-gray-50 last:border-0">
                  <span>{item.product.name} (x{item.quantity})</span>
                  <span className="font-mono">Rp {item.price.toLocaleString()}</span>
                </div>
              ))}
              <div className="mt-4 pt-4 border-t border-gray-100 flex justify-between font-bold">
                <span>Total</span>
                <span>Rp {order.totalAmount.toLocaleString()}</span>
              </div>
            </div>

            {/* Delivery Info Input */}
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
              <h3 className="font-bold mb-2">Informasi Pengiriman / Akses Digital</h3>
              <p className="text-xs text-gray-500 mb-4">Masukkan link download, kredensial akun, atau nomor resi di sini. User akan melihat ini di halaman detail pesanan mereka.</p>
              <textarea 
                value={deliveryInfo}
                onChange={(e) => setDeliveryInfo(e.target.value)}
                rows={5}
                className="w-full p-3 border border-gray-200 rounded-lg text-sm focus:border-black focus:outline-none"
                placeholder="Contoh: Link Download: https://... atau Username: user, Pass: 123"
              />
              <button 
                onClick={saveDeliveryInfo}
                className="mt-4 w-full bg-blue-600 text-white py-2 rounded-lg font-bold hover:bg-blue-700 flex items-center justify-center gap-2"
              >
                <Save size={16} /> Simpan & Kirim ke User
              </button>
            </div>

            {/* Refund Handling */}
            {order.refundReason && (
              <div className="bg-red-50 p-6 rounded-xl border border-red-100">
                <h3 className="font-bold text-red-800 mb-2">Pengajuan Refund</h3>
                <div className="bg-white p-3 rounded text-sm mb-4 border border-red-100">
                  <p><strong>Alasan:</strong> {order.refundReason}</p>
                  <p><strong>Rekening:</strong> {order.refundAccount}</p>
                </div>
                
                {order.status === 'REFUND_REQUESTED' && (
                  <div className="flex gap-3">
                    <button onClick={() => updateStatus('REFUND_APPROVED')} className="bg-green-600 text-white px-4 py-2 rounded-lg text-sm font-bold">Terima & Tunggu Pencairan</button>
                    <button onClick={() => updateStatus('REFUND_REJECTED')} className="bg-red-600 text-white px-4 py-2 rounded-lg text-sm font-bold">Tolak</button>
                  </div>
                )}

                {order.status === 'REFUND_APPROVED' && (
                  <div className="mt-4 space-y-3">
                    <label className="text-xs font-bold text-red-800 uppercase tracking-wider">Link Bukti Transfer / No. Referensi</label>
                    <input 
                      type="text" 
                      placeholder="Masukkan link bukti transfer..."
                      className="w-full p-2 border border-red-200 rounded text-sm"
                      id="refundProofInput"
                    />
                    <button 
                      onClick={async () => {
                        const proof = (document.getElementById('refundProofInput') as HTMLInputElement).value;
                        if(!proof) return toast.error('Bukti harus diisi');
                        try {
                          await api.put(`/admin/orders/${id}`, { 
                            status: 'REFUND_COMPLETED',
                            refundProof: proof 
                          });
                          toast.success('Refund Selesai!');
                          fetchOrder();
                        } catch (err) { toast.error('Gagal'); }
                      }}
                      className="w-full bg-red-600 text-white py-2 rounded-lg font-bold text-sm"
                    >
                      Selesaikan Refund
                    </button>
                  </div>
                )}

                {order.status === 'REFUND_COMPLETED' && (
                  <p className="text-sm font-bold text-green-600 mt-2">✅ Refund telah diselesaikan.</p>
                )}
              </div>
            )}
          </div>

          {/* Sidebar Actions */}
          <div className="space-y-6">
            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
              <h3 className="font-bold mb-4">Status Order</h3>
              <select 
                value={order.status}
                onChange={(e) => updateStatus(e.target.value)}
                className="w-full p-2 border border-gray-200 rounded-lg font-bold"
              >
                <option value="PENDING">PENDING</option>
                <option value="PAID">PAID</option>
                <option value="PROCESSING">PROCESSING</option>
                <option value="SHIPPED">SHIPPED</option>
                <option value="COMPLETED">COMPLETED</option>
                <option value="CANCELLED">CANCELLED</option>
                <option value="REFUND_APPROVED">REFUND APPROVED</option>
                <option value="REFUND_COMPLETED">REFUND COMPLETED</option>
              </select>
            </div>

            <div className="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
              <h3 className="font-bold mb-2">Info Pembeli</h3>
              <p className="text-sm"><strong>Nama:</strong> {order.user.name}</p>
              <p className="text-sm"><strong>Email:</strong> {order.user.email}</p>
              <p className="text-sm mt-2"><strong>Alamat/Catatan:</strong></p>
              <p className="text-sm text-gray-500 bg-gray-50 p-2 rounded">{order.address || '-'}</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
