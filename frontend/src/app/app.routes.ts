import { Routes } from '@angular/router';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: 'login', loadComponent: () => import('./components/login/login.component').then(m => m.LoginComponent) },
  { path: 'dashboard', loadComponent: () => import('./components/dashboard/dashboard.component').then(m => m.DashboardComponent), canActivate: [authGuard] },
  { path: 'product/new', loadComponent: () => import('./components/product-form/product-form.component').then(m => m.ProductFormComponent), canActivate: [authGuard] },
  { path: 'product/:id', loadComponent: () => import('./components/product-form/product-form.component').then(m => m.ProductFormComponent), canActivate: [authGuard] },
  { path: '', redirectTo: '/login', pathMatch: 'full' },
  { path: '**', redirectTo: '/login' }
];
