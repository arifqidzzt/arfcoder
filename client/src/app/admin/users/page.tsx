'use client';

import { useEffect, useState } from 'react';
import api from '@/lib/api';
import { useAuthStore } from '@/store/useAuthStore';
import Link from 'next/link';
import { ArrowLeft, Trash2, Shield } from 'lucide-react';
import toast from 'react-hot-toast';

interface User {
  id: string;
  name: string;
  email: string;
  role: string;
  isVerified: boolean;
  createdAt: string;
}

export default function AdminUsersPage() {
  const [users, setUsers] = useState<User[]>([]);
  const { token } = useAuthStore();

  const fetchUsers = async () => {
    try {
      const res = await api.get('/admin/users');
      setUsers(res.data);
    } catch (error) {
      console.error('Failed to fetch users');
    }
  };

  useEffect(() => {
    if (token) fetchUsers();
  }, [token]);

  const handleDelete = (id: string) => {
    toast((t) => (
      <div className="flex flex-col gap-2 min-w-[200px]">
        <span className="font-bold text-sm">Hapus user ini?</span>
        <div className="flex gap-2 justify-end mt-2">
          <button onClick={() => toast.dismiss(t.id)} className="px-3 py-1.5 bg-gray-100 rounded-lg text-xs font-bold">Batal</button>
          <button onClick={() => confirmDelete(id, t.id)} className="px-3 py-1.5 bg-red-600 text-white rounded-lg text-xs font-bold">Hapus</button>
        </div>
      </div>
    ), { position: 'top-center' });
  };

  const confirmDelete = async (id: string, toastId: string) => {
    toast.dismiss(toastId);
    try {
      await api.delete(`/admin/users/${id}`);
      toast.success('User dihapus');
      fetchUsers();
    } catch (error) { toast.error('Gagal menghapus'); }
  };

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <div className="flex items-center gap-4 mb-8">
           <Link href="/admin" className="p-2 hover:bg-gray-200 rounded-full transition-colors">
             <ArrowLeft size={20} />
           </Link>
           <div>
              <h1 className="text-2xl font-bold">Manajemen Pengguna</h1>
              <p className="text-gray-500">Daftar semua pengguna terdaftar.</p>
           </div>
        </div>

        <div className="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
          <table className="w-full text-left text-sm">
            <thead className="bg-gray-50 border-b border-gray-100">
              <tr>
                <th className="px-6 py-4">Nama</th>
                <th className="px-6 py-4">Email</th>
                <th className="px-6 py-4">Role</th>
                <th className="px-6 py-4">Verified</th>
                <th className="px-6 py-4">Bergabung</th>
                <th className="px-6 py-4 text-right">Aksi</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {users.map((user) => (
                <tr key={user.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 font-medium">{user.name}</td>
                  <td className="px-6 py-4 text-gray-500">{user.email}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded text-xs font-bold ${user.role === 'ADMIN' ? 'bg-purple-100 text-purple-700' : 'bg-gray-100 text-gray-700'}`}>
                      {user.role}
                    </span>
                  </td>
                  <td className="px-6 py-4">
                    {user.isVerified ? <span className="text-green-600 font-bold">Yes</span> : <span className="text-red-500">No</span>}
                  </td>
                  <td className="px-6 py-4 text-gray-500">{new Date(user.createdAt).toLocaleDateString()}</td>
                  <td className="px-6 py-4 text-right">
                    <button 
                      onClick={() => handleDelete(user.id)}
                      className="p-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
                      disabled={user.role === 'SUPER_ADMIN'}
                    >
                      <Trash2 size={18} />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
