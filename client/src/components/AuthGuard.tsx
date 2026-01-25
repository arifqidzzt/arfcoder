'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/store/useAuthStore';

interface AuthGuardProps {
  children: React.ReactNode;
  adminOnly?: boolean;
}

export default function AuthGuard({ children, adminOnly = false }: AuthGuardProps) {
  const { user, token, hasHydrated } = useAuthStore();
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    if (hasHydrated) {
      if (!token || !user) {
        router.push('/login');
      } else if (adminOnly && user.role !== 'ADMIN' && user.role !== 'SUPER_ADMIN') {
        router.push('/');
      } else {
        setIsReady(true);
      }
    }
  }, [hasHydrated, token, user, adminOnly, router]);

  if (!hasHydrated || !isReady) {
    return <div className="min-h-screen flex items-center justify-center bg-gray-50">Loading...</div>;
  }

  return <>{children}</>;
}
