import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { ThemeService } from '../../services/theme.service';
import { APP_INFO, DEMO_ACCOUNT_NAMES, DEMO_CREDENTIAL_SUFFIX } from '../../models/constants';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  username = '';
  credential = '';
  errorMessage = '';
  isLoading = false;
  appName = APP_INFO.NAME;
  demoHint = DEMO_ACCOUNT_NAMES.map(n => n + '/' + n + DEMO_CREDENTIAL_SUFFIX).join(', ');

  constructor(
    private authService: AuthService,
    private themeService: ThemeService,
    private router: Router
  ) {
    if (this.authService.isAuthenticated()) {
      this.router.navigate(['/dashboard']);
    }
  }

  onSubmit(): void {
    this.errorMessage = '';
    if (!this.username.trim() || !this.credential.trim()) {
      this.errorMessage = 'Please enter both username and credentials.';
      return;
    }

    this.isLoading = true;
    const result = this.authService.authenticate(this.username, this.credential);
    this.isLoading = false;

    if (result.success) {
      this.router.navigate(['/dashboard']);
    } else {
      this.errorMessage = result.message;
    }
  }

  toggleTheme(): void {
    this.themeService.toggleTheme();
  }

  isDark(): boolean {
    return this.themeService.isDark();
  }
}
