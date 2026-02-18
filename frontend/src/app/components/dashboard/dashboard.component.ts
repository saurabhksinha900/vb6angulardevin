import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Router } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { InventoryService } from '../../services/inventory.service';
import { ThemeService } from '../../services/theme.service';
import { UtilityService } from '../../services/utility.service';
import { Product, isLowStock, isOutOfStock, totalValue, getStockStatus } from '../../models/product.model';
import { User, canEditProducts, canDeleteProducts } from '../../models/user.model';
import { ProductCategory, CATEGORY_NAMES, ROLE_NAMES, ReportType, REPORT_NAMES } from '../../models/constants';
import { ReportComponent } from '../report/report.component';
import { AboutComponent } from '../about/about.component';

@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [CommonModule, FormsModule, ReportComponent, AboutComponent],
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit {
  currentUser: User | null = null;
  products: Product[] = [];
  filteredProducts: Product[] = [];
  searchTerm = '';
  selectedCategory: ProductCategory | null = null;
  categories = Object.entries(CATEGORY_NAMES).map(([key, name]) => ({ value: Number(key) as ProductCategory, name }));
  showReportModal = false;
  showAboutModal = false;

  constructor(
    private authService: AuthService,
    private inventoryService: InventoryService,
    private themeService: ThemeService,
    private utilityService: UtilityService,
    private router: Router
  ) {}

  ngOnInit(): void {
    this.currentUser = this.authService.getCurrentUser();
    this.inventoryService.getProducts$().subscribe(products => {
      this.products = products;
      this.applyFilters();
    });
  }

  applyFilters(): void {
    this.filteredProducts = this.inventoryService.searchProducts(this.searchTerm, this.selectedCategory);
  }

  onSearchChange(): void {
    this.applyFilters();
  }

  onCategoryChange(): void {
    this.applyFilters();
  }

  clearFilters(): void {
    this.searchTerm = '';
    this.selectedCategory = null;
    this.applyFilters();
  }

  addProduct(): void {
    this.router.navigate(['/product/new']);
  }

  editProduct(product: Product): void {
    this.router.navigate(['/product', product.productId]);
  }

  deleteProduct(product: Product): void {
    if (confirm(`Are you sure you want to delete "${product.productName}"?`)) {
      this.inventoryService.deleteProduct(product.productId);
    }
  }

  logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }

  toggleTheme(): void {
    this.themeService.toggleTheme();
  }

  isDark(): boolean {
    return this.themeService.isDark();
  }

  canEdit(): boolean {
    return this.currentUser ? canEditProducts(this.currentUser) : false;
  }

  canDelete(): boolean {
    return this.currentUser ? canDeleteProducts(this.currentUser) : false;
  }

  getRoleName(): string {
    return this.currentUser ? ROLE_NAMES[this.currentUser.role] : '';
  }

  getStockStatus(product: Product): string {
    return getStockStatus(product);
  }

  isLowStock(product: Product): boolean {
    return isLowStock(product);
  }

  isOutOfStock(product: Product): boolean {
    return isOutOfStock(product);
  }

  getTotalValue(product: Product): number {
    return totalValue(product);
  }

  getCategoryName(category: ProductCategory): string {
    return CATEGORY_NAMES[category] || 'Unknown';
  }

  formatCurrency(amount: number): string {
    return this.utilityService.formatCurrency(amount);
  }

  getProductCount(): number {
    return this.inventoryService.getProductCount();
  }

  getTotalInventoryValue(): number {
    return this.inventoryService.getTotalInventoryValue();
  }

  getLowStockCount(): number {
    return this.inventoryService.getLowStockCount();
  }

  openReports(): void {
    this.showReportModal = true;
  }

  closeReports(): void {
    this.showReportModal = false;
  }

  openAbout(): void {
    this.showAboutModal = true;
  }

  closeAbout(): void {
    this.showAboutModal = false;
  }
}
