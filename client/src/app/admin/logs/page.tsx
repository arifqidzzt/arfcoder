'use client';

import { useState, useEffect } from 'react';
import api from '@/lib/api';
import { History, User, Monitor } from 'lucide-react';

interface Log {
  id: string;
  action: string;
  details: string;
  ipAddress: string;
  createdAt: string;
  user: { name: string; email: string; role: string };
}

export default function LogsPage() {
  const [logs, setLogs] = useState<Log[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const res = await api.get('/logs');
        setLogs(res.data);
      } catch (error) {
        console.error('Failed to fetch logs');
      } finally {
        setLoading(false);
      }
    };
    fetchLogs();
  }, []);

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold mb-8 flex items-center gap-2">
        <History /> Audit Logs
      </h1>

      <div className="bg-white rounded-3xl border border-gray-100 shadow-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50 border-b border-gray-100">
            <tr>
              <th className="text-left p-6 font-bold text-sm text-gray-500">WAKTU</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">USER</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">AKSI</th>
              <th className="text-left p-6 font-bold text-sm text-gray-500">DETAIL</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={4} className="p-8 text-center">Loading...</td></tr>
            ) : logs.length === 0 ? (
              <tr><td colSpan={4} className="p-8 text-center text-gray-400">Tidak ada log.</td></tr>
            ) : (
              logs.map((log) => (
                <tr key={log.id} className="border-b border-gray-50 hover:bg-gray-50/50">
                  <td className="p-6 text-gray-500 font-mono text-xs">
                    {new Date(log.createdAt).toLocaleString()}
                  </td>
                  <td className="p-6">
                    <div className="flex items-center gap-2">
                      <div className="w-8 h-8 bg-gray-100 rounded-full flex items-center justify-center">
                        <User size={14} />
                      </div>
                      <div>
                        <p className="font-bold text-sm">{log.user.name}</p>
                        <p className="text-xs text-gray-400">{log.user.role}</p>
                      </div>
                    </div>
                  </td>
                  <td className="p-6">
                    <span className={`px-2 py-1 rounded text-xs font-bold bg-blue-50 text-blue-600`}>
                      {log.action}
                    </span>
                  </td>
                  <td className="p-6 text-sm text-gray-600">
                    {log.details}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
