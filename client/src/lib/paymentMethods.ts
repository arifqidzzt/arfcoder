// Payment Methods Configuration for Midtrans Core API

export interface PaymentMethod {
  id: string;
  name: string;
  type: 'bank_transfer' | 'ewallet' | 'cstore';
  logo?: string;
  description?: string;
}

export const PAYMENT_METHODS: { [key: string]: PaymentMethod[] } = {
  BANK_TRANSFER: [
    {
      id: 'bca_va',
      name: 'BCA Virtual Account',
      type: 'bank_transfer',
      description: 'Transfer via Virtual Account BCA'
    },
    {
      id: 'bni_va',
      name: 'BNI Virtual Account',
      type: 'bank_transfer',
      description: 'Transfer via Virtual Account BNI'
    },
    {
      id: 'bri_va',
      name: 'BRI Virtual Account',
      type: 'bank_transfer',
      description: 'Transfer via Virtual Account BRI'
    },
    {
      id: 'mandiri_bill',
      name: 'Mandiri Bill Payment',
      type: 'bank_transfer',
      description: 'Bayar via Mandiri Bill Payment'
    },
    {
      id: 'permata_va',
      name: 'Permata Virtual Account',
      type: 'bank_transfer',
      description: 'Transfer via Virtual Account Permata'
    },
  ],
  EWALLET: [
    {
      id: 'qris',
      name: 'QRIS',
      type: 'ewallet',
      description: 'Scan QR Code untuk bayar'
    },
    {
      id: 'gopay',
      name: 'GoPay',
      type: 'ewallet',
      description: 'Bayar dengan GoPay'
    },
    {
      id: 'shopeepay',
      name: 'ShopeePay',
      type: 'ewallet',
      description: 'Bayar dengan ShopeePay'
    },
  ],
};

export const ALL_PAYMENT_METHODS: PaymentMethod[] = [
  ...PAYMENT_METHODS.BANK_TRANSFER,
  ...PAYMENT_METHODS.EWALLET,
];

export function getPaymentMethodById(id: string): PaymentMethod | undefined {
  return ALL_PAYMENT_METHODS.find(pm => pm.id === id);
}

export function getPaymentMethodName(id: string): string {
  const method = getPaymentMethodById(id);
  return method ? method.name : id;
}

export function isInstantPayment(methodId: string): boolean {
  return ['qris', 'gopay', 'shopeepay'].includes(methodId);
}
