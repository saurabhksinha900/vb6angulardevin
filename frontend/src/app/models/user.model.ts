import { UserRole } from './constants';

export interface User {
  userId: number;
  username: string;
  credentialDigest: string;
  fullName: string;
  role: UserRole;
  isActive: boolean;
  loginAttempts: number;
  lastLoginDate: Date | null;
}

export function canEditProducts(user: User): boolean {
  return user.role === UserRole.Admin || user.role === UserRole.Manager;
}

export function canDeleteProducts(user: User): boolean {
  return user.role === UserRole.Admin;
}

export function canManageUsers(user: User): boolean {
  return user.role === UserRole.Admin;
}

export function canViewReports(user: User): boolean {
  return true;
}

export function canExportReports(user: User): boolean {
  return user.role === UserRole.Admin || user.role === UserRole.Manager;
}
