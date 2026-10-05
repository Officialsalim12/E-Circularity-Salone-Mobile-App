// Turns whatever the person typed into one email or one +232 number.
const sierraLeoneCountryCode = '232';

export function normalizeEmail(value: string): string | null {
  const email = value.trim().toLowerCase();
  if (!email || email.length > 254) {
    return null;
  }
  if (!/^[^@]+@[^@]+\.[^@]+$/.test(email)) {
    return null;
  }
  return email;
}

export function normalizeSierraLeonePhone(value: string): string | null {
  const digits = value.replace(/\D/g, '');
  if (!digits) {
    return null;
  }
  let national = digits;
  if (national.startsWith(sierraLeoneCountryCode) && national.length > 3) {
    national = national.slice(sierraLeoneCountryCode.length);
  }
  if (national.startsWith('0')) {
    national = national.slice(1);
  }
  if (!/^\d{8}$/.test(national)) {
    return null;
  }
  return `+${sierraLeoneCountryCode}${national}`;
}
