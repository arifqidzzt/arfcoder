// Complete Midtrans Core API Payment Methods
// Reference: https://docs.midtrans.com/en/core-api/bank-transfer
// https://docs.midtrans.com/en/core-api/e-wallet

export type PaymentMethodType = 'bank_transfer' | 'echannel' | 'qris' | 'gopay' | 'shopeepay' | 'credit_card';

export interface PaymentMethod {
  id: string;
  name: string;
  type: PaymentMethodType;
  logo?: string;
  description?: string;
}

// Virtual Account / Bank Transfer
export const BANK_TRANSFER_METHODS: PaymentMethod[] = [
  { id: 'bca', name: 'BCA Virtual Account', type: 'bank_transfer', description: 'Transfer via BCA Virtual Account' },
  { id: 'bni', name: 'BNI Virtual Account', type: 'bank_transfer', description: 'Transfer via BNI Virtual Account' },
  { id: 'bri', name: 'BRI Virtual Account', type: 'bank_transfer', description: 'Transfer via BRI Virtual Account' },
  { id: 'permata', name: 'Permata Virtual Account', type: 'bank_transfer', description: 'Transfer via Permata Virtual Account' },
  { id: 'cimb', name: 'CIMB Niaga Virtual Account', type: 'bank_transfer', description: 'Transfer via CIMB Virtual Account' },
  { id: 'mandiri', name: 'Mandiri Bill Payment', type: 'echannel', description: 'Bayar via Mandiri e-channel' },
];

// E-Wallet Methods
export const EWALLET_METHODS: PaymentMethod[] = [
  { id: 'qris', name: 'QRIS (Semua E-Wallet)', type: 'qris', description: 'Scan QR dengan e-wallet apapun' },
  { id: 'gopay', name: 'GoPay', type: 'gopay', description: 'Bayar dengan GoPay' },
  { id: 'shopeepay', name: 'ShopeePay', type: 'shopeepay', description: 'Bayar dengan ShopeePay' },
];

// Credit/Debit Card
export const CARD_METHODS: PaymentMethod[] = [
  { id: 'credit_card', name: 'Kartu Kredit/Debit', type: 'credit_card', description: 'Visa, MasterCard, JCB, Amex' },
];

// All payment methods combined
export const ALL_PAYMENT_METHODS: PaymentMethod[] = [
  ...BANK_TRANSFER_METHODS,
  ...EWALLET_METHODS,
  ...CARD_METHODS,
];

// Helper functions
export const getPaymentMethodById = (id: string): PaymentMethod | undefined => {
  return ALL_PAYMENT_METHODS.find(method => method.id === id);
};

export const getPaymentMethodName = (id: string | undefined): string => {
  if (!id) return 'Unknown';
  const method = getPaymentMethodById(id);
  return method?.name || id.toUpperCase();
};

export const isInstantPayment = (paymentMethodId: string): boolean => {
  return ['qris', 'gopay', 'shopeepay', 'credit_card'].includes(paymentMethodId);
};

export const getPaymentMethodsByType = (type: PaymentMethodType): PaymentMethod[] => {
  return ALL_PAYMENT_METHODS.filter(method => method.type === type);
};

// Group payment methods for UI display
export const GROUPED_PAYMENT_METHODS = {
  'Bank Transfer': BANK_TRANSFER_METHODS,
  'E-Wallet': EWALLET_METHODS,
  'Kartu Kredit/Debit': CARD_METHODS,
};
