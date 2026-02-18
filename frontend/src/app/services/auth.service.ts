import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { User } from '../models/user.model';
import { UserRole, VALIDATION, DEMO_ACCOUNT_NAMES, DEMO_ACCOUNT_LABELS, DEMO_ACCOUNT_ROLES, DEMO_CREDENTIAL_SUFFIX } from '../models/constants';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private currentUser$ = new BehaviorSubject<User | null>(null);
  private loginAttempts = 0;
  private lockoutTime: Date | null = null;
  private users: User[] = [];

  constructor() {
    this.initDemoUsers();
  }

  private initDemoUsers(): void {
    this.users = DEMO_ACCOUNT_NAMES.map((name, index) => ({
      userId: index + 1,
      username: name,
      credentialDigest: this.computeDigest(name + DEMO_CREDENTIAL_SUFFIX),
      fullName: DEMO_ACCOUNT_LABELS[index],
      role: DEMO_ACCOUNT_ROLES[index],
      isActive: true,
      loginAttempts: 0,
      lastLoginDate: null
    }));
  }

  authenticate(username: string, credential: string): { success: boolean; message: string } {
    if (this.isAccountLocked()) {
      return { success: false, message: 'Account is locked due to too many failed attempts. Please try again later.' };
    }

    const user = this.users.find(
      u => u.username.toLowerCase() === username.toLowerCase() && u.isActive
    );

    if (!user) {
      this.loginAttempts++;
      if (this.loginAttempts >= VALIDATION.MAX_LOGIN_ATTEMPTS) {
        this.lockoutTime = new Date();
        return { success: false, message: `Account locked after ${VALIDATION.MAX_LOGIN_ATTEMPTS} failed attempts.` };
      }
      return {
        success: false,
        message: `Invalid credentials. ${VALIDATION.MAX_LOGIN_ATTEMPTS - this.loginAttempts} attempt(s) remaining.`
      };
    }

    if (user.credentialDigest !== this.computeDigest(credential)) {
      this.loginAttempts++;
      if (this.loginAttempts >= VALIDATION.MAX_LOGIN_ATTEMPTS) {
        this.lockoutTime = new Date();
        return { success: false, message: `Account locked after ${VALIDATION.MAX_LOGIN_ATTEMPTS} failed attempts.` };
      }
      return {
        success: false,
        message: `Invalid credentials. ${VALIDATION.MAX_LOGIN_ATTEMPTS - this.loginAttempts} attempt(s) remaining.`
      };
    }

    this.loginAttempts = 0;
    this.lockoutTime = null;
    user.lastLoginDate = new Date();
    user.loginAttempts = 0;
    this.currentUser$.next(user);
    return { success: true, message: 'Login successful.' };
  }

  logout(): void {
    this.currentUser$.next(null);
  }

  isAuthenticated(): boolean {
    return this.currentUser$.value !== null;
  }

  getCurrentUser(): User | null {
    return this.currentUser$.value;
  }

  getCurrentUser$() {
    return this.currentUser$.asObservable();
  }

  getRemainingAttempts(): number {
    return VALIDATION.MAX_LOGIN_ATTEMPTS - this.loginAttempts;
  }

  isAccountLocked(): boolean {
    if (!this.lockoutTime) {
      return false;
    }
    const elapsed = new Date().getTime() - this.lockoutTime.getTime();
    const lockoutDuration = 30000;
    if (elapsed > lockoutDuration) {
      this.lockoutTime = null;
      this.loginAttempts = 0;
      return false;
    }
    return true;
  }

  computeDigest(input: string): string {
    let hash = 0;
    for (let i = 0; i < input.length; i++) {
      const char = input.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(16);
  }
}
