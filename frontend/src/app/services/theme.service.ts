import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class ThemeService {
  private static readonly STORAGE_KEY = 'inventory-theme-dark';
  private isDark$ = new BehaviorSubject<boolean>(false);

  constructor() {
    this.loadTheme();
  }

  private loadTheme(): void {
    const stored = localStorage.getItem(ThemeService.STORAGE_KEY);
    const isDark = stored === 'true';
    this.isDark$.next(isDark);
    this.applyTheme(isDark);
  }

  toggleTheme(): void {
    const newValue = !this.isDark$.value;
    this.isDark$.next(newValue);
    localStorage.setItem(ThemeService.STORAGE_KEY, String(newValue));
    this.applyTheme(newValue);
  }

  isDark(): boolean {
    return this.isDark$.value;
  }

  isDark$Observable() {
    return this.isDark$.asObservable();
  }

  private applyTheme(isDark: boolean): void {
    if (isDark) {
      document.body.classList.add('dark-theme');
    } else {
      document.body.classList.remove('dark-theme');
    }
  }
}
